module DC #(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
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
) (
    input wire          clk_in, // system clock signal
    input wire          rst_in, // reset signal
    input wire          rdy_in, // ready signal, pause cpu when low

    // ifetcher
    input wire IF2DC_en,
    input wire [ADDR_WIDTH-1:0]   IF2DC_pc,
    input wire [6:0]   IF2DC_opcode,
    input wire [31:7]  IF2DC_exop,
    output wire DC2IF_query_inst,

    // dispatcher
    input wire DP2DC_query_inst,
    output wire DC2DP_en,
    output wire [ADDR_WIDTH-1:0] DC2DP_pc,
    output wire [6:0]   DC2DP_opcode,
    output wire [REG_WIDTH-1:0]  DC2DP_rs1,
    output wire [REG_WIDTH-1:0]  DC2DP_rs2,
    output wire [REG_WIDTH-1:0]  DC2DP_rd,
    output wire [31:0]  DC2DP_imm
);

assign DC2DP_en = IF2DC_en;
assign DC2DP_pc = IF2DC_pc;
assign DC2DP_opcode =   (IF2DC_opcode==7'b0110111) ? LUI :
                        (IF2DC_opcode==7'b0010111) ? AUIPC :
                        (IF2DC_opcode==7'b1101111) ? JAL :
                        (IF2DC_opcode==7'b1100111) ? JALR :
                        (IF2DC_opcode==7'b1100011) ? ((IF2DC_exop[14:12]==3'b000) ? BEQ :
                                                    (IF2DC_exop[14:12]==3'b001) ? BNE :
                                                    (IF2DC_exop[14:12]==3'b100) ? BLT :
                                                    (IF2DC_exop[14:12]==3'b101) ? BGE :
                                                    (IF2DC_exop[14:12]==3'b110) ? BLTU : BGEU) :
                        (IF2DC_opcode==7'b0000011) ? ((IF2DC_exop[14:12]==3'b000) ? LB :
                                                    (IF2DC_exop[14:12]==3'b001) ? LH :
                                                    (IF2DC_exop[14:12]==3'b010) ? LW :
                                                    (IF2DC_exop[14:12]==3'b100) ? LBU : LHU) :
                        (IF2DC_opcode==7'b0100011) ? ((IF2DC_exop[14:12]==3'b000) ? SB :
                                                    (IF2DC_exop[14:12]==3'b001) ? SH : SW) :
                        (IF2DC_opcode==7'b0010011) ? ((IF2DC_exop[14:12]==3'b000) ? ADDI :
                                                    (IF2DC_exop[14:12]==3'b010) ? SLTI :
                                                    (IF2DC_exop[14:12]==3'b011) ? SLTIU :
                                                    (IF2DC_exop[14:12]==3'b100) ? XORI :
                                                    (IF2DC_exop[14:12]==3'b110) ? ORI :
                                                    (IF2DC_exop[14:12]==3'b111) ? ANDI :
                                                    (IF2DC_exop[14:12]==3'b001 && IF2DC_exop[30]==0) ? SLLI : SRAI) : 
                        (IF2DC_opcode==7'b0110011) ? ((IF2DC_exop[14:12]==3'b000 && IF2DC_exop[30]==0) ? ADD :
                                                    (IF2DC_exop[14:12]==3'b000 && IF2DC_exop[30]==1) ? SUB :
                                                    (IF2DC_exop[14:12]==3'b001) ? SLL :
                                                    (IF2DC_exop[14:12]==3'b010) ? SLT :
                                                    (IF2DC_exop[14:12]==3'b011) ? SLTU :
                                                    (IF2DC_exop[14:12]==3'b100) ? XOR :
                                                    (IF2DC_exop[14:12]==3'b110) ? OR :
                                                    (IF2DC_exop[14:12]==3'b111) ? AND :
                                                    (IF2DC_exop[14:12]==3'b101 && IF2DC_exop[30]==0) ? SRL : SRA) : 0;
assign DC2DP_rs1 = IF2DC_exop[19:15];
assign DC2DP_rs2 = IF2DC_exop[24:20];
assign DC2DP_rd = IF2DC_exop[11:7];
assign DC2DP_imm = (DC2DP_opcode == LUI || DC2DP_opcode == AUIPC) ? {IF2DC_exop[31:12], 12'b0} :
                    (DC2DP_opcode == JAL)? {IF2DC_exop[31], IF2DC_exop[19:12], IF2DC_exop[20], IF2DC_exop[30:21], 1'b0} :
                    (DC2DP_opcode == JALR)? {IF2DC_exop[31:20], 12'b0} : //??
                    (DC2DP_opcode == BEQ || DC2DP_opcode == BNE || DC2DP_opcode == BLT || DC2DP_opcode == BGE || DC2DP_opcode == BLTU || DC2DP_opcode == BGEU)? {IF2DC_exop[31], IF2DC_exop[7], IF2DC_exop[30:25], IF2DC_exop[11:8], 1'b0} :
                    (DC2DP_opcode == LB || DC2DP_opcode == LH || DC2DP_opcode == LW || DC2DP_opcode == LBU || DC2DP_opcode == LHU) ? {IF2DC_exop[31:20]} :
                    (DC2DP_opcode == SB || DC2DP_opcode == SH || DC2DP_opcode == SW) ? {IF2DC_exop[31:25], IF2DC_exop[11:7]} :
                    (DC2DP_opcode == ADDI || DC2DP_opcode == SLTI || DC2DP_opcode == SLTIU || DC2DP_opcode == XORI || DC2DP_opcode == ORI || DC2DP_opcode == ANDI) ? {IF2DC_exop[31:20]} :
                    (DC2DP_opcode == SLLI || DC2DP_opcode == SRLI || DC2DP_opcode == SRAI) ? {IF2DC_exop[24:20]} :
                    32'b0;
assign DC2IF_query_inst = DP2DC_query_inst;


endmodule