#include <ysyxsoc.h>
#include <am.h>
#include <klib.h>
#include <riscv/riscv.h>
#include <klib-macros.h>

extern char  _heap_start;
extern char  _sram_start;
extern char lma_data_start;
extern char vma_data_start;
extern char vma_data_end;
int main(const char *args);

// extern char _pmem_start;
// #define PMEM_SIZE (128 * 1024 * 1024)
// #define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define SRAM_SIZE 8 * 1024
#define SRAM_END ((uintptr_t)&_sram_start + SRAM_SIZE)

Area heap = RANGE(&_heap_start, SRAM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  outb(UART16550_ADDR, ch);
}

void halt(int code) {
  ysyxsoc_trap(code);

  // should not reach here
  while (1);
}

void bootloader() {
  size_t size = &vma_data_end - &vma_data_start;
  memcpy(&vma_data_start , &lma_data_start, size);
}

void _trm_init() {
  bootloader();

  int ret = main(mainargs);
  halt(ret);
}
