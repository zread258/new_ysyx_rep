module ysyx_23060184_PCSRc (
    /*
        Jump Input Signals Begin
    */
    input                               Jal,
    input                               Jalr,
    /*
        Jump Input Signals End
    */

    /*
        Branch Input Signals Begin
    */
    input                               Beq,
    input                               Bne,
    input                               Bltsu,
    input                               Bgesu,
    input                               Zero,
    input                               Flag, // ALUResult[0]
    /*
        Branch Input Signals End
    */

    /*
        Control Status Input Signals Begin
    */
    input                               Ecall,
    input                               Mret,
    /*
        Control Status Input Signals Begin
    */

    output reg [`PC_SRC_LENGTH - 1:0]   PCSrc
);

    wire Branch = Beq | Bne | Bltsu | Bgesu;

    wire Bflag =  (Beq && Zero) ? 1 :
                    (Bne && ~Zero) ? 1 :
                    ((Bltsu) && Flag) ? 1 : 
                    ((Bgesu) && ~Flag) ? 1 : 0;


    assign PCSrc =  (Jal)                   ? `PC_SRC_PCTarget :
                    (Jalr)                  ? `PC_SRC_ALU :
                    (Branch & Bflag)        ? `PC_SRC_PCTarget :
                    (Ecall || Mret)         ? `PC_SRC_CSRREAD :
                    `PC_SRC_PCPlus4;

endmodule