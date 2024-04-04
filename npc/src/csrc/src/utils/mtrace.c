#include <common.h>

#ifdef CONFIG_MTRACE
void display_pread(paddr_t addr, int len, word_t data) {
  printf("[mtrace] " "pread\t at " FMT_PADDR "\t len = %d, data = " FMT_WORD "\n", addr, len, data);
}

void display_pwrite(paddr_t addr, int len, word_t data) {
  printf("[mtrace] " "pwrite\t at " FMT_PADDR "\t len = %d, data = " FMT_WORD "\n", addr, len, data);
}
#endif