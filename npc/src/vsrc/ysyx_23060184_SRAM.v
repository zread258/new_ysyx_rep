module ysyx_23060184_SRAM (
    input                               clk,
    input                               rstn,

    /*
        Arbiter signals Begin
    */
    input [`NUM_ARB_MASTERS - 1:0]      grant,
    /*
        Arbiter signals End
    */

    /*
        DataMem AXI4 Handshake signals Begin
    */
    // Read Addr Channel
    input [`DATA_WIDTH - 1:0]           d_araddr,
    input                               d_arvalid,
    // Read Channel
    input                               d_rready,
    // Write Addr Channel
    input [`DATA_WIDTH - 1:0]           d_awaddr,
    input                               d_awvalid,
    // Write Channel
    input [`DATA_WIDTH - 1:0]           d_wdata,
    input [`WMASK_LENGTH - 1:0]         d_wstrb,
    input                               d_wvalid,
    // Write Response Channel
    input                               d_bready,
    /*
        DataMem AXI4 Handshake signals End
    */

    /*
        InstMem AXI4 Handshake signals Begin
    */
    // Read Addr Channel
    input [`DATA_WIDTH - 1:0]           i_araddr,
    input                               i_arvalid,
    // Read Channel
    input                               i_rready,
    /*
        InstMem AXI4 Handshake signals End
    */

    /*
        SRAM AXI4 Handshake signals Begin
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
        SRAM AXI4 Handshake signals End
    */

);

    wire                                        valid;
    assign valid = (grant == `EMPTY_GRANT) ? 0 : 
                        (grant == `UART_GRANT) ? 0 : 1;
    wire                                        InstMem;
    assign InstMem = (grant == `INSTMEM_GRANT) ? 1 : 0;
    wire                                        DataMem;
    assign DataMem = (grant == `DATAMEM_GRANT) ? 1 : 0;

    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(
    input int waddr, input int wdata, input byte wmask);


    always @ (posedge clk) begin
        if (~rstn) begin
            aready <= 1;
            rvalid <= 0;
            awready <= 1;
            wready <= 0;
            bvalid <= 0;
        end
    end

    /* 
        InstMem AXI4 Transaction Begin
    */
    always @(posedge clk) begin
        if (valid && InstMem) begin
            if (i_arvalid && aready) begin
                aready <= 0;
                rvalid <= 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (InstMem && rvalid && i_rready) begin
            rdata <= pmem_read(i_araddr);
            rresp <= 0;
            aready <= 1;
            rvalid <= 0;
        end
    end
    /* 
        InstMem AXI4 Transaction End
    */

    /* 
        DataMem AXI4 Transaction Begin
    */
    always @(posedge clk) begin
        if (valid && DataMem) begin
            if (d_arvalid && aready) begin
                aready <= 0;
                rvalid <= 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (DataMem && rvalid && d_rready) begin
            rdata <= pmem_read(d_araddr);
            rresp <= 0;
            aready <= 1;
            rvalid <= 0;
        end
    end

    always @ (posedge clk) begin
        if (valid && DataMem) begin
            if (d_awvalid && awready) begin
                awready <= 0;
                wready <= 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (DataMem && d_wvalid && wready) begin
            pmem_write(d_awaddr, d_wdata, d_wstrb);
            awready <= 1;
            wready <= 0;
            bvalid <= 1;
            if (bvalid && d_bready) begin
                bresp <= 0;
                bvalid <= 0;
            end
        end
    end
    /* 
        DataMem AXI4 Transaction End
    */

endmodule