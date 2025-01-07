module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
// parameter & integer
//==================================================================
//state
localparam IDLE = 0;
localparam INPUT = 1;
localparam DETERMINE = 2;
localparam MP = 3;
localparam MP_MIN = 4;
localparam IF = 5;
localparam CC = 6;
localparam CNN = 7;


//action
localparam GT_MAX = 0;
localparam GT_AVG = 1;
localparam GT_WEIGHT = 2;
localparam MAXPOOLING = 3;
localparam NEGATIVE = 4;
localparam HORIZONTAL_FLIP = 5;
localparam IMAGE_FILTER = 6;
localparam CROSS_CORRELATION = 7;
localparam MIN_POOLING = 8;



integer i, j;
//==================================================================
// reg & wire
//==================================================================
reg [3:0] state;
reg [3:0] act [0:5];
reg [4:0] size, ori_size;
reg [15:0] R,G,B;
reg [7:0] kernel [0:8];
reg [7:0] gray0, gray10, gray11, gray20, gray21;
wire [7:0] n_gray0,n_gray1, n_gray2;
wire [15:0] gray_concate0,gray_concate1,gray_concate2;

reg [15:0] mp_reg [0:1];
reg [7:0] mp_temp;

reg [7:0] buffer [0:2][0:15];

reg [10:0] cnt;
reg [3:0] kernel_cnt;
reg [4:0] cnt20;

reg N_flag,HF_flag;

//SRAM512x16
reg [5:0] x_512,y_512;
reg [15:0] din_512;
reg [15:0] dout_512;
reg [8:0] addr_512;// = (y_512 << size) + x_512;
reg web_512;
//SRAM128x16
reg [3:0] x_128,y_128;
reg [15:0] din_128;
reg [15:0] dout_128;
reg [6:0] addr_128;// = (y_128 << size) + x_128;
reg web_128;

reg direction;//0:512->128; 1:128->512

reg [5:0] x_read, x_write;
reg [5:0] y_read, y_write;

reg [5:0] x_cc;


// wire cs_512 = (state == CC && direction ==1) ? 1'b0 :1'b1;
reg cs_512;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cs_512 <= 0;
    end
    else begin
        if(state == CC && direction ==1) begin
            cs_512 <= 0;
        end
        else begin
            cs_512 <= 1;
        end
    end
end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//       x_cc <= 0;
//     end
//     else begin
//       if(state ==CC) begin
//             if(cnt20 == 19) begin
//                 if(x_cc == (size - 1)) x_cc <= 0;
//                 else x_cc <= x_cc + 1'b1;
//             end
//       end
//     end
// end



// SRAM512X16 M0(A0,A1,A2,A3,A4,A5,A6,A7,A8,
//             DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,
//             DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,DI9,DI10,DI11,DI12,DI13,DI14,DI15,
//             CK,WEB,OE, CS);
SRAM512X16 M512(.A0(addr_512[0]), .A1(addr_512[1]), .A2(addr_512[2]), .A3(addr_512[3]), .A4(addr_512[4]), .A5(addr_512[5]), .A6(addr_512[6]), .A7(addr_512[7]), .A8(addr_512[8]),
                .DO0(dout_512[0]), .DO1(dout_512[1]),.DO2(dout_512[2]), .DO3(dout_512[3]), .DO4(dout_512[4]), .DO5(dout_512[5]), .DO6(dout_512[6]), .DO7(dout_512[7]),
                .DO8(dout_512[8]), .DO9(dout_512[9]),.DO10(dout_512[10]), .DO11(dout_512[11]), .DO12(dout_512[12]), .DO13(dout_512[13]), .DO14(dout_512[14]), .DO15(dout_512[15]),
                .DI0(din_512[0]),  .DI1(din_512[1]), .DI2(din_512[2]), .DI3(din_512[3]), .DI4(din_512[4]), .DI5(din_512[5]), .DI6(din_512[6]), .DI7(din_512[7]),
                .DI8(din_512[8]),  .DI9(din_512[9]), .DI10(din_512[10]), .DI11(din_512[11]), .DI12(din_512[12]), .DI13(din_512[13]), .DI14(din_512[14]), .DI15(din_512[15]),
                .CK(clk), .WEB(web_512), .OE(1'b1), .CS(1'b1));

// module SRAM128x16 (A0,A1,A2,A3,A4,A5,A6,DO0,DO1,DO2,DO3,DO4,DO5,DO6,
//                    DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,
//                    DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,DI9,
//                    DI10,DI11,DI12,DI13,DI14,DI15,CK,WEB,OE, CS);
SRAM128x16 M128(.A0(addr_128[0]), .A1(addr_128[1]), .A2(addr_128[2]), .A3(addr_128[3]), .A4(addr_128[4]), .A5(addr_128[5]), .A6(addr_128[6]),
            .DO0(dout_128[0]), .DO1(dout_128[1]), .DO2(dout_128[2]),  .DO3(dout_128[3]),  .DO4(dout_128[4]),  .DO5(dout_128[5]),  .DO6(dout_128[6]),  .DO7(dout_128[7]),
            .DO8(dout_128[8]), .DO9(dout_128[9]), .DO10(dout_128[10]), .DO11(dout_128[11]), .DO12(dout_128[12]), .DO13(dout_128[13]), .DO14(dout_128[14]), .DO15(dout_128[15]),
            .DI0(din_128[0]), .DI1(din_128[1]), .DI2(din_128[2]),  .DI3(din_128[3]),  .DI4(din_128[4]),  .DI5(din_128[5]),  .DI6(din_128[6]),  .DI7(din_128[7]),
            .DI8(din_128[8]), .DI9(din_128[9]), .DI10(din_128[10]), .DI11(din_128[11]), .DI12(din_128[12]), .DI13(din_128[13]), .DI14(din_128[14]), .DI15(din_128[15]),
            .CK(clk), .WEB(web_128), .OE(1'b1), .CS(1'b1));


wire [7:0] mp_result;

wire [15:0] dout = (direction == 0) ? dout_512 : dout_128;

CMP4_MP MP0(
            .in0(mp_reg[0][15:8]),
            .in1(mp_reg[0][7:0]),
            .in2(mp_reg[1][15:8]),
            .in3(mp_reg[1][7:0]),
            .flag(state),
            .mp_result(mp_result));

assign web_128 = ~web_512;



reg act_over; 
always @(*) begin
    case(state)
        MP,MP_MIN: begin
          if((cnt==0 && ((x_write == ((size >> 2) -1)) && (y_write == ((size >> 1) -1)))) || size == 4) begin
                act_over = 1;
          end  
          else act_over = 0;
        end
        IF:begin
            if(x_write == ((size >> 1) - 1) && (y_write == ((size - 1)))) begin
              act_over = 1;
            end
            else act_over = 0;
        end
        CC:begin
            if((x_write ==(size - 1)) && (y_write ==(size - 1)) && cnt20 == 19) begin
                act_over = 1;
            end
            else act_over = 0;
        end
        default: act_over = 0; 
    endcase
end
reg start_IF;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) start_IF <= 0;
    else begin
        if(state == IDLE || state == DETERMINE) start_IF <= 0;
        else if(act_over) start_IF <= 0;
        else if(state == IF) begin
            case(size)
                4:begin
                    if(cnt == 4) start_IF <= 1;
                end
                8:begin
                    if((y_read == 1 || y_read == (1+16) ||y_read == (1+32) || y_read == (1+48)) && x_read == 2) start_IF <= 1;
                end
                16:begin
                    if((y_read == 1 || y_read == (1+16) ||y_read == (1+32) || y_read == (1+48)) && x_read == 2) start_IF <= 1;
                end
            endcase
        end
    end
    
end

// reg stop_shift_IF;
// always @(posedge clk ) begin
//     if(state == IDLE) stop_shift_IF <= 0;
//     else if(state == IF) begin
//         if(x_read == ((size >> 1) - 1) && ())
//     end
// end

