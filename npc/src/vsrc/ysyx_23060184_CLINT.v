module ysyx_23060184_CLINT (
    input                               clk,
    input                               resetn,

    /*
        AXI4 Handshake signals Begin
    */

    input [`NUM_ARB_MASTERS - 1:0]      grant,
    input                               arready,
    input [`DATA_WIDTH - 1:0]           raddr,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,

    /*
        AXI4 Handshake signals End
    */

    /*
        AXI4 Handshake signals Begin
    */
    output [`DATA_WIDTH - 1:0]          araddr,
    output                              arvalid,
    output                              rready,
    output [`ID_WIDTH - 1:0]            arid,
    output [`ALEN - 1:0]                arlen,
    output [`ASIZE - 1:0]               arsize,
    output [`ABURST - 1:0]              arburst,
    output [`DATA_WIDTH - 1:0]          rdata
    /*
        AXI4 Handshake signals End
    */
);

    reg [`DDATA_WIDTH - 1:0]     mtime; // 64-bit interupt register

    always @ (posedge clk) begin
        if (!resetn) begin
            mtime <= 0;
        end else begin
            mtime <= mtime + 1;
        end
    end

    always @ (posedge clk) begin
        if (grant[0] && arready && arvalid) begin
            rdata <= mtime;
        end
    end // ToDo: Add the rest of the logic
    
    
endmodule