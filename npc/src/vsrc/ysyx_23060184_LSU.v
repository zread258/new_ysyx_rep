module ysyx_23060184_LSU (

    input                               clk,
    input                               rstn,


    input [`DATA_WIDTH - 1:0]           ALUResult,

    // Unit Handshake signals
    input                               Wready,
    input                               Evalid,

    /* 
        SoC AXI4 Handshake signals Begin
    */ 

    input                               grant,
    input                               arready,
    input [`DATA_WIDTH - 1:0]           rdata,
    input                               rlast,
    input [`ID_WIDTH - 1:0]             rid,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    input                               awready,
    input                               wready,
    input [`ACERR_WIDTH - 1:0]          bresp,
    input [`ID_WIDTH - 1:0]             bid,
    input                               bvalid,

    /* 
        SoC AXI4 Handshake signals End
    */ 


    // Operation signals
    input                               MemReadE,
    input                               MemWriteE,
    input                               MemRead,
    input                               MemWrite,
    input [`RESULT_SRC_LENGTH - 1:0]    Ropcode,
    input [`WMASK_LENGTH - 1:0]         Wmask,
    input [`DATA_WIDTH - 1:0]           WriteData,

/* --------------------------------------------- */

    output reg                          Mready,
    output reg                          Mvalid,

    /* 
        SoC AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output reg [`DATA_WIDTH - 1:0]      araddr,
    output reg [`ID_WIDTH - 1:0]        arid,
    output reg [`ALEN - 1:0]            arlen,
    output reg [`ASIZE - 1:0]           arsize,
    output reg [`ABURST - 1:0]          arburst,
    output reg                          arvalid,
    // Read Channel
    output reg                          rready,
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      wdata,
    output reg [`DATA_WIDTH - 1:0]      awaddr,
    output reg                          awvalid,
    output reg [`ID_WIDTH - 1:0]        awid,
    output reg [`ALEN - 1:0]            awlen,
    output reg [`ASIZE - 1:0]           awsize,
    output reg [`ABURST - 1:0]          awburst,
    // Write Channel
    output reg [`WSTRB_WIDTH - 1:0]     wstrb,
    output reg                          wvalid,
    output reg                          wlast,
    // Write Response Channel
    output reg                          bready,

    /* 
        SoC AXI4 Handshake signals End
    */ 

    // Output signals
    output reg [`DATA_WIDTH - 1:0]      ReadData,
    output reg                          Drequest
);

    wire soc;
    wire clint;

    always @(posedge clk) begin
        if (!rstn) begin
            Mready <= 1;
            arvalid <= 0;
            awvalid <= 0;
            arid <= 1; // LSU ID == 1
            arlen <= 0; // fix to 0 which means always single transfer
            arsize <= 3'b010;
            arburst <= 2'b01;
            awid <= 0;
            awlen <= 0; // fix to 0 which means always single transfer
            awsize <= 3'b010;
            awburst <= 2'b01;
        end else if (Evalid && Mready) begin
            Mready <= 0;
            if (~MemReadE && ~MemWriteE) begin
                Mvalid <= 1;
                Mready <= 1;
                Drequest <= 0;
            end else begin
                Drequest <= 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (grant && MemRead) begin
            arvalid <= 1;
        end
        else if (grant && MemWrite) begin
            awvalid <= 1;
        end
    end

    always @(posedge clk) begin
        if (Mvalid && Wready) begin
            Mvalid <= 0;
            Mready <= 1;
        end
    end

    reg [`DATA_WIDTH - 1:0]      soc_result;
    reg [`DATA_WIDTH - 1:0]      clint_result;

    ysyx_23060184_SoCMem SoCMem (
      .clk(clk),
      .raddr(ALUResult),
      .grant(soc),
      .Mvalid(Mvalid),
      .Mready(Mready),

      /*
         SoC AXI4 input signals Begin
      */
      .arready(arready),
      .rdata(rdata),
      .rresp(rresp),
      .rvalid(rvalid),
      .awready(awready),
      .wready(wready),
      .bvalid(bvalid),
      .bresp(bresp),
      .bid(bid),
      /*
         SoC AXI4 input signals End
      */

      .araddr(araddr),
      .arvalid(arvalid),
      .rready(rready),
      .wdata(wdata),
      .awaddr(awaddr),
      .awvalid(awvalid),
      .wstrb(wstrb),
      .wvalid(wvalid),
      .wlast(wlast),
      .bready(bready),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .ropcode(Ropcode),
      .wmask(Wmask),
      .data(WriteData),
      .Drequest(Drequest),
      .result(soc_result)
   );

   ysyx_23060184_CLINT CLINT (
      .clk(clk),
      .resetn(rstn),
      .grant(clint),
      .Mready(Mready),
      .Mvalid(Mvalid),
      .MemRead(MemRead),
      .Drequest(Drequest),
      .result(clint_result)
   ); // Why?

   ysyx_23060184_LSUXbar LSUXbar (
      .raddr(ALUResult),
      .lsu_grant(grant),
      .soc_result(soc_result),
      .clint_result(clint_result),
      .soc(soc),
      .clint(clint),
      .result(ReadData)
   );

endmodule