// reg wait_first_data;
// always @(posedge clk) begin
//     if(state == IDLE || state == INPUT || state == DETERMINE) wait_first_data <= 0;
//     else  begin
//         if(act_over) wait_first_data <= 0;
//         else if(cnt==0 && wait_first_data==0) wait_first_data <= 1;
//     end
// end


reg [7:0] md0,md1,md2,md3,md4,md5,md6,md7,md8,md9,md10,md11;
wire [15:0] md_result;
MEDIAN M123(.in0(md0), .in1(md1), .in2(md2), .in3(md3), .in4(md4), .in5(md5), .in6(md6), .in7(md7), .in8(md8), .in9(md9), .in10(md10), .in11(md11), .median_result(md_result));
//median_in
always @(*) begin
    md0  = 0;
    md1  = 0;
    md2  = 0;
    md3  = 0;
    md4  = 0;
    md5  = 0;
    md6  = 0;
    md7  = 0;
    md8  = 0;
    md9  = 0;
    md10 = 0;
    md11 = 0;
    case(size)
        4: begin//[3][0~3]place to [2][4~6]
            case(cnt)
                5:begin
                    md0  = buffer[0][0];
                    md1  = buffer[0][0];
                    md2  = buffer[1][0];
                    md3  = buffer[0][0];
                    md4  = buffer[0][0];
                    md5  = buffer[1][0];
                    md6  = buffer[0][1];
                    md7  = buffer[0][1];
                    md8  = buffer[1][1];
                    md9  = buffer[0][2];
                    md10 = buffer[0][2];
                    md11 = buffer[1][2];
                end
                6:begin
                    md0  = buffer[0][1];
                    md1  = buffer[0][1];
                    md2  = buffer[1][1];
                    md3  = buffer[0][2];
                    md4  = buffer[0][2];
                    md5  = buffer[1][2];
                    md6  = buffer[0][3];
                    md7  = buffer[0][3];
                    md8  = buffer[1][3];
                    md9  = buffer[0][3];
                    md10 = buffer[0][3];
                    md11 = buffer[1][3];
                end
                7:begin
                    md0  = buffer[0][0];
                    md1  = buffer[1][0];
                    md2  = buffer[2][0];
                    md3  = buffer[0][0];
                    md4  = buffer[1][0];
                    md5  = buffer[2][0];
                    md6  = buffer[0][1];
                    md7  = buffer[1][1];
                    md8  = buffer[2][1];
                    md9  = buffer[0][2];
                    md10 = buffer[1][2];
                    md11 = buffer[2][2];
                end
                8:begin
                    md0  = buffer[0][1];
                    md1  = buffer[1][1];
                    md2  = buffer[2][1];
                    md3  = buffer[0][2];
                    md4  = buffer[1][2];
                    md5  = buffer[2][2];
                    md6  = buffer[0][3];
                    md7  = buffer[1][3];
                    md8  = buffer[2][3];
                    md9  = buffer[0][3];
                    md10 = buffer[1][3];
                    md11 = buffer[2][3];
                end
                9:begin
                    md0  = buffer[1][0];
                    md1  = buffer[2][0];
                    md2  = buffer[2][4];
                    md3  = buffer[1][0];
                    md4  = buffer[2][0];
                    md5  = buffer[2][4];
                    md6  = buffer[1][1];
                    md7  = buffer[2][1];
                    md8  = buffer[2][5];
                    md9  = buffer[1][2];
                    md10 = buffer[2][2];
                    md11 = buffer[2][6];
                end
                10:begin
                    md0  = buffer[1][1];
                    md1  = buffer[2][1];
                    md2  = buffer[2][5];
                    md3  = buffer[1][2];
                    md4  = buffer[2][2];
                    md5  = buffer[2][6];
                    md6  = buffer[1][3];
                    md7  = buffer[2][3];
                    md8  = buffer[2][7];
                    md9  = buffer[1][3];
                    md10 = buffer[2][3];
                    md11 = buffer[2][7];
                end
                11:begin
                    md0  = buffer[2][0];
                    md1  = buffer[2][4];
                    md2  = buffer[2][4];
                    md3  = buffer[2][0];
                    md4  = buffer[2][4];
                    md5  = buffer[2][4];
                    md6  = buffer[2][1];
                    md7  = buffer[2][5];
                    md8  = buffer[2][5];
                    md9  = buffer[2][2];
                    md10 = buffer[2][6];
                    md11 = buffer[2][6];
                end
                12:begin
                    md0  = buffer[2][1];
                    md1  = buffer[2][5];
                    md2  = buffer[2][5];
                    md3  = buffer[2][2];
                    md4  = buffer[2][6];
                    md5  = buffer[2][6];
                    md6  = buffer[2][3];
                    md7  = buffer[2][7];
                    md8  = buffer[2][7];
                    md9  = buffer[2][3];
                    md10 = buffer[2][7];
                    md11 = buffer[2][7];
                end
            endcase
        end
        8, 16:begin
            if(y_write == 0) begin
                if(x_write == 0) begin
                    md0  = buffer[1][0];
                    md1  = buffer[1][0];
                    md2  = buffer[2][0];
                    md3  = buffer[1][0];
                    md4  = buffer[1][0];
                    md5  = buffer[2][0];
                    md6  = buffer[1][1];
                    md7  = buffer[1][1];
                    md8  = buffer[2][1];
                    md9  = buffer[1][2];
                    md10 = buffer[1][2];
                    md11 = buffer[2][2];
                end
                else if(x_write == ((size >> 1) - 1)) begin
                    md0  = buffer[1][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[2][(x_write <<1) - 1 ];
                    md3  = buffer[1][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[2][(x_write <<1)     ];
                    md6  = buffer[1][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[2][(x_write <<1) + 1 ];
                    md9  = buffer[1][(x_write <<1) + 1 ];
                    md10 = buffer[1][(x_write <<1) + 1 ];
                    md11 = buffer[2][(x_write <<1) + 1 ];
                end
                else begin
                    md0  = buffer[1][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[2][(x_write <<1) - 1 ];
                    md3  = buffer[1][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[2][(x_write <<1)     ];
                    md6  = buffer[1][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[2][(x_write <<1) + 1 ];
                    md9  = buffer[1][(x_write <<1) + 2 ];
                    md10 = buffer[1][(x_write <<1) + 2 ];
                    md11 = buffer[2][(x_write <<1) + 2 ];
                end
            end
            else if(y_write == ((size ) - 1)) begin
                if(x_write == 0) begin
                    md0  = buffer[0][0];
                    md1  = buffer[1][0];
                    md2  = buffer[1][0];
                    md3  = buffer[0][0];
                    md4  = buffer[1][0];
                    md5  = buffer[1][0];
                    md6  = buffer[0][1];
                    md7  = buffer[1][1];
                    md8  = buffer[1][1];
                    md9  = buffer[0][2];
                    md10 = buffer[1][2];
                    md11 = buffer[1][2];
                end
                else if(x_write == ((size >> 1) - 1)) begin
                    md0  = buffer[0][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[1][(x_write <<1) - 1 ];
                    md3  = buffer[0][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[1][(x_write <<1)     ];
                    md6  = buffer[0][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[1][(x_write <<1) + 1 ];
                    md9  = buffer[0][(x_write <<1) + 1 ];
                    md10 = buffer[1][(x_write <<1) + 1 ];
                    md11 = buffer[1][(x_write <<1) + 1 ];
                end
                else begin
                    md0  = buffer[0][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[1][(x_write <<1) - 1 ];
                    md3  = buffer[0][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[1][(x_write <<1)     ];
                    md6  = buffer[0][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[1][(x_write <<1) + 1 ];
                    md9  = buffer[0][(x_write <<1) + 2 ];
                    md10 = buffer[1][(x_write <<1) + 2 ];
                    md11 = buffer[1][(x_write <<1) + 2 ];
                end
            end
            else begin
                if(x_write == 0) begin
                    md0  = buffer[0][0];
                    md1  = buffer[1][0];
                    md2  = buffer[2][0];
                    md3  = buffer[0][0];
                    md4  = buffer[1][0];
                    md5  = buffer[2][0];
                    md6  = buffer[0][1];
                    md7  = buffer[1][1];
                    md8  = buffer[2][1];
                    md9  = buffer[0][2];
                    md10 = buffer[1][2];
                    md11 = buffer[2][2];
                end
                else if(x_write == ((size >> 1) - 1)) begin
                    md0  = buffer[0][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[2][(x_write <<1) - 1 ];
                    md3  = buffer[0][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[2][(x_write <<1)     ];
                    md6  = buffer[0][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[2][(x_write <<1) + 1 ];
                    md9  = buffer[0][(x_write <<1) + 1 ];
                    md10 = buffer[1][(x_write <<1) + 1 ];
                    md11 = buffer[2][(x_write <<1) + 1 ];
                end
                else begin
                    md0  = buffer[0][(x_write <<1) - 1 ];
                    md1  = buffer[1][(x_write <<1) - 1 ];
                    md2  = buffer[2][(x_write <<1) - 1 ];
                    md3  = buffer[0][(x_write <<1)     ];
                    md4  = buffer[1][(x_write <<1)     ];
                    md5  = buffer[2][(x_write <<1)     ];
                    md6  = buffer[0][(x_write <<1) + 1 ];
                    md7  = buffer[1][(x_write <<1) + 1 ];
                    md8  = buffer[2][(x_write <<1) + 1 ];
                    md9  = buffer[0][(x_write <<1) + 2 ];
                    md10 = buffer[1][(x_write <<1) + 2 ];
                    md11 = buffer[2][(x_write <<1) + 2 ];
                end    
            end
        end
    endcase
    
end


reg [19:0] partial_sum;
wire [19:0] n_partial_sum;
reg [7:0] mul_in0_temp,mul_in1;//in0:img,in1:kernel
wire [7:0] mul_in0;
wire [15:0] mul_out;

// assign mul_in0 = N_flag ? ~mul_in0_temp : mul_in0_temp;
assign mul_in0 = mul_in0_temp;
assign mul_out = mul_in0 * mul_in1;
assign n_partial_sum = mul_out + partial_sum;
 
//mul_in1
always @(*) begin
    mul_in1 =0;
    if(cnt <=5) begin
        case(cnt)
            2:mul_in1 = kernel[4];
            3:mul_in1 = kernel[5];
            4:mul_in1 = kernel[7];
            5:mul_in1 = kernel[8];
            default:mul_in1 = 0;
        endcase
    end
    else begin
        case(cnt20)
            11:mul_in1 = kernel[0];
            12:mul_in1 = kernel[1];
            13:mul_in1 = kernel[2];
            14:mul_in1 = kernel[3];
            15:mul_in1 = kernel[4];
            16:mul_in1 = kernel[5];
            17:mul_in1 = kernel[6];
            18:mul_in1 = kernel[7];
            19:mul_in1 = kernel[8];
            default:mul_in1 = 0;
        endcase
    end
end

always @(*) begin
    if(cnt <=5) begin
        case(cnt)
            2:mul_in0_temp = buffer[1][0];
            3:mul_in0_temp = buffer[1][1];
            4:mul_in0_temp = buffer[2][0];
            5:mul_in0_temp = buffer[2][1];
            default:mul_in0_temp = 0;
        endcase
    end
    else begin
        case(cnt20)
            11: begin//upper_left
                if(y_write == 0) begin
                    mul_in0_temp = 0;
                end
                else begin
                    if(x_write == (size - 1)) begin
                        mul_in0_temp = 0;
                    end
                    else begin
                        mul_in0_temp = buffer[0][x_write];
                    end
                end
            end
            12:begin
                // if(y_write == 0) begin//upper_mid
                //     if(x_write == (size - 1)) begin
                //         mul_in0_temp = N_flag ? ~buffer[0][0] : buffer[0][0];
                //     end
                //     else begin
                //         mul_in0_temp = 0;
                //     end
                // end
                // else begin
                //     if(x_write == (size - 1)) begin
                //         mul_in0_temp =N_flag ? ~buffer[0][0] : buffer[0][0];
                //     end
                //     else begin
                //         mul_in0_temp =N_flag ? ~buffer[0][x_write + 1] : buffer[0][x_write + 1];
                //     end
                    
                // end
                if(x_write == (size - 1)) begin
                    mul_in0_temp = buffer[0][0];
                end
                else begin
                    if(y_write == 0) mul_in0_temp = 0;
                    else mul_in0_temp = buffer[0][x_write + 1];
                end
            end
            13: begin
                if(y_write == 0) begin//upper_right////////////////要改
                    if(x_write == (size - 1)) begin
                        mul_in0_temp = buffer[0][1];
                    end
                    else begin
                        mul_in0_temp = 0;
                    end
                end

                else if(x_write == (size - 2)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    if(x_write == (size - 1)) begin
                        mul_in0_temp = buffer[0][1];
                    end
                    else begin
                        mul_in0_temp = buffer[0][x_write + 2];
                    end
                end
            end
            14: begin
                if(x_write == (size - 1)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    mul_in0_temp = buffer[1][x_write];
                end
            end
            15: begin
                if(x_write == (size - 1)) begin
                    mul_in0_temp = buffer[1][0];
                end
                else begin
                    mul_in0_temp = buffer[1][x_write + 1];
                end
            end
            16: begin
                if(x_write == (size - 1)) begin
                    mul_in0_temp = buffer[1][1];
                end
                else if(x_write == (size - 2)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    mul_in0_temp = buffer[1][x_write + 2];
                end
            end
            17: begin
                if(x_write == (size - 1)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    if(y_write == (size - 1)) begin
                        mul_in0_temp = 0;
                    end
                    else begin
                        mul_in0_temp =buffer[2][x_write];
                    end
                end
            end
            18: begin
                if(x_write == (size - 1)) begin
                    if(y_write == (size - 2)) begin
                        mul_in0_temp = 0;
                    end
                    else begin
                        mul_in0_temp = buffer[2][0];
                    end
                end
                else if(y_write == (size - 1)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    mul_in0_temp =  buffer[2][x_write + 1];
                end
            end
            19: begin
                if(x_write == (size - 1)) begin
                    if(y_write == (size - 2)) begin
                        mul_in0_temp = 0;
                    end
                    else begin
                        mul_in0_temp =  buffer[2][1];
                    end
                end
                else if(y_write == (size - 1) || x_write ==(size - 2)) begin
                    mul_in0_temp = 0;
                end
                else begin
                    mul_in0_temp =  buffer[2][x_write + 2];
                end
            end
            default: begin
              mul_in0_temp = 0;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      partial_sum <= 0;
    end
    else begin
        if(state == CC) begin
            if(cnt == 0 || cnt20 == 1) partial_sum <= 0;
            else if((cnt <= 5) || (cnt20 >= 11)) begin
                partial_sum <= n_partial_sum;
            end
        end
        
    end
end

reg [19:0] shift_out;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      shift_out <= 0;
    end
    else begin
        if(state == CC) begin
            if((cnt == 5 || cnt20 == 19) ) begin
              shift_out <= n_partial_sum;
            end
        else if(cnt > 5) begin
            shift_out[0] <= 0;
            for (i = 0;i<19 ; i++) begin
                shift_out[19 - i] <= shift_out[18 - i];
            end
        end
        end
        
    end
end

//==================================================================
// design
//==================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if(in_valid && cnt == 2) state <= INPUT;
                else if(in_valid2) state <= DETERMINE;
            end 
            INPUT: begin
                if(in_valid2) state <= DETERMINE;
            end
            DETERMINE: begin
                if(!in_valid2) begin
                    case(act[0])
                        MAXPOOLING: state <= MP;
                        IMAGE_FILTER: state <= IF;
                        MIN_POOLING: state <= MP_MIN;
                        default: state <= CC;
                    endcase
                end
            end
            MP,MP_MIN: begin
                if(act_over) begin
                    case(act[1])
                        MAXPOOLING: state <= MP;
                        IMAGE_FILTER: state <= IF;
                        MIN_POOLING: state <= MP_MIN;
                        default: state <= CC;
                    endcase
                end
            end 
            IF: begin
                if(act_over) begin
                    case(act[1])
                        MAXPOOLING: state <= MP;
                        IMAGE_FILTER: state <= IF;
                        MIN_POOLING: state <= MP_MIN;
                        default: state <= CC;
                    endcase
                end
            end
            CC: begin
                if(act_over) begin
                  state <= IDLE;
                end
            end
            default:begin
                
            end 
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                if(in_valid) begin
                    if(cnt == 2) cnt <= 0;
                    else cnt <= cnt + 1;
                end 
            end 
            INPUT: begin
                if(!in_valid && cnt==5) cnt <= 5;
                else if(cnt == 5) cnt <= 0;
                else cnt <= cnt + 1;
            end
            DETERMINE:begin
                if((act[0] == MAXPOOLING || act[0] == MIN_POOLING)) cnt<= 4;
                else cnt <= 0;
            end
            MP,MP_MIN: begin
                if(act_over) begin
                    if(act[1] == MAXPOOLING || act[1] == MIN_POOLING) cnt <= 4;
                    else cnt <= 0;
                end 
                else begin
                    if(cnt == 5) cnt <= 1;
                    else if(cnt == 3) cnt <= 0;
                    else cnt <= cnt + 1;
                end
            end
            IF: begin
                if(act_over) begin
                    if(act[1] == MAXPOOLING || act[1] == MIN_POOLING) cnt <= 4;
                    else cnt <= 0;
                end
                else begin
                    case(size)
                        4:begin
                            if(cnt == 12) cnt <= 0;
                            else  cnt<= cnt + 1;
                        end
                        8:begin
                            if(cnt == 4) cnt <= 1;
                            else  cnt<= cnt + 1;
                        end
                        16:begin
                            if(cnt == 8) cnt <= 1;
                            else  cnt<= cnt + 1;
                        end
                    endcase
                end 
            end
            CC: begin
            //   if(cnt < 18) cnt<= cnt + 1;
                if(act_over) begin
                    cnt <= 0;
                end
                else begin
                    case(size)
                        4:begin
                            if(cnt < 6) cnt<= cnt + 1;
                        end
                        8: begin
                            if(cnt < 10) cnt<= cnt + 1;
                        end
                        16: begin
                            if(cnt < 18) cnt<= cnt + 1;
                        end
                    endcase
                end
                
            end
            default:begin
                
            end 
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        R <= 0;
        G <= 0;
        B <= 0;
    end
    else begin
        if(in_valid) begin
            case(cnt % 3)
                0:R <= image;
                1:G <= image;
                2:B <= image;
            endcase
        end
        
    end
    
end
//gray 0
wire [7:0] temp_max;
assign temp_max = (R > G) ? R : G;
assign n_gray0 = (temp_max > B) ? temp_max : B;
//gray1
assign n_gray1 = (R + G + B) / 3;
//gray 2
assign n_gray2 = (R >> 2) + (G >> 1) + (B >> 2);

//gray_scale write together
assign gray_concate0 = {gray0, n_gray0};
assign gray_concate1 = {gray10, gray11};
assign gray_concate2 = {gray20, gray21};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        gray0  <= 0;
        gray10 <= 0;
        gray20 <= 0;
        gray11 <= 0;
        gray21 <= 0;
    end
    else if(state == INPUT) begin
        case(cnt % 6)
        0: begin
            gray0  <= n_gray0;
            gray10 <= n_gray1;
            gray20 <= n_gray2;
        end
        3: begin
          gray11 <= n_gray1;
          gray21 <= n_gray2;
        end
    endcase
    end
    
end
//data_in 512
always @(*) begin
    case(state)
        INPUT: begin
          case(cnt % 6)
              3:din_512 = gray_concate0;
              4:din_512 = gray_concate1;
              5:din_512 = gray_concate2;
              default:din_512 = 0;
          endcase
        end
        MP,MP_MIN: begin
            if(direction == 1 && cnt ==0) din_512 = {mp_temp, mp_result};
            else din_512 = 0;
        end
        IF: begin
            if(direction == 1 && start_IF) din_512 = md_result;
            else din_512 = 0;
        end
        default:din_512 = 0;
    endcase
end

//data_in_128
always @(*) begin
    case(state)
        MP,MP_MIN: begin
            if(direction == 0 && cnt ==0) din_128 = {mp_temp, mp_result};
            else din_128 = 0;
        end
        IF: begin
            if(direction == 0 && start_IF) din_128 = md_result;
            else din_128 = 0;
        end
        default:din_128 = 0;
    endcase
end


//buffer
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<3; i++)begin
            for(j=0;j<16; j++)begin
                buffer[i][j] <= 0;
            end
        end
    end
    else if(act_over) begin
        for(i=0; i<3; i++)begin
            for(j=0;j<16; j++)begin
                buffer[i][j] <= 0;
            end
        end
    end
    else if(state == IF) begin
        if(size == 4) begin
            case(cnt)
                1:begin
                    buffer[0][0] <= dout[15:8];
                    buffer[0][1] <= dout[7:0];
                end
                2:begin
                    buffer[0][2] <= dout[15:8];
                    buffer[0][3] <= dout[7:0];
                end
                3:begin
                    buffer[1][0] <= dout[15:8];
                    buffer[1][1] <= dout[7:0];
                end
                4:begin
                    buffer[1][2] <= dout[15:8];
                    buffer[1][3] <= dout[7:0];
                end
                5:begin
                    buffer[2][0] <= dout[15:8];
                    buffer[2][1] <= dout[7:0];
                end
                6:begin
                    buffer[2][2] <= dout[15:8];
                    buffer[2][3] <= dout[7:0];
                end
                7:begin
                    buffer[2][4] <= dout[15:8];
                    buffer[2][5] <= dout[7:0];
                end
                8:begin
                    buffer[2][6] <= dout[15:8];
                    buffer[2][7] <= dout[7:0];
                end
            endcase
        end
        else begin
            case(cnt)
                1:begin
                  buffer[0][0] <= buffer[1][0];
                  buffer[1][0] <= buffer[2][0];
                  buffer[2][0] <= dout[15:8];

                  buffer[0][1] <= buffer[1][1];
                  buffer[1][1] <= buffer[2][1];
                  buffer[2][1] <= dout[7:0];
                end
                2:begin
                  buffer[0][2] <= buffer[1][2];
                  buffer[1][2] <= buffer[2][2];
                  buffer[2][2] <= dout[15:8];

                  buffer[0][3] <= buffer[1][3];
                  buffer[1][3] <= buffer[2][3];
                  buffer[2][3] <= dout[7:0];
                end
                3:begin
                  buffer[0][4] <= buffer[1][4];
                  buffer[1][4] <= buffer[2][4];
                  buffer[2][4] <= dout[15:8];

                  buffer[0][5] <= buffer[1][5];
                  buffer[1][5] <= buffer[2][5];
                  buffer[2][5] <= dout[7:0];
                end
                4:begin
                  buffer[0][6] <= buffer[1][6];
                  buffer[1][6] <= buffer[2][6];
                  buffer[2][6] <= dout[15:8];

                  buffer[0][7] <= buffer[1][7];
                  buffer[1][7] <= buffer[2][7];
                  buffer[2][7] <= dout[7:0];
                end
                5:begin
                  buffer[0][8] <= buffer[1][8];
                  buffer[1][8] <= buffer[2][8];
                  buffer[2][8] <= dout[15:8];

                  buffer[0][9] <= buffer[1][9];
                  buffer[1][9] <= buffer[2][9];
                  buffer[2][9] <= dout[7:0];
                end
                6:begin
                  buffer[0][10] <= buffer[1][10];
                  buffer[1][10] <= buffer[2][10];
                  buffer[2][10] <= dout[15:8];

                  buffer[0][11] <= buffer[1][11];
                  buffer[1][11] <= buffer[2][11];
                  buffer[2][11] <= dout[7:0];
                end
                7:begin
                  buffer[0][12] <= buffer[1][12];
                  buffer[1][12] <= buffer[2][12];
                  buffer[2][12] <= dout[15:8];

                  buffer[0][13] <= buffer[1][13];
                  buffer[1][13] <= buffer[2][13];
                  buffer[2][13] <= dout[7:0];
                end
                8:begin
                  buffer[0][14] <= buffer[1][14];
                  buffer[1][14] <= buffer[2][14];
                  buffer[2][14] <= dout[15:8];

                  buffer[0][15] <= buffer[1][15];
                  buffer[1][15] <= buffer[2][15];
                  buffer[2][15] <= dout[7:0];
                end
            endcase
        end
        
    end
    else if(state == CC) begin
        // if(size == 4) begin
        //     case(cnt)
        //         1:begin
                  
        //         end
        //     endcase
        // end
        if((size==4 && cnt <=4) || (size ==8 && cnt <=8) || (size == 16 && cnt <=16)) begin
            case(cnt)
                1: begin
                    buffer[1][0] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][1] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                2: begin
                    buffer[2][0] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][1] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                3: begin
                    buffer[1][2] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][3] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                4: begin
                    buffer[2][2] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][3] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                5: begin
                    buffer[1][4] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][5] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                6: begin
                    buffer[2][4] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][5] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                7: begin
                    buffer[1][6] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][7] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                8: begin
                    buffer[2][6] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][7] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                9: begin
                    buffer[1][8] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][9] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                10: begin
                    buffer[2][8] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][9] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                11:begin
                    buffer[1][10] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][11] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                12:begin
                    buffer[2][10] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][11] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                13:begin
                    buffer[1][12] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][13] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                14:begin
                    buffer[2][12] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][13] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                15:begin
                    buffer[1][14] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[1][15] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
                16:begin
                    buffer[2][14] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                    buffer[2][15] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                end
            endcase
        end
        else begin
            if(x_write == (size - 1)) begin
                case(cnt20)
                    1: begin
                        buffer[0][0] <= buffer[1][0];
                        buffer[1][0] <= buffer[2][0];
                        buffer[2][0] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][1] <= buffer[1][1];
                        buffer[1][1] <= buffer[2][1];
                        buffer[2][1] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    2: begin
                        buffer[0][2] <= buffer[1][2];
                        buffer[1][2] <= buffer[2][2];
                        buffer[2][2] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][3] <= buffer[1][3];
                        buffer[1][3] <= buffer[2][3];
                        buffer[2][3] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    3: begin
                        buffer[0][4] <= buffer[1][4];
                        buffer[1][4] <= buffer[2][4];
                        buffer[2][4] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][5] <= buffer[1][5];
                        buffer[1][5] <= buffer[2][5];
                        buffer[2][5] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    4: begin
                        buffer[0][6] <= buffer[1][6];
                        buffer[1][6] <= buffer[2][6];
                        buffer[2][6] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][7] <= buffer[1][7];
                        buffer[1][7] <= buffer[2][7];
                        buffer[2][7] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    5: begin
                        buffer[0][8] <= buffer[1][8];
                        buffer[1][8] <= buffer[2][8];
                        buffer[2][8] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][9] <= buffer[1][9];
                        buffer[1][9] <= buffer[2][9];
                        buffer[2][9] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    6:begin
                        buffer[0][10] <= buffer[1][10];
                        buffer[1][10] <= buffer[2][10];
                        buffer[2][10] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][11] <= buffer[1][11];
                        buffer[1][11] <= buffer[2][11];
                        buffer[2][11] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    7:begin
                        buffer[0][12] <= buffer[1][12];
                        buffer[1][12] <= buffer[2][12];
                        buffer[2][12] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][13] <= buffer[1][13];
                        buffer[1][13] <= buffer[2][13];
                        buffer[2][13] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                    8:begin
                        buffer[0][14] <= buffer[1][14];
                        buffer[1][14] <= buffer[2][14];
                        buffer[2][14] <= HF_flag ? (N_flag ? ~dout[7:0] : dout[7:0]) : (N_flag ? ~dout[15:8] : dout[15:8]);
                        buffer[0][15] <= buffer[1][15];
                        buffer[1][15] <= buffer[2][15];
                        buffer[2][15] <= HF_flag ? (N_flag ? ~dout[15:8] : dout[15:8]) : (N_flag ? ~dout[7:0] : dout[7:0]);
                    end
                endcase
            end 
        end






        // case(size)
        //     8,16:begin
        //         if() begin
        //             case(cnt)
        //                 1: begin
        //                     buffer[1][0] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][1] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 2: begin
        //                     buffer[2][0] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][1] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 3: begin
        //                     buffer[1][2] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][3] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 4: begin
        //                     buffer[2][2] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][3] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 5: begin
        //                     buffer[1][4] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][5] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 6: begin
        //                     buffer[2][4] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][5] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 7: begin
        //                     buffer[1][6] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][7] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 8: begin
        //                     buffer[2][6] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][7] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 9: begin
        //                     buffer[1][8] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][9] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 10: begin
        //                     buffer[2][8] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][9] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 11:begin
        //                     buffer[1][10] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][11] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 12:begin
        //                     buffer[2][10] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][11] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 13:begin
        //                     buffer[1][12] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][13] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 14:begin
        //                     buffer[2][12] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][13] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 15:begin
        //                     buffer[1][14] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[1][15] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end
        //                 16:begin
        //                     buffer[2][14] <= HF_flag ? dout[7:0] : dout[15:8];
        //                     buffer[2][15] <= HF_flag ? dout[15:8] : dout[7:0];
        //                 end

        //             endcase
        //         end
        //         else begin
        //             if(x_write == (size - 1)) begin
        //                 case(cnt20)
        //                     2: begin
        //                         buffer[0][0] <= buffer[1][0];
        //                         buffer[1][0] <= buffer[2][0];
        //                         buffer[2][0] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][1] <= buffer[1][1];
        //                         buffer[1][1] <= buffer[2][1];
        //                         buffer[2][1] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     3: begin
        //                         buffer[0][2] <= buffer[1][2];
        //                         buffer[1][2] <= buffer[2][2];
        //                         buffer[2][2] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][3] <= buffer[1][3];
        //                         buffer[1][3] <= buffer[2][3];
        //                         buffer[2][3] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     4: begin
        //                         buffer[0][4] <= buffer[1][4];
        //                         buffer[1][4] <= buffer[2][4];
        //                         buffer[2][4] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][5] <= buffer[1][5];
        //                         buffer[1][5] <= buffer[2][5];
        //                         buffer[2][5] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     5: begin
        //                         buffer[0][6] <= buffer[1][6];
        //                         buffer[1][6] <= buffer[2][6];
        //                         buffer[2][6] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][7] <= buffer[1][7];
        //                         buffer[1][7] <= buffer[2][7];
        //                         buffer[2][7] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     6: begin
        //                         buffer[0][8] <= buffer[1][8];
        //                         buffer[1][8] <= buffer[2][8];
        //                         buffer[2][8] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][9] <= buffer[1][9];
        //                         buffer[1][9] <= buffer[2][9];
        //                         buffer[2][9] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     7:begin
        //                         buffer[0][10] <= buffer[1][10];
        //                         buffer[1][10] <= buffer[2][10];
        //                         buffer[2][10] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][11] <= buffer[1][11];
        //                         buffer[1][11] <= buffer[2][11];
        //                         buffer[2][11] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     8:begin
        //                         buffer[0][12] <= buffer[1][12];
        //                         buffer[1][12] <= buffer[2][12];
        //                         buffer[2][12] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][13] <= buffer[1][13];
        //                         buffer[1][13] <= buffer[2][13];
        //                         buffer[2][13] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                     9:begin
        //                         buffer[0][14] <= buffer[1][14];
        //                         buffer[1][14] <= buffer[2][14];
        //                         buffer[2][14] <= HF_flag ? dout[7:0] : dout[15:8];

        //                         buffer[0][15] <= buffer[1][15];
        //                         buffer[1][15] <= buffer[2][15];
        //                         buffer[2][15] <= HF_flag ? dout[15:8] : dout[7:0];
        //                     end
        //                 endcase
        //             end 
        //         end
        //     end
        // endcase
    end

