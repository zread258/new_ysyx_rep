module ysyx_23060184_DataMem (
    input                               clk,
    input                               resetn,
    input [`DATA_WIDTH - 1:0]           raddr,
    input                               Evalid,
    // output reg                          Wready,
    output reg                          Wvalid,
    input                               MemRead,
    input                               MemWrite,
    input [`RESULT_SRC_LENGTH - 1:0]    ropcode,
    input [`WMASK_LENGTH - 1:0]         wmask,
    input [`DATA_WIDTH - 1:0]           wdata,
    output reg [`DATA_WIDTH - 1:0]      result
);

    reg [`DATA_WIDTH - 1:0]             rdata;
    reg                                 arvalid;
    reg                                 aready;
    reg [`ACERR_WIDTH - 1:0]            rresp;
    reg                                 rvalid;
    reg                                 rready;
    reg                                 awvalid;
    reg                                 awready;
    reg                                 wvalid;
    reg                                 wready;
    reg                                 bready;
    reg                                 bvalid;
    reg [`ACERR_WIDTH - 1:0]            bresp;

    ysyx_23060184_DataSRAM DataSRAM (
        .clk(clk),
        .araddr(raddr),
        .arvalid(arvalid),
        .aready(aready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),
        .awaddr(raddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wmask),
        .wvalid(wvalid),
        .wready(wready),
        .bready(bready),
        .bresp(bresp),
        .bvalid(bvalid)
    );

    always @(posedge clk) begin
        if (!resetn) begin
            // Wready = 1;
            // Wvalid <= 1;
        end else begin
            Wvalid <= 0;
            if (Evalid) begin
                // Wready <= 1;
                if (MemRead) begin
                    arvalid <= 1;
                    if (arvalid && aready) begin
                        rready <= 1;
                        if (rvalid && rready) begin
                            arvalid <= 0;
                            rready <= 0;
                            Wvalid <= 1;
                        end
                    end
                end else if (MemWrite) begin
                    awvalid <= 1;
                    if (awvalid && awready) begin
                        wvalid <= 1;
                        if (wvalid && wready) begin
                            awvalid <= 0;
                            wvalid <= 0;
                            bready <= 1;
                            if (bvalid && bready) begin
                                bready <= 0;
                            end
                            Wvalid <= 1;
                        end
                    end
                end
                Wvalid <= 1;
            end
        end
    end

    assign result = (ropcode == `READ_WORD) ? rdata :
                    (ropcode == `READ_HALF) ? {{16{rdata[15]}}, rdata[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{rdata[7]}}, rdata[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, rdata[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, rdata[7:0]} :
                    0;

endmodule
