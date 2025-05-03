module ysyx_23060184_PC (
    input                           clk,
    input                           rstn,
    input                           Branch,
    input                           Stall,
    input                           Iready,
    input                           Ivalid,
    input [`DATA_WIDTH - 1:0]       NPC,
    output reg                      Pvalid,
    output reg [`DATA_WIDTH - 1:0]  PC
);

    always @(posedge clk) begin
        if (!rstn) begin
            PC <= 32'h20000000;
            Pvalid <= 1;
        end
    end

    always @(posedge clk) begin
        if ((Ivalid || Branch) && ~Stall) begin
            PC <= NPC;
            Pvalid <= 1;
        end
    end

    always @(posedge clk) begin
        if (Pvalid && Iready) begin
            Pvalid <= 0;
        end
        if (Stall) begin
            Pvalid <= 0;
        end
    end

endmodule //PC
