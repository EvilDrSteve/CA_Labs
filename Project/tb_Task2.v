`timescale 1ns / 1ps

module tb_Task2();

    reg clk;
    reg reset;

    // Instantiate Top Level Processor
    TopLevelProcessor u_processor (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (10 time units period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation sequence
    initial begin
        // Standard waveform dump
        $dumpfile("tb_Task2.vcd");
        $dumpvars(0, tb_Task2);

        $display("--- Starting Task 2 Full Processor Simulation ---");
        
        // Assert reset for the first 10 ns
        reset = 1;
        #10;
        
        // De-assert reset to allow the processor to start executing program.hex
        reset = 0;

        // Give the processor some time to execute the instruction loaded from memory
        // 200 time units is equivalent to 20 clock cycles.
        #200; 
        
        $display("--- Simulation complete ---");
        $finish;
    end

endmodule
