module ysyx_23060184_SRAM (
    input                           clk,
    input                           resetn,
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
    integer cnta;
    integer cntr;

    // initial begin
    //     cnta = 0;
    //     cntr = 0;
    // end

    always @(posedge clk) begin
        // cnta = cnta + 1;
        // cntr = cntr + 1;
        // if (cnta == 5) begin
        //     cnta = 0;
        //     aready <= 1;
        // end
        // if (cntr == 10) begin
        //     cntr = 0;
        //     rvalid <= 1;
        // end
        aready <= 1;
        rvalid <= 1;
        if (~resetn) begin
            aready <= 1;
            rvalid <= 0;
            awready <= 1;
            wready <= 0;
            rvalid <= 1;
            bvalid <= 0;
        end else if (arvalid && aready) begin
            if (rvalid && rready) begin
                rdata <= pmem_read(araddr);
                rresp <= 0;
                aready <= 0;
                rvalid <= 0;
            end
        end
    end

endmodule
