.text
.globl main

main:
    li x10, 0x200
    li x11, 0x300

    #Dummy array v
    addi x5, x0, 't'
    sb x5, 0(x11)

    addi x5, x0, 'e'
    sb x5, 1(x11)

    addi x5, x0, 's'
    sb x5, 2(x11)

    addi x5, x0, 't'
    sb x5, 3(x11)
    
    sb x0, 4(x11) #null character

    jal x1, strcpy
    beq x0, x0, exit

    strcpy:

        #allocate
        addi sp, sp, -12
        sw x19, 8(sp)
        sw x5, 4(sp)
        sw x6, 0(sp)

        #i = 0
        addi x19, x0, 0        

        Loop:
            #calculate x[i]
            add x6, x19, x10
            
            #calculate y[i]
            add x5, x19, x11
            lb x5, 0(x5) #load y[i]

            sb x5, 0(x6) #x[i] = y[i]

            beq x5, x0, Loop_End # end if x[i] == null character
            addi x19, x19, 1    # i += 1
            beq x0, x0, Loop #rerun loop

        Loop_End:

            #deallocate
            lw x6, 0(sp)
            lw x5, 4(sp)
            lw x19, 8(sp)
            addi sp, sp, 12

            #return
            jalr x0, 0(x1)

            
exit:
    j exit