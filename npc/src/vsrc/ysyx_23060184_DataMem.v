module ysyx_23060184_DataMem (
    input                               clk,
    input                               resetn,
    input [`DATA_WIDTH - 1:0]           raddr,

    // Unit Handshake signals
    input                               Pready,
    input                               Evalid,
    input                               Dgrant,
    output reg                          Wready,
    output reg                          Wvalid,


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
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      wdata,
    output [`DATA_WIDTH - 1:0]          awaddr,
    output                              awvalid,
    input                               awready,
    // Write Channel
    output [`WMASK_LENGTH - 1:0]        wstrb,
    output reg                          wvalid,
    input                               wready,
    // Write Response Channel
    output reg                          bready,
    output reg [`ACERR_WIDTH - 1:0]     bresp,
    output reg                          bvalid,

    /* 
        AXI4 Handshake signals End
    */ 


    // Operation signals
    input                               MemRead,
    input                               MemWrite,
    input [`RESULT_SRC_LENGTH - 1:0]    ropcode,
    input [`WMASK_LENGTH - 1:0]         wmask,
    input [`DATA_WIDTH - 1:0]           data,


    // Output signals
    output reg                          Drequst,
    output reg [`DATA_WIDTH - 1:0]      result
);

    assign araddr = raddr;
    assign awaddr = raddr;
    assign wstrb = wmask;
    assign wdata = data;


    always @(posedge clk) begin
        if (!resetn) begin
            Wready <= 1;
        end
    end

    always @(posedge clk) begin
        if (Evalid && Wready) begin
            Wready <= 0;
            arvalid <= 1;
            awvalid <= 1;
            if (~MemRead && ~MemWrite) begin
                Wvalid <= 1;
                Wready <= 1;
            end else begin
                Drequst <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if (MemRead && Dgrant) begin
            if (arvalid && aready) begin
                rready <= 1;
                if (rvalid && rready) begin
                    arvalid <= 0;
                    rready <= 0;
                    Wvalid <= 1;
                    Wready <= 1;
                    Drequst <= 0;
                end
            end
        end else if (MemWrite && Dgrant) begin
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
                    Wready <= 1;
                    Drequst <= 0;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (Wvalid && Pready) begin
            Wvalid <= 0;
        end
    end

    assign result = (ropcode == `READ_WORD) ? rdata :
                    (ropcode == `READ_HALF) ? {{16{rdata[15]}}, rdata[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{rdata[7]}}, rdata[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, rdata[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, rdata[7:0]} :
                    0;

endmodule
