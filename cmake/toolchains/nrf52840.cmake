######################
# nrf52840 Toolchain #
######################

#################
# System Config #
#################

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CPU_NAME cortex-m4)

####################
# Toolchain Config #
####################

set(CMAKE_C_COMPILER    arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER  arm-none-eabi-g++)
set(AS                  arm-none-eabi-as)
set(CMAKE_AR            arm-none-eabi-gcc-ar)
set(OBJCOPY             arm-none-eabi-objcopy)
set(OBJDUMP             arm-none-eabi-objdump)
set(SIZE                arm-none-eabi-size)

# If set to ONLY, then only the roots in CMAKE_FIND_ROOT_PATH (i.e., the host machine)
# will be searched. If set to NEVER, then the roots in CMAKE_FIND_ROOT_PATH will
# be ignored and only the build machine root will be used.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Test compiles will use static libraries, so we won't need to define linker flags
# and scripts for linking to succeed
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

################
# Common Flags #
################
# See the CMake Manual for CMAKE_<LANG>_FLAGS_INIT:
#	https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS_INIT.html

set(CMAKE_C_FLAGS_INIT
	"-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb -fdata-sections -ffunction-sections"
	CACHE
	INTERNAL "Default C compiler flags.")
set(CMAKE_CXX_FLAGS_INIT
	"-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb -fdata-sections -ffunction-sections"
	CACHE
	INTERNAL "Default C++ compiler flags.")
set(CMAKE_EXE_LINKER_FLAGS_INIT
	"-Wl,--gc-sections"
	CACHE
	INTERNAL "Default linker flags.")
