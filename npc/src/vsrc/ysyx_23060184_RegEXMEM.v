module ysyx_23060184_RegEXMEM(
    input                                       clk,
    input                                       resetn,
    input                                       Evalid,
    input                                       Mready,
    input                                       RegWriteE,
    input                                       MemReadE,
    input                                       MemWriteE,
    input                                       CsrWriteE,
    input           [`WMASK_LENGTH - 1:0]       WmaskE,
    input           [`ROPCODE_LENGTH - 1:0]     RopcodeE,
    input           [`RESULT_SRC_LENGTH - 1:0]  ResultSrcE,
    input           [`DATA_WIDTH - 1:0]         WriteDataE,
    input           [`DATA_WIDTH - 1:0]         PCPlus4E,
    input           [`DATA_WIDTH - 1:0]         CsrReadE,
    input           [`REG_LENGTH - 1:0]         RdE,
    input           [`DATA_WIDTH - 1:0]         ALUResultE,
    output   reg                                RegWriteM,
    output   reg                                MemReadM,
    output   reg                                MemWriteM,
    output   reg                                CsrWriteM,
    output   reg    [`WMASK_LENGTH - 1:0]       WmaskM,
    output   reg    [`ROPCODE_LENGTH - 1:0]     RopcodeM,
    output   reg    [`RESULT_SRC_LENGTH - 1:0]  ResultSrcM,
    output   reg    [`DATA_WIDTH - 1:0]         WriteDataM,
    output   reg    [`DATA_WIDTH - 1:0]         PCPlus4M,
    output   reg    [`DATA_WIDTH - 1:0]         CsrReadM,
    output   reg    [`REG_LENGTH - 1:0]         RdM,
    output   reg    [`DATA_WIDTH - 1:0]         ALUResultM
);

    always @(posedge clk) begin
        if (~resetn) begin
            RegWriteM <= 0;
            MemReadM <= 0;
            MemWriteM <= 0;
            CsrWriteM <= 0;
            WmaskM <= 0;
            RopcodeM <= 0;
            ResultSrcM <= 0;
            WriteDataM <= 0;
            PCPlus4M <= 0;
            RdM <= 0;
            CsrReadM <= 0;
            ALUResultM <= 0;
        end else if (Evalid && Mready) begin
            RegWriteM <= RegWriteE;
            MemReadM <= MemReadE;
            MemWriteM <= MemWriteE;
            CsrWriteM <= CsrWriteE;
            WmaskM <= WmaskE;
            RopcodeM <= RopcodeE;
            ResultSrcM <= ResultSrcE;
            WriteDataM <= WriteDataE;
            PCPlus4M <= PCPlus4E;
            RdM <= RdE;
            CsrReadM <= CsrReadE;
            ALUResultM <= ALUResultE;
        end
    end
    
endmodule //ysyx_23060184_RegEXMEM
