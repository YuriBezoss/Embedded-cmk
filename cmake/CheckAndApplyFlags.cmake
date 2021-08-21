
# Read enabled languages to determine what functionality to provide
get_property(enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

###########################
# Common Macros/Functions #
###########################

# Change - to _ to generate safe variable names
macro(make_safe_varname input_string output_var)
	string(REPLACE - _ ${output_var} ${input_string})
endmacro()

# Use this function to promote an input argument that represents a list
# such that two layers of dereferencing aren't needed.
# This enables supporting both string and variable inputs with a function arg.
macro(check_and_double_deref input)
	if(NOT "${${${input}}}" STREQUAL "")
		set(${input} ${${${input}}})
	endif()
endmacro()

##############
# C Language #
##############

if("C" IN_LIST enabled_languages)
	include(CheckCCompilerFlag)

	function(apply_supported_c_compiler_flags target scope flag_list)
		check_and_double_deref(flag_list)
		foreach(flag ${flag_list})
			make_safe_varname(${flag} flag_var)
			check_c_compiler_flag(${flag} ${flag_var})

			if(${flag_var})
				target_compile_options(${target} ${scope} ${flag})
			endif()
		endforeach()
	endfunction()
endif()




