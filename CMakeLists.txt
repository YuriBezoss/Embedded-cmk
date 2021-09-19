cmake_minimum_required(VERSION 3.17)
project(EmbeddedArtistryLibc
	VERSION 1.0
	DESCRIPTION "A libc implementation for microcontroller-based embedded systems."
	LANGUAGES C CXX)

set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CPM.cmake)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR LIBC_BUILD_TESTING)
    include(CTest)
endif()

include(cmake/CheckAndApplyFlags.cmake)
include(BuildOptions.cmake)

##################
# Compiler Flags #
##################

# If we're not a subproject, globally apply our warning flags
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  add_compile_options(-Wall -Wextra)
endif()

# This function can be used to generate a linker map file on an executable target
# in a compiler-agnostic way (currently supports GCC and Clang compiler families)
function(target_linker_map target)
  check_c_linker_flag("-Wl,-Map,test.map" _Map1)
  if("${_Map1}")
    set(GEN_MAP_FILE "-Wl,-Map,")
  else()
    check_c_linker_flag("-Wl,-map,test.map" _Map2)
    if("${_Map2}")
      set(GEN_MAP_FILE "-Wl,-map,")
    else()
      message("[WARNING] ${CMAKE_C_COMPILER_ID} does not have a defined linker map argument.")
      return()
    endif()
  endif()

  get_target_property(map_dir ${target} BINARY_DIR)
  target_link_options(${target} PRIVATE ${GEN_MAP_FILE}${map_dir}/${target}.map)
  set_target_properties(${target} PROPERTIES
    ADDITIONAL_CLEAN_FILES ${target}.map)
endfunction()

#####################
# Printf Dependency #
#####################

CPMAddPackage(
  NAME printf
  GITHUB_REPOSITORY mpaland/printf
  VERSION 4.0.0
  DOWNLOAD_ONLY
)

add_library(printf INTERFACE)
target_sources(printf INTERFACE ${printf_SOURCE_DIR}/printf.c)
target_include_directories(printf SYSTEM INTERFACE ${printf_SOURCE_DIR})

if(LIBC_TESTING_IS_ENABLED)
  add_executable(printf_tests)
  target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
  target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR})
  target_linker_map(printf_tests)
  set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)

  # Re-build + execute tests, printing test information to the console instead of the XML file
  add_custom_target(test-printf printf_tests)

  add_test(NAME Printf.Test
    COMMAND printf_tests -s -r junit -o ${CMAKE_BINARY_DIR}/printf_tests.xml
  )
endif()

#######################
# Openlibm Dependency #
#######################

CPMAddPackage(
  NAME openlibm
  GITHUB_REPOSITORY JuliaMath/openlibm
  VERSION 0.7.0
  DOWNLOAD_ONLY
)

add_library(openlibm INTERFACE)
target_include_directories(openlibm SYSTEM INTERFACE
	${openlibm_SOURCE_DIR}/src
	${openlibm_SOURCE_DIR}/include
)

#####################
# CMocka Dependency #
#####################

if(LIBC_TESTING_IS_ENABLED)
  find_package(cmocka QUIET)
  if(NOT cmocka_FOUND)
    CPMAddPackage(
      NAME cmocka
      GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
      VERSION 1.1.5
      GIT_TAG cmocka-1.1.5
      DOWNLOAD_ONLY YES
    )

    # Convenience variable to shorten our code below
    set(CMOCKA_STATIC_FILENAME
      ${CMAKE_STATIC_LIBRARY_PREFIX}cmocka-static${CMAKE_STATIC_LIBRARY_SUFFIX}
    )

    # We would normally use CPMAddPackage, but CMocka's build presents problems.
    # So we include it as an external project, which allows us to build the lib
    # separately and then link it in.
    include(ExternalProject)
    ExternalProject_Add(project_cmocka
      SOURCE_DIR ${cmocka_SOURCE_DIR}
      PREFIX ${CMAKE_CURRENT_BINARY_DIR}/cmocka
      BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/cmocka
      CMAKE_ARGS
        -DBUILD_STATIC_LIB=ON
        -DWITH_STATIC_LIB=ON # Without this, Cmocka will not install the static lib
        -DWITH_EXAMPLES=OFF
        -DCMAKE_BUILD_TYPE=Debug
        -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/cmocka
      # This is needed with Ninja generators to prevent it from failing due to
      # the library being missing before the build has been run
      BUILD_BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/cmocka/lib/${CMOCKA_STATIC_FILENAME}
    )

    # We need to get the CMocka installation directory to know where our
    # built libraries can be found
    ExternalProject_Get_Property(project_cmocka BINARY_DIR)

    # Now we define an IMPORTED library target and tell CMake where the library
    # files can be found. To ensure the build flows in the proper order,
    # we'll add a dependency on the ExternalProject target above, which will
    # ensure the library is built before we try to link it
    add_library(cmocka-static STATIC IMPORTED)
    set_target_properties(cmocka-static PROPERTIES
      IMPORTED_LOCATION ${BINARY_DIR}/lib/${CMOCKA_STATIC_FILENAME}
    )
    add_dependencies(cmocka-static project_cmocka)

    # Maintain build compatibility between find_package and CMakeLists.txt variants.
    set(CMOCKA_LIBRARIES cmocka-static)
    set(CMOCKA_INCLUDE_DIR ${BINARY_DIR}/include)
  endif()
endif()

#######################
# Process Source Tree #
#######################

add_subdirectory(src)

#####################
# Process Test Tree #
#####################

if(LIBC_TESTING_IS_ENABLED)
  add_subdirectory(test)
endif()
