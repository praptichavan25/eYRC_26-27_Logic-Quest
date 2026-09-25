
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input RegWrite,
    input [2:0] ImmSrc,
    input ALUSrcA,
    input [2:0] ALUControl,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget, JALRTarget;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [31:0] ALU_A;


// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
assign JALRTarget = {ALUResult[31:1], 1'b0};
mux2 #(32)     pcmux(PCPlus4, (Instr[6:0] == 7'b1100111) ? JALRTarget : PCTarget, PCSrc, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcamux(SrcA, PC, ALUSrcA, ALU_A);
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (ALU_A, SrcB, ALUControl, ALUResult, Zero);
mux3 #(32)     resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule

