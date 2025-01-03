@echo off
:: This script uses https://github.com/static-web-server/ to serve webfiles on localhost.
:: Please choose the correct distribution for your OS and architecture.
set "swsUrl=https://github.com/static-web-server/static-web-server/releases/download/v2.34.0/static-web-server-v2.34.0-x86_64-pc-windows-msvc.zip"

powershell -ExecutionPolicy Bypass -File "%~dp0\neuro_runner_deps\runner.ps1" -swsUrl "%swsUrl%"