module ysyx_23060184_PC #(DATA_WIDTH = 32) (
    input                           clk,
    input                           rstn,
    input                           Wvalid,
    input                           Iready,
    output reg                      Pvalid,
    output reg                      Pready,
    input [DATA_WIDTH - 1:0]        NPC,
    output reg [DATA_WIDTH - 1:0]   PC
);

    always @(posedge clk) begin
        if (!rstn) begin
            PC <= 32'h80000000;
            Pvalid <= 1;
            Pready <= 1;
        end
    end

    always @(posedge clk) begin
        if (Wvalid && Pready) begin
            Pready <= 0;
            PC <= NPC;
            Pvalid <= 1;
        end
    end

    always @(posedge clk) begin
        if (Pvalid && Iready) begin
            Pvalid <= 0;
            Pready <= 1;
        end
    end

endmodule //PC
