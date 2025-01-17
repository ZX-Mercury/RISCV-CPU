module DP#(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,  //extra one bit for empty reg
    parameter NON_REG = 1 << REG_WIDTH,
    parameter RoB_WIDTH = 4,
    parameter EX_RoB_WIDTH = 5,
    parameter NON_DEP = 1 << RoB_WIDTH,  //no dependency
    parameter IDLE = 0, WAITING_INS = 1,
    parameter LUI     =7'b0000001,
    parameter AUIPC   =7'b0000010,
    parameter JAL     =7'b0000011,
    parameter JALR    =7'b0000100,
    parameter BEQ     =7'b0000101,
    parameter BNE     =7'b0000110,
    parameter BLT     =7'b0000111,
    parameter BGE     =7'b0001000,
    parameter BLTU    =7'b0001001,
    parameter BGEU    =7'b0001010,
    parameter LB      =7'b0001011,
    parameter LH      =7'b0001100,
    parameter LW      =7'b0001101,
    parameter LBU     =7'b0001110,
    parameter LHU     =7'b0001111,
    parameter SB      =7'b0010000,
    parameter SH      =7'b0010001,
    parameter SW      =7'b0010010,
    parameter ADDI    =7'b0010011,
    parameter SLTI    =7'b0010100,
    parameter SLTIU   =7'b0010101,
    parameter XORI    =7'b0010110,
    parameter ORI     =7'b0010111,
    parameter ANDI    =7'b0011000,
    parameter SLLI    =7'b0011001,
    parameter SRLI    =7'b0011010,
    parameter SRAI    =7'b0011011,
    parameter ADD     =7'b0011100,
    parameter SUB     =7'b0011101,
    parameter SLL     =7'b0011110,
    parameter SLT     =7'b0011111,
    parameter SLTU    =7'b0100000,
    parameter XOR     =7'b0100001,
    parameter SRL     =7'b0100010,
    parameter SRA     =7'b0100011,
    parameter OR      =7'b0100100,
    parameter AND     =7'b0100101 
)(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,

    //DC
    input wire DC2DP_en,
    input wire [ADDR_WIDTH-1:0] DC2DP_pc,
    input wire [6:0]   DC2DP_opcode,
    input wire [REG_WIDTH-1:0]  DC2DP_rs1,
    input wire [REG_WIDTH-1:0]  DC2DP_rs2,
    input wire [REG_WIDTH-1:0]  DC2DP_rd,
    input wire [31:0]  DC2DP_imm,
    output reg DP2DC_query_inst,

    //RF
    input wire [EX_ROB_WIDTH-1:0] RF2DP_Qj,
    input wire [EX_ROB_WIDTH-1:0] RF2DP_Qk,
    input wire [31:0] RF2DP_Vj,
    input wire [31:0] RF2DP_Vk,
    output reg DP2RF_en,
    output reg [EX_REG_WIDTH-1:0] DP2RF_rd,
    output reg [31:0] DP2RF_data,
    output reg [ROB_WIDTH - 1:0] DPRF_RoB_index,
    output wire [EX_REG_WIDTH - 1:0] DPRF_rs2,

    //LSB

    //ROB
);

endmodule