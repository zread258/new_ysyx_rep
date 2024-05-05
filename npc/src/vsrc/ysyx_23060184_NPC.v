module ysyx_23060184_NPC #(NPC_OP_LENGTH = 3, DATA_WIDTH = 32) (
    input                           clk,
    input                           resetn,
    input [NPC_OP_LENGTH - 1:0]     Npc_op,
    input [DATA_WIDTH - 1:0]        PC,
    input [DATA_WIDTH - 1:0]        ALUResult,
    input [DATA_WIDTH - 1:0]        Inst,
    input [19:0]                    Imm20,
    input [DATA_WIDTH - 1:0]        CsrRead,
    output reg [DATA_WIDTH - 1:0]   NPC
);
    reg [DATA_WIDTH - 1:0] PCPlus4;
    reg [DATA_WIDTH - 1:0] JAL_Offset;
    reg [DATA_WIDTH - 1:0] JALR_Offset;
    reg [DATA_WIDTH - 1:0] Branch_Offset;

    assign PCPlus4 = PC + 4;
    assign JAL_Offset = {{12{Imm20[19]}}, {Imm20[7:0]}, {Imm20[8]}, {Imm20[18:9]}, 1'b0};
    assign Branch_Offset = {{20{Inst[31]}}, Inst[7], Inst[30:25], Inst[11:8], 1'b0};

    always @ (clk) begin
        case (Npc_op)
            `NPC_OP_NEXT:
                NPC <= PCPlus4;
            `NPC_OP_JAL:
                NPC <= PC + JAL_Offset;
            `NPC_OP_JALR:
                NPC <= ALUResult;
            `NPC_OP_BRANCH:
                NPC <= PC + Branch_Offset;
            `NPC_OP_CSR:
                NPC <= CsrRead;
            // `NPC_OP_OFFSET:
            //     NPC <= {PCPlus4 + {{14{Imm16[15]}}, {Imm16, 2'b00}}};
            default:
                NPC <= PCPlus4;
        endcase
    end


endmodule //PCPlus4
