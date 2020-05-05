set(rcid 1 CACHE INTERNAL "rcid")
function(create_resource root input_paths lib)
  set(rc-file-contents "")
  set(emplace-statements "")
  set(offset ${rcid})
  foreach(p ${input_paths})
    file(RELATIVE_PATH rel-path ${root} ${p})
    string(APPEND emplace-statements "    m.emplace(\"${rel-path}\", ${rcid});\n")
    string(APPEND create-statements "    create_resource(${rcid}),\n")
    string(APPEND rc-file-contents "${rcid} RCDATA \"${p}\"\n")
    math(EXPR rcid "${rcid}+1")
    set(rcid ${rcid} CACHE INTERNAL "rcid")
  endforeach(p input_paths)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${lib}/src/resource.rc ${rc-file-contents})
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

#include \"windows.h\"

namespace ${lib} {

resource create_resource(int id) {
  auto const a = FindResource(nullptr, MAKEINTRESOURCEA(id), RT_RCDATA);
  auto const mem = LoadResource(nullptr, a);
  auto const size = SizeofResource(nullptr, a);
  auto const ptr = LockResource(mem);
  return resource{size, ptr};
}

resource make_resource(int id) {
  resource res[] = {
    ${create-statements}\
  };
  return res[id - ${offset}];
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
  add_library(${lib}-res EXCLUDE_FROM_ALL OBJECT ${CMAKE_CURRENT_BINARY_DIR}/${lib}/src/resource.rc)

  add_library(${lib} EXCLUDE_FROM_ALL ${CMAKE_CURRENT_BINARY_DIR}/${lib}/src/${lib}.cc)
  target_compile_features(${lib} PUBLIC cxx_std_17)
  target_include_directories(${lib} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/${lib}/include)
endfunction(create_resource)
