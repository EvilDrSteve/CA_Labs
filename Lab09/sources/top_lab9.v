`timescale 1ns / 1ps

module top_lab9(
    input clk,
    input reset,
    input step_btn,          // physical step button
    input [15:0] sw,         // slide switches
    output [15:0] led        // board LEDs
);

    // ==========================================
    // 1. Hardware Interface Instantiations
    // ==========================================
    
    // Debouncer for the step button (based on Lab 5 debouncer.v interface)
    // module debouncer(input clk, input pbin, output pbout)
    wire step_pulse;
    debouncer u_debouncer (
        .clk(clk),
        .pbin(step_btn),     // Physical button in
        .pbout(step_pulse)   // Debounced out
    );

    // ==========================================
    // 2. FSM for Instruction Data Capture
    // ==========================================
    // Since Basys 3 has 16 switches and the combined instruction 
    // parts (opcode=7, funct3=3, funct7=7) need 17 bits, we 
    // capture them sequentially in two steps before displaying.

    localparam S_READ_OPCODE_FUNCT3 = 2'd0;
    localparam S_READ_FUNCT7        = 2'd1;
    localparam S_DISPLAY_RESULTS    = 2'd2;

    reg [1:0] state, next_state;
    reg [6:0] opcode, next_opcode;
    reg [2:0] funct3, next_funct3;
    reg [6:0] funct7, next_funct7;

    // We can clean switches simply by passing them through a 2-stage synchronizer locally if preferred,
    // but the FSM already captures them synchronously on the button press, so direct reading is safe.

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= S_READ_OPCODE_FUNCT3;
            opcode <= 7'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
        end else begin
            state  <= next_state;
            opcode <= next_opcode;
            funct3 <= next_funct3;
            funct7 <= next_funct7;
        end
    end

    // Use debounced step_pulse directly to transition state. 
    // So we need edge detection to only step ONCE per press.
    reg step_pulse_d;
    always @(posedge clk) begin
        step_pulse_d <= step_pulse;
    end
    wire step_edge = step_pulse & ~step_pulse_d;

    always @(*) begin
        // Default assignments to hold values
        next_state  = state;
        next_opcode = opcode;
        next_funct3 = funct3;
        next_funct7 = funct7;

        case (state)
            S_READ_OPCODE_FUNCT3: begin
                // Map sw[6:0] to opcode, sw[9:7] to funct3
                if (step_edge) begin
                    next_opcode = sw[6:0];
                    next_funct3 = sw[9:7];
                    next_state  = S_READ_FUNCT7;
                end
            end
            S_READ_FUNCT7: begin
                // Map sw[6:0] to funct7
                if (step_edge) begin
                    next_funct7 = sw[6:0];
                    next_state  = S_DISPLAY_RESULTS;
                end
            end
            S_DISPLAY_RESULTS: begin
                // Return to first state to observe a new instruction
                if (step_edge) begin
                    next_state  = S_READ_OPCODE_FUNCT3;
                end
            end
            default: next_state = S_READ_OPCODE_FUNCT3;
        endcase
    end

    // ==========================================
    // 3. Control Path Instantiations
    // ==========================================
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Main Control Unit
    MainControl u_MainControl (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );

    // ALU Control Unit
    ALU_Control u_ALUControl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // ==========================================
    // 4. LED Output Mapping
    // ==========================================

    wire [15:0] led_data;
    
    // Mapping: (Total 12 control bits + 2 state bits = 14 bits)
    //assign led_data = {state, 2'b00, ALUControl, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch};
    assign led_data = (state == S_DISPLAY_RESULTS) 
                  ? {state, 2'b00, ALUControl, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} 
                  : {state, 14'b0};

  
    
    // The memory offset doesn't strictly matter as long as 'writeEnable' is high 
    // for this isolated test context. We will just pass our packed LED data to `writeData`.
    leds u_leds (
        .clk(clk),
        .rst(reset),
        .writeData({16'b0, led_data}), // Write our structured data to lower half
        .writeEnable(1'b1),            // Always enabled to display immediately
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),                   // Unused
        .leds(led)                     // Driven out to physical LEDs
    );

endmodule