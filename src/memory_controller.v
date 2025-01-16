`include "definitions.v"
module MC{
    input   wire clk_in;
    input   wire rst_in;
    input   wire rdy_in;

    //ram
    input   wire    [7:0]    RAM2MC_data;
    output  reg     [7:0]    MC2RAM_data;
    output  reg     [31:0]   MC2RAM_addr;
    output  reg              MC2RAM_wr;

    //iCache
    input   reg     [ADDER_WIDTH-1:0]   IC2MC_addr,
    input   wire                        IC2MC_en,
    output  wire    [BLK_WIDTH:0][31:0] MC2IC_block,
    output  wire                        MC2IC_en,

    //Load Store Buffer
    input  wire                    LSB2MC_en,
    input  wire                    LSB2MC_wr,          // 0:read,1:write
    input  wire [             2:0] LSB2MC_data_width,  //0:byte,1:hw,2:w
    input  wire [            31:0] LSB2MC_data,
    input  wire [ADDR_WIDTH - 1:0] LSB2MC_addr,
    output reg                     MC2LSB_r_en,
    output reg                     MC2LSB_w_en,
    output reg  [            31:0] MC2LSB_data
};

parameter
    MC_IDLE = 0,
    MC_READ = 1,
    MC_WRITE = 2;

wire stop_write;
reg [2:0] MC_state;     //0: idle, 1: read, 2: write
reg [3 + BLOCK_WIDTH - 1:0] rd_btn;
reg [2:0] wr_btn;
reg last_query;
wire stop_write;  // 1 if uart buffer is full write to address 0x30000 or 0x30004.

assign stop_write = io_buffer_full && LSBMC_en && LSBMC_wr && (LSBMC_addr == 32'h30000 || LSBMC_addr == 32'h30004);

always @(posedge clk_in) begin
    if (rst_in) begin
        MC_state <= MC_IDLE;
        last_query <= 0;
        wr_btn <= 0;
        rd_btn <= 0;
        MC2LSB_r_en <= 0;
        MC2LSB_w_en <= 0;
        MC2IC_en <= 0;
        MC2RAM_data <= 0;
        MC2RAM_addr <= 0;
        MC2RAM_wr <= 0;
    end else if (rdy_in) begin
        if (state == MC_IDLE) begin     //将初始状态改为rd状态或者wt状态
            MC2LSB_r_en <= 0;
            MC2LSB_w_en <= 0;
            MC2IC_en <= 0;
            if (IC2MC_en && !MC2IC_en) begin
                MC_state <= MC_READ;
                rd_btn <= 0;
                last_query <= iCache;
                MC2RAM_addr <= IC2MC_addr;
                MC2RAM_wr <= 0;
            end else if (LSB2MC_en && ) begin
                MC_state <= LSB2MC_wr ? MC_WRITE : MC_READ;
                rd_btn <= 0;
                last_query <= LSB;
                MC2RAM_addr <= LSB2MC_addr;
                MC2RAM_wr <= LSB2MC_wr ? 1 : 0;
                if (LSBMC_wr) begin
                    w_byte_num <= 1;
                    MCRAM_data <= LSBMC_data[7:0];
                end else begin
                    r_byte_num <= 0;
                end
            end
        end else if (state == MC_READ) begin        //d
            if (last_query == iCache) begin
                MC2IC_block[rd_btn*8-1:rd_btn*8-8] <= RAM2MC_data;
            end else if (last_query == LSB) begin
                MC2LSB_data[rd_btn*8-1:rd_btn*8-8] <= RAM2MC_data;
            end
            if (last_query == iCache && rd_btn == 4 * BLK_WIDTH) begin
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