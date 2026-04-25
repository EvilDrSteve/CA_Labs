.text
.globl main

main:
    # choose a safe memory base (example address)
    addi sp, x0, 0x80
    addi x10, x0, 0   # base address of array
    addi x11, x0, 11           # size

    jal x1, makeArray
    jal x1, bubble

exit:
    j exit


# --------------------------------------------------
# makeArray: manually initialize array
# x10 = base address
# --------------------------------------------------
makeArray:
    addi sp, sp, -8
    sw x1, 4(sp)
    sw x6, 0(sp)

    addi x6, x0, 23
    sw x6, 0(x10)

    addi x6, x0, 12
    sw x6, 4(x10)

    addi x6, x0, 5
    sw x6, 8(x10)

    addi x6, x0, 44
    sw x6, 12(x10)

    addi x6, x0, 98
    sw x6, 16(x10)

    addi x6, x0, 53
    sw x6, 20(x10)

    addi x6, x0, 6
    sw x6, 24(x10)

    addi x6, x0, 89
    sw x6, 28(x10)

    addi x6, x0, 32
    sw x6, 32(x10)

    addi x6, x0, 65
    sw x6, 36(x10)

    addi x6, x0, 5
    sw x6, 40(x10)

    lw x6, 0(sp)
    lw x1, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(x1)

# --------------------------------------------------
# bubble sort (ascending)
# x10 = base address
# x11 = size
# --------------------------------------------------
bubble:
    addi sp, sp, -16
    sw x1, 12(sp)
    sw x5, 8(sp)
    sw x6, 4(sp)
    sw x7, 0(sp)

    li x5, 0              # i = 0

outer_loop:
    li x6, 0              # j = 0

    sub x7, x11, x5
    addi x7, x7, -1       # limit = size - i - 1

inner_loop:
    bge x6, x7, next_outer

    slli x8, x6, 2        # offset = j * 4
    add x8, x8, x10       # address of a[j]

    lw x9, 0(x8)          # a[j]
    lw x12, 4(x8)         # a[j+1]

    ble x9, x12, no_swap

    # swap
    sw x12, 0(x8)
    sw x9, 4(x8)

no_swap:
    addi x6, x6, 1
    j inner_loop

next_outer:
    addi x5, x5, 1
    blt x5, x11, outer_loop

    # restore
    lw x1, 12(sp)
    lw x5, 8(sp)
    lw x6, 4(sp)
    lw x7, 0(sp)
    addi sp, sp, 16

    jalr x0, 0(x1)