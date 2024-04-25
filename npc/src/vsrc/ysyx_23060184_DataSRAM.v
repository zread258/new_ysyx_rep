module ysyx_23060184_DataSRAM (
    input                           clk,
    // Read Addr Channel
    input [`DATA_WIDTH - 1:0]       araddr,
    input                           arvalid,
    output reg                      aready,
    // Read Channel
    output reg [`DATA_WIDTH - 1:0]  rdata,
    output reg [`ACERR_WIDTH - 1:0] rresp,
    output reg                      rvalid,
    input                           rready,
    // Write Addr Channel
    input [`DATA_WIDTH - 1:0]       awaddr,
    input                           awvalid,
    output reg                      awready,
    // Write Channel
    input [`DATA_WIDTH - 1:0]       wdata,
    input [`WMASK_LENGTH - 1:0]     wstrb,
    input                           wvalid,
    output reg                      wready,
    // Write Response Channel
    input                           bready,
    output reg [`ACERR_WIDTH - 1:0] bresp,
    output reg                      bvalid
);

    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(
    input int waddr, input int wdata, input byte wmask);

    always @(posedge clk) begin
        aready <= 1;
        if (arvalid && aready) begin
            rvalid <= 1;
            if (rvalid && rready) begin
                rdata <= pmem_read(araddr);
                rresp <= 0;
                aready <= 0;
                rvalid <= 0;
            end
        end
        awready <= 1;
        if (awvalid && awready) begin
            wready <= 1;
            if (wvalid && wready) begin
                pmem_write(awaddr, wdata, wstrb);
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

endmodule