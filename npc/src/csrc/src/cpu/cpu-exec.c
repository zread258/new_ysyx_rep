/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
 ***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <cpu/difftest.h>
#include <locale.h>

/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
#define MAX_INST_TO_PRINT 10

void difftest_step(vaddr_t pc, vaddr_t npc);
void device_update();
bool check_wp();
void sdb_mainloop();

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

bool check_wp();

static void trace_and_difftest() {
// #ifdef CONFIG_ITRACE_COND
//   if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }
// #endif
//   if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(cpu.pc, cpu.pc));
#ifdef CONFIG_WATCHPOINT
  if (check_wp()) { 
    npc_state.state = NPC_STOP; 
  }
#endif
}

static void exec_once() {
  step_and_dump_wave();
  cpu.pc = get_curpc();
  update_cpu_reg();
#ifdef CONFIG_ITRACE
  char *log = (char*)malloc(1024);
  char *p = log;
  p += snprintf(p, 16, "0x%08x" ":", cpu.pc);
  int ilen = 4;
  int i;
  word_t cur_inst = get_inst();
  uint8_t *inst = (uint8_t *)(&cur_inst);
  if (cur_inst == 0x00100073) npc_state.state = NPC_END;
  for (i = ilen - 1; i >= 0; i --) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

#ifndef CONFIG_ISA_loongarch32r
  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, 100,
      cpu.pc, inst, ilen);
#else
  p[0] = '\0'; // the upstream llvm does not support loongarch32r
#endif
  printf("%s\n", log);
#else
  word_t cur_inst = get_inst();
  if (cur_inst == 0x00100073) npc_state.state = NPC_END;
#endif
}

static void execute(uint64_t n) {
  for (;n > 0; n --) {
    exec_once();
    trace_and_difftest();
    if (npc_state.state != NPC_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

void cpu_exec(uint64_t n) {
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  execute(n);

  // trace_and_difftest();

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          cpu.pc); break;
      // fall through
    // case NPC_QUIT: statistic(); break;

    case NPC_STOP: Log("Watchpoint Activated!"); break;
  }
}
