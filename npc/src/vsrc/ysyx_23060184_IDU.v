module ysyx_23060184_IDU (

    input                               clk,
    input                               rstn,
    input [`DATA_WIDTH - 1:0]           inst,



    /*
        RegFile Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           Result, // Change to ResultW
    // input [`DATA_WIDTH - 1:0]           RegWriteW, // TODO: Add when change to pipeline
    input                               Ivalid,
    input                               Wvalid,
    input                               Pready,
    input                               Wready,

    /*
        RegFile Input Signals End
    */

    /*
        CSReg Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           ALUResult, // Change to ALUResultW
    // input [`DATA_WIDTH - 1:0]           CsrWriteW, TODO: Add when change to pipeline
    input [`DATA_WIDTH - 1:0]           PC,

    /*
        CSReg Input Signals End
    */

    /* --------------------------------------------- */

    /*
        ControlUnit Output Signals Begin
    */

    output                              Jal,
    output                              Jalr,
    output                              Bne,
    output                              Beq,
    output                              Bltsu,
    output                              Bgesu,
    output                              Ecall,
    output                              Mret,
    output                              RegWrite,
    output                              MemRead,
    output                              MemWrite,
    output                              CsrWrite,
    output [`WMASK_LENGTH - 1:0]        Wmask,
    output [`ROPCODE_LENGTH - 1:0]      Ropcode,
    output [`RESULT_SRC_LENGTH - 1:0]   ResultSrc,
    output [`ALU_SRCA_LENGTH - 1:0]     ALUSrcA,
    output [`ALU_SRCB_LENGTH - 1:0]     ALUSrcB,
    output [`ALU_OP_LENGTH - 1:0]       ALUOp,
    output [`CSR_SRC_LENGTH - 1:0]      CsrSrc,

    /*
        ControlUnit Output Signals End
    */


    /*
        RegFile Output Signals Begin
    */

    output                              Evalid,
    output                              Eready,
    output [`DATA_WIDTH-1:0]            RD1,
    output [`DATA_WIDTH-1:0]            RD2,

    /*
        RegFile Output Signals End
    */


    /*
        Extend Output Signals Begin
    */
    output [`DATA_WIDTH - 1:0]          ImmExt,
    /*
        Extend Output Signals End
    */


    /*
        CSReg Output Signals Begin
    */
    output [`DATA_WIDTH - 1:0]          CsrRead
    /*
        CSReg Output Signals End
    */
);

    wire [`EXT_OP_LENGTH - 1:0]         ExtOp;

    ysyx_23060184_Decode Deocde (
      .clk(clk),
      .inst(inst)
   );

   ysyx_23060184_ControlUnit ControlUnit (
      .opcode(inst[6:0]),
      .funct3(inst[14:12]),
      .funct7(inst[31:25]),
      .funct12(inst[31:20]),
      .Jal(Jal),
      .Jalr(Jalr),
      .Bne(Bne),
      .Beq(Beq),  
      .Bltsu(Bltsu),
      .Bgesu(Bgesu),
      .RegWrite(RegWrite),
      .ResultSrc(ResultSrc),
      .ExtOp(ExtOp),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .ALUOp(ALUOp),
      .Wmask(Wmask),
      .Ropcode(Ropcode),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .CsrWrite(CsrWrite),
      .Ecall(Ecall),
      .CsrSrc(CsrSrc),
      .Mret(Mret)
   );

   ysyx_23060184_RegFile RegFile (
      .clk(clk),
      .resetn(rstn),
      .wdata(Result),
      .waddr(inst[11:7]),
      .wen(RegWrite),
      .raddr1(inst[19:15]),
      .raddr2(inst[24:20]),
      .rdata1(RD1),
      .rdata2(RD2),
      .Ivalid(Ivalid),
      .Wvalid(Wvalid),
      .Pready(Pready),
      .Wready(Wready),
      .Evalid(Evalid),
      .Eready(Eready),
      .ecall(Ecall)
   );

   ysyx_23060184_Extend Extend (
      .Inst(inst),
      .ExtOp(ExtOp),
      .ImmExt(ImmExt)
   );

   ysyx_23060184_CSReg CSReg (
      .clk(clk),
      .ecall(Ecall),
      .mret(Mret),
      .pc(PC),
      .wdata(ALUResult),
      .waddr(inst[29:20]), // TODO: Expand to 12 bits addr
      .wen(CsrWrite),
      .raddr(inst[29:20]),
      .Wvalid(Wvalid),
      .Pready(Pready),
      .rdata(CsrRead)
   );

endmodule