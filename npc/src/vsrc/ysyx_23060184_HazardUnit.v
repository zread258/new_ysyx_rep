module ysyx_23060184_HazardUnit(
    input [`REG_LENGTH - 1:0]           Rs1E,
    input [`REG_LENGTH - 1:0]           Rs2E,
    input [`REG_LENGTH - 1:0]           RdM,
    input [`REG_LENGTH - 1:0]           RdW,
    input                               RegWriteM,
    input                               RegWriteW,
    input [`PC_SRC_LENGTH - 1:0]        PCSrcE,
    output [`FWDA_MUX_LENGTH - 1:0]     ForwardAE,
    output [`FWDB_MUX_LENGTH - 1:0]     ForwardBE,
    output                              Branch
);

   assign ForwardAE = (RegWriteW & (Rs1E != 0) & (Rs1E == RdW)) ? `FWDA_MUX_RESULTW :
                      (RegWriteM & (Rs1E != 0) & (Rs1E == RdM)) ? `FWDA_MUX_ALURESULTM :
                      `FWDA_MUX_RD1E; 

   assign ForwardBE = (RegWriteW & (Rs2E != 0) & (Rs2E == RdW)) ? `FWDB_MUX_RESULTW :
                      (RegWriteM & (Rs2E != 0) & (Rs2E == RdM)) ? `FWDB_MUX_ALURESULTM :
                      `FWDB_MUX_RD2E; 

    assign Branch = (PCSrcE == `PC_SRC_PCPlus4) ? 0 : 1;

endmodule
