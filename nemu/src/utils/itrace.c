#include <common.h>

#if CONFIG_RING_ITRACE == 1

#define MAX_IRINGBUF CONFIG_RING_BUFSIZE 

typedef struct {
    word_t pc;
    uint32_t inst;
} ITraceNode;

ITraceNode iringbuf[CONFIG_RING_BUFSIZE];
bool full = false;
word_t itrace_idx = 0;

void itrace_push(vaddr_t pc, uint32_t inst) {
    iringbuf[itrace_idx].pc = pc;
    iringbuf[itrace_idx].inst = inst;
    itrace_idx = (itrace_idx + 1) % CONFIG_RING_BUFSIZE;
    full = full || (itrace_idx == 0);
}

void display_itrace() {
    if (!full && !itrace_idx) return;

    int end = itrace_idx;
    int i = full?itrace_idx:0;

    void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
    char buf[128]; // 128 should be enough!
    char *p;
    do {
        p = buf;
        p += sprintf(buf, "[itrace]" "%s" FMT_WORD ": ", (i+1)%MAX_IRINGBUF==end?"--> ":"    ", iringbuf[i].pc);
        uint8_t *inst = (uint8_t *)&iringbuf[i].inst;
        disassemble(p, buf+sizeof(buf)-p, iringbuf[i].pc, (uint8_t *)&iringbuf[i].inst, 4);
        p += strlen(p);
        if (strlen(buf) < 30) {
            p += sprintf(p, "\t\t");
        } else {
            p += sprintf(p, "\t");
        }
        for (int i = 3; i >= 0; i--) {
            p += snprintf(p, 4, "%02x ", inst[i]);
        }
        if ((i+1)%MAX_IRINGBUF==end) printf(ANSI_FG_RED);
        puts(buf);
    } while ((i = (i+1)%MAX_IRINGBUF) != end);
    puts(ANSI_NONE);
}

#endif