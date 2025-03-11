/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <isa.h>
#include "memory/paddr.h"
#include "memory/host.h"
#include <device/mmio.h>


static uint8_t mrom[CONFIG_MROM_SIZE] PG_ALIGN = {};
static uint8_t sram[CONFIG_SRAM_SIZE] PG_ALIGN = {};

// static const uint32_t img [] = {
//   0xef000117,  // auipc	sp,0xef000
//   0x1fc10113,  // add	sp,sp,508 # f000200 <_end>
//   0xff410113,  // add	sp,sp,-12
//   0x01e10093,  // add ra,sp,30
//   0x00112423,  // sw	ra,8(sp)
//   0x00812783,  // lw  a5,8(sp)
//   0x00100073,  // ebreak (used as npc_trap)
//   0xdeadbeef,  // some data
  
// };

static const uint32_t img [] = {
  0x00000597,  // auipc	sp,0xef000
  0x1fc50513,  // add	sp,sp,508 # f000200 <_end>
  0xef000117,  // add	sp,sp,-12
  0x00a12023,  // add ra,sp,30
  0x00012603,  // sw	ra,8(sp)
  0x00a61463,  // lw  a5,8(sp)
  0xfe9ff06f,
  0x00100073,  // ebreak (used as npc_trap)
  0xdeadbeef,  // some data
  
};

#ifdef CONFIG_MTRACE
void display_pread(paddr_t addr, int len, word_t data);
void display_pwrite(paddr_t addr, int len, word_t data);
#endif

uint8_t* guest_to_host(paddr_t paddr) { 
  if (addr_is_rom(paddr)) return mrom + paddr - MROM_LEFT;
  if (addr_is_sram(paddr)) return sram + paddr - SRAM_LEFT;
  return mrom + paddr - MROM_LEFT;
  // return pmem + paddr - CONFIG_MBASE; 
}

paddr_t host_to_guest(uint8_t *haddr) { 
  if (haddr >= mrom && haddr < mrom + CONFIG_MROM_SIZE) return MROM_LEFT + haddr - mrom;
  if (haddr >= sram && haddr < sram + CONFIG_SRAM_SIZE) return SRAM_LEFT + haddr - sram;
  return MROM_LEFT + haddr - mrom;
  // return haddr - pmem + CONFIG_MBASE; 
}

void init_mem() {
  memcpy(guest_to_host(MROM_LEFT), img, sizeof(img));
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  IFDEF(CONFIG_MTRACE, display_pread(addr, len, ret));
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  IFDEF(CONFIG_MTRACE, display_pwrite(addr, len, data));
  if (addr_is_rom(addr)) {
    panic("write " FMT_WORD " at " FMT_PADDR \
      "\nmrom do not support write operations ", data, addr);
  }
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of mrom [" FMT_PADDR ", " FMT_PADDR "] and \
        sram [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, MROM_LEFT, MROM_RIGHT, SRAM_LEFT, SRAM_RIGHT, cpu.pc);
}

word_t inst_fetch(paddr_t pc) {
  word_t inst = pmem_read(pc);
  return inst;
}

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  // Log("paddr_read");
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  // Log("paddr_write");
  out_of_bound(addr);
}
