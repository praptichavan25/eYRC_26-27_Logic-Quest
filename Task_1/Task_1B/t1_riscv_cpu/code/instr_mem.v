// instr_mem.v - instruction memory

module instr_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE = 512
) (
    input  [ADDR_WIDTH-1:0] instr_addr,
    output [DATA_WIDTH-1:0] instr
);

// Instruction memory
reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];

initial begin
    // Task 1B test program
    $readmemh("rv32i_test_1b.hex", instr_ram);
end

// Word-aligned instruction access
assign instr = instr_ram[instr_addr[31:2]];

endmodule