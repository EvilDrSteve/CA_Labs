.text
.globl main
main:
# Arrays: A (char) at 0x100, B (short) at 0x200, C (unsigned int) at 0x300
# Implement: c[i] = a[i] + b[i] for i = 0 to 3

    # Initialize array A (char)
    addi t0, x0, 10
    sb t0, 0x100(x0)      # A[0] = 10

    addi t0, x0, 20
    sb t0, 0x101(x0)      # A[1] = 20

    addi t0, x0, 30
    sb t0, 0x102(x0)      # A[2] = 30

    addi t0, x0, 40
    sb t0, 0x103(x0)      # A[3] = 40

    # Initialize array B (short)
    addi t0, x0, 10
    sh t0, 0x200(x0)      # B[0] = 10

    addi t0, x0, 20
    sh t0, 0x202(x0)      # B[1] = 20

    addi t0, x0, 30
    sh t0, 0x204(x0)      # B[2] = 30

    addi t0, x0, 40
    sh t0, 0x206(x0)      # B[3] = 40


    # C[0] = A[0] + B[0]
    lb t0, 0x100(x0)
    lh t1, 0x200(x0)
    add t0, t0, t1
    sw t0, 0x300(x0)

    # C[1] = A[1] + B[1]
    lb t0, 0x101(x0)
    lh t1, 0x202(x0)
    add t0, t0, t1
    sw t0, 0x304(x0)

    # C[2] = A[2] + B[2]
    lb t0, 0x102(x0)
    lh t1, 0x204(x0)
    add t0, t0, t1
    sw t0, 0x308(x0)

    # C[3] = A[3] + B[3]
    lb t0, 0x103(x0)
    lh t1, 0x206(x0)
    add t0, t0, t1
    sw t0, 0x30C(x0)

end:
    j end