//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);



// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;

wire [10:0] decode_data;
wire [4:0] decode_mode;

HAMMING_IP #(.IP_BIT(11)) I_HAMMING_IP_data(.IN_code(in_data), .OUT_code(decode_data)); 
HAMMING_IP #(.IP_BIT(5)) I_HAMMING_IP_mode(.IN_code(in_mode), .OUT_code(decode_mode)); 

reg [4:0] cnt;
reg signed [10:0] map [0:7];
reg [1:0] mode;
reg signed [22:0] det_2x2 [0:5];
reg signed [35:0] det_3x3 [0:2];
reg signed [48:0] det_4x4;
// wire signed [10:0] map_copy [0:1][0:3];
// assign map_copy[0][0] = map[0];
// assign map_copy[0][1] = map[1];
// assign map_copy[0][2] = map[2];
// assign map_copy[0][3] = map[3];
// assign map_copy[1][0] = map[4];
// assign map_copy[1][1] = map[5];
// assign map_copy[1][2] = map[6];
// assign map_copy[1][3] = map[7];

reg [206:0] out_reg;

integer i;

// wire signed [10:0] mul_11x11_0_in0, mul_11x11_1_in0, mul_11x11_2_in0, mul_11x11_3_in0;
// wire signed [10:0] mul_11x11_0_in1, mul_11x11_1_in1, mul_11x11_2_in1, mul_11x11_3_in1;
// wire signed [21:0] mul_11x11_0_out, mul_11x11_1_out, mul_11x11_2_out, mul_11x11_3_out;

wire signed [10:0] mul_11x11_0_in0, mul_11x11_1_in0, mul_11x11_2_in0;
wire signed [10:0] mul_11x11_0_in1, mul_11x11_1_in1, mul_11x11_2_in1;
wire signed [21:0] mul_11x11_0_out, mul_11x11_1_out, mul_11x11_2_out;

wire signed [21:0] add_22x22_0_in0, add_22x22_1_in0;
wire signed [21:0] add_22x22_0_in1, add_22x22_1_in1;
wire signed [22:0] add_22x22_0_out, add_22x22_1_out;

wire signed [10:0] mul_23x11_0_in0, mul_23x11_1_in0;
reg  signed [22:0] mul_23x11_0_in1, mul_23x11_1_in1;
wire signed [33:0] mul_23x11_0_out, mul_23x11_1_out;

reg  signed [35:0] add_36x34_0_in0, add_36x34_1_in0;//partial_sum
wire signed [33:0] add_36x34_0_in1, add_36x34_1_in1;
wire signed [35:0] add_36x34_0_out, add_36x34_1_out;

wire signed [10:0] mul_36x11_0_in0;
reg  signed [35:0] mul_36x11_0_in1;
wire signed [46:0] mul_36x11_0_out;

reg  signed [48:0] add_49x47_in0;//partial_sum
wire signed [46:0] add_49x47_in1;
wire signed [48:0] add_49x47_out;

//det_2x2 mul
assign mul_11x11_0_in0 = map[2];
assign mul_11x11_0_in1 = map[7];
assign mul_11x11_0_out = mul_11x11_0_in0 * mul_11x11_0_in1;

assign mul_11x11_1_in0 = map[3];
assign mul_11x11_1_in1 = map[6];
assign mul_11x11_1_out = mul_11x11_1_in0 * mul_11x11_1_in1;

assign mul_11x11_2_in0 = map[1];
assign mul_11x11_2_in1 = map[7];
assign mul_11x11_2_out = mul_11x11_2_in0 * mul_11x11_2_in1;

// assign mul_11x11_3_in0 = map[3];
// assign mul_11x11_3_in1 = map[5];
// assign mul_11x11_3_out = mul_11x11_3_in0 * mul_11x11_3_in1;
//det_2x2 add
assign add_22x22_0_in0 = mul_11x11_0_out;
assign add_22x22_0_in1 = (mul_11x11_1_out);
// assign add_22x22_0_in1 = (mul_11x11_1_out);
assign add_22x22_0_out = add_22x22_0_in0 - add_22x22_0_in1;

