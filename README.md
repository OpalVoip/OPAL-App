# OPAL-App

Create `CMakeLists.txt` from the OPAL template in the parent checkout. Run this from this directory. The sources are in `App`. The generated file records that OPAL tree and its sibling PTLib tree.

```bat
cmake -DOPAL_NEW_APP_SOURCES=App -P ..\opal\cmake\OPALNewApp.cmake
```

`-D` options go before `-P`. An existing `CMakeLists.txt` is left unchanged. Replace it with `-DOPAL_NEW_APP_FORCE=ON`.

On Windows, `vs_2022.bat` runs that command when `CMakeLists.txt` is missing, then configures Visual Studio 2022 into `build_2022`. Run `ptlib\vs_2022.bat` and `opal\vs_2022.bat` first.
