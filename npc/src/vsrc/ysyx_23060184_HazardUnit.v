module ysyx_23060184_HazardUnit(
    input [`REG_LENGTH - 1:0]           Rs1D,
    input [`REG_LENGTH - 1:0]           Rs2D,
    input [`REG_LENGTH - 1:0]           Rs1E,
    input [`REG_LENGTH - 1:0]           Rs2E,
    input [`REG_LENGTH - 1:0]           RdE,
    input [`REG_LENGTH - 1:0]           RdM,
    input [`REG_LENGTH - 1:0]           RdW,
    input                               RegWriteM,
    input                               RegWriteW,
    input                               Rs2DValid,
    input                               JumpBranch,
    input [`PC_SRC_LENGTH - 1:0]        PCSrcE,
    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrcE,
    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrcM,
    output                              StallF,
    output                              StallD,
    output                              StallE,
    output                              FlushD,
    output                              FlushE,
    output [`FWDA_MUX_LENGTH - 1:0]     ForwardAE,
    output [`FWDB_MUX_LENGTH - 1:0]     ForwardBE,
    output                              Branch,
    output                              ControlStall,
    output                              LoadStall
);

   assign ForwardAE = (RegWriteW & (Rs1E != 0) & (Rs1E == RdW)) ? `FWDA_MUX_RESULTW :
                      (RegWriteM & (Rs1E != 0) & (Rs1E == RdM)) ? `FWDA_MUX_ALURESULTM :
                      `FWDA_MUX_RD1E; 

   assign ForwardBE = (RegWriteW & (Rs2E != 0) & (Rs2E == RdW)) ? `FWDB_MUX_RESULTW :
                      (RegWriteM & (Rs2E != 0) & (Rs2E == RdM)) ? `FWDB_MUX_ALURESULTM :
                      `FWDB_MUX_RD2E; 

    assign Branch = (PCSrcE == `PC_SRC_PCPlus4) ? 0 : 1;

    assign ControlStall = JumpBranch ? 1 : 0;

    wire LoadStallE = (ResultSrcE == `RESULT_SRC_MEM) &
                       ((Rs1D == RdE) | ((Rs2D == RdE) & Rs2DValid)) ? 1 : 0;

    wire LoadStallM = (ResultSrcM == `RESULT_SRC_MEM) &
                       ((Rs1D == RdM) | ((Rs2D == RdM) & Rs2DValid)) ? 1 : 0;

    assign StallF = LoadStallE | LoadStallM;

    assign StallD = LoadStallE | LoadStallM;

    assign StallE = LoadStallE | LoadStallM;

    assign FlushD = Branch;

    assign FlushE = LoadStallE | LoadStallM;

endmodule
