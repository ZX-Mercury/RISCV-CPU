module MC#(
    parameter BLOCK_WIDTH = 1,
    parameter BLOCK_SIZE = 1<<BLOCK_WIDTH,
    parameter CACHE_SIZE = 8,
    parameter BLOCK_NUM = 1<<CACHE_SIZE,
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH = 5,
    parameter EX_REG_WIDTH = 6,
    parameter NON_REG = 0,
    parameter ROB_WIDTH = 4,
    parameter EX_ROB_WIDTH = 5,
    parameter LSB_WIDTH = 3,
    parameter EX_LSB_WIDTH = 4,
    parameter LSB_SIZE = 1<<LSB_WIDTH,
    parameter NON_DEP = 1<<ROB_WIDTH,
    parameter LSB=0, ICACHE = 1,
    parameter MC_IDLE = 0, MC_READ = 1, MC_WRITE = 2
)

(
    input   wire clk_in,
    input   wire rst_in,
    input   wire rdy_in,
    input   wire io_buffer_full,

    //ram
    input   wire    [7:0]    RAM2MC_data,
    output  reg     [7:0]    MC2RAM_data,
    output  reg     [31:0]   MC2RAM_addr,
    output  reg              MC2RAM_wr,

    //iCache
    input   wire    [ADDR_WIDTH-1:0]   IC2MC_addr,
    input   wire                        IC2MC_en,
    output  reg     [32*BLOCK_SIZE-1:0] MC2IC_block,
    output  reg                         MC2IC_en,

    //Load Store Buffer
    input  wire LSB2MC_en,
    input  wire LSB2MC_wr,          // 0:read,1:write
    input  wire [2:0] LSB2MC_data_width,  //0:byte,1:hw,2:w
    input  wire [31:0] LSB2MC_data,
    input  wire [ADDR_WIDTH - 1:0] LSB2MC_addr,
    output reg  MC2LSB_r_en,
    output reg  MC2LSB_w_en,
    output reg  [31:0] MC2LSB_data
);

reg [2:0] MC_state;     //0: idle, 1: read, 2: write
reg [3 + BLOCK_WIDTH - 1:0] rd_btn;
reg [2:0] wr_btn;
reg last_query;
wire stop_write;  // 1 if uart buffer is full write to address 0x30000 or 0x30004.

assign stop_write = (io_buffer_full && LSB2MC_en && LSB2MC_wr && (LSB2MC_addr == 32'h30000 || LSB2MC_addr == 32'h30004))?1:0;

always @(posedge clk_in) begin
    if (rst_in) begin
        MC_state <= MC_IDLE;
        last_query <= LSB;
        wr_btn <= 0;
        rd_btn <= 0;
        MC2LSB_r_en <= 0;
        MC2LSB_w_en <= 0;
        MC2IC_en <= 0;
        MC2RAM_data <= 0;
        MC2RAM_addr <= 0;
        MC2RAM_wr <= 0;
    end else if (rdy_in) begin
        if (MC_state == MC_IDLE) begin     //将初始状态改为rd状态或者wt状态
            MC2LSB_r_en <= 0;
            MC2LSB_w_en <= 0;
            MC2IC_en <= 0;
            if (IC2MC_en && !MC2IC_en &&(!LSB2MC_en || last_query == LSB)) begin
                MC_state <= MC_READ;
                rd_btn <= 0;
                last_query <= ICACHE;
                MC2RAM_addr <= IC2MC_addr;
                MC2RAM_wr <= 0;
            end else if (LSB2MC_en) begin
                MC_state <= LSB2MC_wr ? MC_WRITE : MC_READ;
                rd_btn <= 0;
                last_query <= LSB;
                MC2RAM_addr <= LSB2MC_addr;
                MC2RAM_wr <= LSB2MC_wr ? 1 : 0;
                if (LSB2MC_wr) begin
                    wr_btn <= 1;
                    MC2RAM_data <= LSB2MC_data[7:0];
                end else begin
                    rd_btn <= 0;
                end
            end
        end else if (MC_state == MC_READ) begin        //d
            if (last_query == ICACHE) begin
                //MC2IC_block[rd_btn*8-1:rd_btn*8-8] <= RAM2MC_data;
                //A reference to a wire or reg (`rd_btn') is not allowed in a constant expression.
                case (rd_btn)
                    1: MC2IC_block[7:0]<= RAM2MC_data;
                    2: MC2IC_block[15:8]<= RAM2MC_data;
                    3: MC2IC_block[23:16]<= RAM2MC_data;
                    4: MC2IC_block[31:24]<= RAM2MC_data;
                    5: MC2IC_block[39:32]<= RAM2MC_data;
                    6: MC2IC_block[47:40]<= RAM2MC_data;
                    7: MC2IC_block[55:48]<= RAM2MC_data;
                    8: MC2IC_block[63:56]<= RAM2MC_data;
                endcase        
            end else if (last_query == LSB) begin
                //MC2LSB_data[rd_btn*8-1:rd_btn*8-8] <= RAM2MC_data;
                case (rd_btn)
                    1: MC2LSB_data[7:0] <= RAM2MC_data;
                    2: MC2LSB_data[15:8] <= RAM2MC_data;
                    3: MC2LSB_data[23:16] <= RAM2MC_data;
                    4: MC2LSB_data[31:24] <= RAM2MC_data;
                endcase
            end
            if (last_query == iCache && rd_btn == 4 * BLOCK_WIDTH) begin
                MC_state <= MC_IDLE;
                MC2RAM_addr <= 0;
                MC2RAM_wr <= 0;
                rd_btn <= 0;
                MC2IC_en <= 1;
            end else if (last_query == LSB && rd_btn == LSB2MC_data_width) begin
                MC_state <= MC_IDLE;
                MC2RAM_addr <= 0;
                MC2RAM_wr <= 0;
                rd_btn <= 0;
                MC2LSB_r_en <= 1;
            end else begin
                rd_btn <= rd_btn + 1;
                RAM2MC_addr <= RAM2MC_addr + 1;
            end
        end else if (state == MC_WRITE && !stop_write) begin    //d
            if (wr_btn == LSB2MC_data_width) begin
                MC_state <= MC_IDLE;
                MC2RAM_addr <= 0;
                MC2RAM_wr <= 0;
                wr_btn <= 0;
                MC2LSB_w_en <= 1;
            end else begin
                wr_btn <= wr_btn + 1;
                RAM2MC_addr <= RAM2MC_addr + 1;
                case (wr_btn)
                    1: MC2RAM_data <= LSB2MC_data[15:8];
                    2: MC2RAM_data <= LSB2MC_data[23:16];
                    3: MC2RAM_data <= LSB2MC_data[31:24];
                endcase
            end
        end
    end
end

endmodule