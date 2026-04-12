`timescale 1ns / 1ps

// tb_Task2 — Full processor integration testbench.
// Instantiates the TopLevelProcessor, applies reset, then lets
// the processor execute the program loaded from program.hex.
module tb_Task2();

    reg clk;
    reg reset;

    // Instantiate the full processor
    TopLevelProcessor u_processor (
        .clk(clk),
        .reset(reset)
    );

    // Clock: 10 time-unit period (100 MHz equivalent)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation sequence
    initial begin
        $dumpfile("tb_Task2.vcd");
        $dumpvars(0, tb_Task2);

        $display("--- Starting Task 2 Full Processor Simulation ---");
        $monitor("PC=%h | nextPC=%h | instr=%h | pcSrc=%b | jump=%b",
          u_processor.pcOut,
          u_processor.nextPc,
          u_processor.instruction,
          u_processor.pcSrc,
          u_processor.jump);
$monitor("WB CHECK: memToReg=%b memReadData=%h alu=%h wb=%h",
    tb_Task2.u_processor.memToReg,
    tb_Task2.u_processor.memReadData,
    tb_Task2.u_processor.aluResult,
    tb_Task2.u_processor.writeBackData
);
        // Hold reset for 10 ns
        reset = 1;
        #10;

        // Release reset — processor begins executing from PC = 0
        reset = 0;

        // Run for 20 clock cycles (200 ns) to observe execution
        #3000;
        $display("--- Simulation complete ---");
        $finish;
        
    end

endmodule
