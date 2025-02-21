/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <common.h>
#include <stdint.h>
#include <stdio.h>
#include <config.h>
#include <string.h>

#define MROM_LEFT  ((paddr_t)CONFIG_MROM_BASE)
#define MROM_RIGHT ((paddr_t)CONFIG_MROM_BASE + CONFIG_MROM_SIZE - 1)
#define SRAM_LEFT  ((paddr_t)CONFIG_SRAM_BASE)
#define SRAM_RIGHT ((paddr_t)CONFIG_SRAM_BASE + CONFIG_SRAM_SIZE - 1)
#define RESET_VECTOR (MROM_LEFT + CONFIG_PC_RESET_OFFSET)

/* convert the guest physical address in the guest program to host virtual address in NEMU */
uint8_t* guest_to_host(paddr_t paddr);
/* convert the host virtual address in NEMU to guest physical address in the guest program */
paddr_t host_to_guest(uint8_t *haddr);

static inline bool addr_is_rom(paddr_t addr) { return addr >= MROM_LEFT && addr <= MROM_RIGHT; }
static inline bool addr_is_sram(paddr_t addr) { return addr >= SRAM_LEFT && addr <= SRAM_RIGHT; }

static inline bool in_pmem(paddr_t addr) {
  // return addr - CONFIG_MBASE < CONFIG_MSIZE;
  return addr_is_rom(addr) || addr_is_sram(addr);
}

word_t paddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len, word_t data);
word_t inst_fetch(paddr_t pc);
