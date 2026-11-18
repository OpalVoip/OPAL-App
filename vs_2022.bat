@echo off

set "BUILD_DIR=build_2022"
set "VCPKG_DIR=C:\src\vcpkg"

setlocal EnableExtensions
cd /d "%~dp0"

where cmake >nul 2>&1
if errorlevel 1 (
  echo cmake was not found on PATH.
  exit /b 1
)
where git >nul 2>&1
if errorlevel 1 (
  echo git was not found on PATH.
  exit /b 1
)

if not exist "%~dp0..\opal\cmake\OPALNewApp.cmake" (
  echo The OPAL template was not found at %~dp0..\opal\cmake\OPALNewApp.cmake
  exit /b 1
)
echo Creating CMakeLists.txt
cmake -DOPAL_NEW_APP_FORCE=ON -DOPAL_NEW_APP_SOURCES=App -P "%~dp0..\opal\cmake\OPALNewApp.cmake"
if errorlevel 1 exit /b 1

set "PTLIB_DIR=%~dp0..\ptlib\build_2022"
set "OPAL_DIR=%~dp0..\opal\build_2022"
if not exist "%PTLIB_DIR%\PTLibConfig.cmake" (
  echo PTLib was not configured. Run ptlib\vs_2022.bat first.
  exit /b 1
)
if not exist "%OPAL_DIR%\OPALConfig.cmake" (
  echo OPAL was not configured. Run opal\vs_2022.bat first.
  exit /b 1
)

rem The vcpkg shipped with Visual Studio 2022 does not implement
rem REMOVE_DUPLICATES. Prefer VCPKG_ROOT when that checkout is current,
rem and otherwise use C:\src\vcpkg.
if not defined VCPKG_ROOT goto have_vcpkg_dir
if not exist "%VCPKG_ROOT%\scripts\cmake\vcpkg_host_path_list.cmake" goto have_vcpkg_dir
findstr /C:"REMOVE_DUPLICATES" "%VCPKG_ROOT%\scripts\cmake\vcpkg_host_path_list.cmake" >nul
if not errorlevel 1 set "VCPKG_DIR=%VCPKG_ROOT%"
:have_vcpkg_dir

if exist "%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake" goto vcpkg_present
echo Cloning vcpkg into %VCPKG_DIR%
if not exist "%VCPKG_DIR%\.." mkdir "%VCPKG_DIR%\.."
git clone https://github.com/microsoft/vcpkg.git "%VCPKG_DIR%"
if errorlevel 1 exit /b 1
:vcpkg_present

findstr /C:"REMOVE_DUPLICATES" "%VCPKG_DIR%\scripts\cmake\vcpkg_host_path_list.cmake" >nul
if not errorlevel 1 goto vcpkg_current
echo vcpkg at %VCPKG_DIR% does not implement REMOVE_DUPLICATES.
echo Update it with: git -C "%VCPKG_DIR%" pull
exit /b 1
:vcpkg_current

if exist "%VCPKG_DIR%\vcpkg.exe" goto vcpkg_bootstrapped
echo Bootstrapping vcpkg
call "%VCPKG_DIR%\bootstrap-vcpkg.bat" -disableMetrics
if errorlevel 1 exit /b 1
:vcpkg_bootstrapped

set "VCPKG_INSTALLED=%OPAL_DIR%\vcpkg_installed"
if not exist "%VCPKG_INSTALLED%\." set "VCPKG_INSTALLED=%PTLIB_DIR%\vcpkg_installed"

if not exist "%BUILD_DIR%\CMakeCache.txt" goto configure
findstr /I /C:"%VCPKG_DIR:\=/%/scripts/buildsystems/vcpkg.cmake" "%BUILD_DIR%\CMakeCache.txt" >nul
if not errorlevel 1 goto configure
echo Removing %BUILD_DIR% because it was configured with a different vcpkg.
rmdir /s /q "%BUILD_DIR%"

:configure
echo Configuring OPAL-App with Visual Studio 17 2022
echo PTLib: %PTLIB_DIR%
echo OPAL: %OPAL_DIR%
echo vcpkg: %VCPKG_DIR%
cmake -S . -B "%BUILD_DIR%" -G "Visual Studio 17 2022" -A x64 -DVCPKG_TARGET_TRIPLET=x64-windows -DVCPKG_INSTALLED_DIR="%VCPKG_INSTALLED%" -DAPP_PTLIB_DIR="%PTLIB_DIR%" -DAPP_OPAL_DIR="%OPAL_DIR%" -DCMAKE_TOOLCHAIN_FILE="%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake"
if errorlevel 1 exit /b 1

echo.
echo Created %CD%\%BUILD_DIR%\OPAL-App.sln
exit /b 0
