.text
.globl main
main:
    li x18, 5 #a

    addi x19, x0, 0 #b
    addi x18, x19, 32 # a = b + 32

    add x5, x18, x19 # a + b
    addi x20, x5, -5 # d = (a + b) - 5
    
    sub x6, x18, x20 # a - d
    sub x5, x19, x18 # b - a
    add x6,x6,x5 # (a - d) + (b - a)
    add x21, x6,x20 #e

    add x6, x20,x21 #d + e
    add x5, x18, x19 # a + b
    add x21,x5,x6 # a + b + d + e

end:
    j end