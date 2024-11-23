module decoder(
    input wire          clk_in, // system clock signal
    input wire          rst_in, // reset signal
    input wire          rdy_in, // ready signal, pause cpu when low
    input wire [31:0]   pc,         
    input wire [31:0]   instr,

    output reg [31:0]   to_rs_imm,
)

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [6:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    always @(posedge clk_in or negedge rst_in) begin
        if (rst_in) begin //
            $display("decoder: reset\n");
        end else if (!rdy_in) begin
            $display("decoder: pause\n");
        end else begin
            case(opcode)
                7'b0110111: begin // U lui

                end
            endcase
        end
    end

endmodule