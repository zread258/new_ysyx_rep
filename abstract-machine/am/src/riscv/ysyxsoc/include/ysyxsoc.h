#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>

#define ysyxsoc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

#define MROM_ORIGIN 0x20000000
#define MROM_LENGTH 4000

#define SRAM_ORIGIN 0x0f000000
#define SRAM_LENGTH 8000

#define DEVICE_BASE 0xa0000000
#define MMIO_BASE 0xa0000000

#define UART16550_ADDR  0x10000000
// Details could be found in the specification of Xlinx UART16550
#define LCR_ADDR        (UART16550_ADDR + 0x3)
#define LCR_DLAB        0x80
#define LCR_8N1         0x03

#define LSR_ADDR        (UART16550_ADDR + 0x5)
#define LSR_THRE        0x20

#define DLL_ADDR        (UART16550_ADDR + 0x0)
#define DLM_ADDR        (UART16550_ADDR + 0x1)

#define FCR_ADDR        (UART16550_ADDR + 0x2)  // FIFO Control
#define FCR_ENABLE      0x07
#define KBD_ADDR        0x10011000
#define RTC_ADDR        (DEVICE_BASE + 0x0000048) // ToDo: Change to SoC Address
#define VGACTL_ADDR     0x21000000
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

#endif