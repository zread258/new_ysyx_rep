#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>

#define ysyxsoc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

#define DEVICE_BASE 0xa0000000
#define MMIO_BASE 0xa0000000

#define UART16550_ADDR  0x10000000
#define KBD_ADDR        0x10011000
#define RTC_ADDR        (DEVICE_BASE + 0x0000048) // ToDo: Change to SoC Address
#define VGACTL_ADDR     0x21000000
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

#endif