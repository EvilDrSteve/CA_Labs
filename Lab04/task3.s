.text
.globl main
main:
    
    addi x5, x0, 0x200 # array address
    addi x6, x0, 11 # array address

    add x10, x0, x5 #pass array address as argument
    add x11, x0, x6 #pass size
    jal x1, makeArray

    jal x1, bubble

    
    beq x0, x0, exit


    bubble:
        #allocate to stack
        addi sp, sp, -24
        sw x12, 20(sp)
        sw x9, 16(sp)
        sw x8, 12(sp)
        sw x7, 8(sp)
        sw x6, 4(sp)
        sw x5, 0(sp)
        #

        addi x5, x0, 0 # i = 0

        Loop1:
            add x6, x0, x5 #j = 0
            Loop2:

                slli x7, x5, 2 #i * 4
                slli x8, x6, 2 #j * 4

                add x7, x7, x10 #offset i + base
                add x8, x8, x10 #offset j + base
                lw x9, 0(x7) # a[i]
                lw x12, 0(x8) # a[j]

                bge x9, x12, end # a[i] >= a[j] : end
                
                #swap
                sw x12, 0(x7)
                sw x9, 0(x8)

            end:
                addi x6, x6, 1 #j++
                blt x6, x11, Loop2
                beq x0, x0, Loop1_End
        
        Loop1_End:
            addi x5, x5, 1 #i++
            blt x5, x11, Loop1 # i < len : repeat

            #deallocate
            lw x12, 20(sp)
            lw x9, 16(sp)
            lw x8, 12(sp)
            lw x7, 8(sp)
            lw x6, 4(sp)
            lw x5, 0(sp)
            addi sp, sp, 24
            #

            jalr x0 0(x1)




makeArray:
    addi sp, sp, -4
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
    addi sp, sp, 4
    jalr x0, 0(x1)

exit:
    j exit