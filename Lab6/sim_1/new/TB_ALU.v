`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2026 11:06:33
// Design Name: 
// Module Name: TB_ALU
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


module TB_ALU(

    );
    
    reg [31:0] A, B;
    reg [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire zero;
    
    ALU alu(A, B, ALUControl, ALUResult, zero);
    
    initial begin
    // Test 1: ADD
        A = 32'h00000010; B = 32'h00000020; ALUControl = 4'b0000;
        #10;
        $display("ADD:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 2: SUB
        A = 32'h00000030; B = 32'h00000010; ALUControl = 4'b0001;
        #10;
        $display("SUB:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 3: SUB resulting in zero (for BEQ)
        A = 32'h00000005; B = 32'h00000005; ALUControl = 4'b0001;
        #10;
        $display("SUB(zero): A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 4: AND
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUControl = 4'b0010;
        #10;
        $display("AND:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 5: OR
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUControl = 4'b0011;
        #10;
        $display("OR:   A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 6: XOR
        A = 32'hAAAAAAAA; B = 32'h55555555; ALUControl = 4'b0100;
        #10;
        $display("XOR:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 7: SLL (shift left by 4)
        A = 32'h00000001; B = 32'h00000004; ALUControl = 4'b0101;
        #10;
        $display("SLL:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 8: SRL (shift right by 4)
        A = 32'h00000080; B = 32'h00000004; ALUControl = 4'b0110;
        #10;
        $display("SRL:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 9: Default case
        A = 32'h12345678; B = 32'h9ABCDEF0; ALUControl = 4'b0111;
        #10;
        $display("DEF:  A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        // Test 10: ADD with overflow
        A = 32'hFFFFFFFF; B = 32'h00000001; ALUControl = 4'b0000;
        #10;
        $display("ADD(ovf): A=%h, B=%h, Result=%h, Zero=%b", A, B, ALUResult, zero);

        $display("\nAll tests completed.");
        $finish;
    end
    
endmodule
