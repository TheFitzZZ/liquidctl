@echo off
setlocal EnableExtensions

set "PS1=%~dp0set-pump-power.ps1"
if not exist "%PS1%" (
  echo ERROR: missing "%PS1%"
  exit /b 2
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%PS1%' 40; exit $LASTEXITCODE"
exit /b %ERRORLEVEL%
