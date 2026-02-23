`timescale 1ns / 1ps

module top_lab6(
    input clk, btn_reset,
    input [15:0] sw,
    output reg [3:0] displayPower,
    output [6:0] segments,
    output [15:0] leds
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

    wire [31:0] Result;
    wire zero;
    ALU alu(
        .A(32'h10101010),
        .B(32'h01010101),
        .ALUControl(sw_readData[6:3]),
        .ALUResult(Result),
        .zero(zero)
    );

    assign leds[15] = zero;
    assign leds[14:0] = 15'b0;

    reg [18:0] refresh_counter;
    wire [1:0] digit_sel;
    reg [3:0] current_nibble;

    always @(posedge clk or posedge clean_reset) begin
        if (clean_reset)
            refresh_counter <= 19'b0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    // sw[4] selects upper or lower 16 bits
    wire [15:0] display_val = sw_readData[6] ? Result[31:16] : Result[15:0];

    always @(*) begin
        case (refresh_counter[18:17])
            2'b00: begin displayPower = 4'b1110; current_nibble = display_val[3:0];   end
            2'b01: begin displayPower = 4'b1101; current_nibble = display_val[7:4];   end
            2'b10: begin displayPower = 4'b1011; current_nibble = display_val[11:8];  end
            2'b11: begin displayPower = 4'b0111; current_nibble = display_val[15:12]; end
        endcase
    end

    // Single seven segment decoder
    SevenSegmentDecoder seg_dec(
        .D(current_nibble),
        .S(segments)
    );

endmodule