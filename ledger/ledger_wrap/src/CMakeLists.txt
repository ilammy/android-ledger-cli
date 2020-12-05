set(LEDGER_WRAP_SRC
    global.cc
    session.cc
)
add_library(ledger_wrap STATIC ${LEDGER_WRAP_SRC})

# Configure public headers of the library.
target_include_directories(ledger_wrap PUBLIC
    ../include
)

# Link the library to libledger.a and all its dependencies
target_link_libraries(ledger_wrap PRIVATE libledger_static)

# Make sure that Ledger source tree is available for includsion,
# including the generated system.hh file placed into build directory
target_include_directories(ledger_wrap PRIVATE
    ../ledger/src
    ${PROJECT_BINARY_DIR}/ledger
)
# ...as well as its dependencies
target_include_directories(ledger_wrap SYSTEM PRIVATE
    ${GMP_PATH}
    ${MPFR_PATH}
    ${UTFCPP_INCLUDE_DIR}
)

# We would like to be able to optimize away most of the wrapper code during linkage.
set_target_properties(ledger_wrap
    PROPERTIES
    INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
)

# And now we need to bundle "ledger_wrap" with all its transitive dependencies
# into a single combined static library. After many experiments and much Googling
# I have not found anything that really works. However, thanks to Cristian Adam:
# https://cristianadam.eu/20190501/bundling-together-static-libraries-with-cmake/
# I have found an inspiration to solve this issue.
# Behold! This is CMake at its full glory! The best build system for C++!
function(bundle_static_library tgt_name bundled_tgt_name)
    # First we need to collect all transitive dependencies which are static libraries.
    list(APPEND static_libs ${tgt_name})

    function(_recursively_collect_dependencies input_target)
        # Choose a property with the dependencies, it's a bit different
        # for normal targets and interface libraries.
        set(_input_link_libraries LINK_LIBRARIES)
        get_target_property(_input_type ${input_target} TYPE)
        if (${_input_type} STREQUAL "INTERFACE_LIBRARY")
            set(_input_link_libraries INTERFACE_LINK_LIBRARIES)
        endif()

        # Now get all direct dependencies and walk through them...
        get_target_property(public_dependencies ${input_target} ${_input_link_libraries})
        foreach(dependency IN LISTS public_dependencies)
            if(TARGET ${dependency})
                # A dependency might be another CMake target.
                # Note that CMake targets might be aliased, resolve that.
                get_target_property(alias ${dependency} ALIASED_TARGET)
                if (TARGET ${alias})
                    set(dependency ${alias})
                endif()

                # If a target is a static library, add it to the list.
                get_target_property(_type ${dependency} TYPE)
                if (${_type} STREQUAL "STATIC_LIBRARY")
                    list(APPEND static_libs ${dependency})
                endif()

                # Then recursively scan through its dependencies too.
                # Make sure to avoid loops and don't scan the same target twice.
                get_property(library_already_added
                    GLOBAL PROPERTY _${tgt_name}_static_bundle_${dependency})
                if (NOT library_already_added)
                    set_property(GLOBAL PROPERTY _${tgt_name}_static_bundle_${dependency} ON)
                    _recursively_collect_dependencies(${dependency})
                endif()
            elseif(EXISTS ${dependency})
                # A dependency might be a path to a library in the filesystem.
                # Just make sure it looks like a static library before adding it.
                if(dependency MATCHES "${CMAKE_STATIC_LIBRARY_SUFFIX}$")
                    list(APPEND static_libs ${dependency})
                endif()
            endif()
        endforeach()

        # Finally export the collected list from the function.
        set(static_libs ${static_libs} PARENT_SCOPE)
    endfunction()

    _recursively_collect_dependencies(${tgt_name})

    # Static library dependencies might be duplicated. Just one copy is enough though.
    list(REMOVE_DUPLICATES static_libs)

    set(bundled_tgt_full_name
        ${PROJECT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${bundled_tgt_name}${CMAKE_STATIC_LIBRARY_SUFFIX})

    # Create an MRI script, instructing platform's "ar" to combine libraries into a bundle.
    # We know this works only for GNU-like compiler toolchain.
    if (CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|GNU)$")
        # We still need CMake to expand some generator expressions there for targets
        # so write stuff into an "input" file first. This is the resulting library:
        file(WRITE ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in
            "CREATE ${bundled_tgt_full_name}\n" )

        # Now, loop through static libraries and list them too.
        # For targets, ask CMake for their output file name.
        foreach(tgt IN LISTS static_libs)
            if(TARGET ${tgt})
                file(APPEND ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in
                    "ADDLIB $<TARGET_FILE:${tgt}>\n")
            else()
                file(APPEND ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in
                    "ADDLIB ${tgt}\n")
            endif()
        endforeach()

        # Wrap up...
        file(APPEND ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in "SAVE\n")
        file(APPEND ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in "END\n")

        # Expand CMake substitutions into an actual MRI script.
        file(GENERATE
            OUTPUT ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri
            INPUT  ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri.in)

        # Finally, add a custom command to build the bundled library with "ar".
        # "ar" in MRI mode does not rebuild the archive if it's already there
        # so make sure to remove it first.
        add_custom_command(
            COMMAND rm -f ${bundled_tgt_full_name}
            COMMAND ${CMAKE_AR} -M < ${PROJECT_BINARY_DIR}/${bundled_tgt_name}.mri
            COMMAND ${CMAKE_RANLIB} ${bundled_tgt_full_name}
            OUTPUT ${bundled_tgt_full_name}
            COMMENT "Bundling ${bundled_tgt_name}"
            VERBATIM)
    else()
        message(FATAL_ERROR "Unknown bundle scenario!")
    endif()

    # Set up an intermediate target which calls our custom bundling command.
    add_custom_target(bundling_target_${bundled_tgt_name}
        ALL DEPENDS ${bundled_tgt_full_name})
    add_dependencies(bundling_target_${bundled_tgt_name} ${tgt_name})

    # And finally, set up a library target, importing the results of the custom command.
    add_library(${bundled_tgt_name} STATIC IMPORTED)
    set_target_properties(${bundled_tgt_name}
        PROPERTIES
        IMPORTED_LOCATION ${bundled_tgt_full_name}
        INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${tgt_name},INTERFACE_INCLUDE_DIRECTORIES>)
    add_dependencies(${bundled_tgt_name} bundling_target_${bundled_tgt_name})

endfunction()

# But first, scan for Boost--copying Ledger CMakeLists.txt--because CMake has
# weird target scoping rules. We need Boost targets here.
find_package(Boost 1.49.0
    REQUIRED date_time filesystem system iostreams regex unit_test_framework)

# And now we can finally set up the amalgamation target.
bundle_static_library(ledger_wrap ledger_amalgam)
