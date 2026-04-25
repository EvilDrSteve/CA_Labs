`timescale 1ns / 1ps

// IF_ID — Pipeline register between Instruction Fetch and Instruction Decode.
// Latches the fetched PC and instruction on posedge clk.
//   stall : freezes the register (used by HazardDetectionUnit on load-use)
//   flush : clears the register to a NOP (used on taken branch / jump)
module IF_ID(
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] readAddress,        // PC of fetched instruction
    input  wire [31:0] instruction,        // fetched instruction word

    output reg  [31:0] lastReadAddress,    // registered PC
    output reg  [31:0] lastInstruction     // registered instruction
);

    always @(posedge clk) begin
        if (reset || flush) begin
            lastReadAddress <= 32'b0;
            lastInstruction <= 32'h00000013; // NOP: addi x0, x0, 0
        end
        else if (!stall) begin
            lastReadAddress <= readAddress;
            lastInstruction <= instruction;
        end
    end

endmodule
