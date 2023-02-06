#include <stdlib.h>

int main() {
    char* buf = malloc(8);
    free(buf);
    free(buf); // double-free
}