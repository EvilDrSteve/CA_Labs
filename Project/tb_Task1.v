`timescale 1ns / 1ps

module tb_Task1();

    // Testbench signals
    reg clk;
    reg reset;
    reg PCSrc;
    reg [31:0] inst;

    wire [31:0] pc_out;
    wire [31:0] pc_next_seq;
    wire [31:0] branch_target;
    wire [31:0] next_pc;
    wire [31:0] imm;

    // Instantiate modules
    ProgramCounter u_pc (
        .clk(clk),
        .reset(reset),
        .pc_in(next_pc),
        .pc_out(pc_out)
    );

    pcAdder u_pcAdder (
        .pc(pc_out),
        .pc_next(pc_next_seq)
    );

    immGen u_immGen (
        .inst(inst),
        .imm(imm)
    );

    branchAdder u_branchAdder (
        .pc(pc_out),
        .imm(imm),
        .branch_target(branch_target)
    );

    mux2 u_mux2 (
        .d0(pc_next_seq),
        .d1(branch_target),
        .sel(PCSrc),
        .y(next_pc)
    );

    // Clock generation: 10 time units period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Standard dumpfile and dumpvars
        $dumpfile("tb_Task1.vcd");
        $dumpvars(0, tb_Task1);

        // 1. Initialize
        $display("--- Starting Simulation ---");
        reset = 1;
        PCSrc = 0;
        inst = 32'h00000000;
        
        // Wait 10 time units, then release reset
        #10;
        reset = 0;
        
        // 2. Test PC incrementing sequentially
        $display("[%0t] Evaluating sequential PC increments (PCSrc = 0)", $time);
        #20; // 2 clock cycles pass (PC: 0 -> 4 -> 8)
        
        // 3. Test I-type Immediate
        // Expected PC before next edge: 8 (it will become 12 at t=35)
        // Mock Instruction: ADDI x1, x2, -15  -> imm = -15
        // Binary: 111111110001_00010_000_00001_0010011 = 32'hff110093
        inst = 32'hff110093;
        #10; // Advancing to next cycle. PC becomes 12.
        $display("[%0t] I-Type Test: PC = %0d. Expected Imm = -15, Got = %0d", $time, pc_out, $signed(imm));
        
        // 4. Test S-type Immediate
        // Expected PC before next edge: 12 (it will become 16 at t=45)
        // Mock Instruction: SW x1, 16(x2) -> imm = 16
        // Binary: 0000000_00001_00010_010_10000_0100011 = 32'h00112823
        inst = 32'h00112823;
        #10; // Advancing to next cycle. PC becomes 16.
        $display("[%0t] S-Type Test: PC = %0d. Expected Imm = 16, Got = %0d", $time, pc_out, $signed(imm));
        
        // 5. Test B-type Immediate and Branching
        // Expected PC before next edge: 16 (it would become 20, but we branch!)
        // Mock Instruction: BEQ x1, x2, -8 -> branch offset = -8
        // The immGen should output -4 so that the branchAdder computes: 16 + (-4 << 1) = 8.
        // Binary: 1_111111_00010_00001_000_1100_1_1100011 = 32'hfe208ce3
        inst = 32'hfe208ce3;
        PCSrc = 1; // Take branch
        #10; 
        $display("[%0t] B-Type Test (Branch Taken): PC = %0d. Expected PC = 8. Expected Imm = -4, Got = %0d. Target = %0d", 
                 $time, pc_out, $signed(imm), branch_target);
        if (pc_out !== 32'd8) $display("    [ERROR] Branch missed! PC is %0d", pc_out);

        // 6. Return to sequential execution
        PCSrc = 0;
        #10;
        $display("[%0t] PC Sequential Again: PC = %0d. Expected PC = 12", $time, pc_out);

        // Simulation finish
        #10;
        $display("--- Simulation Finished ---");
        $finish;
    end

endmodule
