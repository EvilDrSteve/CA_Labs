module MainControl(
    input [6:0] opcode,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg Branch
);
    always @(*) begin
        // Default safe values for don't cares and unused opcodes
        RegWrite = 1'b0;
        ALUOp    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;

        case(opcode)
            7'b0110011: begin // R-type (ADD, SUB, SLL, SRL, AND, OR, XOR)
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin // I-type ALU (ADDI)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11; // 11 designated for I-type immediate operations
            end
            7'b0000011: begin // Load (LW, LH, LB)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00; // 00 for address addition
            end
            7'b0100011: begin // Store (SW, SH, SB)
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00; // 00 for address addition
            end
            7'b1100011: begin // Branch (BEQ)
                ALUSrc   = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01; // 01 for branch subtraction/comparison
            end
            default: begin
                // Retain default values
            end
        endcase
    end
endmodule
