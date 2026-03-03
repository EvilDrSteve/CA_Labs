`timescale 1ns / 1ps

module SevenSegmentDriver(
    input clk,
    input reset,
    input [15:0] hex_data, // 16 bits = 4 Hex digits
    output reg [3:0] an,   // Anode controls (active low)
    output [6:0] seg       // Cathode controls (driven by your decoder)
);

    // Clock divider to slow down the refresh rate (~1 kHz)
    reg [18:0] refresh_counter;
    wire [1:0] led_activating_counter;

    always @(posedge clk or posedge reset) begin
        if(reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    // Use the top 2 bits of the counter to select which digit to illuminate
    assign led_activating_counter = refresh_counter[18:17];

    // Multiplexer to select the correct 4-bit hex nibble
    reg [3:0] current_digit;
    
    always @(*) begin
        case(led_activating_counter)
            2'b00: begin
                an = 4'b1110; // Activate Digit 0 (rightmost)
                current_digit = hex_data[3:0];
            end
            2'b01: begin
                an = 4'b1101; // Activate Digit 1
                current_digit = hex_data[7:4];
            end
            2'b10: begin
                an = 4'b1011; // Activate Digit 2
                current_digit = hex_data[11:8];
            end
            2'b11: begin
                an = 4'b0111; // Activate Digit 3 (leftmost)
                current_digit = hex_data[15:12];
            end
        endcase
    end

    // Instantiate your custom decoder!
    SevenSegmentDecoder my_decoder(
        .D(current_digit),
        .S(seg)
    );

endmodule