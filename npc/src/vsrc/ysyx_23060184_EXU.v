module ysyx_23060184_EXU (

    input                               clk,
    input                               rstn,


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

    /* --------------------------------------------- */

    /*
        ALU Output Signals Begin
    */
    output [`DATA_WIDTH - 1:0]          ALUResult,
    /*
        ALU Output Signals End
    */

    output [`DATA_WIDTH - 1:0]          PCTarget,
    output [`PC_SRC_LENGTH - 1:0]       PCSrc
    
);

    wire Zero;

    wire [`DATA_WIDTH - 1:0] SrcA, SrcB;

    ysyx_23060184_Mux_ALUSrcA Mux_ALUSrcA (
        .ALUSrcA(ALUSrcA),
        .PC(PC),
        .RD1(RD1),
        .SrcA(SrcA)
    );

    ysyx_23060184_Mux_ALUSrcB Mux_ALUSrcB (
        .ALUSrcB(ALUSrcB),
        .ImmExt(ImmExt),
        .RD2(RD2),
        .CsrRead(CsrRead),
        .SrcB(SrcB)
    );   

    ysyx_23060184_ALU ALU (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUOp(ALUOp),
        .Zero(Zero),
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