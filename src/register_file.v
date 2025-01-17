
module RF #(
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6, //add a
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter NON_REG = 1 << REG_WIDTH,
    parameter REG_SIZE = 1 << REG_WIDTH,
    parameter ROB_SIZE = 1 << ROB_WIDTH,
    parameter NON_DEP = 1 << ROB_WIDTH
)(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,

    //dispatcher
    input wire DC2RF_en,
    input wire [EX_REG_WIDTH-1:0] DP2RF_rs1,
    input wire [EX_REG_WIDTH-1:0] DP2RF_rs2,
    input wire [EX_REG_WIDTH-1:0] DP2RF_rd,
    input wire [EX_ROB_WIDTH-1:0] DC2RF_ROB_index,
    output wire [EX_ROB_WIDTH-1:0] RF2DP_Qj,
    output wire [EX_ROB_WIDTH-1:0] RF2DP_Qk,
    output wire [31:0] RF2DP_Vj,
    output wire [31:0] RF2DP_Vk,

    //ROB
    input wire ROB2RF_pre_judge,
    input wire ROB2RF_en,
    input wire [ROB_WIDTH-1:0] ROB2RF_ROB_index,
    input wire [31:0] ROB2RF_value,
    input wire [EX_REG_WIDTH-1:0] ROB2RF_rd
);

reg [31:0] regfile [REG_SIZE-1:0];
reg [EX_ROB_WIDTH-1:0] dependency [ROB_SIZE-1:0];

assign RF2DP_Qj = (DP2RF_rs1!=NON_REG && ROB2RF_pre_judge && (ROB2RF_en || dependency[DP2RF_rs1]==ROB2RF_ROB_index))? dependency[DP2RF_rs1] : NON_DEP;
assign RF2DP_Qk = (DP2RF_rs2!=NON_REG && ROB2RF_pre_judge && (ROB2RF_en || dependency[DP2RF_rs2]==ROB2RF_ROB_index))? dependency[DP2RF_rs2] : NON_DEP;
assign RF2DP_Vj = (DP2RF_rs1==NON_REG) ? 0 : 
                    ((ROB2RF_en && dependency[DP2RF_rs1]==ROB2RF_ROB_index) ? ROB2RF_value : 
                        ((dependency[DP2RF_rs1]==NON_DEP) ? regfile[DP2RF_rs1] : 0));
assign RF2DP_Vk = (DP2RF_rs2==NON_REG) ? 0 :
                    ((ROB2RF_en && dependency[DP2RF_rs2]==ROB2RF_ROB_index) ? ROB2RF_value : 
                        ((dependency[DP2RF_rs2]==NON_DEP) ? regfile[DP2RF_rs2] : 0));

integer i;

always @(posedge clk_in) begin
    if (rst_in) begin
        for (i=0; i<REG_SIZE; i=i+1) begin
            regfile[i] <= 0;
            dependency[i] <= NON_DEP;
        end
    end else if (rdy_in) begin
        if (!ROB2RF_pre_judge) begin
            for (i=0; i<REG_SIZE; i=i+1) begin
                dependency[i] <= NON_DEP;
            end
        end else begin
            if (ROB2RF_en && ROB2RF_rd != NON_REG && ROB2RF_rd != 0) begin
                regfile[ROB2RF_rd] <= ROB2RF_value;
                if (dependency[ROB2RF_rd] == ROB2RF_ROB_index) begin
                    dependency[ROB2RF_rd] <= NON_DEP;
                end
            end
            if (DC2RF_en && DC2RF_ROB_index != NON_REG && DC2RF_ROB_index != 0) begin
                dependency[DC2RF_rd] <= DC2RF_ROB_index;
            end
        end
    end
end

endmodule