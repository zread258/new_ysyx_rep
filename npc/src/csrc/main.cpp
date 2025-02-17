/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <main.h>
#include <isa.h>
#include <utils.h>

int main(int argc, char *argv[]) {

  Verilated::commandArgs(argc, argv);

  sim_init();

  machine_init();

  init_monitor(argc, argv);

  // step_and_dump_wave();

  // printf("inst = 0x%x\n", get_inst());

  sdb_mainloop();

  // while (1) {
    // if (flag) {
    //   break;
    // }
    // step_and_dump_wave();
  // }
  
}
