project(res)
cmake_minimum_required(VERSION 3.13)

include(create_resource.cmake)

set(mysrc-files "${CMAKE_CURRENT_SOURCE_DIR}/example.cc;${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt")
create_resource(${CMAKE_CURRENT_SOURCE_DIR} "${mysrc-files}" mysrc)

file(GLOB resources ${CMAKE_CURRENT_SOURCE_DIR}/.gitignore)
create_resource(${CMAKE_CURRENT_SOURCE_DIR} "${resources}" gitignore)

add_executable(res-example EXCLUDE_FROM_ALL example.cc)
target_link_libraries(res-example mysrc mysrc-res gitignore gitignore-res)