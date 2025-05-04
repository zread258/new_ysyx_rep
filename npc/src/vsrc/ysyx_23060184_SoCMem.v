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
    output reg [`ASIZE - 1:0]           arsize,
    // Read Channel
    output reg                          rready,
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      wdata,
    output reg [`DATA_WIDTH - 1:0]      awaddr,
    output reg                          awvalid,
    output reg [`ASIZE - 1:0]           awsize,
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
    output reg                          idle,
    output reg                          Drequest,
    output reg [`DATA_WIDTH - 1:0]      result
);

    assign araddr = raddr;
    assign awaddr = raddr;
    assign wstrb = (awsize == 3'b000) ? (4'b0001 << awaddr[1:0]) : // byte
               (awsize == 3'b001) ? (4'b0011 << awaddr[1:0]) : // half-word
               (awsize == 3'b010) ? 4'b1111 :                  // word
                                   4'b0000;                   // default: no write
    assign wdata =
                    (awsize == 3'b000) ? (
                        (awaddr[1:0] == 2'b00) ? {24'b0, data[7:0]}  :
                        (awaddr[1:0] == 2'b01) ? {16'b0, data[7:0], 8'b0} :
                        (awaddr[1:0] == 2'b10) ? {8'b0,  data[7:0], 16'b0} :
                                                {data[7:0], 24'b0}
                    ) :
                    (awsize == 3'b001) ? (
                        (awaddr[1:0] == 2'b00) ? {16'b0, data[15:0]} :
                        (awaddr[1:0] == 2'b01) ? {8'b0,  data[15:0], 8'b0} :
                                                {data[15:0], 16'b0}
                    ) :
                    data;

    /*
        SoC AXI4 Transaction Begin
    */

    always @ (posedge clk) begin
        if (idle && grant && MemRead) begin
            arvalid <= 1;
            idle <= 0;
            if (ropcode == `READ_WORD) begin
                arsize <= `ASIZE_WORD;
            end else if (ropcode == `READ_HALF 
                        || ropcode == `READ_HALFU) begin
                arsize <= `ASIZE_HALF;
            end else if (ropcode == `READ_BYTE 
                        || ropcode == `READ_BYTEU) begin
                arsize <= `ASIZE_BYTE;
            end
        end
        else if (idle && grant && MemWrite) begin
            awvalid <= 1;
            idle <= 0;
            if (wmask == `WRITE_WORD) begin
                awsize <= `ASIZE_WORD;
            end else if (wmask == `WRITE_HALF) begin
                awsize <= `ASIZE_HALF;
            end else if (wmask == `WRITE_BYTE) begin
                awsize <= `ASIZE_BYTE;
            end
        end
    end
    
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

    /*
        Narrow Transaction
    */

    // Calculate number of bytes per word
    localparam integer BYTES = `DATA_WIDTH / 8;

    // Calculate number of lanes
    localparam integer LANE_WIDTH = (BYTES == 8) ? 4 :
                                 (BYTES == 4) ? 2 :
                                 (BYTES == 2) ? 1 : 0;

    /* 
    Choose the correct byte offset based on the transfer type for SRAM
    Access SRAM would be 4 bytes aligned(SoC would change [1:0] to 00)
    So we need to choose the correct byte offset based on the transfer type
    */
    wire sram = (raddr >= `SRAM_ADDR_BEGIN && raddr <= `SRAM_ADDR_END) ? 1 : 0;
    reg [`DATA_WIDTH - 1:0] s_valid_data;

    assign s_valid_data =
    (arsize == 3'b010) ? 
        // 32‑bit access
        rdata :
    (arsize == 3'b001) ? 
        // 16‑bit access, choose half‑word
        (raddr[1:0] == 2'b00 ? {{16{1'b0}}, rdata[15:0]} :
         raddr[1:0] == 2'b01 ? {{16{1'b0}}, rdata[23:8]} :
         raddr[1:0] == 2'b10 ? {{16{1'b0}}, rdata[31:16]} :
                          {{16{1'b0}}, rdata[31:16]}) :
    (arsize == 3'b000) ?
        // 8‑bit access, choose byte
        (raddr[1:0] == 2'b00 ? {{24{1'b0}}, rdata[7:0]} :
         raddr[1:0] == 2'b01 ? {{24{1'b0}}, rdata[15:8]} :
         raddr[1:0] == 2'b10 ? {{24{1'b0}}, rdata[23:16]} :
                          {{24{1'b0}}, rdata[31:24]}) :
    // default / unsupported size
    {`DATA_WIDTH{1'b0}};

    wire [`DATA_WIDTH - 1:0] valid_data = (sram) ? s_valid_data: rdata;

    assign result = (ropcode == `READ_WORD) ? valid_data :
                    (ropcode == `READ_HALF) ? {{16{valid_data[15]}}, valid_data[15:0]} :
                    (ropcode == `READ_BYTE) ? {{24{valid_data[7]}}, valid_data[7:0]} :
                    (ropcode == `READ_HALFU) ? {16'b0, valid_data[15:0]} :
                    (ropcode == `READ_BYTEU) ? {24'b0, valid_data[7:0]} :
                    0;

endmodule
