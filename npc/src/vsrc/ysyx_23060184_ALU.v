module ysyx_23060184_ALU #(DATA_WIDTH = 32) (
    input                           clk,
    input                           rstn,
    input                           Stall,
    input                           Dvalid,
    input                           Mready,
    input [DATA_WIDTH - 1:0]        SrcA,
    input [DATA_WIDTH - 1:0]        SrcB,
    input [`ALU_OP_LENGTH - 1:0]    ALUOp,
    output reg                      Evalid,
    output reg                      Eready,
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

    // always @ (posedge clk) begin
    //     if (~rstn) begin
    //         ALUResult <= 0;
    //         Evalid <= 0;
    //         Eready <= 1;
    //     end else if (Dvalid && Eready) begin
    //         case (ALUOp)
    //             `ALU_OP_ADD:    ALUResult <= SrcA + SrcB;
    //             `ALU_OP_SUB:    ALUResult <= SrcA - SrcB;
    //             `ALU_OP_OR:     ALUResult <= SrcA | SrcB;
    //             `ALU_OP_AND:    ALUResult <= SrcA & SrcB;
    //             `ALU_OP_XOR:    ALUResult <= SrcA ^ SrcB;
    //             `ALU_OP_SLT:    ALUResult <= ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
    //             `ALU_OP_SLTU:   ALUResult <= (SrcA < SrcB) ? 1 : 0;
    //             `ALU_OP_SLL:    ALUResult <= (SrcA << SrcB[4:0]);
    //             `ALU_OP_SRL:    ALUResult <= (SrcA >> SrcB[4:0]);
    //             `ALU_OP_SRA:    ALUResult <= $signed($signed(SrcA) >>> SrcB[4:0]);
    //             default:        ALUResult <= SrcA + SrcB;
    //         endcase
    //         Evalid <= 1;
    //         Eready <= 0;
    //     end
    // end

    always @ (posedge clk) begin
        if (~rstn) begin
            Evalid <= 0;
            Eready <= 1;
        end

        if (Dvalid && Eready && ~Stall) begin
            Evalid <= 1;
            Eready <= 0;
        end
    end

    always @ (posedge clk) begin
        if (Evalid && Mready) begin
            Eready <= 1;
            Evalid <= 0;
        end
    end

    assign Zero = (ALUResult == 0) ? 1 : 0;
    
endmodule //ALU
