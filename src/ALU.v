`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0010
`define OR  4'b0011
`define XOR 4'b0100
`define SLL 4'b0101     // Shift Left Logical
`define SRL 4'b0110     // Shift Right Logical
`define SRA 4'b0111     // Shift Right Arithmetic
`define SLT 4'b1000     // Set Less Than
`define SLTU 4'b1001    // Set Less Than Unsigned
`define BEQ 4'b1010     // Branch Equal

module ALU (
    input [31:0] A,             // 32位输入A
    input [31:0] B,             // 32位输入B
    input [3:0] alu_op,         // ALU操作控制信号 (例如，加法、减法、与、或等)
    input clk_in,               // 时钟信号
    input rst_in,               // 复位信号
    input rdy_in,               // 有效信号
    input clear,                // 清除信号
    input cal,                  // 计算信号

    output reg [31:0] result,   // 32位运算结果
    output reg zero,            // 零标志位 (结果是否为零)
    output reg carry,           // 进位标志位 (加法进位)
    output reg overflow         // 溢出标志位
);


    always @(posedge clk_in or negedge rst_in) begin
        case(alu_op)
            `ADD: begin
                result <= A + B;
            end
            `SUB: begin
                result <= A - B;
            end
            `AND: begin
                result <= A & B;
            end
            `OR: begin
                result <= A | B;
            end
            `XOR: begin
                result <= A ^ B;
            end
            `SLL: begin
                result <= A << B;
            end
            `SRL: begin
                result <= A >> B;
            end
            `SRA: begin
                result <= A >>> B;
            end
            `SLT: begin
                result <= (A < B) ? 1 : 0;
            end
            `SLTU: begin
                result <= (A < B) ? 1 : 0;
            end
            `BEQ: begin
                result <= (A == B) ? 1 : 0;
            end
        endcase
    end
endmodule