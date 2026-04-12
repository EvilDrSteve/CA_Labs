.globl main
.text
main:
    li   x8,  0x20        # LED address
    li   x9,  0x30        # switch address
    li   x18, 0x40        # reset address

    # beq x0, x0, SkipSetup
    addi x5, x0, 10
    sw x5, 0(x9)

    SkipSetup:

idle:
    lw   x7, 0(x9)         # read switches
    beq  x7, x0, idle      # if switches == 0, keep waiting

    #call countdown
    mv   x10, x7            # pass latched value as argument
    jal  x1, countdown
    sw   x0, 0(x9)         # clear switches so we don't re-enter

    j    idle


countdown:
    #Allocate Stack
    addi sp, sp, -16
    sw   x1, 12(sp)         
    sw   x5, 8(sp)         
    sw   x6, 4(sp)        
    sw   x8, 0(sp)         


    mv   x5, x10            # x5 = counter

count_loop:
    sw   x5, 0(x8)         # display counter on LEDs

    beq  x5, x0, count_done   # if counter == 0, done

    lw   x6, 0(x18)        # x6 = reset button
    bne  x6, x0, count_done   # if reset pressed, exit countdown

    addi x5, x5, -1        # decrement counter

    # delay so LEDs are visible
    li   x6, 1
delay:
    addi x6, x6, -1
    bne  x6, x0, delay

    j    count_loop

count_done:
    sw   x0, 0(x8)         # clear LEDs

    #Deallocate stack
    lw   x8, 0(sp)
    lw   x6, 4(sp) 
    lw   x5, 8(sp) 
    lw   x1, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(x1)                    