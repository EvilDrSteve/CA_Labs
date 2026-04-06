`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2026 10:55:33
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] A, B,
    input [3:0] ALUControl,
    
    output reg [31:0] ALUResult, 
    output zero
    );
    
    always @(*) begin
        case(ALUControl)
            4'b0000: ALUResult = A + B;
            4'b0001: ALUResult = A - B;
            4'b0010: ALUResult = A & B;
            4'b0011: ALUResult = A | B;
            4'b0100: ALUResult = A ^ B;
            4'b0101: ALUResult = A << B[4:0];
            4'b0110: ALUResult = A >> B[4:0];
            default: ALUResult = 32'b0;
        endcase
    end
    assign zero = ((A - B) == 0);
endmodule
