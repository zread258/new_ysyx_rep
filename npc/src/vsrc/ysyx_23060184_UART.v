module ysyx_23060184_UART (
    input                               clk,

    /*
        UART signals Begin
    */
    input [`NUM_ARB_MASTERS - 1:0]      grant,
    /*
        UART signals End
    */

    /*
        DataMem AXI4 Handshake signals Begin
    */
    // Read Addr Channel
    input [`DATA_WIDTH - 1:0]           araddr,
    input                               arvalid,
    // Read Channel
    input                               rready,
    // Write Addr Channel
    input [`DATA_WIDTH - 1:0]           awaddr,
    input                               awvalid,
    // Write Channel
    input [`DATA_WIDTH - 1:0]           wdata,
    input [`WMASK_LENGTH - 1:0]         wstrb,
    input                               wvalid,
    // Write Response Channel
    input                               bready,
    /*
        DataMem AXI4 Handshake signals End
    */

    /*
        UART AXI4 Handshake signals Begin
    */
    // Read Addr Channel
    output reg                          aready,
    // Read Channel
    output reg [`DATA_WIDTH - 1:0]      rdata,
    output reg [`ACERR_WIDTH - 1:0]     rresp,
    output reg                          rvalid,
    // Write Addr Channel
    output reg                          awready,
    // Write Channel
    output reg                          wready,
    // Write Response Channel
    output reg [`ACERR_WIDTH - 1:0]     bresp,
    output reg                          bvalid
    /*
        UART AXI4 Handshake signals End
    */

);

    wire                                    valid;
    assign valid = (grant == `UART_GRANT) ? 1 : 0;
    
    /* 
        DataMem AXI4 Transaction Begin
    */
    always @(posedge clk) begin
        if (valid) begin
            aready <= 1;
            if (arvalid && aready) begin
                rvalid <= 1;
                if (rvalid && rready) begin
                    // rdata <= pmem_read(araddr);
                    rresp <= 0;
                    aready <= 0;
                    rvalid <= 0;
                end
            end
            awready <= 1;
            if (awvalid && awready) begin
                wready <= 1;
                if (wvalid && wready) begin
                    // pmem_write(awaddr, wdata, wstrb);
                    $write("UART: %h %h %h\n", awaddr, wdata, wstrb);
                    awready <= 0;
                    wready <= 0;
                    bvalid <= 1;
                    if (bvalid && bready) begin
                        bresp <= 0;
                        bvalid <= 0;
                    end
                end
            end
        end
    end
    /* 
        DataMem AXI4 Transaction End
    */

endmodule