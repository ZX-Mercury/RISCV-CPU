/*
`timescale 1ns / 1ps

module MC_tb();

    // 输入信号
    reg clk_in;
    reg rst_in;
    reg rdy_in;
    reg [7:0] RAM2MC_data;
    reg [31:0] IC2MC_addr;
    reg IC2MC_en;
    reg LSB2MC_en;
    reg LSB2MC_wr;
    reg [2:0] LSB2MC_data_width;
    reg [31:0] LSB2MC_data;
    reg [31:0] LSB2MC_addr;

    // 输出信号
    wire [31:0] MC2RAM_addr;
    wire [7:0] MC2RAM_data;
    wire MC2RAM_wr;
    wire MC2IC_en;
    wire [31:0] MC2LSB_data;
    wire MC2LSB_r_en;
    wire MC2LSB_w_en;

    // DUT（被测试模块）实例化
    MC dut(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .RAM2MC_data(RAM2MC_data),
        .MC2RAM_data(MC2RAM_data),
        .MC2RAM_addr(MC2RAM_addr),
        .MC2RAM_wr(MC2RAM_wr),
        .IC2MC_addr(IC2MC_addr),
        .IC2MC_en(IC2MC_en),
        .MC2IC_en(MC2IC_en),
        .LSB2MC_en(LSB2MC_en),
        .LSB2MC_wr(LSB2MC_wr),
        .LSB2MC_data_width(LSB2MC_data_width),
        .LSB2MC_data(LSB2MC_data),
        .LSB2MC_addr(LSB2MC_addr),
        .MC2LSB_data(MC2LSB_data),
        .MC2LSB_r_en(MC2LSB_r_en),
        .MC2LSB_w_en(MC2LSB_w_en)
    );

    // 时钟信号产生器
    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;
    end

    // 测试序列
    initial begin
        // 初始化信号
        rst_in = 1;
        rdy_in = 0;
        RAM2MC_data = 0;
        IC2MC_addr = 0;
        IC2MC_en = 0;
        LSB2MC_en = 0;
        LSB2MC_wr = 0;
        LSB2MC_data_width = 0;
        LSB2MC_data = 0;
        LSB2MC_addr = 0;

        // 复位模块
        #10 rst_in = 0;
        rdy_in = 1;

        // 测试 iCache 读取
        #10 IC2MC_addr = 32'h00000010;
        IC2MC_en = 1;
        #20 IC2MC_en = 0;

        // 测试 Load Store Buffer 写操作
        #10 LSB2MC_en = 1;
        LSB2MC_wr = 1;
        LSB2MC_data_width = 3;
        LSB2MC_data = 32'hDEADBEEF;
        LSB2MC_addr = 32'h10000000;
        #20 LSB2MC_en = 0;

        // 测试 Load Store Buffer 读操作
        #10 LSB2MC_en = 1;
        LSB2MC_wr = 0;
        LSB2MC_data_width = 3;
        LSB2MC_addr = 32'h10000004;
        #20 LSB2MC_en = 0;

        // 停止仿真
        #100 $stop;
    end

endmodule
*/