end



// //x_write
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      x_write <= 0;
    end
    // else if(act_over) x_write <= 0;
    else begin
        case(state)
            INPUT: begin
              if(in_valid2) begin
                x_write <= 0;
              end
              else if(cnt == 5) begin
                if(x_write == ((size >> 1) -1)) x_write <= 0;
                else x_write <= x_write + 1'b1;
              end
            end
            MP,MP_MIN: begin
                if(cnt == 0 && (direction==0||direction==1)) begin
                    if((x_write == ((size >> 2) -1)) || act_over) x_write <= 0;
                    else x_write <= x_write + 1'b1;
                end
            end
            IF: begin
                if(start_IF) begin
                    if((x_write == ((size >>1) -1)) || act_over) x_write <= 0;
                    else x_write <= x_write + 1'b1;
                end
            end
            CC: begin
                if(cnt20 == 19) begin
                    if(x_write == (size - 1)) x_write <= 0;
                    else x_write <= x_write + 1'b1;
                end
            end
        endcase
        // if(state == INPUT) begin
        //     if(in_valid2) begin
        //         x_write <= 0;
        //       end
        //       else if(cnt == 5) begin
        //         if(x_write == ((size >> 1) -1)) x_write <= 0;
        //         else x_write <= x_write + 1'b1;
        //       end
        // end
        // else if(state == MP || state ==MP_MIN) begin
        //     if(cnt == 0 && (direction==0||direction==1)) begin
        //             if((x_write == ((size >> 2) -1)) || act_over) x_write <= 0;
        //             else x_write <= x_write + 1'b1;
        //         end
        // end
        // else if(state == IF) begin
        //     if(start_IF) begin
        //         if((x_write == ((size >>1) -1)) || act_over) x_write <= 0;
        //         else x_write <= x_write + 1'b1;
        //     end
        // end
        // else if(state ==CC) begin
        //   if(cnt20 == 19) begin
        //             if(x_write == (size - 1)) x_write <= 0;
        //             else x_write <= x_write + 1'b1;
        //         end
        // end
    end
