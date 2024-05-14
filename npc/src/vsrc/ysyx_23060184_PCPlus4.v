module ysyx_23060184_PCPlus4 (
    input [`DATA_WIDTH - 1:0]       PC,
    output reg [`DATA_WIDTH - 1:0]  PCPlus4
);

    assign PCPlus4 = PC + 4;

endmodule
