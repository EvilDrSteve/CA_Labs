`timescale 1ns / 1ps

module TopLevelProcessor(
    input wire clk,
    input wire reset
);

    // ==========================================
    // Internal Wires Declarations
    // ==========================================
    
    // Program Flow Wires
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] next_pc;
    wire [31:0] instruction;
    
    // Control Signal Wires
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    wire [3:0] ALU_operation; 
    wire PCSrc;
    wire zero_flag;
    
    // Data Path Wires
    wire [31:0] imm_extended;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [31:0] memory_read_data;
    wire [31:0] write_data;

    // ==========================================
    // Branch Logic
    // ==========================================
    assign PCSrc = Branch & zero_flag;

    // ==========================================
    // Module Instantiations
    // ==========================================

    // --- Program Flow ---
    ProgramCounter u_pc (
        .clk(clk),
        .reset(reset),
        .pc_in(next_pc),
        .pc_out(pc_out)
    );

    pcAdder u_pcAdder (
        .pc(pc_out),
        .pc_next(pc_plus_4)
    );

    branchAdder u_branchAdder (
        .pc(pc_out),
        .imm(imm_extended),
        .branch_target(branch_target)
    );

    // Mux for PC selection
    mux2 u_mux_pc_select (
        .d0(pc_plus_4),
        .d1(branch_target),
        .sel(PCSrc),
        .y(next_pc)
    );

    // --- Instruction & Control ---
    InstructionMemory u_imem (
        .ReadAddress(pc_out),
        .Instruction(instruction)
    );

    MainControl u_main_ctrl (
        .opcode(instruction[6:0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    ALU_Control u_alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .ALUControl(ALU_operation)
    );

    // --- Data Path Execution ---
    RegisterFile u_reg_file (
        .clk(clk),
        .rst(reset),
        .WriteEnable(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(write_data),
        .readData1(read_data1),
        .readData2(read_data2)
    );

    immGen u_immGen (
        .inst(instruction),
        .imm(imm_extended)
    );

    // Mux for ALU Source
    mux2 u_mux_alu_src (
        .d0(read_data2),
        .d1(imm_extended),
        .sel(ALUSrc),
        .y(alu_input_b)
    );

    ALU u_alu (
        .A(read_data1),
        .B(alu_input_b),
        .ALUControl(ALU_operation),
        .ALUResult(alu_result),
        .zero(zero_flag)
    );

    // --- Memory & Writeback ---
    DataMemory u_dmem (
        .clk(clk),
        .rst(reset),
        .memWrite(MemWrite),
        .address(alu_result[7:0]), // DataMemory address is natively an 8-bit signal
        .writeData(read_data2),
        .readData(memory_read_data)
    );

    // Mux for Writeback
    mux2 u_mux_writeback (
        .d0(alu_result),
        .d1(memory_read_data),
        .sel(MemtoReg),
        .y(write_data)
    );

endmodule