`timescale 1ns / 1ps

module SevenSegmentDriver(
    input clk,
    input reset,
    input [15:0] hexData, // 16 bits = 4 Hex digits
    output reg [3:0] displayPower,   // display power controls (active low)
    output [6:0] segments       // Cathode controls (driven by your decoder)
);

    // Clock divider to slow down the refresh rate (~1 kHz)
    reg [18:0] refreshCounter;
    wire [1:0] ledActivatingCounter;

    always @(posedge clk or posedge reset) begin
        if(reset)
            refreshCounter <= 0;
        else
            refreshCounter <= refreshCounter + 1;
    end

    // Use the top 2 bits of the counter to select which digit to illuminate
    assign ledActivatingCounter = refreshCounter[18:17];

    // Multiplexer to select the correct 4-bit hex nibble
    reg [3:0] currentDigit;
    
    always @(*) begin
        case(ledActivatingCounter)
            2'b00: begin
                displayPower = 4'b1110; // Activate Digit 0 (rightmost)
                currentDigit = hexData[3:0];
            end
            2'b01: begin
                displayPower = 4'b1101; // Activate Digit 1
                currentDigit = hexData[7:4];
            end
            2'b10: begin
                displayPower = 4'b1011; // Activate Digit 2
                currentDigit = hexData[11:8];
            end
            2'b11: begin
                displayPower = 4'b0111; // Activate Digit 3 (leftmost)
                currentDigit = hexData[15:12];
            end
        endcase
    end

    // InstdisplayPowertiate your custom decoder!
    SevenSegmentDecoder myDecoder(
        .D(currentDigit),
        .S(segments)
    );

endmodule