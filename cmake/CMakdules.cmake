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

    message(STATUS "${MODULE_NAME} Module Found type: ${MOD_TYPE} library")
    
    # if no sources files provided scan for common folders
    # TODO: something tells me this will bring issues when having .h in source
    #       like when you have private headers
    if(NOT MOD_SOURCES)
        message(STATUS " -- Scanning for files in ${MODULE_NAME}")
        file(GLOB_RECURSE MOD_SOURCES
            "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
        )
    endif()

    # if nothing to build stop
    if(NOT MOD_SOURCES)
        message(WARNING "Module ${MODULE_NAME} has no sources. Skipping.")
        return()
    endif()

    
    # Add Library
    if("${MOD_TYPE}" STREQUAL "STATIC")
        add_library(${MODULE_TARGET} STATIC ${MOD_SOURCES})
    elseif("${MOD_TYPE}" STREQUAL "DYNAMIC")
        add_library(${MODULE_TARGET} SHARED ${MOD_SOURCES})
    elseif("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
        add_library(${MODULE_TARGET} INTERFACE ${MOD_SOURCES})
    else()
        add_library(${MODULE_TARGET} ${MOD_SOURCES})
    endif()

    # Add Public/Private include folders if they exist
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        
        if("${MOD_TYPE}" STREQUAL "HEADER_ONLY")
            target_include_directories(${MODULE_TARGET} 
                INTERFACE 
                     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                     $<INSTALL_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            )
        else()
            target_include_directories(${MODULE_TARGET} 
                PUBLIC 
                     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                     $<INSTALL_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            )
        endif()
    endif()

    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
        target_include_directories(${MODULE_TARGET} 
            PRIVATE 
                $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                $<INSTALL_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        )
    endif()

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