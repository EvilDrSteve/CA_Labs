.text
.globl main
main:

    addi x5, x0, 19 # n

    add x10, x5, x0 #pass as argument
    jal x1, ntri

    beq x0, x0, exit

    ntri:
        #allocate
        addi sp, sp, -8
        sw x1, 4(sp)
        sw x10, 0(sp)
        #

        addi x10, x10, -1 # num--
        bgt x10, x0, else #if n > 0: else
        addi x10, x0, 1 # return 1
        addi sp, sp 8 #deallocate
        jalr x0, 0(x1) #return

        else:
            jal x1, ntri #ntri(num - 1)
            addi x5, x10, 0 # save returned value in x5

            #deallocate
            lw x10, 0(sp)
            lw x1, 4(sp)
            addi sp, sp, 8
            #

            add x10, x10, x5 # return num + returned value

            jalr x0, 0(x1)


exit:
    j exit