cmake_minimum_required(VERSION 3.30)
set(CMAKE_EXPERIMENTAL_CXX_MODULE_STD ON) 
# Project
project ("ProjectName" LANGUAGES CXX)

# Include Macros 
include("cmake/Modules.cmake")

discover_modules(${CMAKE_CURRENT_SOURCE_DIR}/modules)

add_subdirectory(app)

enable_testing()

add_executable(ProjectNameTest "tests/main.cpp")

target_link_libraries(ProjectNameTest PRIVATE a_module)