//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output out_valid;
output [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

wire [3:0] LUT [0:9];
assign LUT[0] = 0;
assign LUT[1] = 2;
assign LUT[2] = 4;
assign LUT[3] = 6;
assign LUT[4] = 8;
assign LUT[5] = 1;
assign LUT[6] = 3;
assign LUT[7] = 5;
assign LUT[8] = 7;
assign LUT[9] = 9;

wire [6:0] odd_sum,even_sum;
wire [6:0] sum;

wire  [3:0] card_mul [0:7];
assign card_mul[0] = LUT[  card_num[7:4]];
assign card_mul[1] = LUT[card_num[15:12]];
assign card_mul[2] = LUT[card_num[23:20]];
assign card_mul[3] = LUT[card_num[31:28]];
assign card_mul[4] = LUT[card_num[39:36]];
assign card_mul[5] = LUT[card_num[47:44]];
assign card_mul[6] = LUT[card_num[55:52]];
assign card_mul[7] = LUT[card_num[63:60]];


wire [7:0] total [0:7];
wire [7:0] total_sorted [0:7];

mul4bit p0(.in0(snack_num[3:0]), .in1(price[3:0]), .out(total[0]));
mul4bit p1(.in0(snack_num[7 :4 ]), .in1(price[7 :4 ]), .out(total[1]));
mul4bit p2(.in0(snack_num[11:8 ]), .in1(price[11:8 ]), .out(total[2]));
mul4bit p3(.in0(snack_num[15:12]), .in1(price[15:12]), .out(total[3]));
mul4bit p4(.in0(snack_num[19:16]), .in1(price[19:16]), .out(total[4]));
mul4bit p5(.in0(snack_num[23:20]), .in1(price[23:20]), .out(total[5]));
mul4bit p6(.in0(snack_num[27:24]), .in1(price[27:24]), .out(total[6]));
mul4bit p7(.in0(snack_num[31:28]), .in1(price[31:28]), .out(total[7]));

wire [9:0] sub_out0;
wire [9:0] sub_out1;
wire [9:0] sub_out2;
wire [9:0] sub_out3;
wire [9:0] sub_out4;
wire [9:0] sub_out5;
wire [9:0] sub_out6;
wire [9:0] sub_out7;
//================================================================
//    DESIGN
//================================================================
assign even_sum = (((card_num[3:0] + card_num[11:8]) +(card_num[19:16] +card_num[27:24])) + ((card_num[35:32] + card_num[43:40]) +(card_num[51:48] +card_num[59:56])));
assign odd_sum = (((card_mul[0] + card_mul[1]) +(card_mul[2] +card_mul[3])) +((card_mul[4] +card_mul[5]) +(card_mul[6] +card_mul[7])));
assign sum = even_sum + odd_sum;

reg out_valid_temp;
always @(*) begin
    case(sum)//50,60,70,80,90,100,110,120
    10,20,30,50,60,70,80,90,100,110,120: out_valid_temp = 1;
    default: out_valid_temp = 0;
    endcase
end
assign out_valid = out_valid_temp;

CMP_8 P8_0(
    .in0(total[0]), .in1(total[1]), .in2(total[2]), .in3(total[3]), .in4(total[4]), .in5(total[5]), .in6(total[6]), .in7(total[7]),
    .out0(total_sorted[0]), .out1(total_sorted[1]), .out2(total_sorted[2]), .out3(total_sorted[3]), .out4(total_sorted[4]), .out5(total_sorted[5]), .out6(total_sorted[6]), .out7(total_sorted[7])
);

assign sub_out0 = input_money + (~total_sorted[7]) + 1;
assign sub_out1 = sub_out0    + (~total_sorted[6]) + 1;
assign sub_out2 = sub_out1    + (~total_sorted[5]) + 1;
assign sub_out3 = sub_out2    + (~total_sorted[4]) + 1;
assign sub_out4 = sub_out3    + (~total_sorted[3]) + 1;
assign sub_out5 = sub_out4    + (~total_sorted[2]) + 1;
assign sub_out6 = sub_out5    + (~total_sorted[1]) + 1;
assign sub_out7 = sub_out6    - (total_sorted[0])  ;

reg [8:0] out_change_temp;
always @(*) begin
    if(out_valid == 0 || sub_out0[9]) out_change_temp = input_money;
    else if(sub_out1[9]) out_change_temp = sub_out0;
    else if(sub_out2[9]) out_change_temp = sub_out1;
    else if(sub_out3[9]) out_change_temp = sub_out2;
    else if(sub_out4[9]) out_change_temp = sub_out3;
    else if(sub_out5[9]) out_change_temp = sub_out4;
    else if(sub_out6[9]) out_change_temp = sub_out5;
    else if(sub_out7[9]) out_change_temp = sub_out6;
    else out_change_temp = sub_out7;
end
assign out_change = out_change_temp;

endmodule

module CMP (
	input [7:0] in0,
	input [7:0] in1,
	output [7:0] out0,
	output [7:0] out1
);
    assign out0 = in0 > in1 ? in1 : in0;
    assign out1 = in0 > in1 ? in0 : in1;
endmodule

module mul4bit(in0,in1,out);
    input [3:0] in0, in1;
    output [7:0] out;
    wire [3:0] sh0 = in0[0] ? in1 : 0;
    wire [4:0] sh1 = in0[1] ? in1 << 1 : 0;
    wire [5:0] sh2 = in0[2] ? in1 << 2 : 0;
    wire [6:0] sh3 = in0[3] ? in1 << 3 : 0;
    assign out = sh0 + sh1 + sh2 + sh3;
endmodule

module CMP_8 (
    in0, in1, in2, in3, in4, in5, in6, in7,
    out0, out1, out2, out3, out4, out5, out6, out7
);
    input [7:0]  in0, in1, in2, in3, in4, in5, in6, in7;
    output [7:0] out0;
    output [7:0] out1;
    output [7:0] out2;
    output [7:0] out3;
    output [7:0] out4;
    output [7:0] out5;
    output [7:0] out6;
    output [7:0] out7;
    wire [7:0] w00,w01,w02,w03,w04,w05,w06,w07;
    wire [7:0] w10,w11,w12,w13,w14,w15,w16,w17;
    wire [7:0] w20,w21,w22,w23,w24,w25,w26,w27;
    wire [7:0] w32,w33,w34,w35;
    wire [7:0] w41,w43,w44,w46;
    wire [7:0] w51,w52,w53,w54,w55,w56;

    CMP P0(.in0(in2), .in1(in0), .out0(w00), .out1(w02));
    CMP P1(.in0(in1), .in1(in3), .out0(w01), .out1(w03));
    CMP P2(.in0(in4), .in1(in6), .out0(w04), .out1(w06));
    CMP P3(.in0(in7), .in1(in5), .out0(w05), .out1(w07));

    CMP P4(.in0(w00), .in1(w04), .out0(w10), .out1(w14));
    CMP P5(.in0(w01), .in1(w05), .out0(w11), .out1(w15));
    CMP P6(.in0(w02), .in1(w06), .out0(w12), .out1(w16));
    CMP P7(.in0(w03), .in1(w07), .out0(w13), .out1(w17));

    CMP P8(.in0(w10), .in1(w11), .out0(out0), .out1(w21));
    CMP P9(.in0(w12), .in1(w13), .out0(w22), .out1(w23));
    CMP P10(.in0(w14), .in1(w15), .out0(w24), .out1(w25));
    CMP P11(.in0(w16), .in1(w17), .out0(w26), .out1(out7));

    CMP P12(.in0(w22), .in1(w24), .out0(w32), .out1(w34));
    CMP P13(.in0(w23), .in1(w25), .out0(w33), .out1(w35));

    CMP P14(.in0(w21), .in1(w34), .out0(w41), .out1(w44));
    CMP P15(.in0(w33), .in1(w26), .out0(w43), .out1(w46));

    CMP P16(.in0(w41), .in1(w32), .out0(out1), .out1(out2));
    CMP P17(.in0(w43), .in1(w44), .out0(out3), .out1(out4));
    CMP P18(.in0(w35), .in1(w46), .out0(out5), .out1(out6));

endmodule
