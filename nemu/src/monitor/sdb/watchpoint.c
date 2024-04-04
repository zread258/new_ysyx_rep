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

#include "sdb.h"

#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL;
static WP *free_ = NULL;

WP* new_wp() {
  if (free_ == NULL) {
    Log("No more watchpoints!");
    assert(0);
  }
  WP* ret = free_;
  free_ = free_->next;
  ret->next = head;
  head = ret;
  return ret;
}

void free_wp(WP* wp) {
  if (wp == NULL) {
    printf("No such watchpoint!\n");
    assert(0);
  }
  if (wp == head) {
    head = head->next;
  } else {
    WP* p = head;
    while (p->next != wp) {
      p = p->next;
    }
    p->next = wp->next;
  }
  wp->next = free_;
  free_ = wp;
}

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

bool check_wp() {
  WP* p = head;
  bool ret = false;
  while (p != NULL) {
    bool success = true;
    sword_t new = expr(p->expr, &success);
    if (success && new != p->value) {
      printf("watchpoint %d: %s\n", p->NO, p->expr);
      printf("Old value = 0x%08x\t%010u\n", p->value, p->value);
      printf("New value = 0x%08x\t%010u\n", new, new);
      p->value = new;
      p->hit++;
      ret = true;
    }
    p = p->next;
  }
  return ret;
}

void print_wp() {
  WP* p = head;
  while (p != NULL) {
    printf("watchpoint %d: expr = %s value = %u\n", p->NO, p->expr, p->value);
    printf("watchpoint already hit %d time\n", p->hit);
    p = p->next;
  }
}

WP* get_wp(int N) {
  WP* p = head;
  while (p != NULL) {
    if (p->NO == N) {
      return p;
    }
    p = p->next;
  }
  return NULL;
}