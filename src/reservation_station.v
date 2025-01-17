module RS #(
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,     
    parameter NON_REG = 1 << REG_WIDTH,
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter RS_WIDTH = 3,
    parameter EX_RS_WIDTH = 4,
    parameter RS_SIZE = 1 << RS_WIDTH,
    parameter NON_DEP = 1 << ROB_WIDTH,

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
wire [EX_RS_WIDTH-1:0]    ready_head;

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
        if (ready_head!=RS_SIZE) begin
            RS2CDB_en <= 1;
            busy[ready_head] <= 0;
            RS2CDB_ROB_index <= ROB_index[ready_head];
            case(opcode[ready_head])
                LUI: begin RS2CDB_value <= imm[ready_head]; end
                AUIPC: begin RS2CDB_value <= imm[ready_head] + A[ready_head]; end
                JAL: begin 
                        RS2CDB_value <= A[ready_head] + 4;
                        RS2DCB_next_pc <= A[ready_head] + imm[ready_head];
                    end
                JALR: begin 
                        RS2CDB_value <= A[ready_head] + 4;
                        RS2DCB_next_pc <= (Vj[ready_head] + imm[ready_head]) & 32'hfffffffe;
                    end
                BEQ: begin 
                    RS2CDB_value <= (Vj[ready_head] == Vk[ready_head]) ? 1 : 0; 
                    RS2DCB_next_pc <= (Vj[ready_head] == Vk[ready_head]) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                BNE: begin
                    RS2CDB_value <= (Vj[ready_head] != Vk[ready_head]) ? 1 : 0;
                    RS2DCB_next_pc <= (Vj[ready_head] != Vk[ready_head]) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                BLT: begin
                    RS2CDB_value <= ($signed (Vj[ready_head]) < $signed (Vk[ready_head])) ? 1 : 0;
                    RS2DCB_next_pc <= ($signed (Vj[ready_head]) < $signed (Vk[ready_head])) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                BGE: begin
                    RS2CDB_value <= ($signed (Vj[ready_head]) >= $signed (Vk[ready_head])) ? 1 : 0;
                    RS2DCB_next_pc <= ($signed (Vj[ready_head]) >= $signed (Vk[ready_head])) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                BLTU: begin
                    RS2CDB_value <= (Vj[ready_head] < Vk[ready_head]) ? 1 : 0;
                    RS2DCB_next_pc <= (Vj[ready_head] < Vk[ready_head]) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                BGEU: begin
                    RS2CDB_value <= (Vj[ready_head] >= Vk[ready_head]) ? 1 : 0;
                    RS2DCB_next_pc <= (Vj[ready_head] >= Vk[ready_head]) ? A[ready_head] + imm[ready_head] : A[ready_head] + 4;
                    end
                LB: begin end
                LH: begin end
                LW: begin end
                LBU: begin end
                LHU: begin end
                SB: begin end
                SH: begin end
                SW: begin end
                ADDI: begin RS2CDB_value <= Vj[ready_head] + imm[ready_head]; end
                SLTI: begin RS2CDB_value <= ($signed (Vj[ready_head]) < $signed (imm[ready_head])) ? 1 : 0; end 
                SLTIU: begin RS2CDB_value <= (Vj[ready_head] < imm[ready_head]) ? 1 : 0; end
                XORI: begin RS2CDB_value <= Vj[ready_head] ^ imm[ready_head]; end
                ORI: begin RS2CDB_value <= Vj[ready_head] | imm[ready_head]; end
                ANDI: begin RS2CDB_value <= Vj[ready_head] & imm[ready_head]; end
                SLLI: begin RS2CDB_value <= Vj[ready_head] << imm[ready_head]; end
                SRLI: begin RS2CDB_value <= Vj[ready_head] >> imm[ready_head]; end
                SRAI: begin RS2CDB_value <= $signed (Vj[ready_head]) >>> imm[ready_head]; end
                ADD: begin RS2CDB_value <= Vj[ready_head] + Vk[ready_head]; end
                SUB: begin RS2CDB_value <= Vj[ready_head] - Vk[ready_head]; end
                SLL: begin RS2CDB_value <= Vj[ready_head] << Vk[ready_head]; end
                SLT: begin RS2CDB_value <= ($signed (Vj[ready_head]) < $signed (Vk[ready_head])) ? 1 : 0; end
                SLTU: begin RS2CDB_value <= (Vj[ready_head] < Vk[ready_head]) ? 1 : 0; end
                XOR: begin RS2CDB_value <= Vj[ready_head] ^ Vk[ready_head]; end
                SRL: begin RS2CDB_value <= Vj[ready_head] >> Vk[ready_head]; end
                SRA: begin RS2CDB_value <= $signed (Vj[ready_head]) >>> Vk[ready_head]; end
                OR: begin RS2CDB_value <= Vj[ready_head] | Vk[ready_head]; end
                AND: begin RS2CDB_value <= Vj[ready_head] & Vk[ready_head]; end
            endcase
        end
    end
    else begin
    end
end
endmodule