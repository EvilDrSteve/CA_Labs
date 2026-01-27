.text
.globl main

main:
    addi x10, x0, 5 #g
    addi x11, x0, 9 #h
    addi x12, x0, 2 #i
    addi x13, x0, 3 #j
    
    # original values in registers
    # to show the function does not change them

    addi x18, x0, 5 
    addi x19, x0, 6
    addi x20, x0, 7

    #function call
    jal x1, leaf_example

    #print to console
    add x11, x0, x10
    addi x10, x0, 1
    ecall
    
    #end so no infinite loop
    beq x0, x0, exit

    leaf_example:
        addi sp, sp, -12
        sw x18, 8(sp)
        sw x19, 4(sp)
        sw x20, 0(sp)

        #function operations
        add x18, x10, x11
        add x19, x12, x13
        sub x20, x18, x19
        add x10, x0, x20

        lw x20, 0(sp)
        lw x19, 4(sp)
        lw x18, 8(sp)
        addi sp, sp, 12

        jalr x0, 0(x1)
exit:
    j exit