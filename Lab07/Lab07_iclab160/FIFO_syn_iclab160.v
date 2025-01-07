module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;
reg [$clog2(WORDS):0] n_wptr;
reg [$clog2(WORDS):0] n_rptr;



reg [6:0] wptr_bin, rptr_bin;
reg [6:0] n_wptr_bin, n_rptr_bin;

reg [6:0] w_to_r_ptr, r_to_w_ptr;
reg wfull, rempty, n_wfull, n_rempty;

reg [7:0] rdata_temp, n_rdata;
reg rinc_delay, n_rinc_delay;


always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rempty <= 1;
        rptr_bin <= 0;
        rptr <= 0;
        rinc_delay <= 0;
        rdata <= 0;
    end
    else begin
        rempty <= n_rempty;
        rptr_bin <= n_rptr_bin;
        rptr <= n_rptr;
        rinc_delay <= n_rinc_delay;
        rdata <= n_rdata;
    end
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wfull <= 0;
        wptr_bin <= 0;
        wptr <= 0;
    end
    else begin
        wfull <= n_wfull;
        wptr_bin <= n_wptr_bin;
        wptr <= n_wptr;
    end
end






always @(*) begin
    if(w_to_r_ptr == n_rptr) begin
        n_rempty = 1;
    end
    else n_rempty = 0;
end

always @(*) begin
    if(({~r_to_w_ptr[6], ~r_to_w_ptr[5], r_to_w_ptr[4:0]} == n_wptr)) begin
        n_wfull = 1;
    end
    else n_wfull = 0;
end

always @(*) begin
        n_wptr_bin = wptr_bin + (!wfull && winc);
end

always @(*) begin
        n_rptr_bin = rptr_bin + (!rempty && rinc);
end


always @(*) begin
    n_wptr = bin2gray(n_wptr_bin);
    n_rptr = bin2gray(n_rptr_bin);
end


NDFF_BUS_syn  #(7) (
    .D(wptr), .Q(w_to_r_ptr), .clk(rclk), .rst_n(rst_n)
);
NDFF_BUS_syn  #(7) (
    .D(rptr), .Q(r_to_w_ptr), .clk(wclk), .rst_n(rst_n)
);



always @(*) begin
   if(rinc) n_rinc_delay = 1;
   else n_rinc_delay = 0;
end

always @(*) begin
    if(rinc_delay) n_rdata = rdata_temp;
    else n_rdata = rdata;
end



//A:read B:write
DUAL_64X8X1BM1 u_dual_sram(.A0(rptr_bin[0]), .A1(rptr_bin[1]), .A2(rptr_bin[2]), .A3(rptr_bin[3]), .A4(rptr_bin[4]), .A5(rptr_bin[5]), .B0(wptr_bin[0]), .B1(wptr_bin[1]), .B2(wptr_bin[2]), .B3(wptr_bin[3]), .B4(wptr_bin[4]), .B5(wptr_bin[5]),
                .DOA0(rdata_temp[0]), .DOA1(rdata_temp[1]), .DOA2(rdata_temp[2]),.DOA3(rdata_temp[3]), .DOA4(rdata_temp[4]), .DOA5(rdata_temp[5]), .DOA6(rdata_temp[6]), .DOA7(rdata_temp[7]),
                .DOB0(), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), .DOB7(),
                 .DIA0(), .DIA1(), .DIA2(), .DIA3(), .DIA4(), .DIA5(), .DIA6(), .DIA7(),
                .DIB0(wdata[0]), .DIB1(wdata[1]), .DIB2(wdata[2]),.DIB3(wdata[3]), .DIB4(wdata[4]), .DIB5(wdata[5]), .DIB6(wdata[6]), .DIB7(wdata[7]), 
                .WEAN(1'b1), .WEBN(~winc), .CKA(rclk), .CKB(wclk), .CSA(1'b1), .CSB(1'b1), .OEA(1'b1), .OEB(1'b1));


function [6:0] bin2gray;
    input[6:0] bin;
    begin
        bin2gray = bin ^ (bin >> 1);
    end
endfunction

endmodule
