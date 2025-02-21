#include <ysyxsoc.h>
#include <am.h>
#include <klib.h>
#include <riscv/riscv.h>
#include <klib-macros.h>

extern int _heap_start;
extern int _etext;
extern int _data;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
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
  memcpy((void*)_etext , (void*)MROM_ORIGIN, _data - _etext);
}

void _trm_init() {
  // bootloader
  // bootloader();
  // putch('H');

  int ret = main(mainargs);
  halt(ret);
}
