#include <am.h>
#include <nemu.h>
#include <klib.h>

extern char _heap_start;
extern char lma_data_start;
extern char vma_data_start;
extern char vma_data_end;
int main(const char *args);

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  outb(SERIAL_PORT, ch);
}

void bootloader() {
  size_t size = &vma_data_end - &vma_data_start;
  memcpy(&vma_data_start , &lma_data_start, size);
}

void halt(int code) {
  nemu_trap(code);

  // should not reach here
  while (1);
}

void _trm_init() {
  bootloader();

  int ret = main(mainargs);
  halt(ret);
}
