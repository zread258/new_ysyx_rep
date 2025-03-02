`include "ysyx_23060184_Config.v"

/* The Fire-Core Project started on January 22nd, 2024,
   which is relied on YSYX Project. This Core design is based on 
   RISC-V Instruction Set Architecture.
*/

module ysyx_23060184 (
    input                                 clock,
    input                                 reset,
    input                                 io_interrupt,
    input                                 io_master_awready,
    output reg                            io_master_awvalid,
    output reg [`DATA_WIDTH - 1:0]        io_master_awaddr,
    // Transaction identifier used for the ordering of write requests and responses
    output reg [`ID_WIDTH - 1:0]          io_master_awid,
    output reg [`ALEN - 1:0]              io_master_awlen,
    output reg [`ASIZE - 1:0]             io_master_awsize,
    output reg [`ABURST - 1:0]            io_master_awburst,
    input                                 io_master_wready,
    output reg                            io_master_wvalid,
    output reg [`DATA_WIDTH - 1:0]        io_master_wdata,
    output reg [`WSTRB_WIDTH - 1:0]       io_master_wstrb,
    output reg                            io_master_wlast,
    output reg                            io_master_bready,
    input                                 io_master_bvalid,
    input [`ACERR_WIDTH - 1:0]            io_master_bresp,
    input [`ID_WIDTH - 1:0]               io_master_bid,
    input                                 io_master_arready,
    output                                io_master_arvalid,
    output reg [`DATA_WIDTH - 1:0]        io_master_araddr,
    output reg [`ID_WIDTH - 1:0]          io_master_arid,
    output reg [`ALEN - 1:0]              io_master_arlen,
    output reg [`ASIZE - 1:0]             io_master_arsize,
    output reg [`ABURST - 1:0]            io_master_arburst,
    output reg                            io_master_rready,
    input                                 io_master_rvalid,
    input [`ACERR_WIDTH - 1:0]            io_master_rresp,
    input [`DATA_WIDTH - 1:0]             io_master_rdata,
    input                                 io_master_rlast,
    input [`ID_WIDTH - 1:0]               io_master_rid,
    output reg                            io_slave_awready,
    input                                 io_slave_awvalid,
    input [`DATA_WIDTH - 1:0]             io_slave_awaddr,
    input [`ID_WIDTH - 1:0]               io_slave_awid,
    input [`ALEN - 1:0]                   io_slave_awlen,
    input [`ASIZE - 1:0]                  io_slave_awsize,
    input [`ABURST - 1:0]                 io_slave_awburst,
    output reg                            io_slave_wready,
    input                                 io_slave_wvalid,
    input [`DATA_WIDTH - 1:0]             io_slave_wdata,
    input [`WSTRB_WIDTH - 1:0]            io_slave_wstrb,
    input                                 io_slave_wlast,
    input                                 io_slave_bready,
    output reg                            io_slave_bvalid,
    output reg [`ACERR_WIDTH - 1:0]       io_slave_bresp,
    output reg [`ID_WIDTH - 1:0]          io_slave_bid,
    output reg                            io_slave_arready,
    input                                 io_slave_arvalid,
    input [`DATA_WIDTH - 1:0]             io_slave_araddr,
    input [`ID_WIDTH - 1:0]               io_slave_arid,
    input [`ALEN - 1:0]                   io_slave_arlen,
    input [`ASIZE - 1:0]                  io_slave_arsize,
    input [`ABURST - 1:0]                 io_slave_arburst,
    input                                 io_slave_rready,
    output reg                            io_slave_rvalid,
    output reg [`ACERR_WIDTH - 1:0]       io_slave_rresp,
    output reg [`DATA_WIDTH - 1:0]        io_slave_rdata,
    output reg                            io_slave_rlast,
    output reg[`ID_WIDTH - 1:0]           io_slave_rid
);

    /* 
      CPU-related signals Begin
   */
    wire                     resetn;
    assign resetn            = ~reset;

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

    wire [`DATA_WIDTH - 1:0] PCF, InstF, PCPlus4F;
    wire ifu_grant, lsu_grant;

    wire Branch;

    /*
      IFU related AXI4 signals Begin
   */

    wire [  `DATA_WIDTH - 1:0] ifu_araddr;
    // wire                       d_arvalid;
    // wire                       d_rready;
    // wire [  `DATA_WIDTH - 1:0] d_awaddr;
    // wire                       d_awvalid;
    // wire [  `DATA_WIDTH - 1:0] d_wdata;
    // wire [`WMASK_LENGTH - 1:0] d_wstrb;
    // wire                       d_wvalid;
    // wire                       d_bready;

    /*
      IFU related AXI4 signals End
   */

    ysyx_23060184_IFU IFU (
        .clk(clock),
        .rstn(resetn),
        .Branch(Branch),
        // .Stall(StallF),
        .PCSrc(PCSrcE),
        .PCTarget(PCTargetE),
        .ALUResult(ALUResultE),
        .CsrRead(CsrReadD),
        .Dready(Dready),
        .grant(ifu_grant),
        .arready(io_master_arready),
        .rdata(io_master_rdata),
        .rresp(io_master_rresp),
        .rvalid(io_master_rvalid),
        .rlast(io_master_rlast),
        .Pready(Pready),
        .pc(PCF),
        .araddr(ifu_araddr),
        .arvalid(io_master_arvalid),
        .rready(io_master_rready),
        .inst(InstF),
        .Ivalid(Ivalid),
        .Irequest(Irequest),
        .arid(io_master_arid),
        .arlen(io_master_arlen),
        .arsize(io_master_arsize),
        .arburst(io_master_arburst),
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
        .clk(clock),
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
    wire [   `CSR_LENGTH - 1:0] CsrAddrD;

    ysyx_23060184_IDU IDU (
        .clk(clock),
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
        .CsrAddrD(CsrAddrD),
        .CsrAddrW(CsrAddrW),
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
    wire [`DATA_WIDTH - 1:0] PCE, InstE, ImmExtE, PCPlus4E, RD1E, RD2E, CsrReadE;
    wire [`REG_LENGTH - 1:0] Rs1E, Rs2E, RdE;
    wire [   `CSR_LENGTH - 1:0] CsrAddrD;

    ysyx_23060184_RegIDEXE RegIDEXE (
        .clk(clock),
        .resetn(resetn),
        .Dvalid(Dvalid),
        .Eready(Eready),
        .InstD(InstD),
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
        .CsrAddrD(CsrAddrD),
        .InstE(InstE),
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
        .RdE(RdE),
        .CsrAddrE(CsrAddrE)
    );

    wire [`DATA_WIDTH - 1:0] ALUResultE, PCTargetE, WriteDataE;
    wire [`PC_SRC_LENGTH - 1:0] PCSrcE;
    wire [`FWDA_MUX_LENGTH - 1:0] ForwardAE;
    wire [`FWDB_MUX_LENGTH - 1:0] ForwardBE;

    ysyx_23060184_EXU EXU (
        .clk(clock),
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

    wire [`DATA_WIDTH - 1:0] PCM, ALUResultM, PCTargetM, WriteDataM;
    wire RegWriteM, MemReadM, MemWriteM, CsrWriteM;
    wire [     `WMASK_LENGTH - 1:0] WmaskM;
    wire [   `ROPCODE_LENGTH - 1:0] RopcodeM;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcM;
    wire [`DATA_WIDTH - 1:0] InstM, PCPlus4M, CsrReadM;
    wire [`REG_LENGTH - 1:0] RdM;
    wire [   `CSR_LENGTH - 1:0] CsrAddrE, CsrAddrM;


    ysyx_23060184_RegEXMEM RegEXMEM (
        .clk(clock),
        .resetn(resetn),
        .Evalid(Evalid),
        .Mready(Mready),
        .PCE(PCE),
        .InstE(InstE),
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
        .CsrAddrE(CsrAddrE),
        .PCM(PCM),
        .InstM(InstM),
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
        .ALUResultM(ALUResultM),
        .CsrAddrM(CsrAddrM)
    );


    /*
      LSU related AXI4 signals Begin
   */

    wire [  `DATA_WIDTH - 1:0] lsu_araddr;
    // wire                       d_arvalid;
    // wire                       d_rready;
    // wire [  `DATA_WIDTH - 1:0] d_awaddr;
    // wire                       d_awvalid;
    // wire [  `DATA_WIDTH - 1:0] d_wdata;
    // wire [`WMASK_LENGTH - 1:0] d_wstrb;
    // wire                       d_wvalid;
    // wire                       d_bready;

    /*
      LSU related AXI4 signals End
   */

    wire [  `DATA_WIDTH - 1:0] ReadDataM;

    ysyx_23060184_LSU LSU (
        .clk(clock),
        .rstn(resetn),
        .ALUResult(ALUResultM),
        .Wready(Wready),
        .Evalid(Evalid),
        .grant(lsu_grant),
        .arready(io_master_arready),
        .rdata(io_master_rdata),
        .rlast(io_master_rlast),
        .rid(io_master_rid),
        .rresp(io_master_rresp),
        .rvalid(io_master_rvalid),
        .awready(io_master_awready),
        .wready(io_master_wready),
        .bresp(io_master_bresp),
        .bid(io_master_bid),
        .bvalid(io_master_bvalid),
        .MemReadE(MemReadE),
        .MemWriteE(MemWriteE),
        .MemRead(MemReadM),     // caused by non-blocking assignment 
        .MemWrite(MemWriteM),   // caused by non-blocking assignment
        .Ropcode(RopcodeM),
        .Wmask(WmaskM),
        .WriteData(WriteDataM),
        .Mready(Mready),
        .Mvalid(Mvalid),
        .araddr(lsu_araddr),
        .arid(io_master_arid),
        .arlen(io_master_arlen),
        .arsize(io_master_arsize),
        .arburst(io_master_arburst),
        .arvalid(io_master_arvalid),
        .rready(io_master_rready),
        .awaddr(io_master_awaddr),
        .awvalid(io_master_awvalid),
        .awid(io_master_awid),
        .awlen(io_master_awlen),
        .awsize(io_master_awsize),
        .awburst(io_master_awburst),
        .wdata(io_master_wdata),
        .wstrb(io_master_wstrb),
        .wvalid(io_master_wvalid),
        .wlast(io_master_wlast),
        .bready(io_master_bready),
        .Drequest(Drequest),
        .ReadData(ReadDataM)
    );

    wire RegWriteW, CsrWriteW;
    wire [`RESULT_SRC_LENGTH - 1:0] ResultSrcW;
    wire [`DATA_WIDTH - 1:0] PCW, InstW, ALUResultW, PCPlus4W, ReadDataW, CsrReadW;
    wire [`REG_LENGTH - 1:0] RdW;
    wire [   `CSR_LENGTH - 1:0] CsrAddrW;

    ysyx_23060184_RegMEMWB RegMEMWB (
        .clk(clock),
        .resetn(resetn),
        .Mvalid(Mvalid),
        .Wready(Wready),
        .PCM(PCM),
        .InstM(InstM),
        .RegWriteM(RegWriteM),
        .CsrWriteM(CsrWriteM),
        .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM),
        .PCPlus4M(PCPlus4M),
        .ReadDataM(ReadDataM),
        .CsrReadM(CsrReadM),
        .RdM(RdM),
        .CsrAddrM(CsrAddrM),
        .PCW(PCW),
        .InstW(InstW),
        .RegWriteW(RegWriteW),
        .CsrWriteW(CsrWriteW),
        .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW),
        .PCPlus4W(PCPlus4W),
        .ReadDataW(ReadDataW),
        .CsrReadW(CsrReadW),
        .RdW(RdW),
        .CsrAddrW(CsrAddrW)
    );

    wire [`DATA_WIDTH - 1:0] ResultW;

    ysyx_23060184_WBU WBU (
        .clk(clock),
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

    ysyx_23060184_Xbar Xbar (
        .clk(clock),
        .rstn(resetn),
        .ifu_req(Irequest),
        .lsu_req(Drequest),
        .ifu_araddr(ifu_araddr),
        .lsu_araddr(lsu_araddr),
        .ifu_grant(ifu_grant),
        .lsu_grant(lsu_grant),
        .io_master_araddr(io_master_araddr)
    );

    // wire [`NUM_ARB_MASTERS - 1:0] grant;

    // ysyx_23060184_Arbiter Arbiter (
    //     .clk  (clock),
    //     .rstn (resetn),
    //     .req  ({Drequest, Irequest}),
    //     .s_rvalid(s_rvalid),
    //     .s_wready(s_wready),
    //     .iraddr(i_araddr),
    //     .draddr(d_araddr),
    //     .dwaddr(d_awaddr),
    //     .dren(MemReadM),
    //     .dwen(MemWriteM),
    //     .grant(grant)
    // );

    // SRAM output signals
    // wire                      s_aready;
    // wire [ `DATA_WIDTH - 1:0] s_rdata;
    // wire [`ACERR_WIDTH - 1:0] s_rresp;
    // wire                      s_rvalid;
    // wire                      s_awready;
    // wire                      s_wready;
    // wire [`ACERR_WIDTH - 1:0] s_bresp;
    // wire                      s_bvalid;

    // ysyx_23060184_SRAM SRAM (
    //     .clk(clock),
    //     .rstn(resetn),

    //     /*
    //     Arbiter signals Begin
    //   */
    //     .grant(grant),
    //     /*
    //     Arbiter signals End
    //   */

    //     /*
    //     DataMem AXI4 Handshake signals Begin
    //   */
    //     .d_araddr (d_araddr),
    //     .d_arvalid(d_arvalid),
    //     .d_rready (d_rready),
    //     .d_awaddr (d_awaddr),
    //     .d_awvalid(d_awvalid),
    //     .d_wdata  (d_wdata),
    //     .d_wstrb  (d_wstrb),
    //     .d_wvalid (d_wvalid),
    //     .d_bready (d_bready),
    //     /*
    //     DataMem AXI4 Handshake signals End
    //   */

    //     /*
    //     InstMem AXI4 Handshake signals Begin
    //   */
    //     .i_araddr (i_araddr),
    //     .i_arvalid(i_arvalid),
    //     .i_rready (i_rready),
    //     /*
    //     InstMem AXI4 Handshake signals End
    //   */

    //     /*
    //     SRAM AXI4 Handshake signals Begin
    //   */
    //     .aready (s_aready),
    //     .rdata  (s_rdata),
    //     .rresp  (s_rresp),
    //     .rvalid (s_rvalid),
    //     .awready(s_awready),
    //     .wready (s_wready),
    //     .bresp  (s_bresp),
    //     .bvalid (s_bvalid)
    //     /*
    //     SRAM AXI4 Handshake signals End
    //   */
    // );

    // UART output signals
    // wire                      u_aready;
    // wire [ `DATA_WIDTH - 1:0] u_rdata;
    // wire [`ACERR_WIDTH - 1:0] u_rresp;
    // wire                      u_rvalid;
    // wire                      u_awready;
    // wire                      u_wready;
    // wire [`ACERR_WIDTH - 1:0] u_bresp;
    // wire                      u_bvalid;

    // ysyx_23060184_UART UART (
    //     .clk(clock),

    //     /*
    //     Arbiter signals Begin
    //   */
    //     .grant(grant),
    //     /*
    //     Arbiter signals End
    //   */

    //     /*
    //     DataMem AXI4 Handshake signals Begin
    //   */
    //     .araddr (d_araddr),
    //     .arvalid(d_arvalid),
    //     .rready (d_rready),
    //     .awaddr (d_awaddr),
    //     .awvalid(d_awvalid),
    //     .wdata  (d_wdata),
    //     .wstrb  (d_wstrb),
    //     .wvalid (d_wvalid),
    //     .bready (d_bready),
    //     /*
    //     DataMem AXI4 Handshake signals End
    //   */

    //     /*
    //     UART AXI4 Handshake signals Begin
    //   */
    //     .aready (u_aready),
    //     .rdata  (u_rdata),
    //     .rresp  (u_rresp),
    //     .rvalid (u_rvalid),
    //     .awready(u_awready),
    //     .wready (u_wready),
    //     .bresp  (u_bresp),
    //     .bvalid (u_bvalid)
    //     /*
    //     UART AXI4 Handshake signals End
    //   */
    // );

endmodule
