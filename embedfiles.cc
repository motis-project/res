// Based on https://stackoverflow.com/a/11814544

#include <cstdlib>
#include <cstdio>

FILE* open_or_exit(const char* fname, const char* mode) {
  FILE* f = fopen(fname, mode);
  if (f == NULL) {
    perror(fname);
    exit(EXIT_FAILURE);
  }
  return f;
}

int main(int argc, char** argv) {
  if (argc < 4) {
    fprintf(stderr,
            "USAGE: %s DESTINATION_FILE NAMESPACE RES_PATH_1 [RES_PATH_2, ...]\n",
            argv[0]);
    return EXIT_FAILURE;
  }

  FILE* out = open_or_exit(argv[1], "w");
  fprintf(out, "#include <cinttypes>\n");
  fprintf(out, "namespace %s {\n", argv[2]);
  fprintf(out, "std::uint8_t base_[] = {\n");

  size_t total_bytes = 0;
  for (int i = 3; i < argc; ++i) {
    FILE* in = open_or_exit(argv[i], "r");

    unsigned char buf[256];
    size_t nread = 0;
    size_t linecount = 0;
    do {
      nread = fread(buf, 1, sizeof(buf), in);
      size_t i;
      for (i = 0; i < nread; i++) {
        ++total_bytes;
        if (total_bytes != 1) {
          fprintf(out, ", ");
        }
        fprintf(out, "0x%02x", buf[i]);
        if (++linecount == 10) {
          fprintf(out, "\n");
          linecount = 0;
        }
      }
    } while (nread > 0);
    if (linecount > 0) {
      fprintf(out, "\n");
    }

    fclose(in);
  }
  fprintf(out, "};\n");
  fprintf(out, "std::uint8_t* base = &base_[0];\n");
  fprintf(out, "std::uint32_t size = %zu;\n", total_bytes);
  fprintf(out, "}  // namespace %s\n", argv[2]);
  fclose(out);

  return EXIT_SUCCESS;
}