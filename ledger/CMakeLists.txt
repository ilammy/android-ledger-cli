cmake_minimum_required(VERSION 3.10.2)

project(Ledger)

# Quick check whether the prebuilt library directory exists.
# Top-level makefile should have taken care of this for CI,
# but the user can also build manually from IDE.
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/ledger_wrap/lib)
    message(FATAL_ERROR
        "Prebuilt Ledger libraries misssing.\n"
        "You need to run \"make ledger-libs\" first.")
endif()

# Define the prebuilt Ledger library amalgamation.
add_library(ledger_amalgam STATIC IMPORTED)
set_target_properties(ledger_amalgam
    PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/ledger_wrap/lib/${ANDROID_ABI}/${CMAKE_STATIC_LIBRARY_PREFIX}ledger_amalgam${CMAKE_STATIC_LIBRARY_SUFFIX}"
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/ledger_wrap/include"
)

# Include JNI library.
add_subdirectory(jni)
