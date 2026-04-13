# FPGA Fibonacci Program
main:
    ADDI x2, x0, 252       # sp (x2) = 252 (Top of Data Memory)
    ADDI x8, x0, 0x100     # x8 = 0x100 (LED Memory Map Address)
    ADDI x5, x0, 1         # a = 1
    ADDI x6, x0, 1         # b = 1

loop:
    SW x5, 0(x8)           # Output 'a' to the LEDs!
    
    ADD x10, x0, x5        # a0 = a
    ADD x11, x0, x6        # a1 = b
    JAL x1, calc_fib       # Call procedure, save PC+4 to ra (x1)
    
    ADD x5, x0, x10        # a = old_b
    ADD x6, x0, x11        # b = new_fib
    
    JAL x0, loop           # Infinite loop

calc_fib:
    ADDI x2, x2, -4        # Decrement stack pointer
    SW x1, 0(x2)           # Push ra to stack
    
    ADD x7, x10, x11       # t2 = a + b
    ADD x10, x0, x11       # Return a0 = old_b
    ADD x11, x0, x7        # Return a1 = new_fib
    
    LW x1, 0(x2)           # Pop ra from stack
    ADDI x2, x2, 4         # Increment stack pointer
    JALR x0, 0(x1)         # Return