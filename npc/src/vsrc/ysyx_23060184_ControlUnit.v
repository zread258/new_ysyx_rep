module ysyx_23060184_ControlUnit (
    input [`OPCODE_LENGTH - 1:0]        opcode,
    input [`FUNCT3_LENGTH - 1:0]        funct3,
    input [`FUNCT7_LENGTH - 1:0]        funct7,
    input [`FUNCT12_LENGTH - 1:0]       funct12,
    input                               Flag,
    input                               Zero,
    output [`NPC_OP_LENGTH - 1:0]       Npc_op,
    output                              RegWrite,
    output                              MemRead,
    output                              MemWrite,
    output                              CsrWrite,
    output                              ecall,
    output                              mret,
    output [`WMASK_LENGTH - 1:0]        Wmask,
    output [`ROPCODE_LENGTH - 1:0]      Ropcode,
    output [`RESULT_SRC_LENGTH - 1:0]   ResultSrc,
    output [`EXT_OP_LENGTH - 1:0]       ExtOp,
    output [`ALU_SRCA_LENGTH - 1:0]     ALUSrcA,
    output [`ALU_SRCB_LENGTH - 1:0]     ALUSrcB,
    output [`ALU_OP_LENGTH - 1:0]       ALUOp,
    output [`CSR_SRC_LENGTH - 1:0]      CsrSrc
);
    wire auipc, jalr, jal, lui;

    wire itype, addi, slli, sltiu, slti, xori, ori, andi, srli, srai;

    wire rtype, add, sub, slt, sltu, sll, srl, sra, ror, aand, rxor;

    wire branch, beq, bne, blt, bge, bltu, bgeu, branch_flag;

    wire load, lw, lh, lb, lhu, lbu;

    wire store, sw, sh, sb;

    wire csrrw, csrrs;

    // I-Type instructions
    assign itype = (opcode == `INST_I_TYPE) ? 1 : 0;
    assign addi = (opcode == `INST_I_TYPE) ? 
                (funct3 == `FUNC3_ADDI) ? 1 : 0 : 0;
    assign slli = (opcode == `INST_I_TYPE) ?
                (funct3 == `FUNC3_SLLI) ? 
                (funct7 == `FUNC7_SLLI) ? 1 : 0 : 0 : 0;
    assign srli = (opcode == `INST_I_TYPE) ?
                (funct3 == `FUNC3_SRLI) ? 
                (funct7 == `FUNC7_SRLI) ? 1 : 0 : 0 : 0;
    assign srai = (opcode == `INST_I_TYPE) ?
                (funct3 == `FUNC3_SRAI) ?
                (funct7 == `FUNC7_SRAI) ? 1 : 0 : 0 : 0;
    assign slti =  (opcode == `INST_I_TYPE) ? 
                (funct3 == `FUNC3_SLTI) ? 1 : 0 : 0;
    assign sltiu = (opcode == `INST_I_TYPE) ?
                (funct3 == `FUNC3_SLTIU) ? 1 : 0 : 0;
    assign ori =   (opcode == `INST_I_TYPE) ? 
                (funct3 == `FUNC3_ORI) ? 1 : 0 : 0;
    assign andi =  (opcode == `INST_I_TYPE) ? 
                (funct3 == `FUNC3_ANDI) ? 1 : 0 : 0;
    assign xori =  (opcode == `INST_I_TYPE) ? 
                (funct3 == `FUNC3_XORI) ? 1 : 0 : 0;

    // CSR related instructions
    assign ecall = (opcode == `INST_CSR) ?
                (funct3 == `FUNC3_ECALL) ? 
                (funct12 == `FUNC12_ECALL) ? 1 : 0 : 0 : 0;
    assign mret = (opcode == `INST_CSR) ?
                (funct3 == `FUNC3_MRET) ? 
                (funct12 == `FUNC12_MRET) ? 1 : 0 : 0 : 0;
    assign csrrw = (opcode == `INST_CSR) ? 
                (funct3 == `FUNC3_CSRRW) ? 1 : 0 : 0;
    assign csrrs = (opcode == `INST_CSR) ?
                (funct3 == `FUNC3_CSRRS) ? 1 : 0 : 0;


    assign jal = (opcode == `INST_JAL) ? 1 : 0;
    assign jalr = (opcode == `INST_JALR) ? 1 : 0;
    assign auipc = (opcode == `INST_AUIPC) ? 1 : 0;
    assign lui = (opcode == `INST_LUI) ? 1 : 0;

    // R-Type instructions
    assign rtype = (opcode == `INST_R_TYPE) ? 1 : 0;
    assign add = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_ADD) ?
                (funct7 == `FUNC7_ADD) ? 1 : 0 : 0 : 0;
    assign sub = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SUB) ?
                (funct7 == `FUNC7_SUB) ? 1 : 0 : 0 : 0;
    assign slt = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SLT) ?
                (funct7 == `FUNC7_SLT) ? 1 : 0 : 0 : 0;
    assign sltu = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SLTU) ?
                (funct7 == `FUNC7_SLTU) ? 1 : 0 : 0 : 0;
    assign sll = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SLL) ?
                (funct7 == `FUNC7_SLL) ? 1 : 0 : 0 : 0;
    assign srl = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SRL) ?
                (funct7 == `FUNC7_SRL) ? 1 : 0 : 0 : 0;
    assign sra = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_SRA) ?
                (funct7 == `FUNC7_SRA) ? 1 : 0 : 0 : 0;
    assign ror = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_OR) ?
                (funct7 == `FUNC7_OR) ? 1 : 0 : 0 : 0;
    assign aand = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_AND) ?
                (funct7 == `FUNC7_AND) ? 1 : 0 : 0 : 0;
    assign rxor = (opcode == `INST_R_TYPE) ? 
                (funct3 == `FUNC3_XOR) ?
                (funct7 == `FUNC7_XOR) ? 1 : 0 : 0 : 0;

    // Branch instructions
    assign branch = (opcode == `INST_BRANCH) ? 1 : 0;
    assign beq = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BEQ) ? 1 : 0 : 0;
    assign bne = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BNE) ? 1 : 0 : 0;
    assign blt = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BLT) ? 1 : 0 : 0;
    assign bge = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BGE) ? 1 : 0 : 0;
    assign bltu = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BLTU) ? 1 : 0 : 0;
    assign bgeu = (opcode == `INST_BRANCH) ?
             (funct3 == `INST_BGEU) ? 1 : 0 : 0;

    // Load instructions 
    assign load = (opcode == `INST_LOAD) ? 1 : 0;
    assign lb = (opcode == `INST_LOAD) ?
            (funct3 == `INST_LB) ? 1 : 0 : 0;
    assign lh = (opcode == `INST_LOAD) ?
            (funct3 == `INST_LH) ? 1 : 0 : 0;
    assign lw = (opcode == `INST_LOAD) ? 
            (funct3 == `INST_LW) ? 1 : 0 : 0;
    assign lbu = (opcode == `INST_LOAD) ? 
            (funct3 == `INST_LBU) ? 1 : 0 : 0;
    assign lhu = (opcode == `INST_LOAD) ? 
            (funct3 == `INST_LHU) ? 1 : 0 : 0;

    // Store instructions
    assign store = (opcode == `INST_STORE) ? 1 : 0;
    assign sw = (opcode == `INST_STORE) ? 
            (funct3 == `INST_SW) ? 1 : 0 : 0;
    assign sh = (opcode == `INST_STORE) ? 
            (funct3 == `INST_SH) ? 1 : 0 : 0;    
    assign sb = (opcode == `INST_STORE) ? 
            (funct3 == `INST_SB) ? 1 : 0 : 0;



    assign RegWrite = (lui || itype || auipc || jalr || jal || load || rtype || csrrw || csrrs || ecall) ? 1 : 0;

    assign MemRead = (load) ? 1 : 0;

    assign MemWrite = (store) ? 1 : 0;

    assign Wmask = (sw) ? `WRITE_WORD :
                   (sh) ? `WRITE_HALF :
                   (sb) ? `WRITE_BYTE : 0; 

    assign Ropcode = (lw) ? `READ_WORD :
                     (lh) ? `READ_HALF :
                     (lb) ? `READ_BYTE :
                     (lhu) ? `READ_HALFU :
                     (lbu) ? `READ_BYTEU : 0;

    assign ALUSrcA = (auipc) ? `ALU_SRCA_PC :
            (itype || jalr || store || load || branch || rtype) ? `ALU_SRCA_RD1 : 
            (lui) ? `ALU_SRCA_ZERO : 
            (csrrs || csrrw) ? `ALU_SRCA_RD1 :
            `ALU_SRCA_ZERO;

    assign ALUSrcB = (lui || itype || jal || auipc || store || load) ? `ALU_SRCB_IMM : 
            (csrrs) ? `ALU_SRCB_CSR : 
            (csrrw) ? `ALU_SRCB_ZERO :
            `ALU_SRCB_RD2;

    assign ALUOp = (addi || jalr || load || lui || auipc || add) ? `ALU_OP_ADD :
            (store) ? `ALU_OP_ADD :
            (jal) ? `ALU_OP_ADD :
            (sub || beq || bne) ? `ALU_OP_SUB : 
            (ror || ori) ? `ALU_OP_OR : 
            (aand || andi) ? `ALU_OP_AND :
            (slt || slti || blt || bge) ? `ALU_OP_SLT :
            (sltu || sltiu || bltu || bgeu) ? `ALU_OP_SLTU : 
            (sll || slli) ? `ALU_OP_SLL :
            (srl || srli) ? `ALU_OP_SRL :
            (sra || srai) ? `ALU_OP_SRA :
            (rxor || xori) ? `ALU_OP_XOR : 
            (csrrw) ? `ALU_OP_ADD : 
            (csrrs) ? `ALU_OP_OR :
            `ALU_OP_ADD;

    assign ResultSrc = (itype || auipc || lui || rtype) ? `RESULT_SRC_ALU :
            (load) ? `RESULT_SRC_MEM :
            (jal || jalr) ? `RESULT_SRC_PCPlus4 :
            (csrrw || csrrs) ? `RESULT_SRC_CSR :
            `RESULT_SRC_DEFAULT;

    assign ExtOp = (lui || auipc) ? `EXT_OP_U :
            (itype) ? `EXT_OP_I : 
            (store)  ? `EXT_OP_S : 
            (branch) ? `EXT_OP_B :
            `EXT_OP_I;

    assign branch_flag = (beq && Zero) ? 1 :
            (bne && ~Zero) ? 1 :
            ((blt || bltu) && Flag) ? 1 : 
            ((bge || bgeu) && ~Flag) ? 1 : 0;

    assign Npc_op = (lui || auipc || addi) ? `NPC_OP_NEXT :
            (jal) ? `NPC_OP_JAL :
            (jalr) ? `NPC_OP_JALR : 
            (branch & branch_flag) ? `NPC_OP_BRANCH :
            (ecall || mret) ? `NPC_OP_CSR :
            `NPC_OP_NEXT;

    assign CsrSrc = (ecall) ? `CSR_SRC_PC :
            (csrrw || csrrs) ? `CSR_SRC_ALU : 0;

    assign CsrWrite = (csrrw || csrrs) ? 1 : 0;

endmodule 
