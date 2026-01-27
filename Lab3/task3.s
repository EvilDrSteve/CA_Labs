.text
.globl main
main:
    li x10, 0x200 #v[]
    addi x11, x0, 2 #k

    #Dummy array v
    addi x5, x0, 1
    sw x5, 0(x10)

    addi x5, x5, 1
    sw x5, 4(x10)

    addi x5, x5, 1
    sw x5, 8(x10)

    addi x5, x5, 1
    sw x5, 12(x10)


    #function call
    jal x1, swap

    beq x0, x0, exit

    swap:
        #allocate
        addi sp, sp, -12
        sw x5, 8(sp)
        sw x6, 4(sp)
        sw x7, 0(sp)

        slli x5, x11, 2 # k * 4 = offset

        add x7, x10, x5 # base + offset
        lw x5, 0(x7) # temp = v[k]

        lw x6, 4(x7)    #load v[k+1]

        sw x6, 0(x7) # v[k] = x6

        sw x5, 4(x7) # v[k+1] = temp

        #deallocate
        lw x7, 0(sp)
        lw x6, 4(sp)
        lw x5, 8(sp)
        addi sp, sp, 12

        jalr x0, 0(x1) 


exit:
    j exit