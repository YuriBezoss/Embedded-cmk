cmake_minimum_required(VERSION 3.17)
project(EmbeddedArtistryLibc
	VERSION 1.0
	DESCRIPTION "A libc implementation for microcontroller-based embedded systems."
	LANGUAGES C CXX)

set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CPM.cmake)

# Only use testing if we're not somebody's subproject!
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    include(CTest)
endif()

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

if(BUILD_TESTING)
  add_executable(printf_tests)
  target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
  target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR})
  set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)

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

find_package(cmocka QUIET)

if(NOT cmocka_FOUND)
  CPMAddPackage(
    NAME cmocka
    GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
    VERSION 1.1.5
    GIT_TAG cmocka-1.1.5
    OPTIONS
      "WITH_EXAMPLES OFF"
      "CMAKE_BUILD_TYPE DEBUG"
  )

  # Maintain build compatibility between find_package and CMakeLists.txt variants.
  set(CMOCKA_LIBRARIES cmocka)
endif()

#######################
# Process Source Tree #
#######################

add_subdirectory(src)
