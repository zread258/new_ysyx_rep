`include "ysyx_23060184_Config.v"

module ysyx_23060184_RegMEMWB(
    input                                       clk,
    input                                       resetn,

    input                                       Mvalid,
    input                                       Wready,

    /* 
        MEM Stage Signals input Begin
    */

    input           [`DATA_WIDTH - 1:0]         PCM,
    input           [`DATA_WIDTH - 1:0]         InstM,
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

    output   reg    [`DATA_WIDTH - 1:0]         PCW,
    output   reg    [`DATA_WIDTH - 1:0]         InstW,
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
            PCW <= 0;
            InstW <= 0;
            RegWriteW <= 0;
            ResultSrcW <= 0;
            PCPlus4W <= 0;
            ReadDataW <= 0;
            CsrReadW <= 0;
            ALUResultW <= 0;
            RdW <= 0;
            CsrAddrW <= 0;
        end else if (Mvalid && Wready) begin
            PCW <= PCM;
            InstW <= InstM;
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
        //     RdW <= 0;
        // end

        /* 
        ToDo: Here are some problems, The RegWriteW is not reset
        So, there may be double write. But if reset the RegWriteW
        The Forwarding will not work, it needs more time to think
        */
        
    end
    
endmodule //ysyx_23060184_RegMEMWB
