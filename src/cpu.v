// RISCV32 CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,     // system clock signal
  input  wire                 rst_in,     // reset signal
  input  wire                 rdy_in,     // ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,    // data input bus
  output wire [ 7:0]          mem_dout,   // data output bus
  output wire [31:0]          mem_a,      // address bus (only 17:0 is used)
  output wire                 mem_wr,     // write/read signal (1 for write)

  input  wire                 io_buffer_full, // 1 if uart buffer is full

  output wire [31:0]          dbgreg_dout     // cpu register output (debugging demo)
);

// implementation goes here
  parameter BLOCK_WIDTH = 1;
  parameter BLOCK_SIZE = 1 << BLOCK_WIDTH;
  parameter CACHE_WIDTH = 8;
  parameter BLOCK_NUM = 1 << CACHE_WIDTH;
  parameter ADDR_WIDTH = 32;
  parameter REG_WIDTH = 5;
  parameter EX_REG_WIDTH = 6;
  parameter NON_REG = 1 << REG_WIDTH;
  parameter ROB_WIDTH = 4;
  parameter EX_ROB_WIDTH = 5;
  parameter LSB_WIDTH = 3;
  parameter EX_LSB_WIDTH = 4;
  parameter LSB_SIZE = 1 << LSB_WIDTH;
  parameter NON_DEP = 1 << ROB_WIDTH;
  parameter LSB = 0, ICACHE = 1, IDLE = 0, READ = 1, WRITE = 2;

  //MC
  wire [BLOCK_SIZE*32-1:0] MC2IC_block;
  wire MC2IC_en;
  wire MC2LSB_r_en;
  wire MC2LSB_w_en;
  wire [31:0] MC2LSB_data;
  //IC
  wire [ADDR_WIDTH-1:0] IC2MC_addr;
  wire IC2MC_en;
  wire IC2IF_en;
  wire [31:0]IC2IF_data;
  //IF
  wire IF2IC_en;
  wire [ADDR_WIDTH-1:0] IF2IC_addr;
  wire IF2DC_en;
  wire [ADDR_WIDTH-1:0] IF2DC_pc;
  wire [6:0] IF2DC_opcode;
  wire [31:7] IF2DC_exop;
  //DC
  wire DC2IF_query_inst;
  wire DC2DP_en;
  wire [ADDR_WIDTH-1:0] DC2DP_pc;
  wire [6:0]   DC2DP_opcode;
  wire [REG_WIDTH-1:0]  DC2DP_rs1;
  wire [REG_WIDTH-1:0]  DC2DP_rs2;
  wire [REG_WIDTH-1:0]  DC2DP_rd;
  wire [31:0]  DC2DP_imm;
  //DP

  //RS
  wire RS2DP_full;
  wire RS2CDB_en;
  wire [ROB_WIDTH-1:0] RS2CDB_ROB_index;
  wire [31:0] RS2CDB_value;
  wire [ADDR_WIDTH-1:0] RS2DCB_next_pc;






// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule