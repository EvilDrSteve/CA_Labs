`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 20:30:59
// Design Name: 
// Module Name: DataMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DataMemory(
    input clk, memWrite,
    input [7:0] address,
    input [31:0]  writeData,
    output [31:0] readData
    );
    
    reg [31:0] memory [255:0];

    always @(posedge clk) begin
        if(memWrite)
            memory[address[7:0]] <= writeData;
    end
    assign readData = memory[address[7:0]];

endmodule
