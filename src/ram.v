// implements 128KB of on-board RAM

module ram
#(
  parameter ADDR_WIDTH = 17
)
(
  input  wire                   clk_in,   // system clock
  input  wire                   en_in,    // chip enable 使能信号，仅在使能时 RAM 可读写。
  input  wire                   r_nw_in,  // read/write select (read: 1, write: 0) 读/写选择信号（1 为读，0 为写）。
  input  wire  [ADDR_WIDTH-1:0] a_in,     // memory address 地址输入，决定操作的存储单元位置。
  input  wire  [ 7:0]           d_in,     // data input 数据输入，用于写操作。
  output wire  [ 7:0]           d_out     // data output 数据输出，用于读操作。
);

wire       ram_bram_we;                   //写使能信号，控制是否允许写操作。
wire [7:0] ram_bram_dout;                 //从内部 RAM 输出的数据，连接到外部的 d_out。

single_port_ram_sync #(.ADDR_WIDTH(ADDR_WIDTH),
                       .DATA_WIDTH(8)) ram_bram(
  .clk(clk_in),
  .we(ram_bram_we),
  .addr_a(a_in),
  .din_a(d_in),
  .dout_a(ram_bram_dout)
);

assign ram_bram_we = (en_in) ? ~r_nw_in      : 1'b0;
assign d_out       = ram_bram_dout;

endmodule