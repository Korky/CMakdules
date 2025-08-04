cmake_minimum_required(VERSION 3.21)

# Project
project ("CMakdules" LANGUAGES CXX C)

# Include Macros 
include("cmake/CMakdules.cmake")

add_subdirectory(project_modules)

add_subdirectory(project_app)


add_executable(CMakdulesProgram "project_app/src/project_app.cpp")


target_link_libraries(CMakdulesProgram PRIVATE project_app)


enable_testing()

add_executable(CMakdulesTest "tests/main.cpp")

target_link_libraries(CMakdulesTest PRIVATE module_a)