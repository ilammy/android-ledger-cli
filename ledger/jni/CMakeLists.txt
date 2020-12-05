set(JNI_SRC
    exceptions.cc
    session.cc
)
add_library(ledger_jni SHARED ${JNI_SRC})

# Link JNI library to Ledger amalgamation library
target_link_libraries(ledger_jni PRIVATE ledger_amalgam)

# Apply a version script to the JNI library so that only JNI symbols are exported.
#.CMake 3.13+ provides target_link_options(), but we need to support older versions
# so we use this little hack to add options, since we know we're compiling with Clang.
target_link_libraries(ledger_jni PRIVATE
    "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libledger_jni.version"
)
