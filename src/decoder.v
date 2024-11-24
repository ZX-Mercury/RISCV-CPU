`include "defines.v"

module decoder(
    input wire          clk_in, // system clock signal
    input wire          rst_in, // reset signal
    input wire          rdy_in, // ready signal, pause cpu when low
    input wire [31:0]   pc,         
    input wire [31:0]   instr,

    output reg [31:0]   to_rs_imm,
    output reg [5:0]    to_rs_op,
)

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [6:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    always @(posedge clk_in or negedge rst_in) begin
        if (rst_in) begin
            $display("decoder: reset\n");
        end else if (!rdy_in) begin
            $display("decoder: pause\n");
        end else begin
            case(opcode)
                7'b0110111: begin // U lui
                    to_rs_imm <= {instr[31:12], 12'b0};
                    to_rs_op <= `LUI;
                end
                7'b0010111: begin // U auipc
                    to_rs_imm <= {instr[31:12], 12'b0};
                    to_rs_op <= `AUIPC;
                end
                7'b1101111: begin // J jal
                    to_rs_imm <= {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                    to_rs_op <= `JAL;
                end
                7'b1100111: begin // I jalr
                    to_rs_imm <= {instr[31:20], 12'b0};
                    to_rs_op <= `JALR;
                end
                7'b1100011: begin // B branch
                    to_rs_imm <= {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                    case(funct3)
                        3'b000: begin // BEQ
                            to_rs_op <= `BEQ;
                        end
                        3'b001: begin // BNE
                            to_rs_op <= `BNE;
                        end
                        3'b100: begin // BLT
                            to_rs_op <= `BLT;
                        end
                        3'b101: begin // BGE
                            to_rs_op <= `BGE;
                        end
                        3'b110: begin // BLTU
                            to_rs_op <= `BLTU;
                        end
                        3'b111: begin // BGEU
                            to_rs_op <= `BGEU;
                        end
                    endcase
                end
                7'b0000011: begin // I load
                    to_rs_imm <= {instr[31:20]};
                    case(funct3)
                        3'b000: begin // LB
                            to_rs_op <= `LB;
                        end
                        3'b001: begin // LH\
                            to_rs_op <= `LH;
                        end
                        3'b010: begin // LW
                            to_rs_op <= `LW;
                        end
                        3'b100: begin // LBU
                            to_rs_op <= `LBU;
                        end
                        3'b101: begin // LHU
                            to_rs_op <= `LHU;
                        end
                    endcase
                end
                7'b0100011: begin // S store
                    to_rs_imm <= {instr[31:25], instr[11:7]};
                    case(funct3)
                        3'b000: begin // SB
                            to_rs_op <= `SB;
                        end
                        3'b001: begin // SH
                            to_rs_op <= `SH;
                        end
                        3'b010: begin // SW
                            to_rs_op <= `SW;
                        end
                    endcase
                end
                7'b0010011: begin // I alu
                    to_rs_imm <= instr[31:20];
                    case(funct3)
                        3'b000: begin // ADDI
                            to_rs_op <= `ADDI;
                        end
                        3'b010: begin // SLTI
                            to_rs_op <= `SLTI;
                        end
                        3'b011: begin // SLTIU
                            to_rs_op <= `SLTIU;
                        end
                        3'b100: begin // XORI
                            to_rs_op <= `XORI;
                        end
                        3'b110: begin // ORI
                            to_rs_op <= `ORI;
                        end
                        3'b111: begin // ANDI
                            to_rs_op <= `ANDI;
                        end
                        3'b001: begin // SLLI
                            to_rs_op <= `SLLI;
                        end
                        3'b101: begin // SRLI/SRAI
                            case(funct7)
                                7'b0000000: begin // SRLI
                                    to_rs_op <= `SRLI;
                                end
                                7'b0100000: begin // SRAI
                                    to_rs_op <= `SRAI;
                                end
                            endcase
                        end
                    endcase
                end
                7'b0110011: begin // R alu
                    to_rs_imm <= 0;
                    case(funct3)
                        3'b000: begin // ADD/SUB
                            case(funct7)
                                7'b0000000: begin // ADD
                                    to_rs_op <= `ADD;
                                end
                                7'b0100000: begin // SUB
                                    to_rs_op <= `SUB;
                                end
                            endcase
                        end
                        3'b001: begin // SLL
                            to_rs_op <= `SLL;
                        end
                        3'b010: begin // SLT
                            to_rs_op <= `SLT;
                        end
                        3'b011: begin // SLTU
                            to_rs_op <= `SLTU;
                        end
                        3'b100: begin // XOR
                            to_rs_op <= `XOR;
                        end
                        3'b101: begin // SRL/SRA
                            case(funct7)
                                7'b0000000: begin // SRL
                                    to_rs_op <= `SRL;
                                end
                                7'b0100000: begin // SRA
                                    to_rs_op <= `SRA;
                                end
                            endcase
                        end
                        3'b110: begin // OR
                            to_rs_op <= `OR;
                        end
                        3'b111: begin // AND
                            to_rs_op <= `AND;
                        end
                    endcase
                end
            endcase
        end
    end

endmodule