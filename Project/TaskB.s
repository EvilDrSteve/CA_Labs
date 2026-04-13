.globl main
.text
main:
    li   sp, 0x80          # init stack (data memory region)
    li   x8, 0x100         # LED address
    li   x9, 0x200         # switch address
    li   x11, 8            # threshold

spin:
    lw   x10, 0(x9)        # read switches
    beq  x10, x0, spin     # wait until non-zero

    # --- BGE demo ---
    bge  x10, x11, big     # if switches >= 8 take 'big' path

small:
    jal  x1, doubleIt      # call doubleIt(x10) -> x10
    j    show

big:
    jal  x1, halveIt       # call halveIt(x10) -> x10 (SRL by 1 via subtracting)
    j    show

show:
    sw   x10, 0(x8)        # display result on LEDs
    j    spin              # loop forever

# ---------------------------------------------
# doubleIt: x10 = x10 + x10
# ---------------------------------------------
doubleIt:
    addi sp, sp, -4
    sw   x1, 0(sp)

    add  x10, x10, x10

    lw   x1, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(x1)         # return

# ---------------------------------------------
# halveIt: x10 = x10 - 1  (placeholder op, since SRLI may not be supported)
# ---------------------------------------------
halveIt:
    addi sp, sp, -4
    sw   x1, 0(sp)

    srli x10, x10, 1

    lw   x1, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(x1)         # return
