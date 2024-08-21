module ysyx_23060184_LSU (

    input                               clk,
    input                               rstn,


    input [`DATA_WIDTH - 1:0]           ALUResult,

    // Unit Handshake signals
    input                               Wready,
    input                               Evalid,
    input [`NUM_ARB_MASTERS - 1:0]      grant,

    /* 
        DataMem AXI4 Handshake signals Begin
    */ 

    input [`NUM_ARB_MASTERS - 1:0]      grant,
    input                               arready,
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    input                               awready,
    input                               wready,
    input [`ACERR_WIDTH - 1:0]          bresp,
    input                               bvalid,

    /* 
        DataMem AXI4 Handshake signals End
    */ 


    // Operation signals
    input                               MemRead,
    input                               MemWrite,
    input [`RESULT_SRC_LENGTH - 1:0]    Ropcode,
    input [`WMASK_LENGTH - 1:0]         Wmask,
    input [`DATA_WIDTH - 1:0]           WriteData,

/* --------------------------------------------- */

    output reg                          Mready,
    output reg                          Mvalid,

    /* 
        DataMem AXI4 Handshake signals Begin
    */ 

    // Read Addr Channel 
    output [`DATA_WIDTH - 1:0]          d_araddr,
    output reg                          d_arvalid,
    // Read Channel
    output reg                          d_rready,
    // Write Addr Channel
    output reg [`DATA_WIDTH - 1:0]      d_wdata,
    output [`DATA_WIDTH - 1:0]          d_awaddr,
    output                              d_awvalid,
    // Write Channel
    output [`WMASK_LENGTH - 1:0]        d_wstrb,
    output reg                          d_wvalid,
    // Write Response Channel
    output reg                          d_bready,

    /* 
        DataMem AXI4 Handshake signals End
    */ 

    // Output signals
    output reg [`DATA_WIDTH - 1:0]      ReadData,
    output reg                          Drequest
);

    wire clint;

    ysyx_23060184_DataMem DataMem (
      .clk(clk),
      .resetn(rstn),
      .raddr(ALUResult),
      .Wready(Wready),
      .Evalid(Evalid),
      .grant(grant),
      .clint(clint),
      .Mvalid(Mvalid),
      .Mready(Mready),
      .araddr(d_araddr),
      .arvalid(d_arvalid),

      /*
         SRAM AXI4 input signals Begin
      */
      .s_aready(s_aready),
      .s_rdata(s_rdata),
      .s_rresp(s_rresp),
      .s_rvalid(s_rvalid),
      .s_awready(s_awready),
      .s_wready(s_wready),
      .s_bvalid(s_bvalid),
      .s_bresp(s_bresp),
      /*
         SRAM AXI4 input signals End
      */

      /*
         UART AXI4 input signals Begin
      */
      .u_aready(u_aready),
      .u_rdata(u_rdata),
      .u_rresp(u_rresp),
      .u_rvalid(u_rvalid),
      .u_awready(u_awready),
      .u_wready(u_wready),
      .u_bvalid(u_bvalid),
      .u_bresp(u_bresp),
      /*
         UART AXI4 input signals End
      */


      .rready(d_rready),
      .awaddr(d_awaddr),
      .awvalid(d_awvalid),
      .wdata(d_wdata),
      .wstrb(d_wstrb),
      .wvalid(d_wvalid),
      .bready(d_bready),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .wmask(Wmask),
      .data(WriteData),
      .ropcode(Ropcode),
      .Drequest(Drequest),
      .result(ReadData)
   );

   ysyx_23060184_CLINT CLINT (
      .clk(clk),
      .resetn(rstn),
      
   );

   ysyx_23060184_Xbar Xbar (
      .raddr(ALUResult),
      .clint(clint)
   );

endmodule
