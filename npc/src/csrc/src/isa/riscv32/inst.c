/***************************************************************************************
* Copyright (c) 2023-2025 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include "local-include/reg.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>

#define R(i) gpr(i)
#define Mr vaddr_read
#define Mw vaddr_write

enum {
  TYPE_S,
  TYPE_N, // none
};

#define src1R() do { *src1 = R(rs1); } while (0)
#define src2R() do { *src2 = R(rs2); } while (0)
#define immS() do { *imm = (SEXT(BITS(i, 31, 25), 7) << 5) | BITS(i, 11, 7); } while(0)

static void decode_operand(uint32_t inst, int *rd, word_t *src1, word_t *src2, word_t *imm, int type) {
  uint32_t i = inst;
  int rs1 = BITS(i, 19, 15);
  int rs2 = BITS(i, 24, 20);
  *rd     = BITS(i, 11, 7);
  switch (type) {
    case TYPE_S: src1R(); src2R(); immS(); break;
    case TYPE_N: break;
  }
}

static int decode_exec(uint32_t inst) {
  int rd = 0;
  word_t src1 = 0, src2 = 0, imm = 0;

#define INSTPAT_INST inst
#define INSTPAT_MATCH(inst, name, type, ... /* execute body */ ) { \
  decode_operand(inst, &rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}

  INSTPAT_START();
  INSTPAT("??????? ????? ????? 000 ????? 01000 11", sb     , S, Mw(src1 + imm, 1, src2));
  INSTPAT("??????? ????? ????? 001 ????? 01000 11", sh     , S, Mw(src1 + imm, 2, src2));
  INSTPAT("??????? ????? ????? 010 ????? 01000 11", sw     , S, Mw(src1 + imm, 4, src2));
  INSTPAT("??????? ????? ????? ??? ????? ????? ??", other  , N, );
  INSTPAT_END();

  R(0) = 0; // reset $zero to 0awq2 

  return 0;
}

void isa_exec_once(uint32_t inst) {
  decode_exec(inst);
}
