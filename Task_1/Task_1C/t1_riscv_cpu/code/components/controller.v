// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,

    output [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc,
    output       ALUSrc,
    output       RegWrite,
    output       Jump,

    output [2:0] ImmSrc,
    output       ALUSrcA,

    output [3:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;


// Main decoder
main_decoder md (
    op,
    ResultSrc,
    MemWrite,
    Branch,
    ALUSrc,
    RegWrite,
    Jump,
    ImmSrc,
    ALUSrcA,
    ALUOp
);


// ALU decoder
alu_decoder ad (
    op[5],
    funct3,
    funct7b5,
    ALUOp,
    ALUControl
);


// Branch / jump PC selection
assign PCSrc = (Branch & Zero) | Jump;

endmodule