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

#include <isa.h>
#include <cpu/decode.h>
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>

#define NR_GPR MUXDEF(CONFIG_RVE, 16, 32)

struct diff_context_t {
  word_t gpr[MUXDEF(CONFIG_RVE, 16, 32)];
  word_t mepc, mtvec, mstatus, mcause;
  word_t pc;
};

struct diff_context_t ref;

static void ref_init() {
  cpu.pc = RESET_VECTOR;
  ref.pc = 0;
  for (int i = 0; i < NR_GPR; i++) {
    ref.gpr[i] = 0;
  }
}

static void write_back_reg() {
  for (int i = 0; i < NR_GPR; i++) {
    ref.gpr[i] = cpu.gpr[i];
  }
  ref.pc = cpu.pc;
  // printf("(nemu side)cpu.pc = 0x%x\nref.pc = 0x%x\n", cpu.pc, ref.pc);
}

void diff_set_regs(void* diff_context) {
  struct diff_context_t* ctx = (struct diff_context_t*)diff_context;
  for (int i = 0; i < NR_GPR; i++) {
    cpu.gpr[i] = (sword_t)ctx->gpr[i];
  }
  if (ctx->pc != 0x00000000) cpu.pc = ctx->pc;
  // printf("diff_set_regs_pc = %x\n", cpu.pc);
}

void diff_get_regs(void* diff_context) {
  struct diff_context_t* ctx = (struct diff_context_t*)diff_context;
  // printf("(nemu side) sizeof(ctx) = %ld\n", sizeof(ctx));
  // printf("(nemu side) BEFORE ctx->pc = 0x%08x\n", ctx->pc);
  for (int i = 0; i < NR_GPR; i++) {
    ctx->gpr[i] = ref.gpr[i];
  }
  // printf("(nemu side) address of ctx->pc = %p\n", &(ctx->pc));
  ctx->pc = ref.pc;
  // printf("(nemu side) AFTER ctx->pc = 0x%x\n", ctx->pc);
}

void diff_step(uint64_t n) {
  Decode s;
  ref.pc = cpu.pc;
  s.pc = ref.pc;
  s.snpc = ref.pc;
  for (int i = 0; i < n; i++) {
    // if (cpu.pc == 0x00000000) {
    //   printf("Here!\n");
    // }
    write_back_reg();
    isa_exec_once(&s);
    cpu.pc = s.dnpc;
  }
}

void diff_memcpy(paddr_t dest, void* src, size_t n) {
  memcpy(guest_to_host(dest), src, n);
}

__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    diff_memcpy(addr, buf, n);
  } else {
    assert(0);
  }
}

__EXPORT void difftest_regcpy(void *dut, bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    diff_set_regs(dut);
  } else {
    // printf("(nemu side) address of dut = %p\n", dut);
    diff_get_regs(dut);
  }
}

__EXPORT void difftest_exec(uint64_t n) {
  diff_step(n);
}

__EXPORT void difftest_raise_intr(word_t NO) {
  assert(0);
}

__EXPORT void difftest_init(int port) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
  ref_init();
  // printf("difftest_init\n");
  // printf("cpu.pc = 0x%x\n", cpu.pc);
}
