#############
# Cortex-M3 #
#############

# CMake includes the toolchain file multiple times when configuring the build,
# which causes errors for some flags (e.g., --specs=nano.specs).
# We prevent this with an include guard.
if(ARM_CORTEX_M3_TOOLCHAIN_INCLUDED)
	return()
endif()

set(ARM_CORTEX_M3_TOOLCHAIN_INCLUDED true)

set(CPU_NAME cortex-m3)
set(CPU_FLAGS "-mcpu=cortex-m3 -mthumb")
set(VFP_FLAGS "-mfloat-abi=soft")

include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-gcc.cmake)
