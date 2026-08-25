# project_app Module
 # This is a generated CMakeLists.txt for the module.
add_executable(ProjectNameApp "src/app.cpp" "include/app.h")
target_include_directories(ProjectNameApp PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)
target_link_libraries(ProjectNameApp PRIVATE a_module)