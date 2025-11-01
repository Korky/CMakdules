# Creates barebones for a CMakdules style module
# Usage: cmake -P cmake/CMakdulesUtils/MakeModule.cmake


message("Source directory: ${CMAKE_CURRENT_SOURCE_DIR}")
set(MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(INC_DIR "${MODULE_DIR}/include")
set(SRC_DIR "${MODULE_DIR}/src")
get_filename_component(MODULE_NAME "${MODULE_DIR}" NAME)
message("Module directory: ${MODULE_DIR}")
message("Module name: ${MODULE_NAME}")
message("Creating module structure for: ${MODULE_NAME}")
file(MAKE_DIRECTORY "${INC_DIR}")
file(MAKE_DIRECTORY "${SRC_DIR}")
file(WRITE "${INC_DIR}/${MODULE_NAME}.h" "// ${MODULE_NAME}\n // Boilerplate CMakdule Module.\n\n class ${MODULE_NAME} {};\n")
file(WRITE "${SRC_DIR}/${MODULE_NAME}.cpp" "#include \"${MODULE_NAME}.h\"\n\n ${MODULE_NAME}::${MODULE_NAME}() {}\n")


file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt" "# ${MODULE_NAME} Module\n # This is a generated CMakeLists.txt for the module.\n\n register_module(${MODULE_NAME} TYPE Static)\n")