end

//y_write
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        y_write <= 16;
    end
    else if(act_over) y_write <= 0;
    else begin
        case(state)
            IDLE: begin
                if(in_valid) begin
                  y_write <= 16;
                end
            end
            INPUT: begin
                if(cnt % 6 == 5) begin
                    if(x_write == ((size >> 1) - 1)) y_write <= y_write + 1'b1;
                end
            end 
            DETERMINE: y_write <= 0;
            MP,MP_MIN: begin
                if(cnt == 0) begin
                    if((x_write == ((size >> 2) - 1))) y_write <= y_write + 1'b1;
                end
            end
            IF: begin
                if(start_IF) begin
                    if(x_write == ((size >>1) - 1)) y_write <= y_write + 1'b1;
                end
            end
            CC: begin
                if(cnt20 == 19) begin
                  if(x_write == (size - 1)) y_write <= y_write + 1'b1;
                end
            end
        endcase
    end
end

//x_read
always @(posedge clk or negedge rst_n) begin
    if(!rst_n ) begin
      x_read <= 0;
    end
    else if(act_over || ((state == DETERMINE) && (!in_valid2) && (act[0]==0)))begin//flip x
        if(act[1] == 0 && HF_flag == 1) begin
            if((state == MP || state == MP_MIN)) begin
                if(size == 4) x_read <= 1;
                else x_read <= ((size >> 2) - 1);
            end 
            else x_read <= ((size >> 1) - 1);
        end 
        else begin
            x_read <= 0;
        end 
    end
    else begin
        case(state)
            IDLE: x_read <= 0;
            MP,MP_MIN: begin
                case(cnt)
                    0:x_read <= x_read + 1;
                    2:begin
                      if(x_read == ((size >> 1) - 1)) x_read <= 0;
                      else x_read <= x_read + 1;
                    end 
                    5:x_read <= x_read + 1;
                endcase
            end
            IF: begin
                if(x_read == ((size >>1) - 1) && state==IF) x_read <= 0;//////////////////////////
                else x_read <= x_read + 1;
            end
            CC:begin
                // if((size == 8 && cnt <=7) || (size == 16 && cnt <=15))begin//read 1st,2nd row
                //     case(cnt[0])
                //         1:x_read <= ((size == 8 && cnt ==7) || (size == 16 && cnt ==15)) ? 0 : (HF_flag ? (x_read - 1) : (x_read + 1));
                //     endcase
                // end
                // else if(x_write == (size - 1)) begin
                //     case(size)
                //         4:begin
                          
                //         end
                //         8: begin
                //             case(cnt20)
                //                 0,1,2: x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                //                 3:x_read <= HF_flag ? 3 : 0;
                //             endcase
                //         end
                //         16: begin
                //             case(cnt20)
                //                 0,1,2,3,4,5,6: x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                //                 6:x_read <= HF_flag ? 7 : 0;
                //             endcase
                //         end
                //     endcase
                // end
                case(size)
                    4:begin
                        if(cnt == 3) begin
                            x_read <= HF_flag ? 1 : 0;
                        end
                        else if(cnt < 3 && cnt[0] == 1)begin
                            x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                        end
                        else if(x_write == (size - 1)) begin
                            case(cnt20)
                                0: x_read <= HF_flag ? 0 : 1;
                                1:x_read <= HF_flag ? 1 : 0;
                            endcase
                        end
                    end
                    8:begin
                        if(cnt == 7) begin
                            x_read <= HF_flag ? 3 : 0;
                        end
                        else if(cnt < 7 && cnt[0] == 1) begin
                            x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                        end
                        else if(x_write == (size - 1)) begin
                            case(cnt20)
                                0,1,2: x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                                3:x_read <= HF_flag ? 3 : 0;
                            endcase
                        end
                    end
                    16: begin
                        if(cnt == 15) begin
                            x_read <= HF_flag ? 7 : 0;
                        end
                        else if(cnt < 15 && cnt[0] == 1) begin
                            x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                        end
                        else if(x_write == (size - 1)) begin
                            case(cnt20)
                                0,1,2,3,4,5,6: x_read <= HF_flag ? (x_read - 1) : (x_read + 1);
                                7:x_read <= HF_flag ? 7 : 0;
                            endcase
                        end
                    end
                endcase
            end
        endcase
    end
