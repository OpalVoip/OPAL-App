# OPAL-App

Create `CMakeLists.txt` from the OPAL template in the parent checkout. Run this from this directory. The sources are in `App`. The generated file records that OPAL tree and its sibling PTLib tree.

```bat
cmake -DOPAL_NEW_APP_SOURCES=App -P ..\opal\cmake\OPALNewApp.cmake
```

`-D` options go before `-P`. An existing `CMakeLists.txt` is left unchanged. Replace it with `-DOPAL_NEW_APP_FORCE=ON`.
