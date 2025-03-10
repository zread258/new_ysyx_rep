module ysyx_23060184_PC (
    input                           clk,
    input                           rstn,
    input                           Branch,
    input                           Iready,
    input                           Ivalid,
    output reg                      Pvalid,
    output reg                      Pready,
    input [`DATA_WIDTH - 1:0]       NPC,
    output reg [`DATA_WIDTH - 1:0]  PC
);

    always @(posedge clk) begin
        if (!rstn) begin
            PC <= 32'h20000000;
            Pvalid <= 1;
            Pready <= 1;
        end
    end

    always @(posedge clk) begin
        if (
            // (Pready && 
        Ivalid || Branch) begin // StallF
            // Pready <= 0;
            PC <= NPC;
            Pvalid <= 1;
        end
    end

    always @(posedge clk) begin
        if (Pvalid && Iready) begin
            Pvalid <= 0;
            // Pready <= 1;
        end
    end

endmodule //PC
