`timescale 1ns / 1ps

// ALU — 32-bit Arithmetic Logic Unit.
// Performs the operation selected by aluControl on inputs a and b.
// Outputs the result and a zero flag (used for branch comparison).
//
// aluControl encoding:
//   0000 = ADD    (a + b)
//   0001 = SUB    (a - b)
//   0010 = AND    (a & b)
//   0011 = OR     (a | b)
//   0100 = XOR    (a ^ b)
//   0101 = SLL    (a << b[4:0])
//   0110 = SRL    (a >> b[4:0])
module ALU(
    input wire [31:0]      a,
    input wire [31:0]      b,
    input wire [3:0]       aluControl,  // operation select
    output reg [31:0]      aluResult,   // computation result
    output wire            zero,        // 1 when a == b
    output wire            lessThan     // 1 when a < b
);

    always @(*) begin
        case (aluControl)
            4'b0000: aluResult = a & b;         // AND
            4'b0001: aluResult = a | b;         // OR
            4'b0010: aluResult = a + b;         // ADD
            4'b0110: aluResult = a - b;         // SUB
            4'b0100: aluResult = a ^ b;         // XOR
            4'b0101: aluResult = a << b[4:0];   // SLL
            4'b0111: aluResult = a >> b[4:0];   // SRL
            default: aluResult = 32'b0;
        endcase

    end

    // Zero flag: asserted when a equals b (used by BEQ)
    assign zero = ((a - b) == 0);
    assign lessThan = ($signed(a) < $signed(b));

endmodule
