`timescale 1ns / 1ps

// tb_PipelineDemo — Short showcase testbench for the video.
//
// Loads pipeline_demo.hex AFTER the InstructionMemory's own initial
// block runs, so you don't have to edit InstructionMemory.v's path.
//
// Wave layout suggestion (group these in this order):
//   1. Pipeline contents
//        clk, reset, pcOut,
//        instruction (IF), IF_ID_instruction (ID),
//        ID_EX_rd, ID_EX_aluOp, ID_EX_memRead,
//        EX_MEM_rd, EX_MEM_aluResult,
//        MEM_WB_rd, writeBackData
//   2. Hazard control
//        forwardA, forwardB, stall, mem_pcSrc
//   3. Result check
//        u_regFile.regs[1], regs[3], regs[4], regs[5],
//        regs[6], regs[7], regs[8], regs[9]
module tb_PipelineDemo;

    reg clk, reset;

    PipelinedProcessor uut(.clk(clk), .reset(reset));

    initial clk = 0;
    always #5 clk = ~clk;            // 100 MHz, period 10 ns

    // Override the program with the demo (runs after imem's initial block).
    initial begin
        #1;
        $readmemh("c:/Uni/CA_Labs/Project/pipeline_demo.hex",
                  uut.u_imem.memory);
    end

    initial begin
        $dumpfile("pipeline_demo.vcd");
        $dumpvars(0, tb_PipelineDemo);

        reset = 1;
        #20;
        reset = 0;

        #280;                        // ~28 cycles of execution

        $display("");
        $display("=== Final Register Values ===");
        $display("  x1 = %0d   (expect  5)",          uut.u_regFile.regs[1]);
        $display("  x2 = %0d   (expect 10)",          uut.u_regFile.regs[2]);
        $display("  x3 = %0d   (expect 15)",          uut.u_regFile.regs[3]);
        $display("  x4 = %0d   (expect 30)",          uut.u_regFile.regs[4]);
        $display("  x5 = %0d   (expect 30)",          uut.u_regFile.regs[5]);
        $display("  x6 = %0d   (expect 35, load-use)", uut.u_regFile.regs[6]);
        $display("  x7 = %0d   (expect  0, FLUSHED)", uut.u_regFile.regs[7]);
        $display("  x8 = %0d   (expect  0, FLUSHED)", uut.u_regFile.regs[8]);
        $display("  x9 = %0d   (expect 77)",          uut.u_regFile.regs[9]);
        $display("");

        if (uut.u_regFile.regs[1] == 5  &&
            uut.u_regFile.regs[2] == 10 &&
            uut.u_regFile.regs[3] == 15 &&
            uut.u_regFile.regs[4] == 30 &&
            uut.u_regFile.regs[5] == 30 &&
            uut.u_regFile.regs[6] == 35 &&
            uut.u_regFile.regs[7] == 0  &&
            uut.u_regFile.regs[8] == 0  &&
            uut.u_regFile.regs[9] == 77)
            $display("*** PASS: forwarding, stall and flush all worked ***");
        else
            $display("*** FAIL: see register dump above ***");

        $finish;
    end

endmodule
