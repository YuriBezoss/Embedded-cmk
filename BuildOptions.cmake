###################
# Project Options #
###################

include(CMakeDependentOption)
include(CheckIPOSupported)

check_ipo_supported(RESULT lto_supported)
if("${lto_supported}")
  option(ENABLE_LTO
    "Enable link-time optimization"
    OFF)
endif()

if(NOT ("${ENABLE_LTO}" AND (${CMAKE_C_COMPILER_ID} STREQUAL Clang OR ${CMAKE_C_COMPILER_ID} STREQUAL AppleClang)))
  set(OPTION_DISABLE_BUILTINS_IS_ENABLED True)
else()
  set(OPTION_DISABLE_BUILTINS_IS_ENABLED False)
endif()

option(HIDE_UNIMPLEMENTED_C_APIS
	"Make unimplemented libc functions invisible to the compiler."
	OFF)
option(ENABLE_GNU_EXTENSIONS
  "Enable GNU extensions to the standard libc functions."
  OFF)
option(DISABLE_STACK_PROTECTION
  "Disable stack smashing protection (-fno-stack-protector)."
  ON)
option(NOSTDINC_FOR_DEPENDENTS
  "Disable the -nostdinc flag when using the libc dependency."
  OFF)
CMAKE_DEPENDENT_OPTION(LIBC_BUILD_TESTING
  "Enable libc testing even when used as an external project."
  OFF
  "NOT CMAKE_CROSSCOMPILING" OFF)
CMAKE_DEPENDENT_OPTION(DISABLE_BUILTINS
  "Disable compiler builtins (-fno-builtin)."
  ON
  "${OPTION_DISABLE_BUILTINS_IS_ENABLED}"
  ON)

if((NOT CMAKE_CROSSCOMPILING) AND BUILD_TESTING AND
    (LIBC_BUILD_TESTING OR (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)))
  message("Enabling libc tests.")
  set(LIBC_TESTING_IS_ENABLED ON CACHE INTERNAL "Logic that sets whether testing is enabled on this project")
endif()

if("${ENABLE_LTO}")
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

##############################################
# Default Settings for CMake Cache Variables #
##############################################

# Set a default build type if none was specified
set(default_build_type "RelWithDebInfo")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
      STRING "Choose the type of build."
      FORCE
  )
  # Set the possible values of build type for cmake-gui/ccmake
  set_property(CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo"
  )
endif()

set(default_pic ON)
if("${CMAKE_POSITION_INDEPENDENT_CODE}" STREQUAL "")
  message(STATUS "Setting PIC for all targets to '${default_pic}' as no value was specified.")
  set(CMAKE_POSITION_INDEPENDENT_CODE ${default_pic} CACHE
    BOOL "Compile all targets with -fPIC"
    FORCE
  )
endif()

set(default_shared_libs OFF)
if("${BUILD_SHARED_LIBS}" STREQUAL "")
  message(STATUS "Setting 'build shared libraries' to '${default_shared_libs}' as no value was specified.")
  set(BUILD_SHARED_LIBS ${default_shared_libs} CACHE
    BOOL "Compile shared libraries by default instead of static libraries."
    FORCE
  )
endif()

# Export compile_commands.json file.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
