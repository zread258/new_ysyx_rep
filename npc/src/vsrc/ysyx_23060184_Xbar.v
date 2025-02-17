module ysyx_23060184_Xbar (
    input                             clk,
    input                             rstn,
    input                             ifu_req,
    input                             lsu_req,
    input      [  `DATA_WIDTH - 1:0]  ifu_araddr,
    input      [  `DATA_WIDTH - 1:0]  lsu_araddr,
    output reg                        ifu_grant,
    output reg                        lsu_grant,
    output reg [  `DATA_WIDTH - 1:0]  io_master_araddr    
);

    reg [1:0] state;

    always @ (posedge clk) begin
        if (~rstn) begin
            state <= 2'b00; // IDLE
        end else begin
            case (state)
                2'b00: begin // IDLE
                    if (lsu_req) begin
                        state <= 2'b01; // LSU-state
                    end else if (ifu_req) begin
                        state <= 2'b10; // IFU-state
                    end
                end
                2'b01: begin // LSU-state
                    if (~lsu_req) begin
                        if (ifu_req) begin
                            state <= 2'b10;
                        end else begin
                            state <= 2'b00;
                        end
                    end
                end
                2'b10: begin // IFU-state
                    if (~ifu_req) begin
                        if (lsu_req) begin
                            state <= 2'b01;
                        end else begin
                            state <= 2'b00;
                        end
                    end
                end
                2'b11: begin // Undefined
                    state <= 2'b00;
                end
            endcase
        end
    end

    assign lsu_grant = (state == 2'b01 && lsu_req) ? 1 : 0;
    assign ifu_grant = (state == 2'b10 && ifu_req) ? 1 : 0;

    assign io_master_araddr = lsu_grant ? lsu_araddr : ifu_araddr;

endmodule
