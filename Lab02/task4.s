.text
.globl main

# Task 4: Nested Loop - D[4*j] = i + j
# x5 = a, x6 = b, x7 = i, x29 = j, x10 = D base address

main:
    addi x5, x0, 2          # a = 2
    addi x6, x0, 2          # b = 2
    addi x7, x0, 0          # i = 0
    li x10, 0x200           # D array base address

    Loop1:
        beq x7, x5, Exit    # if i == a, exit
        addi x29, x0, 0     # j = 0
        beq x0, x0, Loop2   # jump to inner loop

    Loop1_End:
        addi x7, x7, 1      # i++
        beq x0, x0, Loop1   # continue outer loop

    Loop2:
        beq x29, x6, Loop1_End  # if j == b, exit inner loop

        add t3, x7, x29     # t3 = i + j
        slli t5, x29, 4     # t5 = j * 16 (offset for D[4*j])
        add t5, t5, x10     # t5 = base + offset
        sw t3, 0(t5)        # D[4*j] = i + j

        addi x29, x29, 1    # j++
        beq x0, x0, Loop2   # continue inner loop

    Exit:

end:
    j end