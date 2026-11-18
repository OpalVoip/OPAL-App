# OPAL-App

A sample program that uses PTLib and OPAL. The sources are in `App`. This directory sits next to the `ptlib` and `opal` checkouts. Build those two libraries first, then this program.

`CMakeLists.txt` is written by `opal/cmake/OPALNewApp.cmake`. `-D` options go before `-P`. An existing file is left unchanged unless `-DOPAL_NEW_APP_FORCE=ON` is set.

## Windows

Visual Studio 2022 writes a `.sln` in `build_2022`. From each directory, in this order:

```bat
ptlib\vs_2022.bat
opal\vs_2022.bat
OPAL-App\vs_2022.bat
```

Open `OPAL-App\build_2022\OPAL-App.sln`. That solution also lists the PTLib and OPAL projects from their `build_2022` directories.

Visual Studio 2026 uses `vs_2026.bat` and writes `build_2026`. The solution file is `OPAL-App\build_2026\OPAL-App.slnx`.

```bat
ptlib\vs_2026.bat
opal\vs_2026.bat
OPAL-App\vs_2026.bat
```

Each script configures that tree. The OPAL-App script also rewrites `CMakeLists.txt` from the template. The scripts share one current vcpkg checkout, `C:\src\vcpkg`, when `VCPKG_ROOT` is unset.

## Linux

From the PTLib directory:

```sh
cmake -S . -B build
cmake --build build
```

From the OPAL directory:

```sh
cmake -S . -B build -DOPAL_PTLIB_DIR=../ptlib/build
cmake --build build
```

From this directory:

```sh
cmake -DOPAL_NEW_APP_SOURCES=App -P ../opal/cmake/OPALNewApp.cmake
cmake -S . -B build
cmake --build build
```

## macOS

Install CMake and the libraries with Homebrew. OpenLDAP and Cyrus SASL are keg-only, so point pkg-config at them before configuring PTLib. On an Intel Mac, use `/usr/local` in place of `/opt/homebrew`.

```sh
export PKG_CONFIG_PATH="/opt/homebrew/opt/openldap/lib/pkgconfig:/opt/homebrew/opt/cyrus-sasl/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
```

From the PTLib directory:

```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/homebrew
cmake --build build
```

From the OPAL directory:

```sh
cmake -S . -B build -DOPAL_PTLIB_DIR=../ptlib/build -DCMAKE_PREFIX_PATH=/opt/homebrew
cmake --build build
```

From this directory:

```sh
cmake -DOPAL_NEW_APP_SOURCES=App -P ../opal/cmake/OPALNewApp.cmake
cmake -S . -B build
cmake --build build
```

The program does not need `PKG_CONFIG_PATH`. PTLib records those directories when it is configured.
