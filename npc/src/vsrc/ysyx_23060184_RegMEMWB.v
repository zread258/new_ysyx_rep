`include "ysyx_23060184_Config.v"

module ysyx_23060184_RegMEMWB(
    input                                       clk,
    input                                       resetn,

    input                                       Mvalid,
    input                                       Wready,

    /* 
        MEM Stage Signals input Begin
    */

    input                                       RegWriteM,
    input                                       CsrWriteM,
    input           [`RESULT_SRC_LENGTH - 1:0]  ResultSrcM,
    input           [`DATA_WIDTH - 1:0]         ALUResultM,
    input           [`DATA_WIDTH - 1:0]         PCPlus4M,
    input           [`DATA_WIDTH - 1:0]         ReadDataM,
    input           [`DATA_WIDTH - 1:0]         CsrReadM,
    input           [`REG_LENGTH - 1:0]         RdM,
    input           [`CSR_LENGTH - 1:0]         CsrAddrM,

    /* 
        MEM Stage Signals input End
    */


    /* 
        WB Stage Signals output Begin
    */

    output   reg                                RegWriteW,
    output   reg                                CsrWriteW,
    output   reg    [`RESULT_SRC_LENGTH - 1:0]  ResultSrcW,
    output   reg    [`DATA_WIDTH - 1:0]         ALUResultW,
    output   reg    [`DATA_WIDTH - 1:0]         PCPlus4W,
    output   reg    [`DATA_WIDTH - 1:0]         ReadDataW,
    output   reg    [`DATA_WIDTH - 1:0]         CsrReadW,
    output   reg    [`REG_LENGTH - 1:0]         RdW,
    output   reg    [`CSR_LENGTH - 1:0]         CsrAddrW

    /* 
        WB Stage Signals output End
    */
);

    always @(posedge clk) begin
        if (~resetn) begin
            RegWriteW <= 0;
            ResultSrcW <= 0;
            PCPlus4W <= 0;
            ReadDataW <= 0;
            CsrReadW <= 0;
            ALUResultW <= 0;
            RdW <= 0;
            CsrAddrW <= 0;
        end else if (Mvalid && Wready) begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            PCPlus4W <= PCPlus4M;
            ReadDataW <= ReadDataM;
            CsrReadW <= CsrReadM;
            ALUResultW <= ALUResultM;
            RdW <= RdM;
            CsrAddrW <= CsrAddrM;
        end 
        // else begin
        //     RegWriteW <= 0;
        //     ResultSrcW <= 0;
        //     PCPlus4W <= 0;
        //     ReadDataW <= 0;
        //     CsrReadW <= 0;
        //     ALUResultW <= 0;
        //     RdW <= 0;
        // end
    end
    
endmodule //ysyx_23060184_RegMEMWB
