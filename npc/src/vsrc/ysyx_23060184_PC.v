module ysyx_23060184_PC #(DATA_WIDTH = 32) (
    input                           clk,
    input                           rstn,
    input                           Wvalid,
    // input                           Iready,
    output reg                      Pvalid,
    input [DATA_WIDTH - 1:0]        NPC,
    output reg [DATA_WIDTH - 1:0]   PC
);
    // initial begin
    //     PC = 32'h80000000;
    //     // Ivalid = 1;
    // end

    always @(posedge clk) begin
        if (!rstn) begin
            PC <= 32'h80000000;
            Pvalid <= 1;
        end else if (Wvalid) begin
            PC <= NPC;
            Pvalid <= 1;
        end else begin
            Pvalid <= 0;
        end
    end
endmodule //PC
