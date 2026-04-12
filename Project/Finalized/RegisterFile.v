`timescale 1ns / 1ps

// RegisterFile — 32x32-bit RISC-V register file.
// Two async read ports (rs1, rs2) and one sync write port (rd).
// Register x0 is hardwired to zero — reads always return 0,
// writes to x0 are ignored.
module RegisterFile(
    input wire         clk,
    input wire         rst,
    input wire         writeEnable,     // register write enable
    input wire [4:0]   rs1,             // source register 1 address
    input wire [4:0]   rs2,             // source register 2 address
    input wire [4:0]   rd,              // destination register address
    input wire [31:0]  writeData,       // data to write to rd
    output wire [31:0] readData1,       // data from rs1
    output wire [31:0] readData2        // data from rs2
);

    reg [31:0] regs [31:0]; // 32 registers, each 32 bits

    // Async reads — x0 always returns 0
    assign readData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign readData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    integer i;

    // Sync write with reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (writeEnable && rd != 5'b0) begin
            regs[rd] <= writeData;
        end
    end
always @(posedge clk) begin
    if (writeEnable) begin
        $display("REG WRITE: x%0d = %h", rd, writeData);
    end
end
endmodule
