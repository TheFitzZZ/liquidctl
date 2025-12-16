@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Aquacomputer D5 Legacy speed setter (callable from anywhere if this folder is on PATH)

if "%~1"=="" goto :usage
if "%~1"=="/?" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="--help" goto :usage

set "SPEED=%~1"

REM Basic numeric validation (only digits)
for /f "delims=0123456789" %%A in ("%SPEED%") do (
  echo ERROR: speed must be an integer percent (e.g. 25..100)
  exit /b 2
)

REM Enforce device constraint: 25..100
if %SPEED% LSS 25 (
  echo ERROR: Aquacomputer D5 Legacy minimum is 25%%
  exit /b 2
)
if %SPEED% GTR 100 (
  echo ERROR: speed cannot be greater than 100%%
  exit /b 2
)

set "REPO=c:\Users\fitzz\Repos\liquidctl"

REM Prefer repo venv python if it exists, otherwise fall back to python/py on PATH.
set "PY=%REPO%\.venv\Scripts\python.exe"
if exist "%PY%" goto :run
set "PY=python"
where /q "%PY%" || set "PY=py -3"

:run
pushd "%REPO%" >nul || (
  echo ERROR: could not cd into "%REPO%"
  exit /b 3
)

%PY% -m liquidctl --match "Aquacomputer D5 Legacy" set pump speed %SPEED%
set "EC=%ERRORLEVEL%"

popd >nul
exit /b %EC%

:usage
echo Usage: %~nx0 ^<speedPercent^>
echo.
echo Example:
echo   %~nx0 100
echo   %~nx0 25
exit /b 1