`timescale 1ns / 1ps

module instructionMemory_tb;

    reg [31:0] instAddress;
    wire [31:0] instruction;

    instructionMemory uut (
        .instAddress(instAddress),
        .instruction(instruction)
    );

    integer pass_count;
    integer fail_count;

    task check;
        input [31:0] addr;
        input [31:0] expected;
        input [255:0] asm_str;  // wide enough for string
        begin
            instAddress = addr;
            #1;
            if (instruction === expected) begin
                $display("PASS  0x%03H: 0x%08H  %0s", addr, instruction, asm_str);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  0x%03H: got 0x%08H, expected 0x%08H  %0s", addr, instruction, expected, asm_str);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        instAddress = 0;

        $display("");
        $display("=== Instruction Memory Verification ===");
        $display("Addr      Hex         Assembly");
        $display("----------------------------------------------");

        // === main ===
        check(32'h000, 32'h20000413, "addi x8, x0, 0x200");
        check(32'h004, 32'h30000493, "addi x9, x0, 0x300");
        check(32'h008, 32'h40000913, "addi x18, x0, 0x400");
        check(32'h00C, 32'h00A00293, "addi x5, x0, 10");
        check(32'h010, 32'h0054A023, "sw x5, 0(x9)");

        // === idle ===
        check(32'h014, 32'h0004A383, "lw x7, 0(x9)");
        check(32'h018, 32'hFE038EE3, "beq x7, x0, idle");
        check(32'h01C, 32'h00038513, "mv x10, x7");
        check(32'h020, 32'h008000EF, "jal x1, countdown");
        check(32'h024, 32'hFF1FF06F, "j idle");

        // === countdown ===
        check(32'h028, 32'hFF010113, "addi sp, sp, -16");
        check(32'h02C, 32'h00112623, "sw x1, 12(sp)");
        check(32'h030, 32'h00512423, "sw x5, 8(sp)");
        check(32'h034, 32'h00612223, "sw x6, 4(sp)");
        check(32'h038, 32'h00812023, "sw x8, 0(sp)");
        check(32'h03C, 32'h00050293, "mv x5, x10");

        // === count_loop ===
        check(32'h040, 32'h00542023, "sw x5, 0(x8)");
        check(32'h044, 32'h02028063, "beq x5, x0, count_done");
        check(32'h048, 32'h00092303, "lw x6, 0(x18)");
        check(32'h04C, 32'h00031C63, "bne x6, x0, count_done");
        check(32'h050, 32'hFFF28293, "addi x5, x5, -1");
        check(32'h054, 32'h00100313, "li x6, 1");

        // === delay ===
        check(32'h058, 32'hFFF30313, "addi x6, x6, -1");
        check(32'h05C, 32'hFE031EE3, "bne x6, x0, delay");
        check(32'h060, 32'hFE1FF06F, "j count_loop");

        // === count_done ===
        check(32'h064, 32'h00042023, "sw x0, 0(x8)");
        check(32'h068, 32'h00012403, "lw x8, 0(sp)");
        check(32'h06C, 32'h00412303, "lw x6, 4(sp)");
        check(32'h070, 32'h00812283, "lw x5, 8(sp)");
        check(32'h074, 32'h00C12083, "lw x1, 12(sp)");
        check(32'h078, 32'h01010113, "addi sp, sp, 16");
        check(32'h07C, 32'h00008067, "jalr x0, 0(x1)");

        $display("----------------------------------------------");
        $display("Results: %0d PASSED, %0d FAILED out of 32 instructions", pass_count, fail_count);
        $display("=== Test Complete ===");
        $display("");
        $finish;
    end

endmodule