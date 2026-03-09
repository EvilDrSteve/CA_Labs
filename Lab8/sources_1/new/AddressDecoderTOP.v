`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 20:54:32
// Design Name: 
// Module Name: AddressDecoderTOP
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


module AddressDecoderTOP(
    input clk, rst,
    input [31:0] address,
    input readEnable, writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
    );
    
    wire dataMemRead, dataMemWrite, LEDWrite, switchRead;
    
    AddressDecoder ad(
        .address(address[9:8]), .writeData(writeEnable), .readData(readEnable),
         .dataMemRead(dataMemRead), .dataMemWrite(dataMemWrite),
         .LEDWrite(LEDWrite), .switchReadEnable(switchRead)
    );
    
    
    wire [31:0] sw_readData;
    switches sw_inst(
        .clk(clk),
        .rst(rst),
        .readEnable(switchRead),
        .switches(switches),
        .readData(sw_readData)
    );
    
    leds led_inst(
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LEDWrite),
        .leds(leds)
    );

    wire [31:0] dm_readData;
    DataMemory dataMem(
        .clk(clk),
        .memWrite(dataMemWrite),
        .address(address[7:0]),
        .writeData(writeData),
        .readData(dm_readData)
    );
    
    assign readData = (address[9:8] == 2'b00) ? dm_readData :
                      (address[9:8] == 2'b10) ? sw_readData :
                      32'b0;
endmodule
