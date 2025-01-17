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
        RS2CDB_en <= 0;
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
        if (DP2RS_en && !RS2DP_full) begin
            if (DP2RS_Qj != NON_DEP) begin
            if (RS2CDB_en && RS2CDB_ROB_index == DP2RS_Qj) begin
                Qj[idle_head] <= NON_DEP;
                Vj[idle_head] <= RS2CDB_value;
            end else if (CD2BRS_LSB_en && CD2BRS_LSB_ROB_index == DP2RS_Qj) begin
                Qj[idle_head] <= NON_DEP;
                Vj[idle_head] <= CD2BRS_LSB_value;
            end else begin
                Qj[idle_head] <= DP2RS_Qj;
                Vj[idle_head] <= DP2RS_Vj;
            end
            end else begin
            Qj[idle_head] <= NON_DEP;
            Vj[idle_head] <= DP2RS_Vj;
            end
            if (DP2RS_Qk != NON_DEP) begin
            if (RS2CDB_en && RS2CDB_ROB_index == DP2RS_Qk) begin
                Qk[idle_head] <= NON_DEP;
                Vk[idle_head] <= RS2CDB_value;
            end else if (CDB2RS_LSB_en && CDB2RS_LSB_ROB_index == DP2RS_Qk) begin
                Qk[idle_head] <= NON_DEP;
                Vk[idle_head] <= CDB2RS_LSB_value;
            end else begin
                Qk[idle_head] <= DP2RS_Qk;
                Vk[idle_head] <= DP2RS_Vk;
            end
            end else begin
            Qk[idle_head] <= NON_DEP;
            Vk[idle_head] <= DP2RS_Vk;
            end
            ROB_index[idle_head] <= DP2RS_ROB_index;
            opcode[idle_head] <= DP2RS_opcode;
            imm[idle_head] <= DP2RS_imm;
            busy[idle_head] <= 1;
            A[idle_head] <= DP2RS_pc;
      end
    end
    else begin
    end
end
endmodule