assign add_22x22_1_in0 = mul_11x11_2_out;
// assign add_22x22_1_in1 = (~mul_11x11_3_out + 1'b1);
assign add_22x22_1_in1 = (mul_36x11_0_out[21:0]);
// assign add_22x22_1_in1 = (mul_11x11_3_out);
assign add_22x22_1_out = add_22x22_1_in0 - add_22x22_1_in1;


//det3x3 mul 
assign mul_23x11_0_in0 = map[7];
assign mul_23x11_0_out = mul_23x11_0_in0 * mul_23x11_0_in1;
assign mul_23x11_1_in0 = (cnt == 8) ? map[4] : map[7];
assign mul_23x11_1_out = mul_23x11_1_in0 * mul_23x11_1_in1;

//det4x4 mul
assign mul_36x11_0_in0 = ((mode==1) || (mode==2 && cnt<=8))? map[3] : map[7];
assign mul_36x11_0_out = mul_36x11_0_in0 * mul_36x11_0_in1;


always @(*) begin
    mul_23x11_0_in1 = 0;
    mul_23x11_1_in1 = 0;
    mul_36x11_0_in1 = 0;
    if(mode == 1) begin//3*3
        case(cnt)
            7,8:begin
                mul_36x11_0_in1 = map[5];
            end
            9 :begin
                mul_23x11_0_in1 = det_2x2[1];
            end
            10:begin
                mul_23x11_0_in1 = (~det_2x2[2] + 1);
                mul_23x11_1_in1 = det_2x2[3];
            end
            11:begin
                mul_23x11_0_in1 = det_2x2[0];
                mul_23x11_1_in1 = (~det_2x2[4] + 1);
                mul_36x11_0_in1 = map[5];
            end
            12:begin
                mul_23x11_1_in1 = det_2x2[1];
                mul_36x11_0_in1 = map[5];
            end
            13 :begin
                mul_23x11_0_in1 = det_2x2[0];

            end
            14:begin
                mul_23x11_0_in1 = (~det_2x2[2] + 1);
                mul_23x11_1_in1 = det_2x2[3];
            end
            15:begin
                mul_23x11_0_in1 = det_2x2[5];
                mul_23x11_1_in1 = (~det_2x2[4] + 1);
            end
            16:begin
                mul_23x11_1_in1 = det_2x2[0];
            end
            default: begin
                mul_23x11_0_in1 = 0;
                mul_23x11_1_in1 = 0;
                mul_36x11_0_in1 = 0;
            end
        endcase
    end
    else begin
        case(cnt)
            7: begin
                mul_36x11_0_in1 = map[5];
            end
            8: begin//share
                mul_23x11_0_in1 = map[0];
                mul_23x11_1_in1 = map[3];
                mul_36x11_0_in1 = map[5];
            end
            9 :begin
                mul_23x11_0_in1 = det_2x2[3];
                mul_23x11_1_in1 = det_2x2[4];
                mul_36x11_0_in1 = det_2x2[1];
            end
            10:begin
                mul_23x11_0_in1 = (~det_2x2[5] + 1);
                mul_23x11_1_in1 = det_2x2[3];
                mul_36x11_0_in1 = (~det_2x2[2] + 1);
            end
            11:begin
                mul_23x11_0_in1 = det_2x2[0];
                mul_23x11_1_in1 = (~det_2x2[4] + 1);
                mul_36x11_0_in1 = (~det_2x2[5] + 1);
            end
            12:begin//////////////////////////////////////////////!!!!!!!!!!!!!!!
                mul_23x11_0_in1 = det_2x2[2];
                mul_23x11_1_in1 = det_2x2[1];
                mul_36x11_0_in1 = det_2x2[0];
            end
            13:begin
                mul_36x11_0_in1 = (~det_4x4[35:0] + 1);
            end
            14:begin
                mul_36x11_0_in1 = det_3x3[0];
            end
            15:begin
                mul_36x11_0_in1 = (~det_3x3[1] + 1);
            end
            16:begin
                mul_36x11_0_in1 = det_3x3[2];
            end
            // 13:begin
            //     mul_36x11_0_in1 = (~det_3x3[0] + 1);
            // end
            // 14:begin
            //     mul_36x11_0_in1 = det_3x3[1];
            // end
            // 15:begin
            //     mul_36x11_0_in1 = (~det_3x3[2] + 1);
            // end
            // 16:begin
            //     mul_36x11_0_in1 = det_3x3[3];
            // end
            default: begin
                mul_23x11_0_in1 = 0;
                mul_23x11_1_in1 = 0;
                mul_36x11_0_in1 = 0;
            end
        endcase
    end
    
