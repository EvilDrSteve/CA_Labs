`timescale 1ns / 1ps

// PipelinedProcessor — 5-stage pipelined RISC-V (RV32I) processor.
//
// Stages: IF | ID | EX | MEM | WB, separated by the IF_ID, ID_EX,
// EX_MEM and MEM_WB pipeline registers. Branches and JAL/JALR are
// resolved in the MEM stage, so a taken control transfer flushes
// the two younger instructions in IF/ID and ID/EX.
//
// Hazard handling:
//   - HazardDetectionUnit stalls one cycle on a load-use hazard.
//   - ForwardingUnit forwards EX/MEM and MEM/WB results to the EX
//     stage so back-to-back ALU dependencies do not require a stall.
//   - RegisterFile bypasses the WB write data on a same-cycle read
//     (write-through) to handle the WB->ID race introduced by stalls.
module PipelinedProcessor(
    input wire clk,
    input wire reset
);

    // ==================== IF stage ====================
    wire [31:0] pcOut, nextPc, pcPlus4;
    wire [31:0] instruction;

    // ==================== IF/ID outputs ====================
    wire [31:0] IF_ID_pc;
    wire [31:0] IF_ID_instruction;
    wire [4:0]  IF_ID_rs1 = IF_ID_instruction[19:15];
    wire [4:0]  IF_ID_rs2 = IF_ID_instruction[24:20];
    wire [4:0]  IF_ID_rd  = IF_ID_instruction[11:7];

    // ==================== ID stage ====================
    wire        branch, memRead, memToReg, memWrite, aluSrc, regWrite, jump, jalr;
    wire [1:0]  aluOp;
    wire [31:0] immExtended;
    wire [31:0] readData1, readData2;
    wire [31:0] writeBackData;

    // ==================== ID/EX outputs ====================
    wire [2:0]  ID_EX_func3;
    wire [6:0]  ID_EX_func7;
    wire [31:0] ID_EX_pc;
    wire [1:0]  ID_EX_aluOp;
    wire        ID_EX_regWrite, ID_EX_memRead, ID_EX_memWrite, ID_EX_aluSrc,
                ID_EX_memToReg, ID_EX_branch, ID_EX_jump, ID_EX_jalr;
    wire [4:0]  ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    wire [31:0] ID_EX_readData1, ID_EX_readData2, ID_EX_immediateValue;

    // ==================== EX stage ====================
    wire [1:0]  forwardA, forwardB;
    wire [3:0]  aluControl;
    wire [31:0] aluInputA, forwardedB;
    wire [31:0] aluInputB    = ID_EX_aluSrc ? ID_EX_immediateValue : forwardedB;
    wire [31:0] aluResult;
    wire        zeroFlag, lessThan;
    wire [31:0] ex_branchTarget;
    wire [31:0] ex_pcPlus4   = ID_EX_pc + 32'd4;

    // ==================== EX/MEM outputs ====================
    wire [31:0] EX_MEM_aluResult, EX_MEM_readData2, EX_MEM_branchTarget, EX_MEM_pcPlus4;
    wire        EX_MEM_zero, EX_MEM_lessThan;
    wire [4:0]  EX_MEM_rd;
    wire [2:0]  EX_MEM_func3;
    wire        EX_MEM_regWrite, EX_MEM_memRead, EX_MEM_memWrite,
                EX_MEM_memToReg, EX_MEM_branch, EX_MEM_jump, EX_MEM_jalr;

    // ==================== MEM stage ====================
    wire [31:0] memReadData;
    wire [31:0] branchTarget;
    wire        mem_pcSrc;

    // ==================== MEM/WB outputs ====================
    wire [31:0] MEM_WB_aluResult, MEM_WB_memReadData, MEM_WB_pcPlus4;
    wire [4:0]  MEM_WB_rd;
    wire        MEM_WB_regWrite, MEM_WB_memToReg, MEM_WB_jump, MEM_WB_jalr;

    // ==================== Hazard control ====================
    wire stall, flush;
    assign nextPc = stall    ? pcOut
                  : mem_pcSrc ? branchTarget
                  : pcPlus4;
    assign flush = mem_pcSrc;

    // ==================== IF stage ====================
    ProgramCounter u_pc(
        .clk(clk),
        .reset(reset),
        .pcIn(nextPc),
        .pcOut(pcOut)
    );

    PcAdder u_pcAdder(
        .pcIn(pcOut),
        .pcNext(pcPlus4)
    );

    InstructionMemory u_imem(
        .readAddress(pcOut),
        .instruction(instruction)
    );

    IF_ID u_ifid(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .readAddress(pcOut),
        .instruction(instruction),

        .lastReadAddress(IF_ID_pc),
        .lastInstruction(IF_ID_instruction)
    );

    // ==================== ID stage ====================
    HazardDetectionUnit u_hdu(
        .IF_ID_rs1(IF_ID_rs1),
        .IF_ID_rs2(IF_ID_rs2),
        .ID_EX_rd(ID_EX_rd),
        .ID_EX_memRead(ID_EX_memRead),

        .stall(stall)
    );

    MainControl u_mainCtrl(
        .opcode(IF_ID_instruction[6:0]),
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

    ImmGen u_immGen(
        .inst(IF_ID_instruction),
        .imm(immExtended)
    );

    RegisterFile u_regFile(
        .clk(clk),
        .rst(reset),
        .writeEnable(MEM_WB_regWrite),
        .rs1(IF_ID_rs1),
        .rs2(IF_ID_rs2),
        .rd(MEM_WB_rd),
        .writeData(writeBackData),
        .readData1(readData1),
        .readData2(readData2)
    );

    ID_EX u_idex(
        .clk(clk),
        .reset(reset),
        .flush(stall | mem_pcSrc),

        .func3(IF_ID_instruction[14:12]),
        .func7(IF_ID_instruction[31:25]),
        .PC(IF_ID_pc),

        .branch(branch),
        .memRead(memRead),
        .memToReg(memToReg),
        .aluOp(aluOp),
        .memWrite(memWrite),
        .aluSrc(aluSrc),
        .regWrite(regWrite),
        .jump(jump),
        .jalr(jalr),

        .rs1(IF_ID_rs1),
        .rs2(IF_ID_rs2),
        .rd(IF_ID_rd),
        .readData1(readData1),
        .readData2(readData2),
        .immediateValue(immExtended),

        .func3Last(ID_EX_func3),
        .func7Last(ID_EX_func7),
        .PCLast(ID_EX_pc),

        .aluOpLast(ID_EX_aluOp),
        .regWriteLast(ID_EX_regWrite),
        .memReadLast(ID_EX_memRead),
        .memWriteLast(ID_EX_memWrite),
        .aluSrcLast(ID_EX_aluSrc),
        .memToRegLast(ID_EX_memToReg),
        .branchLast(ID_EX_branch),
        .jumpLast(ID_EX_jump),
        .jalrLast(ID_EX_jalr),

        .rs1Last(ID_EX_rs1),
        .rs2Last(ID_EX_rs2),
        .rdLast(ID_EX_rd),
        .readData1Last(ID_EX_readData1),
        .readData2Last(ID_EX_readData2),
        .immediateValueLast(ID_EX_immediateValue)
    );

    // ==================== EX stage ====================
    ForwardingUnit u_fwd(
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .EX_MEM_rd(EX_MEM_rd),
        .MEM_WB_rd(MEM_WB_rd),
        .EX_MEM_regWrite(EX_MEM_regWrite),
        .MEM_WB_regWrite(MEM_WB_regWrite),

        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    Mux3 u_muxAluSrc1(
        .d0(ID_EX_readData1),
        .d1(writeBackData),
        .d2(EX_MEM_aluResult),
        .sel(forwardA),
        .y(aluInputA)
    );

    Mux3 u_muxAluSrc2(
        .d0(ID_EX_readData2),
        .d1(writeBackData),
        .d2(EX_MEM_aluResult),
        .sel(forwardB),
        .y(forwardedB)
    );

    BranchAdder u_branchAdder(
        .pcIn(ID_EX_pc),
        .imm(ID_EX_immediateValue),
        .branchTarget(ex_branchTarget)
    );

    ALUControl u_aluCtrl(
        .aluOp(ID_EX_aluOp),
        .funct3(ID_EX_func3),
        .funct7(ID_EX_func7),
        .aluControl(aluControl)
    );

    ALU u_alu(
        .a(aluInputA),
        .b(aluInputB),
        .aluControl(aluControl),
        .aluResult(aluResult),
        .zero(zeroFlag),
        .lessThan(lessThan)
    );

    EX_MEM u_exmem(
        .clk(clk),
        .reset(reset),
        .flush(mem_pcSrc),

        .aluResult(aluResult),
        .readData2(forwardedB),
        .branchTarget(ex_branchTarget),
        .pcPlus4(ex_pcPlus4),
        .zero(zeroFlag),
        .lessThan(lessThan),
        .rd(ID_EX_rd),
        .func3(ID_EX_func3),
        .memRead(ID_EX_memRead),
        .memWrite(ID_EX_memWrite),
        .memToReg(ID_EX_memToReg),
        .branch(ID_EX_branch),
        .jump(ID_EX_jump),
        .jalr(ID_EX_jalr),
        .regWrite(ID_EX_regWrite),

        .aluResultLast(EX_MEM_aluResult),
        .readData2Last(EX_MEM_readData2),
        .branchTargetLast(EX_MEM_branchTarget),
        .pcPlus4Last(EX_MEM_pcPlus4),
        .zeroLast(EX_MEM_zero),
        .lessThanLast(EX_MEM_lessThan),
        .rdLast(EX_MEM_rd),
        .func3Last(EX_MEM_func3),
        .memReadLast(EX_MEM_memRead),
        .memWriteLast(EX_MEM_memWrite),
        .memToRegLast(EX_MEM_memToReg),
        .branchLast(EX_MEM_branch),
        .jumpLast(EX_MEM_jump),
        .jalrLast(EX_MEM_jalr),
        .regWriteLast(EX_MEM_regWrite)
    );

    // ==================== MEM stage ====================
    // Branch decision is made here (3 cycles after fetch).
    wire mem_branchTaken = EX_MEM_branch & (
        (EX_MEM_func3 == 3'b000 &  EX_MEM_zero)     |  // BEQ
        (EX_MEM_func3 == 3'b001 & ~EX_MEM_zero)     |  // BNE
        (EX_MEM_func3 == 3'b100 &  EX_MEM_lessThan) |  // BLT
        (EX_MEM_func3 == 3'b101 & ~EX_MEM_lessThan)    // BGE
    );

    assign mem_pcSrc    = mem_branchTaken | EX_MEM_jump | EX_MEM_jalr;
    assign branchTarget = EX_MEM_jalr ? EX_MEM_aluResult : EX_MEM_branchTarget;

    DataMemory u_dmem(
        .clk(clk),
        .rst(reset),
        .memWrite(EX_MEM_memWrite),
        .address(EX_MEM_aluResult[9:2]),
        .writeData(EX_MEM_readData2),
        .readData(memReadData)
    );

    MEM_WB u_memwb(
        .clk(clk),
        .reset(reset),

        .aluResult(EX_MEM_aluResult),
        .memReadData(memReadData),
        .pcPlus4(EX_MEM_pcPlus4),
        .rd(EX_MEM_rd),
        .regWrite(EX_MEM_regWrite),
        .memToReg(EX_MEM_memToReg),
        .jump(EX_MEM_jump),
        .jalr(EX_MEM_jalr),

        .aluResultLast(MEM_WB_aluResult),
        .memReadDataLast(MEM_WB_memReadData),
        .pcPlus4Last(MEM_WB_pcPlus4),
        .rdLast(MEM_WB_rd),
        .regWriteLast(MEM_WB_regWrite),
        .memToRegLast(MEM_WB_memToReg),
        .jumpLast(MEM_WB_jump),
        .jalrLast(MEM_WB_jalr)
    );

    // ==================== WB stage ====================
    wire [31:0] wb_aluOrMem = MEM_WB_memToReg ? MEM_WB_memReadData : MEM_WB_aluResult;
    assign writeBackData    = (MEM_WB_jump | MEM_WB_jalr) ? MEM_WB_pcPlus4 : wb_aluOrMem;

endmodule
