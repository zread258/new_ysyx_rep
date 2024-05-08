module ysyx_23060184_InstMem(
    input                               clk,
    input                               resetn,

    // Input signals
    input       [`DATA_WIDTH - 1:0]     A,
    input                               Igrant,


    /* 
        AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output [`DATA_WIDTH - 1:0]          araddr,
    output reg                          arvalid,
    input                               aready,
    // Read Channel
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    output reg                          rready,

    // Redundant signals
    output reg                          wready,
    output reg [`ACERR_WIDTH - 1:0]     bresp,
    output reg                          bvalid,
    output reg                          awready,

    /* 
        AXI4 Handshake signals End
    */ 


    // Unit Handshake signals
    input                               Pvalid,
    input                               Eready,
    output reg                          Ivalid,
    output reg                          Iready,

    // Output signals
    output reg                          Irequst,
    output reg  [`DATA_WIDTH - 1:0]     RD
);

    assign araddr = A;
    // assign RD =   rdata;


    always @(posedge clk) begin
        if (~resetn) begin
            Iready <= 1;
            Ivalid <= 0;
            rready <= 1;
        end else if (Pvalid && Iready) begin
            Iready <= 0; // Inst Fetch start
            Irequst <= 1; // Inst Fetch request
            arvalid <= 1; // Addr Read request
        end 
    end

    always @(posedge clk) begin
        if (Ivalid && Eready) begin
            Ivalid <= 0;
        end
    end

    always @(posedge clk) begin
        if (arvalid && aready) begin // Addr Handshake
            rready <= 1; // Read Ready
            if (rvalid && rready) begin // Read Handshake
                arvalid <= 0;
                rready <= 0;
                Ivalid <= 1;
                Iready <= 1;
                Irequst <= 0;
            end
        end
    end

    always @(rdata) begin
        if (Igrant) begin
            RD <= rdata;
        end
    end

endmodule //InstMem
