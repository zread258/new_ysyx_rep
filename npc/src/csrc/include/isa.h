/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

// Located at src/isa/$(GUEST_ISA)/include/isa-def.h
#include "isa-def.h"

#include <common.h>
#include <stdint.h>

#include "Vysyx_23060184_SGC.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

// The macro `__GUEST_ISA__` is defined in $(CFLAGS).
// It will be expanded as "x86" or "mips32" ...
typedef concat(riscv32, _CPU_state) CPU_state;
// typedef concat(__GUEST_ISA__, _ISADecodeInfo) ISADecodeInfo;

// typedef uint32_t word_t;
// typedef word_t vaddr_t;
// typedef word_t paddr_t;

// monitor
extern unsigned char isa_logo[];
void init_isa(); 

// reg
extern CPU_state cpu;
extern Vysyx_23060184_SGC *dut;
word_t get_curpc();
word_t get_inst();
extern "C" void get_regval(int num, int result);
void isa_reg_display();
void update_cpu_reg();
word_t isa_reg_str2val(const char *name, bool *success);

// exec
void step_and_dump_wave();
void sim_init();
void sim_exit();
void machine_init();
extern "C" void sim_break();
extern "C" int pmem_read(int raddr);
struct Decode;
int isa_exec_once(struct Decode *s);

// memory
// enum { MMU_DIRECT, MMU_TRANSLATE, MMU_FAIL };
// enum { MEM_TYPE_IFETCH, MEM_TYPE_READ, MEM_TYPE_WRITE };
// enum { MEM_RET_OK, MEM_RET_FAIL, MEM_RET_CROSS_PAGE };
// #ifndef isa_mmu_check
// int isa_mmu_check(vaddr_t vaddr, int len, int type);
// #endif
// paddr_t isa_mmu_translate(vaddr_t vaddr, int len, int type);

// interrupt/exception
vaddr_t isa_raise_intr(word_t NO, vaddr_t epc);
#define INTR_EMPTY ((word_t)-1)
word_t isa_query_intr();

// difftest
bool isa_difftest_checkregs(NPCState *ref_r, vaddr_t pc);
void isa_difftest_attach();

// #endif
