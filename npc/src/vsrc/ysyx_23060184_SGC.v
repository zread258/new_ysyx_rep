`include "ysyx_23060184_Config.v"

/* The Steins Gate Computer Project started on January 22nd, 2024,
   which is relied on YSYX Project. This CPU design is based on 
   RISC-V Instruction Set Architecture.
*/

module ysyx_23060184_SGC(
      input                          clk, 
      input                          resetn,
      output reg [`DATA_WIDTH - 1:0] pc,
      output reg [`DATA_WIDTH - 1:0] inst
   );

   /* 
      CPU-related signals Begin
   */

   wire [`DATA_WIDTH - 1:0]          ImmExt;
   wire [`DATA_WIDTH - 1:0]          ALUResult;
   wire [`DATA_WIDTH - 1:0]          PCTarget;
   wire [`DATA_WIDTH - 1:0]          RD1;
   wire [`DATA_WIDTH - 1:0]          RD2;
   wire [`PC_SRC_LENGTH - 1:0]       PCSrc;
   wire [`ALU_OP_LENGTH - 1:0]       ALUOp;
   wire [`EXT_OP_LENGTH - 1:0]       ExtOp;
   wire [`RESULT_SRC_LENGTH - 1:0]   ResultSrc;
   wire [`WMASK_LENGTH - 1:0]        Wmask;
   wire [`DATA_WIDTH - 1:0]          Result;
   wire [`DATA_WIDTH - 1:0]          SrcA;
   wire [`DATA_WIDTH - 1:0]          SrcB;
   wire [`ALU_SRCA_LENGTH - 1:0]     ALUSrcA;
   wire [`ALU_SRCB_LENGTH - 1:0]     ALUSrcB;
   wire [`DATA_WIDTH - 1:0]          ReadData;
   wire [`ROPCODE_LENGTH - 1:0]      Ropcode;
   wire [`CSR_SRC_LENGTH - 1:0]      CsrSrc;
   wire [`DATA_WIDTH - 1:0]          CsrRead;
   wire [`DATA_WIDTH - 1:0]          CsrWdata;

   wire RegWrite;
   wire CsrWrite;
   wire MemRead;
   wire MemWrite;
   wire Zero;
   wire ecall;
   wire mret;
   wire Pvalid;
   wire Pready;
   wire Ivalid;
   wire Iready;
   wire Dvalid;
   wire Dready;
   wire Evalid;
   wire Eready;
   wire Mvalid;
   wire Mready;
   wire Wvalid;
   wire Wready;
   wire Drequst;
   wire Irequst;

   /* 
      CPU-related signals End
   */

   /*
      Inst Memory related AXI4 signals Begin
   */

   wire [`DATA_WIDTH - 1:0]         i_araddr;
   wire                             i_arvalid;
   wire                             i_rready;

   ysyx_23060184_IFU IFU (
      .clk(clk),
      .rstn(resetn),
      .PCSrc(PCSrc),
      .PCTarget(PCTarget),
      .ALUResult(ALUResult),
      .CsrRead(CsrRead),
      .Wvalid(Wvalid),
      .Dready(Dready),
      .grant(grant),
      .aready(s_aready),
      .rdata(s_rdata),
      .rresp(s_rresp),
      .rvalid(s_rvalid),
      .Pready(Pready),
      .pc(pc),
      .araddr(i_araddr),
      .arvalid(i_arvalid),
      .rready(i_rready),
      .wready(s_wready),
      .bresp(s_bresp),
      .bvalid(s_bvalid),
      .awready(s_awready),
      .inst(inst),
      .Ivalid(Ivalid),
      .Irequst(Irequst),
      .PCPlus4(PCPlus4)
   );

   wire [`DATA_WIDTH - 1:0] PCPlus4;
   wire [`DATA_WIDTH - 1:0] PCD, PCPlus4D, InstD;

  //  ysyx_23060184_RegIFID RegIFID (
  //     .clk(clk),
  //     .rstn(resetn),
  //     .InstF(inst),
  //     .PCPlus4F(PCPlus4F),
  //     .PCF(pc),
  //     .InstD(InstD),
  //     .PCPlus4D(PCPlus4D),
  //     .PCD(PCD)
  //  );

   wire Jal, Jalr, Beq, Bne, Bltsu, Bgesu, Ecall, Mret;

   ysyx_23060184_IDU IDU (
      .clk(clk),
      .rstn(resetn),
      .inst(inst),
      .PC(pc),
      .Result(Result),
      .Ivalid(Ivalid),
      .Wvalid(Wvalid),
      .Pready(Pready),
      .Eready(Eready),
      .ALUResult(ALUResult),
      .Jal(Jal),
      .Jalr(Jalr),
      .Bne(Bne),
      .Beq(Beq),
      .Bltsu(Bltsu),
      .Bgesu(Bgesu),
      .Ecall(Ecall),
      .Mret(Mret),
      .RegWrite(RegWrite),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .CsrWrite(CsrWrite),
      .Wmask(Wmask),
      .Ropcode(Ropcode),
      .ResultSrc(ResultSrc),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .ALUOp(ALUOp),
      .CsrSrc(CsrSrc),
      .Dvalid(Dvalid),
      .Dready(Dready),
      .RD1(RD1),
      .RD2(RD2),
      .ImmExt(ImmExt),
      .CsrRead(CsrRead)
   );

   ysyx_23060184_EXU EXU (
      .clk(clk),
      .rstn(resetn),
      .Dvalid(Dvalid),
      .Mready(Mready),
      .RD1(RD1),
      .RD2(RD2),
      .ALUOp(ALUOp),
      .PC(pc),
      .CsrRead(CsrRead),
      .ImmExt(ImmExt),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .Jal(Jal),
      .Jalr(Jalr),
      .Beq(Beq),
      .Bne(Bne),
      .Bltsu(Bltsu),
      .Bgesu(Bgesu),
      .Ecall(Ecall),
      .Mret(Mret),
      .ALUResult(ALUResult),
      .PCTarget(PCTarget),
      .Evalid(Evalid),
      .Eready(Eready),
      .PCSrc(PCSrc)
   );


   /*
      Data Memory related AXI4 signals Begin
   */

   wire [`DATA_WIDTH - 1:0]         d_araddr;
   wire                             d_arvalid;
   wire                             d_rready;
   wire [`DATA_WIDTH - 1:0]         d_awaddr;
   wire                             d_awvalid;
   wire [`DATA_WIDTH - 1:0]         d_wdata;
   wire [`WMASK_LENGTH - 1:0]       d_wstrb;
   wire                             d_wvalid;
   wire                             d_bready;

   /*
      Data Memory related AXI4 signals End
   */

   ysyx_23060184_MEMU MEMU (
      .clk(clk),
      .rstn(resetn),
      .ALUResult(ALUResult),
      .Wready(Wready),
      .Evalid(Evalid),
      .grant(grant),
      .s_aready(s_aready),
      .s_rdata(s_rdata),
      .s_rresp(s_rresp),
      .s_rvalid(s_rvalid),
      .s_awready(s_awready),
      .s_wready(s_wready),
      .s_bresp(s_bresp),
      .s_bvalid(s_bvalid),
      .u_aready(u_aready),
      .u_rdata(u_rdata),
      .u_rresp(u_rresp),
      .u_rvalid(u_rvalid),
      .u_awready(u_awready),
      .u_wready(u_wready),
      .u_bresp(u_bresp),
      .u_bvalid(u_bvalid),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .Ropcode(Ropcode),
      .Wmask(Wmask),
      .RD2(RD2),
      .Mready(Mready),
      .Mvalid(Mvalid),
      .d_araddr(d_araddr),
      .d_arvalid(d_arvalid),
      .d_rready(d_rready),
      .d_awaddr(d_awaddr),
      .d_awvalid(d_awvalid),
      .d_wdata(d_wdata),
      .d_wstrb(d_wstrb),
      .d_wvalid(d_wvalid),
      .d_bready(d_bready),
      .Drequst(Drequst)
   );

   ysyx_23060184_WBU WBU (
      .clk(clk),
      .rstn(resetn),
      .Mvalid(Mvalid),
      .Pready(Pready),
      .ResultSrc(ResultSrc),
      .PCPlus4(PCPlus4),
      .ALUResult(ALUResult),
      .ReadData(ReadData),
      .CsrRead(CsrRead),
      .Wready(Wready),
      .Wvalid(Wvalid),
      .Result(Result)
   );

   wire [`NUM_ARB_MASTERS - 1:0] grant;

   ysyx_23060184_Arbiter Arbiter (
      .clk(clk),
      .req({Drequst, Irequst}),
      .iaddr(i_araddr),
      .daddr(ALUResult),
      .grant(grant)
   );

   // SRAM output signals
   wire                          s_aready;
   wire [`DATA_WIDTH - 1:0]      s_rdata;
   wire [`ACERR_WIDTH - 1:0]     s_rresp;
   wire                          s_rvalid;
   wire                          s_awready;
   wire                          s_wready;
   wire [`ACERR_WIDTH - 1:0]     s_bresp;
   wire                          s_bvalid;
   
   ysyx_23060184_SRAM SRAM (
      .clk(clk),

      /*
        Arbiter signals Begin
      */
      .grant(grant),
      /*
        Arbiter signals End
      */

      /*
        DataMem AXI4 Handshake signals Begin
      */
      .d_araddr(d_araddr),
      .d_arvalid(d_arvalid),
      .d_rready(d_rready),
      .d_awaddr(d_awaddr),
      .d_awvalid(d_awvalid),
      .d_wdata(d_wdata),
      .d_wstrb(d_wstrb),
      .d_wvalid(d_wvalid),
      .d_bready(d_bready),
      /*
        DataMem AXI4 Handshake signals End
      */

      /*
        InstMem AXI4 Handshake signals Begin
      */
      .i_araddr(i_araddr),
      .i_arvalid(i_arvalid),
      .i_rready(i_rready),
      /*
        InstMem AXI4 Handshake signals End
      */

      /*
        SRAM AXI4 Handshake signals Begin
      */
      .aready(s_aready),
      .rdata(s_rdata),
      .rresp(s_rresp),
      .rvalid(s_rvalid),
      .awready(s_awready),
      .wready(s_wready),
      .bresp(s_bresp),
      .bvalid(s_bvalid)
      /*
        SRAM AXI4 Handshake signals End
      */
   );
   
   // UART output signals
   wire                          u_aready;
   wire [`DATA_WIDTH - 1:0]      u_rdata;
   wire [`ACERR_WIDTH - 1:0]     u_rresp;
   wire                          u_rvalid;
   wire                          u_awready;
   wire                          u_wready;
   wire [`ACERR_WIDTH - 1:0]     u_bresp;
   wire                          u_bvalid;
   
   ysyx_23060184_UART UART (
      .clk(clk),

      /*
        Arbiter signals Begin
      */
      .grant(grant),
      /*
        Arbiter signals End
      */

      /*
        DataMem AXI4 Handshake signals Begin
      */
      .araddr(d_araddr),
      .arvalid(d_arvalid),
      .rready(d_rready),
      .awaddr(d_awaddr),
      .awvalid(d_awvalid),
      .wdata(d_wdata),
      .wstrb(d_wstrb),
      .wvalid(d_wvalid),
      .bready(d_bready),
      /*
        DataMem AXI4 Handshake signals End
      */

      /*
        UART AXI4 Handshake signals Begin
      */
      .aready(u_aready),
      .rdata(u_rdata),
      .rresp(u_rresp),
      .rvalid(u_rvalid),
      .awready(u_awready),
      .wready(u_wready),
      .bresp(u_bresp),
      .bvalid(u_bvalid)
      /*
        UART AXI4 Handshake signals End
      */
   );

endmodule 
