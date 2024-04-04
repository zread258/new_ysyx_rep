`define READ_WORD       3'b000
`define READ_HALF       3'b001
`define READ_BYTE       3'b010
`define READ_HALFU      3'b011
`define READ_BYTEU      3'b100

module ysyx_23060184_DataMem (
    input clk,
    input [31:0] raddr,
    input MemRead,
    input MemWrite,
    input [2:0] ropcode,
    input [7:0] wmask,
    input [31:0] wdata,
    output reg [31:0] result
);

    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(
    input int waddr, input int wdata, input byte wmask);

    reg [31:0] rdata;

    always @(negedge clk) begin
        if (MemRead) begin
            rdata <= pmem_read(raddr);
        end
        if (MemWrite) begin // when MemWrite is high
            pmem_write(raddr, wdata, wmask);
        end
    end

    assign result = (ropcode == `READ_WORD) ? rdata :
                    (ropcode == `READ_HALF) ? {{16{rdata[15]}}, rdata[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{rdata[7]}}, rdata[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, rdata[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, rdata[7:0]} :
                    0;

endmodule