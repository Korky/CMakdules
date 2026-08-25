# ===================================================
# Function register_module(PARAMS)
# ===================================================
# Registers Modules into Build System
# register_module (
#   MODULE_NAME
#       TYPE
#           [STATIC, DYANAMIC]
#       PUBLIC_DEPENDENCIES
#           [Module Name List]
#       PRIVATE_DEPENDENCIES
#           [Module Name List]
#       EXTERNAL_DEPENDENCIES
#           [ThirdParty Libraries to link privately]
#       EXTERNAL_DAISY_CHAINS
#           [ThirdParty Libraries to daisy chain]
# )
# Usage:
# register_module(
#   MyModule 
#       TYPE
#           STATIC
#       PUBLIC_DEPENDENCIES
#           ModuleA
#           ModuleB 
#       PRIVATE_DEPENDENCIES
#           ModuleC 
#       EXTERNAL_DEPENDENCIES
#           pthread
#       EXTERNAL_DAISY_CHAINS
#           GlobalNeededLib
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
            EXTERNAL_DEPENDENCIES 
            EXTERNAL_DAISY_CHAINS
    )
    cmake_parse_arguments(MOD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # sets seprate Var for Target
    set(MODULE_TARGET ${MODULE_NAME})

    message(STATUS "Configuring ${MODULE_NAME} module")
    
    # if no sources files provided scan for common folders
    # TODO: something tells me this will bring issues when having .h in source
    #       like when you have private headers
    if(NOT MOD_SOURCES)
        message(STATUS " -- Scanning for files in ${MODULE_NAME}")
        file(GLOB_RECURSE MOD_SOURCES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cppm"
        )
    endif()

    # if nothing to build stop
    if(NOT MOD_SOURCES)
        message(WARNING "Module ${MODULE_NAME} has no sources. Skipping.")
        return()
    endif()

    add_library(${MODULE_TARGET} STATIC)



    set_source_files_properties(${MOD_SOURCES} PROPERTIES LANGUAGE CXX)

    target_sources(
        ${MODULE_TARGET}
            PUBLIC
                FILE_SET CXX_MODULES
                BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                FILES ${MOD_SOURCES}
    )
  

    # Add EDGE-specific Module Dependencies
    foreach(dep ${MOD_PUBLIC_DEPENDENCIES})
        message(STATUS " -- Adding Public dependancy ${dep}")
        if("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
            target_link_libraries(${MODULE_TARGET} INTERFACE ${dep})
        else()
            target_link_libraries(${MODULE_TARGET} PUBLIC ${dep})
        endif()
    endforeach()
    foreach(dep ${MOD_PRIVATE_DEPENDENCIES})
        message(STATUS " -- Adding Private dependancy ${dep}")
        if("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
            target_link_libraries(${MODULE_TARGET} INTERFACE ${dep})
        else()
            target_link_libraries(${MODULE_TARGET} PRIVATE ${dep})
        endif()
    endforeach()

    # Add External libraries dependencies
    foreach(dep ${MOD_EXTERNAL_DEPENDENCIES})
        message(STATUS " -- Adding External dependancy ${dep}")
        if("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
            target_link_libraries(${MODULE_TARGET} INTERFACE ${dep})
        else()
            target_link_libraries(${MODULE_TARGET} PRIVATE ${dep})
        endif()
    endforeach()
    foreach(dep ${MOD_EXTERNAL_DAISY_CHAINS})
        message(STATUS " -- Adding daisy chained dependancy ${dep}")
        if("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
            target_link_libraries(${MODULE_TARGET} INTERFACE ${dep})
        else()
            target_link_libraries(${MODULE_TARGET} PUBLIC ${dep})
        endif()
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
            message("-- Found Module: ${SUB_DIR}")
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
            CLASSES
            FUNCTIONS
    )
    cmake_parse_arguments(EXP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # TODO: pre-generate with functions and or classes

    message("Module destination: ${CMAKE_CURRENT_SOURCE_DIR}/${IN_DIR}")
    
    set(MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${IN_DIR}/${MODULE_NAME}")
    set(SRC_DIR "${MODULE_DIR}/src")
    
    message("Module directory: ${MODULE_DIR}")
    message("Module name: ${MODULE_NAME}")
    message("Creating module structure for: ${MODULE_NAME}")
    
    file(MAKE_DIRECTORY "${SRC_DIR}")
    
    message("Creating minimal files for: ${MODULE_NAME}")
    
    file(WRITE "${SRC_DIR}/${MODULE_NAME}.cppm" "export module ${MODULE_NAME};\n\n export namespace ${MODULE_NAME} { \n\n\tvoid foo() {}\n\n}")
    file(WRITE "${MODULE_DIR}/CMakeLists.txt" "# ${MODULE_NAME} Module\n # This is a generated CMakeLists.txt for the module.\n\n register_module(${MODULE_NAME})\n")


endfunction()