`timescale 1ns / 1ps
module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input [OPERAND_LENGTH:0] instAddress,
    output reg [31:0] instruction
);

    reg [7:0] memory [0:255];

    // Byte-addressable, little-endian read
    always @(*) begin
        instruction = {memory[instAddress+3], memory[instAddress+2],
                       memory[instAddress+1], memory[instAddress]};
    end

    integer i;
    initial begin
        // Clear all memory
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;

        // === main: ===
        // 0x000: addi x8, x0, 0x200       (li x8, 0x200 - LED address)
        memory[0]   = 8'h13;
        memory[1]   = 8'h04;
        memory[2]   = 8'h00;
        memory[3]   = 8'h20;

        // 0x004: addi x9, x0, 0x300       (li x9, 0x300 - switch address)
        memory[4]   = 8'h93;
        memory[5]   = 8'h04;
        memory[6]   = 8'h00;
        memory[7]   = 8'h30;

        // 0x008: addi x18, x0, 0x400      (li x18, 0x400 - reset address)
        memory[8]   = 8'h13;
        memory[9]   = 8'h09;
        memory[10]  = 8'h00;
        memory[11]  = 8'h40;

        // 0x00C: addi x5, x0, 10          (test setup: x5 = 10)
        memory[12]  = 8'h93;
        memory[13]  = 8'h02;
        memory[14]  = 8'hA0;
        memory[15]  = 8'h00;

        // 0x010: sw x5, 0(x9)             (test setup: store to switches)
        memory[16]  = 8'h23;
        memory[17]  = 8'hA0;
        memory[18]  = 8'h54;
        memory[19]  = 8'h00;

        // === idle: ===
        // 0x014: lw x7, 0(x9)             (read switches)
        memory[20]  = 8'h83;
        memory[21]  = 8'hA3;
        memory[22]  = 8'h04;
        memory[23]  = 8'h00;

        // 0x018: beq x7, x0, idle         (if switches == 0, keep waiting)
        memory[24]  = 8'hE3;
        memory[25]  = 8'h8E;
        memory[26]  = 8'h03;
        memory[27]  = 8'hFE;

        // 0x01C: addi x10, x7, 0          (mv x10, x7 - pass count as arg)
        memory[28]  = 8'h13;
        memory[29]  = 8'h85;
        memory[30]  = 8'h03;
        memory[31]  = 8'h00;

        // 0x020: jal x1, countdown         (call countdown subroutine)
        memory[32]  = 8'hEF;
        memory[33]  = 8'h00;
        memory[34]  = 8'h80;
        memory[35]  = 8'h00;

        // 0x024: jal x0, idle              (j idle - loop back)
        memory[36]  = 8'h6F;
        memory[37]  = 8'hF0;
        memory[38]  = 8'h1F;
        memory[39]  = 8'hFF;

        // === countdown: ===
        // 0x028: addi sp, sp, -16          (allocate stack)
        memory[40]  = 8'h13;
        memory[41]  = 8'h01;
        memory[42]  = 8'h01;
        memory[43]  = 8'hFF;

        // 0x02C: sw x1, 12(sp)            (save ra)
        memory[44]  = 8'h23;
        memory[45]  = 8'h26;
        memory[46]  = 8'h11;
        memory[47]  = 8'h00;

        // 0x030: sw x5, 8(sp)             (save x5)
        memory[48]  = 8'h23;
        memory[49]  = 8'h24;
        memory[50]  = 8'h51;
        memory[51]  = 8'h00;

        // 0x034: sw x6, 4(sp)             (save x6)
        memory[52]  = 8'h23;
        memory[53]  = 8'h22;
        memory[54]  = 8'h61;
        memory[55]  = 8'h00;

        // 0x038: sw x8, 0(sp)             (save x8)
        memory[56]  = 8'h23;
        memory[57]  = 8'h20;
        memory[58]  = 8'h81;
        memory[59]  = 8'h00;

        // 0x03C: addi x5, x10, 0          (mv x5, x10 - x5 = counter)
        memory[60]  = 8'h93;
        memory[61]  = 8'h02;
        memory[62]  = 8'h05;
        memory[63]  = 8'h00;

        // === count_loop: ===
        // 0x040: sw x5, 0(x8)             (display counter on LEDs)
        memory[64]  = 8'h23;
        memory[65]  = 8'h20;
        memory[66]  = 8'h54;
        memory[67]  = 8'h00;

        // 0x044: beq x5, x0, count_done   (if counter == 0, done)
        memory[68]  = 8'h63;
        memory[69]  = 8'h80;
        memory[70]  = 8'h02;
        memory[71]  = 8'h02;

        // 0x048: lw x6, 0(x18)            (read reset button)
        memory[72]  = 8'h03;
        memory[73]  = 8'h23;
        memory[74]  = 8'h09;
        memory[75]  = 8'h00;

        // 0x04C: bne x6, x0, count_done   (if reset pressed, exit)
        memory[76]  = 8'h63;
        memory[77]  = 8'h1C;
        memory[78]  = 8'h03;
        memory[79]  = 8'h00;

        // 0x050: addi x5, x5, -1          (decrement counter)
        memory[80]  = 8'h93;
        memory[81]  = 8'h82;
        memory[82]  = 8'hF2;
        memory[83]  = 8'hFF;

        // 0x054: addi x6, x0, 1           (li x6, 1 - delay init)
        memory[84]  = 8'h13;
        memory[85]  = 8'h03;
        memory[86]  = 8'h10;
        memory[87]  = 8'h00;

        // === delay: ===
        // 0x058: addi x6, x6, -1          (decrement delay counter)
        memory[88]  = 8'h13;
        memory[89]  = 8'h03;
        memory[90]  = 8'hF3;
        memory[91]  = 8'hFF;

        // 0x05C: bne x6, x0, delay        (loop delay)
        memory[92]  = 8'hE3;
        memory[93]  = 8'h1E;
        memory[94]  = 8'h03;
        memory[95]  = 8'hFE;

        // 0x060: jal x0, count_loop        (j count_loop)
        memory[96]  = 8'h6F;
        memory[97]  = 8'hF0;
        memory[98]  = 8'h1F;
        memory[99]  = 8'hFE;

        // === count_done: ===
        // 0x064: sw x0, 0(x8)             (clear LEDs)
        memory[100] = 8'h23;
        memory[101] = 8'h20;
        memory[102] = 8'h04;
        memory[103] = 8'h00;

        // 0x068: lw x8, 0(sp)             (restore x8)
        memory[104] = 8'h03;
        memory[105] = 8'h24;
        memory[106] = 8'h01;
        memory[107] = 8'h00;

        // 0x06C: lw x6, 4(sp)             (restore x6)
        memory[108] = 8'h03;
        memory[109] = 8'h23;
        memory[110] = 8'h41;
        memory[111] = 8'h00;

        // 0x070: lw x5, 8(sp)             (restore x5)
        memory[112] = 8'h83;
        memory[113] = 8'h22;
        memory[114] = 8'h81;
        memory[115] = 8'h00;

        // 0x074: lw x1, 12(sp)            (restore ra)
        memory[116] = 8'h83;
        memory[117] = 8'h20;
        memory[118] = 8'hC1;
        memory[119] = 8'h00;

        // 0x078: addi sp, sp, 16          (deallocate stack)
        memory[120] = 8'h13;
        memory[121] = 8'h01;
        memory[122] = 8'h01;
        memory[123] = 8'h01;

        // 0x07C: jalr x0, 0(x1)           (return)
        memory[124] = 8'h67;
        memory[125] = 8'h80;
        memory[126] = 8'h00;
        memory[127] = 8'h00;
    end

endmodule