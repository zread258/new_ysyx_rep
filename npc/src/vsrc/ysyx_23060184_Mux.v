module ysyx_23060184_Mux_Result_Src (
    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrc,
    input [`DATA_WIDTH - 1:0]           PCPlus4,
    input [`DATA_WIDTH - 1:0]           ALUResult,
    input [`DATA_WIDTH - 1:0]           ReadData,
    input [`DATA_WIDTH - 1:0]           CsrRead,
    output reg [`DATA_WIDTH - 1:0]      Result
);
    MuxKey #(4, `RESULT_SRC_LENGTH, `DATA_WIDTH) i0 (Result, ResultSrc, {
        `RESULT_SRC_PCPlus4,  PCPlus4,
        `RESULT_SRC_ALU,      ALUResult,
        `RESULT_SRC_MEM,      ReadData,
        `RESULT_SRC_CSR,      CsrRead
    });
endmodule

module ysyx_23060184_Mux_ALUSrcA (
    input [`ALU_SRCA_LENGTH - 1:0]   ALUSrcA,
    input [`DATA_WIDTH - 1:0]        PC,
    input [`DATA_WIDTH - 1:0]        RD1,
    output reg [`DATA_WIDTH - 1:0]   SrcA
);
    MuxKey #(3, `ALU_SRCA_LENGTH, `DATA_WIDTH) i0 (SrcA, ALUSrcA, {
        `ALU_SRCA_PC,   PC,
        `ALU_SRCA_RD1,  RD1,
        `ALU_SRCA_ZERO, `DATA_WIDTH'b0
    });

endmodule

module ysyx_23060184_Mux_ALUSrcB (
    input [`ALU_SRCB_LENGTH - 1:0]   ALUSrcB,
    input [`DATA_WIDTH - 1:0]        ImmExt,
    input [`DATA_WIDTH - 1:0]        RD2,
    input [`DATA_WIDTH - 1:0]        CsrRead,
    output reg [`DATA_WIDTH - 1:0]   SrcB
);
    MuxKey #(4, `ALU_SRCB_LENGTH, `DATA_WIDTH) i0 (SrcB, ALUSrcB, {
        `ALU_SRCB_IMM,  ImmExt,
        `ALU_SRCB_RD2,  RD2,
        `ALU_SRCB_CSR,  CsrRead,
        `ALU_SRCB_ZERO, `DATA_WIDTH'b0
    });

endmodule

module ysyx_23060184_Mux_PC_Src (
    input [`PC_SRC_LENGTH - 1:0]     PCSrc,
    input [`DATA_WIDTH - 1:0]        PCPlus4,
    input [`DATA_WIDTH - 1:0]        PCTarget,
    input [`DATA_WIDTH - 1:0]        ALUResult,
    input [`DATA_WIDTH - 1:0]        CsrRead,
    output reg [`DATA_WIDTH - 1:0]   NPC
);
    MuxKey #(4, `PC_SRC_LENGTH, `DATA_WIDTH) i0 (NPC, PCSrc, {
        `PC_SRC_PCPlus4,    PCPlus4,
        `PC_SRC_PCTarget,   PCTarget,
        `PC_SRC_ALU,        ALUResult,
        `PC_SRC_CSRREAD,    CsrRead
    });
    
endmodule

module ysyx_23060184_Mux_RD1E (
    input [`FWDA_MUX_LENGTH - 1:0]   ForwardAE,
    input [`DATA_WIDTH - 1:0]        RD1E,
    input [`DATA_WIDTH - 1:0]        ResultW,
    input [`DATA_WIDTH - 1:0]        ALUResultM,
    output reg [`DATA_WIDTH - 1:0]   FwdRD1E
);
    MuxKey #(3, `FWDA_MUX_LENGTH, `DATA_WIDTH) i0 (FwdRD1E, ForwardAE, {
        `FWDA_MUX_RD1E,         RD1E,
        `FWDA_MUX_RESULTW,      ResultW,
        `FWDA_MUX_ALURESULTM,   ALUResultM
    });
    
endmodule

module ysyx_23060184_Mux_RD2E (
    input [`FWDB_MUX_LENGTH - 1:0]   ForwardBE,
    input [`DATA_WIDTH - 1:0]        RD2E,
    input [`DATA_WIDTH - 1:0]        ResultW,
    input [`DATA_WIDTH - 1:0]        ALUResultM,
    output reg [`DATA_WIDTH - 1:0]   FwdRD2E
);
    MuxKey #(3, `FWDB_MUX_LENGTH, `DATA_WIDTH) i0 (FwdRD2E, ForwardBE, {
        `FWDB_MUX_RD2E,         RD2E,
        `FWDB_MUX_RESULTW,      ResultW,
        `FWDB_MUX_ALURESULTM,   ALUResultM
    });
    
endmodule
