# FindGLFW3.cmake
#
# Defines:
#   GLFW3_INCLUDE_DIR
#   GLFW3_LIBRARY
#   GLFW3_LIBRARY_RELEASE
#   GLFW3_LIBRARY_DEBUG
#   GLFW3_FOUND
#   GLFW3_VERSION
#
# Optional inputs:
#   GLFW3_ROOT  (or env var GLFW3_ROOT) points to the root install folder

cmake_minimum_required(VERSION 3.15)

# -----------------------------
# Roots / search paths
# -----------------------------
set(_glfw3_ENV_ROOT $ENV{GLFW3_ROOT})
if(NOT GLFW3_ROOT AND _glfw3_ENV_ROOT)
  set(GLFW3_ROOT "${_glfw3_ENV_ROOT}")
endif()

# Header search paths
set(_glfw3_HEADER_SEARCH_DIRS
  "/usr/include"
  "/usr/local/include"
  "${CMAKE_SOURCE_DIR}/includes"
  "C:/sdks/glfw/include"
)

# Lib search paths (generic + your exact Debug/Release folders)
set(_glfw3_LIB_SEARCH_DIRS
  "/usr/lib"
  "/usr/local/lib"
  "${CMAKE_SOURCE_DIR}/lib"
  "C:/Program Files (x86)/glfw/lib"
  "C:/sdks/glfw/x64/lib/Release"
  "C:/sdks/glfw/x64/lib/Debug"
)

# Put user-specified root first (supports both layouts)
if(GLFW3_ROOT)
  list(INSERT _glfw3_HEADER_SEARCH_DIRS 0
    "${GLFW3_ROOT}/include"
    "${GLFW3_ROOT}/x64/include"
  )
  list(INSERT _glfw3_LIB_SEARCH_DIRS 0
    "${GLFW3_ROOT}/lib"
    "${GLFW3_ROOT}/x64/lib"
    "${GLFW3_ROOT}/x64/lib/Release"
    "${GLFW3_ROOT}/x64/lib/Debug"
  )
endif()

# -----------------------------
# Find header
# -----------------------------
find_path(GLFW3_INCLUDE_DIR
  NAMES "GLFW/glfw3.h"
  PATHS ${_glfw3_HEADER_SEARCH_DIRS}
)

# -----------------------------
# Find libs (separate Debug/Release for VS multi-config)
# -----------------------------
set(_glfw3_LIB_SEARCH_DIRS_RELEASE
  "C:/sdks/glfw/x64/lib/Release"
  ${_glfw3_LIB_SEARCH_DIRS}
)

set(_glfw3_LIB_SEARCH_DIRS_DEBUG
  "C:/sdks/glfw/x64/lib/Debug"
  ${_glfw3_LIB_SEARCH_DIRS}
)

# Common naming: glfw3.lib (release) and glfw3d.lib (debug)
find_library(GLFW3_LIBRARY_RELEASE
  NAMES glfw3 glfw
  PATHS ${_glfw3_LIB_SEARCH_DIRS_RELEASE}
)

find_library(GLFW3_LIBRARY_DEBUG
  NAMES glfw3d glfw3 glfw
  PATHS ${_glfw3_LIB_SEARCH_DIRS_DEBUG}
)

include(SelectLibraryConfigurations)
select_library_configurations(GLFW3)
# After this, GLFW3_LIBRARY is set appropriately:
# - VS: debug/optimized mapping using RELEASE/DEBUG variants
# - Single-config: picks whatever is available

# -----------------------------
# Parse version from header (optional but helps REQUIRED version checks)
# -----------------------------
if(GLFW3_INCLUDE_DIR AND EXISTS "${GLFW3_INCLUDE_DIR}/GLFW/glfw3.h")
  file(STRINGS "${GLFW3_INCLUDE_DIR}/GLFW/glfw3.h" _glfw3_ver_lines
    REGEX "^#define[ \t]+GLFW_VERSION_(MAJOR|MINOR|REVISION)[ \t]+[0-9]+"
  )
  foreach(_line IN LISTS _glfw3_ver_lines)
    if(_line MATCHES "GLFW_VERSION_MAJOR[ \t]+([0-9]+)")
      set(_glfw3_ver_major "${CMAKE_MATCH_1}")
    elseif(_line MATCHES "GLFW_VERSION_MINOR[ \t]+([0-9]+)")
      set(_glfw3_ver_minor "${CMAKE_MATCH_1}")
    elseif(_line MATCHES "GLFW_VERSION_REVISION[ \t]+([0-9]+)")
      set(_glfw3_ver_rev "${CMAKE_MATCH_1}")
    endif()
  endforeach()

  if(DEFINED _glfw3_ver_major AND DEFINED _glfw3_ver_minor AND DEFINED _glfw3_ver_rev)
    set(GLFW3_VERSION "${_glfw3_ver_major}.${_glfw3_ver_minor}.${_glfw3_ver_rev}")
  endif()
endif()

# -----------------------------
# Standard args + target
# -----------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(glfw3
  REQUIRED_VARS GLFW3_LIBRARY GLFW3_INCLUDE_DIR
  VERSION_VAR GLFW3_VERSION
)

if(GLFW3_FOUND AND NOT TARGET glfw3::glfw)
  add_library(glfw3::glfw UNKNOWN IMPORTED)
  set_target_properties(glfw3::glfw PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GLFW3_INCLUDE_DIR}"
  )

  if(GLFW3_LIBRARY_RELEASE)
    set_target_properties(glfw3::glfw PROPERTIES
      IMPORTED_LOCATION_RELEASE "${GLFW3_LIBRARY_RELEASE}"
    )
  endif()

  if(GLFW3_LIBRARY_DEBUG)
    set_target_properties(glfw3::glfw PROPERTIES
      IMPORTED_LOCATION_DEBUG "${GLFW3_LIBRARY_DEBUG}"
    )
  endif()
endif()