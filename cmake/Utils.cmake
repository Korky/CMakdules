# Prompt for required variables
function(prompt_user var_name)
    if(NOT DEFINED ${var_name})
        execute_process(
            COMMAND powershell -NoProfile -Command "$value = Read-Host \"Enter value for ${var_name}\"; Write-Output $value"
            RESULT_VARIABLE res
            OUTPUT_VARIABLE out
            ERROR_VARIABLE err
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(NOT res EQUAL 0 OR "${out}" STREQUAL "")
            message(FATAL_ERROR "Could not obtain value for ${var_name} : ${err}")
        endif()
        # Use a normal variable unless you really need to cache it
        set(${var_name} "${out}" CACHE STRING "User-provided ${var_name}" FORCE)
    endif()
endfunction()


function(find_and_replace_in_file in_file)
    # Parsing Optional Params
    set(options)
    set(multiValueArgs
            PLACEHOLDERS
            REPLACEMENTS
    )
    cmake_parse_arguments(FRF "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT FRF_PLACEHOLDERS)
        message(FATAL_ERROR "Missing parameter PLACEHOLDERS.")
    elseif(NOT FRF_REPLACEMENTS)
        message(FATAL_ERROR "Missing parameter REPLACEMENTS.")
    elseif(IS_DIRECTORY "${in_file}")
         message(FATAL_ERROR "${in_file} is a Directory.")
    elseif(NOT EXISTS ${in_file})
        message(FATAL_ERROR "${in_file} does not exist.")
    endif()

    list(LENGTH FRF_PLACEHOLDERS placeholder_count)
    math(EXPR idx_max "${placeholder_count} - 1")

    # Read source content
    file(READ ${in_file} CONTENT)

    # Apply replacements to the content
    foreach(idx RANGE 0 ${idx_max})
        list(GET PLACEHOLDERS ${idx} ph)
        list(GET REPLACEMENTS ${idx} rep)
        string(REPLACE "${ph}" "${rep}" CONTENT "${CONTENT}")
    endforeach()

    # Write the transformed file back to its original location
    file(WRITE ${in_file} ${CONTENT})

endfunction()

function(rename_path old_path new_path)
    # 1. Ensure the source path actually exists
    if(NOT EXISTS "${old_path}")
        message(FATAL_ERROR "Rename failed: Source path does not exist: ${old_path}")
    endif()

    # 2. Perform the atomic move/rename operation
    file(RENAME "${old_path}" "${new_path}" RESULT rename_result)

    # 3. Check for errors (file(RENAME) returns an error string on failure)
    if(rename_result)
        message(FATAL_ERROR "Rename failed from '${old_path}' to '${new_path}'. Reason: ${rename_result}")
    else()
        message(STATUS "Successfully renamed: '${old_path}' -> '${new_path}'")
    endif()
endfunction()
