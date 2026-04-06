module downCounter(
    input clk, reset, enable, load,
    input [15:0] value,
    
    output reg [15:0] counter
    );
    
    reg [3:0] slow_counter = 0;
    wire slow_tick = (slow_counter == 0);
    
    always @(posedge clk) begin
        if (reset)
            slow_counter <= 0;
        else
            slow_counter <= slow_counter + 1;
    end
    
    always @(posedge clk) begin
        if(reset) counter <= 0;
        else if(load) counter <= value;
        else if(enable && counter > 0 && slow_tick)
            counter <= counter - 1;
    end
endmodule