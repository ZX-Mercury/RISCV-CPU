module ROB#(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,
    parameter NON_REG = 1 << REG_WIDTH,
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter ROB_SIZE = 1 << ROB_WIDTH,
    parameter LSB_WIDTH = 3,
    parameter EX_LSB_WIDTH = 4,
    parameter LSB_SIZE = 1 << LSB_WIDTH,
    parameter NON_DEP = 1 << ROB_WIDTH
)(
    //System
    input Sys_clk,
    input Sys_rst,
    input Sys_rdy,

    //ICache
    output wire ROB2IC_pre_judge,

    //Dispatcher
    input wire [EX_ROB_WIDTH - 1:0] DP2ROB_Qj,
    input wire [EX_ROB_WIDTH - 1:0] DP2ROB_Qk,
    input wire DP2ROB_en,
    input wire [ADDR_WIDTH - 1:0] DP2ROB_pc,
    input wire DP2ROB_predict_result,
    input wire [6:0] DP2ROB_opcode,
    input wire [EX_REG_WIDTH - 1:0] DP2ROB_rd,
    output wire ROB2DP_full,
    output wire [ROB_WIDTH - 1:0] ROB2DP_ROB_index,
    output wire ROB2DP_pre_judge,
    output wire ROB2DP_Qj_ready,
    output wire ROB2DP_Qk_ready,
    output wire [31:0] ROB2DP_Vj,
    output wire [31:0] ROB2DP_Vk,

    //Instruction Fetcher
    output reg ROB2IF_jalr_en,
    output reg ROB2IF_branch_en,
    output wire ROB2IF_pre_judge,
    output reg ROB2IF_branch_result,
    output reg [ADDR_WIDTH - 1:0] ROB2IF_branch_pc,
    output reg [ADDR_WIDTH - 1:0] ROB2IF_next_pc,

    //ReservationStation
    output wire ROB2RS_pre_judge,

    //LoadStoreBuffer
    //TODO

    //CDB
    input wire CDB2ROB_RS_en,
    input wire [ROB_WIDTH - 1:0] CDB2ROB_RS_ROB_index,
    input wire [31:0] CDB2ROB_RS_value,  //rd value or branch result(jump or not)
    input wire [ADDR_WIDTH - 1:0] CDB2ROB_RS_next_pc,
    input wire CDB2ROB_LSB_en,
    input wire [ROB_WIDTH - 1:0] CDB2ROB_LSB_ROB_index,
    input wire [31:0] CDB2ROB_LSB_value,

    //RF
    output wire ROB2RF_pre_judge,
    output reg ROB2RF_en,  //commit a new instruction, ROB index,rd,value is valid now!
    output reg [ROB_WIDTH - 1:0] ROB2RF_ROB_index,
    output reg [EX_REG_WIDTH - 1:0] ROB2RF_rd,
    output reg [31:0] ROB2RF_value
);
endmodule