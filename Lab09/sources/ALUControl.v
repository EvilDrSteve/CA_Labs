module ALU_Control(
    input [1:0] ALUOp,         // ALUOp signal from Main Control
    input [2:0] funct3,        // funct3 from instruction
    input [6:0] funct7,        // funct7 from instruction
    output reg [3:0] ALUControl // ALU control signals
);
    always @(*) begin
        // Default safe values for don't cares and unknown states
        ALUControl = 4'b0000; 

        case (ALUOp)
            2'b00: begin // Load / Store
                ALUControl = 4'b0010; // ADD
            end
            2'b01: begin // Branch
                ALUControl = 4'b0110; // SUB
            end
            2'b10: begin // R-type operations
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = 4'b0110; // SUB
                        else
                            ALUControl = 4'b0010; // ADD
                    end
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = 4'b0111; // SRL
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b111: ALUControl = 4'b0000; // AND
                    default: ALUControl = 4'b0000; // default safe value
                endcase
            end
            2'b11: begin // I-type ALU (ADDI)
                // For ADDI, funct3 is 000. It behaves like ADD.
                if (funct3 == 3'b000)
                    ALUControl = 4'b0010; // ADD
                else
                    ALUControl = 4'b0010; // safely default to ADD for other possible I-type formats
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule
