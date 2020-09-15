# don't enclose this all in "if(NOT DEFINED HDF5OK)" because CMake intermittantly doesn't cache needed HDF5 variables.

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.19)
  # make missing imported targets fail immediately
  cmake_policy(SET CMP0111 NEW)
endif()

set(HDF5_USE_STATIC_LIBRARIES true)
# Intel HDF5 for Windows has some real issues from the factory, this makes it work:
if(MSVC)
  set(HDF5_NO_FIND_PACKAGE_CONFIG_FILE true)
  set(HDF5_USE_STATIC_LIBRARIES false)
endif()

if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  find_package(HDF5 COMPONENTS Fortran HL REQUIRED)
else()
  find_package(HDF5 COMPONENTS Fortran HL)
endif()

if(NOT HDF5_FOUND)
  return()
endif()

if(HDF5_Fortran_INCLUDE_DIRS)
  list(APPEND HDF5_INCLUDE_DIRS ${HDF5_Fortran_INCLUDE_DIRS})
endif()
# this is because HDF5's CONFIG files are incorrect (at least for 1.10.5)
find_path(HDF5_MODULE_DIR NAMES hdf5.mod HINTS ${HDF5_INCLUDE_DIRS} PATH_SUFFIXES static)
if(HDF5_MODULE_DIR)
  list(APPEND HDF5_INCLUDE_DIRS ${HDF5_MODULE_DIR})
  set(SZIP_ROOT "${HDF5_MODULE_DIR}/..;${HDF5_MODULE_DIR}/../..")
  set(ZLIB_ROOT "${HDF5_MODULE_DIR}/..;${HDF5_MODULE_DIR}/../..")
endif()
list(REMOVE_DUPLICATES HDF5_INCLUDE_DIRS)

set(HDF5_LIBRARIES ${HDF5_Fortran_HL_LIBRARIES} ${HDF5_Fortran_LIBRARIES} ${HDF5_LIBRARIES})

# --- make imported target
# NOTE: this is coming to CMake 3.19 FindHDF5, but the alpha didn't work for Intel Windows.
add_library(HDF5::HDF5 INTERFACE IMPORTED)
target_include_directories(HDF5::HDF5 INTERFACE "${HDF5_INCLUDE_DIRS}")
target_link_libraries(HDF5::HDF5 INTERFACE "${HDF5_LIBRARIES}")
target_compile_definitions(HDF5::HDF5 INTERFACE "${HDF5_DEFINITIONS}")

set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_REQUIRED_LIBRARIES HDF5::HDF5)

include(CheckSymbolExists)
check_symbol_exists(H5_HAVE_FILTER_SZIP H5pubconf.h use_szip)
check_symbol_exists(H5_HAVE_FILTER_DEFLATE H5pubconf.h use_zlib)

# Szip even though not directly used because if system static links libhdf5 with szip,
# our builds will fail if we don't also link szip.
if(use_szip)
  find_package(SZIP)
  if(SZIP_FOUND)
    list(APPEND HDF5_LIBRARIES SZIP::SZIP)
  endif()
endif(use_szip)

if(use_zlib)
  find_package(ZLIB)
  if(ZLIB_FOUND)
    list(APPEND HDF5_LIBRARIES ZLIB::ZLIB)
  endif()
endif(use_zlib)

set(THREADS_PREFER_PTHREAD_FLAG true)
find_package(Threads)
if(Threads_FOUND)
  list(APPEND HDF5_LIBRARIES Threads::Threads)
endif()

list(APPEND HDF5_LIBRARIES ${CMAKE_DL_LIBS})

if(UNIX)
  list(APPEND HDF5_LIBRARIES m)
endif()

# finish up the HDF5::HDF5 target
target_link_libraries(HDF5::HDF5 INTERFACE "${HDF5_LIBRARIES}")

# if(MSVC)
# didn't work, just copy .dll files
#   # this stanza must be BEFORE if(DEFINED HDF5OK)
#   # this is specifically for Intel compiler with HDF5 1.10 or 1.12 binary install.
#   if(NOT DEFINED HDF5_ROOT AND DEFINED ENV{HDF5_ROOT})
#     file(TO_CMAKE_PATH "$ENV{HDF5_ROOT}" HDF5_ROOT)
#   endif()

#   if(DEFINED HDF5_ROOT)
#     set(ENV{PATH} "${HDF5_ROOT}/bin;$ENV{PATH}")
#   endif()
# endif()

if(NOT DEFINED HDF5OK)
message(STATUS "HDF5 include: ${HDF5_INCLUDE_DIRS}")
message(STATUS "HDF5 library: ${HDF5_LIBRARIES}")
# we don't use broken compiler wrapper
if(MSVC)
  include(${CMAKE_CURRENT_LIST_DIR}/win32_hdf5.cmake)
  win32_hdf5_env()
endif(MSVC)
endif()

# --- configure time checks
# these checks avoid messy, confusing errors at build time

include(CheckFortranSourceCompiles)
set(_code "program test_minimal
use hdf5, only : h5open_f, h5close_f
use h5lt, only : h5ltmake_dataset_f
implicit none (type, external)
integer :: i
call h5open_f(i)
if (i /= 0) error stop 'could not open hdf5 library'
call h5close_f(i)
if (i /= 0) error stop
end")
check_fortran_source_compiles(${_code} HDF5_compiles_ok SRC_EXT f90)

include(CheckFortranSourceRuns)
check_fortran_source_runs(${_code} HDF5_runs_ok SRC_EXT f90)

if(HDF5_compiles_ok)
  if(MSVC OR HDF5_runs_ok)
    # FIXME: MSVC check_fortran_source_runs needs to be set to PROJECT_BINARY_DIR.
    # may require vendoring, so we just do this workaround for now for MSVC.
    set(HDF5OK true CACHE BOOL "HDF5 library compiles and run OK" FORCE)
  endif()
else()
  set(HDF5OK false)
endif()
