# Local Resource Cache for Windows Build Dependencies
# This module pre-copies cached files to build directory before plugins are loaded

cmake_minimum_required(VERSION 3.14)

# Get project root directory (3 levels up from build directory)
get_filename_component(PROJECT_ROOT "${CMAKE_BINARY_DIR}/../../.." ABSOLUTE)
set(LOCAL_CACHE_DIR "${PROJECT_ROOT}/build_resources")

message(STATUS "========================================")
message(STATUS "Local Resource Cache Module")
message(STATUS "========================================")
message(STATUS "Project root: ${PROJECT_ROOT}")
message(STATUS "Build directory: ${CMAKE_BINARY_DIR}")
message(STATUS "Cache directory: ${LOCAL_CACHE_DIR}")
message(STATUS "")

# Define dependencies with their MD5 hashes
set(CACHED_DEPENDENCIES
  "mpv-dev-x86_64-20250514-git-4522929.7z;3ad17fccbbbe4b100889020cace5e57f"
  "ANGLE.7z;e866f13e8d552348058afaafe869b1ed"
)

# Function to copy cached file to build directory
function(copy_from_cache filename expected_md5)
  set(CACHE_FILE "${LOCAL_CACHE_DIR}/${filename}")
  set(BUILD_FILE "${CMAKE_BINARY_DIR}/${filename}")

  message(STATUS "Checking: ${filename}")

  # Check if file exists in cache
  if(NOT EXISTS "${CACHE_FILE}")
    message(STATUS "  Not found in cache, will be downloaded by plugin")
    return()
  endif()

  # Verify MD5 of cached file
  file(MD5 "${CACHE_FILE}" CACHE_MD5)
  string(TOLOWER "${CACHE_MD5}" CACHE_MD5_LOWER)
  string(TOLOWER "${expected_md5}" EXPECTED_MD5_LOWER)

  if(NOT EXPECTED_MD5_LOWER STREQUAL CACHE_MD5_LOWER)
    message(WARNING "  Cache file has incorrect MD5!")
    message(WARNING "  Expected: ${EXPECTED_MD5_LOWER}")
    message(WARNING "  Got:      ${CACHE_MD5_LOWER}")
    message(WARNING "  File will be downloaded by plugin")
    return()
  endif()

  message(STATUS "  Found in cache with valid MD5")

  # Check if file already exists in build directory
  if(EXISTS "${BUILD_FILE}")
    file(MD5 "${BUILD_FILE}" BUILD_MD5)
    string(TOLOWER "${BUILD_MD5}" BUILD_MD5_LOWER)

    if(EXPECTED_MD5_LOWER STREQUAL BUILD_MD5_LOWER)
      message(STATUS "  Build file already exists and is valid")
      return()
    else()
      message(STATUS "  Build file exists but MD5 mismatch, replacing...")
      file(REMOVE "${BUILD_FILE}")
    endif()
  endif()

  # Copy from cache to build directory
  message(STATUS "  Copying to build directory...")
  configure_file("${CACHE_FILE}" "${BUILD_FILE}" COPYONLY)

  # Verify the copied file
  file(MD5 "${BUILD_FILE}" COPIED_MD5)
  string(TOLOWER "${COPIED_MD5}" COPIED_MD5_LOWER)

  if(EXPECTED_MD5_LOWER STREQUAL COPIED_MD5_LOWER)
    message(STATUS "  ✓ Successfully copied and verified")
  else()
    message(FATAL_ERROR "  ✗ Copy failed! MD5 mismatch after copy")
  endif()
endfunction()

# Pre-copy all cached dependencies
message(STATUS "Pre-copying cached dependencies...")
message(STATUS "")

# Process mpv-dev dependency
copy_from_cache("mpv-dev-x86_64-20250514-git-4522929.7z" "3ad17fccbbbe4b100889020cace5e57f")
message(STATUS "")

# Process ANGLE dependency
copy_from_cache("ANGLE.7z" "e866f13e8d552348058afaafe869b1ed")
message(STATUS "")

message(STATUS "========================================")
message(STATUS "Cache check complete")
message(STATUS "========================================")
message(STATUS "")
