`timescale 1ns / 1ps

// AddressDecoder — Routes memory read/write enables to the correct
// peripheral based on address[9:8]:
//   00 = Data Memory
//   01 = LEDs
//   10 = Switches
module AddressDecoder(
    input wire [1:0] address,            // top 2 bits of memory address
    input wire       writeEnable,        // global write enable (memWrite)
    input wire       readEnable,         // global read enable (memRead)
    output wire      dataMemWrite,       // write enable to DataMemory
    output wire      dataMemRead,        // read enable to DataMemory
    output wire      ledWrite,           // write enable to LEDs
    output wire      switchReadEnable    // read enable to Switches
);

    assign dataMemWrite     = (address == 2'b00) ? writeEnable : 0;
    assign dataMemRead      = (address == 2'b00) ? readEnable  : 0;
    assign ledWrite         = (address == 2'b01) ? writeEnable : 0;
    assign switchReadEnable = (address == 2'b10) ? readEnable  : 0;

endmodule
