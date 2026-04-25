`timescale 1ns / 1ps

// mux3 — 32-bit 3-to-1 multiplexer.
// sel=00 selects d0, sel=01 selects d1, sel=10 selects d2, sel=11 outputs 0.
module Mux3(
    input wire [31:0]  d0,   // input 0
    input wire [31:0]  d1,   // input 1
    input wire [31:0]  d2,   // input 2
    input wire [1:0]   sel,  // select line
    output wire [31:0] y     // output
);

    assign y = sel == 2'b00 ? d0 : sel == 2'b01 ? d1 : sel == 2'b10 ? d2 : 32'b0;

endmodule