end


//y_read
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        y_read <= 16;
    end
    else if(act_over)begin
        if(!((state == MP || state == MP_MIN) && size ==4)) y_read <= 0;
    end 
    else begin
        case(state)
        IDLE: begin
            if(in_valid2) begin
                case(action)
                    0:y_read <= 16;
                    1:y_read <= 32;
                    2:y_read <= 48;
                endcase
            end
        end
        INPUT: begin
            if(in_valid2) begin
                case(action)
                    0:y_read <= 16;
                    1:y_read <= 32;
                    2:y_read <= 48;
                endcase
            end
        end
        MP,MP_MIN: begin
        //    if(x_read == ((size >> 1) -1)) y_read <= y_read + 1'b1;
            case(cnt)
                0:y_read <= y_read - 1'b1;
                1:y_read <= y_read + 1'b1;
                2:begin
                    if(x_read == ((size >> 1) -1)) y_read <= y_read + 1'b1;
                    else y_read <= y_read - 1'b1;
                end
                3:y_read <= y_read + 1'b1;
                4:y_read <= y_read + 1'b1;
                5:y_read <= y_read - 1'b1;
            endcase
        end
        IF:begin
            if(x_read == ((size >>1) -1)) y_read <= y_read + 1'b1;
        end
        CC: begin
            if((size == 4 && cnt <= 3) || (size == 8 && cnt <=7) || (size == 16 && cnt <=15))begin//read 1st,2nd row
                case(cnt)
                    0,2,4,6,8,10,12,14:y_read <= y_read + 1'b1;
                    1,5,9,11,13:y_read <= y_read - 1'b1;
                    7:y_read <= (size == 8) ? y_read : y_read - 1'b1;
                    3: y_read <= (size == 4) ? y_read : y_read - 1'b1;
                endcase
            end
            else if(x_write == (size - 2) && cnt20 ==19) begin//next cycle want to push buffer
                y_read <= y_read + 1'b1;
            end
        end
        endcase
    end
