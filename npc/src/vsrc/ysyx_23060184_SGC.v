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
   reg [`DATA_WIDTH - 1:0]          Npc;
   reg [`DATA_WIDTH - 1:0]          ImmExt;
   reg [`DATA_WIDTH - 1:0]          ALUResult;
   reg [`DATA_WIDTH - 1:0]          RD1;
   reg [`DATA_WIDTH - 1:0]          RD2;
   reg [`NPC_OP_LENGTH - 1:0]       Npc_op;
   reg [`ALU_OP_LENGTH - 1:0]       ALUOp;
   reg [`EXT_OP_LENGTH - 1:0]       ExtOp;
   reg [`RESULT_SRC_LENGTH - 1:0]   ResultSrc;
   reg [`WMASK_LENGTH - 1:0]        Wmask;
   reg [`DATA_WIDTH - 1:0]          Result;
   reg [`DATA_WIDTH - 1:0]          SrcA;
   reg [`DATA_WIDTH - 1:0]          SrcB;
   reg [`ALU_SRCA_LENGTH - 1:0]     ALUSrcA;
   reg [`ALU_SRCB_LENGTH - 1:0]     ALUSrcB;
   reg [`DATA_WIDTH - 1:0]          ReadData;
   reg [`ROPCODE_LENGTH - 1:0]      Ropcode;
   reg [`CSR_SRC_LENGTH - 1:0]      CsrSrc;
   reg [`DATA_WIDTH - 1:0]          CsrRead;
   reg [`DATA_WIDTH - 1:0]          CsrWdata;

   wire RegWrite;
   wire CsrWrite;
   wire MemRead;
   wire MemWrite;
   wire Zero;
   wire ecall;
   wire mret;
   wire Pvalid;
   wire Ivalid;
   // wire Iready;
   wire Evalid;
   // wire Eready;
   wire Wvalid;
   // wire Wready;

   ysyx_23060184_DataMem DataMem (
      .clk(clk),
      .resetn(resetn),
      .raddr(ALUResult),
      .Evalid(Evalid),
      .Wvalid(Wvalid),
      // .Wready(Wready),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .wmask(Wmask),
      .wdata(RD2),
      .ropcode(Ropcode),
      .result(ReadData)
   );

   ysyx_23060184_InstMem InstMem (
      .clk(clk),
      .A(pc),
      .Pvalid(Pvalid),
      .Ivalid(Ivalid),
      .RD(inst)
   );

   ysyx_23060184_ControlUnit ControlUnit (
      .opcode(inst[6:0]),
      .funct3(inst[14:12]),
      .funct7(inst[31:25]),
      .funct12(inst[31:20]),
      .Npc_op(Npc_op),
      .Zero(Zero),
      .Flag(ALUResult[0]),
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
      .ecall(ecall),
      .CsrSrc(CsrSrc),
      .mret(mret)
   );
   ysyx_23060184_PC PC (
      .clk(clk),
      .rstn(resetn),
      .Wvalid(Wvalid),
      .Pvalid(Pvalid),
      .NPC(Npc),
      .PC(pc)
   );
   ysyx_23060184_NPC NPC (
      .resetn(resetn),
      .Npc_op(Npc_op),
      .PC(pc),
      .Inst(inst),
      .ALUResult(ALUResult),
      .Imm20(inst[31:12]),
      .CsrRead(CsrRead),
      .NPC(Npc)
   );
   ysyx_23060184_Extend Extend (
      .Inst(inst),
      .ExtOp(ExtOp),
      .ImmExt(ImmExt)
   );
   ysyx_23060184_ALU ALU (
      .SrcA(SrcA),
      .SrcB(SrcB),
      .ALUOp(ALUOp),
      .Zero(Zero),
      .ALUResult(ALUResult)
   );

   // Multiplexers
   ysyx_23060184_Mux_Result_Src Mux_Result_Src (
      .ResultSrc(ResultSrc),
      .PC(pc),
      .ALUResult(ALUResult),
      .ReadData(ReadData),
      .CsrRead(CsrRead),
      .Result(Result)
   );

   ysyx_23060184_Mux_ALUSrcA Mux_ALUSrcA (
      .ALUSrcA(ALUSrcA),
      .PC(pc),
      .RD1(RD1),
      .SrcA(SrcA)
   );

   ysyx_23060184_Mux_ALUSrcB Mux_ALUSrcB (
      .ALUSrcB(ALUSrcB),
      .ImmExt(ImmExt),
      .RD2(RD2),
      .CsrRead(CsrRead),
      .SrcB(SrcB)
   );   

   ysyx_23060184_RegFile RegFile (
      .clk(clk),
      .wdata(Result),
      .waddr(inst[11:7]),
      .wen(RegWrite),
      .raddr1(inst[19:15]),
      .raddr2(inst[24:20]),
      .rdata1(RD1),
      .rdata2(RD2),
      .Ivalid(Ivalid),
      // .Wready(Wready),
      .Evalid(Evalid),
      // .Eready(Eready),
      .ecall(ecall)
   );

   ysyx_23060184_CSReg CSReg (
      .clk(clk),
      .ecall(ecall),
      .mret(mret),
      .pc(pc),
      .wdata(ALUResult),
      .waddr(inst[29:20]), // TODO: Expand to 12 bits addr
      .wen(CsrWrite),
      .raddr(inst[29:20]),
      .rdata(CsrRead)
   );

   ysyx_23060184_Decode Deocde (
      .clk(clk),
      .inst(inst)
   );
endmodule 
