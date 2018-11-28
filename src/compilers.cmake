if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-O3)
endif()

if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)

  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    list(APPEND FFLAGS -debug extended -check all -heap-arrays -fp-stack-check)
  endif()
  list(APPEND FFLAGS -warn -traceback)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  list(APPEND FFLAGS -march=native -fimplicit-none)
  
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    list(APPEND FFLAGS -fcheck=all)
  endif()
  
  if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
    list(APPEND FFLAGS -std=f2018)
  endif()
  
  list(APPEND FFLAGS -Wall -Wextra -Wpedantic -Werror=array-bounds -Warray-temporaries)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Flang) 
  list(APPEND FFLAGS -Mallocatable=03)
  link_libraries(-static-flang-libs)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL NAG)
  list(APPEND FFLAGS -u -C=all)
endif()
