`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2026 10:54:51
// Design Name: 
// Module Name: FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FSM(
    input clk, reset,
    input [31:0] switches,
    
    output [31:0] leds
    );
    
    reg state = 1'b0;
    reg [15:0] latched_value = 0;
    wire [15:0] counter;
    reg load;
        
    downCounter c(clk, reset, state, load, latched_value, counter);
    
    assign leds = (state == 1'b1) ? counter : 32'b0;

    always@(posedge clk) begin
        //Reset
        if(reset) begin
            state <= 1'b0;
            load <= 1'b0;
            latched_value <= 0;
        end
        //IDLE state
        else if(state == 1'b0) begin
            if(switches > 0) begin
                state <= 1'b1;
                latched_value <= switches;
                load <= 1'b1;
            end
        end
        //Countdown state
        else if(state == 1'b1) begin
            load <= 1'b0;
            if(counter == 0) begin
                state <= 1'b0;
            end
        end
    end
endmodule
