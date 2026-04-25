# PipelinedProcessor — Changes from the Single-Cycle Implementation

This document lists every change made to convert the existing single-cycle
RISC-V processor (`TopLevelProcessor.v`) into the 5-stage pipelined processor
(`PipelinedProcessor.v`).

## 1. New modules

Five new modules were added to support the pipeline.

| File | Role |
|------|------|
| [IF_ID.v](IF_ID.v) | Pipeline register between IF and ID. Latches the fetched PC and instruction. Supports `stall` (freeze) and `flush` (NOP injection on taken branch). |
| [ID_EX.v](ID_EX.v) | Pipeline register between ID and EX. Latches register-read data, the immediate, the funct3/funct7 fields, and all downstream control signals. |
| [EX_MEM.v](EX_MEM.v) | Pipeline register between EX and MEM. Latches the ALU result, store data, branch target, link address, branch flags, and remaining control signals. |
| [MEM_WB.v](MEM_WB.v) | Pipeline register between MEM and WB. Latches the ALU result, the loaded memory data, the link address, and the writeback control signals. |
| [HazardDetectionUnit.v](HazardDetectionUnit.v) | Detects load-use hazards and asserts `stall` for one cycle. |
| [ForwardingUnit.v](ForwardingUnit.v) | Resolves RAW hazards by forwarding `EX/MEM` and `MEM/WB` results into the EX stage. |
| [Mux3.v](Mux3.v) | 3-to-1 mux used in front of the ALU to select between the register read, the EX/MEM forward, and the MEM/WB forward. |

The single-cycle datapath modules (`ProgramCounter`, `PcAdder`, `BranchAdder`,
`Mux2`, `ImmGen`, `RegisterFile`, `ALU`, `ALUControl`, `MainControl`,
`InstructionMemory`, `DataMemory`) are reused unchanged except where noted in
section 3.

## 2. Datapath restructuring

The single-cycle datapath (`TopLevelProcessor.v`) executes one instruction per
clock with one PC mux, one ALU, one regfile read, etc. The pipelined version
keeps the same module set but slices it into five stages with pipeline
registers between them:

```
IF -> [IF_ID] -> ID -> [ID_EX] -> EX -> [EX_MEM] -> MEM -> [MEM_WB] -> WB
```

Per-stage placement:

| Stage | Modules used |
|-------|--------------|
| IF    | `ProgramCounter`, `PcAdder`, `InstructionMemory` |
| ID    | `MainControl`, `ImmGen`, `RegisterFile` (read), `HazardDetectionUnit` |
| EX    | `ForwardingUnit`, two `Mux3`, `BranchAdder`, `ALUControl`, `ALU` |
| MEM   | branch-decision logic, `DataMemory` |
| WB    | writeback mux (ALU result / memory data / PC+4 for JAL/JALR) |

Notable structural differences from the single-cycle version:

- **Branch target adder moved to EX.** The single-cycle processor placed
  `BranchAdder` next to the PC, computing `PC + (imm << 1)` from the current
  fetch PC. In the pipelined version, the branch target is computed in EX from
  `ID_EX_pc` and `ID_EX_immediateValue` so it travels through EX/MEM with the
  branch.
- **Branch decision moved to MEM.** The taken/not-taken comparison runs on
  `EX_MEM_zero` / `EX_MEM_lessThan` / `EX_MEM_func3`. JAL and JALR also resolve
  here. A taken control transfer drives `mem_pcSrc` and flushes the two
  younger instructions in IF/ID and ID/EX.
- **Two ALU-input muxes instead of one.** The single-cycle processor used a
  single `Mux2` to choose between `rs2` and `imm`. The pipelined version uses
  two `Mux3` instances driven by the forwarding unit, then a 2-input mux on
  the B input that selects between forwarded `rs2` and the immediate.
- **Writeback mux chain unchanged in spirit, fed from `MEM_WB_*`** instead of
  the live ALU/memory wires.

## 3. Changes to existing files

### `RegisterFile.v` — internal write-through bypass

Required to fix a WB->ID race that only exists in the pipelined version.

