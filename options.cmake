message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} CMake ${CMAKE_VERSION} Toolchain ${CMAKE_TOOLCHAIN_FILE}")

include(GNUInstallDirs)

option(find "try to find libraries" on)

option(h5fortran_COVERAGE "Code coverage tests")
option(tidy "Run clang-tidy on the code")

option(matlab "check HDF5 file writes with Matlab")
option(concepts "conceptual testing, for devs only" off)

option(CMAKE_TLS_VERIFY "Verify TLS certificates" on)

option(h5fortran_BUILD_TESTING "build tests" ${h5fortran_IS_TOP_LEVEL})

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)
