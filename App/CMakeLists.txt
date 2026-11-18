# CMakeList.txt : CMake project for App, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.16)

project ("App")

# vcpkg installs manifest dependencies when its toolchain loads inside project().
opal_vcpkg_windows_features()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Hot Reload for MSVC compilers if supported.
if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

set(PTLIB_PREFIX_DIR "" CACHE PATH
  "PTLib install prefix, or a PTLib CMake build directory.")
if(PTLIB_PREFIX_DIR)
  # Force the cache entry. A plain set() loses to a stale PTLib_DIR from a
  # previous configure that found /usr/local (headers without CrashMark).
  if(EXISTS "${PTLIB_PREFIX_DIR}/PTLibConfig.cmake")
    set(PTLib_DIR "${PTLIB_PREFIX_DIR}" CACHE PATH
      "Directory containing PTLibConfig.cmake" FORCE)
  else()
    list(PREPEND CMAKE_PREFIX_PATH "${PTLIB_PREFIX_DIR}")
  endif()
endif()
find_package(PTLib CONFIG REQUIRED)

set(OPAL_PREFIX_DIR "" CACHE PATH
  "OPAL install prefix, or an OPAL CMake build directory.")
if(OPAL_PREFIX_DIR)
  # Force the cache entry. A plain set() loses to a stale OPAL_DIR from a
  # previous configure that found /usr/local (headers without CrashMark).
  if(EXISTS "${OPAL_PREFIX_DIR}/OPALConfig.cmake")
    set(OPAL_DIR "${OPAL_PREFIX_DIR}" CACHE PATH
      "Directory containing OPALConfig.cmake" FORCE)
  else()
    list(PREPEND CMAKE_PREFIX_PATH "${OPAL_PREFIX_DIR}")
  endif()
endif()
find_package(OPAL CONFIG REQUIRED)

# Add source to this project's executable.
add_executable (App "App.cpp" "App.h")
target_link_libraries(App PRIVATE OPAL::opal PTLib::ptlib)

include(GNUInstallDirs)
install(TARGETS App RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
