set(JNI_SRC
    example.cc
    exceptions.cc
    global.cc
    session.cc
)
add_library(ledger_jni SHARED ${JNI_SRC})

# Link the library to libledger.a and all its dependencies
target_link_libraries(ledger_jni PRIVATE libledger)

# Make sure that Ledger source tree is available for includsion,
# including the generated system.hh file placed into build directory
target_include_directories(ledger_jni PRIVATE
    ../ledger/src
    ${PROJECT_BINARY_DIR}/ledger
)
# ...as well as its dependencies
target_include_directories(ledger_jni SYSTEM PRIVATE
    ${GMP_PATH}
    ${MPFR_PATH}
    ${UTFCPP_INCLUDE_DIR}
)

# Apply a version script to the JNI library so that only JNI symbols are exported.
#.CMake 3.13+ provides target_link_options(), but we need to support older versions
# so we use this little hack to add options, since we know we're compiling with Clang.
target_link_libraries(ledger_jni PRIVATE
    "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libledger_jni.version"
)
