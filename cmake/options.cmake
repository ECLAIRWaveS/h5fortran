
option(hdf5_external "Build HDF5 library")
option(autobuild "auto-build HDF5 if missing/broken" on)
option(dev "developer mode")

option(shaky "run shaky tests that may segfault since designed to fail" off)
option(matlab "check HDF5 file writes with Matlab" off)
option(concepts "conceptual testing, for devs only" off)

option(zlib_legacy "use unmaintained ZLIB 1.x")

set(CMAKE_EXPORT_COMPILE_COMMANDS true)

set(CMAKE_TLS_VERIFY true)

if(dev)
else()
  set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)
endif()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
