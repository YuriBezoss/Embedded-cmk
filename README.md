
https://pspdfkit.com/blog/2020/visual-studio-code-cpp-docker/

# CMake Configurations
CMake will configure and generate makefiles by default, set all options to their default settings and cache them into a file called CMakeCache.txt in the build directory.
cmake -S . -B build

## invoke your build system
cmake --build build

## run your tests
cmake --build build --target test
ninja test

## run a subset of tests
by passing a regular expression using the -R flag.
```
ctest -R 'Printf.' -j4 --output-on-failure
```

# CMake debugging
## Printing variables
- print statements
```
message(STATUS "MY_VARIABLE=${MY_VARIABLE}")
```
- built in module
```
include(CMakePrintHelpers)
cmake_print_variables(MY_VARIABLE)
```
```
cmake_print_properties(
    TARGETS my_target
    PROPERTIES POSITION_INDEPENDENT_CODE
)
```

# [[Tracing a run]]
- Print with variable
```
cmake -S . -B build --trace-source=CMakeLists.txt
```
- Print with expanded variable
```
cmake -S . -B build --trace-source=CMakeLists.txt --trace-expand
```
- Print with expanded packet/fetch
```
cmake -S . -B build --trace
```