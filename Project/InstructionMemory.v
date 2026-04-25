`timescale 1ns / 1ps

// InstructionMemory — ROM that stores the program (machine code).
// Asynchronous read: the instruction is available combinationally
// from the address. Loaded at simulation start from a .hex file.
module InstructionMemory(
    input wire [31:0]  readAddress,  // byte address from PC
    output wire [31:0] instruction   // fetched 32-bit instruction
);

    // 64-word (256-byte) instruction memory
    (* ram_style = "block" *) reg [31:0] memory [0:63];    // InstructionMemory

    // Convert byte address to word address by dropping the 2 LSBs.
    // RISC-V instructions are always 4-byte aligned.
    wire [5:0] wordAddr = readAddress[7:2];

    // Asynchronous read — no clock needed for instruction fetch
    assign instruction = memory[wordAddr];

    // Load program from hex file at simulation start
    initial begin
        $readmemh("C:/Uni/CA_Labs/Project/bubble.hex", memory);
    end

endmodule
