/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
***************************************************************************************/

#include <common.h>

#define MAX_VARLEN 32

word_t expr(char *e, bool *success);

word_t vaddr_read(vaddr_t addr, int len);

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  sword_t value;
  int hit;
  char expr[MAX_VARLEN];

} WP;

void print_wp();
void free_wp(WP* wp);
WP* new_wp();
WP* get_wp(int N);
