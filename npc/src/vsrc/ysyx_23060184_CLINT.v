module ysyx_23060184_CLINT (
    input                               clk,
    input                               resetn,

    /*
        AXI4 Handshake signals Begin
    */

    // Unit Handshake signals
    input                               grant,
    output reg                          Mready,
    output reg                          Mvalid,

    // /* 
    //     CLINT AXI4 Handshake signals Begin
    // */ 

    // // Read Addr Channel 
    // input                               arready,
    // // Read Channel
    // input [`ACERR_WIDTH - 1:0]          rresp,
    // input                               rvalid,

    // /*
    //     AXI4 Handshake signals End
    // */

    // /*
    //     AXI4 Handshake signals Begin
    // */
    // output [`DATA_WIDTH - 1:0]          araddr,
    // output                              arvalid,
    // output                              rready,
    // output [`ID_WIDTH - 1:0]            arid,
    // output [`ALEN - 1:0]                arlen,
    // output [`ASIZE - 1:0]               arsize,
    // output [`ABURST - 1:0]              arburst,

    input                               MemRead,

    output reg                          Drequest,
    output reg [`DATA_WIDTH - 1:0]      result
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
        if (MemRead && grant) begin
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
            result <= mtime[`DATA_WIDTH - 1:0];
        end
    end

    /* Keep it until it doesn't work well 
    it is said that the CLINT should use AXI-Lite interface

    always @ (posedge clk) begin
        if (MemRead && grant) begin
            if (arready && arvalid) begin
                rready <= 1;
            end
        end
    end
    
    always @ (posedge clk) begin
        if (grant && rvalid && rready) begin
            arvalid <= 0;
            rready <= 0;
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
            result <= mtime;
        end
    end // ToDo: Add the rest of the logic(upper 32 bits of mtime, etc.)
    
    */
    
endmodule