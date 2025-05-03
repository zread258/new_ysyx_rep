module ysyx_23060184_RegIFID(
    input                                 clk,
    input                                 rstn,
    // input                                 clr,
    input                                 Stall,
    input                                 Ivalid,
    input                                 Dready,
    input                                 Dvalid,
    input                                 Eready,
    input           [`DATA_WIDTH - 1:0]   InstF,
    input           [`DATA_WIDTH - 1:0]   PCPlus4F,
    input           [`DATA_WIDTH - 1:0]   PCF,
    output   reg    [`DATA_WIDTH - 1:0]   InstD,
    output   reg    [`DATA_WIDTH - 1:0]   PCPlus4D,
    output   reg    [`DATA_WIDTH - 1:0]   PCD
);

    always @(posedge clk) begin
        if (~rstn) begin
            InstD <= 0;
            PCPlus4D <= 0;
            PCD <= 0;
        end else if (Ivalid && Dready) begin
            InstD <= InstF;
            PCPlus4D <= PCPlus4F;
            PCD <= PCF;
        end else if (Dvalid && Eready && ~Stall) begin
            InstD <= `INST_NOP;
            PCPlus4D <= 0;
            PCD <= 0;
        end
    end
    
endmodule //RegIFID
