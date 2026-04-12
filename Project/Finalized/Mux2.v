`timescale 1ns / 1ps

// mux2 — 32-bit 2-to-1 multiplexer.
// sel=0 selects d0, sel=1 selects d1.
module Mux2(
    input wire [31:0]  d0,   // input 0
    input wire [31:0]  d1,   // input 1
    input wire         sel,  // select line
    output wire [31:0] y     // output
);

    assign y = sel ? d1 : d0;

endmodule
