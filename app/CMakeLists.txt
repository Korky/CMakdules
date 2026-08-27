# ProjectName App executable CMakeLists.txt
add_executable(ProjectNameApp "src/app.cpp" "include/app.h")

# Legacy Include assuming some developers might need header files.
# **NOTE: one of the goals of CXX Modules is to remove .h and .hpp files.
target_include_directories(ProjectNameApp PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)

# Linking CXX Module
target_link_libraries(ProjectNameApp PRIVATE a_module)