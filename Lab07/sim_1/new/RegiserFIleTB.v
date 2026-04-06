`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2026 07:42:37 AM
// Design Name: 
// Module Name: RegiserFIleTB
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


module RegisterFile_tb(); 
    reg clk, rst, WriteEnable;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] readData1, readData2;

    RegisterFile uut (
        .clk(clk), .rst(rst), .WriteEnable(WriteEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .readData1(readData1), .readData2(readData2)
    );
// Expose all 32 registers for waveform viewing
    wire [31:0] r0  = uut.regs[0];
    wire [31:0] r1  = uut.regs[1];
    wire [31:0] r2  = uut.regs[2];
    wire [31:0] r3  = uut.regs[3];
    wire [31:0] r4  = uut.regs[4];
    wire [31:0] r5  = uut.regs[5];
    wire [31:0] r6  = uut.regs[6];
    wire [31:0] r7  = uut.regs[7];
    wire [31:0] r8  = uut.regs[8];
    wire [31:0] r9  = uut.regs[9];
    wire [31:0] r10 = uut.regs[10];
    wire [31:0] r11 = uut.regs[11];
    wire [31:0] r12 = uut.regs[12];
    wire [31:0] r13 = uut.regs[13];
    wire [31:0] r14 = uut.regs[14];
    wire [31:0] r15 = uut.regs[15];
    wire [31:0] r16 = uut.regs[16];
    wire [31:0] r17 = uut.regs[17];
    wire [31:0] r18 = uut.regs[18];
    wire [31:0] r19 = uut.regs[19];
    wire [31:0] r20 = uut.regs[20];
    wire [31:0] r21 = uut.regs[21];
    wire [31:0] r22 = uut.regs[22];
    wire [31:0] r23 = uut.regs[23];
    wire [31:0] r24 = uut.regs[24];
    wire [31:0] r25 = uut.regs[25];
    wire [31:0] r26 = uut.regs[26];
    wire [31:0] r27 = uut.regs[27];
    wire [31:0] r28 = uut.regs[28];
    wire [31:0] r29 = uut.regs[29];
    wire [31:0] r30 = uut.regs[30];
    wire [31:0] r31 = uut.regs[31];
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Initialize
        clk = 0; rst = 1; WriteEnable = 0; 
        rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        #10 rst = 0;

        // Test i: Write to a register (x5 = 0xDEADBEEF) [cite: 37]
        rd = 5; WriteData = 32'hDEADBEEF; WriteEnable = 1;
        #10 WriteEnable = 0; rs1 = 5; // Read it back
        #10 $display("Test i (Write x5): readData1 = %h", readData1);

        // Test ii: Attempt to write to x0 [cite: 38]
        rd = 0; WriteData = 32'hFFFFFFFF; WriteEnable = 1;
        #10 WriteEnable = 0; rs1 = 0;
        #10 $display("Test ii (Write x0): readData1 = %h (Should be 0)", readData1);

        // Test iii: Simultaneous reads [cite: 39]
        // First write to x6
        rd = 6; WriteData = 32'hCAFEBABE; WriteEnable = 1;
        #10 WriteEnable = 0;
        rs1 = 5; rs2 = 6; // Read x5 and x6 together
        #10 $display("Test iii (Simultaneous Read): readData1 (x5) = %h, readData2 (x6) = %h", readData1, readData2);

        // Test iv: Overwrite a register [cite: 40]
        rd = 5; WriteData = 32'h12345678; WriteEnable = 1;
        #10 WriteEnable = 0; rs1 = 5;
        #10 $display("Test iv (Overwrite x5): readData1 = %h", readData1);

        // Test v: Reset behavior [cite: 41]
        rst = 1; 
        #10 rst = 0; rs1 = 5; rs2 = 6;
        #10 $display("Test v (Reset): readData1 = %h, readData2 = %h", readData1, readData2);

        $finish;
    end
endmodule
