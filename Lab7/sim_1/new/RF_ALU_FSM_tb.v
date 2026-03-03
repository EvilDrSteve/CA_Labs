`timescale 1ns / 1ps

module RF_ALU_FSM_tb();

    reg clk, rst;
    reg [4:0] rs1, rs2;

    FSM_Lab7 uut(
        .clk(clk), .rst(rst),
        .rs1(rs1), .rs2(rs2)
    );

    always #5 clk = ~clk;

    // Expose all registers for waveform
    wire [31:0] r0  = uut.registers.regs[0];
    wire [31:0] r1  = uut.registers.regs[1];
    wire [31:0] r2  = uut.registers.regs[2];
    wire [31:0] r3  = uut.registers.regs[3];
    wire [31:0] r4  = uut.registers.regs[4];
    wire [31:0] r5  = uut.registers.regs[5];
    wire [31:0] r6  = uut.registers.regs[6];
    wire [31:0] r7  = uut.registers.regs[7];
    wire [31:0] r8  = uut.registers.regs[8];
    wire [31:0] r9  = uut.registers.regs[9];
    wire [31:0] r10 = uut.registers.regs[10];
    wire [31:0] r11 = uut.registers.regs[11];
    wire [31:0] r12 = uut.registers.regs[12];

    // Expose FSM internals
    wire [2:0]  state     = uut.state;
    wire [3:0]  op_count  = uut.op_count;
    wire [31:0] rd1       = uut.readData1;
    wire [31:0] rd2       = uut.readData2;
    wire [31:0] aluRes    = uut.ALUResult;
    wire        aluZero   = uut.ALUZero;
    wire        we        = uut.writeEnable;
    wire [4:0]  rd_val    = uut.rd;
    wire [31:0] wd        = uut.writeData;
    wire [3:0]  aluCtrl   = uut.ALUControl;

    initial begin
        clk = 0; rst = 1;
        rs1 = 5'd0; rs2 = 5'd0;

        #15 rst = 0;

        // === (i) WRITE_INIT: write x1, x2, x3 ===
        // rs1/rs2 don't matter during init
        @(posedge clk); // IDLE -> WRITE_INIT
        @(posedge clk); // op_count=0: write x1
        @(posedge clk); // op_count=1: write x2
        @(posedge clk); // op_count=2: write x3 -> READ_REGISTERS
        #1;
        $display("\n=== (i) INITIAL REGISTER WRITES ===");
        $display("x1 = %h (expect 10101010)", r1);
        $display("x2 = %h (expect 01010101)", r2);
        $display("x3 = %h (expect 00000005)", r3);

        // === (ii) ALU operations: testbench drives rs1=x1, rs2=x2 ===
        rs1 = 5'd1; rs2 = 5'd2;

        // op0: ADD -> x4
        @(posedge clk); // READ_REGISTERS
        @(posedge clk); // ALU_OPERATION
        @(posedge clk); // WRITE_REGISTERS
        #1;
        $display("\n=== (ii) ALU OPERATIONS (rs1=x1, rs2=x2) ===");
        $display("[op0 ADD]  x4  = %h (expect 11111111)", r4);

        // op1: SUB -> x5
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op1 SUB]  x5  = %h (expect 0F0F0F0F)", r5);

        // op2: AND -> x6
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op2 AND]  x6  = %h (expect 00000000)", r6);

        // op3: OR -> x7
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op3 OR]   x7  = %h (expect 11111111)", r7);

        // op4: XOR -> x8
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op4 XOR]  x8  = %h (expect 11111111)", r8);

        // op5: SLL -> x9
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op5 SLL]  x9  = %h", r9);

        // op6: SRL -> x10
        @(posedge clk); @(posedge clk); @(posedge clk);
        #1;
        $display("[op6 SRL]  x10 = %h", r10);

        // === (iii) BEQ: change rs2 to x1 so both operands are equal ===
        rs2 = 5'd1;  // now rs1=x1, rs2=x1 -> SUB gives 0 -> Zero=1

        // op7: BEQ -> x11
        @(posedge clk); // READ_REGISTERS
        @(posedge clk); // ALU_OPERATION
        @(posedge clk); // WRITE_REGISTERS
        #1;
        $display("\n=== (iii) BEQ CHECK (rs1=x1, rs2=x1) ===");
        $display("[op7 BEQ]  Zero = %b (expect 1)", aluZero);
        $display("           x11  = %h (expect BEEF0000)", r11);

        // === (iv) Write-then-read test ===
        // op8: write x12 = ABCD1234
        rs1 = 5'd12; rs2 = 5'd0;

        @(posedge clk); // READ_REGISTERS
        @(posedge clk); // ALU_OPERATION
        @(posedge clk); // WRITE_REGISTERS (writes x12)
        #1;
        $display("\n=== (iv) READ-AFTER-WRITE TEST ===");
        $display("x12 written = %h (expect ABCD1234)", r12);

        // READ_AFTER_WRITE state: rs1 already set to x12
        @(posedge clk);
        #1;
        $display("readData1 (rs1=x12, next cycle) = %h (expect ABCD1234)", rd1);

        // DONE
        @(posedge clk);
        #1;
        $display("\nFSM state = %d (expect 6 = DONE)", state);

        // === Final register dump ===
        #20;
        $display("\n============ FINAL REGISTER STATE ============");
        $display("x0  = %h  (hardwired 0)",     r0);
        $display("x1  = %h  (0x10101010)",       r1);
        $display("x2  = %h  (0x01010101)",       r2);
        $display("x3  = %h  (0x00000005)",       r3);
        $display("x4  = %h  (ADD: x1 + x2)",    r4);
        $display("x5  = %h  (SUB: x1 - x2)",    r5);
        $display("x6  = %h  (AND: x1 & x2)",    r6);
        $display("x7  = %h  (OR:  x1 | x2)",    r7);
        $display("x8  = %h  (XOR: x1 ^ x2)",    r8);
        $display("x9  = %h  (SLL: x1 << x2)",   r9);
        $display("x10 = %h  (SRL: x1 >> x2)",   r10);
        $display("x11 = %h  (BEQ flag)",         r11);
        $display("x12 = %h  (read-after-write)", r12);
        $display("==============================================\n");

        $finish;
    end

endmodule