.text
.globl main

# Task 3: Sum of Array Elements
# s6 (x22) = i, s7 (x23) = sum, array a at 0x200

main:
    add s6, x0, x0          # i = 0
    addi t0, x0, 10         # loop limit = 10
    addi s7, x0, 0          # sum = 0

# Loop1: Initialize array a[0] to a[9] with values 0 to 9
Loop1:
    slli t1, s6, 2          # t1 = i * 4 (byte offset for word)
    sw s6, 0x200(t1)        # a[i] = i (store at address 0x200 + offset)
    addi s6, s6, 1          # i++
    bne s6, t0, Loop1       # if i != 10, continue loop

    add s6, x0, x0          # reset i = 0

# Loop2: Calculate sum = a[0] + a[1] up until a[9]
Loop2:
    slli t1, s6, 2          # t1 = i * 4 (byte offset)
    lw t1, 0x200(t1)        # t1 = a[i]
    add s7, s7, t1          # sum = sum + a[i]
    addi s6, s6, 1          # i++
    bne s6, t0, Loop2       # if i != 10, continue loop

end:
    j end