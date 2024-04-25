TOPNAME=ysyx_23060184_SGC
INC_PATH ?= /home/csardas/ysyx-workbench/npc/src/csrc/include
INC_PATH += /home/csardas/ysyx-workbench/npc/include
INC_PATH += /home/csardas/ysyx-workbench/npc/build/obj_dir
# INC_PATH += $(NPC_HOME)/src/csrc/src/isa/riscv32/include
INC_PATH += /usr/lib/llvm-11/include

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -trace \
				-O3 --x-assign fast --x-initial fast --noassert
VERILATOR_INC_PATH ?= /home/csardas/ysyx-workbench/npc/src/vsrc/include

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# Include all filelist.mk to merge file lists
FILELIST_MK = $(shell find -L ./src -name "filelist.mk")
include $(FILELIST_MK)

# project source
VSRCS = $(shell find $(abspath ./src/vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./src/csrc) -name "*.c" -or -name "*.cc" \
-or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

# Extract compiler and options from menuconfig
CC = $(call remove_quote,$(CONFIG_CC))
CFLAGS_BUILD += $(call remove_quote,$(CONFIG_CC_OPT))
CFLAGS_BUILD += $(if $(CONFIG_CC_LTO),-flto,)
CFLAGS_BUILD += $(if $(CONFIG_CC_DEBUG),-Og -ggdb3,)
CFLAGS_BUILD += $(if $(CONFIG_CC_ASAN),-fsanitize=address,)
CFLAGS_TRACE += -DITRACE_COND=$(if $(CONFIG_ITRACE_COND),$(call remove_quote,$(CONFIG_ITRACE_COND)),true)
CFLAGS  += $(CFLAGS_BUILD) $(CFLAGS_TRACE) -D__GUEST_ISA__=$(GUEST_ISA)
LDFLAGS += $(CFLAGS_BUILD)
LDFLAGS += -lreadline
LDFLAGS += -lLLVM-11
LDFLAGS += -ldl
LDFLAGS += -lSDL2

NPCFLAGS += --log=$(BUILD_DIR)/npc-log.txt
DIFF_REF_SO = /home/csardas/ysyx-workbench/nemu/build/riscv32-nemu-interpreter-so
NPCFLAGS += --diff=$(DIFF_REF_SO)

# Include rules for menuconfig
include $(NPC_HOME)/scripts/config.mk

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		-I$(VERILATOR_INC_PATH) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) 

all: default

run: $(BIN) 
	@$^ $(NPCFLAGS) $(ARGS) $(IMG)

gdb: $(BIN)
	@gdb --args $^ $(NPCFLAGS) $(ARGS) $(IMG) 

waves: $(BIN)
	gtkwave $(BUILD_DIR)/waveform.vcd $(BUILD_DIR)/config.gtkw

clean:
	rm -rf $(BUILD_DIR)

count:
	@echo "Statisticing lines of codes in .v files!"
	@find . -name "*.v" | xargs wc -l

.PHONY: default all clean run waves

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!

include ../Makefile
