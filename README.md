# OPAL-App

Create `CMakeLists.txt` from the OPAL template. Run this from this directory, after the `opal` submodule is present. The sources are in `App`.

```bat
cmake -DOPAL_NEW_APP_SOURCES=App -P opal\cmake\OPALNewApp.cmake
```

`-D` options go before `-P`. An existing `CMakeLists.txt` is left unchanged. Replace it with `-DOPAL_NEW_APP_FORCE=ON`.
