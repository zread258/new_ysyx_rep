/* Module: Instruction Control Signals
 *
 * Define: LUI, ADDI, LW, SW, JAL, JALR
 */

// CPU Data Width
`define DATA_WIDTH      32
// Instruction Memory Capacity
`define IM_LENGTH       1023
// Data Memory Capacity
`define DM_LENGTH       1023
// Default register data (32 digits of 0)
`define INIT_VAL        32'h00000000
// FUNC3 LENGTH
`define FUNCT3_LENGTH    3
// FUNC7 LENGTH
`define FUNCT7_LENGTH    7
// FUNC12 LENGTH
`define FUNCT12_LENGTH   12
// OPCODE LENGTH
`define OPCODE_LENGTH    7
// ACCESS ERROR WIDTH
`define ACERR_WIDTH      2

// R-Type instructions
`define INST_R_TYPE     7'b0110011  // R-Type opcode, decode via function code
`define FUNC3_ADD       3'b000      // ADD func3 code
`define FUNC7_ADD       7'b0000000  // ADD func7 code
`define FUNC3_SUB       3'b000      // SUB func3 code
`define FUNC7_SUB       7'b0100000  // SUB func7 code
`define FUNC3_OR        3'b110      // OR func3 code
`define FUNC7_OR        7'b0000000  // OR func3 code
`define FUNC3_AND       3'b111      // AND func3 code 
`define FUNC7_AND       7'b0000000  // AND func7 code 
`define FUNC3_XOR       3'b100      // XOR func3 code
`define FUNC7_XOR       7'b0000000  // XOR func7 code
`define FUNC3_SLT       3'b010      // SLT func3 code
`define FUNC7_SLT       7'b0000000  // SLT func7 code
`define FUNC3_SLTU      3'b011      // SLTU func3 code
`define FUNC7_SLTU      7'b0000000  // SLTU func7 code
`define FUNC3_SLL       3'b001      // SLL func3 code
`define FUNC7_SLL       7'b0000000  // SLL func7 code
`define FUNC3_SRL       3'b101      // SRL func3 code 
`define FUNC7_SRL       7'b0000000  // SRL func7 code 
`define FUNC3_SRA       3'b101      // SRL func3 code 
`define FUNC7_SRA       7'b0100000  // SRL func7 code
`define FUNC_SUBU       6'b100011   // SUBU func code

// I-Type instructions
`define INST_I_TYPE     7'b0010011 // R-Type opcode, decode via function code
`define FUNC3_ADDI      3'b000     // ADDI
`define FUNC3_SLTI      3'b010     // SLTI
`define FUNC3_SLTIU     3'b011     // SLTIU
`define FUNC3_XORI      3'b100     // XORI
`define FUNC3_ORI       3'b110     // ORI
`define FUNC3_ANDI      3'b111     // ANDI
`define FUNC3_SLLI      3'b001     // SLLI
`define FUNC7_SLLI      7'b0000000 // SLLI
`define FUNC3_SRLI      3'b101     // SRLI
`define FUNC7_SRLI      7'b0000000 // SRLI
`define FUNC3_SRAI      3'b101     // SRLA
`define FUNC7_SRAI      7'b0100000 // SRAI
// Load instructions
`define INST_LOAD       7'b0000011 // LOAD
`define INST_LB         3'b000     // LB
`define INST_LH         3'b001     // LH
`define INST_LW         3'b010     // LW
`define INST_LBU        3'b100     // LBU
`define INST_LHU        3'b101     // LBU
`define INST_LUI        7'b0110111 // LUI

// CSR related instructions
`define INST_CSR        7'b1110011 // CSR
`define FUNC3_ECALL     3'b000     // ECALL
`define FUNC12_ECALL    12'b0      // ECALL
`define FUNC3_MRET      3'b000     // MRET
`define FUNC12_MRET     12'h302    // MRET
`define FUNC3_CSRRW     3'b001     // CSRRW
`define FUNC3_CSRRS     3'b010     // CSRRS

