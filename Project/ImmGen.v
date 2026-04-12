`timescale 1ns / 1ps

// immGen — Immediate Generator for RISC-V.
// Extracts and sign-extends the immediate field from the instruction
// based on the opcode (I, S, B, J, U types).
module ImmGen(
    input wire [31:0]  inst,  // full 32-bit instruction
    output reg [31:0]  imm    // sign-extended immediate output
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-Type: arithmetic immediates (ADDI), loads (LW/LH/LB), JALR
            // Format: imm[11:0] = inst[31:20]
            7'b0010011,   // I-type ALU
            7'b0000011,   // Load
            7'b1100111:   // JALR
                imm = {{20{inst[31]}}, inst[31:20]};

            // S-Type: stores (SW/SH/SB)
            // Format: imm[11:5] = inst[31:25], imm[4:0] = inst[11:7]
            7'b0100011:
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-Type: branches (BEQ)
            // Encodes a 13-bit offset with LSB=0 (not stored).
            // immGen outputs the 12 encoded bits sign-extended;
            // branchAdder shifts left by 1 to reconstruct the full offset.
            7'b1100011:
                imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};

            //J-Type: jump and link (JAL)
            // inst[31]=imm[20], inst[30:21]=imm[10:1], inst[20]=imm[11], inst[19:12]=imm[19:12]
            // Output imm[20:1] (no LSB) — BranchAdder shifts left by 1
            7'b1101111:
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21]};
            default:
                imm = 32'b0;
        endcase
    end

endmodule
