`timescale 1ns / 1ps

// ForwardingUnit — Resolves RAW hazards by forwarding ALU operands
// from later pipeline stages back into the EX stage.
//
// Select encoding (forwardA / forwardB):
//   00 = use ID/EX register read data (no forwarding)
//   01 = forward from MEM/WB writeback data
//   10 = forward from EX/MEM ALU result
//
// EX/MEM has priority over MEM/WB: a more recent producer overrides
// an older one writing the same register.
module ForwardingUnit(
    input  wire [4:0] ID_EX_rs1,
    input  wire [4:0] ID_EX_rs2,
    input  wire [4:0] EX_MEM_rd,
    input  wire [4:0] MEM_WB_rd,
    input  wire       EX_MEM_regWrite,
    input  wire       MEM_WB_regWrite,

    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);

    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX/MEM hazard (higher priority)
        if (EX_MEM_regWrite && EX_MEM_rd != 5'b0 && EX_MEM_rd == ID_EX_rs1)
            forwardA = 2'b10;
        if (EX_MEM_regWrite && EX_MEM_rd != 5'b0 && EX_MEM_rd == ID_EX_rs2)
            forwardB = 2'b10;

        // MEM/WB hazard (only if EX/MEM did not already match)
        if (MEM_WB_regWrite && MEM_WB_rd != 5'b0 &&
           !(EX_MEM_regWrite && EX_MEM_rd != 5'b0 && EX_MEM_rd == ID_EX_rs1) &&
            MEM_WB_rd == ID_EX_rs1)
            forwardA = 2'b01;
        if (MEM_WB_regWrite && MEM_WB_rd != 5'b0 &&
           !(EX_MEM_regWrite && EX_MEM_rd != 5'b0 && EX_MEM_rd == ID_EX_rs2) &&
            MEM_WB_rd == ID_EX_rs2)
            forwardB = 2'b01;
    end

endmodule