end

//addr512
// always @(*) begin
//     case(state)
//         INPUT: begin
//           case(cnt % 6)
//               3:addr_512 = (y_512 << 3) + x_512;
//               4:addr_512 = ((y_512 + 16)  << 3) + x_512;
//               5:addr_512 = ((y_512 + 32) << 3) + x_512;
//               default:addr_512 = (y_512 << 3) + x_512;
//           endcase
//         end
//         DETERMINE: addr_512 = (y_512 << 3) + x_512;
//         default: begin
//             addr_512 = (y_512 << 3) + x_512;
//         end
//     endcase
// end

//new
always @(*) begin
    if(state == CC && direction ==1) begin
        addr_512 = 0;
    end
    else begin
          case(state)
            INPUT: begin
              case(cnt % 6)
                  3:addr_512 = (y_write << 3) + x_write;
                  4:addr_512 = ((y_write + 16)  << 3) + x_write;
                  5:addr_512 = ((y_write + 32) << 3) + x_write;
                  default:addr_512 = 0;
              endcase
            end
            DETERMINE: addr_512 = (y_write << 3) + x_write;
            default: begin
                addr_512 = (direction==0) ? ((y_read << 3) + x_read) : ((y_write << 3) + x_write);
            end
        endcase
    end
    
end

//addr128
// always @(*) begin
//     case (state)
//         MP: addr_128 =  (y_128 << 3) + x_128;
//         default: addr_128 =  (y_128 << 3) + x_128;
//     endcase
// end

