/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <isa.h>
#include "local-include/reg.h"
#include "Vysyx_23060184_SGC.h"
#include "Vysyx_23060184_SGC___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

#define NR_GPR MUXDEF(CONFIG_RVE, 16, 32)

bool instr_valid() {
  return dut->rootp->ysyx_23060184_SGC__DOT__Ivalid;
}

void update_cpu_reg() {
  for (int i = 0; i < NR_GPR; i++) {
    cpu.gpr[i] = dut->rootp->ysyx_23060184_SGC__DOT__IDU__DOT__RegFile__DOT__rf[i];
  }
  cpu.mstatus = csr(0x300);
  cpu.mtvec = csr(0x305);
  cpu.mepc = csr(0x341);
  cpu.mcause = csr(0x342);
}

void isa_reg_display() {
  for (int i = 0; i < NR_GPR; i++) {
    word_t val = dut->rootp->ysyx_23060184_SGC__DOT__IDU__DOT__RegFile__DOT__rf[i];
    printf("%s\t0x%08x\t%010u\n", regs[i], val, val);
  }
}

word_t isa_reg_str2val(const char *s, bool *success) {
  int i = 0;
  for (i = 0; i < NR_GPR; i++) {
    if (strcmp(s, regs[i]) == 0) {
      *success = true;
      break;
    }
  }
  return dut->rootp->ysyx_23060184_SGC__DOT__IDU__DOT__RegFile__DOT__rf[i];
}

word_t csr_reg_str2val(const char *s, bool *success) {
  if (strcmp(s, "mepc") == 0) {
      *success = true;
      return cpu.mepc;
  } else if (strcmp(s, "mtvec") == 0) {
      *success = true;
      return cpu.mtvec;
  } else if (strcmp(s, "mstatus") == 0) {
      *success = true;
      return cpu.mstatus;
  } else if (strcmp(s, "mcause") == 0) {
      *success = true;
      return cpu.mcause;
  }
  return 0;
}
