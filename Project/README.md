# RISC-V Single-Cycle Processor — Final Project

Single-cycle RV32I processor in Verilog, targeting the **Basys3 FPGA** (xc7a35tcpg236-1) with Xilinx Vivado. Extended from Lab 11 with new instructions and a set of demo programs.

## Deliverables

| Task | Description | Program | Bitstream |
|------|-------------|---------|-----------|
| A | Lab 10 IDLE/COUNTDOWN FSM on the integrated processor | `programA.hex` / `TaskA.s` | `TaskA.bit` |
| B | Adds JAL, JALR, LUI, BGE, SRLI — demo uses all of them | `ProgramB.hex` / `TaskB.s` | `TaskB.bit` |
| C | Procedure-call program with stack-based register saving | `programC.hex` / `TaskC.s` | `TaskC.bit` |

## Program Descriptions

### Task A — IDLE / COUNTDOWN FSM (`TaskA.s`)

Ports the Lab 10 FSM onto the single-cycle processor. The program idles until any switch is raised, then counts the switch value down to zero on the LEDs.

- **Idle state**: loops on `lw x7, 0(x9)` until the switch word is non-zero.
- **Countdown state**: calls the `countdown` procedure with the switch value as its argument. Decrements once per iteration and writes the running counter to the LEDs.
- **Done**: clears LEDs and returns to idle via `jalr`.

**Switch behavior**: the 16 switches are read as a 32-bit word. Any non-zero value starts the countdown from that value — e.g. SW0 up = 1, SW3 up = 8, SW0+SW1 up = 3. Pressing the center button (reset) at any time restarts the CPU.

### Task B — JAL / JALR / BGE / SRLI Demo (`TaskB.s`)

Exercises the new instructions by branching on the switch value and dispatching to one of two subroutines.

- Reads the switch word into `x10`.
- **`bge x10, x11, big`** — if switches ≥ 8, takes the `big` branch; otherwise falls through to `small`.
- **`jal x1, doubleIt`** (small path) — `x10 ← x10 + x10`, return via **`jalr x0, 0(x1)`**.
- **`jal x1, halveIt`** (big path) — `x10 ← x10 >> 1` using **`srli`**, return via **`jalr`**.
- Result is written to LEDs and the loop repeats.

**Switch behavior**: the raw switch value drives both the branch decision and the subroutine input.
- SW = 1 → LEDs = 2 (doubled)
- SW = 4 → LEDs = 8 (doubled)
- SW = 8 → LEDs = 4 (halved)
- SW = 12 → LEDs = 6 (halved)

### Task C — Fibonacci with Stack-Saved Procedure Call (`TaskC.s`)

Generates the Fibonacci sequence in an infinite loop, displaying each term on the LEDs. Demonstrates a proper procedure call using the stack to preserve the return address.

- `x5` and `x6` hold the two running Fibonacci terms (`a`, `b`), initialized to 1.
- Each iteration writes `a` to the LEDs, then calls `calc_fib` via `jal` to produce the next pair.
- `calc_fib` saves `ra` (`x1`) to the stack, computes `a + b`, shifts the pair, restores `ra`, and returns via `jalr`.
- The stack pointer starts at 252 (top of the 256-byte data memory region).

**Switch behavior**: Task C is a pure output demo — switches are not read. Use reset to restart the sequence. (The sequence runs freely and the CPU clock divider in `clkDivider.v` determines how fast terms scroll by on the LEDs.)

## Directory Layout

```
Project/
├── Finalized/              # Stable datapath modules (locked from earlier labs)
│   ├── ALU.v
│   ├── AddressDecoder.v
│   ├── DataMemory.v
│   ├── Debouncer.v
│   ├── Leds.v
│   ├── Mux2.v
│   ├── PcAdder.v
│   ├── ProgramCounter.v
│   ├── RegisterFile.v
│   └── Switches.v
├── TopLevelProcessor.v     # Wires the whole datapath together
├── FpgaTop.v               # Board-level wrapper (clock divider, 7-seg driver, peripherals)
├── MainControl.v           # Opcode → control signals
├── ALUControl.v            # aluOp + funct3/funct7 → 4-bit ALU op
├── ImmGen.v                # Sign-extends I/S/B/J/U immediates
├── InstructionMemory.v     # 64-word ROM (loaded from programX.hex)
├── BranchAdder.v           # PC + (imm << 1)
├── Mux4.v                  # Writeback source mux
├── SevenSegmentDriver.v    # 4-digit multiplexed 7-seg controller
├── SevenSegmentDecoder.v   # Hex nibble → 7-seg pattern
├── BinaryToBCD.v           # Binary → BCD for decimal display
├── clkDivider.v            # 100 MHz → slow CPU clock
├── SevenSegmentDisplay.xdc # Basys3 pin constraints
├── tb_Task1.v              # PC / ImmGen / branch target testbench
├── tb_Task2.v              # Full-processor integration testbench
├── TaskA.s / TaskB.s / TaskC.s   # Assembly sources
└── programA.hex / ProgramB.hex / programC.hex   # Machine code for InstructionMemory
```

