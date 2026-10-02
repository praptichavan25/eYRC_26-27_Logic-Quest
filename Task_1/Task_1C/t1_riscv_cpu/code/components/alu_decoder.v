// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin

    case (ALUOp)

        // -------------------------
        // Load / Store / AUIPC / LUI
        // -------------------------
        2'b00:
            ALUControl = 4'b0000;       // ADD


        // -------------------------
        // Branch instructions
        // -------------------------
        2'b01: begin

            case (funct3)

                3'b000:
                    ALUControl = 4'b1010;    // BEQ

                3'b001:
                    ALUControl = 4'b1011;    // BNE

                3'b100:
                    ALUControl = 4'b1100;    // BLT

                3'b101:
                    ALUControl = 4'b1101;    // BGE

                3'b110:
                    ALUControl = 4'b1110;    // BLTU

                3'b111:
                    ALUControl = 4'b1111;    // BGEU

                default:
                    ALUControl = 4'bxxxx;

            endcase

        end


        // -------------------------
        // R-type / I-type ALU
        // -------------------------
        2'b10: begin

            case (funct3)

                3'b000: begin

                    // SUB only for R-type with funct7 bit set
                    if (funct7b5 && opb5)
                        ALUControl = 4'b0001;    // SUB
                    else
                        ALUControl = 4'b0000;    // ADD / ADDI

                end

                3'b001:
                    ALUControl = 4'b0100;        // SLL / SLLI

                3'b010:
                    ALUControl = 4'b0101;        // SLT / SLTI

                3'b011:
                    ALUControl = 4'b0110;        // SLTU / SLTIU

                3'b100:
                    ALUControl = 4'b0111;        // XOR / XORI

                3'b101: begin

                    if (funct7b5)
                        ALUControl = 4'b1001;    // SRA / SRAI
                    else
                        ALUControl = 4'b1000;    // SRL / SRLI

                end

                3'b110:
                    ALUControl = 4'b0011;        // OR / ORI

                3'b111:
                    ALUControl = 4'b0010;        // AND / ANDI

                default:
                    ALUControl = 4'bxxxx;

            endcase

        end


        default:
            ALUControl = 4'bxxxx;

    endcase

end

endmodule

