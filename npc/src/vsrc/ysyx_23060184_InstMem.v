module ysyx_23060184_InstMem(
    input                           clk,
    input       [`DATA_WIDTH - 1:0] A,
    input                           Pvalid,
    // input                           Eready,
    output reg                      Ivalid,
    // output reg                      Iready,
    output reg  [`DATA_WIDTH - 1:0] RD
);

    reg                         arvalid;
    reg                         aready;
    reg [`DATA_WIDTH - 1:0]     rdata;
    reg [`ACERR_WIDTH - 1:0]    rresp;
    reg                         rvalid;
    reg                         rready;
    reg                         awready;
    reg                         wready;
    reg [`ACERR_WIDTH - 1:0]    bresp;
    reg                         bvalid;

    ysyx_23060184_SRAM SRAM (
        .clk(clk),
        .araddr(A),
        .arvalid(arvalid),
        .aready(aready),
        .rdata(RD),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),
        .awaddr(0),
        .awvalid(0),
        .awready(awready),
        .wdata(0),
        .wstrb(0),
        .wvalid(0),
        .wready(wready),
        .bready(0),
        .bresp(bresp),
        .bvalid(bvalid)
    );

    always @(posedge clk) begin
        if (Pvalid) begin
            arvalid <= 1;
            Ivalid <= 0;
            if (arvalid && aready) begin
                rready <= 1;
                if (rvalid && rready) begin
                    // RD <= rdata;
                    arvalid <= 0;
                    rready <= 0;
                    Ivalid <= 1;
                end
            end
        end
    end

endmodule //InstMem
