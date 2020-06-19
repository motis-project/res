#include <cstdio>

#include "gitignore.h"
#include "mysrc.h"

int main() {
  auto r = mysrc::get_resource("example.cc");
  printf("%zu %p\n", r.size_, r.ptr_);
  printf("%.*s\n", static_cast<int>(r.size_), static_cast<char const*>(r.ptr_));

  printf("\n");

  auto r0 = mysrc::get_resource("CMakeLists.txt");
  printf("%zu %p\n", r0.size_, r0.ptr_);
  printf("%.*s\n", static_cast<int>(r0.size_),
         static_cast<char const*>(r0.ptr_));

  printf("\n");

  auto r1 = gitignore::get_resource(".gitignore");
  printf("%zu %p\n", r1.size_, r1.ptr_);
  printf("%.*s\n", static_cast<int>(r1.size_),
         static_cast<char const*>(r1.ptr_));
}