//new addr128
always @(*) begin
        // MP: addr_128 =  (y_128 << 3) + x_128;
    addr_128 = (direction==1) ? ((y_read << 3) + x_read) : ((y_write << 3) + x_write);
end




//WEB512
always @(*) begin
    // case(state)
    //     INPUT: begin
    //         web_512 = 1'b0;
    //     end
    //     MP: web_512 = 1'b1;
    //     default: web_512 = 1'b1;
    // endcase
    
    // if(state == INPUT ) web_512 = 1'b0;
    // else begin
    //     if(direction == 0) web_512 = 1'b1;
    //     else web_512 = 1'b0;
    // end
    case(state)
        INPUT:begin
            if(!in_valid && cnt == 0) begin
                web_512 = 1'b1;
            end
            else web_512 = 1'b0;
        end
        MP, MP_MIN:begin
            if(direction == 0) web_512 = 1'b1;
            else web_512 = 1'b0;
        end
        default: begin
            if(direction == 0) web_512 = 1'b1;
            else web_512 = 1'b0;
        end 
    endcase
end
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         web_512 <= 0;
//     end
//     else begin
//         case(state)
//             INPUT: begin
//                 web_512 <= 1'b0;
//             end
//             DETERMINE: begin
//                 if(!in_valid2) web_512 <= 1'b1;
              
//             end
//             MP: web_512 <= 1'b1;
//         endcase
//     end
// end

//direction
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        direction <= 0;
    end
    else begin
        case(state)
            IDLE: direction <= 0;
            MP,MP_MIN: begin
                if(act_over && size != 4) direction <= ~direction;
            end
            IF: begin
                if(act_over) direction <= ~direction;
            end
        endcase
    end
end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         x_512 <= 0;
//     end
//     else begin
//         case(state)
//             INPUT: begin
//                 if(in_valid2) begin
//                   x_512 <= 0;
//                 end
//                 else if(cnt % 6 == 5) begin
//                     if(x_512 == ((size >> 1) -1)) x_512 <= 0;
//                     else x_512 <= x_512 + 1'b1;
//                 end
//             end 
//             DETERMINE: begin
                
//             end
//             MP: begin
//                 // if(x_512 == ((size >> 1) -1)) x_512 <= 0;
//                 // else x_512 <= x_512 + 1'b1;
//                 case(cnt)
//                     0:x_512 <= x_512 + 1;
//                     2:begin
//                       if(x_512 == ((size >> 1) - 1)) x_512 <= 0;
//                       else x_512 <= x_512 + 1;
//                     end 
//                     5:x_512 <= x_512 + 1;
//                 endcase
//             end
//         endcase
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         y_512 <= 16;
//     end
//     else begin
//         case(state)
//             INPUT: begin
//                 if(in_valid2) begin
//                     case(action)
//                         0:y_512    <= 16;
//                         1:y_512    <= 32;
//                         2:y_512 <= 48;
//                     endcase
//                 end
//                 else if(cnt % 6 == 5) begin
//                     if(x_512 == ((size >> 1) -1)) y_512 <= y_512 + 1'b1;
//                 end
//             end 
//             DETERMINE:begin
                
//             end
//             MP: begin
//             //    if(x_512 == ((size >> 1) -1)) y_512 <= y_512 + 1'b1;
//                 case(cnt)
//                     0:y_512 <= y_512 - 1'b1;
//                     1:y_512 <= y_512 + 1'b1;
//                     2:begin
//                         if(x_512 == ((size >> 1) -1)) y_512 <= y_512 + 1'b1;
//                         else y_512 <= y_512 - 1'b1;
//                     end
//                     3:y_512 <= y_512 + 1'b1;
//                     4:y_512 <= y_512 + 1'b1;
//                     5:y_512 <= y_512 - 1'b1;
//                 endcase
//             end
//         endcase
//     end
// end

// //x,y_128
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//       x_128 <= 0;
//     end
//     else begin
//         if(direction == 0)begin//write
//             case(state)
//                 MP: begin
//                     if(cnt == 0) begin
//                         if((x_128 == ((size >> 2) -1))) x_128 <= 0;
//                         else x_128 <= x_128 + 1'b1;
//                     end
//                 end
//             endcase
//         end 
//     end
// end
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//       y_128 <= 0;
//     end
//     else begin
//         if(direction == 0)begin//write
//             case(state)
//                 MP: begin
//                     if(cnt == 0) begin
//                         if((x_128 == ((size >> 2) -1))) y_128 <= y_128 + 1'b1;
//                     end
//                 end
//             endcase
//         end 
//     end
// end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        N_flag <= 1;
    end
    else begin
        if(state == IDLE) N_flag <= 0;
        else if(state == DETERMINE) begin
            if(action == NEGATIVE && in_valid2) N_flag <= ~N_flag;
        end
    end
    
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        HF_flag <= 1;
    end
    else begin
        
        if(state == DETERMINE) begin
            if(action == HORIZONTAL_FLIP && in_valid2) HF_flag <= ~HF_flag;
        end
        else if(state == IDLE) HF_flag <= 0;
    end
    
