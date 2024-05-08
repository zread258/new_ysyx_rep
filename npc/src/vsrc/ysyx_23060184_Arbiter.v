module ysyx_23060184_Arbiter(
    input                               clk,
    input [`NUM_ARB_MASTERS - 1:0]      req,
    output reg [`NUM_ARB_MASTERS - 1:0] grant
);

    /*
        In this arbiter, we have two masters:
            `INSTMEM_REQ      01
            `DATAMEM_REQ      10
            `BOTH_REQ         11

        Take `EMPTY_REQ 00 as default
    */

    always @(posedge clk) begin
        case (req)
            `EMPTY_REQ:
                grant <= `EMPTY_GRANT;
            `INSTMEM_REQ:
                grant <= `INSTMEM_GRANT;
            `DATAMEM_REQ:
                grant <= `DATAMEM_GRANT;
            `BOTH_REQ:
                grant <= `INSTMEM_GRANT;
        endcase
    end

endmodule