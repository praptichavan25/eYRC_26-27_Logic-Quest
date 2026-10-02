// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,
    input       [3:0] alu_ctrl,
    output reg  [WIDTH-1:0] alu_out,
    output reg  zero
);

always @(*) begin

    case (alu_ctrl)

        // -------------------------
        // Normal ALU operations
        // -------------------------

        4'b0000: begin
            alu_out = a + b;                    // ADD
            zero = (alu_out == 0);
        end

        4'b0001: begin
            alu_out = a - b;                    // SUB
            zero = (alu_out == 0);
        end

        4'b0010: begin
            alu_out = a & b;                    // AND
            zero = (alu_out == 0);
        end

        4'b0011: begin
            alu_out = a | b;                    // OR
            zero = (alu_out == 0);
        end

        4'b0100: begin
            alu_out = a << b[4:0];              // SLL
            zero = (alu_out == 0);
        end

        4'b0101: begin
            // SLT - signed comparison
            if (a[31] != b[31])
                alu_out = a[31] ? 32'd1 : 32'd0;
            else
                alu_out = (a < b) ? 32'd1 : 32'd0;

            zero = (alu_out == 0);
        end

        4'b0110: begin
            alu_out = (a < b) ? 32'd1 : 32'd0;  // SLTU
            zero = (alu_out == 0);
        end

        4'b0111: begin
            alu_out = a ^ b;                    // XOR
            zero = (alu_out == 0);
        end

        4'b1000: begin
            alu_out = a >> b[4:0];              // SRL
            zero = (alu_out == 0);
        end

        4'b1001: begin
            alu_out = $signed(a) >>> b[4:0];    // SRA
            zero = (alu_out == 0);
        end

        // -------------------------
        // Branch comparison operations
        // -------------------------

        4'b1010: begin
            // BEQ
            alu_out = (a == b) ? 32'd1 : 32'd0;
            zero = (a == b);
        end

        4'b1011: begin
            // BNE
            alu_out = (a != b) ? 32'd1 : 32'd0;
            zero = (a != b);
        end

        4'b1100: begin
            // BLT - signed
            alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            zero = ($signed(a) < $signed(b));
        end

        4'b1101: begin
            // BGE - signed
            alu_out = ($signed(a) >= $signed(b)) ? 32'd1 : 32'd0;
            zero = ($signed(a) >= $signed(b));
        end

        4'b1110: begin
            // BLTU - unsigned
            alu_out = (a < b) ? 32'd1 : 32'd0;
            zero = (a < b);
        end

        4'b1111: begin
            // BGEU - unsigned
            alu_out = (a >= b) ? 32'd1 : 32'd0;
            zero = (a >= b);
        end

        default: begin
            alu_out = 32'b0;
            zero = 1'b1;
        end

    endcase

end

endmodule