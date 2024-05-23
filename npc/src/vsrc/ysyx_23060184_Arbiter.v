/*
    Reconstruct it into a finite state machine
    The state machine should have the following states:
        `EMPTY
        `INSTMEM
        `DATAMEM
*/


module ysyx_23060184_Arbiter(
    input                               clk,
    input                               rstn,
    input [`NUM_ARB_MASTERS - 1:0]      req,
    input                               s_rvalid,
    input                               s_wready,
    input [`DATA_WIDTH - 1:0]           iraddr,
    input [`DATA_WIDTH - 1:0]           draddr,
    input [`DATA_WIDTH - 1:0]           dwaddr,
    input                               dren,
    input                               dwen,
    output reg [`NUM_ARB_MASTERS - 1:0] grant
);

    /*
        In this arbiter, we have two masters:
            `INSTMEM_REQ      01
            `DATAMEM_REQ      10
            `BOTH_REQ         11

            ToDo: Read and Write concurrently
                Differentiate between read and write requests

        Take `EMPTY_REQ 00 as default

        we also have two slaves -- SRAM and UART
            `INSTMEM_GRANT    01
            `DATAMEM_GRANT    10
            `UART_GRANT       11
    */

    reg [`DATA_WIDTH - 1:0] addr;
    assign addr = (req == `DATAMEM_REQ) ?  
                  (dren) ? draddr : dwaddr : 
                                    iraddr;

    typedef enum reg [1:0] {
        IDLE    = 2'b00,
        DGRANT  = 2'b01,
        IGRANT  = 2'b10
    } state_t;

    // State Registers
    reg [1:0] current_state;

    // State Transition Logic
    always @(posedge clk) begin
        if (~rstn) begin
            current_state <= IDLE;
        end
    end

    // // Next State & Output Logic
    always @ (posedge clk) begin
        case (current_state) 
            IDLE: begin
                case (req)
                    `EMPTY_REQ: begin
                        grant <= `EMPTY_GRANT;
                        current_state <= IDLE;
                    end
                    `INSTMEM_REQ: begin
                        grant <= `INSTMEM_GRANT;
                        current_state <= IGRANT;
                    end
                    `DATAMEM_REQ: begin
                        grant <= `DATAMEM_GRANT;
                        current_state <= DGRANT;
                    end
                    `BOTH_REQ: begin
                        grant <= `DATAMEM_GRANT;
                        current_state <= DGRANT;
                    end
                endcase
            end

            DGRANT: begin
                if (s_rvalid || s_wready) begin
                    current_state <= IDLE;
                    grant <= `EMPTY_GRANT;
                end
                else
                    current_state <= DGRANT;
            end

            IGRANT: begin
                if (s_rvalid) begin
                    current_state <= IDLE;
                    grant <= `EMPTY_GRANT;
                end
                else
                    current_state <= IGRANT;
            end

            default: current_state <= IDLE;
        endcase
    end

    // always @(posedge clk) begin
    //     if (addr >= `SRAM_ADDR_BEGIN && 
    //             addr <= `SRAM_ADDR_END) begin
    //         case (req)
    //             `EMPTY_REQ:
    //                 grant <= `EMPTY_GRANT;
    //             `INSTMEM_REQ:
    //                 grant <= `INSTMEM_GRANT;
    //             `DATAMEM_REQ:
    //                 grant <= `DATAMEM_GRANT;
    //             `BOTH_REQ: begin
    //                 if (s_rvalid)
    //                     grant <= `DATAMEM_GRANT;
    //             end
    //         endcase
    //     end else if (addr >= `UART_ADDR_BEGIN && 
    //             addr <= `UART_ADDR_END) begin
    //         case (req) 
    //             `EMPTY_REQ:
    //                 grant <= `EMPTY_GRANT;
    //             `DATAMEM_REQ:
    //                 grant <= `UART_GRANT;
    //             default:
    //                 grant <= `EMPTY_GRANT;
    //         endcase
    //     end
    // end

endmodule
