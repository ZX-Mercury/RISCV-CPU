module RS #(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,  //extra one bit for empty reg
    parameter NON_REG = 1 << REG_WIDTH,
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter RS_WIDTH = 3,
    parameter EX_RS_WIDTH = 4,
    parameter RS_SIZE = 1 << RS_WIDTH,
    parameter NON_DEP = 1 << ROB_WIDTH  //no dependency
)(
    input wire          clk_in, // system clock signal
    input wire          rst_in, // reset signal
    input wire          rdy_in, // ready signal, pause cpu when low

    //dispatcher
    input wire          DP2RS_en,
    input wire [ADDR_WIDTH-1:0] DP2RS_pc,
    input wire [EX_ROB_WIDTH-1:0] DP2RS_Qj,
    input wire [EX_ROB_WIDTH-1:0] DP2RS_Qk,
    input wire [31:0] DP2RS_Vj,
    input wire [31:0] DP2RS_Vk,
    input wire [31:0] DP2RS_imm,
    input wire [6:0] DP2RS_opcode,
    input wire [ROB_WIDTH-1:0] DP2RS_ROB_index,
    output wire RS2DP_full,

    //Reorder Buffer
    input wire ROB2RS_pre_judge,

    //CDB
    input wire CDB2RS_LSB_en,
    input wire [ROB_WIDTH-1:0] CDB2RS_LSB_ROB_index,
    input wire [31:0] CDB2RS_LSB_value,
    output reg RS2CDB_en,
    output reg [ROB_WIDTH-1:0] RS2CDB_ROB_index,
    output reg [31:0] RS2CDB_value,
    output reg [ADDR_WIDTH-1:0] RS2DCB_next_pc

);

reg [6:0]                   op[RS_SIZE-1:0];
reg [EX_ROB_WIDTH-1:0]      Qj[RS_SIZE-1:0];
reg [EX_ROB_WIDTH-1:0]      Qk[RS_SIZE-1:0];
reg [31:0]                  Vj[RS_SIZE-1:0];
reg [31:0]                  Vk[RS_SIZE-1:0];
reg [31:0]                  imm[RS_SIZE-1:0];
reg [ADDR_WIDTH-1:0]        A[RS_SIZE-1:0];
reg                         busy[RS_SIZE-1:0];

reg [ROB_WIDTH-1:0]         ROB_index[RS_SIZE-1:0];
wire ready[RS_SIZE-1:0];
wire [EX_RS_WIDTH-1:0]    idle_head;
wire [EX_RS_WIDTH-1:0]    ready_tail;

integer i;
always @(posedge clk_in)begin
    if(rst_in) begin
        for(i=0; i<RS_SIZE; i=i+1)begin
            op[i] <= 0;
            Qj[i] <= 0;
            Qk[i] <= 0;
            Vj[i] <= 0;
            Vk[i] <= 0;
            A[i] <= 0;
            busy[i] <= 0;
        end
    end
    else if (rdy_in) begin
        
    end
    else begin
    end
end
endmodule