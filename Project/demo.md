# Deep Dive: Processor Pipelining and Hazard Handling

Pipelining means multiple instructions are in different stages at the same time. After the first few cycles (pipeline fill), every cycle has up to 5 instructions in flight.

## 1. Pipelining Overview & Timeline

### The 5-Stage Pipeline
1.  **IF**: Instruction Fetch
2.  **ID**: Instruction Decode & Register Read
3.  **EX**: Execute or Address Calculation
4.  **MEM**: Data Memory Access
5.  **WB**: Write Back to Register

### Cycle vs Instructions Timeline

| Cycle → | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `addi x1, x0, 5` | IF | ID | EX | MEM | WB | | | | | | | |
| `addi x2, x0, 10` | | IF | ID | EX | MEM | WB | | | | | | |
| `add x3, x1, x2` | | | IF | ID | EX | MEM | WB | | | | | |
| `add x4, x3, x3` | | | | IF | ID | EX | MEM | WB | | | | |
| `sw x4, 0(x0)` | | | | | IF | ID | EX | MEM | WB | | | |
| `lw x5, 0(x0)` | | | | | | IF | ID | EX | MEM | WB | | |
| `add x6, x5, x1` | | | | | | | IF | ID | **STALL** | EX | MEM | WB |
| `beq x0, x0, target` | | | | | | | | IF | ID | EX | MEM | WB |
| `addi x7, x0, 99` | | | | | | | | | IF | ID | **FLUSH** | |
| `addi x8, x0, 88` | | | | | | | | | | IF | **FLUSH** | |

* **Pipeline fill:** first 2–3 cycles
* **Full overlap:** cycles ~4–8

Hazards handled in this timeline:
* **Forwarding:** (x3, x4)
* **Stall:** (load-use between lw and add)
* **Flush:** (branch)

---

## 2. Forwarding (Data Hazards Resolved Without Stalls)

Forwarding allows the pipeline to use results as soon as they are computed, avoiding stalls.

### Case A: ALU to ALU Forwarding
`add x3, x1, x2`

* **Problem:** `x1` and `x2` are not yet written back when `add x3` needs them.
* **Solution (Forwarding):** At Cycle 4 (EX stage of `add x3`):
    * `x1` comes from: `addi x1` → MEM stage → EX forwarding
    * `x2` comes from: `addi x2` → EX stage → EX forwarding
* 👉 **Forward paths used:**
    * `EX/MEM → EX` (x1)
    * `MEM/WB → EX` (x2 depending on timing)

### Case B: Direct ALU Chain
`add x4, x3, x3`

* **Problem:** `x3` just computed in previous instruction.
* **Solution:** At Cycle 5 (EX stage of `add x4`):
    * `x3` comes from: `add x3` → EX/MEM pipeline register
* 👉 **Both operands use:** `EX/MEM → EX` forwarding (same value twice)

---

## 3. Store Uses Forwarded Value

`sw x4, 0(x0)`

* **Problem:** `x4` not written back yet.
* **Solution:** At Cycle 6 (MEM stage of `sw`):
    * `x4` forwarded from: `add x4` → MEM/WB or EX/MEM
* 👉 **Forward path used:** `EX/MEM → MEM` (store data path)

---

## 4. Load-Use Hazard (The ONLY Stall)

`lw  x5, 0(x0)`
`add x6, x5, x1`

* **Problem:** Load result (`x5`) is only ready after MEM stage, but next instruction needs it in EX immediately.
* **What happens:** 1-cycle stall inserted.

**Timeline:**
* **Cycle 7:** `lw` in EX
* **Cycle 8:** `lw` in MEM → data ready
* **Cycle 8:** `add x6` STALL (bubble)
* **Cycle 9:** `add x6` EX → now gets forwarded data

* **Forwarding at Cycle 9 (EX of add x6):**
    * `x5` comes from: `MEM/WB → EX` forwarding
    * `x1` comes from register file (already written)

---

## 5. Branch Hazard (Flush)

`beq x0, x0, target`

* **Behavior:** Always taken. Decision made in EX stage.
* **What gets flushed:** Instructions already fetched (`addi x7`, `addi x8`).

**Timeline:**
* **Cycle when beq is in EX:** branch resolved
* **Next cycle:** Instructions in IF/ID are invalidated
* 👉 **Flush occurs in:** IF and ID stages

---

## 6. Summary of Forwarding Paths Used

* **EX → EX forwarding**
    * `add x3` gets `x2`
    * `add x4` gets `x3`
* **MEM → EX forwarding**
    * `add x3` gets `x1`
    * `add x6` gets `x5` (after stall)
* **EX/MEM → MEM (store)**
    * `sw` gets `x4`

---

## 7. Key Insights

1.  **No stalls for ALU chains** thanks to forwarding (`x1/x2 → x3 → x4`).
2.  **Exactly 1 stall** for load-use (`lw → add`).
3.  **Branch causes 2 instruction flush**.
4.  **Pipeline is fully utilized except:**
    * Initial fill
    * 1 bubble (load-use)
    * Flush penalty