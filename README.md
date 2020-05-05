![Linux Build](https://github.com/motis-project/res/workflows/Linux%20Build/badge.svg)
![Windows Build](https://github.com/motis-project/res/workflows/Windows%20Build/badge.svg)

Embed resources directly into the binary to reduce dependencies to files in the filesystem at runtime.

**CMake**:

    include(create_resource.cmake)

    file(GLOB resources ${CMAKE_CURRENT_SOURCE_DIR}/example.cc)
    create_resource(${CMAKE_CURRENT_SOURCE_DIR} "${resources}" mysrc)

    add_executable(res-example EXCLUDE_FROM_ALL example.cc)
    target_link_libraries(res-example mysrc mysrc-res)


**C++ Code**:

    auto r = mysrc::get_resource("example.cc");
    printf("%zu %p\n", r.size_, r.ptr_);
    printf("%.*s\n", static_cast<int>(r.size_), static_cast<char const*>(r.ptr_));


**Dev**
Compare details of all three implementations:

    meld create_resource_msvc.cmake create_resource_apple.cmake create_resource_default.cmake
