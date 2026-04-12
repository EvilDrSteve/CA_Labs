`timescale 1ns / 1ps

// pcAdder — Computes PC + 4 for sequential instruction fetch.
// Each RISC-V instruction is 4 bytes, so the next sequential
// instruction is always at the current PC plus 4.
module PcAdder(
    input wire [31:0]  pcIn,    // current PC
    output wire [31:0] pcNext   // PC + 4
);

    assign pcNext = pcIn + 32'd4;

endmodule
