`timescale 1ns / 1ps

// MainControl — Decodes the 7-bit opcode into control signals
// that drive the datapath (register writes, memory access, ALU
// source selection, branching).
//
// Supported opcodes:
//   0110011 = R-type  (ADD, SUB, SLL, SRL, AND, OR, XOR)
//   0010011 = I-type  (ADDI)
//   0000011 = Load    (LW, LH, LB)
//   0100011 = Store   (SW, SH, SB)
//   1100011 = Branch  (BEQ, BNE)
//   1101111 = Jump and Link (JAL)
//   1100111 =  (JALR)

module MainControl(
    input wire [6:0]   opcode,
    output reg         regWrite,   // enable register file write
    output reg [1:0]   aluOp,      // ALU operation category
    output reg         memRead,    // enable data memory read
    output reg         memWrite,   // enable data memory write
    output reg         aluSrc,     // 0=rs2, 1=immediate to ALU input B
    output reg         memToReg,   // 0=ALU result, 1=memory data to register
    output reg         branch,     // enable branch comparison
    output reg         jump,       // JAL — unconditional jump via branchTarget
    output reg         jalr        // JALR — jump via ALU result (rs1 + imm)
);

    always @(*) begin
        // Safe defaults — all control signals deasserted
        regWrite = 1'b0;
        aluOp    = 2'b00;
        memRead  = 1'b0;
        memWrite = 1'b0;
        aluSrc   = 1'b0;
        memToReg = 1'b0;
        branch   = 1'b0;
        jump     = 1'b0;
        jalr     = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                regWrite = 1'b1;
                aluSrc   = 1'b0;  // second operand from rs2
                aluOp    = 2'b10; // R-type decode
            end

            7'b0010011: begin // I-type ALU (ADDI)
                regWrite = 1'b1;
                aluSrc   = 1'b1;  // second operand from immediate
                aluOp    = 2'b11; // I-type decode
            end

            7'b0000011: begin // Load (LW, LH, LB)
                regWrite = 1'b1;
                aluSrc   = 1'b1;  // base + offset
                memToReg = 1'b1;  // write memory data to register
                memRead  = 1'b1;
                aluOp    = 2'b00; // ADD for address calc
            end

            7'b0100011: begin // Store (SW, SH, SB)
                aluSrc   = 1'b1;  // base + offset
                memWrite = 1'b1;
                aluOp    = 2'b00; // ADD for address calc
            end

            7'b1100011: begin // Branch (BEQ, BNE, BGE)
                aluSrc   = 1'b0;  // compare rs1 and rs2
                branch   = 1'b1;
                aluOp    = 2'b01; // SUB for comparison
            end

            7'b1101111: begin // Jump and Link(JAL)
                regWrite = 1'b1;
                aluOp = 2'b00;
                memToReg = 1'b0;
                branch = 1'b0;
                memRead = 1'b0;
                memWrite = 1'b0;
                jump = 1'b1;
            end

            7'b1100111: begin // JALR
                regWrite = 1'b1;
                aluSrc   = 1'b1;  // ALU computes rs1 + imm
                aluOp    = 2'b00; // ADD
                jalr     = 1'b1;  // PC = aluResult
            end
            default: begin
                // Retain safe defaults
            end
        endcase
    end

endmodule