end
//det3x3 add
assign add_36x34_0_in1 = (cnt==8) ? (~mul_23x11_1_out + 1) : mul_23x11_0_out;//share
assign add_36x34_1_in1 = mul_23x11_1_out;
assign add_36x34_0_out = add_36x34_0_in0 + add_36x34_0_in1;
assign add_36x34_1_out = add_36x34_1_in0 + add_36x34_1_in1;

//det4x4 add
assign add_49x47_in1 = mul_36x11_0_out;
assign add_49x47_out = add_49x47_in0 + add_49x47_in1;

always @(*) begin
    add_36x34_0_in0 = 0;
    add_36x34_1_in0 = 0;
    add_49x47_in0   = 0;
    if(mode == 1) begin
        case(cnt)
            // 9 :begin
            //     // add_36x34_0_in0 = out_reg[188:153];
            //     add_36x34_0_in0 = 0;
            // end
            // 10:begin
            //     add_36x34_0_in0 = out_reg[188:153];
            //     add_36x34_1_in0 = out_reg[137:102];
            //     // add_36x34_1_in0 = 0;
            // end
            // 11:begin
            //     add_36x34_0_in0 = out_reg[188:153];
            //     add_36x34_1_in0 = out_reg[137:102];
            // end
            // 12:begin
            //     add_36x34_1_in0 = out_reg[137:102];
            // end
            // 13 :begin
            //     // add_36x34_0_in0 = out_reg[86:51];
            //     add_36x34_0_in0 = 0;
            // end
            // 14:begin
            //     add_36x34_0_in0 = out_reg[86:51];
            //     // add_36x34_1_in0 = out_reg[35:0];
            //     add_36x34_1_in0 = 0;
            // end
            // 15:begin
            //     add_36x34_0_in0 = out_reg[86:51];
            //     add_36x34_1_in0 = out_reg[35:0];
            // end
            // 16:begin
            //     add_36x34_1_in0 = out_reg[35:0];
            // end
            9 :begin
                add_36x34_0_in0 = 0;
            end
            10:begin
                add_36x34_0_in0 = det_3x3[0];
                add_36x34_1_in0 = 0;
            end
            11:begin
                add_36x34_0_in0 = det_3x3[0];
                add_36x34_1_in0 = det_3x3[1];
            end
            12:begin
                add_36x34_1_in0 = det_3x3[1];
            end
            13 :begin
                add_36x34_0_in0 = 0;

            end
            14:begin
                add_36x34_0_in0 = det_3x3[2];
                add_36x34_1_in0 = 0;
            end
            15:begin
                add_36x34_0_in0 = det_3x3[2];
                add_36x34_1_in0 = det_4x4[35:0];
            end
            16:begin
                add_36x34_1_in0 = det_4x4[35:0];
            end
            default: begin
                add_36x34_0_in0 = 0;
                add_36x34_1_in0 = 0;
                add_49x47_in0   = 0;
            end
        endcase
    end
    else begin
        case(cnt)
            // 8: begin//share
            //     add_36x34_0_in0 = mul_23x11_0_out;
            // end
            // 9 :begin
            //     add_36x34_0_in0 = 0;
            //     add_36x34_1_in0 = 0;
            //     add_49x47_in0   = 0;
            // end
            // 10:begin
            //     add_36x34_0_in0 = out_reg[86:51]  ;
            //     add_36x34_1_in0 = out_reg[188:153];
            //     add_49x47_in0   = out_reg[35:0]   ;
            // end
            // 11:begin
            //     add_36x34_0_in0 = out_reg[35:0]   ;
            //     add_36x34_1_in0 = out_reg[188:153];
            //     add_49x47_in0   = out_reg[137:102];
            // end
            // 12:begin
            //     add_36x34_0_in0 = out_reg[188:153];
            //     add_36x34_1_in0 = out_reg[137:102];
            //     add_49x47_in0   = out_reg[86:51]  ;
            // end
            // 13: begin
            //     add_49x47_in0 = 0;
            // end
            // 14,15,16: begin
            //     add_49x47_in0 = out_reg[206:158];
            // end
            

            8: begin//share
                add_36x34_0_in0 = mul_23x11_0_out;
            end
            9 :begin
                add_36x34_0_in0 = 0;
                add_36x34_1_in0 = 0;
                add_49x47_in0   = 0;
            end
            10:begin
                add_36x34_0_in0 = det_3x3[1];
                add_36x34_1_in0 = 0;//////////////////////////
                add_49x47_in0   = det_3x3[2];
            end
            11:begin
                add_36x34_0_in0 = det_3x3[2];
                add_36x34_1_in0 = det_4x4[35:0];
                add_49x47_in0 = det_3x3[0];
            end
            12:begin
                add_36x34_1_in0 = det_4x4[35:0];
                add_36x34_0_in0 = det_3x3[0];
                add_49x47_in0 = det_3x3[1];
            end
            13: begin
                add_49x47_in0 = 0;
            end
            14,15,16: begin
                add_49x47_in0 = det_4x4;
            end
            default: begin
                add_36x34_0_in0 = 0;
                add_36x34_1_in0 = 0;
                add_49x47_in0   = 0;
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i< 6; i = i+1) begin
            det_2x2[i] <= 0;
        end
    end
    else begin
        case(mode)
            0: begin
                case(cnt)
                    6 : det_2x2[0] <= add_22x22_0_out;
                    7 : det_2x2[1] <= add_22x22_0_out;
                    8 : det_2x2[2] <= add_22x22_0_out;
                    10: det_2x2[3] <= add_22x22_0_out;
                    11: det_2x2[4] <= add_22x22_0_out;
                    12: det_2x2[5] <= add_22x22_0_out;
                    // 14: det_3x3[0][22:0] <= add_22x22_0_out;
                    // 15: det_3x3[1][22:0] <= add_22x22_0_out;
                    // 16: det_3x3[2][22:0] <= add_22x22_0_out;
                endcase
            end
            1: begin
                case(cnt)
                    6: begin 
                        det_2x2[0] <= add_22x22_0_out;
                    end
                    7: begin
                        det_2x2[1] <= add_22x22_0_out;
                        det_2x2[2] <= add_22x22_1_out;
                    end
                    8: begin
                        det_2x2[3] <= add_22x22_0_out;
                        det_2x2[4] <= add_22x22_1_out;
                    end
                    10:begin
                        det_2x2[5] <= add_22x22_0_out;
                    end
                    11:begin
                        det_2x2[0] <= add_22x22_0_out;
                        det_2x2[2] <= add_22x22_1_out;
                    end
                    12:begin
                        det_2x2[3] <= add_22x22_0_out;
                        det_2x2[4] <= add_22x22_1_out;
                    end
                endcase
            end
            2: begin
                case(cnt)
                    6: begin 
                        det_2x2[0] <= add_22x22_0_out;
                    end
                    7: begin
                        det_2x2[1] <= add_22x22_0_out;
                        det_2x2[2] <= add_22x22_1_out;
                    end
                    8: begin
                        det_2x2[3] <= add_22x22_0_out;
                        det_2x2[4] <= add_22x22_1_out;
                        det_2x2[5] <= add_36x34_0_out;/////////////////////
                    end
                endcase
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i< 4; i = i+1) begin
            det_3x3[i] <= 0;
        end
    end
    else if(cnt == 17) begin
        for(i=0; i< 4; i = i+1) begin
            det_3x3[i] <= 0;
        end
    end
    else begin
        case(mode)
            0: begin
                case(cnt)
                    14: det_3x3[0][22:0] <= add_22x22_0_out;
                    15: det_3x3[1][22:0] <= add_22x22_0_out;
                    16: det_3x3[2][22:0] <= add_22x22_0_out;
                endcase
            end
            1: begin
                case(cnt)
                    9:begin
                        det_3x3[0] <= add_36x34_0_out;
                    end
                    10:begin
                        det_3x3[0] <= add_36x34_0_out;
                        det_3x3[1] <= add_36x34_1_out;
                    end
                    11:begin
                        det_3x3[0] <= add_36x34_0_out;
                        det_3x3[1] <= add_36x34_1_out;
                    end
                    12:begin
                        det_3x3[1] <= add_36x34_1_out;
                    end
                    13:begin
                        det_3x3[2] <= add_36x34_0_out;
                    end
                    14:begin
                        det_3x3[2] <= add_36x34_0_out;
                        // det_3x3[3] <= add_36x34_1_out;
                    end
                    15:begin
                        det_3x3[2] <= add_36x34_0_out;
                        // det_3x3[3] <= add_36x34_1_out;
                    end
                    // 16:begin
                    //     det_3x3[3] <= add_36x34_1_out;
                    // end
                endcase
            end
            2: begin
                case(cnt)
                    9 :begin
                        det_3x3[0] <= add_36x34_0_out;
                        det_3x3[1] <= add_36x34_1_out;
                        det_3x3[2] <= add_49x47_out   ;
                    end
                    10:begin
                        det_3x3[1] <= add_36x34_0_out;
                        // det_3x3[0] <= add_36x34_1_out;
                        det_3x3[2] <= add_49x47_out   ;
                    end
                    11:begin
                        det_3x3[2] <= add_36x34_0_out;
                        // det_3x3[0] <= add_36x34_1_out;
                        det_3x3[0] <= add_49x47_out   ;
                    end
                    12:begin
                        // det_3x3[0] <= add_36x34_0_out;
                        det_3x3[0] <= add_36x34_0_out;
                        det_3x3[1] <= add_49x47_out   ;
                    end
                endcase
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        det_4x4 <= 0;
    end
    else begin
        // if(mode == 1) begin
        //     case(cnt) 
        //         14,15,16: begin
        //             det_4x4[35:0] <= add_36x34_1_out;
        //         end
        //     endcase
        // end
        // else begin
        //     case(cnt) 
        //         10,11: begin
        //             det_4x4[35:0] <= add_36x34_1_out;
        //         end
        //         12: begin
        //             det_4x4 <= add_36x34_1_out;
        //         end
        //         13,14,15,16:begin
        //             det_4x4 <= add_49x47_out;
        //         end
        //     endcase
        // end
        if(mode == 2 && (cnt >=13)) det_4x4 <= add_49x47_out;
        else det_4x4 <= add_36x34_1_out;
    end
