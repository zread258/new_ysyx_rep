/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <memory/paddr.h>
#include <cpu/difftest.h>
#include <isa.h>

#ifdef CONFIG_WAVEVCD
static VerilatedContext *contextp = NULL;
static VerilatedVcdC *tfp = NULL;
#endif

VysyxSoCFull *dut;

static bool npc_halt_ret = false;

void step_and_dump_wave() {
  dut->clock = 1;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
#endif
  dut->clock = 0;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
#endif
}

void sim_init() {
  dut = new VysyxSoCFull;
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
  dut->clock = 0;
  dut->eval();
#ifdef CONFIG_WAVEVCD
  contextp->timeInc(1);
  tfp->dump(contextp->time());
  tfp->close();
#endif
}

void machine_init() {
  dut->reset = 1;
  for (int i = 0; i < 20; i++) {
    step_and_dump_wave();
  }
  dut->reset = 0;
  // difftest_skip_ref();
}

word_t get_curpc() {
  return dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__PCW;
}

word_t get_inst() {
  return dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__InstW;
}

extern "C" void sim_break() {
  sim_exit();
  npc_halt_ret = true;
}

extern "C" int pmem_read(int raddr) {
  // always return 4 bytes data whose address is `raddr & ~0x3u`
  if (raddr == 0x00000020) {
    Log("Read Error Here! @raddr = 0x00000020");
  }
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

extern "C" bool is_device(int32_t raddr, int8_t grant, int8_t MemRead, int8_t MemWrite) {
  if (!in_pmem(raddr) && grant && (MemRead || MemWrite)) {
    return true;
  }
  return false;
}

extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }

extern "C" void mrom_read(int32_t addr, int32_t *data) { 
  *data = paddr_read(addr, 4);
}