end
reg [2:0] act_pointer;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        act_pointer <= 0;
    end
    else begin
        if(state == IDLE) act_pointer <= 0;
        else if(state == DETERMINE && in_valid2) begin
            if(action == MAXPOOLING || action == IMAGE_FILTER) begin
                act_pointer <= act_pointer + 1;
            end    
        end
    end
    
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 6; i++) begin
            act[i] <= 0;
        end
    end
    else begin
        if(state == DETERMINE && in_valid2) begin
            // if(action == MAXPOOLING || action == IMAGE_FILTER) begin
            //     act[act_pointer] <= action;
            // end
            case(action)
                MAXPOOLING: begin
                    if(N_flag == 1'b1) begin
                      act[act_pointer] <= MIN_POOLING;
                    end
                    else act[act_pointer] <= MAXPOOLING;
                end 
                IMAGE_FILTER: begin
                    act[act_pointer] <= IMAGE_FILTER;
                end
            endcase
        end
        else if(act_over) begin
            act[5] <= 0;
            for(i = 0; i < 5; i++) begin
                act[i] <= act[i+1];
            end
        end
    end
end

//MP_REG
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<2; i++) begin
            mp_reg[i] <= 0;
        end
    end
    else if(state == MP || state==MP_MIN) begin
        case(cnt)
            0,5:mp_reg[0] <= dout;
            1:mp_reg[1] <= dout;
            2:begin
                mp_reg[0] <= dout;
            end 
            3:mp_reg[1] <= dout;
        endcase
    end
end
//mp_temp
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mp_temp <= 0;
    end
    else begin
        if(state == MP || state == MP_MIN) begin
            if(cnt == 2) begin
                mp_temp <= mp_result;
            end
        end
    end
    
end


//cnt202020202020220
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt20 <= 0;
    end
    else if(state == CC) begin
        if(cnt >= 6 ) begin
            if(cnt20 == 19) cnt20 <= 0;
            else cnt20 <= cnt20 + 1;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        kernel_cnt <= 0;
    end
    else begin
        if(in_valid) begin
            if(kernel_cnt < 9) kernel_cnt <= kernel_cnt + 1;  
        end
        else begin
          kernel_cnt <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<9; i++) begin
            kernel[i] <= 0;
        end
    end
    else if(in_valid && kernel_cnt < 9) begin
        kernel[8] <= template;
        for(i=0; i<8; i++) begin
            kernel[i] <= kernel[i+1];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        size <= 0;
    end
    // else if(state == IDLE && in_valid) begin
    //     case(image_size)
    //         0:size <= 4;
    //         1:size <= 8;
    //         2:size <= 16;
    //     endcase
    // end
    else begin
        case(state)
            IDLE: begin
                if(in_valid && cnt == 0) begin
                    case(image_size)
                        0:size <= 4;
                        1:size <= 8;
                        2:size <= 16;
                    endcase
                end
            end
            DETERMINE: begin
                size <= ori_size;
            end
            MP, MP_MIN: begin
                if(act_over && size != 4) size <= (size >> 1);
            end
            default: begin
              size <= size;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ori_size <= 0;
    end
    else if(state == IDLE && in_valid && cnt == 0) begin
        case(image_size)
            0:ori_size <= 4;
            1:ori_size <= 8;
            2:ori_size <= 16;
            default: ori_size <= ori_size;
        endcase
    end
end


// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         act <= 0;
//     end
//     else if(in_valid2) begin
        
//     end
// end



// always @(*) begin
//     if(state == CC) begin
//         if((x_write ==(size - 1)) && (y_write ==(size - 1)) && cnt20 == 19) begin
            
//         end
//     end
// end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_valid <= 0;
    end
    else begin
        if(state == CC) begin
            if(act_over) out_valid <= 0;
            else if(cnt >= 5) out_valid <= 1;
        end
    end
end

always @(*) begin
    if(out_valid) begin
      out_value = shift_out[19];
    end
    else begin
      out_value = 0;
    end
end


  
endmodule

module MEDIAN (
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    input [7:0] in4,
    input [7:0] in5,
    input [7:0] in6,
    input [7:0] in7,
    input [7:0] in8,
    input [7:0] in9,
    input [7:0] in10,
    input [7:0] in11,
    output [15:0] median_result
);
    wire [7:0] max0, max1, max2, max3;
    wire [7:0] min0, min1, min2, min3;
    wire [7:0] mid0, mid1, mid2, mid3;

    CMP3 C0 (.in0(in0), .in1(in1), .in2(in2),  .min(min0), .mid(mid0), .max(max0));
    CMP3 C1 (.in0(in3), .in1(in4), .in2(in5),  .min(min1), .mid(mid1), .max(max1));
    CMP3 C2 (.in0(in6), .in1(in7), .in2(in8),  .min(min2), .mid(mid2), .max(max2));
    CMP3 C3(.in0(in9), .in1(in10), .in2(in11), .min(min3), .mid(mid3), .max(max3));

    wire [7:0] share_max, share_min, share_large_mid, share_little_mid;

    CMP2 C4(.in0(max1), .in1(max2), .min(share_max), .max());
    CMP2 C5(.in0(min1), .in1(min2), .min(), .max(share_min));
    CMP2 C6(.in0(mid1), .in1(mid2), .min(share_little_mid), .max(share_large_mid));

    wire [7:0] min_max0, max_min0, mid_mid0, mid_temp0;
    wire [7:0] min_max1, max_min1, mid_mid1, mid_temp1;
    wire [7:0] median0, median1;

    CMP2 C7(.in0(share_max), .in1(max0), .min(min_max0), .max());
    CMP2 C8(.in0(share_min), .in1(min0), .min(), .max(max_min0));
    CMP2 C9(.in0(share_little_mid), .in1(mid0), .min(), .max(mid_temp0));
    CMP2 C10(.in0(share_large_mid), .in1(mid_temp0), .min(mid_mid0), .max());
    CMP3 C11(.in0(min_max0), .in1(mid_mid0), .in2(max_min0), .min(), .mid(median0), .max());
 
    CMP2 C12(.in0(share_max), .in1(max3), .min(min_max1), .max());
    CMP2 C13(.in0(share_min), .in1(min3), .min(), .max(max_min1));
    CMP2 C14(.in0(share_little_mid), .in1(mid3), .min(), .max(mid_temp1));
    CMP2 C15(.in0(share_large_mid), .in1(mid_temp1), .min(mid_mid1), .max());
    CMP3 C16(.in0(min_max1), .in1(mid_mid1), .in2(max_min1), .min(), .mid(median1), .max());

    assign median_result = {median0, median1};
endmodule


module CMP2 (
	input [7:0] in0,
	input [7:0] in1,
	output [7:0] min,
	output [7:0] max
);
    assign min = in0 > in1 ? in1 : in0;
    assign max = in0 > in1 ? in0 : in1;
endmodule


module CMP3 (
	input [7:0] in0,
	input [7:0] in1,
    input [7:0] in2,
	output [7:0] min,
	output [7:0] mid,
    output [7:0] max
);
    wire [7:0] temp_min0, temp_min1,temp_max;
    CMP2 P0(.in0(in0      ), .in1(in1      ), .min(temp_min0), .max(temp_max));
    CMP2 P1(.in0(temp_max ), .in1(in2      ), .min(temp_min1), .max(max     ));
    CMP2 P2(.in0(temp_min0), .in1(temp_min1), .min(min      ), .max(mid     ));
endmodule

module CMP4_MP (
	input [7:0] in0,
	input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    input [3:0] flag,
	output [7:0] mp_result
);
    wire [7:0] temp_min0, temp_min1, temp_max0, temp_max1, max, min;
    CMP2 M0(.in0(in0), .in1(in1), .min(temp_min0), .max(temp_max0));
    CMP2 M1(.in0(in2), .in1(in3), .min(temp_min1), .max(temp_max1));
    CMP2 M2(.in0(temp_min0), .in1(temp_min1), .min(min), .max());
    CMP2 M3(.in0(temp_max0), .in1(temp_max1), .min(), .max(max));

    //state MP is 3
    assign mp_result = (flag == 3) ? max : min;

endmodule