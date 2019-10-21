#include <cstdio>

#include "mysrc.h"

int main() {
  auto r = mysrc::get_resource("example.cc");
  printf("%.*s\n", static_cast<int>(r.size_), static_cast<char const*>(r.ptr_));
}