## Memory Map

Selected by `aluResult[9:8]`:

| Region    | address[9:8] | Range        | Device        |
|-----------|:-----------:|--------------|----------------|
| Data Mem  | `00`        | `0x000–0x0FF` | 512×32 RAM     |
| LEDs      | `01`        | `0x100–…`     | Memory-mapped 16 LEDs |
| Switches  | `10`        | `0x200–…`     | 16 physical switches |

## Instruction Set

**R-type**: ADD, SUB, AND, OR, XOR, SLL, SRL
**I-type (ALU)**: ADDI, SRLI
**I-type (Load)**: LW, LH, LB
**S-type**: SW, SH, SB
**B-type**: BEQ, BNE, BGE
**J-type**: JAL
**I-type (Jump)**: JALR
**U-type**: LUI

## Board I/O

| Signal           | Pin / Port         |
|------------------|-------------------|
| `clk`            | W5 (100 MHz, divided in `clkDivider.v`) |
| `reset`          | U18 (center button) |
| `btnMode`        | Side button — toggles debug / run mode |
| `switches[15:0]` | SW0–SW15          |
| `leds[15:0]`     | LD0–LD15          |
| 7-seg `segments`, `displayPower` | Standard Basys3 pins |

## Debug Mode

`FpgaTop` has two modes toggled by `btnMode` (reset starts in debug mode):

- **Run mode**: the processor receives the real switches; `leds` shows the program's memory-mapped LED output; the 7-seg shows the selected view (PC / instruction / LED value in BCD).
- **Debug mode**: the processor sees `switches = 0` so the program is effectively paused at the idle path. The switches instead drive display selectors (latched), and the LEDs show live control-unit and ALU signals for whichever instruction the PC is on. `switches[15]` high gates the CPU clock — useful for freezing on a single instruction to inspect its control word.

### Debug switch functions

| Switch | Function (debug mode only) |
|--------|---------------------------|
| `sw0`  | 7-seg source: 0 = current instruction, 1 = PC |
| `sw1`  | 7-seg half: 0 = lower 16 bits, 1 = upper 16 bits |
| `sw2`  | 7-seg override: 0 = instruction/PC, 1 = LED value (in BCD) |
| `sw15` | High = freeze CPU clock |

### Debug LED layout

When in debug mode, `leds[15:0]` reflect the following internal signals:

| Bit(s) | Signal       |
|--------|--------------|
| 15:12  | `aluControl[3:0]` |
| 11     | `regWrite`   |
| 10     | `memRead`    |
| 9      | `memWrite`   |
| 8      | `memToReg`   |
| 7      | `aluSrc`     |
| 6      | `branch`     |
| 5      | `jump` (JAL) |
| 4      | `jalr`       |
| 3      | `zero` flag  |
| 2      | `lessThan` flag |
| 1:0    | unused       |

### Expected LED patterns per instruction

`aluControl` encoding: ADD=`0010`, SUB=`0110`, AND=`0000`, OR=`0001`, XOR=`0100`, SLL=`0101`, SRL/SRLI=`0111`.

| Instruction | aluCtrl | rW | mR | mW | m2R | aSrc | br | j | jr |
|-------------|:-------:|:--:|:--:|:--:|:---:|:----:|:--:|:-:|:--:|
| R-type (ADD/SUB/…) | varies | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ADDI       | 0010 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| SRLI       | 0111 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| LW         | 0010 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 0 |
| SW         | 0010 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 |
| BEQ        | 0110 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| BGE        | 0110 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| JAL        | 0010 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| JALR       | 0010 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 1 |

(`zero` and `lessThan` reflect live ALU state and are consumed for BEQ / BGE respectively.)

## Toolchain

- **Synthesis / Implementation / Bitstream**: Xilinx Vivado (top module = `FpgaTop`)
- **Simulation**: Vivado simulator (testbenches in `tb_Task1.v`, `tb_Task2.v`)
- **RISC-V assembly**: written by hand, assembled with a Python helper, loaded into `InstructionMemory` via `$readmemh`
- **Editor**: VS Code + Verilog-HDL / iverilog linter

## Running on Hardware

1. Open the project in Vivado.
2. Set `FpgaTop` as the top module.
3. Point `InstructionMemory.v` at the desired `programX.hex`.
4. Run synthesis → implementation → generate bitstream.
5. Program the Basys3 over USB.
6. Use switches to provide input; observe results on LEDs and the 7-seg display.
