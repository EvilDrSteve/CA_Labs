# 5-Stage Pipeline Execution Analysis (RISC-V)

## 1. Where pipelining occurs

Pipelining means multiple instructions are in different stages at the same time. After the first few cycles (pipeline fill), every cycle has up to 5 instructions in flight.

### Pipeline timeline (cycles vs instructions)

```text
Cycle →   1   2   3   4   5   6   7   8   9   10  11  12
-------------------------------------------------------
addi x1   IF  ID  EX  MEM WB
addi x2       IF  ID  EX  MEM WB
add x3            IF  ID  EX  MEM WB
add x4                IF  ID  EX  MEM WB
sw x4                     IF  ID  EX  MEM WB
lw x5                         IF  ID  EX  MEM WB
add x6                            IF  ID  ST  EX  MEM WB
beq                                 IF  ID  EX  MEM WB
addi x7                                IF  ID  FLUSH
addi x8                                    IF  FLUSH