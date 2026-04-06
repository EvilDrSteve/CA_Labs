`timescale 1ns / 1ps

module debouncer(
    input clk,
    input pbin,
    output pbout
);
    // Two-stage synchronizer to avoid metastability
    reg sync_0, sync_1;
    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;
    end

    // Slow sampling clock using counter
    reg [29:0] divider = 0;
    reg sample_en = 0;
    always @(posedge clk) begin
        if (divider >= 249999) begin
            divider <= 0;
            sample_en <= 1;
        end else begin
            divider <= divider + 1;
            sample_en <= 0;
        end
    end

    // Shift register to check stable input over 3 sample periods
    reg [2:0] shift_reg = 0;
    always @(posedge clk) begin
        if (sample_en)
            shift_reg <= {shift_reg[1:0], sync_1};
    end

    wire stable_high = &shift_reg;  // all three samples are 1

    // Edge detector: output one-cycle pulse on rising edge
    reg prev_stable = 0;
    always @(posedge clk)
        prev_stable <= stable_high;

    assign pbout = stable_high & ~prev_stable;
endmodule