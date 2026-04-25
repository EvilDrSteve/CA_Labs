.text
.globl main

# ============================================================
# pipeline_demo.s — Showcase program for the 3-minute video.
# Designed so each pipeline behaviour is visible in one screen
# of waveform (~18 cycles of useful execution).
#
#   PC  hex        instruction         what to point at
#   --  --------   -----------------   ----------------------
#   00  00500093   addi x1, x0, 5      pipeline fill
#   04  00a00113   addi x2, x0, 10     pipeline fill
#   08  002081b3   add  x3, x1, x2     forwardA=01 (MEM/WB), forwardB=10 (EX/MEM)
#   0C  00318233   add  x4, x3, x3     forwardA=10, forwardB=10 (both EX/MEM)
#   10  00402023   sw   x4, 0(x0)      forwardB=10 (EX/MEM) for store data
#   14  00002283   lw   x5, 0(x0)      sets up the load-use hazard
#   18  00128333   add  x6, x5, x1     LOAD-USE: stall=1 one cycle, then MEM/WB forward
#   1C  00000663   beq  x0, x0, +12    always taken -> mem_pcSrc=1, flush IF/ID + ID/EX
#   20  06300393   addi x7, x0, 99     FLUSHED (x7 stays 0)
#   24  05800413   addi x8, x0, 88     FLUSHED (x8 stays 0)
#   28  04d00493   addi x9, x0, 77     branch target — executes
#   2C  0000006f   j halt              halt loop (jumps to itself)
# ============================================================
/*
pcOut   | Wave time (ns) | EX stage holds                     | What to highlight
--------|----------------|------------------------------------|-------------------------------
4 → 12  | 25 – 55        | (filling: NOP → addi x1 → addi x2) | Pipeline fills. After 3 cycles all 4 regs populated.
16      | 55 – 65        | add x3                             | First forwarding:
        |                |                                    |   forwardA=01 (MEM/WB → x1=5)
        |                |                                    |   forwardB=10 (EX/MEM → x2=10)
20      | 65 – 75        | add x4                             | Back-to-back:
        |                |                                    |   forwardA=10, forwardB=10 (both from EX/MEM, x3)
24      | 75 – 85        | sw x4                              | forwardB=10 (store data x4 from EX/MEM)
28      | 85 – 95        | lw x5                              | stall=1 (load-use hazard with add x6 in ID)
28(frz) | 95 – 105       | NOP (bubble)                       | PC frozen; ID/EX becomes NOP
32      | 105 – 115      | add x6                             | Load-use resolved:
        |                |                                    |   forwardA=01 (MEM/WB → x5=30)
36      | 115 – 125      | beq                                | ALU: 0-0=0 → zeroFlag=1 (branch taken next)
40      | 125 – 135      | addi x7                            | mem_pcSrc=1; branch target=40
40(held)| 135 – 145      | NOP (flushed)                      | IF/ID, ID/EX, EX/MEM flushed
        |                |                                    | addi x7/x8 never reach EX/MEM
44 → 56 | 145 – 185      | (addi x9 flows)                    | addi x9 completes pipeline
—       | 185            | —                                  | regs[9]=77; regs[7]=0, regs[8]=0 (flush confirmed)
*/
main:
    addi x1, x0, 5            # pipeline fill
    addi x2, x0, 10           # pipeline fill
    add  x3, x1, x2           # 5 + 10 = 15  — forwarding demo
    add  x4, x3, x3           # 15 + 15 = 30 — back-to-back forwarding
    sw   x4, 0(x0)            # mem[0] = 30
    lw   x5, 0(x0)            # x5 = 30 (sets up load-use)
    add  x6, x5, x1           # 30 + 5 = 35  — load-use stall
    beq  x0, x0, target       # always taken — flush demo
    addi x7, x0, 99           # FLUSHED
    addi x8, x0, 88           # FLUSHED
target:
    addi x9, x0, 77           # 77

halt:
    j halt                    # spin forever


# Cycle →        1   2   3   4   5   6   7   8   9   10  11  12
# ----------------------------------------------------------------
# addi x1, x0, 5        IF  ID  EX  MEM WB
# addi x2, x0, 10           IF  ID  EX  MEM WB
# add  x3, x1, x2               IF  ID  EX  MEM WB
# add  x4, x3, x3                   IF  ID  EX  MEM WB
# sw   x4, 0(x0)                      IF  ID  EX  MEM WB
# lw   x5, 0(x0)                         IF  ID  EX  MEM WB
# add  x6, x5, x1                           IF  ID  ST  EX  MEM WB
# beq  x0, x0, target                          IF  ID  EX  MEM WB
# addi x7, x0, 99                                IF  ID  FL
# addi x8, x0, 88                                    IF  FL