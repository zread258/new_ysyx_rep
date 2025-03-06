module ysyx_23060184_SoCMem (
    input                               clk,
    input [`DATA_WIDTH - 1:0]           raddr,

    // Unit Handshake signals
    input                               grant,
    output reg                          Mready,
    output reg                          Mvalid,


    /* 
        SoC AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    input                               arready,
    // Read Channel
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    // Write Addr Channel
    input                               awready,
    // Write Channel
    input                               wready,
    // Write Response Channel
    input                               bvalid,
    input [`ACERR_WIDTH - 1:0]          bresp,
    input [`ID_WIDTH - 1:0]             bid,

    /* 
        SoC AXI4 Handshake signals End
    */ 


    /* 
        SoCMem AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output [`DATA_WIDTH - 1:0]          araddr,
    output reg                          arvalid,
    // Read Channel
    output reg                          rready,
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      wdata,
    output reg [`DATA_WIDTH - 1:0]      awaddr,
    output reg                          awvalid,
    // Write Channel
    output reg [`WSTRB_WIDTH - 1:0]     wstrb,
    output reg                          wvalid,
    output reg                          wlast,
    // Write Response Channel
    output reg                          bready,

    /* 
        SoCMem AXI4 Handshake signals End
    */ 


    // Operation signals
    input                               MemRead,
    input                               MemWrite,
    input [`RESULT_SRC_LENGTH - 1:0]    ropcode,
    input [`WMASK_LENGTH - 1:0]         wmask,
    input [`DATA_WIDTH - 1:0]           data,


    // Output signals
    output reg                          Drequest,
    output reg [`DATA_WIDTH - 1:0]      result
);

    assign araddr = raddr;
    assign awaddr = raddr;
    assign wstrb = 4'b1111;
    assign wdata = data;

    /*
        SoC AXI4 Transaction Begin
    */

    import "DPI-C" function void is_device(
    input int raddr, input byte grant, input byte MemRead, input byte MemWrite);

    always @(posedge clk) begin
        if (MemRead && grant && arvalid && arready) begin
            arvalid <= 0;
            rready <= 1;
        end
    end

    always @ (posedge clk) begin
        if (MemRead && grant && rvalid && rready) begin
            rready <= 0;
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
        end
    end

    always @ (posedge clk) begin
        if (MemWrite && grant && awvalid && awready) begin
            awvalid <= 0;
            wvalid <= 1;
            wlast <= 1;
        end
    end
    
    always @ (posedge clk) begin
        if (MemWrite && grant && wvalid && wready) begin
            wvalid <= 0;
            wlast <= 0;
            bready <= 1;
        end
    end

    always @ (posedge clk) begin
        if (MemWrite && grant && bvalid && bready) begin
            bready <= 0;
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
        end
    end
    
    /*
        SoC AXI4 Transaction End
    */

    assign result = (ropcode == `READ_WORD) ? rdata :
                    (ropcode == `READ_HALF) ? {{16{rdata[15]}}, rdata[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{rdata[7]}}, rdata[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, rdata[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, rdata[7:0]} :
                    0;

endmodule