end



// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_reg <= 0;
//     end
//     else if(cnt == 0) begin
//         out_reg <= 0;
//     end
//     else begin
//         case(mode)
//             0: begin
//                 case(cnt)
//                     6,7,8,10,11,12,14,15,16: begin
//                         out_reg[22:0] <= add_22x22_0_out;
//                         out_reg[206:23] <= out_reg[183:0];
//                     end
//                 endcase
//             end
//             1: begin
//                 case(cnt)
//                     9: begin
//                         out_reg[203:153] <= {{15{add_36x34_0_out[35]}},add_36x34_0_out[35:0]};
//                     end
//                     10,11: begin
//                         out_reg[203:153] <= {{15{add_36x34_0_out[35]}},add_36x34_0_out[35:0]};
//                         out_reg[152:102] <= {{15{add_36x34_1_out[35]}},add_36x34_1_out[35:0]};
//                     end
//                     12: begin
//                         out_reg[152:102] <= {{15{add_36x34_1_out[35]}},add_36x34_1_out[35:0]};
//                     end
//                     13: begin
//                         out_reg[101:51] <= {{15{add_36x34_0_out[35]}},add_36x34_0_out[35:0]};
//                     end
//                     14,15: begin
//                         out_reg[101:51] <= {{15{add_36x34_0_out[35]}},add_36x34_0_out[35:0]};
//                         out_reg[50:0] <= {{15{add_36x34_1_out[35]}},add_36x34_1_out[35:0]};
//                     end
//                     16: begin
//                         out_reg[50:0] <= {{15{add_36x34_1_out[35]}},add_36x34_1_out[35:0]};
//                     end

