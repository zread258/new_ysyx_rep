module ysyx_23060184_WBU (

    input                               clk,
    input                               rstn,
    input [`DATA_WIDTH - 1:0]           pc,


    /*
        DataMem Input Signals Begin
    */

        input [`DATA_WIDTH - 1:0]           ALUResult,

        // Unit Handshake signals
        input                               Pready,
        input                               Evalid,
        input [`NUM_ARB_MASTERS - 1:0]      grant,

        /* 
            SRAM AXI4 Handshake signals Begin
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
            SRAM AXI4 Handshake signals End
        */ 


        /* 
            UART AXI4 Handshake signals Begin
        */ 

        // Read Addr Channel 
        input                               u_aready,
        // Read Channel
        input [`DATA_WIDTH - 1:0]           u_rdata,
        input [`ACERR_WIDTH - 1:0]          u_rresp,
        input                               u_rvalid,
        // Write Addr Channel
        input                               u_awready,
        // Write Channel
        input                               u_wready,
        // Write Response Channel
        input                               u_bvalid,
        input [`ACERR_WIDTH - 1:0]          u_bresp,

        /* 
            UART AXI4 Handshake signals End
        */ 


        // Operation signals
        input                               MemRead,
        input                               MemWrite,
        input [`RESULT_SRC_LENGTH - 1:0]    Ropcode,
        input [`WMASK_LENGTH - 1:0]         Wmask,
        input [`DATA_WIDTH - 1:0]           RD2, // Change it to WriteData when it is pipelined


    /*
        DataMem Input Signals End
    */

    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrc,
    input [`DATA_WIDTH - 1:0]           CsrRead,

    /* --------------------------------------------- */

    /*
        DataMem Output Signals Begin
    */

        output reg                          Wready,
        output reg                          Wvalid,

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
        output reg                          Drequst,
        output reg [`DATA_WIDTH - 1:0]      Result

    /*
        DataMem Output Signals End
    */
);

    wire [`DATA_WIDTH - 1:0]        ReadData;

    ysyx_23060184_DataMem DataMem (
      .clk(clk),
      .resetn(rstn),
      .raddr(ALUResult),
      .Evalid(Evalid),
      .grant(grant),
      .Wvalid(Wvalid),
      .Wready(Wready),
      .Pready(Pready),
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
      .data(RD2),
      .ropcode(Ropcode),
      .Drequst(Drequst),
      .result(ReadData)
   );

   ysyx_23060184_Mux_Result_Src Mux_Result_Src (
      .ResultSrc(ResultSrc),
      .PC(pc),
      .ALUResult(ALUResult),
      .ReadData(ReadData),
      .CsrRead(CsrRead),
      .Result(Result)
   );

endmodule