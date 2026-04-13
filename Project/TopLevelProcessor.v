`timescale 1ns / 1ps

// TopLevelProcessor — Single-cycle RISC-V (RV32I) processor.
// Integrates all datapath and control modules: PC, instruction fetch,
// decode/control, register file, ALU, data memory, and writeback.
module TopLevelProcessor(
    input wire clk,
    input wire reset,
    input [15:0] switchesIn, //To be stored in memory 0x30

    output [31:0] currentInstruction,
    output [31:0] pcOut,
    output [15:0] ledsOut //To be loaded from memory 0x20
);

    // ==============================================
    // Internal Wires
    // ==============================================

    // Program flow
    // wire [31:0] pcOut;          // current PC
    wire [31:0] pcPlus4;        // PC + 4 (next sequential)
    wire [31:0] branchTarget;   // PC + (imm << 1)
    wire [31:0] pcBranchOrSeq;  // PC value selection between branch or sequential
    wire [31:0] nextPc;         // selected next PC value
    wire [31:0] instruction;    // fetched instruction word
    wire [31:0] writeAluOrMem;  // writeData selection between ALU or MemRead
    // Control signals (from MainControl)
    wire        branch;
    wire        memRead;
    wire        memToReg;
    wire [1:0]  aluOp;
    wire        memWrite;
    wire        aluSrc;
    wire        regWrite;
    wire        jump;
    wire        jalr;

    // ALU control and flags
    wire [3:0]  aluOperation;   // from ALUControl to ALU
    wire        pcSrc;          // branch taken?
    wire        zeroFlag;       // ALU zero output

    // Datapath
    wire [31:0] immExtended;    // sign-extended immediate
    wire [31:0] readData1;      // rs1 value
    wire [31:0] readData2;      // rs2 value
    wire [31:0] aluInputB;      // ALU second operand (rs2 or imm)
    wire [31:0] aluResult;      // ALU output
    wire [31:0] memReadData;    // final read output (either switch or memory)
    wire [31:0] memReadDataRaw; // data memory read output
    wire [31:0] writeBackData;  // data written to register file
    wire [31:0] swReadData;     // data read from switches

    wire dataMemWrite, dataMemRead, ledWrite, switchReadEnable;
    // ==============================================
    // Branch Logic
    // ==============================================
    // Branch is taken when the branch control signal is set AND
    // the ALU zero flag indicates equality (for BEQ) or the
    // ALU zero flag indicates inequality (for BNE).
    assign pcSrc = (branch & (zeroFlag ^ instruction[12])) | jump;
    assign currentInstruction = instruction;
    // ==============================================
    // Module Instantiations
    // ==============================================


    // --- Program Counter ---
    ProgramCounter u_pc (
        .clk(clk),
        .reset(reset),
        .pcIn(nextPc),
        .pcOut(pcOut)
    );

    // --- PC + 4 Adder ---
    PcAdder u_pcAdder (
        .pcIn(pcOut),
        .pcNext(pcPlus4)
    );

    // --- Branch Target Adder ---
    BranchAdder u_branchAdder (
        .pcIn(pcOut),
        .imm(immExtended),
        .branchTarget(branchTarget)
    );

    // --- PC Source Mux: select sequential (PC+4) or branch target or aluResult(for JALR) ---
    Mux2 u_muxPcSelect (
        .d0(pcPlus4),
        .d1(branchTarget),
        .sel(pcSrc),
        .y(pcBranchOrSeq)
    );

    Mux2 u_muxPcJalr (
        .d0(pcBranchOrSeq),
        .d1(aluResult),
        .sel(jalr),
        .y(nextPc)
    );

    

    // --- Instruction Memory (ROM) ---
    InstructionMemory u_imem (
        .readAddress(pcOut),
        .instruction(instruction)
    );

    // --- Main Control Unit: decode opcode → control signals ---
    MainControl u_mainCtrl (
        .opcode(instruction[6:0]),
        .branch(branch),
        .memRead(memRead),
        .memToReg(memToReg),
        .aluOp(aluOp),
        .memWrite(memWrite),
        .aluSrc(aluSrc),
        .regWrite(regWrite),
        .jump(jump),
        .jalr(jalr)
    );

    // --- ALU Control: generate ALU op from aluOp + funct3 + funct7 ---
    ALUControl u_aluCtrl (
        .aluOp(aluOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .aluControl(aluOperation)
    );

    // --- Register File ---
    RegisterFile u_regFile (
        .clk(clk),
        .rst(reset),
        .writeEnable(regWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .writeData(writeBackData),
        .readData1(readData1),
        .readData2(readData2)
    );

    // --- Immediate Generator ---
    ImmGen u_immGen (
        .inst(instruction),
        .imm(immExtended)
    );

    // --- ALU Source Mux: select rs2 or immediate ---
    Mux2 u_muxAluSrc (
        .d0(readData2),
        .d1(immExtended),
        .sel(aluSrc),
        .y(aluInputB)
    );

    // --- ALU ---
    ALU u_alu (
        .a(readData1),
        .b(aluInputB),
        .aluControl(aluOperation),
        .aluResult(aluResult),
        .zero(zeroFlag)
    );

    // Address Decoder
    AddressDecoder u_addressDecoder(
        .address(aluResult[9:8]),
        .writeEnable(memWrite),
        .readEnable(memRead),
        .dataMemWrite(dataMemWrite),
        .dataMemRead(dataMemRead),
        .ledWrite(ledWrite),
        .switchReadEnable(switchReadEnable)
    );

    // LED
    Leds u_leds(
        .clk(clk),
        .reset(reset),
        .writeEnable(ledWrite),
        .readEnable(1'b0),
        .memAddress(30'b0),
        .writeData(readData2),
        .readData(),            // unused
        .ledOut(ledsOut)
    );


    //Switches
    Switches u_switches(
        .clk(clk),
        .rst(reset),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(switchReadEnable),
        .memAddress(30'b0),
        .switchIn(switchesIn),
        .readData(swReadData)
    );


    // --- Data Memory ---
    DataMemory u_dmem (
        .clk(clk),
        .rst(reset),
        .memWrite(dataMemWrite),
        .address(aluResult[7:0]),
        .writeData(readData2),
        .readData(memReadDataRaw)
    );

    //Mux
    Mux2 u_muxSwitchesOrMem(
        .d0(memReadDataRaw),
        .d1(swReadData),
        .sel(aluResult[9:8] == 2'b10),
        .y(memReadData)
    );

    // --- Writeback Mux: select ALU result or memory data or next pc value (for JALR) ---
    Mux2 u_muxWritebackAluOrMem (
        .d0(aluResult),
        .d1(memReadData),
        .sel(memToReg),
        .y(writeAluOrMem)
    );

    Mux2 u_muxWritebackJalr (
        .d0(writeAluOrMem),
        .d1(pcPlus4),
        .sel(jump | jalr),
        .y(writeBackData)
    );
endmodule
