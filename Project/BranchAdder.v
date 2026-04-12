`timescale 1ns / 1ps

// branchAdder — Computes the branch target address.
// Target = PC + (immediate << 1). The immGen outputs the encoded
// 12-bit offset (half the real offset), so shifting left by 1
// reconstructs the full byte offset for B-type branches.
module BranchAdder(
    input wire [31:0]  pcIn,          // current PC
    input wire [31:0]  imm,           // sign-extended immediate from immGen
    output wire [31:0] branchTarget   // computed branch target address
);

    assign branchTarget = pcIn + (imm << 1);

endmodule
