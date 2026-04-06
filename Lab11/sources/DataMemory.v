`timescale 1ns / 1ps
module DataMemory(
    input clk, rst, memWrite,
    input [7:0] address,
    input [31:0]  writeData,
    output [31:0] readData
    );
    
    reg [31:0] memory [511:0];
    integer i;
    
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 512; i = i + 1)
                memory[i] <= 32'b0;
        end
        else if (memWrite)
            memory[address] <= writeData;
    end
    
    assign readData = memory[address];
endmodule