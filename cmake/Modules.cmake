# ===================================================
# Function register_module(PARAMS)
# ===================================================
# Registers Modules into Build System
# register_module (
#   MODULE_NAME
#       TYPE
#           [STATIC, DYANAMIC] (Deprecated .. maybe!?)
#       PUBLIC_DEPENDENCIES
#           [Module Name List]
#       PRIVATE_DEPENDENCIES
#           [Module Name List]
# )
# Usage:
# register_module(
#   MyModule 
#       TYPE
#           STATIC (replace for MSVC vs Clang!?)
#       PUBLIC_DEPENDENCIES
#           ModuleA
#           ModuleB 
#       PRIVATE_DEPENDENCIES
#           ModuleC 
#           pthread
#)
# ===================================================

function(register_module MODULE_NAME)
    
    # Parsing Params
    set(options)
    set(oneValueArgs TYPE)
    set(multiValueArgs 
            SOURCES 
            PUBLIC_DEPENDENCIES 
            PRIVATE_DEPENDENCIES
    )
    cmake_parse_arguments(MOD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Sets seprate Var for Target
    set(MODULE_TARGET ${MODULE_NAME})

    message(STATUS "|\tConfiguring ${MODULE_NAME} module")
    
    # if no sources files provided scan for common folders
    if(NOT MOD_SOURCES)
        message(STATUS "|\tScanning for files in ${MODULE_NAME}")
        file(GLOB_RECURSE MOD_SOURCES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cppm"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.ixx"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cxx"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc"
        )
    endif()

    # If nothing to build stop
    if(NOT MOD_SOURCES)
        message(FATAL_ERROR "Module ${MODULE_NAME} has no sources. Skipping.")
        return()
    endif()
    message(STATUS "|\tCreating CXX Module ${MODULE_NAME}")
    # Start C++20 Module Configuration
    add_library(${MODULE_TARGET} STATIC)
    set_source_files_properties(${MOD_SOURCES} PROPERTIES LANGUAGE CXX)
    # Set Module Source Files
    target_sources(
        ${MODULE_TARGET}
            PUBLIC
                FILE_SET CXX_MODULES
                BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                FILES ${MOD_SOURCES}
    )
    # Add Module Dependencies.
    # NOTE: include directories handled at module's CMakeList.txt.
    foreach(dep ${MOD_PUBLIC_DEPENDENCIES})
        message(STATUS "|\tAdding Public dependancy ${dep}")
        target_link_libraries(${MODULE_TARGET} PUBLIC ${dep})
    endforeach()
    foreach(dep ${MOD_PRIVATE_DEPENDENCIES})
        message(STATUS "|\tAdding Private dependancy ${dep}")
        target_link_libraries(${MODULE_TARGET} PRIVATE ${dep})
    endforeach()

    set_target_properties(${MODULE_TARGET} PROPERTIES POSITION_INDEPENDENT_CODE ON)

endfunction()

# ===================================================
# Function discover_modules(PARAMS)
# ===================================================
# Registers Modules into Build System
# register_module (
#   DISCOVERY_PATH
#       [Path to scan for modules]
# )
# It saves the discovered modules in a global property
# DISCOVERED_MODULES that can be retrieved with:
# get_property(MODULES GLOBAL PROPERTY DISCOVERED_MODULES)
# Usage:
# discover_modules(${CMAKE_CURRENT_SOURCE_DIR}/modules)
# ===================================================
function(discover_modules DISCOVERY_PATH)

    message(STATUS "Discovering modules in: ${DISCOVERY_PATH}")

    # Get existing targets property for global use
    get_property(EXISTING_TARGETS GLOBAL PROPERTY DISCOVERED_MODULES)
    if(NOT EXISTING_TARGETS)
        set(EXISTING_TARGETS "")
    endif()
    
    # Discover subdirectories
    file(GLOB SUBMODULE_DIRS RELATIVE ${DISCOVERY_PATH} ${DISCOVERY_PATH}/*)
    foreach(SUB_DIR ${SUBMODULE_DIRS})
        if (IS_DIRECTORY "${DISCOVERY_PATH}/${SUB_DIR}")
            message(STATUS "Found Module: ${SUB_DIR}")
            add_subdirectory("${DISCOVERY_PATH}/${SUB_DIR}")
            # Append to existing targets
            list(APPEND EXISTING_TARGETS ${SUB_DIR})
        endif()
    endforeach()
    # Set the global property for discovered modules
    set_property(GLOBAL PROPERTY DISCOVERED_MODULES "${EXISTING_TARGETS}")
endfunction()

# WIP
function(generate_module IN_DIR MODULE_NAME)

    # Parsing Optional Params
    set(options)
    set(multiValueArgs
            DEPENDENCIES
            CLASSES
            FUNCTIONS
    )
    cmake_parse_arguments(EXP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # TODO: pre-generate with dependencies.

    message("Module destination: ${CMAKE_CURRENT_SOURCE_DIR}/${IN_DIR}")
    
    set(MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${IN_DIR}/${MODULE_NAME}")
    set(SRC_DIR "${MODULE_DIR}/src")
    
    message("Module directory: ${MODULE_DIR}")
    message("Module name: ${MODULE_NAME}")
    message("Creating module structure for: ${MODULE_NAME}")
    
    file(MAKE_DIRECTORY "${SRC_DIR}")
    
    message("Creating minimal files for: ${MODULE_NAME}")
    
    file(WRITE "${SRC_DIR}/${MODULE_NAME}.cppm" "export module ${MODULE_NAME};\n\n export namespace ${MODULE_NAME} { \n\n\tvoid init() {}\n\n}")
    file(WRITE "${MODULE_DIR}/CMakeLists.txt" "# ${MODULE_NAME} Module\n # This is a generated CMakeLists.txt for the module.\n\n register_module(${MODULE_NAME})\n")


endfunction()