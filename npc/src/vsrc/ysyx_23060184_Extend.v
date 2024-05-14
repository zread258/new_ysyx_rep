module ysyx_23060184_Extend (
    input  [`DATA_WIDTH - 1:0]      Inst,
    input  [`EXT_OP_LENGTH - 1:0]   ExtOp,
    output [`DATA_WIDTH - 1:0]      ImmExt
);
    assign ImmExt = (ExtOp == `EXT_OP_I) ? {{20{Inst[31]}}, Inst[31:20]} :
            (ExtOp == `EXT_OP_U) ? {Inst[31:12], 12'b0} :
            (ExtOp == `EXT_OP_S) ? {{20{Inst[31]}}, Inst[31:25], Inst[11:7]} : 
            (ExtOp == `EXT_OP_B) ? {{20{Inst[31]}}, Inst[7], Inst[30:25], Inst[11:8], 1'b0} : 
            (ExtOp == `EXT_OP_J) ? {{12{Inst[31]}}, {Inst[19:12]}, {Inst[20]}, {Inst[30:21]}, 1'b0} :
            32'b0;
    
endmodule //Extend
