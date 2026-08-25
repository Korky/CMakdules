
include("${CMAKE_CURRENT_LIST_DIR}/Utils.cmake")

set(OPERATION "${CMAKE_ARGV3}")

if(NOT OPERATION)
    message(FATAL_ERROR "No operation specified. Use 'help' for more information.")
endif()

# Print Help
if(${OPERATION} STREQUAL "help")
    message("\nusage: cmake -P cmake/CMakdules.cmake [operation] \n\noperations: \n\tinit\n\tnew_module\n\tconfig_vcpkg\n\thelp\n")
endif()

# Init Project
if(${OPERATION} STREQUAL "init")
    prompt_user(PROJECT_NAME)
    prompt_user(MODULE_NAME)
    set(PLACEHOLDERS "ProjectName" "a_module")
    set(REPLACEMENTS "${PROJECT_NAME}" "${MODULE_NAME}")

    # Gather all files in the repository (excluding hidden .git directories and this script)
    file(GLOB_RECURSE ALL_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*")
    foreach(file IN LISTS ALL_FILES)
        if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
            continue()
        endif()

        # Skip hidden .git directories/files
        if(file MATCHES "^\\.git($|/)")
            continue()
        endif()

        # Skip this script itself to avoid re-processing it
        if(file STREQUAL "cmake/CMakdules.cmake")
            continue()
        endif()

        find_and_replace_in_file("${CMAKE_CURRENT_SOURCE_DIR}/${file}" PLACEHOLDERS ${PLACEHOLDERS} REPLACEMENTS ${REPLACEMENTS})
        
    endforeach()

endif()


# New Module Wizard
if(${OPERATION} STREQUAL "new_module")
    prompt_user(MODULES_DIR)
    prompt_user(MODULE_NAME)
    include("${CMAKE_CURRENT_LIST_DIR}/Modules.cmake")
    generate_module(${MODULES_DIR} ${MODULE_NAME})
endif()

# Clone and bootstrap ... TODO add vcpkg.json manifest file
if(${OPERATION} STREQUAL "config_vcpkg")
    include("${CMAKE_CURRENT_LIST_DIR}/ConfigVcpkg.cmake")
endif()