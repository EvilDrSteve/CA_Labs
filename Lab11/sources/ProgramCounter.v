`timescale 1ns / 1ps

module ProgramCounter(
    input wire clk,
    input wire reset,
    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= pc_in;
    end

endmodule