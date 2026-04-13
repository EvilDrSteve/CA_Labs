`timescale 1ns / 1ps

// leds — Memory-mapped LED output peripheral.
// Stores a 16-bit value split into two byte registers.
// The processor writes LED values via the memory bus;
// the combined 16 bits drive the physical LEDs on the FPGA.
module Leds(
    input wire         clk,
    input wire         reset,
    input wire [31:0]  writeData,       // data from processor
    input wire         writeEnable,     // write strobe from address decoder
    input wire         readEnable,      // read strobe (unused but kept for bus interface)
    input wire [29:0]  memAddress,      // byte address within LED space (unused)
    output reg [31:0]  readData,        // readback value (unused by typical programs)
    output wire [15:0] ledOut           // drives physical LEDs
);

    reg [7:0] ledLow;    // lower 8 LEDs
    reg [7:0] ledHigh;   // upper 8 LEDs

    initial begin
        ledLow  = 8'b0;
        ledHigh = 8'b0;
        readData = 32'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            ledLow  <= 8'b0;
            ledHigh <= 8'b0;
        end
        else if (writeEnable) begin
            ledLow  <= writeData[7:0];
            ledHigh <= writeData[15:8];
        end
    end

    // Combine both byte registers into the 16-bit LED output
    assign ledOut = {ledHigh, ledLow};

endmodule
