module ysyx_23060184_Mux_Result_Src (
    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrc,
    input [`DATA_WIDTH - 1:0]           PC,
    input [`DATA_WIDTH - 1:0]           ALUResult,
    input [`DATA_WIDTH - 1:0]           ReadData,
    output reg [`DATA_WIDTH - 1:0]      Result
);
    MuxKey #(3, `RESULT_SRC_LENGTH, 32) i0 (Result, ResultSrc, {
        `RESULT_SRC_PCPlus4,  PC + 4,
        `RESULT_SRC_ALU,      ALUResult,
        `RESULT_SRC_MEM,      ReadData
    });
endmodule

module ysyx_23060184_Mux_ALUSrcA (
    input [`ALU_SRCA_LENGTH - 1:0]   ALUSrcA,
    input [`DATA_WIDTH - 1:0]        PC,
    input [`DATA_WIDTH - 1:0]        RD1,
    output reg [`DATA_WIDTH - 1:0]   SrcA
);
    MuxKey #(3, `ALU_SRCA_LENGTH, 32) i0 (SrcA, ALUSrcA, {
        `ALU_SRCA_PC,   PC,
        `ALU_SRCA_RD1,  RD1,
        `ALU_SRCA_ZERO, 32'b0
    });

endmodule

module ysyx_23060184_Mux_ALUSrcB (
    input [`ALU_SRCB_LENGTH - 1:0]   ALUSrcB,
    input [`DATA_WIDTH - 1:0]        ImmExt,
    input [`DATA_WIDTH - 1:0]        RD2,
    output reg [`DATA_WIDTH - 1:0]   SrcB
);
    MuxKey #(2, `ALU_SRCB_LENGTH, 32) i0 (SrcB, ALUSrcB, {
        `ALU_SRCB_IMM, ImmExt,
        `ALU_SRCB_RD2, RD2
    });

endmodule