cmake_minimum_required(VERSION 2.9)

project(Hello)

add_subdirectory(hello)

# Android build system refuses to package non-libraries into APKs
# and Google refuses to care about that. The common workaround is
# to rename binaries so that they look like libraries.
set_target_properties(hello
  PROPERTIES
    OUTPUT_NAME lib...hello...so
)
