#include <cstdio>

#include "mysrc.h"

int main() {
  auto r = mysrc::get_resource("example.cc");
  printf("%zu %p\n", r.size_, r.ptr_);
  printf("%.*s\n", static_cast<int>(r.size_), static_cast<char const*>(r.ptr_));
}