module Lab11Top(
    input clk, reset
);

wire [31:0] pcIdx, pcIdxNext, pcIdxIncrement;
wire [31:0] instruction, immediateValue;

//Write enable
wire writeEnable;
wire [4:0] rs1, rs2, rd;
wire [31:0] writeData, readData1, readData2;

ProgramCounter pc(
    .clk(clk),
    .reset(reset),
    .pc_in(pcIdxNext),
    .pc_out(pcIdx)
);

pcAdder pcAdd(
    .pc(pcIdx),
    .pc_next(pcIdxIncrement)
);

InstructionMemory instMem(
    .ReadAddress(pcIdx),
    .Instruction(instruction)
);

immGen immediateGen(
    .inst(instruction),
    .imm(immediateValue)
);

RegisterFile regFile(
    .clk(clk),
    .WriteEnable(writeEnable),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(writeData),
    .readData1(readData1),
    .readData2(readData2)
);

mux2 ALUInputSelect(
    .d0(readData2),
    .d1(immediateValue),
    .sel(ALUSrc),
    .y(ALUInput)
);

ALU alu(
    .A(readData1),
    .B(ALUInput),
    .ALUControl(ALUControlSignal),
    .ALUResult()
)
endmodule