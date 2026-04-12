`timescale 1ns / 1ps

// switches — Memory-mapped switch input peripheral.
// Reads the 16 physical switches and presents them as a
// 32-bit value to the processor via the memory bus.
// Upper 16 bits are always zero.
module Switches(
    input wire         clk,
    input wire         rst,
    input wire [15:0]  btns,            // button inputs (active after debounce)
    input wire [31:0]  writeData,       // write bus (unused — switches are read-only)
    input wire         writeEnable,     // write strobe (unused)
    input wire         readEnable,      // read strobe from address decoder
    input wire [29:0]  memAddress,      // byte address within switch space
    input wire [15:0]  switchIn,        // physical switch inputs
    output reg [31:0]  readData         // 32-bit value returned to processor
);

    // Split 16 switches into 4 byte lanes for byte-addressable access
    wire [7:0] swBytes [0:3];
    assign swBytes[0] = switchIn[7:0];
    assign swBytes[1] = switchIn[15:8];
    assign swBytes[2] = 8'b0;
    assign swBytes[3] = 8'b0;

    // Synchronous read: assemble 4 bytes starting at memAddress
    always @(posedge clk) begin
        if (rst)
            readData <= 32'b0;
        else if (readEnable)
            readData <= {swBytes[memAddress + 3],
                         swBytes[memAddress + 2],
                         swBytes[memAddress + 1],
                         swBytes[memAddress]};
    end

endmodule
