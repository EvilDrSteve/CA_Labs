`timescale 1ns / 1ps

// ALUControl — Generates the 4-bit ALU operation code from the
// main control's ALUOp signal and the instruction's funct3/funct7 fields.
//
// ALUOp mapping:
//   00 = Load/Store  → always ADD (address calculation)
//   01 = Branch      → always SUB (equality comparison)
//   10 = R-type      → decode funct3 + funct7
//   11 = I-type ALU  → decode funct3 (currently only ADDI)
module ALUControl(
    input wire [1:0]   aluOp,       // from MainControl
    input wire [2:0]   funct3,      // instruction[14:12]
    input wire [6:0]   funct7,      // instruction[31:25]
    output reg [3:0]   aluControl   // to ALU
);

    always @(*) begin
        aluControl = 4'b0000; // default: ADD

        case (aluOp)
            2'b00: // Load / Store — need ADD for address calculation
                aluControl = 4'b0010;

            2'b01: // Branch — need SUB for comparison
                aluControl = 4'b0110;

            2'b10: begin // R-type — decode from funct3 + funct7
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            aluControl = 4'b0110; // SUB
                        else
                            aluControl = 4'b0010; // ADD
                    end
                    3'b001: aluControl = 4'b0101; // SLL
                    3'b100: aluControl = 4'b0100; // XOR
                    3'b101: aluControl = 4'b0111; // SRL
                    3'b110: aluControl = 4'b0001; // OR
                    3'b111: aluControl = 4'b0000; // AND
                    default: aluControl = 4'b0000;
                endcase
            end

            2'b11: begin // I-type ALU
                case (funct3)
                    3'b000: aluControl = 4'b0010; // ADDI
                    3'b101: aluControl = 4'b0111; // SRLI (same ALU op as SRL)
                    3'b001: aluControl = 4'b0101; // SLLI
                    default: aluControl = 4'b0010;
                endcase
            end


            default:
                aluControl = 4'b0000;
        endcase
    end

endmodule
