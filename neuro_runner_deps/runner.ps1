# This script uses https://github.com/static-web-server/ to serve webfiles on localhost.
# Please choose the correct distribution for your OS and architecture.

param(
    [string]$swsUrl = "https://github.com/static-web-server/static-web-server/releases/download/v2.34.0/static-web-server-v2.34.0-x86_64-pc-windows-msvc.zip",
    [string]$port = "8787"
)

[Environment]::SetEnvironmentVariable("NEURO_SDK_WS_URL", "localhost:8000", 'Process')

$outputZip = "static-web-server.zip"
$outputDir = "neuro_runner_deps/static-web-server"
$zipDirName = $swsUrl.Split('/')[-1].Replace('.zip', '')
$exePath = "$outputDir\$zipDirName\static-web-server.exe"
$publicDir = "."

if (Test-Path $exePath) {

} else {
    # Create directory if it doesn't exist
    New-Item -ItemType Directory -Force -Path $outputDir

    # Download the file
    Write-Host "Downloading Static Web Server..."
    Invoke-WebRequest -Uri $swsUrl -OutFile $outputZip

    # Extract the zip file
    Write-Host "Extracting files..."
    Expand-Archive -Path $outputZip -DestinationPath $outputDir -Force

    # Clean up the zip file
    Write-Host "Cleaning up..."
    Remove-Item $outputZip

    Write-Host "Done! Files extracted to $outputDir"
}

# Function to display menu and handle selection
function Show-Menu {
    param (
        [string]$Title,
        [array]$Options
    )
    
    $selectedIndex = 0
    $pressed = $null
    $maxLength = ($Options | Measure-Object -Property Length -Maximum).Maximum
    
    do {
        Clear-Host
        Write-Host $Title -ForegroundColor Cyan
        Write-Host

        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host ("> " + $Options[$i].PadRight($maxLength)) -ForegroundColor Green
            } else {
                Write-Host ("  " + $Options[$i].PadRight($maxLength)) -ForegroundColor Gray
            }
        }

        $pressed = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($pressed.VirtualKeyCode) {
            38 { # Up arrow
                if ($selectedIndex -gt 0) {
                    $selectedIndex--
                }
                break
            }
            40 { # Down arrow
                if ($selectedIndex -lt ($Options.Count - 1)) {
                    $selectedIndex++
                }
                break
            }
        }
    } while ($pressed.VirtualKeyCode -ne 13) # Enter key

    return $selectedIndex
}


# Scan for HTML game folders
# Write-Host "Scanning for HTML games..." -ForegroundColor Yellow
$folders = Get-ChildItem -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "*.html")
}

if ($folders.Count -eq 0) {
    Write-Host "`nNo HTML games found in neighboring directories." -ForegroundColor Red
    Write-Host "Make sure game folders contain .html files."
    Read-Host "Press Enter to exit"
    exit
}

# Build menu options for folders
$folderOptions = @()
foreach ($folder in $folders) {
    $htmlFiles = Get-ChildItem -Path $folder.FullName -Filter "*.html"
    if ($htmlFiles.Count -eq 1) {
        $folderOptions += "$($folder.Name) ($($htmlFiles[0].Name))"
    } else {
        $folderOptions += "$($folder.Name)"
    }
}

# Show folder selection menu
Write-Host
$title = "These folders look like they might contain HTML games. Which do you want to play?"
$folderIndex = Show-Menu -Title $title -Options $folderOptions

$selectedFolder = $folders[$folderIndex]
$htmlFiles = Get-ChildItem -Path $selectedFolder.FullName -Filter "*.html"

# If multiple HTML files, show second menu
if ($htmlFiles.Count -gt 1) {
    Write-Host
    $title = "The folder $($selectedFolder.Name) has multiple HTML files, which one is the game located at?"
    $htmlOptions = $htmlFiles | ForEach-Object { $_.Name }
    $fileIndex = Show-Menu -Title $title -Options $htmlOptions
    $selectedFile = $htmlFiles[$fileIndex].Name
} else {
    $selectedFile = $htmlFiles[0].Name
}

Write-Host
# Write the neuro sdk variable if present
if (Test-Path env:NEURO_SDK_WS_URL) {
    Write-Host "NEURO_SDK_WS_URL = $env:NEURO_SDK_WS_URL"
    Write-Host "Writing to game directory..."
    New-Item -ItemType Directory -Force -Path "$selectedFolder\`$ENV\"
    $env:NEURO_SDK_WS_URL | Out-File -FilePath "$selectedFolder\`$ENV\NEURO_SDK_WS_URL"
} else {
   Write-Host "NEURO_SDK_WS_URL environment variable is not set."
}

# Start the server
Write-Host
Write-Host "[PLACEHOLDER] Starting local server..." -ForegroundColor Yellow
Write-Host "Game will be running at http://localhost:$port/$selectedFile (Ctrl+Click to open)" -ForegroundColor Cyan

# Attempt to open the browser automatically
Start-Process "http://localhost:$port/$selectedFile"

& $exePath "--port", $port, "--root", $selectedFolder


