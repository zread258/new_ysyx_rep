#include <common.h>

typedef uint32_t word_t;
typedef word_t vaddr_t;
typedef word_t paddr_t;
word_t inst_fetch(paddr_t pc);
int parse_args(int argc, char *argv[]);
void init_monitor(int argc, char *argv[]);
long load_img();
void init_mem();
void sim_init();
void machine_init();
void sdb_mainloop();
