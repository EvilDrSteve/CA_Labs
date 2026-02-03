.text
.globl main

main:
    addi x10, x0, 5 # base
    addi x11, x0, 5 #exp

    jal x1, exp

    beq x0, x0, exit

    exp: 
        #allocate stack
        addi sp, sp, -12
        sw x1, 8(sp)
        sw x10, 4(sp)
        sw x11, 0(sp)
        

        #base case
        bgt x11, x0, else
        addi x10, x0, 1

        addi sp, sp, 12

        jalr x0, 0(x1)

        #recursive
        else:
            addi x11, x11, -1 #exp--
            jal x1, exp
            add x5, x10, x0

            #deallocate stack
            lw x1, 8(sp)
            lw x10, 4(sp)
            lw x11, 0(sp)
            addi sp, sp, 12
            
            #multiply and return for prev call
            mul x10, x10, x5
            

            

            jalr x0, 0(x1)




exit:
    j exit