`timescale 1ns / 1ps

// HazardDetectionUnit — Detects load-use hazards.
// When a load is in the EX stage and the instruction in ID reads the
// loaded register, the loaded value is not available in time for
// forwarding. We assert `stall` for one cycle: PC and IF/ID freeze,
// and a NOP is injected into ID/EX.
module HazardDetectionUnit(
    input  wire [4:0] IF_ID_rs1,
    input  wire [4:0] IF_ID_rs2,
    input  wire [4:0] ID_EX_rd,
    input  wire       ID_EX_memRead,

    output reg        stall
);

    always @(*) begin
        stall = 1'b0;
        if (ID_EX_memRead && ID_EX_rd != 5'b0 &&
           (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2))
            stall = 1'b1;
    end

endmodule