//                     // 11,15: begin
//                     //     out_reg[50:0] <= {{15{add_36x34_0_out[35]}},add_36x34_0_out[35:0]};
//                     //     out_reg[206:51] <= out_reg[155:0];
//                     // end
//                     // 12,16: begin
//                     //     // out_reg[34:0] <= add_36x34_0_out;
//                     //     // out_reg[50:35] <= add_36x34_0_out[34];
//                     //     out_reg[50:0] <= {{15{add_36x34_1_out[35]}},add_36x34_1_out[35:0]};
//                     //     out_reg[206:51] <= out_reg[155:0];
//                     // end
//                 endcase
//             end
//             2: begin
//                 case(cnt)
//                     9 :begin
//                         out_reg[137:102] <= add_36x34_0_out;//1
//                         out_reg[86:51]   <= add_36x34_1_out;//2
//                         out_reg[35:0]    <= add_49x47_out  ;//3
//                     end
//                     10:begin
//                         out_reg[86:51]   <= add_36x34_0_out;//2
//                         out_reg[188:153] <= add_36x34_1_out;//0
//                         out_reg[35:0]    <= add_49x47_out  ;//3
//                     end
//                     11:begin
//                         out_reg[35:0]    <= add_36x34_0_out;//3
//                         out_reg[188:153] <= add_36x34_1_out;//0
//                         out_reg[137:102] <= add_49x47_out  ;//1
//                     end
//                     12:begin
//                         out_reg[188:153] <= add_36x34_0_out;//0
//                         out_reg[137:102] <= add_36x34_1_out;//1
//                         out_reg[86:51]   <= add_49x47_out  ;//2`
//                     end
//                     13,14,15: begin
//                         out_reg[206:158] <= add_49x47_out[48:0];
//                     end
//                     16: begin
//                         out_reg[48:0] <= add_49x47_out[48:0];
//                         out_reg[206:49] <= {158{add_49x47_out[48]}};
//                     end
//                     // 13,14,15,16: begin
//                     //     out_reg[48:0] <= add_49x47_out[48:0];
//                     //     out_reg[206:49] <= {158{add_49x47_out[48]}};
//                     // end
//                 endcase
//             end
//         endcase
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else begin
        // if(in_valid) cnt <= cnt + 1;
        // else cnt <= 0;
        if(cnt==0 && in_valid) cnt <= cnt + 1;
        else if(cnt > 0) begin
            if(cnt == 17) cnt <= 0;
            else cnt <= cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mode <= 0;
    end
    else begin
        if(in_valid && cnt == 0) begin
            case(decode_mode)
                5'b10110: mode <= 2'd2;
                5'b00110: mode <= 2'd1;
                5'b00100: mode <= 2'd0;
                default: mode <= 2'd0;
            endcase
        end  
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<8; i = i+1) begin
            map[i] <= 0;
        end
    end    
    else if(cnt == 17) begin
        for(i=0; i<8; i = i+1) begin
            map[i] <= 0;
        end
    end
    else begin
        if(in_valid) begin
            map[7] <= decode_data;
            for(i=0; i<7; i = i+1) begin
                map[i] <= map[i+1];
            end
        end
    end
end

always @(*) begin
    if(cnt == 17) begin
        out_data = 0;
        case(mode)
            0: begin
                out_data = {det_2x2[0], det_2x2[1], det_2x2[2], det_2x2[3], det_2x2[4], det_2x2[5], det_3x3[0][22:0], det_3x3[1][22:0], det_3x3[2][22:0]};
            end
            1:begin
                out_data = {3'b000, {{15{det_3x3[0][35]}}, det_3x3[0]}, {{15{det_3x3[1][35]}}, det_3x3[1]}, {{15{det_3x3[2][35]}}, det_3x3[2]}, {{15{det_4x4[35]}}, det_4x4[35:0]}};
            end
            2: begin
                out_data = {{158{det_4x4[48]}}, det_4x4};
            end
        endcase

    end
    else begin
        out_data = 0;

    end
end

always @(*) begin
    if(cnt == 17) begin
        out_valid = 1;
    end
    else begin
        out_valid = 0;
    end
end

endmodule