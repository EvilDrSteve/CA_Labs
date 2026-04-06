.text
.globl main

# Task 2: Switch Statement
# x20 = x, x21 = a, x22 = b, x23 = c

main: 
    addi x20, x0, 3         # x = 3 (test value, change to 1,2,3,4,5)
    addi x22, x0, 10        # b = 10
    addi x23, x0, 15        # c = 15

    addi t0, x0, 1          # t0 = 1 for case comparison
    beq x20, t0, ONE        # if x == 1, jump to ONE
    
    addi t0, t0, 1          # t0 = 2
    beq x20, t0, TWO        # if x == 2, jump to TWO
    
    addi t0, t0, 1          # t0 = 3
    beq x20, t0, THREE      # if x == 3, jump to THREE
    
    addi t0, t0, 1          # t0 = 4
    beq x20, t0, FOUR       # if x == 4, jump to FOUR
    
    add x21, x0, x0         # default: a = 0
    beq x0, x0, EXIT        # jump to exit

    ONE:
        add x21, x22, x23   # a = b + c = 25
        beq x0, x0, EXIT
    TWO:
        sub x21, x22, x23   # a = b - c = -5
        beq x0, x0, EXIT
    THREE:
        slli x21, x22, 1    # a = b * 2 = 20 (shift left by 1)
        beq x0, x0, EXIT
    FOUR:
        srli x21, x22, 1    # a = b / 2 = 5 (shift right by 1)
        beq x0, x0, EXIT
    EXIT:

end:
    j end