`timescale 1ns / 1ps

module tb_PipelinedBubbleSort;

    reg clk, reset;

    PipelinedProcessor uut(.clk(clk), .reset(reset));

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        // Initialize stack pointer
        uut.u_regFile.regs[2] = 32'd252;

        reset = 1;
        #20;
        reset = 0;

        // Run long enough for bubble sort to complete
        #50000;

        // Array is at address 0x200 = word address 128
        $display("=== Array After Sorting ===");
        for (i = 0; i < 11; i = i + 1)
            $display("  a[%0d] = %0d", i, uut.u_dmem.memory[i]);
        $display("");
        if (uut.u_dmem.memory[0] == 5 &&
            uut.u_dmem.memory[1] == 5 &&
            uut.u_dmem.memory[2] == 6 &&
            uut.u_dmem.memory[3] == 12 &&
            uut.u_dmem.memory[4] == 23 &&
            uut.u_dmem.memory[5] == 32 &&
            uut.u_dmem.memory[6] == 44 &&
            uut.u_dmem.memory[7] == 53 &&
            uut.u_dmem.memory[8] == 65 &&
            uut.u_dmem.memory[9] == 89 &&
            uut.u_dmem.memory[10] == 98)
            $display("*** PASS: Array correctly sorted! ***");
        else
            $display("*** FAIL: Array not correctly sorted ***");

        $finish;
    end

endmodule