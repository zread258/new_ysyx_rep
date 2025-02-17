module ysyx_23060184_IFU (

    input                               clk,
    input                               rstn,
    // input                               Stall,
    input                               Branch,


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


    /*
        PC Input Signals End
    */


    /*
        InstMem Input Signals Begin
    */

    input                               Dready,
    input                               grant,
    input                               arready,
    input [`DATA_WIDTH - 1:0]           rdata,
    input [`ACERR_WIDTH - 1:0]          rresp,
    input                               rvalid,
    input                               rlast,

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
    output [`DATA_WIDTH - 1:0]          inst,
    output                              Ivalid,
    output                              Irequest,
    output [`ID_WIDTH - 1:0]            arid,
    output [`ALEN - 1:0]                arlen,
    output [`ASIZE - 1:0]               arsize,
    output [`ABURST - 1:0]              arburst,

    /*
        InstMem Output Signals End
    */

    output [`DATA_WIDTH - 1:0]          PCPlus4
);

    wire [`DATA_WIDTH - 1:0]            NPC;
    wire                                Pvalid;
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
      .Branch(Branch),
    //   .Stall(Stall),
      .Pvalid(Pvalid),
      .Ivalid(Ivalid),
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
      .arready(arready),
      .arid(arid),
      .arlen(arlen),
      .arsize(arsize),
      .arburst(arburst),
      .rdata(rdata),
      .rresp(rresp),
      .rvalid(rvalid),
      .rready(rready),
      .Pvalid(Pvalid),
      .Dready(Dready),
      .Ivalid(Ivalid),
      .Iready(Iready),
      .Irequest(Irequest),
      .RD(inst)
   );

endmodule