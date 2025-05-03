module ysyx_23060184_EXU (

    input                               clk,
    input                               rstn,
    input                               Stall,
    input                               Dvalid,
    input                               Mready,


    /*
        ALU Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           RD1, 
    input [`DATA_WIDTH - 1:0]           RD2, 
    input [`ALU_OP_LENGTH - 1:0]        ALUOp,

    /*
        ALU Input Signals End
    */


    /*
        Mux Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           PC, 
    input [`DATA_WIDTH - 1:0]           CsrRead, 
    input [`DATA_WIDTH - 1:0]           ImmExt, 
    input [`ALU_SRCA_LENGTH - 1:0]      ALUSrcA,
    input [`ALU_SRCB_LENGTH - 1:0]      ALUSrcB,

    /*
        Mux Input Signals End
    */

    /*
        PCSRc Input Signals Begin
    */

    input                               Jal,
    input                               Jalr,
    input                               Beq,
    input                               Bne,
    input                               Bltsu,
    input                               Bgesu,
    input                               Ecall,
    input                               Mret,

    /*
        PCSRc Input Signals End
    */

    /*
        Forwarding Input Signals Begin
    */

    input [`FWDA_MUX_LENGTH - 1:0]      ForwardAE,
    input [`FWDB_MUX_LENGTH - 1:0]      ForwardBE,
    input [`DATA_WIDTH - 1:0]           ResultW,
    input [`DATA_WIDTH - 1:0]           ALUResultM,

    /*
        Forwarding Input Signals End
    */

    /* --------------------------------------------- */

    output                              Evalid,
    output                              Eready,

    /*
        ALU Output Signals Begin
    */
    output [`DATA_WIDTH - 1:0]          ALUResult,
    /*
        ALU Output Signals End
    */

    output reg [`DATA_WIDTH - 1:0]      WriteData, // ToDo: Data Hazard

    output [`DATA_WIDTH - 1:0]          PCTarget,
    output [`PC_SRC_LENGTH - 1:0]       PCSrc
    
);

    wire Zero;

    wire [`DATA_WIDTH - 1:0] SrcA, SrcB;
    wire [`DATA_WIDTH - 1:0] FwdRD1E, FwdRD2E;

    assign WriteData = FwdRD2E;

    ysyx_23060184_Mux_RD1E Mux_RD1E (
        .ForwardAE(ForwardAE),
        .RD1E(RD1),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .FwdRD1E(FwdRD1E)
    );

    ysyx_23060184_Mux_RD2E Mux_RD2E (
        .ForwardBE(ForwardBE),
        .RD2E(RD2),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .FwdRD2E(FwdRD2E)
    );

    ysyx_23060184_Mux_ALUSrcA Mux_ALUSrcA (
        .ALUSrcA(ALUSrcA),
        .PC(PC),
        .RD1(FwdRD1E),
        .SrcA(SrcA)
    );

    ysyx_23060184_Mux_ALUSrcB Mux_ALUSrcB (
        .ALUSrcB(ALUSrcB),
        .ImmExt(ImmExt),
        .RD2(FwdRD2E),
        .CsrRead(CsrRead),
        .SrcB(SrcB)
    );   

    ysyx_23060184_ALU ALU (
        .clk(clk),
        .rstn(rstn),
        .Stall(Stall),
        .Dvalid(Dvalid),
        .Mready(Mready),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUOp(ALUOp),
        .Zero(Zero),
        .Evalid(Evalid),
        .Eready(Eready),
        .ALUResult(ALUResult)
    );

    ysyx_23060184_PCTarget PCTArget (
        .PC(PC),
        .ImmExt(ImmExt),
        .PCTarget(PCTarget)
    );

    ysyx_23060184_PCSRc PCSRc (
        .Jal(Jal),
        .Jalr(Jalr),
        .Beq(Beq),
        .Bne(Bne),
        .Bltsu(Bltsu),
        .Bgesu(Bgesu),
        .Zero(Zero),
        .Flag(ALUResult[0]),
        .Ecall(Ecall),
        .Mret(Mret),
        .PCSrc(PCSrc)
    );

endmodule