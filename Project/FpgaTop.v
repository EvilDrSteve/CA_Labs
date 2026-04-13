`timescale 1ns / 1ps

module FpgaTop(
    input clk,
    input reset,
    input [15:0] switches,
    input btnMode,
    
    output [15:0] leds,
    output [3:0] displayPower,
    output [6:0] segments
);
    
    wire [31:0] currentInstruction;
    wire [31:0] pcOut;
    wire [15:0] ledsOut;

    wire slowClk;
    clkDivider u_divider(.clkIn(clk), .reset(reset), .clkOut(slowClk));

    // Debounce mode button
    wire btnClean;
    Debouncer u_debounce(.clk(clk), .pbIn(btnMode), .pbOut(btnClean));

    // Toggle debug/run mode
    reg debugMode;
    always @(posedge clk or posedge reset) begin
        if (reset)
            debugMode <= 1'b1;
        else if (btnClean)
            debugMode <= ~debugMode;
    end

    // Pause in debug mode: switches[15] ON = frozen
    wire processorClk = slowClk & ~(debugMode & switches[15]);

    // Debug mode: processor sees 0. Run mode: all switches pass through.
    wire [15:0] processorSwitches = debugMode ? 16'b0 : switches;

    TopLevelProcessor u_topLevelProcessor(
        .clk(processorClk),
        .reset(reset),
        .switchesIn(processorSwitches),
        .currentInstruction(currentInstruction),
        .pcOut(pcOut),
        .ledsOut(ledsOut)
    );

    // LED output: leds[15] = mode indicator, others are output leds from processor
    assign leds = {debugMode, ledsOut[14:0]};

    // Latch debug switch settings — update live in debug mode, freeze in run mode
    reg dbgSel0, dbgSel1, dbgSel2;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dbgSel0 <= 0;
            dbgSel1 <= 0;
            dbgSel2 <= 0;
        end else if (debugMode) begin
            dbgSel0 <= switches[0];
            dbgSel1 <= switches[1];
            dbgSel2 <= switches[2];
        end
    end

    // Display select (debug switches, latched):
    //   dbgSel0: 0 = instruction,      1 = PC
    //   dbgSel1: 0 = lower 16 bits,    1 = upper 16 bits
    //   dbgSel2: 0 = instruction/PC,   1 = LED output
    wire [31:0] instrOrPc;
    Mux2 u_muxInstructionOrPcOut (
        .d0(currentInstruction),
        .d1(pcOut),
        .sel(dbgSel0),
        .y(instrOrPc)
    );
    // BCD conversion of LED output
    wire [3:0] bcdTh, bcdH, bcdT, bcdO;
    BinaryToBCD u_bcd(
        .bin(ledsOut),
        .thousands(bcdTh),
        .hundreds(bcdH),
        .tens(bcdT),
        .ones(bcdO)
    );
    wire [15:0] ledsDecimal = {bcdTh, bcdH, bcdT, bcdO};

    wire [31:0] displaySource = dbgSel2 ? {16'b0, ledsDecimal} : instrOrPc;

    SevenSegmentDriver u_sevenSegmentDriver(
        .clk(clk),
        .reset(reset),
        .hexData(dbgSel1 ? displaySource[31:16] : displaySource[15:0]),
        .displayPower(displayPower),
        .segments(segments)
    );

endmodule