`timescale 1ns / 1ps

// MEM_WB — Pipeline register between Memory and Writeback stages.
// Carries the ALU result, the loaded data from memory, the link
// address (for JAL/JALR), and the writeback control signals.
module MEM_WB(
    input  wire        clk,
    input  wire        reset,

    // MEM-stage results
    input  wire [31:0] aluResult, memReadData, pcPlus4,

    // Destination register and writeback control
    input  wire [4:0]  rd,
    input  wire        regWrite, memToReg, jump, jalr,

    // Registered outputs (suffix "Last")
    output reg  [31:0] aluResultLast, memReadDataLast, pcPlus4Last,
    output reg  [4:0]  rdLast,
    output reg         regWriteLast, memToRegLast, jumpLast, jalrLast
);

    always @(posedge clk) begin
        if (reset) begin
            aluResultLast   <= 32'b0;
            memReadDataLast <= 32'b0;
            pcPlus4Last     <= 32'b0;

            rdLast          <= 5'b0;

            regWriteLast    <= 1'b0;
            memToRegLast    <= 1'b0;
            jumpLast        <= 1'b0;
            jalrLast        <= 1'b0;
        end
        else begin
            aluResultLast   <= aluResult;
            memReadDataLast <= memReadData;
            pcPlus4Last     <= pcPlus4;

            rdLast          <= rd;

            regWriteLast    <= regWrite;
            memToRegLast    <= memToReg;
            jumpLast        <= jump;
            jalrLast        <= jalr;
        end
    end

endmodule
