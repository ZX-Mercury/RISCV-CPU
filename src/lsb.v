module LSB #(
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
    parameter NON_DEP = 1 << ROB_WIDTH,
    WAITING_MEM = 1,
    parameter LOAD = 1, STORE = 0,
    parameter READ = 0, WRITE = 1
)(
    input clk_in,
    input rst_in,
    input rdy_in,

    //MC
    input wire  MC2LSB_r_en,
    input wire  MC2LSB_w_en,
    input wire  [31:0] MC2LSB_data,
    output reg LSB2MC_en,
    output reg LSB2MC_wr,
    output reg [2:0] LSB2MC_data_width,
    output reg [31:0] LSB2MC_data,
    output reg [ADDR_WIDTH - 1:0] LSB2MC_addr,

    //DP

    //ROB

    //CDB
    input wire CDB2LSB_RS_en,
    input wire [ROB_WIDTH-1:0] CDB2LSB_RS_ROB_index,
    input wire [31:0] CDB2LSB_RS_value,
    output wire LSB2CDB_en,
    output wire [ROB_WIDTH-1:0] LSB2CDB_ROB_index,
    output wire [31:0] LSB2CDB_value
);
endmodule