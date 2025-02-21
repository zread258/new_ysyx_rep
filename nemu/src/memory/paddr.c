/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_MROM_GARRAY
static uint8_t mrom[CONFIG_MROM_SIZE] PG_ALIGN = {};
static uint8_t sram[CONFIG_SRAM_SIZE] PG_ALIGN = {};
#endif

#if CONFIG_MTRACE == 1
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

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(sram, rand(), CONFIG_SRAM_SIZE));
  Log("physical sram area [" FMT_PADDR ", " FMT_PADDR "]", SRAM_LEFT, SRAM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  // Log("read " FMT_WORD " at " FMT_PADDR, len, addr);
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  // Log("write " FMT_WORD " at " FMT_PADDR, data, addr);
  out_of_bound(addr);
}
