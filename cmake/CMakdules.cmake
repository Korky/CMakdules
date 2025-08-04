# ===================================================
# Function register_module(PARAMS)
# ===================================================
# Registers Modules into Build System
# register_module (
#   MODULE_NAME
#       TYPE
#           [STATIC, DYANAMIC]
#       PUBLIC_DEPENDENCIES
#           [EDGE Module Name List]
#       PRIVATE_DEPENDENCIES
#           [EDGE Module Name List]
#       EXTERNAL_DEPENDENCIES
#           [ThirdParty Libraries to link privately]
#       EXTERNAL_DAISY_CHAINS
#           [ThirdParty Libraries to daisy chain]
# )

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
    elseif("${MOD_TYPE}" STREQUAL "SHARED")
        add_library(${MODULE_TARGET} SHARED ${MOD_SOURCES})
    else()
        add_library(${MODULE_TARGET} ${MOD_SOURCES})
    endif()

    # Add Public/Private include folders if they exist
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories(${MODULE_TARGET} 
            PUBLIC 
                 $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                 $<INSTALL_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        )
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
        target_link_libraries(${MODULE_TARGET} PUBLIC ${dep})
    endforeach()
    foreach(dep ${MOD_PRIVATE_DEPENDENCIES})
        message(STATUS " -- Adding Private dependancy ${dep}")
        target_link_libraries(${MODULE_TARGET} PRIVATE ${dep})
    endforeach()

    # Add External libraries dependencies
    foreach(dep ${MOD_EXTERNAL_DEPENDENCIES})
        message(STATUS " -- Adding External dependancy ${dep}")
        target_link_libraries(${MODULE_TARGET} PRIVATE ${dep})
    endforeach()
    foreach(dep ${MOD_EXTERNAL_DAISY_CHAINS})
        message(STATUS " -- Adding daisy chained dependancy ${dep}")
        target_link_libraries(${MODULE_TARGET} PUBLIC ${dep})
    endforeach()


endfunction()