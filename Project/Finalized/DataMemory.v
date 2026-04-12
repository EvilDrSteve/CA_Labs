`timescale 1ns / 1ps

// DataMemory — 512x32 read/write data memory.
// Synchronous write on posedge clk when memWrite is asserted.
// Asynchronous read — readData is always available combinationally.
module DataMemory(
    input wire         clk,
    input wire         rst,
    input wire         memWrite,        // write enable
    input wire [7:0]   address,         // 8-bit word address (512 entries)
    input wire [31:0]  writeData,       // data to write
    output wire [31:0] readData         // data read (async)
);

    reg [31:0] memory [511:0];
    integer i;

    // Synchronous write with reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 512; i = i + 1)
                memory[i] <= 32'b0;
        end
        else if (memWrite)
            memory[address] <= writeData;
    end

    // Asynchronous read
    assign readData = memory[address];

endmodule
