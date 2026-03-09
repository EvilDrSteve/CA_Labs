`timescale 1ns / 1ps

module MemorySystem_tb;

    // Inputs
    reg clk, rst;
    reg [31:0] address;
    reg readEnable, writeEnable;
    reg [31:0] writeData;
    reg [15:0] switches;

    // Outputs
    wire [31:0] readData;
    wire [15:0] leds;

    // Instantiate the Unit Under Test (UUT)
    AddressDecoderTOP uut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(switches),
        .readData(readData),
        .leds(leds)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize all inputs
        rst = 1;
        address = 32'b0;
        readEnable = 0;
        writeEnable = 0;
        writeData = 32'b0;
        switches = 16'b0;

        // Hold reset for a few cycles
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        // ============================================================
        // TEST 1: Write to Data Memory (address[9:8] = 00)
        // ============================================================
        $display("--- TEST 1: Write to Data Memory ---");

        // Write 0xDEADBEEF to Data Memory address 0x00
        address = 32'h00000000;
        writeData = 32'hDEADBEEF;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk);
        writeEnable = 0;
        @(posedge clk);

        // Write 0x12345678 to Data Memory address 0x04
        address = 32'h00000004;
        writeData = 32'h12345678;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;
        @(posedge clk);

        // Write 0xCAFEBABE to Data Memory address 0x08
        address = 32'h00000008;
        writeData = 32'hCAFEBABE;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;
        @(posedge clk);

        // ============================================================
        // TEST 2: Read from Data Memory (address[9:8] = 00)
        // ============================================================
        $display("--- TEST 2: Read from Data Memory ---");

        // Read from Data Memory address 0x00 - expect 0xDEADBEEF
        address = 32'h00000000;
        readEnable = 1;
        writeEnable = 0;
        #1;
        $display("Read DM addr 0x00: readData = %h (expected DEADBEEF)", readData);

        // Read from Data Memory address 0x04 - expect 0x12345678
        address = 32'h00000004;
        #1;
        $display("Read DM addr 0x04: readData = %h (expected 12345678)", readData);

        // Read from Data Memory address 0x08 - expect 0xCAFEBABE
        address = 32'h00000008;
        #1;
        $display("Read DM addr 0x08: readData = %h (expected CAFEBABE)", readData);

        readEnable = 0;
        @(posedge clk);

        // ============================================================
        // TEST 3: Write to LEDs (address[9:8] = 01)
        //   0x100 = 256 decimal = 01_00000000 binary
        //   address[9:8] = 01
        // ============================================================
        $display("--- TEST 3: Write to LEDs ---");

        // Write 0x0000ABCD to LEDs
        address = 32'h00000100;   // address[9:8] = 01
        writeData = 32'h0000ABCD;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk);
        writeEnable = 0;
        #1;
        $display("LEDs output: %h (expected ABCD)", leds);

        @(posedge clk);

        // Write a different value to LEDs
        address = 32'h00000100;
        writeData = 32'h0000F0F0;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;
        #1;
        $display("LEDs output: %h (expected F0F0)", leds);

        @(posedge clk);

        // ============================================================
        // TEST 4: Read from Switches (address[9:8] = 10)
        //   0x200 = 512 decimal = 10_00000000 binary
        //   address[9:8] = 10
        // ============================================================
        $display("--- TEST 4: Read from Switches ---");

        // Set switch values and read them
        switches = 16'hA5A5;
        address = 32'h00000200;   // address[9:8] = 10
        readEnable = 1;
        writeEnable = 0;
        @(posedge clk);
        #1;
        $display("Read Switches: readData = %h (expected 0000A5A5)", readData);

        // Change switch values
        switches = 16'h1234;
        @(posedge clk);
        #1;
        $display("Read Switches: readData = %h (expected 00001234)", readData);

        readEnable = 0;
        @(posedge clk);

        // ============================================================
        // TEST 5: Verify address decoder enables only correct module
        // ============================================================
        $display("--- TEST 5: Verify no cross-talk between devices ---");

        // Read DM addr 0x00 to confirm it still has DEADBEEF
        address = 32'h00000000;
        readEnable = 1;
        writeEnable = 0;
        #1;
        $display("DM addr 0x00 after LED write: readData = %h (expected DEADBEEF)", readData);

        readEnable = 0;
        @(posedge clk);

        // Write to Data Memory should NOT affect LEDs
        address = 32'h00000010;
        writeData = 32'hFFFFFFFF;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;
        #1;
        $display("LEDs after DM write: %h (expected F0F0, unchanged)", leds);

        @(posedge clk);

        // ============================================================
        // TEST 6: Reset behavior
        // ============================================================
        $display("--- TEST 6: Reset behavior ---");

        rst = 1;
        @(posedge clk);
        @(posedge clk);
        #1;
        $display("LEDs after reset: %h (expected 0000)", leds);

        rst = 0;
        @(posedge clk);

        // ============================================================
        $display("--- ALL TESTS COMPLETE ---");
        $finish;
    end

endmodule