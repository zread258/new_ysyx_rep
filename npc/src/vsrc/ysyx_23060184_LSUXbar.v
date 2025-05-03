module ysyx_23060184_LSUXbar (
    input                             clk,
    input [`DATA_WIDTH - 1:0]         raddr,
    input                             lsu_grant,
    input [`DATA_WIDTH - 1:0]         soc_result,
    input [`DATA_WIDTH - 1:0]         clint_result,
    output reg                        soc,
    output reg                        clint,
    output reg [`DATA_WIDTH - 1:0]    result
);
    // ToDo: 0 -- SoC, 1 -- CLINT  

    assign clint = (lsu_grant) ?
                   (raddr >= `CLINT_ADDR_BEGIN) ? 
                   (raddr <= `CLINT_ADDR_END) ? 1 : 0 : 0 : 0;

    assign soc = (clint) ? 0 :
                 (lsu_grant) ? 1 : 0; // temporarily use this

    always @ (posedge clk) begin
        if (soc) begin
            result <= soc_result;
        end
        else if (clint) begin
            result <= clint_result;
        end
    end

endmodule
