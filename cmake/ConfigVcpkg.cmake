
##################################################################################
# Clones and bootstrap's vcpkg
# 
# Usage: cmake -P cmake/ConfigVcpkg.cmake
# 
# NOTE: always call from root of project
##################################################################################
message(${CMAKE_CURRENT_SOURCE_DIR})
set(VCPKG_DEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/vcpkg")

# 1. Clone vcpkg if it doesn't exist
if(NOT EXISTS "${VCPKG_DEST_DIR}")
    message(STATUS "Cloning vcpkg...")
    execute_process(
        COMMAND git clone https://github.com/microsoft/vcpkg.git "${VCPKG_DEST_DIR}"
        RESULT_VARIABLE GIT_RESULT
    )
    if(NOT GIT_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to clone vcpkg")
    endif()
endif()

# 2. Run bootstrap script
if(WIN32)
    set(BOOTSTRAP_SCRIPT "${VCPKG_DEST_DIR}/bootstrap-vcpkg.bat")
else()
    set(BOOTSTRAP_SCRIPT "${VCPKG_DEST_DIR}/bootstrap-vcpkg.sh")
endif()

# Check if the executable (vcpkg.exe or vcpkg) already exists
if(WIN32)
    set(VCPKG_EXE "${VCPKG_DEST_DIR}/vcpkg.exe")
else()
    set(VCPKG_EXE "${VCPKG_DEST_DIR}/vcpkg")
endif()

if(NOT EXISTS "${VCPKG_EXE}")
    message(STATUS "Bootstrapping vcpkg...")
    execute_process(
        COMMAND "${BOOTSTRAP_SCRIPT}"
        WORKING_DIRECTORY "${VCPKG_DEST_DIR}"
        RESULT_VARIABLE BOOTSTRAP_RESULT
    )
    if(NOT BOOTSTRAP_RESULT EQUAL 0)
        message(FATAL_ERROR "vcpkg bootstrap failed")
    endif()
endif()


message("Modify CMakePresets.json add cachedVariables \"CMAKE_TOOLCHAIN_FILE\": \"${VCPKG_DEST_DIR}/scripts/buildsystems/vcpkg.cmake\"")

# Create a boilerplate vcpkg.json if it doesn't exist
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg.json")
    set(VCPKG_JSON_CONTENT "{\n  \"name\": \"${PROJECT_NAME_LOWER}\",\n  \"version-string\": \"0.1.0\",\n  \"dependencies\": []\n}")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg.json" "${VCPKG_JSON_CONTENT}")
    message(STATUS "Created boilerplate vcpkg.json at ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg.json")
else()
    message(STATUS "vcpkg.json already exists, skipping creation.")
endif()