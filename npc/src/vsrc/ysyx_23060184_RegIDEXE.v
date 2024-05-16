module ysyx_23060184_RegIDEXE (
    input                                       clk,
    input                                       resetn,
    input                                       Dvalid,
    input                                       Eready,
    input                                       RegWriteD,
    input                                       MemReadD,
    input                                       MemWriteD,
    input                                       CsrWriteD,
    input                                       JalD,
    input                                       JalrD,
    input                                       BneD,
    input                                       BeqD,
    input                                       BltsuD,
    input                                       BgesuD,
    input                                       EcallD,
    input                                       MretD,
    input           [`WMASK_LENGTH - 1:0]       WmaskD,
    input           [`ROPCODE_LENGTH - 1:0]     RopcodeD,
    input           [`RESULT_SRC_LENGTH - 1:0]  ResultSrcD,
    input           [`ALU_SRCA_LENGTH - 1:0]    ALUSrcAD,
    input           [`ALU_SRCB_LENGTH - 1:0]    ALUSrcBD,
    input           [`ALU_OP_LENGTH - 1:0]      ALUOpD,
    input           [`DATA_WIDTH - 1:0]         RD1D,
    input           [`DATA_WIDTH - 1:0]         RD2D,
    input           [`DATA_WIDTH - 1:0]         PCD,
    input           [`DATA_WIDTH - 1:0]         ImmExtD,
    input           [`DATA_WIDTH - 1:0]         PCPlus4D,
    input           [`DATA_WIDTH - 1:0]         CsrReadD,
    input           [`REG_LENGTH - 1:0]         Rs1D,
    input           [`REG_LENGTH - 1:0]         Rs2D,
    input           [`REG_LENGTH - 1:0]         RdD,
    output reg                                  RegWriteE,
    output reg                                  MemReadE,
    output reg                                  MemWriteE,
    output reg                                  CsrWriteE,
    output reg                                  JalE,
    output reg                                  JalrE,
    output reg                                  BneE,
    output reg                                  BeqE,
    output reg                                  BltsuE,
    output reg                                  BgesuE,
    output reg                                  EcallE,
    output reg                                  MretE,
    output reg      [`WMASK_LENGTH - 1:0]       WmaskE,
    output reg      [`ROPCODE_LENGTH - 1:0]     RopcodeE,
    output reg      [`RESULT_SRC_LENGTH - 1:0]  ResultSrcE,
    output reg      [`ALU_SRCA_LENGTH - 1:0]    ALUSrcAE,
    output reg      [`ALU_SRCB_LENGTH - 1:0]    ALUSrcBE,
    output reg      [`ALU_OP_LENGTH - 1:0]      ALUOpE,
    output reg      [`DATA_WIDTH - 1:0]         RD1E,
    output reg      [`DATA_WIDTH - 1:0]         RD2E,
    output reg      [`DATA_WIDTH - 1:0]         PCE,
    output reg      [`DATA_WIDTH - 1:0]         ImmExtE,
    output reg      [`DATA_WIDTH - 1:0]         PCPlus4E,
    output reg      [`DATA_WIDTH - 1:0]         CsrReadE,
    output reg      [`REG_LENGTH - 1:0]         Rs1E,
    output reg      [`REG_LENGTH - 1:0]         Rs2E,
    output reg      [`REG_LENGTH - 1:0]         RdE
);

    always @(posedge clk) begin
        if (~resetn) begin
            RegWriteE <= 1'b0;
            MemReadE <= 1'b0;
            MemWriteE <= 1'b0;
            CsrWriteE <= 1'b0;
            JalE <= 1'b0;
            JalrE <= 1'b0;
            BneE <= 1'b0;
            BeqE <= 1'b0;
            BltsuE <= 1'b0;
            BgesuE <= 1'b0;
            EcallE <= 1'b0;
            MretE <= 1'b0;
            WmaskE <= 0;
            RopcodeE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            ImmExtE <= 0;
            PCPlus4E <= 0;
            CsrReadE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
        end else if (Dvalid && Eready) begin
            RegWriteE <= RegWriteD;
            MemReadE <= MemReadD;
            MemWriteE <= MemWriteD;
            CsrWriteE <= CsrWriteD;
            JalE <= JalD;
            JalrE <= JalrD;
            BneE <= BneD;
            BeqE <= BeqD;
            BltsuE <= BltsuD;
            BgesuE <= BgesuD;
            EcallE <= EcallD;
            MretE <= MretD;
            WmaskE <= WmaskD;
            RopcodeE <= RopcodeD;
            ResultSrcE <= ResultSrcD;
            ALUSrcAE <= ALUSrcAD;
            ALUSrcBE <= ALUSrcBD;
            ALUOpE <= ALUOpD;
            RD1E <= RD1D;
            RD2E <= RD2D;
            PCE <= PCD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
            CsrReadE <= CsrReadD;
            Rs1E <= Rs1D;
            Rs2E <= Rs2D;
            RdE <= RdD;
        end
    end
    
endmodule //RegIFID
