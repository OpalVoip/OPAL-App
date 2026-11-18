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

rem The template writes the checkout locations into CMakeLists.txt.
if not exist CMakeLists.txt (
  echo CMakeLists.txt was not found.
  echo Create it from the OPAL template:
  echo   cmake -DOPAL_NEW_APP_SOURCES=App -P ..\opal\cmake\OPALNewApp.cmake
  exit /b 1
)
set "PTLIB_SRC="
set "OPAL_SRC="
for /f "usebackq delims=" %%L in (`findstr /B /C:"set(APP_PTLIB_DIR" CMakeLists.txt`) do (
  for /f tokens^=2^ delims^=^" %%A in ("%%L") do set "PTLIB_SRC=%%A"
)
for /f "usebackq delims=" %%L in (`findstr /B /C:"set(APP_OPAL_DIR" CMakeLists.txt`) do (
  for /f tokens^=2^ delims^=^" %%A in ("%%L") do set "OPAL_SRC=%%A"
)
if not defined PTLIB_SRC (
  echo APP_PTLIB_DIR was not found in CMakeLists.txt.
  exit /b 1
)
if not defined OPAL_SRC (
  echo APP_OPAL_DIR was not found in CMakeLists.txt.
  exit /b 1
)
if not exist "%PTLIB_SRC%\CMakeLists.txt" (
  echo PTLib was not found at %PTLIB_SRC%
  exit /b 1
)
if not exist "%OPAL_SRC%\CMakeLists.txt" (
  echo OPAL was not found at %OPAL_SRC%
  exit /b 1
)

echo ==========================================================================
echo Configuring PTLib with "%GENERATOR%"
echo PTLib: %PTLIB_SRC%
cmake -S "%PTLIB_SRC%" -B "%PTLIB_SRC%\build" -G "%GENERATOR%" -A x64 %TOOLCHAIN%
if errorlevel 1 exit /b 1

echo ==========================================================================
echo Configuring OPAL with "%GENERATOR%"
echo OPAL: %OPAL_SRC%
cmake -S "%OPAL_SRC%" -B "%OPAL_SRC%\build" -G "%GENERATOR%" -A x64 %TOOLCHAIN% -DOPAL_PTLIB_DIR="%PTLIB_SRC%\build"
if errorlevel 1 exit /b 1

echo ==========================================================================
echo Configuring the application with "%GENERATOR%"
rem Ports such as OpenSSL are installed into the library build tree. This
rem application has no vcpkg manifest, so point the toolchain at that tree.
set "VCPKG_INSTALLED="
if exist "%OPAL_SRC%\build\vcpkg_installed\." (
  set VCPKG_INSTALLED=-DVCPKG_INSTALLED_DIR="%OPAL_SRC%\build\vcpkg_installed" -DVCPKG_TARGET_TRIPLET=x64-windows
  echo vcpkg: %OPAL_SRC%\build\vcpkg_installed
) else if exist "%PTLIB_SRC%\build\vcpkg_installed\." (
  set VCPKG_INSTALLED=-DVCPKG_INSTALLED_DIR="%PTLIB_SRC%\build\vcpkg_installed" -DVCPKG_TARGET_TRIPLET=x64-windows
  echo vcpkg: %PTLIB_SRC%\build\vcpkg_installed
)
cmake -S . -B build\App -G "%GENERATOR%" -A x64 %TOOLCHAIN% %VCPKG_INSTALLED% -U OPENSSL_* -DAPP_PTLIB_DIR="%PTLIB_SRC%" -DAPP_OPAL_DIR="%OPAL_SRC%"
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
