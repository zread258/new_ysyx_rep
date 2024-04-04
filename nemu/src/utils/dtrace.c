#ifdef CONFIG_DTRACE

#include <utils.h>
#include <device/map.h>

void trace_dread(paddr_t addr, int len, IOMap *map) {
	log_write("dtrace: read %10s at " FMT_PADDR ",%d\n",
		map->name, addr, len);
}

void trace_dwrite(paddr_t addr, int len, word_t data, IOMap *map) {
	log_write("dtrace: write %10s at " FMT_PADDR ",%d with " FMT_WORD "\n",
		map->name, addr, len, data);
}

#endif