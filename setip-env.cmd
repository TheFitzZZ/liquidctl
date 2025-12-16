@echo off
setlocal EnableExtensions

REM Setup script for this repo on Windows:
REM - creates/uses .venv
REM - upgrades pip tooling
REM - installs the repo + dev/test dependencies

set "REPO=%~dp0"
for %%I in ("%REPO%") do set "REPO=%%~fI"
set "VENV=%REPO%\.venv"
set "PY=%VENV%\Scripts\python.exe"
set "PIP=%PY% -m pip"

echo Repo: "%REPO%"
pushd "%REPO%" >nul || (
  echo ERROR: could not cd into "%REPO%"
  exit /b 1
)

REM Pick a Python launcher.
set "PYLAUNCH=py -3"
%PYLAUNCH% -c "import sys; print(sys.executable)" >nul 2>nul
if errorlevel 1 (
  set "PYLAUNCH=python"
)

if exist "%PY%" (
  echo Using existing venv: "%VENV%"
) else (
  echo Creating venv: "%VENV%"
  %PYLAUNCH% -m venv "%VENV%" || (
    echo ERROR: failed to create venv (need Python 3 installed)
    popd >nul
    exit /b 1
  )
)

echo Upgrading pip/setuptools/wheel...
%PIP% install --upgrade pip setuptools wheel || (
  echo ERROR: failed to upgrade pip tooling
  popd >nul
  exit /b 1
)

REM Install dependencies
REM Prefer a dev requirements file if the repo has one, otherwise install editable + pytest.
if exist "requirements-dev.txt" (
  echo Installing dev requirements from requirements-dev.txt...
  %PIP% install -r requirements-dev.txt || (
    echo ERROR: failed to install requirements-dev.txt
    popd >nul
    exit /b 1
  )
) else if exist "requirements.txt" (
  echo Installing requirements from requirements.txt...
  %PIP% install -r requirements.txt || (
    echo ERROR: failed to install requirements.txt
    popd >nul
    exit /b 1
  )
)

echo Installing this repo in editable mode...
%PIP% install -e . || (
  echo ERROR: failed to install repo (pip install -e .)
  popd >nul
  exit /b 1
)

REM Ensure test runner is available (in case there was no requirements-dev.txt)
echo Ensuring pytest is installed...
%PIP% install -U pytest || (
  echo ERROR: failed to install pytest
  popd >nul
  exit /b 1
)

echo.
echo Done.
echo To activate:
echo   "%VENV%\Scripts\activate.bat"
echo To run:
echo   python -m liquidctl list
echo   pytest
echo.

popd >nul
exit /b 0