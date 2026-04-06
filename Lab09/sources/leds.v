`timescale 1ns / 1ps

module leds(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,

    output reg [31:0] readData = 0,
    output [15:0] leds
);
    // Two byte registers to hold LED values
    reg [7:0] led_low = 0;
    reg [7:0] led_high = 0;

    always @(posedge clk) begin
        if (rst) begin
            led_low <= 8'b0;
            led_high <= 8'b0;
        end
        else if (writeEnable) begin
            led_low <= writeData[7:0];
            led_high <= writeData[15:8];
        end
    end

    // Combine bytes into 16-bit LED output
    assign leds = {led_high, led_low};
endmodule