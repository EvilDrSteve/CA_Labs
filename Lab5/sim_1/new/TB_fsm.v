`timescale 1ns / 1ps

module TB_fsb;
    reg clk, reset;
    reg [31:0] switches;
    wire [31:0] leds;

    FSM uut(
        .clk(clk),
        .reset(reset),
        .switches(switches),
        .leds(leds)
    );

    // 10ns clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        switches = 0;

        // Apply reset
        #10 reset = 1;
        #10 reset = 0;

        // Test 1: Switches = 0, should stay in IDLE
        #50;

        // Test 2: Set switches to 5
        switches = 5;
        #50;              // hold for 3 clock cycles
        switches = 0;
        #550;             // wait for countdown to finish

        // Test 3: Set switches to 3, then reset mid-countdown
        switches = 3;
        #10;
        switches = 0;
        #30;              // let it count a couple cycles
        reset = 1;
        #10;
        reset = 0;
        #50;

        $finish;
    end
endmodule