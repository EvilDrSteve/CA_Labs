`timescale 1ns / 1ps

module FSM_Lab7(
    input clk, rst,
    input [4:0] rs1, rs2
);

    localparam IDLE            = 3'd0;
    localparam WRITE_INIT      = 3'd1;
    localparam READ_REGISTERS  = 3'd2;
    localparam ALU_OPERATION   = 3'd3;
    localparam WRITE_REGISTERS = 3'd4;
    localparam READ_AFTER_WRITE = 3'd5;
    localparam DONE            = 3'd6;

    reg [2:0] state;
    reg [3:0] op_count;
    reg writeEnable;
    reg [4:0] rd;
    reg [3:0] ALUControl;
    reg [31:0] writeData;
    wire [31:0] readData1, readData2, ALUResult;
    wire ALUZero;

    RegisterFile registers(
        .clk(clk), .rst(rst), .WriteEnable(writeEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(writeData),
        .readData1(readData1), .readData2(readData2)
    );

    ALU alu(
        .A(readData1), .B(readData2),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult), .zero(ALUZero)
    );

    // State transitions
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            op_count <= 4'd0;
        end
        else begin
            case (state)
                IDLE: state <= WRITE_INIT;
                WRITE_INIT: begin
                    if (op_count == 4'd2) begin
                        state <= READ_REGISTERS;
                        op_count <= 4'd0;
                    end
                    else
                        op_count <= op_count + 1;
                end
                READ_REGISTERS:  state <= ALU_OPERATION;
                ALU_OPERATION:   state <= WRITE_REGISTERS;
                WRITE_REGISTERS: begin
                    if (op_count == 4'd8) begin
                        state <= READ_AFTER_WRITE;
                        op_count <= 4'd0;
                    end
                    else begin
                        op_count <= op_count + 1;
                        state <= READ_REGISTERS;
                    end
                end
                READ_AFTER_WRITE: state <= DONE;
                DONE: state <= DONE;
            endcase
        end
    end

    // Outputs
    always @(*) begin
        writeEnable = 0;
        writeData = 32'd0;
        rd = 5'd0;
        ALUControl = 4'b0000;

        case (state)
            WRITE_INIT: begin
                writeEnable = 1;
                case (op_count)
                    4'd0: begin rd = 5'd1; writeData = 32'h10101010; end
                    4'd1: begin rd = 5'd2; writeData = 32'h01010101; end
                    4'd2: begin rd = 5'd3; writeData = 32'h00000005; end
                endcase
            end

            ALU_OPERATION: begin
                case (op_count)
                    4'd0: ALUControl = 4'b0000;  // ADD
                    4'd1: ALUControl = 4'b0001;  // SUB
                    4'd2: ALUControl = 4'b0010;  // AND
                    4'd3: ALUControl = 4'b0011;  // OR
                    4'd4: ALUControl = 4'b0100;  // XOR
                    4'd5: ALUControl = 4'b0101;  // SLL
                    4'd6: ALUControl = 4'b0110;  // SRL
                    4'd7: ALUControl = 4'b0001;  // BEQ (SUB)
                    4'd8: ALUControl = 4'b0000;  // ADD (read-after-write)
                endcase
            end

            WRITE_REGISTERS: begin
                writeEnable = 1;
                writeData = ALUResult;
                case (op_count)
                    4'd0: begin ALUControl=4'b0000; rd=5'd4;  end
                    4'd1: begin ALUControl=4'b0001; rd=5'd5;  end
                    4'd2: begin ALUControl=4'b0010; rd=5'd6;  end
                    4'd3: begin ALUControl=4'b0011; rd=5'd7;  end
                    4'd4: begin ALUControl=4'b0100; rd=5'd8;  end
                    4'd5: begin ALUControl=4'b0101; rd=5'd9;  end
                    4'd6: begin ALUControl=4'b0110; rd=5'd10; end
                    4'd7: begin
                        ALUControl = 4'b0001;
                        if (ALUZero) begin
                            rd = 5'd11;
                            writeData = 32'hBEEF0000;
                        end else begin
                            writeEnable = 0;
                        end
                    end
                    4'd8: begin
                        rd = 5'd12;
                        writeData = 32'hABCD1234;
                    end
                endcase
            end
        endcase
    end
endmodule