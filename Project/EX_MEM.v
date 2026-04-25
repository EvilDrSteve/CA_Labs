`timescale 1ns / 1ps

// EX_MEM — Pipeline register between Execute and Memory stages.
// Carries the ALU result, store data, branch target, link address,
// branch flags, and downstream control signals.
//   flush : clears all signals (used on taken branch / jump in MEM)
module EX_MEM(
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // EX-stage results
    input  wire [31:0] aluResult, readData2, branchTarget, pcPlus4,
    input  wire        zero, lessThan,

    // Destination + funct3 (for MEM-stage branch decision)
    input  wire [4:0]  rd,
    input  wire [2:0]  func3,

    // Control signals
    input  wire        memRead, memWrite, branch, jump, jalr, regWrite, memToReg,

    // Registered outputs (suffix "Last")
    output reg  [31:0] aluResultLast, readData2Last, branchTargetLast, pcPlus4Last,
    output reg         zeroLast, lessThanLast,
    output reg  [4:0]  rdLast,
    output reg  [2:0]  func3Last,
    output reg         memReadLast, memWriteLast, branchLast, jumpLast, jalrLast,
                       regWriteLast, memToRegLast
);

    always @(posedge clk) begin
        if (reset || flush) begin
            aluResultLast    <= 32'b0;
            readData2Last    <= 32'b0;
            branchTargetLast <= 32'b0;
            pcPlus4Last      <= 32'b0;

            zeroLast         <= 1'b0;
            lessThanLast     <= 1'b0;

            rdLast           <= 5'b0;
            func3Last        <= 3'b0;

            memReadLast      <= 1'b0;
            memWriteLast     <= 1'b0;
            branchLast       <= 1'b0;
            jumpLast         <= 1'b0;
            jalrLast         <= 1'b0;
            regWriteLast     <= 1'b0;
            memToRegLast     <= 1'b0;
        end
        else begin
            aluResultLast    <= aluResult;
            readData2Last    <= readData2;
            branchTargetLast <= branchTarget;
            pcPlus4Last      <= pcPlus4;

            zeroLast         <= zero;
            lessThanLast     <= lessThan;

            rdLast           <= rd;
            func3Last        <= func3;

            memReadLast      <= memRead;
            memWriteLast     <= memWrite;
            branchLast       <= branch;
            jumpLast         <= jump;
            jalrLast         <= jalr;
            regWriteLast     <= regWrite;
            memToRegLast     <= memToReg;
        end
    end

endmodule
