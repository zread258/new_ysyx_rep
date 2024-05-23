`include "ysyx_23060184_Config.v"

/* The Steins Gate Computer Project started on January 22nd, 2024,
   which is relied on YSYX Project. This CPU design is based on 
   RISC-V Instruction Set Architecture.
*/

module ysyx_23060184_SGC (
    input                      clk,
    input                      resetn,
    output [`DATA_WIDTH - 1:0] pc,
    output [`DATA_WIDTH - 1:0] inst
);

    /* 
      CPU-related signals Begin
   */

    wire                     Pready;
    wire                     Ivalid;
    wire                     Dvalid;
    wire                     Dready;
    wire                     Evalid;
    wire                     Eready;
    wire                     Mvalid;
    wire                     Mready;
    wire                     Wvalid;
    wire                     Wready;
    wire                     Drequest;
    wire                     Irequest;

    /* 
      CPU-related signals End
   */

    /*
      Inst Memory related AXI4 signals Begin
   */

    wire [`DATA_WIDTH - 1:0] i_araddr;
    wire                     i_arvalid;
    wire                     i_rready;


    wire [`DATA_WIDTH - 1:0] PCF, InstF, PCPlus4F;
    assign pc   = PCF;
    assign inst = InstF;

    wire Branch;

    ysyx_23060184_IFU IFU (
        .clk(clk),
        .rstn(resetn),
        .Branch(Branch),
        // .Stall(StallF),
        .PCSrc(PCSrcE),
        .PCTarget(PCTargetE),
        .ALUResult(ALUResultE),
        .CsrRead(CsrReadD),
        .Dready(Dready),
        .grant(grant),
        .aready(s_aready),
        .rdata(s_rdata),
        .rresp(s_rresp),
        .rvalid(s_rvalid),
        .Pready(Pready),
        .pc(PCF),
        .araddr(i_araddr),
        .arvalid(i_arvalid),
        .rready(i_rready),
        .wready(s_wready),
        .bresp(s_bresp),
        .bvalid(s_bvalid),
        .awready(s_awready),
        .inst(InstF),
        .Ivalid(Ivalid),
        .Irequest(Irequest),
        .PCPlus4(PCPlus4F)
    );

    wire [`DATA_WIDTH - 1:0] PCD, PCPlus4D, InstD;
    // wire FlushD;
    wire StallF;

    ysyx_23060184_HazardUnit HazardUnit (
      .Rs1E(Rs1E),
      .Rs2E(Rs2E),
      .RdM(RdM),
      .RdW(RdW),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .PCSrcE(PCSrcE),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      // .StallF(StallF),
      // .FlushD(FlushD),
      .Branch(Branch)
    );

    ysyx_23060184_RegIFID RegIFID (
        .clk(clk),
        .rstn(resetn),
        // .clr(FlushD),
        .Ivalid(Ivalid),
        .Dready(Dready),
        .InstF(InstF),
        .PCPlus4F(PCPlus4F),
        .PCF(PCF),
        .InstD(InstD),
        .PCPlus4D(PCPlus4D),
        .PCD(PCD)
    );

    wire JalD, JalrD, BeqD, BneD, BltsuD, BgesuD, EcallD, MretD;
    wire RegWriteD, MemReadD, MemWriteD, CsrWriteD;
    wire [     `WMASK_LENGTH - 1:0] WmaskD;
    wire [   `ROPCODE_LENGTH - 1:0] RopcodeD;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcD;
    wire [  `ALU_SRCA_LENGTH - 1:0] ALUSrcAD;
    wire [  `ALU_SRCB_LENGTH - 1:0] ALUSrcBD;
    wire [    `ALU_OP_LENGTH - 1:0] ALUOpD;
    wire [`DATA_WIDTH - 1:0] ImmExtD, RD1D, RD2D, CsrReadD;

    ysyx_23060184_IDU IDU (
        .clk(clk),
        .rstn(resetn),
        .inst(InstD),
        .PCPlus4(PCPlus4W),
        .Result(ResultW),
        .RdW(RdW),
        .Ivalid(Ivalid),
        .Wvalid(Wvalid),
        .Eready(Eready),
        .ALUResult(ALUResultW),
        .Jal(JalD),
        .Jalr(JalrD),
        .Bne(BneD),
        .Beq(BeqD),
        .Bltsu(BltsuD),
        .Bgesu(BgesuD),
        .Ecall(EcallD),
        .Mret(MretD),
        .RegWriteD(RegWriteD),
        .RegWriteW(RegWriteW),
        .MemRead(MemReadD),
        .MemWrite(MemWriteD),
        .CsrWriteD(CsrWriteD),
        .CsrWriteW(CsrWriteW),
        .Wmask(WmaskD),
        .Ropcode(RopcodeD),
        .ResultSrc(ResultSrcD),
        .ALUSrcA(ALUSrcAD),
        .ALUSrcB(ALUSrcBD),
        .ALUOp(ALUOpD),
        .Dvalid(Dvalid),
        .Dready(Dready),
        .RD1(RD1D),
        .RD2(RD2D),
        .ImmExt(ImmExtD),
        .CsrRead(CsrReadD)
    );

    wire JalE, JalrE, BeqE, BneE, BltsuE, BgesuE, EcallE, MretE;
    wire RegWriteE, MemReadE, MemWriteE, CsrWriteE;
    wire [     `WMASK_LENGTH - 1:0] WmaskE;
    wire [   `ROPCODE_LENGTH - 1:0] RopcodeE;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcE;
    wire [  `ALU_SRCA_LENGTH - 1:0] ALUSrcAE;
    wire [  `ALU_SRCB_LENGTH - 1:0] ALUSrcBE;
    wire [    `ALU_OP_LENGTH - 1:0] ALUOpE;
    wire [`DATA_WIDTH - 1:0] PCE, ImmExtE, PCPlus4E, RD1E, RD2E, CsrReadE;
    wire [`REG_LENGTH - 1:0] Rs1E, Rs2E, RdE;

    ysyx_23060184_RegIDEXE RegIDEXE (
        .clk(clk),
        .resetn(resetn),
        .Dvalid(Dvalid),
        .Eready(Eready),
        .RegWriteD(RegWriteD),
        .MemReadD(MemReadD),
        .MemWriteD(MemWriteD),
        .CsrWriteD(CsrWriteD),
        .JalD(JalD),
        .JalrD(JalrD),
        .BneD(BneD),
        .BeqD(BeqD),
        .BltsuD(BltsuD),
        .BgesuD(BgesuD),
        .EcallD(EcallD),
        .MretD(MretD),
        .WmaskD(WmaskD),
        .RopcodeD(RopcodeD),
        .ResultSrcD(ResultSrcD),
        .ALUSrcAD(ALUSrcAD),
        .ALUSrcBD(ALUSrcBD),
        .ALUOpD(ALUOpD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .PCD(PCD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),
        .CsrReadD(CsrReadD),
        .Rs1D(InstD[19:15]),
        .Rs2D(InstD[24:20]),
        .RdD(InstD[11:7]),
        .RegWriteE(RegWriteE),
        .MemReadE(MemReadE),
        .MemWriteE(MemWriteE),
        .CsrWriteE(CsrWriteE),
        .JalE(JalE),
        .JalrE(JalrE),
        .BneE(BneE),
        .BeqE(BeqE),
        .BltsuE(BltsuE),
        .BgesuE(BgesuE),
        .EcallE(EcallE),
        .MretE(MretE),
        .WmaskE(WmaskE),
        .RopcodeE(RopcodeE),
        .ResultSrcE(ResultSrcE),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ALUOpE(ALUOpE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),
        .CsrReadE(CsrReadE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE)
    );

    wire [`DATA_WIDTH - 1:0] ALUResultE, PCTargetE, WriteDataE;
    wire [`PC_SRC_LENGTH - 1:0] PCSrcE;
    wire [`FWDA_MUX_LENGTH - 1:0] ForwardAE;
    wire [`FWDB_MUX_LENGTH - 1:0] ForwardBE;

    ysyx_23060184_EXU EXU (
        .clk(clk),
        .rstn(resetn),
        .Dvalid(Dvalid),
        .Mready(Mready),
        .RD1(RD1E),
        .RD2(RD2E),
        .ALUOp(ALUOpE),
        .PC(PCE),
        .CsrRead(CsrReadE),
        .ImmExt(ImmExtE),
        .ALUSrcA(ALUSrcAE),
        .ALUSrcB(ALUSrcBE),
        .Jal(JalE),
        .Jalr(JalrE),
        .Beq(BeqE),
        .Bne(BneE),
        .Bltsu(BltsuE),
        .Bgesu(BgesuE),
        .Ecall(EcallE),
        .Mret(MretE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .ALUResult(ALUResultE),
        .PCTarget(PCTargetE),
        .WriteData(WriteDataE),
        .Evalid(Evalid),
        .Eready(Eready),
        .PCSrc(PCSrcE)
    );

    wire [`DATA_WIDTH - 1:0] ALUResultM, PCTargetM, WriteDataM;
    wire RegWriteM, MemReadM, MemWriteM, CsrWriteM;
    wire [     `WMASK_LENGTH - 1:0] WmaskM;
    wire [   `ROPCODE_LENGTH - 1:0] RopcodeM;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcM;
    wire [`DATA_WIDTH - 1:0] PCPlus4M, CsrReadM;
    wire [`REG_LENGTH - 1:0] RdM;


    ysyx_23060184_RegEXMEM RegEXMEM (
        .clk(clk),
        .resetn(resetn),
        .Evalid(Evalid),
        .Mready(Mready),
        .RegWriteE(RegWriteE),
        .MemReadE(MemReadE),
        .MemWriteE(MemWriteE),
        .WmaskE(WmaskE),
        .RopcodeE(RopcodeE),
        .ResultSrcE(ResultSrcE),
        .WriteDataE(WriteDataE),
        .CsrWriteE(CsrWriteE),
        .ALUResultE(ALUResultE),
        .PCPlus4E(PCPlus4E),
        .CsrReadE(CsrReadE),
        .RdE(RdE),
        .RegWriteM(RegWriteM),
        .MemReadM(MemReadM),
        .MemWriteM(MemWriteM),
        .CsrWriteM(CsrWriteM),
        .WmaskM(WmaskM),
        .RopcodeM(RopcodeM),
        .ResultSrcM(ResultSrcM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .CsrReadM(CsrReadM),
        .RdM(RdM),
        .ALUResultM(ALUResultM)
    );


    /*
      Data Memory related AXI4 signals Begin
   */

    wire [  `DATA_WIDTH - 1:0] d_araddr;
    wire                       d_arvalid;
    wire                       d_rready;
    wire [  `DATA_WIDTH - 1:0] d_awaddr;
    wire                       d_awvalid;
    wire [  `DATA_WIDTH - 1:0] d_wdata;
    wire [`WMASK_LENGTH - 1:0] d_wstrb;
    wire                       d_wvalid;
    wire                       d_bready;

    /*
      Data Memory related AXI4 signals End
   */

    wire [  `DATA_WIDTH - 1:0] ReadDataM;

    ysyx_23060184_MEMU MEMU (
        .clk(clk),
        .rstn(resetn),
        .ALUResult(ALUResultM),
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
        .MemRead(MemReadE),     // caused by non-blocking assignment 
        .MemWrite(MemWriteE),   // caused by non-blocking assignment
        .Ropcode(RopcodeM),
        .Wmask(WmaskM),
        .WriteData(WriteDataM),
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
        .Drequest(Drequest),
        .ReadData(ReadDataM)
    );

    wire RegWriteW, CsrWriteW;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcW;
    wire [`DATA_WIDTH - 1:0] ALUResultW, PCPlus4W, ReadDataW, CsrReadW;
    wire [`REG_LENGTH - 1:0] RdW;

    ysyx_23060184_RegMEMWB RegMEMWB (
        .clk(clk),
        .resetn(resetn),
        .Mvalid(Mvalid),
        .Wready(Wready),
        .RegWriteM(RegWriteM),
        .CsrWriteM(CsrWriteM),
        .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM),
        .PCPlus4M(PCPlus4M),
        .ReadDataM(ReadDataM),
        .CsrReadM(CsrReadM),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .CsrWriteW(CsrWriteW),
        .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW),
        .PCPlus4W(PCPlus4W),
        .ReadDataW(ReadDataW),
        .CsrReadW(CsrReadW),
        .RdW(RdW)
    );

    wire [`DATA_WIDTH - 1:0] ResultW;

    ysyx_23060184_WBU WBU (
        .clk(clk),
        .rstn(resetn),
        .Mvalid(Mvalid),
        .ResultSrc(ResultSrcW),
        .PCPlus4(PCPlus4W),
        .ALUResult(ALUResultW),
        .ReadData(ReadDataW),
        .CsrRead(CsrReadW),
        .Wready(Wready),
        .Wvalid(Wvalid),
        .Result(ResultW)
    );

    wire [`NUM_ARB_MASTERS - 1:0] grant;

    ysyx_23060184_Arbiter Arbiter (
        .clk  (clk),
        .rstn (resetn),
        .req  ({Drequest, Irequest}),
        .s_rvalid(s_rvalid),
        .s_wready(s_wready),
        .iraddr(i_araddr),
        .draddr(d_araddr),
        .dwaddr(d_awaddr),
        .dren(MemReadM),
        .dwen(MemWriteM),
        .grant(grant)
    );

    // SRAM output signals
    wire                      s_aready;
    wire [ `DATA_WIDTH - 1:0] s_rdata;
    wire [`ACERR_WIDTH - 1:0] s_rresp;
    wire                      s_rvalid;
    wire                      s_awready;
    wire                      s_wready;
    wire [`ACERR_WIDTH - 1:0] s_bresp;
    wire                      s_bvalid;

    ysyx_23060184_SRAM SRAM (
        .clk(clk),
        .rstn(resetn),

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
        .d_araddr (d_araddr),
        .d_arvalid(d_arvalid),
        .d_rready (d_rready),
        .d_awaddr (d_awaddr),
        .d_awvalid(d_awvalid),
        .d_wdata  (d_wdata),
        .d_wstrb  (d_wstrb),
        .d_wvalid (d_wvalid),
        .d_bready (d_bready),
        /*
        DataMem AXI4 Handshake signals End
      */

        /*
        InstMem AXI4 Handshake signals Begin
      */
        .i_araddr (i_araddr),
        .i_arvalid(i_arvalid),
        .i_rready (i_rready),
        /*
        InstMem AXI4 Handshake signals End
      */

        /*
        SRAM AXI4 Handshake signals Begin
      */
        .aready (s_aready),
        .rdata  (s_rdata),
        .rresp  (s_rresp),
        .rvalid (s_rvalid),
        .awready(s_awready),
        .wready (s_wready),
        .bresp  (s_bresp),
        .bvalid (s_bvalid)
        /*
        SRAM AXI4 Handshake signals End
      */
    );

    // UART output signals
    wire                      u_aready;
    wire [ `DATA_WIDTH - 1:0] u_rdata;
    wire [`ACERR_WIDTH - 1:0] u_rresp;
    wire                      u_rvalid;
    wire                      u_awready;
    wire                      u_wready;
    wire [`ACERR_WIDTH - 1:0] u_bresp;
    wire                      u_bvalid;

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
        .araddr (d_araddr),
        .arvalid(d_arvalid),
        .rready (d_rready),
        .awaddr (d_awaddr),
        .awvalid(d_awvalid),
        .wdata  (d_wdata),
        .wstrb  (d_wstrb),
        .wvalid (d_wvalid),
        .bready (d_bready),
        /*
        DataMem AXI4 Handshake signals End
      */

        /*
        UART AXI4 Handshake signals Begin
      */
        .aready (u_aready),
        .rdata  (u_rdata),
        .rresp  (u_rresp),
        .rvalid (u_rvalid),
        .awready(u_awready),
        .wready (u_wready),
        .bresp  (u_bresp),
        .bvalid (u_bvalid)
        /*
        UART AXI4 Handshake signals End
      */
    );

endmodule
