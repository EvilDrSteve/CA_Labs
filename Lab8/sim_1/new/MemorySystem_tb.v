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
        #3; // deassert reset mid-cycle, not on clock edge
        rst = 0;
        @(posedge clk);

        // ============================================================
        // TEST 1: Write to Data Memory (address[9:8] = 00)
        //   Stimulus set up mid-cycle so signals are stable before edge
        // ============================================================
        $display("--- TEST 1: Write to Data Memory ---");

        // Write 0xDEADBEEF to Data Memory address 0x00
        #3; // offset from clock edge
        address = 32'h00000000;
        writeData = 32'hDEADBEEF;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk); // write captured here
        #2;
        writeEnable = 0;

        // Write 0x12345678 to Data Memory address 0x04
        #3;
        address = 32'h00000004;
        writeData = 32'h12345678;
        writeEnable = 1;
        @(posedge clk);
        #2;
        writeEnable = 0;

        // Write 0xCAFEBABE to Data Memory address 0x08
        #3;
        address = 32'h00000008;
        writeData = 32'hCAFEBABE;
        writeEnable = 1;
        @(posedge clk);
        #2;
        writeEnable = 0;

        @(posedge clk);

        // ============================================================
        // TEST 2: Read from Data Memory (address[9:8] = 00)
        //   Combinational read - data available after address settles
        // ============================================================
        $display("--- TEST 2: Read from Data Memory ---");

        #3;
        address = 32'h00000000;
        readEnable = 1;
        writeEnable = 0;
        #2;
        $display("Read DM addr 0x00: readData = %h (expected DEADBEEF)", readData);

        #3;
        address = 32'h00000004;
        #2;
        $display("Read DM addr 0x04: readData = %h (expected 12345678)", readData);

        #3;
        address = 32'h00000008;
        #2;
        $display("Read DM addr 0x08: readData = %h (expected CAFEBABE)", readData);

        readEnable = 0;
        @(posedge clk);

        // ============================================================
        // TEST 3: Write to LEDs (address[9:8] = 01)
        //   0x100 = 256 decimal, address[9:8] = 01
        // ============================================================
        $display("--- TEST 3: Write to LEDs ---");

        // Write 0x0000ABCD to LEDs
        #3;
        address = 32'h00000100;
        writeData = 32'h0000ABCD;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk); // LED registers capture here
        #2;
        writeEnable = 0;
        $display("LEDs output: %h (expected ABCD)", leds);

        // Write a different value to LEDs
        #3;
        address = 32'h00000100;
        writeData = 32'h0000F0F0;
        writeEnable = 1;
        @(posedge clk);
        #2;
        writeEnable = 0;
        $display("LEDs output: %h (expected F0F0)", leds);

        @(posedge clk);

        // ============================================================
        // TEST 4: Read from Switches (address[9:8] = 10)
        //   0x200 = 512 decimal, address[9:8] = 10
        // ============================================================
        $display("--- TEST 4: Read from Switches ---");

        #3;
        switches = 16'hA5A5;
        address = 32'h00000200;
        readEnable = 1;
        writeEnable = 0;
        @(posedge clk); // switch module registers on this edge
        #2;
        $display("Read Switches: readData = %h (expected 0000A5A5)", readData);

        #3;
        switches = 16'h1234;
        @(posedge clk);
        #2;
        $display("Read Switches: readData = %h (expected 00001234)", readData);

        readEnable = 0;
        @(posedge clk);

        // ============================================================
        // TEST 5: Verify no cross-talk between devices
        // ============================================================
        $display("--- TEST 5: Verify no cross-talk between devices ---");

        // Read DM addr 0x00 - should still be DEADBEEF
        #3;
        address = 32'h00000000;
        readEnable = 1;
        writeEnable = 0;
        #2;
        $display("DM addr 0x00 after LED write: readData = %h (expected DEADBEEF)", readData);

        readEnable = 0;
        @(posedge clk);

        // Write to Data Memory should NOT affect LEDs
        #3;
        address = 32'h00000010;
        writeData = 32'hFFFFFFFF;
        writeEnable = 1;
        @(posedge clk);
        #2;
        writeEnable = 0;
        $display("LEDs after DM write: %h (expected F0F0, unchanged)", leds);

        @(posedge clk);

        // ============================================================
        // TEST 6: Reset behavior
        // ============================================================
        $display("--- TEST 6: Reset behavior ---");

        #3;
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        #2;
        $display("LEDs after reset: %h (expected 0000)", leds);

        #3;
        rst = 0;
        @(posedge clk);

        // ============================================================
        // TEST 7: Write and Reset asserted simultaneously
        //   Reset should take priority - write should NOT go through
        // ============================================================
        $display("--- TEST 7: Write during reset (reset priority) ---");

        // First write a known value to DM addr 0x10
        #3;
        address = 32'h00000010;
        writeData = 32'hAAAAAAAA;
        writeEnable = 1;
        rst = 0;
        @(posedge clk);
        #2;
        writeEnable = 0;

        // Verify it was written
        #3;
        address = 32'h00000010;
        readEnable = 1;
        #2;
        $display("DM addr 0x10 before reset-write: readData = %h (expected AAAAAAAA)", readData);
        readEnable = 0;

        // Now try writing a NEW value while reset is also high
        #3;
        address = 32'h00000010;
        writeData = 32'hBBBBBBBB;
        writeEnable = 1;
        rst = 1;  // reset AND write at the same time
        @(posedge clk);
        #2;
        writeEnable = 0;
        rst = 0;
        $display("LEDs after reset+write: %h (expected 0000, reset wins)", leds);

        // Read DM addr 0x10 - check if write went through or reset blocked it
        @(posedge clk);
        #3;
        address = 32'h00000010;
        readEnable = 1;
        #2;
        $display("DM addr 0x10 after reset+write: readData = %h", readData);
        $display("  (If 00000000: reset blocked the write)");
        $display("  (If BBBBBBBB: write went through despite reset)");
        readEnable = 0;

        // ============================================================
        // TEST 8: Write to LEDs during reset
        //   LEDs should stay cleared, not show the written value
        // ============================================================
        $display("--- TEST 8: LED write during reset ---");

        // Write to LEDs with reset high
        #3;
        address = 32'h00000100;
        writeData = 32'h0000FFFF;
        writeEnable = 1;
        rst = 1;
        @(posedge clk);
        #2;
        writeEnable = 0;
        $display("LEDs during reset+write: %h (expected 0000, reset wins)", leds);

        // Release reset and check LEDs stayed cleared
        #3;
        rst = 0;
        @(posedge clk);
        #2;
        $display("LEDs after releasing reset: %h (expected 0000)", leds);

        // ============================================================
        $display("--- ALL TESTS COMPLETE ---");
        $finish;
    end

endmodule