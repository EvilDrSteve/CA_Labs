`timescale 1ns / 1ps

module ControlPath_tb;
    // Main Control Signals
    reg [6:0] opcode;
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;

    // ALU Control Signals
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [3:0] ALUControl;

    // Instantiate Main Control
    MainControl u_MainControl (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );

    // Instantiate ALU Control
    ALU_Control u_ALUControl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    initial begin
        // For waveform generation, dump all variables
        $dumpfile("control_path.vcd");
        $dumpvars(0, ControlPath_tb);

        $display("Time | Instruction | opcode  | f3  | f7      || RegW | ALUOp | MemR | MemW | ALUSrc | Mem2Reg | Branch || ALUControl");
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        
        // === Required Instructions: ADD, ADDI, SUB, SLL, SRL, AND, OR, XOR, LW, LH, LB, SW, SH, SB, BEQ === //

        // --- R-type --- (ADD, SUB, SLL, SRL, AND, OR, XOR)
        opcode = 7'b0110011; 
        funct3 = 3'b000; funct7 = 7'b0000000; #10 print_signals("ADD");
        funct3 = 3'b000; funct7 = 7'b0100000; #10 print_signals("SUB");
        funct3 = 3'b001; funct7 = 7'b0000000; #10 print_signals("SLL");
        funct3 = 3'b101; funct7 = 7'b0000000; #10 print_signals("SRL");
        funct3 = 3'b111; funct7 = 7'b0000000; #10 print_signals("AND");
        funct3 = 3'b110; funct7 = 7'b0000000; #10 print_signals("OR");
        funct3 = 3'b100; funct7 = 7'b0000000; #10 print_signals("XOR");

        // --- I-type ALU --- (ADDI)
        opcode = 7'b0010011; 
        funct3 = 3'b000; funct7 = 7'bxxxxxxx; #10 print_signals("ADDI");

        // --- I-type Load --- (LW, LH, LB)
        opcode = 7'b0000011; 
        funct3 = 3'b010; funct7 = 7'bxxxxxxx; #10 print_signals("LW");
        funct3 = 3'b001; funct7 = 7'bxxxxxxx; #10 print_signals("LH");
        funct3 = 3'b000; funct7 = 7'bxxxxxxx; #10 print_signals("LB");

        // --- S-type Store --- (SW, SH, SB)
        opcode = 7'b0100011; 
        funct3 = 3'b010; funct7 = 7'bxxxxxxx; #10 print_signals("SW");
        funct3 = 3'b001; funct7 = 7'bxxxxxxx; #10 print_signals("SH");
        funct3 = 3'b000; funct7 = 7'bxxxxxxx; #10 print_signals("SB");

        // --- B-type Branch --- (BEQ)
        opcode = 7'b1100011; 
        funct3 = 3'b000; funct7 = 7'bxxxxxxx; #10 print_signals("BEQ");

        $finish;
    end

    // Task to print the signals for verification
    task print_signals(input [64:1] inst_name);
        begin
            $display("%40t | %11s | %7b | %3b | %7b ||  %b   |  %2b   |  %b   |  %b   |   %b    |    %b    |   %b    ||    %4b",
                     $time, inst_name, opcode, funct3, funct7,
                     RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);
        end
    endtask
endmodule
