module top(
    input clk,
    input btn_reset,
    input [15:0] sw,
    output [15:0] led
);
    wire clean_reset;
    debouncer db(
        .clk(clk),
        .pbin(btn_reset),
        .pbout(clean_reset)
    );

    wire [31:0] sw_readData;
    switches sw_inst(
        .clk(clk),
        .rst(clean_reset),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .switches(sw),
        .readData(sw_readData)
    );

    wire [31:0] fsm_leds;

    FSM fsm_inst(
        .clk(clk),
        .reset(clean_reset),
        .switches(sw_readData),
        .leds(fsm_leds)
    );

    // Just to confirm - this should fail
    leds led_inst(
        .clk(clk),
        .rst(clean_reset),
        .writeData(fsm_leds),
        .writeEnable(1'b1),
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),
        .leds(led)
    );
endmodule