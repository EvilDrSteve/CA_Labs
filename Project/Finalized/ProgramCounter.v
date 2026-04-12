`timescale 1ns / 1ps

// ProgramCounter — Holds the current instruction address.
// On each rising clock edge, loads the next PC value.
// Asynchronous reset sets PC back to 0.
module ProgramCounter(
    input wire        clk,
    input wire        reset,
    input wire [31:0] pcIn,    // next PC value to load
    output reg [31:0] pcOut    // current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pcOut <= 32'b0;
        else
            pcOut <= pcIn;
    end

endmodule
