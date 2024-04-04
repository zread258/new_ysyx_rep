/***************************************************************************************
* Copyright (c) 2023-2024 modified by Ruidong Zhang
* Thanks to Zihao Yu from Nanjing University 
* and YSYX-project group
 ***************************************************************************************/

#include "sdb.h"

#include <cpu/cpu.h>
#include <isa.h>
#include <readline/history.h>
#include <readline/readline.h>

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

static char *rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");

  // if (line_read && *line_read) {
  //   add_history(line_read);
  // }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) { 
  sim_exit();
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args);

static int cmd_info(char *args);

static int cmd_x(char *args);

static int cmd_p(char *args);

static int cmd_w(char *args);

static int cmd_d(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler)(char *);
} cmd_table[] = {
    {"help", "Display information about all supported commands", cmd_help},
    {"c", "Continue the execution of the program", cmd_c},
    {"q", "Exit NEMU", cmd_q},
    {"si", "Step forward N steps", cmd_si},
    {"info", "Print register status/ watchpoint info", cmd_info},
    {"x", "Scan continous memory units", cmd_x},
    {"p", "Calculate the value of the expression", cmd_p},
    {"w", "Set a watchpoint", cmd_w},
    {"d", "Delete a watchpoint", cmd_d}

    /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  } else {
    for (i = 0; i < NR_CMD; i++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

static int cmd_si(char *args) {
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Usage: si [N]\n");
    return 1;
  } else {
    uint64_t steps = strtol(arg, NULL, 0);
    cpu_exec(steps);
  }

  return 0;
}

static int cmd_info(char *args) {
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Usage: info SUBCMD\n");
    return 1;
  } else {
    if (strcmp(arg, "r") == 0) {
      isa_reg_display();
    } else if (strcmp(arg, "w") == 0) {
      print_wp();
    } else {
      printf("Usage: info SUBCMD\n");
      return 1;
    }
  }
  return 0;
}

static int cmd_x(char *args) {
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Usage: x [N] EXPR\n");
    return 1;
  } else {
    word_t N = (int)strtol(arg, NULL, 0);
    word_t offset = 4;
    arg = strtok(NULL, " ");
    vaddr_t addr = strtol(arg, NULL, 0);
    for (word_t i = 0; i < N; i++) {
      word_t data = (word_t)vaddr_read(addr, offset);
      printf("%#x: %#x\n", addr, data);
      addr += offset;
    }
  }
  return 0;
}

static int cmd_p(char *args) {
  if (args == NULL) {
    printf("Usage: p EXPR\n");
    return 1;
  } else {
    bool is_success = false;
    word_t result = expr(args, &is_success);
    
    printf("%u 0x%x\n", result, result);
  }

  return 0;
}

static int cmd_w(char *args) {
  if (args == NULL) {
    printf("Usage: w EXPR\n");
    return 1;
  } else {
    WP* wp = new_wp();
    if (wp == NULL) {
      printf("No more watchpoints!\n");
      return 1;
    }
    strcpy(wp->expr, args);
    bool is_success = false;
    wp->value = expr(args, &is_success);
    if (!is_success) {
      printf("Invalid expression!\n");
      free_wp(wp);
      return 1;
    }
    printf("Add a watchpoint %s = %u\n", wp->expr, wp->value);
  }

  return 0;
}

static int cmd_d(char *args) {
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Usage: d [N]\n");
    return 1;
  } else {
    int N = (int)strtol(arg, NULL, 0);
    // Log("N = %d", N);
    WP* p = get_wp(N);
    if (p != NULL) {
      free_wp(p);
      printf("Delete watchpoint %d\n", N);
    } else {
      printf("No such watchpoint!\n");
    }
  }

  return 0; 
}

void sdb_set_batch_mode() { is_batch_mode = true; }

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL;) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) {
      continue;
    }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) {
          return;
        }
        break;
      }
    }

    if (i == NR_CMD) {
      printf("Unknown command '%s'\n", cmd);
    }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
