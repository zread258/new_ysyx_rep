`define INITIAL_VAL     32'h00000000

module ysyx_23060184_RegFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input wen,
  input [ADDR_WIDTH-1:0] raddr1,
  input [ADDR_WIDTH-1:0] raddr2,
  output reg [DATA_WIDTH-1:0] rdata1,
  output reg [DATA_WIDTH-1:0] rdata2
);
  reg [DATA_WIDTH - 1:0] num;

  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
  always @(posedge clk) begin
    if (wen && waddr != 5'b00000) begin
      rf[waddr] <= wdata;
    end
  end
  assign rdata1 = (raddr1 == 0) ? `INITIAL_VAL : rf[raddr1];
  assign rdata2 = (raddr2 == 0) ? `INITIAL_VAL : rf[raddr2];

endmodule
