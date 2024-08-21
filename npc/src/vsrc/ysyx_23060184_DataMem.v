module ysyx_23060184_DataMem (
    input                               clk,
    input                               resetn,
    input [`DATA_WIDTH - 1:0]           raddr,

    // Unit Handshake signals
    input                               Wready,
    input                               Evalid,
    input [`NUM_ARB_MASTERS - 1:0]      grant,
    input                               clint,
    output reg                          Mready,
    output reg                          Mvalid,


    /* 
        SoC AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    input                               s_aready,
    // Read Channel
    input [`DATA_WIDTH - 1:0]           s_rdata,
    input [`ACERR_WIDTH - 1:0]          s_rresp,
    input                               s_rvalid,
    // Write Addr Channel
    input                               s_awready,
    // Write Channel
    input                               s_wready,
    // Write Response Channel
    input                               s_bvalid,
    input [`ACERR_WIDTH - 1:0]          s_bresp,

    /* 
        SoC AXI4 Handshake signals End
    */ 


    /* 
        CLINT AXI4 Handshake signals Begin
    */ 
 
    // Read Addr Channel 
    input                               c_aready,
    // Read Channel
    input [`DATA_WIDTH - 1:0]           c_rdata,
    input [`ACERR_WIDTH - 1:0]          c_rresp,
    input                               c_rvalid,
    // Write Addr Channel
    input                               c_awready,
    // Write Channel
    input                               c_wready,
    // Write Response Channel
    input                               c_bvalid,
    input [`ACERR_WIDTH - 1:0]          c_bresp,

    /* 
        CLINT AXI4 Handshake signals End
    */ 


    /* 
        DataMem AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output [`DATA_WIDTH - 1:0]          araddr,
    output reg                          arvalid,
    // Read Channel
    output reg                          rready,
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      wdata,
    output [`DATA_WIDTH - 1:0]          awaddr,
    output                              awvalid,
    // Write Channel
    output [`WMASK_LENGTH - 1:0]        wstrb,
    output reg                          wvalid,
    // Write Response Channel
    output reg                          bready,

    /* 
        DataMem AXI4 Handshake signals End
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
    assign wstrb = wmask;
    assign wdata = data;

    wire SRAM, UART;
    assign SRAM = (raddr >= `SRAM_ADDR_BEGIN && raddr <= `SRAM_ADDR_END) ? 1 : 0;
    assign UART = (raddr >= `UART_ADDR_BEGIN && raddr <= `UART_ADDR_END) ? 1 : 0;
    wire Dgrant = (grant == `DATAMEM_GRANT) ? 1 : 0;

    wire [`DATA_WIDTH - 1:0] rdata;
    assign rdata = (SRAM) ? s_rdata : u_rdata;


    always @(posedge clk) begin
        if (!resetn) begin
            Mready <= 1;
            arvalid <= 0;
            awvalid <= 0;
        end
    end

    always @(posedge clk) begin
        if (Evalid && Mready) begin
            Mready <= 0;
            if (~MemRead && ~MemWrite) begin
                Mvalid <= 1;
                Mready <= 1;
                Drequest <= 0;
            end else begin
                if (MemRead)
                    arvalid <= 1;
                else if (MemWrite)
                    awvalid <= 1;
                Drequest <= 1;
            end
        end
    end

    /*
        SRAM AXI4 Transaction Begin
    */
    always @(posedge clk) begin
        if (MemRead && SRAM && Dgrant) begin
            if (arvalid && s_aready) begin
                rready <= 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (s_rvalid && rready) begin
            arvalid <= 0;
            rready <= 0;
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
        end
    end

    always @ (posedge clk) begin
        if (MemWrite && SRAM && Dgrant) begin
            if (awvalid && s_awready) begin
                wvalid <= 1;
            end
        end
    end
    
    always @ (posedge clk) begin
        if (wvalid && s_wready) begin
            awvalid <= 0;
            wvalid <= 0;
            bready <= 1;
            if (s_bvalid && bready) begin
                bready <= 0;
            end
            Mvalid <= 1;
            Mready <= 0;
            Drequest <= 0;
        end
    end
    /*
        SRAM AXI4 Transaction End
    */

    /*
        UART AXI4 Transaction Begin
    */
    always @(posedge clk) begin
        if (MemRead && UART && Dgrant) begin
            if (arvalid && u_aready) begin
                rready <= 1;
                if (u_rvalid && rready) begin
                    arvalid <= 0;
                    rready <= 0;
                    Mvalid <= 1;
                    Mready <= 0;
                    Drequest <= 0;
                end
            end
        end else if (MemWrite && UART && Dgrant) begin
            if (awvalid && u_awready) begin
                wvalid <= 1;
                if (wvalid && u_wready) begin
                    awvalid <= 0;
                    wvalid <= 0;
                    bready <= 1;
                    if (u_bvalid && bready) begin
                        bready <= 0;
                    end
                    Mvalid <= 1;
                    Mready <= 0;
                    Drequest <= 0;
                end
            end
        end
    end
    /*
        UART AXI4 Transaction End
    */

    always @(posedge clk) begin
        if (Mvalid && Wready) begin
            Mvalid <= 0;
            Mready <= 1;
        end
    end

    assign result = (ropcode == `READ_WORD) ? rdata :
                    (ropcode == `READ_HALF) ? {{16{rdata[15]}}, rdata[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{rdata[7]}}, rdata[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, rdata[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, rdata[7:0]} :
                    0;

endmodule
