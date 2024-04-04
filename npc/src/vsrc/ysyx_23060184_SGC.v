/* The Steins Gate Computer Project started on January 22nd, 
   relying on YSYX Project. This computer designing based on 
   RISC-V Instruction Set Architecture.
*/
module ysyx_23060184_SGC(
      input clk, 
      input resetn,
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

   wire RegWrite;
   wire MemRead;
   wire MemWrite;
   wire Zero;

   ysyx_23060184_DataMem DataMem (
      .clk(clk),
      .raddr(ALUResult),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .wmask(Wmask),
      .wdata(RD2),
      .ropcode(Ropcode),
      .result(ReadData)
   );

   ysyx_23060184_InstMem InstMem (
      .A(pc),
      .RD(inst)
   );

   ysyx_23060184_ControlUnit ControlUnit (
      .opcode(inst[6:0]),
      .funct3(inst[14:12]),
      .funct7(inst[31:25]),
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
      .MemWrite(MemWrite)
   );
   ysyx_23060184_PC PC (
      .clk(clk),
      .rstn(resetn),
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
      .rdata2(RD2)
   );
   ysyx_23060184_Decode Deocde (
      .clk(clk),
      .inst(inst)
   );
endmodule 
