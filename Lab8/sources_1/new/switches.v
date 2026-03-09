`timescale 1ns / 1ps

module switches(
    input clk, rst,
    input readEnable,
    input [15:0] switches,

    output reg [31:0] readData
);
    // Store switch values as individual bytes for byte-addressable access
    wire [7:0] sw_bytes [0:3];
    assign sw_bytes[0] = switches[7:0];
    assign sw_bytes[1] = switches[15:8];
    assign sw_bytes[2] = 8'b0;
    assign sw_bytes[3] = 8'b0;

    // On clock edge, assemble 4 bytes into 32-bit read output
    always @(posedge clk) begin
        if (rst)
            readData <= 32'b0;
        else if (readEnable)
            readData <= {sw_bytes[3],
                         sw_bytes[2],
                         sw_bytes[1],
                         sw_bytes[0]};
    end
endmodule