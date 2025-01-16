module reservation_station(
    input wire          clk_in, // system clock signal
    input wire          rst_in, // reset signal
    input wire          rdy_in, // ready signal, pause cpu when low

    output wire         rs_full,

    input wire          RS_clear,
);

reg [5:0]               op[`RS_size-1:0];
reg [`RoB_addr-1:0]     qj[`RS_size-1:0];
reg [`RoB_addr-1:0]     qk[`RS_size-1:0];
reg [31:0]              vj[`RS_size-1:0];
reg [31:0]              vk[`RS_size-1:0];
reg                     is_qj[`RS_size:0];
reg                     is_qk[`RS_size-1:0];
reg [`RoB_addr-1:0]     A[`RS_size-1:0];
reg [31:0]              qi[`RS_size-1:0];
reg                     busy[`RS_size:0];

integer i;
always @(posedge clk_in)begin
    if(rst_in || RS_clear) begin
        for(i=0; i<`RS_size; i=i+1)begin
            op[i] <= 0;
            qj[i] <= 0;
            qk[i] <= 0;
            vj[i] <= 0;
            vk[i] <= 0;
            is_qj[i] <= 0;
            is_qk[i] <= 0;
            A[i] <= 0;
            qi[i] <= 0;
            busy[i] <= 0;
        end
    end
    else if (rdy_in) begin
        
    end
    else begin
    end
end
endmodule