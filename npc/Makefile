TOPNAME=ysyxSoCFull
NPC_HOME ?= $(shell pwd)
INC_PATH ?= $(NPC_HOME)/include
INC_PATH += $(NPC_HOME)/src/csrc/include
INC_PATH += $(NPC_HOME)/build/obj_dir
INC_PATH += /home/csardas/ysyx-workbench/ysyxSoC/perip
# INC_PATH += $(NPC_HOME)/src/csrc/src/isa/riscv32/include
INC_PATH += /usr/local/llvm-16/include

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -trace \
				-O3 --x-assign fast --x-initial fast --noassert
VERILATOR_INC_PATH ?= src/vsrc/include
VERILATOR_INC_PATH += /home/csardas/ysyx-workbench/ysyxSoC/perip/uart16550/rtl
VERILATOR_INC_PATH += /home/csardas/ysyx-workbench/ysyxSoC/perip/spi/rtl

VERILATOR_INC_FLAGS = $(addprefix -I, $(VERILATOR_INC_PATH))

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)
VCD = $(BUILD_DIR)/waveform.vcd 

$(shell mkdir -p $(BUILD_DIR))

# Include all filelist.mk to merge file lists
FILELIST_MK = $(shell find -L ./src -name "filelist.mk")
include $(FILELIST_MK)

# project source
VSRCS = $(shell find $(abspath ./src/vsrc) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/build) -name "*.v")
CSRCS = $(shell find $(abspath ./src/csrc) -name "*.c" -or -name "*.cc" \
-or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
CXXFLAGS += -std=c++17

# Extract compiler and options from menuconfig
CC = $(call remove_quote,$(CONFIG_CC))
CFLAGS_BUILD += $(call remove_quote,$(CONFIG_CC_OPT))
CFLAGS_BUILD += $(if $(CONFIG_CC_LTO),-flto,)
CFLAGS_BUILD += $(if $(CONFIG_CC_DEBUG),-Og -ggdb3,)
CFLAGS_BUILD += $(if $(CONFIG_CC_ASAN),-fsanitize=address,)
CFLAGS_TRACE += -DITRACE_COND=$(if $(CONFIG_ITRACE_COND),$(call remove_quote,$(CONFIG_ITRACE_COND)),true)
CFLAGS  += $(CFLAGS_BUILD) $(CFLAGS_TRACE) -D__GUEST_ISA__=$(GUEST_ISA)
CFLAGS += -std=c++17
LDFLAGS += $(CFLAGS_BUILD)
LDFLAGS += -L/usr/local/lib
LDFLAGS += -lreadline
LDFLAGS += -lLLVM-16
LDFLAGS += -ldl
LDFLAGS += -lSDL2

NPCFLAGS += --log=$(BUILD_DIR)/npc-log.txt
DIFF_REF_SO = /home/csardas/ysyx-workbench/nemu/build/riscv32-nemu-interpreter-so
NPCFLAGS += --diff=$(DIFF_REF_SO)

# Include rules for menuconfig
include $(NPC_HOME)/scripts/config.mk

default: $(BIN)

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		$(VERILATOR_INC_FLAGS) \
		--timescale "1ns/1ns" --no-timing \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) 

all: default

run: $(BIN) 
	@$^ $(NPCFLAGS) $(ARGS) $(IMG)

gdb: $(BIN)
	@gdb --args $^ $(NPCFLAGS) $(ARGS) $(IMG) 

waves: $(VCD)
	gtkwave $(VCD) ./config.gtkw

clean:
	rm -rf $(BUILD_DIR)

count:
	@echo "Statisticing lines of codes in .v files!"
	@find . -name "*.v" | xargs wc -l

.PHONY: default all clean run waves

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!

include ../Makefile
