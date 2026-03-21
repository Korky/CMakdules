
##################################################################################
# Creates barebones for a CMakdules style module
# 
# Usage: cmake -P cmake/CMakdulesUtils/MakeModule.cmake [modules_folder] [module_name]
# 
# NOTE: [modules_folder] should be relative path from where script is called.
##################################################################################

message("Module destination: ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_ARGV3}")
set(MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_ARGV3}/${CMAKE_ARGV4}")
set(MODULE_NAME "${CMAKE_ARGV4}")

set(INC_DIR "${MODULE_DIR}/include")
set(SRC_DIR "${MODULE_DIR}/src")
message("Module directory: ${MODULE_DIR}")
message("Module name: ${MODULE_NAME}")
message("Creating module structure for: ${MODULE_NAME}")
file(MAKE_DIRECTORY "${INC_DIR}")
file(MAKE_DIRECTORY "${SRC_DIR}")
file(WRITE "${INC_DIR}/${MODULE_NAME}.h" "#pragma once\n// ${MODULE_NAME}\n\n class ${MODULE_NAME} {\n\t// Boilerplate CMakdule Module.\n\t${MODULE_NAME}() = default;\n\t~${MODULE_NAME}() = default;\n};\n")
file(WRITE "${SRC_DIR}/${MODULE_NAME}.cpp" "#include \"${MODULE_NAME}.h\"\n\n ${MODULE_NAME}::${MODULE_NAME}() {}\n")


file(WRITE "${MODULE_DIR}/CMakeLists.txt" "# ${MODULE_NAME} Module\n # This is a generated CMakeLists.txt for the module.\n\n register_module(${MODULE_NAME} TYPE Static)\n")
