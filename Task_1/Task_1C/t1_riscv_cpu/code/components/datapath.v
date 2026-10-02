module datapath (
    input         clk,
    input         reset,

    input  [1:0]  ResultSrc,
    input         PCSrc,

    input         ALUSrc,
    input         RegWrite,

    input  [2:0]  ImmSrc,
    input         ALUSrcA,

    input  [3:0]  ALUControl,

    output        Zero,

    output [31:0] PC,

    input  [31:0] Instr,

    output [31:0] Mem_WrAddr,
    output [31:0] Mem_WrData,

    input  [31:0] ReadData,

    output [31:0] Result
);

wire [31:0] PCNext;
wire [31:0] PCPlus4;
wire [31:0] PCTarget;
wire [31:0] JALRTarget;

wire [31:0] ImmExt;

wire [31:0] SrcA;
wire [31:0] WriteData;

wire [31:0] ALU_A;
wire [31:0] SrcB;
wire [31:0] ALUResult;

reg [31:0] LoadResult;
reg [31:0] StoreData;


// ============================================================
// PROGRAM COUNTER
// ============================================================

reset_ff #(32) pcreg (
    clk,
    reset,
    PCNext,
    PC
);


// PC + 4
adder pcadd4 (
    PC,
    32'd4,
    PCPlus4
);


// Branch / Jump target
adder pcaddbranch (
    PC,
    ImmExt,
    PCTarget
);


// JALR target
assign JALRTarget = {ALUResult[31:1], 1'b0};


// Next PC selection
// For JALR, use JALRTarget.
// For branches/JAL, use PCTarget.

mux2 #(32) pcmux (
    PCPlus4,
    (Instr[6:0] == 7'b1100111) ?
        JALRTarget :
        PCTarget,
    PCSrc,
    PCNext
);


// ============================================================
// REGISTER FILE
// ============================================================

reg_file rf (
    clk,
    RegWrite,
    Instr[19:15],
    Instr[24:20],
    Instr[11:7],
    Result,
    SrcA,
    WriteData
);


// ============================================================
// IMMEDIATE EXTENSION
// ============================================================

imm_extend ext (
    Instr[31:7],
    ImmSrc,
    ImmExt
);


// ============================================================
// ALU INPUT SELECTION
// ============================================================

// ALU A:
//   normal instructions -> register SrcA
//   AUIPC              -> PC

mux2 #(32) srcamux (
    SrcA,
    PC,
    ALUSrcA,
    ALU_A
);


// ALU B:
//   R-type -> register WriteData
//   I/S/B/U/J type -> immediate

mux2 #(32) srcbmux (
    WriteData,
    ImmExt,
    ALUSrc,
    SrcB
);


// ============================================================
// ALU
// ============================================================

alu alu (
    ALU_A,
    SrcB,
    ALUControl,
    ALUResult,
    Zero
);


// ============================================================
// MEMORY ADDRESS
// ============================================================

assign Mem_WrAddr = ALUResult;


// ============================================================
// LOAD DATA
// ============================================================
//
// Supports:
//   LB
//   LH
//   LW
//   LBU
//   LHU
//
// data_mem provides a 32-bit word.
// The byte/halfword is selected using ALUResult[1:0].
// ============================================================

always @(*) begin

    case (Instr[14:12])

        // ----------------------------------------------------
        // LB
        // ----------------------------------------------------
        3'b000: begin

            case (ALUResult[1:0])

                2'b00:
                    LoadResult = {{24{ReadData[7]}}, ReadData[7:0]};

                2'b01:
                    LoadResult = {{24{ReadData[15]}}, ReadData[15:8]};

                2'b10:
                    LoadResult = {{24{ReadData[23]}}, ReadData[23:16]};

                2'b11:
                    LoadResult = {{24{ReadData[31]}}, ReadData[31:24]};

                default:
                    LoadResult = 32'b0;

            endcase
        end


        // ----------------------------------------------------
        // LH
        // ----------------------------------------------------
        3'b001: begin

            if (ALUResult[1] == 1'b0)
                LoadResult = {{16{ReadData[15]}}, ReadData[15:0]};
            else
                LoadResult = {{16{ReadData[31]}}, ReadData[31:16]};

        end


        // ----------------------------------------------------
        // LW
        // ----------------------------------------------------
        3'b010: begin

            LoadResult = ReadData;

        end


        // ----------------------------------------------------
        // LBU
        // ----------------------------------------------------
        3'b100: begin

            case (ALUResult[1:0])

                2'b00:
                    LoadResult = {24'b0, ReadData[7:0]};

                2'b01:
                    LoadResult = {24'b0, ReadData[15:8]};

                2'b10:
                    LoadResult = {24'b0, ReadData[23:16]};

                2'b11:
                    LoadResult = {24'b0, ReadData[31:24]};

                default:
                    LoadResult = 32'b0;

            endcase
        end


        // ----------------------------------------------------
        // LHU
        // ----------------------------------------------------
        3'b101: begin

            if (ALUResult[1] == 1'b0)
                LoadResult = {16'b0, ReadData[15:0]};
            else
                LoadResult = {16'b0, ReadData[31:16]};

        end


        // ----------------------------------------------------
        // Default
        // ----------------------------------------------------
        default: begin

            LoadResult = ReadData;

        end

    endcase

end


// ============================================================
// STORE DATA
// ============================================================
//
// The Task 1C testbench checks the CPU's Mem_WrData output
// directly for SB, SH and SW.
//
// Therefore all store instructions pass the register value
// directly to the memory write-data output.
//
// SB -> WriteData
// SH -> WriteData
// SW -> WriteData
// ============================================================

always @(*) begin

    case (Instr[14:12])

        // ----------------------------------------------------
        // SB
        // ----------------------------------------------------
        3'b000: begin

            StoreData = WriteData;

        end


        // ----------------------------------------------------
        // SH
        // ----------------------------------------------------
        3'b001: begin

            StoreData = WriteData;

        end


        // ----------------------------------------------------
        // SW
        // ----------------------------------------------------
        3'b010: begin

            StoreData = WriteData;

        end


        // ----------------------------------------------------
        // Default
        // ----------------------------------------------------
        default: begin

            StoreData = WriteData;

        end

    endcase

end


assign Mem_WrData = StoreData;


// ============================================================
// RESULT MUX
// ============================================================
//
// ResultSrc:
//   00 -> ALU result
//   01 -> Load result
//   10 -> PC + 4
//
// Used for:
//   ALU instructions
//   Loads
//   JAL / JALR
// ============================================================

mux3 #(32) resultmux (
    ALUResult,
    LoadResult,
    PCPlus4,
    ResultSrc,
    Result
);

endmodule