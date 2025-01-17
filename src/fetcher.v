
module IF #(
    parameter ADDR_WIDTH = 32,
    parameter BLOCK_WIDTH = 1,
    parameter BLOCK_SIZE = 1 << BLOCK_WIDTH,
    parameter CACHE_WIDTH = 8,
    parameter CACHE_SIZE = 1 << CACHE_WIDTH,
    parameter BLOCK_NUM = 1 << CACHE_WIDTH,
    parameter WORK=1, PAUSE=0
)
(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,

    // icache
    input wire IC2IF_en,
    input wire [31:0] IC2IF_data,
    output wire IF2IC_en,
    output wire [ADDR_WIDTH-1:0]IF2IC_addr,

    // decoder
    input wire DC2IF_query_inst,
    output reg IF2DC_en,
    output reg [ADDR_WIDTH-1:0] IF2DC_pc,
    output reg [6:0] IF2DC_opcode,
    output reg [31:7] IF2DC_exop,

    // reorder buffer
    input wire RoB2IF_pre_judge,
    input wire RoB2IF_branch_result,
    input wire RoB2IF_jalr_en,
    input wire RoB2IF_branch_en,
    input wire [ADDR_WIDTH - 1:0] RoB2IF_branch_pc,
    input wire [ADDR_WIDTH - 1:0] RoB2IF_next_pc
);

wire [31:0] imm;
reg  [ADDR_WIDTH-1:0] pc;
reg  stop_fetch;
reg  [31:0] instr;
reg  IF_state;  //0: pause, 1: work

assign IF2IC_en = DC2IF_query_inst && !stop_fetch;
assign IF2IC_addr = pc;
assign IF2DC_opcode = IC2IF_data[6:0];
assign IF2DC_exop = IC2IF_data[31:7];
assign imm = (IF2DC_opcode == 7'b1101111) ? {{12{IC2IF_data[31]}},IC2IF_data[19:12],IC2IF_data[20],IC2IF_data[30:21],1'b0}  //jal
    :(IF2DC_opcode == 7'b1100011) ? {{20{IC2IF_data[31]}},IC2IF_data[7],IC2IF_data[30:25],IC2IF_data[11:8],1'b0}  //branch
    : 32'b0;
assign IF2DC_pc = pc;

always @(posedge clk_in) begin
    if (rst_in) begin
        pc <= 0;
        IF_state <= WORK;
        IF2DC_en <= 0;
        stop_fetch <= 0;
        instr <= NONINST;
    end else if (rdy_in) begin
        if (!RoB2IC_pre_judge) begin
            pc <= RoBIF_next_pc;
            IF_state <= WORK;
            IF2DC_en <= 0;
            stop_fetch <= 0;
        end else begin
            if (IF_state == work && IC2IF_en && DC2IF_query_inst) begin
                case (opcode)
                    7'b1101111: begin
                        pc <= pc + imm;
                        IF2DC_pc <= pc;
                        IF2DC_en <= 1;
                    end
                    7'b1100111: begin
                        IF_state <= PAUSE;
                        stop_fetch <= 1;
                        IF2DC_pc <= pc;
                        IF2DC_en <= 1;
                    end
                    default: begin
                        pc <= pc + 4;
                        IF2DC_pc <= pc;
                        IF2DC_en <= 1;
                    end
                endcase
            end else begin//不可以继续取指
                IF2DC_en <= 0;
            end
        end
    end
end

endmodule