@echo off
setlocal EnableExtensions
cd /d "%~dp0"

where cmake >nul 2>&1
if errorlevel 1 (
  echo cmake was not found on PATH.
  exit /b 1
)

call :generator "%~1"

rem Prefer a current vcpkg. Visual Studio 2022's bundled scripts do not
rem implement REMOVE_DUPLICATES and fail while building expat.
set "VCPKG_DIR=C:\src\vcpkg"
if defined VCPKG_ROOT if exist "%VCPKG_ROOT%\scripts\cmake\vcpkg_host_path_list.cmake" (
  findstr /C:"REMOVE_DUPLICATES" "%VCPKG_ROOT%\scripts\cmake\vcpkg_host_path_list.cmake" >nul
  if not errorlevel 1 set "VCPKG_DIR=%VCPKG_ROOT%"
)
if not exist "%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake" (
  echo Cloning vcpkg into %VCPKG_DIR%
  if not exist "%VCPKG_DIR%\.." mkdir "%VCPKG_DIR%\.."
  where git >nul 2>&1
  if errorlevel 1 (
    echo git was not found on PATH.
    exit /b 1
  )
  git clone https://github.com/microsoft/vcpkg.git "%VCPKG_DIR%"
  if errorlevel 1 exit /b 1
)
findstr /C:"REMOVE_DUPLICATES" "%VCPKG_DIR%\scripts\cmake\vcpkg_host_path_list.cmake" >nul
if errorlevel 1 (
  echo vcpkg at %VCPKG_DIR% does not implement REMOVE_DUPLICATES.
  echo Update it with: git -C "%VCPKG_DIR%" pull
  exit /b 1
)
if not exist "%VCPKG_DIR%\vcpkg.exe" (
  echo Bootstrapping vcpkg
  call "%VCPKG_DIR%\bootstrap-vcpkg.bat" -disableMetrics
  if errorlevel 1 exit /b 1
)
rem Quote only the path. Quoting the whole assignment drops those quotes.
set TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE="%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake"

rem The template writes the checkout locations into CMakeLists.txt.
if not exist CMakeLists.txt (
  set "OPAL_NEW_APP="
  if exist "%~dp0..\opal\cmake\OPALNewApp.cmake" set "OPAL_NEW_APP=%~dp0..\opal\cmake\OPALNewApp.cmake"
  if exist "%~dp0opal\cmake\OPALNewApp.cmake" set "OPAL_NEW_APP=%~dp0opal\cmake\OPALNewApp.cmake"
  if not defined OPAL_NEW_APP (
    echo CMakeLists.txt was not found, and OPALNewApp.cmake was not found under ..\opal or .\opal.
    exit /b 1
  )
  echo CMakeLists.txt was not found, creating it from the OPAL template:
  cmake -DOPAL_NEW_APP_SOURCES=src -P "%OPAL_NEW_APP%"
  if errorlevel 1 exit /b 1
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

set "PTLIB_BUILD=.\build\ptlib"
set "OPAL_BUILD=.\build\opal"

echo ==========================================================================
echo Configuring PTLib (%PTLIB_SRC%) with "%GENERATOR%"
echo vcpkg: %VCPKG_DIR%
if exist "%PTLIB_BUILD%\CMakeCache.txt" (
  findstr /I /C:"%VCPKG_DIR:\=/%/scripts/buildsystems/vcpkg.cmake" "%PTLIB_BUILD%\CMakeCache.txt" >nul
  if errorlevel 1 (
    echo Removing %PTLIB_BUILD% because it was configured with a different vcpkg.
    rmdir /s /q "%PTLIB_BUILD%"
  )
)
cmake -S "%PTLIB_SRC%" -B "%PTLIB_BUILD%" -G "%GENERATOR%" -A x64 -DVCPKG_TARGET_TRIPLET=x64-windows %TOOLCHAIN%
if errorlevel 1 exit /b 1

echo ==========================================================================
echo Configuring OPAL (%OPAL_SRC%) with "%GENERATOR%"
if exist "%OPAL_BUILD%\CMakeCache.txt" (
  findstr /I /C:"%VCPKG_DIR:\=/%/scripts/buildsystems/vcpkg.cmake" "%OPAL_BUILD%\CMakeCache.txt" >nul
  if errorlevel 1 (
    echo Removing %OPAL_BUILD% because it was configured with a different vcpkg.
    rmdir /s /q "%OPAL_BUILD%"
  )
)
cmake -S "%OPAL_SRC%" -B "%OPAL_BUILD%" -G "%GENERATOR%" -A x64 -DVCPKG_TARGET_TRIPLET=x64-windows %TOOLCHAIN% -DOPAL_PTLIB_DIR="%PTLIB_BUILD%"
if errorlevel 1 exit /b 1

rem Ports such as OpenSSL are installed into the library build tree. This
rem application has no vcpkg manifest, so point the toolchain at that tree.
set "VCPKG_INSTALLED="
if exist "%OPAL_BUILD%\vcpkg_installed\." (
  set VCPKG_INSTALLED=-DVCPKG_INSTALLED_DIR="%OPAL_BUILD%\vcpkg_installed" -DVCPKG_TARGET_TRIPLET=x64-windows
  echo vcpkg: %OPAL_BUILD%\vcpkg_installed
) else if exist "%PTLIB_BUILD%\vcpkg_installed\." (
  set VCPKG_INSTALLED=-DVCPKG_INSTALLED_DIR="%PTLIB_BUILD%\vcpkg_installed" -DVCPKG_TARGET_TRIPLET=x64-windows
  echo vcpkg: %PTLIB_BUILD%\vcpkg_installed
)

echo ==========================================================================
echo Configuring the application with "%GENERATOR%"
if exist "build\App\CMakeCache.txt" (
  findstr /I /C:"%VCPKG_DIR:\=/%/scripts/buildsystems/vcpkg.cmake" "build\App\CMakeCache.txt" >nul
  if errorlevel 1 (
    echo Removing build\App because it was configured with a different vcpkg.
    rmdir /s /q "build\App"
  )
)
cmake -S . -B build\App -G "%GENERATOR%" -A x64 %TOOLCHAIN% %VCPKG_INSTALLED% -U OPENSSL_* -DAPP_PTLIB_DIR="%PTLIB_BUILD%" -DAPP_OPAL_DIR="%OPAL_BUILD%"
if errorlevel 1 exit /b 1

echo ==========================================================================
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
