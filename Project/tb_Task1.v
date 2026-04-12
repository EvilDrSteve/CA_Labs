`timescale 1ns / 1ps

// tb_Task1 — Testbench for PC flow, immediate generation, and branching.
// Tests sequential PC increment, I-type/S-type/B-type immediate extraction,
// and branch target calculation.
module tb_Task1();

    reg         clk;
    reg         reset;
    reg         pcSrc;
    reg [31:0]  inst;

    wire [31:0] pcOut;
    wire [31:0] pcNextSeq;
    wire [31:0] branchTarget;
    wire [31:0] nextPc;
    wire [31:0] imm;

    // --- Module instances ---

    ProgramCounter u_pc (
        .clk(clk),
        .reset(reset),
        .pcIn(nextPc),
        .pcOut(pcOut)
    );

    PcAdder u_pcAdder (
        .pcIn(pcOut),
        .pcNext(pcNextSeq)
    );

    ImmGen u_immGen (
        .inst(inst),
        .imm(imm)
    );

    BranchAdder u_branchAdder (
        .pcIn(pcOut),
        .imm(imm),
        .branchTarget(branchTarget)
    );

    Mux2 u_mux2 (
        .d0(pcNextSeq),
        .d1(branchTarget),
        .sel(pcSrc),
        .y(nextPc)
    );

    // Clock: 10 time-unit period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $dumpfile("tb_Task1.vcd");
        $dumpvars(0, tb_Task1);

        // 1. Reset
        $display("--- Starting Simulation ---");
        reset = 1;
        pcSrc = 0;
        inst  = 32'h00000000;
        #10;
        reset = 0;

        // 2. Sequential PC increments: 0 → 4 → 8
        $display("[%0t] Evaluating sequential PC increments (pcSrc = 0)", $time);
        #20;

        // 3. I-type: ADDI x1, x2, -15 → imm should be -15
        inst = 32'hff110093;
        #10;
        $display("[%0t] I-Type Test: PC = %0d. Expected Imm = -15, Got = %0d", $time, pcOut, $signed(imm));

        // 4. S-type: SW x1, 16(x2) → imm should be 16
        inst = 32'h00112823;
        #10;
        $display("[%0t] S-Type Test: PC = %0d. Expected Imm = 16, Got = %0d", $time, pcOut, $signed(imm));

        // 5. B-type: BEQ x1, x2, -8 → branch to PC 8
        inst  = 32'hfe208ce3;
        pcSrc = 1;
        #10;
        $display("[%0t] B-Type Test (Branch Taken): PC = %0d. Expected PC = 8. Expected Imm = -4, Got = %0d. Target = %0d",
                 $time, pcOut, $signed(imm), branchTarget);
        if (pcOut !== 32'd8) $display("    [ERROR] Branch missed! PC is %0d", pcOut);

        // 6. Resume sequential
        pcSrc = 0;
        #10;
        $display("[%0t] PC Sequential Again: PC = %0d. Expected PC = 12", $time, pcOut);

        #10;
        $display("--- Simulation Finished ---");
        $finish;
    end

endmodule
