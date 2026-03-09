`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 20:34:43
// Design Name: 
// Module Name: AddressDecoder
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


module AddressDecoder(
    input [1:0] address,
    input writeData, readData,
    output dataMemWrite, dataMemRead, LEDWrite, switchReadEnable
    );
    
    assign dataMemWrite = (address == 2'b00) ? writeData : 0;
    assign dataMemRead = (address == 2'b00) ? readData : 0;
    assign LEDWrite = (address == 2'b01) ? writeData : 0;
    assign switchReadEnable = (address == 2'b10) ? readData : 0;
    
endmodule
