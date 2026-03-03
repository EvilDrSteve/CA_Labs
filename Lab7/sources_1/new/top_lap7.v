`timescale 1ns / 1ps

module top_lab7(
    input clk,
    input btn_reset,
    input [15:0] sw,
    output [15:0] led,
    output [3:0] an,       // Seven-segment power
    output [6:0] seg       // Seven-segment Cathodes
);
    //Debouncer for the reset button
    wire clean_reset;
    debouncer db(
        .clk(clk),
        .pbin(btn_reset),
        .pbout(clean_reset)
    );
    
   // 2. Debouncer for the Write Enable Switch (sw[15])
    wire clean_sw15;
    debouncer db1(
        .clk(clk),
        .pbin(sw[15]),
        .pbout(clean_sw15) // FIXED: Now outputs to its own wire
    );

    // 3. Edge Detector for the Write Switch
    reg sw15_delay;
    wire write_pulse;

    always @(posedge clk) begin
        if (clean_reset) begin
            sw15_delay <= 1'b0;
        end else begin
            sw15_delay <= clean_sw15; // Remember the switch state from the last clock cycle
        end
    end

    // The pulse is exactly 1 when the switch is currently UP, but was DOWN on the last cycle
    assign write_pulse = clean_sw15 & ~sw15_delay;
    
    //Register File Signals
    reg rf_we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    RegisterFile rf(
        .clk(clk), .rst(clean_reset), .WriteEnable(rf_we),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .readData1(ReadData1), .readData2(ReadData2)
    );

    //ALU Signals
    wire [31:0] alu_result;
    wire zero_flag;

    ALU alu(
        .A(ReadData1), 
        .B(ReadData2),
        .ALUControl(sw[3:0]), // Switches 3:0 control the ALU
        .ALUResult(alu_result), 
        .zero(zero_flag)
    );

    // Seven-Segment Display Controller
    // We will display the lower 16 bits of the ALU result
    SevenSegmentDriver ssd(
        .clk(clk),
        .reset(clean_reset),
        .hex_data(alu_result[15:0]),
        .an(an),
        .seg(seg)
    );

    // 5. Hardware FSM
    localparam INIT_A  = 2'b00;
    localparam INIT_B  = 2'b01;
    localparam COMPUTE = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk) begin
        if (clean_reset) state <= INIT_A;
        else state <= next_state;
    end

    always @(*) begin
        // Default values
        rf_we = 0;
        rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        next_state = state;

        case (state)
            INIT_A: begin
                // Initialize x1 with 0x1111
                rf_we = 1; rd = 1; WriteData = 32'h00001111;
                next_state = INIT_B;
            end
            
            INIT_B: begin
                // Initialize x2 with 0x2222
                rf_we = 1; rd = 2; WriteData = 32'h00002222;
                next_state = COMPUTE;
            end
            
            COMPUTE: begin
                rs1 = sw[8:4];   // 5 bits for rs1
                rs2 = sw[13:9];  // 5 bits for rs2
                
                // Write the ALU result into x3 if switch 15 is high
                if (write_pulse) begin
                    rf_we = 1; 
                    rd = 5'd3; 
                    WriteData = alu_result;
                end
                
                next_state = COMPUTE; 
            end
        endcase
    end

    assign led[14:0] = alu_result[14:0]; // Show binary result
    assign led[15]   = zero_flag;        // Zero flag indicator

endmodule