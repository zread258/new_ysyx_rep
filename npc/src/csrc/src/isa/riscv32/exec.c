/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <memory/paddr.h>
#include <isa.h>

#ifdef CONFIG_WAVEVCD
static VerilatedContext *contextp = NULL;
static VerilatedVcdC *tfp = NULL;
#endif

Vysyx_23060184_SGC *dut;

static bool npc_halt_ret = false;

void step_and_dump_wave() {
  dut->clk = 1;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
#endif
  dut->clk = 0;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
#endif
}

void sim_init() {
  dut = new Vysyx_23060184_SGC;
#ifdef CONFIG_WAVEVCD
  Verilated::traceEverOn(true); // Enable Wavetrace
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  contextp->traceEverOn(true);
  dut->trace(tfp, 0);
  tfp->open("/home/csardas/ysyx-workbench/npc/build/waveform.vcd");
#endif
}

void sim_exit() {
  step_and_dump_wave();
  dut->clk = 0;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
  tfp->close();
#endif
}

void machine_init() {
  dut->resetn = 0;
  step_and_dump_wave();
  step_and_dump_wave();
  dut->resetn = 1;
}

word_t get_curpc() {
  return dut->pc;
}

word_t get_inst() {
  return dut->inst;
}

extern "C" void sim_break() {
  sim_exit();
  npc_halt_ret = true;
}

extern "C" int pmem_read(int raddr) {
  // always return 4 bytes data whose address is `raddr & ~0x3u`
  return paddr_read(raddr, 4);
}
extern "C" void pmem_write(int waddr, int wdata, char wmask) {
  // 总是往地址为`waddr & ~0x3u`的4字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  int len = 0;
  switch (wmask) {
    case 0x1: len = 1; break;
    case 0x3: len = 2; break;
    case 0xf: len = 4; break;
    default: assert(0);
  }
  paddr_write(waddr, len, wdata);
}