// B-Type instructions
`define INST_BRANCH     7'b1100011 // BRANCH
`define INST_BEQ        3'b000     // BEQ
`define INST_BNE        3'b001     // BNE
`define INST_BLT        3'b100     // BLT
`define INST_BGE        3'b101     // BGE
`define INST_BLTU       3'b110     // BLTU
`define INST_BGEU       3'b111     // BGEU

// S-Type instructions
`define INST_STORE      7'b0100011 // STORE
`define INST_SB         3'b000     // SB
`define INST_SH         3'b001     // SH
`define INST_SW         3'b010     // SW

// J-Type instructions
`define INST_JAL        7'b1101111 // JAL
`define INST_JALR       7'b1100111 // JALR

// U-Type instructions
`define INST_AUIPC      7'b0010111 // AUIPC
`define INST_LUI        7'b0110111 // LUI

// ALU Control Signals
`define ALU_OP_LENGTH   4          // Bits of signal ALUOp
`define ALU_OP_DEFAULT  4'b0000     // ALUOp default value
`define ALU_OP_ADD      4'b0001     // ALUOp ADD
`define ALU_OP_SUB      4'b0010     // ALUOp SUB
`define ALU_OP_XOR      4'b0011     // ALUOp XOR
`define ALU_OP_SLT      4'b0100     // ALUOp SLT
`define ALU_OP_SLTU     4'b0101     // ALUOp SLTU
`define ALU_OP_SLL      4'b0110     // ALUOp SLL
`define ALU_OP_SRL      4'b0111     // ALUOp SRL
`define ALU_OP_SGT      4'b1000     // ALUOp SGT
`define ALU_OP_OR       4'b1001     // ALUOp OR
`define ALU_OP_AND      4'b1010     // ALUOp AND
`define ALU_OP_SRA      4'b1011     // ALUOp SRA

// RegDst Control Signals
`define REG_DST_RT      1'b0       // Register write destination: rt
`define REG_DST_RD      1'b1       // Register write destination: rd

// ALUSrcA_Control Signals -- To Be used in multi-cycle
`define ALU_SRCA_LENGTH  2          // Bits of signal ALUSrcA
`define ALU_SRCA_PC     2'b00
`define ALU_SRCA_RD1    2'b01
`define ALU_SRCA_ZERO   2'b10
`define ALU_SRCA_NPC    2'b11

// ALUSrcB_Control Signals
`define ALU_SRCB_LENGTH  2          // Bits of signal ALUSrcB
`define ALU_SRCB_IMM    2'b00
`define ALU_SRCB_RD2    2'b01
`define ALU_SRCB_CSR    2'b10
`define ALU_SRCB_ZERO   2'b11

// ResultSrc Control Signals
`define RESULT_SRC_LENGTH  3           // Bits of signal RegSrc
`define RESULT_SRC_DEFAULT 3'b000      // Register default value
`define RESULT_SRC_ALU     3'b001      // Register write source: ALU
`define RESULT_SRC_MEM     3'b010      // Register write source: Immidiate Extension
`define RESULT_SRC_PCPlus4 3'b011      // Register write source: NPC
`define RESULT_SRC_CSR     3'b100      // Register write source: CSR
// `define RESULT_SRC_MEM     2'b10      // Register write source: Data Memory

// CsrSrc Control Signals
`define CSR_SRC_LENGTH  2           // Bits of signal CsrSrc
`define CSR_SRC_PC      2'b00
`define CSR_SRC_ALU     2'b01

// ExtOp Control Signals
`define EXT_OP_LENGTH   3           // Bits of Signal ExtOp
`define EXT_OP_I        3'b000      // ExtOp default value
`define EXT_OP_U        3'b001      // LUI: Shift Left 16
`define EXT_OP_S        3'b010      // STORE
`define EXT_OP_B        3'b011      // ADDIU: `imm16` signed extended to 32 bit
// `define EXT_OP_J        2'b100      // LW, SW: `imm16` unsigned extended to 32 bit

// NPCOp Control Signals
`define NPC_OP_LENGTH   3          // Bits of NPCOp
`define NPC_OP_DEFAULT  3'b000     // NPCOp default value
`define NPC_OP_NEXT     3'b001     // Next instruction: normal
`define NPC_OP_JAL      3'b010     // Next instruction: JAL
`define NPC_OP_BRANCH   3'b011     // Next instruction: BEQ
`define NPC_OP_JALR     3'b100     // Next instruction: JALR
`define NPC_OP_CSR      3'b101

// DataMem WriteMask Signals
`define WMASK_LENGTH    8
`define WRITE_WORD      8'h0f
`define WRITE_HALF      8'h03
`define WRITE_BYTE      8'h01

// DataMem ReadMask Signals
`define ROPCODE_LENGTH  3
`define READ_WORD       3'b000
`define READ_HALF       3'b001
`define READ_BYTE       3'b010
`define READ_HALFU      3'b011
`define READ_BYTEU      3'b100

// CSR Register Address
// `define CSR_ADDR_LENGTH 9
// `define CSR_MSTATUS     12'h300
// `define CSR_MTVEC       12'h305
// `define CSR_MEPC        12'h341
// `define CSR_MCAUSE      12'h342

// ARBITER CONTROL SIGNALS
// NUMBER OF ARBITER MASTERS
`define NUM_ARB_MASTERS  2
`define EMPTY_REQ        2'b00
`define INSTMEM_REQ      2'b01
`define DATAMEM_REQ      2'b10
`define BOTH_REQ         2'b11
`define EMPTY_GRANT      2'b00
`define INSTMEM_GRANT    2'b01
`define DATAMEM_GRANT    2'b10
