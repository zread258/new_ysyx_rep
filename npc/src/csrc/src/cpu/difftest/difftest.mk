#***************************************************************************************
# * Copyright (c) 2023-2024 modified by Ruidong Zhang
# * Thanks to Zihao Yu from Nanjing University 
# * and YSYX-project group
#**************************************************************************************/

# ifdef CONFIG_DIFFTEST
DIFF_REF_PATH = $(NEMU_HOME)
GUEST_ISA = riscv32
CONFIG_DIFFTEST_REF_NAME = nemu-interpreter
DIFF_REF_SO = $(DIFF_REF_PATH)/build/$(GUEST_ISA)-$(call remove_quote,$(CONFIG_DIFFTEST_REF_NAME))-so
MKFLAGS = GUEST_ISA=$(GUEST_ISA) SHARE=1 ENGINE=interpreter
ARGS_DIFF = --diff=$(DIFF_REF_SO)
ARGS += ARGS_DIFF

# ifndef CONFIG_DIFFTEST_REF_NEMU
# $(DIFF_REF_SO):
# 	$(MAKE) -s -C $(DIFF_REF_PATH) $(MKFLAGS)
# endif

# .PHONY: $(DIFF_REF_SO)
# endif
