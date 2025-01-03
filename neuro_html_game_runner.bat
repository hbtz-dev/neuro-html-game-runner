@echo off
:: This script uses https://github.com/static-web-server/ to serve webfiles on localhost.
:: Please choose the correct distribution for your OS and architecture.
set "swsUrl=https://github.com/static-web-server/static-web-server/releases/download/v2.34.0/static-web-server-v2.34.0-x86_64-pc-windows-msvc.zip"

set "releaseUrl=https://github.com/hbtz-dev/neuro-html-game-runner/archive/refs/tags/1.0.0.zip"
set "releaseDir=neuro-html-game-runner-1.0.0"

:: Check if the release folder exists
if not exist "%~dp0\%releaseDir%" (
    echo Downloading release...
    powershell -Command "Invoke-WebRequest -Uri '%releaseUrl%' -OutFile '%~dp0\release.zip'"
    echo Extracting release...
    powershell -Command "Expand-Archive -Path '%~dp0\release.zip' -DestinationPath '%~dp0' -Force"
    del "%~dp0\release.zip"
    move "%~dp0\%releaseDir%\neuro_runner_deps" "%~dp0\neuro_runner_deps"
    del "%~dp0\%releaseDir%" /s /q
)

powershell -ExecutionPolicy Bypass -File "%~dp0\neuro_runner_deps\runner.ps1" -swsUrl "%swsUrl%"