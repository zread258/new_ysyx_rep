#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
#define HEAP_SIZE 1024 * 1024

static unsigned long int next = 1;
static char heap_memory[HEAP_SIZE];
static char* addr = heap_memory;
const char* heap_start = heap_memory;
const char* heap_end = heap_memory + sizeof(heap_memory);

int rand(void) {
  // RAND_MAX assumed to be 32767
  next = next * 1103515245 + 12345;
  return (unsigned int)(next/65536) % 32768;
}

void srand(unsigned int seed) {
  next = seed;
}

int abs(int x) {
  return (x < 0 ? -x : x);
}

int atoi(const char* nptr) {
  int x = 0;
  while (*nptr == ' ') { nptr ++; }
  while (*nptr >= '0' && *nptr <= '9') {
    x = x * 10 + *nptr - '0';
    nptr ++;
  }
  return x;
}

void *malloc(size_t size) {
  // On native, malloc() will be called during initializaion of C runtime.
  // Therefore do not call panic() here, else it will yield a dead recursion:
  //   panic() -> putchar() -> (glibc) -> malloc() -> panic()
// #if !(defined(__ISA_NATIVE__) && defined(__NATIVE_USE_KLIB__))
//   panic("Not implemented");
// #endif
  size = (size_t)ROUNDUP(size, 8);
  char* old = addr;
  addr += size;
  assert((uintptr_t)heap_start <= (uintptr_t)addr && (uintptr_t)addr < (uintptr_t)heap_end);
  for (uint64_t *p = (uint64_t*)old; p != (uint64_t*)addr; p++) {
    *p = 0;
  }
  return old;
}

void free(void *ptr) {
}

#endif
