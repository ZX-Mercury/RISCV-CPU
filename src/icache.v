
module IC #(
    parameter ADDR_WIDTH = 32,
    parameter BLOCK_WIDTH = 1,
    parameter BLOCK_SIZE = 1 << BLOCK_WIDTH,
    parameter CACHE_WIDTH = 8,
    parameter CACHE_SIZE = 1 << CACHE_WIDTH,
    parameter BLOCK_NUM = 1 << CACHE_WIDTH,
    parameter WORK=1, PAUSE=0
)

(      // Instruction Cache,  memory controller和instruction fetcher的中介
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,

    // memory controller
    input   wire    [BLK_WIDTH:0][31:0] MC2IC_addr,
    input   wire    MC2IC_en,
    output  reg     [ADDER_WIDTH-1:0]   IC2MC_addr,
    output  wire    IC2MC_en,

    // instruction fetcher
    input   wire    IF2IC_en,
    input   wire    [32*BLOCK_WIDTH-1:0] IF2IC_addr,
    output  wire    [31:0] IF2IC_instr,
    output  wire    IF2IC_pc,

    // reorder buffer
    input  wire RoB2IC_pre_judge
);

reg IC_state; // 0: pause, 1: work
reg disgard;
reg block_valid[CACHE_SIZE-1:0];
reg [31:0] block_data[CACHE_SIZE-1:0][BLK_SIZE-1:0];
reg [:] block_tag[CACHE_SIZE-1:0];

wire [BLOCK_WIDTH - 1:0] IF2IC_block_offset;
wire [CACHE_WIDTH - 1:0] IF2IC_index;
wire [ADDR_WIDTH - 1:BLOCK_WIDTH + 2 + CACHE_WIDTH] IF2IC_tag;
wire [BLOCK_WIDTH - 1:0] MC2IC_block_offset;
wire [CACHE_WIDTH - 1:0] MC2IC_index;
wire [ADDR_WIDTH - 1:BLOCK_WIDTH + 2 + CACHE_WIDTH] MC2IC_tag;

assign IF2IC_block_offset   = IF2IC_addr[BLOCK_WIDTH-1+2:2];
assign IF2IC_index          = IF2IC_addr[BLOCK_WIDTH+2+CACHE_WIDTH-1:BLOCK_WIDTH+2];
assign IF2IC_tag            = IF2IC_addr[ADDR_WIDTH-1:BLOCK_WIDTH+2+CACHE_WIDTH];
assign MC2IC_block_offset   = MC2IC_addr[BLOCK_WIDTH-1+2:2];
assign MC2IC_index          = MC2IC_addr[BLOCK_WIDTH+2+CACHE_WIDTH-1:BLOCK_WIDTH+2];
assign MC2IC_tag            = MC2IC_addr[ADDR_WIDTH-1:BLOCK_WIDTH+2+CACHE_WIDTH];

integer i;
always @(posedge clk_in) begin
    if (rst_in) begin
        for (i = 0; i < CACHE_SIZE; i = i + 1) begin
            block_valid[i] <= 0;
        end
        IC_state <= work;
        disgard <= 0;
        IC2MC_en <= 0;
        IC2IF_en <= 0;
    end else if (!RoB2IC_pre_judge) begin
        disgard <= IC_state == PAUSE ? 1 : 0;
        IC_state <= PAUSE;
        IC2MC_en <= 0;
        IC2IF_en <= 0;
    end else if (rdy_in) begin
        if (IC2IF_en) begin
            IC2IF_en <= 0;
        end else begin
            if (IF2Ic_en && IC_state == WORK) begin
                if (block_valid[IF2IC_index] && block_tag[IF2IC_index] == IF2IC_tag) begin  //hit
                    IC2IF_data <= block_data[IF2IC_index][IF2IC_block_offset];
                    IC2IF_en <= 1;
                end else begin      //miss
                    IC_state <= PAUSE;
                    IC2IF_en <= 0;
                    IC2MC_addr <= IF2IC_addr - (IF2IC_block_offset<<2);
                    IC2MC_en <= 1;
                end
            end
            if (MC2IC_en) begin
                IC_state <= WORK;
                IC2MC_en <= 0;
                if (!disgard) begin
                    block_data[IC2MC_index][MC2IC_block_offset] <= MC2IC_block;//data
                    block_tag[IC2MC_index] <= MC2IC_tag;
                    block_valid[MC2IC_index] <= 1;
                    IF2IC_en <= 1;
                    case IF2IC_block_offset
                        0: IC2IF_data <= MC2IC_block[31:0];
                        1: IC2IF_data <= MC2IC_block[63:32];
                    endcase
                end else begin
                    disgard <= 0;
                end

            end
        end
    end
end

endmodule