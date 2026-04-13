module clkDivider(
    input wire clkIn,      // 100 MHz
    input wire reset,
    output reg clkOut       // slow clock
);
    reg [25:0] counter;      // 26 bits → 100M / 2^26 ≈ 1.5 Hz

    always @(posedge clkIn or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clkOut <= 0;
        end else begin
            if (counter == 26'd49_999_999) begin  // exactly 1 Hz
                counter <= 0;
                clkOut <= ~clkOut;
            end else
                counter <= counter + 1;
        end
    end
endmodule