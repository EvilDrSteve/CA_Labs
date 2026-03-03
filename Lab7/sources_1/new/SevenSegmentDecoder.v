`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2026 11:32:32
// Design Name: 
// Module Name: SevenSegmentDecoder
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


module SevenSegmentDecoder(
input [3:0] D,
output [6:0] S
    );
    

        //SOP of A
assign S[0] = (!D[3] & !D[2] & !D[1] & D[0]) 
            + (!D[3] & D[2] & !D[1] & !D[0]) 
            + (D[3] & !D[2] & D[1] & D[0]) 
            + (D[3] & D[2] & !D[1] & D[0]);
//assign S[0] = (!D[3] & !D[2] & !D[1] & D[0])
//            + (!D[3] & D[2] & !D[1] & !D[0])
//            + (D[3] & !D[2] & D[1] & D[0])
//            + (D[3] & D[2] & !D[1] & D[0]);
            
        //SOP of B
assign S[1] = (!D[3] & D[2] & !D[1] & D[0]) 
            + (!D[3] & D[2] & D[1] & !D[0]) 
            + (D[3] & !D[2] & D[1] & D[0])
             + (D[3] & D[2] & !D[1] & !D[0])
              + (D[3] & D[2] & D[1] & !D[0])
              + (D[3] & D[2] & D[1] & D[0]);
//assign S[1] = (D[2] & D[1] & !D[0]) 
//            + (!D[3] & D[2] & D[1] & !D[0]) 
//            + (D[3] & !D[2] & D[1] & D[0]);
             
        //SOP of C
assign S[2] = (!D[3] & !D[2] & D[1] & !D[0])
            + (D[3] & D[2] & !D[1] & !D[0])
            + (D[3] & D[2] & D[1] & !D[0])
            + (D[3] & D[2] & D[1] & D[0]);


        //SOP of D
assign S[3] = (!D[3] & !D[2] & !D[1] & D[0])
            + (!D[3] & D[2] & !D[1] & !D[0])
            + (!D[3] & D[2] & D[1] & D[0])
            + (D[3] & !D[2] & D[1] & !D[0])
            + (D[3] & D[2] & D[1] & D[0]);
        
        //SOP of E
assign S[4] = (!D[3] & !D[2] & !D[1] & D[0])
            + (!D[3] & !D[2] & D[1] & D[0])
            + (!D[3] & D[2] & !D[1] & !D[0])
            + (!D[3] & D[2] & !D[1] & D[0])
            + (!D[3] & D[2] & D[1] & D[0])
            + (D[3] & !D[2] & !D[1] & D[0]);

        //SOP of F
assign S[5] = (!D[3] & !D[2] & !D[1] & D[0])
            + (!D[3] & !D[2] & D[1] & !D[0])
            + (!D[3] & !D[2] & D[1] & D[0])
            + (!D[3] & D[2] & D[1] & D[0])
            + (D[3] & D[2] & !D[1] & D[0]);

        //SOP of G
assign S[6] = (!D[3] & !D[2] & !D[1] & !D[0])
            + (!D[3] & !D[2] & !D[1] & D[0])
            + (!D[3] & D[2] & D[1] & D[0])
            + (D[3] & D[2] & !D[1] & !D[0]);
            
endmodule
