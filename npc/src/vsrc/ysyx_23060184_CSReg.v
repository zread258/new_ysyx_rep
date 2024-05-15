`define CSR_ADDR_LENGTH 10
`define CSR_MSTATUS     10'h300
`define CSR_MTVEC       10'h305
`define CSR_MEPC        10'h341
`define CSR_MCAUSE      10'h342

module ysyx_23060184_CSReg #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input                           clk,
  input                           ecall,
  input                           mret,
  input [DATA_WIDTH - 1:0]        pc, 
  input [DATA_WIDTH - 1:0]        wdata,
  input [`CSR_ADDR_LENGTH - 1:0]  waddr,
  input                           wen,
  input [`CSR_ADDR_LENGTH - 1:0]  raddr,
  input                           Pready,
  input                           Wvalid,
  output reg [DATA_WIDTH - 1:0]   rdata
);

  reg [DATA_WIDTH-1:0] csr [2**`CSR_ADDR_LENGTH - 1:0];

  always @(posedge clk) begin
    if (Wvalid && Pready) begin
      if (wen) begin
          csr[waddr] <= wdata;
      end
      if (ecall) begin
          csr[`CSR_MCAUSE] <= wdata;
          csr[`CSR_MEPC] <= pc;
      end
    end
  end
  assign rdata = (ecall) ? csr[`CSR_MTVEC] : 
                 (mret) ? csr[`CSR_MEPC] : csr[raddr];

endmodule
