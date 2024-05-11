module ysyx_23060184_Decode(
    input clk,
    input [31:0] inst
);

    import "DPI-C" function void sim_break();

    always @(inst) begin
        if (inst == 32'h00100073) begin
            sim_break();
        end
    end
    
endmodule //ysyx_23060184_Decode
