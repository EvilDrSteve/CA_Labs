.text
.globl main
main:

    addi x5, x0, 2 #n
    addi x6, x0, 1 #result

    addi sp, sp, 8
    sw x5, 4(sp)
    sw x5, 0(sp)

    fact:

        ble x5, x0, end # check if n <= 0
        mul x6, x6, x5 # result *= n
        addi x5, x5, -1 #n--
        beq x0, x0, fact #loop again


    end:
        add x10, x6, x0
        lw x5, 0(sp)
        lw x6, 4(sp)
        addi sp, sp, -8
        beq x0, x0, exit

exit:
    j exit