When a load-use stall holds an instruction in ID for an extra cycle, the
instruction in WB may write the same register the stalled instruction is about
to read. With pure synchronous write + async read, the ID stage latches the
**old** value (Verilog NBA semantics evaluate the RHS before the write fires).
Forwarding from EX/MEM and MEM/WB does not help because by the time the
stalled instruction reaches EX, the producing load is no longer in any
pipeline register — it has moved past WB.

Fix: bypass `writeData` directly at the read port when `rd == rs1/rs2`.

```verilog
assign readData1 = (rs1 == 5'b0) ? 32'b0 :
                   (writeEnable && rd == rs1) ? writeData :
                   regs[rs1];
assign readData2 = (rs2 == 5'b0) ? 32'b0 :
                   (writeEnable && rd == rs2) ? writeData :
                   regs[rs2];
```

This is the standard "write-in-first-half, read-in-second-half" trick
implemented combinationally. It is harmless to the single-cycle processor.

### `InstructionMemory.v` — program path

Updated `$readmemh` path from `programA.hex` to `bubble.hex` for the
pipelined bubble-sort test program.

## 4. Hazard handling

### 4.1 Load-use stall (HazardDetectionUnit)

The only stall condition. Detected in ID:

```verilog
if (ID_EX_memRead && ID_EX_rd != 0 &&
   (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2))
    stall = 1;
```

When asserted:
- `nextPc` holds (`stall ? pcOut : ...`)
- `IF_ID` does not update
- `ID_EX` is flushed to a NOP

This injects a single-cycle bubble so that the next cycle the loaded value is
available in MEM/WB and can be forwarded to EX.

### 4.2 Forwarding (ForwardingUnit)

Resolves all other RAW hazards without stalling. For each ALU operand:

| Select | Source |
|--------|--------|
| `00`   | `ID_EX` register-file read data |
| `01`   | `MEM_WB` writeback data (covers loads and 2-instruction-old ALU producers) |
| `10`   | `EX_MEM` ALU result (covers immediate-prior ALU producer) |

EX/MEM has priority over MEM/WB so that a more recent producer wins when both
match.

### 4.3 Control hazards (branches and JAL/JALR)

Resolved in MEM (3 cycles after fetch). On `mem_pcSrc`:
- `nextPc` is overridden to the computed target (`branchTarget` for taken
  branches and JAL, `EX_MEM_aluResult` for JALR — selected by the
  `EX_MEM_jalr ? aluResult : branchTarget` mux).
- `IF_ID` and `ID_EX` are flushed to NOPs.
- `EX_MEM` is also flushed; the branch's own results have already propagated
  to MEM/WB at the same clock edge so writeback (e.g. JAL's link register) is
  preserved.

The MEM-stage branch comparator was extended to handle four `funct3` values:

```verilog
(EX_MEM_func3 == 3'b000 &  EX_MEM_zero)     |  // BEQ
(EX_MEM_func3 == 3'b001 & ~EX_MEM_zero)     |  // BNE
(EX_MEM_func3 == 3'b100 &  EX_MEM_lessThan) |  // BLT
(EX_MEM_func3 == 3'b101 & ~EX_MEM_lessThan)    // BGE
```

(The original single-cycle version only handled BEQ/BNE/BGE; BLT was added
because the bubble-sort program uses it for the outer loop test.)

## 5. Testbench

[tb_PipelinedBubbleSort.v](tb_PipelinedBubbleSort.v) loads `bubble.hex`,
preloads the stack pointer, runs for 50 us, then dumps `u_dmem.memory[0..10]`
and checks against the expected sorted array.

Note: `DataMemory` is addressed by word, so `EX_MEM_aluResult[9:2]` is used
for the address (the program uses byte offsets `0, 4, 8, ...`, which the
`[9:2]` slice converts to consecutive word indices `0, 1, 2, ...`).

## 6. Naming conventions used in `PipelinedProcessor.v`

- Pipeline-register output wires use the prefix of the register they come
  from: `IF_ID_*`, `ID_EX_*`, `EX_MEM_*`, `MEM_WB_*`.
- Stage-local combinational wires use a lowercase stage prefix, e.g.
  `ex_branchTarget`, `ex_pcPlus4`, `mem_pcSrc`, `mem_branchTaken`,
  `wb_aluOrMem`.
- Everything else stays in the project's standard camelCase / PascalCase
  convention.
