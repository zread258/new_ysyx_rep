module ysyx_23060184_IDU (

    input                               clk,
    input                               rstn,
    input                               Stall,
    input [`DATA_WIDTH - 1:0]           inst,



    /*
        RegFile Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           Result, // Change to ResultW
    input [`RADD_WIDTH - 1:0]           RdW,
    input                               RegWriteW, // TODO: Add when change to pipeline
    input                               Ivalid,
    input                               Wvalid,
    input                               Eready,

    /*
        RegFile Input Signals End
    */

    /*
        CSReg Input Signals Begin
    */

    input [`DATA_WIDTH - 1:0]           ALUResult, // Change to ALUResultW
    input [`CSR_LENGTH - 1:0]           CsrAddrW,
    input                               CsrWriteW, // TODO: Add when change to pipeline
    input [`DATA_WIDTH - 1:0]           PCPlus4,

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
    output                              RegWriteD,
    output                              MemRead,
    output                              MemWrite,
    output                              CsrWriteD,
    output                              Rs2Valid,
    output                              JumpBranch,
    output [`WMASK_LENGTH - 1:0]        Wmask,
    output [`ROPCODE_LENGTH - 1:0]      Ropcode,
    output [`RESULT_SRC_LENGTH - 1:0]   ResultSrc,
    output [`ALU_SRCA_LENGTH - 1:0]     ALUSrcA,
    output [`ALU_SRCB_LENGTH - 1:0]     ALUSrcB,
    output [`ALU_OP_LENGTH - 1:0]       ALUOp,

    /*
        ControlUnit Output Signals End
    */


    /*
        RegFile Output Signals Begin
    */

    output reg                          Dvalid,
    output reg                          Dready,
    output reg [`DATA_WIDTH-1:0]        RD1,
    output reg [`DATA_WIDTH-1:0]        RD2,

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
    output [`CSR_LENGTH - 1:0]          CsrAddrD,
    output [`DATA_WIDTH - 1:0]          CsrRead
    /*
        CSReg Output Signals End
    */
);

    wire [`EXT_OP_LENGTH - 1:0]         ExtOp;

    wire [`DATA_WIDTH - 1:0]            PC = PCPlus4 - 4;

    assign CsrAddrD = inst[29:20];

    always @(posedge clk) begin
        if (~rstn) begin
            Dready <= 1;
        end
    end

    always @(posedge clk) begin
        if (Dready && Ivalid) begin
            Dready <= 0;
            Dvalid <= 1;
        end
        if (Dvalid && Eready && ~Stall) begin
            Dvalid <= 0;
            Dready <= 1;
        end
    end

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
      .RegWrite(RegWriteD),
      .ResultSrc(ResultSrc),
      .ExtOp(ExtOp),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .ALUOp(ALUOp),
      .Wmask(Wmask),
      .Ropcode(Ropcode),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .CsrWrite(CsrWriteD),
      .Ecall(Ecall),
      .Mret(Mret),
      .Rs2Valid(Rs2Valid),
      .JumpBranch(JumpBranch)
   );

   ysyx_23060184_RegFile RegFile (
      .clk(clk),
      .resetn(rstn),
      .wdata(Result),
      .waddr(RdW),
      .wen(RegWriteW),
      .raddr1(inst[19:15]),
      .raddr2(inst[24:20]),
      .rdata1(RD1),
      .rdata2(RD2),
      .Wvalid(Wvalid),
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
      .waddr(CsrAddrW), // TODO: Expand to 12 bits(Currently 10 bits) addr ToDo: Change it to CsrAddrW 
      .wen(CsrWriteW),
      .raddr(CsrAddrW),
      .Wvalid(Wvalid),
      .rdata(CsrRead)
   );

endmodule
