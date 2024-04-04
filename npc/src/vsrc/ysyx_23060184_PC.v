module ysyx_23060184_PC #(DATA_WIDTH = 32) (
    input clk,
    input rstn,
    input [DATA_WIDTH - 1:0] NPC,
    output reg [DATA_WIDTH - 1:0] PC
);
    initial begin
        PC = 32'h80000000;
    end

    always @(posedge clk) begin
        if (!rstn) begin
            PC <= 32'h80000000;
        end else
            PC <= NPC;
    end
endmodule //PC
