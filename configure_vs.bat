@echo off
setlocal EnableExtensions
cd /d "%~dp0"

where cmake >nul 2>&1
if errorlevel 1 (
  echo cmake was not found on PATH.
  exit /b 1
)

call :generator

set "TOOLCHAIN="
if defined VCPKG_ROOT if exist "%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" (
  set "TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
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
echo Configuring App with "%GENERATOR%"
cmake -S App -B build/App -G "%GENERATOR%" -A x64 %TOOLCHAIN% -DPTLIB_PREFIX_DIR=build/ptlib -DOPAL_PREFIX_DIR=build/opal
if errorlevel 1 exit /b 1

echo.
echo Created project files
exit /b 0

:generator
set "GENERATOR=Visual Studio 18 2026"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" exit /b 0
set "VS_MAJOR="
set "VS_YEAR="
for /f "usebackq tokens=1 delims=." %%V in (`"%VSWHERE%" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property catalog_productLineVersion`) do set "VS_MAJOR=%%V"
for /f "usebackq delims=" %%Y in (`"%VSWHERE%" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property catalog_featureReleaseYear`) do set "VS_YEAR=%%Y"
if not defined VS_MAJOR exit /b 0
if not defined VS_YEAR exit /b 0
set "GENERATOR=Visual Studio %VS_MAJOR% %VS_YEAR%"
exit /b 0
