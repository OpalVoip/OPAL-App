# OPAL-App

This is a sample program that uses PTLib and OPAL. The project may use
sub-modules, or sit next to the `ptlib` and `opal` checkouts. Source files are
expected in the `src` directory. When bootstrapping a new application, you  may
copy the pattern used here.

Using sub-modules for PTLib/OPAL is useful if specific versions of those
libraries are required for production version control. Alternatively, the
libraries may be shared amongst several applications by placing them in
sibling directories to the applications(s).

The `CMakeLists.txt` should be created by `opal/cmake/OPALNewApp.cmake`, e.g.
```
cmake -DOPAL_NEW_APP_SOURCES=./src -P ./opal/cmake/OPALNewApp.cmake
```
Note, any `-D` options go before `-P`. An existing file is left unchanged
unless `-DOPAL_NEW_APP_FORCE=ON` is set.

## Windows

Visual Studio projects and solutions are configured using the script:
```
.\configure_vs.bat
```
which will automatically detect the latest version of Visual Studio installed
and generate projects and the local `CMakeLists.txt` file mentioned above.

This script uses one `build` directory for all generated output, PTLib/OPAL and
the application itself.

It is expected that a system wide vcpkg installation is available, which is
pointed to by `VCPKG_ROOT`. If this is not set, the script will create a
`vcpkg` directory next to the application directory, checkout the entire vcpkg
system and build the required libraries. This is a one-time operation, and will
take some time to complete.

For "point and click" support, Visual Studio solutions (2022 .sln & 2026 .slnx)
are provided in this sample to build the application. On creating your own app,
you will find a large number of solution projects are not present in the
solution. Simply do a build on the `Configure` project to execute the
`configure_vs.bat`. The solution should then be updated with the new projects
and then be ready for development.

## Linux

For PTLib/OPAL you may follow the instructions in each library to build and
install the libraries into the operating system. So, all headers & binaries
are shared across all applications built on that host.

Alternatively, you may build the libraries in the local directory only. For
example when sub-modules are used:

```sh
cmake -S ./ptlib -B ./build/ptlib
cmake --build ./build/ptlib
cmake -S ./opal -B ./build/opal -DOPAL_PTLIB_DIR=../build/ptlib
cmake --build ./build/opal
cmake -DOPAL_NEW_APP_SOURCES=./src -P ./opal/cmake/OPALNewApp.cmake
cmake -S . -B ./build/App -DOPAL_PTLIB_DIR=./build/ptlib -DOPAL_OPAL_DIR=./build/opal
cmake --build ./build/App
```

## macOS

For PTLib/OPAL you may follow the instructions in each library to build and
install the libraries into the operating system. So, all headers & binaries
are shared across all applications built on that host.

Alternatively, you may build the libraries in the local directory only. Here is
an excerpt from the PTLib instructions:

	Install CMake and the libraries with Homebrew. OpenLDAP and Cyrus SASL are
	keg-only, so point pkg-config at them before configuring PTLib. On an
	Intel Mac, use `/usr/local` in place of `/opt/homebrew`. There is no need
	for `PKG_CONFIG_PATH` as PTLib records those directories during its
	configuration.


Then, when sub-modules are used:
```sh
export PKG_CONFIG_PATH="/opt/homebrew/opt/openldap/lib/pkgconfig:/opt/homebrew/opt/cyrus-sasl/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

cmake -S ./ptlib -B ./build/ptlib -DCMAKE_PREFIX_PATH=/opt/homebrew
cmake --build ./build/ptlib

cmake -S ./opal -B ./build/opal -DCMAKE_PREFIX_PATH=/opt/homebrew -DOPAL_PTLIB_DIR=../build/ptlib
cmake --build ./build/opal

cmake -DOPAL_NEW_APP_SOURCES=./src -P ./opal/cmake/OPALNewApp.cmake
cmake -S . -B ./build/App -DOPAL_PTLIB_DIR=./build/ptlib -DOPAL_OPAL_DIR=./build/opal
cmake --build ./build/App
```
