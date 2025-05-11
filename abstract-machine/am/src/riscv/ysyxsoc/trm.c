#include <ysyxsoc.h>
#include <am.h>
#include <klib.h>
#include <riscv/riscv.h>
#include <klib-macros.h>

extern char  _heap_start;
long  _sram_start = 0x0f000000;
extern char lma_data_start;
extern char vma_data_start;
extern char vma_data_end;
int main(const char *args);

#define SRAM_SIZE 8 * 1024
#define SRAM_END ((uintptr_t)&_sram_start + SRAM_SIZE)

Area heap = RANGE(&_heap_start, SRAM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void _uart_init() {
  // 1. Enable access to Divisor Latch
  outb(LCR_ADDR, LCR_DLAB);

  // 2. Set Divisor Latch (baud rate = input_clk / (16 * divisor))
  outb(DLL_ADDR, 0x01);
  outb(DLM_ADDR, 0x00);

  // 3. Set 8N1 format and disable DLAB
  outb(LCR_ADDR, LCR_8N1); // 8 data bits, no parity, 1 stop bit, DLAB=0

  // 4. Enable FIFO, clear TX/RX FIFO
  outb(FCR_ADDR, FCR_ENABLE);
}

void putch(char ch) {
  while ((inb(LSR_ADDR) & LSR_THRE) == 0); // wait until THR is empty
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
  _uart_init();
  bootloader();

  int ret = main(mainargs);
  halt(ret);
}
