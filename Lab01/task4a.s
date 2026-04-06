.text
.globl main
main:
    #Initialize registers
    li x10, 0x78786464
    li x11, 0xA8A81919

    #Store x10 as unsigned integer at address 0x100.
    sw x10, 0x100(x0)

    # Store x11 as unsigned integer at address 0x1F0.
    sw x11, 0x1F0(x0)


    # Load an unsigned short integer (two bytes) from address 0x100 in x12.
    lw x12, 2(t5)

    # Load a short integer from address 0x1F0 in register x13.
    lw x13, 2(t6)

    # Load a singed character from address 0x1F0 in register 0x14.
    lw x14, 8(t6)

end:
    j end