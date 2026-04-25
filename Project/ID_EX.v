`timescale 1ns / 1ps

// ID_EX — Pipeline register between Instruction Decode and Execute.
// Latches decoded control signals, register-file read data, the
// sign-extended immediate, and the instruction's funct3/funct7 fields.
//   flush : clears all signals to a NOP (used on stall or taken branch)
module ID_EX(
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // Instruction fields
    input  wire [2:0]  func3,
    input  wire [6:0]  func7,
    input  wire [31:0] PC,

    // Control signals
    input  wire [1:0]  aluOp,
    input  wire        regWrite, memRead, memWrite, aluSrc,
                       memToReg, branch, jump, jalr,

    // Register file read ports + immediate
    input  wire [4:0]  rs1, rs2, rd,
    input  wire [31:0] readData1, readData2, immediateValue,

    // Registered outputs (suffix "Last")
    output reg  [2:0]  func3Last,
    output reg  [6:0]  func7Last,
    output reg  [31:0] PCLast,

    output reg  [1:0]  aluOpLast,
    output reg         regWriteLast, memReadLast, memWriteLast, aluSrcLast,
                       memToRegLast, branchLast, jumpLast, jalrLast,

    output reg  [4:0]  rs1Last, rs2Last, rdLast,
    output reg  [31:0] readData1Last, readData2Last, immediateValueLast
);

    always @(posedge clk) begin
        if (reset || flush) begin
            func3Last          <= 3'b0;
            func7Last          <= 7'b0;
            PCLast             <= 32'b0;

            aluOpLast          <= 2'b0;
            regWriteLast       <= 1'b0;
            memReadLast        <= 1'b0;
            memWriteLast       <= 1'b0;
            aluSrcLast         <= 1'b0;
            memToRegLast       <= 1'b0;
            branchLast         <= 1'b0;
            jumpLast           <= 1'b0;
            jalrLast           <= 1'b0;

            rs1Last            <= 5'b0;
            rs2Last            <= 5'b0;
            rdLast             <= 5'b0;

            readData1Last      <= 32'b0;
            readData2Last      <= 32'b0;
            immediateValueLast <= 32'b0;
        end
        else begin
            func3Last          <= func3;
            func7Last          <= func7;
            PCLast             <= PC;

            aluOpLast          <= aluOp;
            regWriteLast       <= regWrite;
            memReadLast        <= memRead;
            memWriteLast       <= memWrite;
            aluSrcLast         <= aluSrc;
            memToRegLast       <= memToReg;
            branchLast         <= branch;
            jumpLast           <= jump;
            jalrLast           <= jalr;

            rs1Last            <= rs1;
            rs2Last            <= rs2;
            rdLast             <= rd;

            readData1Last      <= readData1;
            readData2Last      <= readData2;
            immediateValueLast <= immediateValue;
        end
    end

endmodule
