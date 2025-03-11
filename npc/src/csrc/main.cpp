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

  sdb_mainloop();

  return 0;

}
