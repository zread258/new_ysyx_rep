module ysyx_23060184_Arbiter(
    input                               clk,
    input [`NUM_ARB_MASTERS - 1:0]      req,
    input [`DATA_WIDTH - 1:0]           iaddr,
    input [`DATA_WIDTH - 1:0]           daddr,
    output reg [`NUM_ARB_MASTERS - 1:0] grant
);

    /*
        In this arbiter, we have two masters:
            `INSTMEM_REQ      01
            `DATAMEM_REQ      10
            `BOTH_REQ         11

        Take `EMPTY_REQ 00 as default

        we also have two slaves -- SRAM and UART
            `INSTMEM_GRANT    01
            `DATAMEM_GRANT    10
            `UART_GRANT       11
    */

    reg [`DATA_WIDTH - 1:0] addr;
    assign addr = (req == `INSTMEM_REQ) ? iaddr : daddr;

    always @(posedge clk) begin
        if (addr >= `SRAM_ADDR_BEGIN && 
                addr <= `SRAM_ADDR_END) begin
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
        end else if (addr >= `UART_ADDR_BEGIN && 
                addr <= `UART_ADDR_END) begin
            case (req) 
                `EMPTY_REQ:
                    grant <= `EMPTY_GRANT;
                `DATAMEM_REQ:
                    grant <= `UART_GRANT;
                default:
                    grant <= `EMPTY_GRANT;
            endcase
        end
    end

endmodule