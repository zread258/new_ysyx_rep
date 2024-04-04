module ysyx_23060184_Decode(
    input clk,
    input [31:0] inst
    // output [4:0] opcode,
    // output [4:0] funct3,
    // output [6:0] funct7,
    // output [6:0] shamt,
    // output [1:0] branch,
    // output [2:0] aluop,
    // output [1:0] memop,
    // output [1:0] memwidth,
    // output [1:0] memsign,
    // output [1:0] regwrite,
    // output [1:0] memtoreg,
);
    // reg [31:0] buffer;
    import "DPI-C" function void sim_break();

    always @(inst) begin
        if (inst == 32'h00100073) begin
            sim_break();
        end
        // buffer <= inst;
    end
endmodule //ysyx_23060184_Decode
