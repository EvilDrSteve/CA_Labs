`timescale 1ns / 1ps

module InstructionMemory(
    input wire [31:0] ReadAddress,
    output wire [31:0] Instruction
);

    // For a typical lab setup, 64 words (256 bytes) is usually enough memory,
    // but you can expand this array size if you have larger programs.
    reg [31:0] memory [0:63]; 

    // RISC-V memory is byte-addressed, but instructions are always full 32-bit (4-byte) words.
    // By discarding the bottom 2 bits (ReadAddress[31:2]), we correctly fetch the aligned word.
    wire [5:0] word_addr = ReadAddress[7:2];
    
    // Asynchronous read
    assign Instruction = memory[word_addr];

    // Load initial memory contents from a file
    initial begin
        // Providing the absolute path so Vivado's deeply-nested simulation folder can always find it!
        $readmemh("C:/Users/LENOVO/OneDrive/Desktop/parhai/CA/CA_Labs-main/lab11/program.hex", memory);
    end

endmodule
