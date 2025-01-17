
module CDB #(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,
    parameter NON_REG = 1 << REG_WIDTH,
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter RS_WIDTH = 3,
    parameter EX_RS_WIDTH = 4,
    parameter RS_SIZE = 1 << RS_WIDTH,
    parameter NON_DEP = 1 << ROB_WIDTH
)(
    //RS
    input wire RS2CDB_en,
    input wire [ROB_WIDTH-1:0] RS2CDB_ROB_index,
    input wire [31:0] RS2CDB_value,
    input wire [ADDR_WIDTH-1:0] RS2DCB_next_pc,
    output wire CDBRS_LSB_en,
    output wire [ROB_WIDTH-1:0] CDBRS_LSB_ROB_index,
    output wire [31:0] CDBRS_LSB_value,

    //LSB
    input wire LSB2CDB_en,
    input wire [ROB_WIDTH-1:0] LSB2CDB_ROB_index,
    input wire [31:0] LSB2CDB_value,
    output wire CDB2LSB_RS_en,
    output wire [ROB_WIDTH-1:0] CDB2LSB_RS_ROB_index,
    output wire [31:0] CDB2LSB_RS_value,

    //ROBS
    output wire CDB2ROB_RS_en,
    output wire [ROB_WIDTH-1:0] CDB2ROB_RS_ROB_index,
    output wire [31:0] CDB2ROB_RS_value,
    output wire [ADDR_WIDTH-1:0] CDB2ROB_RS_next_pc,
    output wire CDB2ROB_LSB_en,
    output wire [ROB_WIDTH-1:0] CDB2ROB_LSB_ROB_index,
    output wire [31:0] CDB2ROB_LSB_value,

    //Dispatcher
    output wire CDB2DP_RS_en,
    output wire [ROB_WIDTH-1:0] CDB2DP_RS_ROB_index,
    output wire [31:0] CDB2DP_RS_value,
    output wire CDB2DP_LSB_en,
    output wire [ROB_WIDTH-1:0] CDB2DP_LSB_ROB_index,
    output wire [31:0] CDB2DP_LSB_value
);

    assign CDBRS_LSB_en = LSB2CDB_en;
    assign CDBRS_LSB_ROB_index = LSB2CDB_ROB_index;
    assign CDBRS_LSB_value = LSB2CDB_value;
    assign CDB2LSB_RS_en = RS2CDB_en;
    assign CDB2LSB_RS_ROB_index = RS2CDB_ROB_index;
    assign CDB2LSB_RS_value = RS2CDB_value;
    
    assign CDB2ROB_RS_en = RS2CDB_en;
    assign CDB2ROB_RS_ROB_index = RS2CDB_ROB_index;
    assign CDB2ROB_RS_value = RS2CDB_value;
    assign CDB2ROB_RS_next_pc = RS2DCB_next_pc;
    assign CDB2ROB_LSB_en = LSB2CDB_en;
    assign CDB2ROB_LSB_ROB_index = LSB2CDB_ROB_index;
    assign CDB2ROB_LSB_value = LSB2CDB_value;
    
    assign CDB2DP_RS_en = RS2CDB_en;
    assign CDB2DP_RS_ROB_index = RS2CDB_ROB_index;
    assign CDB2DP_RS_value = RS2CDB_value;
    assign CDB2DP_LSB_en = LSB2CDB_en;
    assign CDB2DP_LSB_ROB_index = LSB2CDB_ROB_index;
    assign CDB2DP_LSB_value = LSB2CDB_value;
endmodule
