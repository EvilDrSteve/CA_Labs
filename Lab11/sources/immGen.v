`timescale 1ns / 1ps

module immGen(
    input wire [31:0] inst,
    output reg [31:0] imm
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-Type: ALU, Loads, JALR
            7'b0010011, 
            7'b0000011, 
            7'b1100111: begin 
                imm = {{20{inst[31]}}, inst[31:20]};
            end
            
            // S-Type: Stores
            7'b0100011: begin 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            
            // B-Type: Branches
            7'b1100011: begin 
                // B-type format encodes a 13-bit offset with the LSB always 0, missing from the instruction.
                // Depending on the external datapath setup, this either needs to be reconstructed fully or
                // extracted so that an external 'shifted left by 1' matches the exact offset.
                // Given branchAdder performs: pc + (imm << 1), this immGen extracts the 12 encoded bits,
                // sign extends them, effectively providing exactly half the offset to be shifted correctly.
                imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
            end
            
            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule
