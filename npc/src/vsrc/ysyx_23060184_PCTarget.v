module ysyx_23060184_PCTarget (
    input [`DATA_WIDTH - 1:0]       PC,
    input [`DATA_WIDTH - 1:0]       ImmExt,
    output reg [`DATA_WIDTH - 1:0]  PCTarget
);

    assign PCTarget = PC + ImmExt;

endmodule
