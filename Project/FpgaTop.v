module FpgaTop(
    input clk,
    input reset,
    input [15:0] switches,
    input btnMode,          // one of the Basys3 buttons
    
    output [15:0] leds,
    output [3:0] displayPower,
    output [6:0] segments
);
    
    wire [31:0] currentInstruction;
    wire [31:0] pcOut;
    wire [31:0] dataToBeDisplayed;

    wire slowClk;
    clkDivider u_divider(.clkIn(clk), .reset(reset), .clkOut(slowClk));

    // Debounce the mode button
    wire btnClean;
    Debouncer u_debounce(.clk(clk), .pbIn(btnMode), .pbOut(btnClean));

    // Toggle mode on debounced pulse
    reg debugMode;
    always @(posedge clk or posedge reset) begin
        if (reset)
            debugMode <= 1'b1;
        else if (btnClean)
            debugMode <= ~debugMode;
    end
    // Debug mode: processor sees 0. Run mode: processor gets all 16 switches.
    wire [15:0] processorSwitches = debugMode ? 16'b0 : switches;

    wire processorClk = slowClk & ~(debugMode & switches[15]);  
    wire [15:0] ledsOut;  
    TopLevelProcessor u_topLevelProcessor(
        .clk(processorClk),
        .reset(reset),
        .switchesIn(processorSwitches),

        .currentInstruction(currentInstruction),
        .pcOut(pcOut),
        .ledsOut(ledsOut)
    );
    assign leds = {debugMode, ledsOut[14:0]};
    Mux2 u_muxInstructionOrPcOut (
        .d0(currentInstruction),
        .d1(pcOut),
        .sel(switches[0]),
        .y(dataToBeDisplayed)
    );

    SevenSegmentDriver u_sevenSegmentDriver(
        .clk(clk),
        .reset(reset),
        .hexData(switches[1] ? dataToBeDisplayed[31:16] : dataToBeDisplayed[15:0]),

        .displayPower(displayPower),
        .segments(segments)
    );

endmodule