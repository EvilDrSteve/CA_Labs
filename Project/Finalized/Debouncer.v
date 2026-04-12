`timescale 1ns / 1ps

// debouncer — Debounces a mechanical push-button input.
// Uses a two-stage synchronizer, a slow sampling clock, and a
// 3-sample shift register to filter glitches. Outputs a single
// one-clock-cycle pulse on the rising edge of a stable press.
module Debouncer(
    input wire  clk,
    input wire  pbIn,   // raw push-button input
    output wire pbOut   // debounced one-cycle pulse
);

    // Stage 1: Two-flip-flop synchronizer to avoid metastability
    reg sync0, sync1;
    always @(posedge clk) begin
        sync0 <= pbIn;
        sync1 <= sync0;
    end

    // Stage 2: Clock divider — generates a sample enable pulse
    // every 250,000 clock cycles (~2.5 ms at 100 MHz)
    reg [29:0] divider = 0;
    reg sampleEn = 0;
    always @(posedge clk) begin
        if (divider >= 249999) begin
            divider  <= 0;
            sampleEn <= 1;
        end else begin
            divider  <= divider + 1;
            sampleEn <= 0;
        end
    end

    // Stage 3: Shift register — captures 3 consecutive samples.
    // Input is considered stable-high only when all 3 bits are 1.
    reg [2:0] shiftReg = 0;
    always @(posedge clk) begin
        if (sampleEn)
            shiftReg <= {shiftReg[1:0], sync1};
    end

    wire stableHigh = &shiftReg; // all three samples are 1

    // Stage 4: Rising-edge detector — output a one-cycle pulse
    reg prevStable = 0;
    always @(posedge clk)
        prevStable <= stableHigh;

    assign pbOut = stableHigh & ~prevStable;

endmodule
