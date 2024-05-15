`define INITIAL_VAL     32'h00000000

module ysyx_23060184_RegFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input                       clk,
  input                       resetn,
  input [DATA_WIDTH-1:0]      wdata,
  input [ADDR_WIDTH-1:0]      waddr,
  input                       wen,
  input [ADDR_WIDTH-1:0]      raddr1,
  input [ADDR_WIDTH-1:0]      raddr2,
  input                       Ivalid,
  input                       Wvalid,
  input                       Pready, // Warning: Change Pready to Iready, to be tested
  input                       Wready,
  output reg                  Evalid,
  output reg                  Eready,
  input                       ecall,
  output reg [DATA_WIDTH-1:0] rdata1,
  output reg [DATA_WIDTH-1:0] rdata2
);

  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];

  always @(posedge clk) begin
    if (~resetn) begin
      Eready <= 1;
    end
  end

  always @(posedge clk) begin
    if (Wvalid && Pready) begin // Warning: Change Pready to Iready, to be tested
      if (wen && waddr != 5'b00000) begin
        rf[waddr] <= wdata;
      end
    end
  end

  always @(posedge clk) begin
    Eready <= 1;
    if (Eready && Ivalid) begin
      Eready <= 0;
      Evalid <= 1;
    end
    if (Evalid && Wready) begin
      Evalid <= 0;
    end
  end

  assign rdata1 = (raddr1 == 0) ? `INITIAL_VAL : rf[raddr1];
  assign rdata2 = (raddr2 == 0 && ~ecall) ? `INITIAL_VAL : 
                  (ecall) ? rf[15] : rf[raddr2]; // rv32 or rv32e ? rf[17] : rf[15]

endmodule
