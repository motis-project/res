function(create_resource root input_paths lib)
  set(id 0)
  foreach(p ${input_paths})
    file(RELATIVE_PATH rel-path ${root} ${p})
    string(REGEX REPLACE "[^0-9a-zA-Z]" "_" mangled-path ${rel-path})
    string(APPEND extern-definitions "extern const char _binary_${mangled-path}_start, _binary_${mangled-path}_end;\n")
    string(APPEND resource-statements "  resource{\
static_cast<std::size_t>(&_binary_${mangled-path}_end - &_binary_${mangled-path}_start),\
reinterpret_cast<void const*>(&_binary_${mangled-path}_start)},\n")
    string(APPEND emplace-statements "    m.emplace(\"${rel-path}\", ${id});\r\n")
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${lib}/obj)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${lib}/obj/res_${id}.o
      COMMAND ld -r -b binary -o ${CMAKE_CURRENT_BINARY_DIR}/${lib}/obj/res_${id}.o ${rel-path}
      DEPENDS ${p}
      WORKING_DIRECTORY ${root}
      COMMENT "Generating resource ${rel-path} (${CMAKE_CURRENT_BINARY_DIR}/${lib}/obj/res_${id}.o)"
      VERBATIM
    )
    list(APPEND o-files ${CMAKE_CURRENT_BINARY_DIR}/${lib}/obj/res_${id}.o)
    math(EXPR id "${id}+1")
  endforeach(p input_paths)

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${lib}/include/${lib}.h "\
#pragma once

#include <cstddef>
#include <string>

namespace ${lib} {

struct resource {
  std::size_t size_{0U};
  void const* ptr_{nullptr};
};

resource get_resource(std::string const&);
int get_resource_id(std::string const&);
resource make_resource(int id);

}  // namespace ${lib}
")
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${lib}/src/${lib}.cc "\
#include \"${lib}.h\"

#include <map>
#include <string>

${extern-definitions}

namespace ${lib} {

resource resources[] = {
${resource-statements}\
};

resource make_resource(int id) {
  return resources[id];
}

int get_resource_id(std::string const& s) {
  static auto resources = [] {
    std::map<std::string, int> m;
${emplace-statements}\
    return m;
  }();
  return resources.at(s);
}

resource get_resource(std::string const& s) {
  return make_resource(get_resource_id(s));
}

}  // namespace ${lib}
")
  set_source_files_properties(${o-files} PROPERTIES
    EXTERNAL_OBJECT true
    GENERATED true
  )
  add_library(${lib}-res OBJECT IMPORTED GLOBAL)
  set_target_properties(${lib}-res PROPERTIES IMPORTED_OBJECTS "${o-files}")

  add_library(${lib} EXCLUDE_FROM_ALL STATIC ${CMAKE_CURRENT_BINARY_DIR}/${lib}/src/${lib}.cc)
  target_link_libraries(${lib} ${lib}-res)
  target_compile_features(${lib} PUBLIC cxx_std_17)
  target_include_directories(${lib} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/${lib}/include)
endfunction(create_resource)

