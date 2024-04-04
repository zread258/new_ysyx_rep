/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <isa.h>
#include "memory/paddr.h"
#include "memory/host.h"
#include <device/mmio.h>


static uint8_t pmem[CONFIG_MSIZE] = {};

static const uint32_t img [] = {
  0x00000297,  // auipc t0,0
  0x00028823,  // sb  zero,16(t0)
  0x0102c503,  // lbu a0,16(t0)
  0x00100073,  // ebreak (used as npc_trap)
  0xdeadbeef,  // some data
  
};

#ifdef CONFIG_MTRACE
void display_pread(paddr_t addr, int len, word_t data);
void display_pwrite(paddr_t addr, int len, word_t data);
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

void init_mem() {
  memcpy(guest_to_host(CONFIG_MBASE), img, sizeof(img));
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  IFDEF(CONFIG_MTRACE, display_pread(addr, len, ret));
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  IFDEF(CONFIG_MTRACE, display_pwrite(addr, len, data));
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

word_t inst_fetch(paddr_t pc) {
  word_t inst = pmem_read(pc);
  return inst;
}

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
