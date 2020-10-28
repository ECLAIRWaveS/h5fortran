set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo;Debug" CACHE STRING "Build type selections" FORCE)

if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL ${CMAKE_C_COMPILER_ID})
message(FATAL_ERROR "C compiler ${CMAKE_C_COMPILER_ID} does not match Fortran compiler ${CMAKE_Fortran_COMPILER_ID}.
Set environment variables CC and FC to control compiler selection in general.")
endif()

include(CheckFortranCompilerFlag)

if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  if(WIN32)
    add_compile_options(/arch:native)
    string(APPEND CMAKE_Fortran_FLAGS " /stand:f18 /traceback /warn /heap-arrays")
    string(APPEND CMAKE_Fortran_FLAGS_DEBUG " /check:bounds /debug:all")
  else()
    add_compile_options(-march=native)
    string(APPEND CMAKE_Fortran_FLAGS " -stand f18 -traceback -warn -heap-arrays")
    string(APPEND CMAKE_Fortran_FLAGS_DEBUG " -check all -debug extended")
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  add_compile_options(-mtune=native -Wall -Wextra)
  string(APPEND CMAKE_Fortran_FLAGS " -fimplicit-none")
  string(APPEND CMAKE_Fortran_FLAGS_DEBUG " -fcheck=all -Werror=array-bounds")

  check_fortran_compiler_flag(-std=f2018 f18flag)
  if(f18flag)
    string(APPEND CMAKE_Fortran_FLAGS " -std=f2018")
  endif()

  if(CMAKE_Fortran_COMPILER_VERSION VERSION_EQUAL 9.3.0)
    # makes a lot of spurious warnings on alloctable scalar character
    string(APPEND CMAKE_Fortran_FLAGS " -Wno-maybe-uninitialized")
  elseif(CMAKE_Fortran_COMPILER_VERSION VERSION_EQUAL 10.2.0)
    # avoid spurious warning on intrinsic :: rank
    string(APPEND CMAKE_Fortran_FLAGS " -Wno-surprising")
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)
  string(APPEND CMAKE_Fortran_FLAGS " -C -Mdclchk")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Flang)
  string(APPEND CMAKE_Fortran_FLAGS " -W")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL NAG)
  string(APPEND CMAKE_Fortran_FLAGS " -f2018 -u -C=all")
endif()

include(CheckFortranSourceCompiles)
check_fortran_source_compiles("implicit none (type, external); end" f2018impnone SRC_EXT f90)
if(NOT f2018impnone)
  message(FATAL_ERROR "Compiler does not support Fortran 2018 implicit none (type, external): ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
endif()
