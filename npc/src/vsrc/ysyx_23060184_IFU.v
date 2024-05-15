module ysyx_23060184_IFU (

    input                               clk,
    input                               rstn,


    /*
        Mux_PC_Src Input Signals Begin
    */

    input [`PC_SRC_LENGTH - 1:0]        PCSrc,
    input [`DATA_WIDTH - 1:0]           PCTarget,
    input [`DATA_WIDTH - 1:0]           ALUResult,
    input [`DATA_WIDTH - 1:0]           CsrRead,

    /*
        Mux_PC_Src Input Signals End
    */


    /*
        PC Input Signals Begin
    */

    input                               Wvalid,

    /*
        PC Input Signals End
    */


    /*
        InstMem Input Signals Begin
    */

    input                               Eready,
    input [`NUM_ARB_MASTERS - 1:0]      grant,
    input                               aready,
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,

    /*
        InstMem Input Signals End
    */

    /* --------------------------------------------- */

    /*
        PC Output Signals Begin
    */

    output                             Pready,
    output [`DATA_WIDTH - 1:0]         pc,

    /*
        PC Output Signals End
    */

    /*
        InstMem Output Signals Begin
    */

    output [`DATA_WIDTH - 1:0]          araddr,
    output                              arvalid,
    output                              rready,
    output                              wready,
    output [`ACERR_WIDTH - 1:0]         bresp,
    output                              bvalid,
    output                              awready,
    output [`DATA_WIDTH - 1:0]          inst,
    output                              Ivalid,
    output                              Irequst

    /*
        InstMem Output Signals End
    */
);

    wire [`DATA_WIDTH - 1:0]            NPC;
    wire                                Pvalid;
    wire [`DATA_WIDTH - 1:0]            PCPlus4;
    wire                                Iready;


    ysyx_23060184_Mux_PC_Src Mux_PC_Src (
      .PCSrc(PCSrc),
      .PCPlus4(PCPlus4),
      .PCTarget(PCTarget), 
      .ALUResult(ALUResult),
      .CsrRead(CsrRead),
      .NPC(NPC)
   );

    ysyx_23060184_PC PC (
      .clk(clk),
      .rstn(rstn),
      .Wvalid(Wvalid),
      .Pvalid(Pvalid),
      .Iready(Iready),
      .Pready(Pready),
      .NPC(NPC),
      .PC(pc)
   );

   ysyx_23060184_PCPlus4 PCPLus4 (
      .PC(pc),
      .PCPlus4(PCPlus4)
   );

    ysyx_23060184_InstMem InstMem (
      .clk(clk),
      .resetn(rstn),
      .A(pc),
      .grant(grant),
      .araddr(araddr),
      .arvalid(arvalid),
      .aready(aready),
      .rdata(rdata),
      .rresp(rresp),
      .rvalid(rvalid),
      .rready(rready),
      .wready(wready),
      .bresp(bresp),
      .bvalid(bvalid),
      .awready(awready),
      .Pvalid(Pvalid),
      .Eready(Eready),
      .Ivalid(Ivalid),
      .Iready(Iready),
      .Irequst(Irequst),
      .RD(inst)
   );

endmodule