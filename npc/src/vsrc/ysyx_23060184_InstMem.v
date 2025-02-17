module ysyx_23060184_InstMem(
    input                               clk,
    input                               resetn,

    // Input signals
    input [`DATA_WIDTH - 1:0]           A,
    input                               grant,
    // input                               Stall,


    /* 
        AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output reg [`DATA_WIDTH - 1:0]      araddr,
    output reg                          arvalid,
    input                               arready,
    output reg [`ID_WIDTH - 1:0]        arid,
    output reg [`ALEN - 1:0]            arlen,
    output reg [`ASIZE - 1:0]           arsize,
    output reg [`ABURST - 1:0]          arburst,
    // Read Channel
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    output reg                          rready,

    /* 
        AXI4 Handshake signals End
    */ 


    // Unit Handshake signals
    input                               Pvalid,
    input                               Dready,
    output reg                          Ivalid,
    output reg                          Iready,
    

    // Output signals
    output reg                          Irequest,
    output reg [`DATA_WIDTH - 1:0]      RD
);

    assign araddr = A;
    // assign RD = rdata[`DATA_WIDTH - 1:0];

    always @(posedge clk) begin
        if (~resetn) begin
            Iready <= 1;
            Ivalid <= 0;
            rready <= 1;
            arlen <= 0; // Fix to 0
            arburst <= 2'b01; // Fix to 1
        end else if (Pvalid && Iready) begin
            Iready <= 0; // Inst Fetch start
            Irequest <= 1; // Inst Fetch request
            arvalid <= 1; // Addr Read request
            arid <= 0; // InstFetch ID == 0
            arsize <= 3'b010; // 32-bit 00--1 byte 01--2 bytes 10--4 bytes 11--8 bytes
        end 
    end

    always @(posedge clk) begin
        if (Ivalid && Dready) begin
            Ivalid <= 0;
        end
    end

    always @(posedge clk) begin
        if (grant && arvalid && arready) begin // Addr Handshake
            rready <= 0; // Read Ready
        end
    end

    always @ (posedge clk) begin
        if (grant && rvalid && rready) begin // Read Handshake
            arvalid <= 0;
            rready <= 1;
            Ivalid <= 1;
            Iready <= 1;
            RD <= rdata;
            Irequest <= 0;
        end
    end

endmodule //InstMem
