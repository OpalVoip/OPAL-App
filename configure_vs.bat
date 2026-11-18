@echo off
setlocal EnableExtensions
cd /d "%~dp0"

where cmake >nul 2>&1
if errorlevel 1 (
  echo cmake was not found on PATH.
  exit /b 1
)

call :generator "%~1"

set "TOOLCHAIN="
if defined VCPKG_ROOT if exist "%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" (
  set TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
)
if not defined TOOLCHAIN echo VCPKG_ROOT is not set. CMake will look for vcpkg.

echo ==========================================================================
echo Configuring PTLib/OPAL with "%GENERATOR%"
cmake -S ptlib -B build/ptlib -G "%GENERATOR%" -A x64 %TOOLCHAIN%
if errorlevel 1 exit /b 1

echo ==========================================================================
echo Configuring OPAL with "%GENERATOR%"
cmake -S opal -B build/opal -G "%GENERATOR%" -A x64 %TOOLCHAIN% -DOPAL_PTLIB_DIR=build/ptlib
if errorlevel 1 exit /b 1

echo ==========================================================================
echo Configuring the application with "%GENERATOR%"
cmake -S . -B build/App -G "%GENERATOR%" -A x64 %TOOLCHAIN% -DAPP_PTLIB_DIR=build/ptlib -DAPP_OPAL_DIR=build/opal
if errorlevel 1 exit /b 1

echo.
echo Created project files
exit /b 0

:generator
if not "%~1"=="" (
  if /I "%~1"=="2017" set "GENERATOR=Visual Studio 15 2017" & exit /b 0
  if /I "%~1"=="2019" set "GENERATOR=Visual Studio 16 2019" & exit /b 0
  if /I "%~1"=="2022" set "GENERATOR=Visual Studio 17 2022" & exit /b 0
  if /I "%~1"=="2026" set "GENERATOR=Visual Studio 18 2026" & exit /b 0
  set "GENERATOR=%~1"
  exit /b 0
)
set "GENERATOR=Visual Studio 17 2022"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" exit /b 0
set "VS_LINE="
for /f "usebackq tokens=1 delims=." %%V in (`"%VSWHERE%" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property catalog_productLineVersion`) do set "VS_LINE=%%V"
if "%VS_LINE%"=="15" set "GENERATOR=Visual Studio 15 2017"
if "%VS_LINE%"=="16" set "GENERATOR=Visual Studio 16 2019"
if "%VS_LINE%"=="17" set "GENERATOR=Visual Studio 17 2022"
if "%VS_LINE%"=="18" set "GENERATOR=Visual Studio 18 2026"
exit /b 0
