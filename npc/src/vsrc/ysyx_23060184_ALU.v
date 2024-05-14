module ysyx_23060184_ALU #(DATA_WIDTH = 32) (
    input [DATA_WIDTH - 1:0]        SrcA,
    input [DATA_WIDTH - 1:0]        SrcB,
    input [`ALU_OP_LENGTH - 1:0]    ALUOp,
    output reg                      Zero,
    output reg [DATA_WIDTH - 1:0]   ALUResult
);

    assign ALUResult =  (ALUOp == `ALU_OP_ADD) ? SrcA + SrcB :
                        (ALUOp == `ALU_OP_SUB) ? SrcA - SrcB :
                        (ALUOp == `ALU_OP_OR) ? SrcA | SrcB :
                        (ALUOp == `ALU_OP_AND) ? SrcA & SrcB : 
                        (ALUOp == `ALU_OP_XOR) ? SrcA ^ SrcB :
                        (ALUOp == `ALU_OP_SLT) ? ($signed(SrcA) < $signed(SrcB)) ? 1 : 0 :
                        (ALUOp == `ALU_OP_SLTU) ? (SrcA < SrcB) ? 1 : 0 :
                        (ALUOp == `ALU_OP_SLL) ? (SrcA << SrcB[4:0]) :
                        (ALUOp == `ALU_OP_SRL) ? (SrcA >> SrcB[4:0]) :
                        (ALUOp == `ALU_OP_SRA) ? $signed($signed(SrcA) >>> SrcB[4:0]) :
                        SrcA + SrcB;

    assign Zero = (ALUResult == 0) ? 1 : 0;
    
endmodule //ALU
