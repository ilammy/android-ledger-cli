set(JNI_SRC
    exceptions.cc
    session.cc
)
add_library(ledger_jni SHARED ${JNI_SRC})

# Link JNI library to Ledger amalgamation library
target_link_libraries(ledger_jni PRIVATE ledger_amalgam)

# CMake 3.13+ provides target_link_options(), but we need to support older versions.
function(append_flags target property new_flags)
    get_target_property(old_flags ${target} ${property})
    if(old_flags)
        set_target_properties(${target} PROPERTIES ${property} "${old_flags} ${new_flags}")
    else()
        set_target_properties(${target} PROPERTIES ${property} "${new_flags}")
    endif()
endfunction()

# Enable link-time optimizations for release builds because we would like the wrapper
# code to be inlined as much as possible to avoid silly performance losses there.
set_target_properties(ledger_jni
    PROPERTIES
    INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
)

# Also, pass the "-O3" flag to override "-Oz" that Gradle likes to add there
# when LTO is enabled. It is not supported by linker for some architectures.
# https://github.com/android/ndk/issues/721
append_flags(ledger_jni LINK_FLAGS_RELEASE "-O3")

# Apply a version script to the JNI library so that only JNI symbols are exported.
append_flags(ledger_jni LINK_FLAGS
    "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libledger_jni.version")
