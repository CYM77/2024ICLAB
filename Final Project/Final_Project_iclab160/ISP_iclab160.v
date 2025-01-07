module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input [1:0]      in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output out_valid,
    output [7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output [3:0]  awid_s_inf,
    output [31:0] awaddr_s_inf,
    output [2:0]  awsize_s_inf,
    output [1:0]  awburst_s_inf,
    output [7:0]  awlen_s_inf,
    output        awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output [127:0] wdata_s_inf,
    output         wlast_s_inf,
    output         wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output         bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output [3:0]   arid_s_inf,
    output [31:0]  araddr_s_inf,
    output [7:0]   arlen_s_inf,
    output [2:0]   arsize_s_inf,
    output [1:0]   arburst_s_inf,
    output         arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output         rready_s_inf
    
);

parameter DRAM_R_IDLE = 0;
parameter DRAM_R_ADDR = 1;
parameter DRAM_R_DATA = 2;

parameter DRAM_W_IDLE = 0;
parameter DRAM_W_ADDR = 1;
parameter DRAM_W_DATA = 2;
parameter DRAM_W_RESP = 3;

parameter IDLE = 0;
parameter WAIT = 1;
// parameter FOCUS = 2;
// parameter EXPOSURE = 3;
parameter CAL = 2;
parameter OUT = 3;
parameter ZERO_OUT = 4;

integer i,j,k;
genvar a,b;
////////////////////////////////////////
assign awid_s_inf = 4'd0;
assign awsize_s_inf = 3'b100;
assign awburst_s_inf = 2'b01;
assign awlen_s_inf = 8'd191;


assign arid_s_inf = 4'd0;
assign arlen_s_inf = 8'd191;
assign arsize_s_inf = 3'b100;
assign arburst_s_inf = 2'b01;

reg [1:0] dram_r_state;
reg [1:0] dram_w_state;
reg [3:0] state, n_state;


reg arvalid_s_inf_reg;
reg [31:0] araddr_s_inf_reg;
reg rready_s_inf_reg;

assign araddr_s_inf = araddr_s_inf_reg;
assign arvalid_s_inf = arvalid_s_inf_reg;
assign rready_s_inf = rready_s_inf_reg;

reg awvalid_s_inf_reg;
reg [31:0] awaddr_s_inf_reg;
reg wvalid_s_inf_reg;
reg [127:0] wdata_s_inf_reg;
reg wlast_s_inf_reg;
reg bready_s_inf_reg;

assign awaddr_s_inf = awaddr_s_inf_reg;
assign awvalid_s_inf = awvalid_s_inf_reg;
assign wvalid_s_inf = wvalid_s_inf_reg;
assign wdata_s_inf = wdata_s_inf_reg;
assign wlast_s_inf = wlast_s_inf_reg;
assign bready_s_inf = bready_s_inf_reg;



reg [3:0] in_pic_no_reg;
reg [1:0] in_mode_reg;
reg [1:0] in_ratio_mode_reg;

reg [127:0] rdata_s_inf_reg;
reg rvalid_s_inf_reg;
reg rlast_s_inf_reg;

reg [5:0] pixel_cnt;
reg [1:0] rgb_cnt;
reg [3:0] over_cnt;
reg [2:0] wdata_delay_cnt;

reg [15:0] img_get_flag;
reg [15:0] exposure_flag;

reg [7:0] focus_buffer [0:5][0:5];

reg [1:0] focus_result [0:15];
reg [7:0] exposure_result [0:15];
reg [15:0] zero_flag;

reg [7:0] sub_abs_in0 [0:4];
reg [7:0] sub_abs_in1 [0:4];
reg [7:0] sub_abs_out [0:4];

reg [7:0] ratio_data [0:15];
reg [7:0] ratio_data_reg1 [0:15];
reg [7:0] ratio_data_reg2 [0:15];
reg [7:0] ratio_data_reg3 [0:15];
reg rvalid_s_inf_reg1;
reg rvalid_s_inf_reg2;
reg rvalid_s_inf_reg3;

reg [7:0] max_temp, min_temp;
reg [9:0] max_rgb_sum, min_rgb_sum;
reg [7:0] amm_result [0:15];
wire [7:0] cmp_max, cmp_min;

wire [7:0] min_in0;
wire [7:0] min_in1;
wire [7:0] max_in0;
wire [7:0] max_in1;

assign min_in0 = cmp_min;
assign min_in1 = (pixel_cnt == 4) ? 255 : min_temp;
assign max_in0 = cmp_max;
assign max_in1 = (pixel_cnt == 4) ? 0 : max_temp;

wire [7:0] cmp_min_out = (min_in0 < min_in1) ? min_in0 : min_in1;
wire [7:0] cmp_max_out = (max_in0 > max_in1) ? max_in0 : max_in1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_temp <= 0;
        min_temp <= 255;
    end
    else begin
            max_temp <= cmp_max_out;
            min_temp <= cmp_min_out;
    end
end


Max_Min MM(.clk(clk), .in0(ratio_data[0]), .in1(ratio_data[1 ]), .in2(ratio_data[2 ]), .in3(ratio_data[3 ]), .in4(ratio_data[4 ]), .in5(ratio_data[5 ]), .in6(ratio_data[6 ]), .in7(ratio_data[7 ]), .in8(ratio_data[8 ]), .in9(ratio_data[9 ]), .in10(ratio_data[10 ]), .in11(ratio_data[11 ]), .in12(ratio_data[12 ]), .in13(ratio_data[13 ]), .in14(ratio_data[14 ]), .in15(ratio_data[15 ]), .max(cmp_max), .min(cmp_min));


always @(posedge clk) begin
    if((rgb_cnt != 0 && pixel_cnt == 4) || over_cnt == 5) begin
        max_rgb_sum <= max_rgb_sum + max_temp;
        min_rgb_sum <= min_rgb_sum + min_temp;
    end
    else if(state == IDLE) begin
        max_rgb_sum <= 0;
        min_rgb_sum <= 0;
    end 
end

reg [7:0] div_max, div_min;
always @(posedge clk) begin
    div_max <= max_rgb_sum / 3;
    div_min <= min_rgb_sum / 3;
end

reg [8:0] amm_out;
always @(posedge clk) begin
    amm_out <= (div_max + div_min);
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<16; i=i+1) begin
            amm_result[i] <= 0;
        end
    end
    else begin
        if(over_cnt == 8) begin
            amm_result[in_pic_no_reg] <= amm_out >> 1;
        end
    end
end





always @(posedge clk) begin
    for(i=0; i<16; i=i+1) begin
        ratio_data_reg1[i] <= ratio_data[i];
        ratio_data_reg2[i] <= ratio_data_reg1[i];
        ratio_data_reg3[i] <= ratio_data_reg2[i];
    end
end

always @(posedge clk) begin
    rvalid_s_inf_reg1 <= rvalid_s_inf_reg;
    rvalid_s_inf_reg2 <= rvalid_s_inf_reg1;
    rvalid_s_inf_reg3 <= rvalid_s_inf_reg2;
end

generate
    for(a=0; a<16; a=a+1) begin
        always @(*) begin
            case(in_ratio_mode_reg)
                0: ratio_data[a] = rdata_s_inf_reg[8*a +: 8] >> 2;
                1: ratio_data[a] = rdata_s_inf_reg[8*a +: 8] >> 1;
                2: ratio_data[a] = rdata_s_inf_reg[8*a +: 8];
                3: ratio_data[a] = (rdata_s_inf_reg[8*a + 7] == 1) ? 8'hFF : (rdata_s_inf_reg[8*a +: 8] << 1);
            endcase
        end
    end
endgenerate

reg [7:0] exposure_in[0:15];
generate
    for(a=0; a<16; a=a+1) begin
        always @(*) begin
            case(rgb_cnt)
                0: exposure_in[a] = ratio_data[a] >> 2;
                1: exposure_in[a] = ratio_data[a] >> 1;
                2: exposure_in[a] = ratio_data[a] >> 2;
                default: exposure_in[a] = 0;
            endcase
        end
    end
endgenerate

wire [7:0] add_exposure_stage1_out [0:7];
wire [8:0] add_exposure_stage2_out [0:3];
wire [9:0] add_exposure_stage3_out [0:1];
wire [10:0] add_exposure_stage4_out;
reg [18:0] exposure_temp;

reg [7:0] add_exposure_stage1_out_reg [0:7];
reg [8:0] add_exposure_stage2_out_reg [0:3];
reg [9:0] add_exposure_stage3_out_reg [0:1];

reg [10:0] add_exposure_stage4_out_reg;
generate
    for(a=0; a<8; a=a+1) begin
        assign add_exposure_stage1_out[a] = exposure_in[2*a] + exposure_in[2*a + 1];
    end
endgenerate

generate
    for(a=0; a<4; a=a+1) begin
        assign add_exposure_stage2_out[a] = add_exposure_stage1_out_reg[2*a] + add_exposure_stage1_out_reg[2*a + 1];
    end
endgenerate

always @(posedge clk ) begin
    for(i=0; i<8; i=i+1) begin
        add_exposure_stage1_out_reg[i] <= add_exposure_stage1_out[i];
    end
    for(i=0; i<4; i=i+1) begin
        add_exposure_stage2_out_reg[i] <= add_exposure_stage2_out[i];
    end
    for(i=0; i<2; i=i+1) begin
        add_exposure_stage3_out_reg[i] <= add_exposure_stage3_out[i];
    end
    add_exposure_stage4_out_reg <= add_exposure_stage4_out;
end

generate
    for(a=0; a<2; a=a+1) begin
        assign add_exposure_stage3_out[a] = add_exposure_stage2_out_reg[2*a] + add_exposure_stage2_out_reg[2*a + 1];
    end
endgenerate

assign add_exposure_stage4_out = add_exposure_stage3_out_reg[0] + add_exposure_stage3_out_reg[1];


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exposure_temp <= 0;
    end
    else begin
        if(state == IDLE) begin
            exposure_temp <= 0;
        end
        else begin
            exposure_temp <= add_exposure_stage4_out_reg + exposure_temp;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<16; i=i+1) begin
            exposure_result[i] <= 0;
        end
    end
    else begin
        if(over_cnt == 5)begin
            exposure_result[in_pic_no_reg] <= exposure_temp[17:10];
        end
    end
end

wire [127:0] concate_ratio_data;
generate
    for(a=0; a<16; a=a+1) begin
        assign concate_ratio_data[8*a +: 8] = ratio_data_reg3[a];
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        zero_flag <= 0;
    end
    else begin
        case(state)
            CAL: begin
                if(rvalid_s_inf_reg == 1 && in_mode_reg == 1) begin
                    if((concate_ratio_data) != 0 && zero_flag[in_pic_no_reg] == 0) begin
                        zero_flag[in_pic_no_reg] <= 1;
                    end
                end
                else if(over_cnt == 9 && in_mode_reg == 1) zero_flag[in_pic_no_reg] <= ~zero_flag[in_pic_no_reg];///////////////////!!!!!!!!!
            end
            // OUT: begin
            //     if(in_mode_reg == 1) begin
            //         zero_flag[in_pic_no_reg] <= ~zero_flag[in_pic_no_reg];
            //     end
            // end
        endcase
    end
end


// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         state <= IDLE;
//     end
//     else begin
//         case(state)
//             IDLE:begin
//                 if(in_valid) begin
//                     state <= WAIT;
//                 end
//             end
//             WAIT: begin
//                 if(zero_flag[in_pic_no_reg] == 1) begin
//                     state <= ZERO_OUT;
//                 end
//                 else if(img_get_flag[in_pic_no_reg] == 0 || ((in_mode_reg == 1) && (in_ratio_mode_reg != 2))) begin
//                     state <= CAL;
//                 end
//                 else begin
//                     state <= OUT;
//                 end
//             end
//             CAL: begin
//                 if(over_cnt == 6) begin
//                     state <= OUT;
//                 end
//             end
//             OUT, ZERO_OUT:begin
//                 state <= IDLE;
//             end
//         endcase
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= n_state;
    end
end

always @(*) begin
    case(state)
        IDLE:begin
            if(in_valid) begin
                n_state = WAIT;
            end
            else begin
                n_state = state;
            end
        end
        WAIT: begin
            if(zero_flag[in_pic_no_reg] == 1) begin
                n_state = ZERO_OUT;
            end
            else if(img_get_flag[in_pic_no_reg] == 0 || ((in_mode_reg == 1) && (in_ratio_mode_reg != 2))) begin
                n_state = CAL;
            end
            else begin
                n_state = OUT;
            end
        end
        CAL: begin
            if(over_cnt == 9) begin
                n_state = OUT;
            end
            else begin
                n_state = state;
            end
        end
        OUT, ZERO_OUT:begin
            n_state = IDLE;
        end
        default: n_state = state;
    endcase
end



wire [1:0] shamt = (rgb_cnt == 0 ||rgb_cnt == 2) ? 2 : 1;
wire [7:0] dram_data [0:15];
generate
    for(a=0; a<16; a=a+1) begin
        assign dram_data[a] = rdata_s_inf_reg[a*8 +: 8];
    end
endgenerate

//focus_buffer
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<6; i=i+1) begin
            for(j=0; j<6; j=j+1) begin
                focus_buffer[i][j] <= 0;
            end
        end
    end
    else begin
        if(state == CAL) begin
            case(pixel_cnt)
                26,28,30,32,34,36: begin
                    focus_buffer[5][2] <= focus_buffer[0][2] + (ratio_data[15] >> shamt);
                    focus_buffer[5][1] <= focus_buffer[0][1] + (ratio_data[14] >> shamt);
                    focus_buffer[5][0] <= focus_buffer[0][0] + (ratio_data[13] >> shamt);
                    for(i=0; i<5; i=i+1) begin
                        focus_buffer[i][0] <= focus_buffer[i+1][0];
                        focus_buffer[i][1] <= focus_buffer[i+1][1];
                        focus_buffer[i][2] <= focus_buffer[i+1][2];
                    end
                end
                27,29,31,33,35,37: begin
                    focus_buffer[5][5] <= focus_buffer[0][5] +  (ratio_data[2] >> shamt);
                    focus_buffer[5][4] <= focus_buffer[0][4] +  (ratio_data[1]>> shamt );
                    focus_buffer[5][3] <= focus_buffer[0][3] +  (ratio_data[0] >> shamt  );
                    for(i=0; i<5; i=i+1) begin
                        focus_buffer[i][3] <= focus_buffer[i+1][3];
                        focus_buffer[i][4] <= focus_buffer[i+1][4];
                        focus_buffer[i][5] <= focus_buffer[i+1][5];
                    end
                end
                38,39,40,41,42,43:begin
                    focus_buffer[5][0] <= focus_buffer[0][0];
                    focus_buffer[5][1] <= focus_buffer[0][1];
                    focus_buffer[5][2] <= focus_buffer[0][2];
                    focus_buffer[5][3] <= focus_buffer[0][3];
                    focus_buffer[5][4] <= focus_buffer[0][4];
                    focus_buffer[5][5] <= focus_buffer[0][5];
                    for(i=0; i<5; i=i+1) begin
                        focus_buffer[i][0] <= focus_buffer[i+1][0];
                        focus_buffer[i][1] <= focus_buffer[i+1][1];
                        focus_buffer[i][2] <= focus_buffer[i+1][2];
                        focus_buffer[i][3] <= focus_buffer[i+1][3];
                        focus_buffer[i][4] <= focus_buffer[i+1][4];
                        focus_buffer[i][5] <= focus_buffer[i+1][5];
                    end
                end
                44,45,46,47,48,49: begin
                    focus_buffer[0][5] <= focus_buffer[0][0];
                    focus_buffer[1][5] <= focus_buffer[1][0];
                    focus_buffer[2][5] <= focus_buffer[2][0];
                    focus_buffer[3][5] <= focus_buffer[3][0];
                    focus_buffer[4][5] <= focus_buffer[4][0];
                    focus_buffer[5][5] <= focus_buffer[5][0];
                    for(i=0; i<5; i=i+1) begin
                        focus_buffer[0][i] <= focus_buffer[0][i+1];
                        focus_buffer[1][i] <= focus_buffer[1][i+1];
                        focus_buffer[2][i] <= focus_buffer[2][i+1];
                        focus_buffer[3][i] <= focus_buffer[3][i+1];
                        focus_buffer[4][i] <= focus_buffer[4][i+1];
                        focus_buffer[5][i] <= focus_buffer[5][i+1];
                    end
                end
            endcase            
        end
        else begin
            for(i=0; i<6; i=i+1) begin
                for(j=0; j<6; j=j+1) begin
                    focus_buffer[i][j] <= 0;
                end
            end
        end
    end
end

generate
    for(a=0;a<5; a=a+1) begin
        always @(*) begin
            if(rgb_cnt == 2) begin
                if(pixel_cnt < 44) begin
                    sub_abs_in0[a] = focus_buffer[0][a];
                    sub_abs_in1[a] = focus_buffer[0][a+1];
                end
                else begin
                    sub_abs_in0[a] = focus_buffer[a][0];
                    sub_abs_in1[a] = focus_buffer[a+1][0];
                end
            end
            else begin
                sub_abs_in0[a] = 0;
                sub_abs_in1[a] = 0;
            end
        end
    end
endgenerate

generate
    for(a=0; a<5; a=a+1) begin:sub_abs
        SUB_w_ABS YM(.clk(clk), .in0(sub_abs_in0[a]), .in1(sub_abs_in1[a]), .out(sub_abs_out[a]));
    end    
endgenerate

wire [7:0] partial_sum_2x2;
wire [9:0] partial_sum_4x4;
wire [10:0] partial_sum_6x6;
reg [13:0] sum_6x6;
reg [12:0]  sum_4x4;
reg [9:0]  sum_2x2;

assign partial_sum_2x2 = sub_abs_out[2];
assign partial_sum_4x4 = sub_abs_out[1] + sub_abs_out[2] + sub_abs_out[3];
// assign partial_sum_6x6 = partial_sum_4x4 + (sub_abs_out[0] + sub_abs_out[4]);


wire [8:0] partial_sum_sub_abs_0_4 = (sub_abs_out[0] + sub_abs_out[4]);
reg [8:0] partial_sum_sub_abs_0_4_reg;
reg [9:0] partial_sum_4x4_reg;
always @(posedge clk) begin
    partial_sum_sub_abs_0_4_reg <= partial_sum_sub_abs_0_4;
    partial_sum_4x4_reg <= partial_sum_4x4;
end

assign partial_sum_6x6 = partial_sum_4x4_reg + partial_sum_sub_abs_0_4_reg;

//SUM2X2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_2x2 <= 0;
    end
    else begin
        if(state == CAL) begin
            case(pixel_cnt)
                42,43,48,49: begin
                    sum_2x2 <= partial_sum_2x2 + sum_2x2;
                end 
            endcase
        end
        else begin
            sum_2x2 <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_4x4 <= 0;
    end
    else begin
        if(state == CAL) begin
            case(pixel_cnt)
                41,42,43,44,47,48,49,50: begin
                    sum_4x4 <= partial_sum_4x4 + sum_4x4;
                end 
            endcase
        end
        else begin
            sum_4x4 <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_6x6 <= 0;
    end
    else begin
        if(state == CAL) begin
            case(pixel_cnt)
                41,42,43,44,45,46,47,48,49,50,51,52: begin
                    sum_6x6 <= partial_sum_6x6 + sum_6x6;
                end 
            endcase 
        end
        else begin
            sum_6x6 <= 0;
        end
    end
end
wire [1:0] cmp_out;
wire[7:0] cmp_in0 =  sum_2x2 >> 2;
wire [8:0] cmp_in1 = sum_4x4 >> 4;
wire [8:0] cmp_in2 = (sum_6x6>>2) / 9; 

reg [7:0] cmp_in0_reg;
reg [8:0] cmp_in1_reg;
reg [8:0] cmp_in2_reg;

always @(posedge clk) begin
    cmp_in0_reg <= cmp_in0;
    cmp_in1_reg <= cmp_in1;
    cmp_in2_reg <= cmp_in2;
end

// wire [13:0] cmp_in2 = div_out;

CMP3 YM(.clk(clk), .in0(cmp_in0_reg), .in1(cmp_in1_reg), .in2(cmp_in2_reg), .out_index(cmp_out));

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<16; i=i+1) begin
            focus_result[i] <= 0;
        end
    end
    else begin
        if(pixel_cnt == 55) begin
            // focus_result[in_pic_no_reg] <= cmp_out;
            case(in_pic_no_reg)
                0: focus_result[0] <= cmp_out;
                1: focus_result[1] <= cmp_out;
                2: focus_result[2] <= cmp_out;
                3: focus_result[3] <= cmp_out;
                4: focus_result[4] <= cmp_out;
                5: focus_result[5] <= cmp_out;
                6: focus_result[6] <= cmp_out;
                7: focus_result[7] <= cmp_out;
                8: focus_result[8] <= cmp_out;
                9: focus_result[9] <= cmp_out;
                10: focus_result[10] <= cmp_out;
                11: focus_result[11] <= cmp_out;
                12: focus_result[12] <= cmp_out;
                13: focus_result[13] <= cmp_out;
                14: focus_result[14] <= cmp_out;
                15: focus_result[15] <= cmp_out;
            endcase
        end
    end
end




always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        exposure_flag <= 0;
    end
    else begin
        if(state == OUT) begin
            exposure_flag[in_pic_no_reg] <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_get_flag <= 0;
    end
    else begin
        if(state == OUT) begin
            img_get_flag[in_pic_no_reg] <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        over_cnt <= 0;
    end
    else begin
        if(state == IDLE) begin
            over_cnt <= 0;
        end
        else begin
            if(rlast_s_inf_reg == 1 || over_cnt != 0) begin
                over_cnt <= over_cnt + 1;
            end
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rgb_cnt <= 0;
    end
    else begin
        if(pixel_cnt == 63) begin
            if(rgb_cnt == 2) begin
                rgb_cnt <= 0;
            end
            else begin
                rgb_cnt <= rgb_cnt + 1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pixel_cnt <= 0;
    end
    else begin
        if(rvalid_s_inf_reg == 1'b1) begin
            pixel_cnt <= pixel_cnt + 1;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rdata_s_inf_reg <= 0;
        rvalid_s_inf_reg <= 0;
        rlast_s_inf_reg <= 0;
    end
    else begin
        rdata_s_inf_reg <= rdata_s_inf;
        rvalid_s_inf_reg <= rvalid_s_inf;
        rlast_s_inf_reg <= rlast_s_inf;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_pic_no_reg <= 0;
        in_mode_reg <= 0;
        in_ratio_mode_reg <= 0;
    end
    else begin
        if(in_valid) begin
            in_pic_no_reg <= in_pic_no;
            in_mode_reg <= in_mode;
            if(in_mode != 1) begin
                in_ratio_mode_reg <= 2;
            end
            else begin
                in_ratio_mode_reg <= in_ratio_mode;
            end
            
        end
    end
end

reg [7:0] out_temp;
assign out_valid = (state == OUT || state == ZERO_OUT) ? 1 : 0;
assign out_data = out_temp;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_temp <= 0;
    end
    else begin
        case(n_state)
            OUT: begin
                case(in_mode_reg)
                    0:out_temp <= focus_result[in_pic_no_reg];
                    1:begin
                        // if(in_ratio_mode_reg == 2) begin
                            out_temp <= exposure_result[in_pic_no_reg];
                        // end
                        // else begin
                        //     out_temp = exposure_temp[17:10];
                        // end
                    end
                    2:out_temp <= amm_result[in_pic_no_reg];
                    default: out_temp <= 0;
                endcase 
            end
            ZERO_OUT: begin
                $display("ZERO_OUT");
                out_temp <= 0;
            end
            default: out_temp <= 0;
        endcase
    end
end









always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dram_r_state <= 0;
    end 
    else begin
        case(dram_r_state)
            DRAM_R_IDLE: begin
                if(state == WAIT && (img_get_flag[in_pic_no_reg] == 0 || ((in_mode_reg == 1) && (in_ratio_mode_reg != 2))) && zero_flag[in_pic_no_reg] != 1) begin
                    dram_r_state <= DRAM_R_ADDR;
                end
            end
            DRAM_R_ADDR: begin
                if(arvalid_s_inf && arready_s_inf) begin
                    dram_r_state <= DRAM_R_DATA;
                end
            end
            DRAM_R_DATA: begin
                if(rvalid_s_inf && rlast_s_inf) begin
                    dram_r_state <= DRAM_R_IDLE;
                end
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arvalid_s_inf_reg <= 0;
    end
    else begin
        case(dram_r_state)
            DRAM_R_IDLE: begin
                if(state == WAIT && (img_get_flag[in_pic_no_reg] == 0 || ((in_mode_reg == 1) && (in_ratio_mode_reg != 2)))&& zero_flag[in_pic_no_reg] != 1) begin
                    arvalid_s_inf_reg <= 1;
                end
            end
            DRAM_R_ADDR: begin
                if(arready_s_inf == 1'b1) begin
                    arvalid_s_inf_reg <= 0;
                end
            end
        endcase
    end
end

wire [5:0] addr = (in_pic_no_reg << 1) + in_pic_no_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        araddr_s_inf_reg <= 32'h10000;
    end
    else begin
        case(dram_r_state)
            DRAM_R_IDLE: begin
                if(state == WAIT && (img_get_flag[in_pic_no_reg] == 0 || (in_mode_reg == 1 && in_ratio_mode_reg != 2))) begin
                    araddr_s_inf_reg <= {16'h0001, addr, 10'h000};
                end
            end
            // DRAM_R_ADDR: begin
            //         araddr_s_inf_reg <= {16'h0001, addr, 10'h000};
            // end
            // DRAM_R_DATA: begin
            //     if(arready_s_inf == 1'b1) begin
            //         araddr_s_inf <= 0;
            //     end
            // end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rready_s_inf_reg <= 0;
    end
    else begin
        case(dram_r_state)
            DRAM_R_ADDR: begin
                    if(arready_s_inf == 1'b1) begin
                        rready_s_inf_reg <= 1;
                    end
            end
            DRAM_R_DATA: begin
                if(rlast_s_inf_reg == 1'b1) begin
                    rready_s_inf_reg <= 0;
                end
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dram_w_state <= 0;
    end 
    else begin
        case(dram_w_state)
            DRAM_W_IDLE: begin
                if(state == WAIT && (in_mode_reg == 1 && in_ratio_mode_reg != 2)&& zero_flag[in_pic_no_reg] != 1) begin//////////////////////////////
                    dram_w_state <= DRAM_W_ADDR;
                end
            end
            DRAM_W_ADDR: begin
                if(awvalid_s_inf && awready_s_inf) begin
                    dram_w_state <= DRAM_W_DATA;
                end
            end
            DRAM_W_DATA: begin
                if(wdata_delay_cnt == 4) begin
                    dram_w_state <= DRAM_W_RESP;
                end
            end
            DRAM_W_RESP: begin
                if(bvalid_s_inf) begin
                    dram_w_state <= DRAM_W_IDLE;
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awvalid_s_inf_reg <= 0;
    end
    else begin
        case(dram_w_state)
            DRAM_W_IDLE: begin
                if(state == WAIT && (in_mode_reg == 1 && in_ratio_mode_reg != 2)&& zero_flag[in_pic_no_reg] != 1) begin
                    awvalid_s_inf_reg <= 1;
                end
            end
            DRAM_W_ADDR: begin
                if(awready_s_inf == 1'b1) begin
                    awvalid_s_inf_reg <= 0;
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awaddr_s_inf_reg <= 32'h10000;
    end
    else begin
        case(dram_w_state)
            DRAM_W_IDLE: begin
                if(state == WAIT && (in_mode_reg == 1 && in_ratio_mode_reg != 2)&& zero_flag[in_pic_no_reg] != 1) begin
                    awaddr_s_inf_reg <= {16'h0001, addr, 10'h000};
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wvalid_s_inf_reg <= 0;
    end
    else begin
        case(dram_w_state)
            DRAM_W_DATA: begin
                if(rvalid_s_inf_reg || rvalid_s_inf_reg3) begin
                    wvalid_s_inf_reg <= 1;
                end
                else begin
                    wvalid_s_inf_reg <= 0;
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wdata_s_inf_reg <= 0;
    end
    else begin
        case(dram_w_state)
            DRAM_W_DATA: begin
                if(rvalid_s_inf_reg3) begin
                    for(i=0; i<16; i=i+1) begin
                        wdata_s_inf_reg[8*i +: 8] <= ratio_data_reg3[i];
                    end
                end
                else begin
                    wdata_s_inf_reg <= 0;
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wlast_s_inf_reg <= 0;
    end
    else begin
        case(dram_w_state)
            DRAM_W_DATA: begin
                if(wdata_delay_cnt == 3) begin
                    wlast_s_inf_reg <= 1;
                end
                else begin
                    wlast_s_inf_reg <= 0;
                end
            end
            DRAM_W_RESP: begin
                wlast_s_inf_reg <= 0;
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wdata_delay_cnt <= 0;
    end
    else begin
        if(dram_w_state == DRAM_W_DATA) begin
            if((rgb_cnt == 2 && pixel_cnt == 63) || wdata_delay_cnt != 0) begin
                wdata_delay_cnt <= wdata_delay_cnt + 1;
            end
        end
        else begin
            wdata_delay_cnt <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bready_s_inf_reg <= 0;
    end
    else begin
        case(dram_w_state)
            DRAM_W_DATA: begin

                    bready_s_inf_reg <= 1;
            end
            DRAM_W_RESP: begin
                if(bvalid_s_inf == 1) begin
                    bready_s_inf_reg <= 0;
                end
            end
        endcase
    end
end




endmodule


module SUB_w_ABS(clk,in0,in1,out);
    input clk;
    input [7:0] in0,in1;
    output reg [7:0] out;
    // wire [7:0] temp = in0 - in1;
    // assign out = (temp[7] == 1'b1)? ~temp + 1 : temp;
    wire [7:0] big = (in0 > in1) ? in0 : in1;
    wire [7:0] little = (in0 > in1) ? in1 : in0;

    reg [7:0] big_reg;
    reg [7:0] little_reg;

    always @(posedge clk) begin
        big_reg <= big;
        little_reg <= little;
    end

    wire [7:0] out_temp = big_reg - little_reg;

    always @(posedge clk ) begin
        out <= out_temp;
    end

endmodule

module CMP3(clk,in0, in1,in2, out_index);
    input clk;
    input [7:0] in0;
    input [8:0] in1;
    input [8:0] in2;
    output [1:0] out_index;

    wire [8:0] temp = (in0 >= in1) ? in0 : in1;
    wire [8:0]  big = (temp >= in2) ? temp : in2;

    reg [7:0] in0_reg, in1_reg;
    reg [8:0] big_reg;

    always @(posedge clk) begin
        in0_reg <= in0;
        in1_reg <= in1;
        big_reg <= big;
    end

    assign out_index = (big_reg == in0_reg) ? 0 : (big_reg == in1_reg) ? 1 : 2;
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

module Max_Min (
    clk,
    in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,
    max,min
);
    input clk;
    input [7:0] in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15;  
    output reg [7:0] max,min;

    wire [7:0] cmp_stage1 [0:15];
    wire [7:0] cmp_stage2 [0:7];
    wire [7:0] cmp_stage3 [0:3];
    wire [7:0] max_temp, min_temp;

    reg [7:0] cmp_stage1_reg [0:15];
    reg [7:0] cmp_stage2_reg [0:7];
    reg [7:0] cmp_stage3_reg [0:3];

    genvar a;
    integer i;

    CMP2 C1(.in0(in0), .in1(in1), .min(cmp_stage1[0]), .max(cmp_stage1[1]));
    CMP2 C2(.in0(in2), .in1(in3), .min(cmp_stage1[2]), .max(cmp_stage1[3]));
    CMP2 C3(.in0(in4), .in1(in5), .min(cmp_stage1[4]), .max(cmp_stage1[5]));
    CMP2 C4(.in0(in6), .in1(in7), .min(cmp_stage1[6]), .max(cmp_stage1[7]));    
    CMP2 C5(.in0(in8), .in1(in9), .min(cmp_stage1[8]), .max(cmp_stage1[9]));
    CMP2 C6(.in0(in10), .in1(in11), .min(cmp_stage1[10]), .max(cmp_stage1[11]));
    CMP2 C7(.in0(in12), .in1(in13), .min(cmp_stage1[12]), .max(cmp_stage1[13]));
    CMP2 C8(.in0(in14), .in1(in15), .min(cmp_stage1[14]), .max(cmp_stage1[15]));

    always @(posedge clk ) begin
        for(i=0; i<16; i=i+1) begin
            cmp_stage1_reg[i] <= cmp_stage1[i];
        end
    end


    CMP2 C12(.in0(cmp_stage1_reg[0]),  .in1(cmp_stage1_reg[2]), .min(cmp_stage2[0]), .max());
    CMP2 C13(.in0(cmp_stage1_reg[1]),  .in1(cmp_stage1_reg[3]), .min(), .max(cmp_stage2[1]));
    CMP2 C14(.in0(cmp_stage1_reg[4]),  .in1(cmp_stage1_reg[6]), .min(cmp_stage2[2]), .max());
    CMP2 C15(.in0(cmp_stage1_reg[5]),  .in1(cmp_stage1_reg[7]), .min(), .max(cmp_stage2[3]));
    CMP2 C16(.in0(cmp_stage1_reg[8]),  .in1(cmp_stage1_reg[10]), .min(cmp_stage2[4]), .max());
    CMP2 C17(.in0(cmp_stage1_reg[9]),  .in1(cmp_stage1_reg[11]), .min(), .max(cmp_stage2[5]));
    CMP2 C18(.in0(cmp_stage1_reg[12]), .in1(cmp_stage1_reg[14]), .min(cmp_stage2[6]), .max());
    CMP2 C19(.in0(cmp_stage1_reg[13]), .in1(cmp_stage1_reg[15]), .min(), .max(cmp_stage2[7]));

    always @(posedge clk ) begin
        for(i=0; i<8; i=i+1) begin
            cmp_stage2_reg[i] <= cmp_stage2[i];
        end
    end

    CMP2 C110(.in0(cmp_stage2_reg[0]), .in1(cmp_stage2_reg[2]), .min(cmp_stage3[0]), .max());
    CMP2 C111(.in0(cmp_stage2_reg[1]), .in1(cmp_stage2_reg[3]), .min(), .max(cmp_stage3[1]));
    CMP2 C112(.in0(cmp_stage2_reg[4]), .in1(cmp_stage2_reg[6]), .min(cmp_stage3[2]), .max());
    CMP2 C113(.in0(cmp_stage2_reg[5]), .in1(cmp_stage2_reg[7]), .min(), .max(cmp_stage3[3]));

    always @(posedge clk ) begin
        for(i=0; i<4; i=i+1) begin
            cmp_stage3_reg[i] <= cmp_stage3[i];
        end
    end


    CMP2 C114(.in0(cmp_stage3_reg[0]), .in1(cmp_stage3_reg[2]), .min(min_temp), .max());
    CMP2 C115(.in0(cmp_stage3_reg[1]), .in1(cmp_stage3_reg[3]), .min(), .max(max_temp));

    always @(posedge clk ) begin
        max <= max_temp;
        min <= min_temp;
    end
endmodule




















// `define index0 10:0
// `define index1 21:11
// `define index2 32:22
// `define index3 43:33
// module ISP(
//     // Input Signals
//     input clk,
//     input rst_n,
//     input in_valid,
//     input [3:0] in_pic_no,
//     input [1:0]      in_mode,
//     input [1:0] in_ratio_mode,

//     // Output Signals
//     output out_valid,
//     output [7:0] out_data,
    
//     // DRAM Signals
//     // axi write address channel
//     // src master
//     output [3:0]  awid_s_inf,
//     output [31:0] awaddr_s_inf,
//     output [2:0]  awsize_s_inf,
//     output [1:0]  awburst_s_inf,
//     output [7:0]  awlen_s_inf,
//     output        awvalid_s_inf,
//     // src slave
//     input         awready_s_inf,
//     // -----------------------------
  
//     // axi write data channel 
//     // src master
//     output [127:0] wdata_s_inf,
//     output         wlast_s_inf,
//     output         wvalid_s_inf,
//     // src slave
//     input          wready_s_inf,
  
//     // axi write response channel 
//     // src slave
//     input [3:0]    bid_s_inf,
//     input [1:0]    bresp_s_inf,
//     input          bvalid_s_inf,
//     // src master 
//     output         bready_s_inf,
//     // -----------------------------
  
//     // axi read address channel 
//     // src master
//     output [3:0]   arid_s_inf,
//     output [31:0]  araddr_s_inf,
//     output [7:0]   arlen_s_inf,
//     output [2:0]   arsize_s_inf,
//     output [1:0]   arburst_s_inf,
//     output         arvalid_s_inf,
//     // src slave
//     input          arready_s_inf,
//     // -----------------------------
  
//     // axi read data channel 
//     // slave
//     input [3:0]    rid_s_inf,
//     input [127:0]  rdata_s_inf,
//     input [1:0]    rresp_s_inf,
//     input          rlast_s_inf,
//     input          rvalid_s_inf,
//     // master
//     output         rready_s_inf
    
// );

// localparam IDLE = 0;
// localparam DRAM_ADDR = 1;
// localparam WAIT_DRAM_DATA = 2;
// localparam FOCUS = 3;
// localparam EXPOSURE = 4;
// localparam Avg_Min_Max = 5;
// localparam READ_SRAM = 6;//wait read sram 2 cycle delay
// localparam WRITE_SRAM = 7;
// localparam OUT = 8;
// localparam WAIT = 9;
// localparam ZERO_OUT = 10;
// localparam SKIP_FOCUS = 11;


// // localparam IDLE = 4'b0000;
// // localparam DRAM_ADDR = 4'b0001;
// // localparam WAIT_DRAM_DATA = 4'b0011;
// // localparam WAIT = 4'b0010;
// // localparam READ_SRAM = 4'b0110;//wait read sram 2 cycle delay
// // localparam ZERO_OUT = 4'b0111;
// // localparam SKIP_FOCUS = 4'b0101;
// // localparam FOCUS = 4'b0100;
// // localparam EXPOSURE = 4'b1100;
// // localparam OUT = 4'b1101;



// integer i,j,k;
// genvar a,b;









// // Your Design
// ////DRAM read port////
// // reg [31:0] araddr_s_inf_reg, n_araddr_s_inf_reg;
// reg arvalid_s_inf_reg, n_arvalid_s_inf_reg;
// reg rready_s_inf_reg, n_rready_s_inf_reg;

// //read data pipeline
// reg [127:0] rdata_s_inf_reg, n_rdata_s_inf_reg;
// reg rvalid_s_inf_reg, n_rvalid_s_inf_reg;
// reg rlast_s_inf_reg, n_rlast_s_inf_reg;

// ////get img from DRAM////
// reg [1:0] rgb_cnt, n_rgb_cnt;
// reg [5:0] pixel_cnt, n_pixel_cnt;
// reg [3:0] img_cnt, n_img_cnt;
// reg [3:0] table_cnt, n_table_cnt;
// reg [3:0] focus_cnt, n_focus_cnt;//0-5
// reg [3:0] dram_read_cnt, n_dram_read_cnt;
// // reg [5:0] read_cnt, n_read_cnt;
// ////state////
// reg [4:0] state, n_state;
// ////buffer////
// reg [43:0] r_exposure_buffer [0:8];
// reg [43:0] n_r_exposure_buffer [0:8];
// reg [43:0] g_exposure_buffer [0:8];
// reg [43:0] n_g_exposure_buffer [0:8];
// reg [43:0] b_exposure_buffer [0:8];
// reg [43:0] n_b_exposure_buffer [0:8];

// // reg [10:0] full_buffer [0:15][0:2];
// // reg [10:0] n_full_buffer [0:15][0:2];
// wire [10:0] new_full_cnt;


// // reg [47:0] focus_buffer;
// // reg [47:0] n_focus_buffer;
// ////SRAM////
// reg [8:0] addr_exposure, n_addr_exposure;
// reg [8:0] addr_focus, n_addr_focus;
// reg wen_exposure;
// //  n_wen_exposure;
// reg wen_focus;
// // , n_wen_focus;
// reg [43:0] di_exposure;
// //  n_di_exposure;
// reg [47:0] di_focus;
// //  n_di_focus;
// wire [43:0] do_exposure;
// wire[47:0] do_focus;
// //do pipelined
// reg [43:0] do_exposure_reg, n_do_exposure_reg;
// reg [47:0] do_focus_reg, n_do_focus_reg;

// ///store input////
// reg [3:0] in_pic_no_reg, n_in_pic_no_reg;
// reg [1:0] in_mode_reg, n_in_mode_reg;
// reg [1:0] in_ratio_mode_reg, n_in_ratio_mode_reg;
// ///flag///
// reg [15:0] zero_flag, n_zero_flag;
// reg wait_sram_flag, n_wait_sram_flag;
// ///
// reg [3*8 - 1 : 0] focus_data_reg, n_focus_data_reg;
// wire [47:0] focus_data_concate;
// assign focus_data_concate = {rdata_s_inf_reg[23:0], focus_data_reg};
// //////wire assignment////////////////
// assign arid_s_inf = 4'd0;
// assign arlen_s_inf = 8'd255;
// assign arsize_s_inf = 3'b100;
// assign arburst_s_inf = 2'b01;

// // assign araddr_s_inf = araddr_s_inf_reg;
// assign araddr_s_inf ={16'h0001, dram_read_cnt, 12'h000};
// assign arvalid_s_inf = arvalid_s_inf_reg;
// assign rready_s_inf = rready_s_inf_reg;
// wire get_final_img = (dram_read_cnt == 12 && pixel_cnt == 63) ? 1 : 0;

// reg [1:0] focus_result;

// reg [21:0] add22_in0 [0:17];
// reg [21:0] add22_in1 [0:17];
// wire [21:0] add22_out [0:17];
// reg [17:0] sum, n_sum;
// reg [17:0] exposure_partial_sum;

// reg [15:0] zero_detect, n_zero_detect;

// reg [13:0] sum_6x6;
// reg [13:0] n_sum_6x6;
// reg [12:0]  sum_4x4;
// reg [12:0] n_sum_4x4;
// reg [9:0]  sum_2x2;
// reg [9:0] n_sum_2x2; 
// wire [7:0] partial_sum_2x2;
// wire [9:0] partial_sum_4x4;
// wire [10:0] partial_sum_6x6;

// reg [1:0] dirty_bit [0:15];
// reg [1:0] n_dirty_bit [0:15];

// reg [15:0] dirty_flag, n_dirty_flag;

// reg [7:0] exposure_result [0:15];
// reg [7:0] n_exposure_result [0:15];
// reg [15:0] exposure_flag;
// reg [15:0] n_exposure_flag;

// wire [7:0] find_max_result, find_min_result;
// reg [7:0] max_temp, min_temp;
// reg [7:0] max_rgb [0:15][0:2];
// reg [7:0] min_rgb [0:15][0:2];

// Find_Max max(.clk(clk), .max_temp(max_temp), .in0(rdata_s_inf_reg[7:0]), .in1(rdata_s_inf_reg[15:8]), .in2(rdata_s_inf_reg[23:16]), .in3(rdata_s_inf_reg[31:24]), .in4(rdata_s_inf_reg[39:32]), .in5(rdata_s_inf_reg[47:40]), .in6(rdata_s_inf_reg[55:48]), .in7(rdata_s_inf_reg[63:56]), .in8(rdata_s_inf_reg[71:64]), .in9(rdata_s_inf_reg[79:72]), .in10(rdata_s_inf_reg[87:80]), .in11(rdata_s_inf_reg[95:88]), .in12(rdata_s_inf_reg[103:96]), .in13(rdata_s_inf_reg[111:104]), .in14(rdata_s_inf_reg[119:112]), .in15(rdata_s_inf_reg[127:120]), .max(find_max_result));
// Find_Min min(.clk(clk), .min_temp(min_temp), .in0(rdata_s_inf_reg[7:0]), .in1(rdata_s_inf_reg[15:8]), .in2(rdata_s_inf_reg[23:16]), .in3(rdata_s_inf_reg[31:24]), .in4(rdata_s_inf_reg[39:32]), .in5(rdata_s_inf_reg[47:40]), .in6(rdata_s_inf_reg[55:48]), .in7(rdata_s_inf_reg[63:56]), .in8(rdata_s_inf_reg[71:64]), .in9(rdata_s_inf_reg[79:72]), .in10(rdata_s_inf_reg[87:80]), .in11(rdata_s_inf_reg[95:88]), .in12(rdata_s_inf_reg[103:96]), .in13(rdata_s_inf_reg[111:104]), .in14(rdata_s_inf_reg[119:112]), .in15(rdata_s_inf_reg[127:120]), .min(find_min_result));

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         max_temp <= 0;
//         min_temp <= 255;
//     end
//     else begin
//         if(pixel_cnt == 0) begin
//             max_temp <= 0;
//             min_temp <= 255;
//         end
//         else if(rvalid_s_inf_reg == 1) begin
//             max_temp <= find_max_result;
//             min_temp <= find_min_result;
//         end
//     end
// end

// always @(posedge clk /*or negedge rst_n*/) begin
//     // if(!rst_n) begin
//     //     for(i=0; i<16; i=i+1) begin
//     //         for(j=0; j<3; j=j+1) begin
//     //             max_rgb[i][j] <= 0;
//     //             min_rgb[i][j] <= 0;
//     //         end
//     //     end
//     // end
//     // else 
//     begin
//         if(state == IDLE) begin
//             for(i=0; i<16; i=i+1) begin
//                 for(j=0; j<3; j=j+1) begin
//                     max_rgb[i][j] <= 0;
//                     min_rgb[i][j] <= 0;
//                 end
//             end
//         end
//         else if(focus_cnt == 1 &&(state == WAIT_DRAM_DATA || state == DRAM_ADDR || state == WAIT)) begin
//             max_rgb[15][2] <= find_max_result;
//             min_rgb[15][2] <= find_min_result;
//             max_rgb[15][1] <= max_rgb[15][2];
//             min_rgb[15][1] <= min_rgb[15][2];
//             max_rgb[15][0] <= max_rgb[15][1];
//             min_rgb[15][0] <= min_rgb[15][1];
//             for(i=0; i<15; i=i+1) begin
//                 for(j=0; j<2; j=j+1) begin
//                     max_rgb[i][j] <= max_rgb[i][j+1];
//                     min_rgb[i][j] <= min_rgb[i][j+1];
//                 end
//                 max_rgb[i][2] <= max_rgb[i+1][0];
//                 min_rgb[i][2] <= min_rgb[i+1][0];
//             end
//         end
//         else if(state == EXPOSURE && table_cnt == 5 && pixel_cnt == 8) begin
//             for(j=0; j<3; j=j+1) begin
//                 case(in_ratio_mode_reg)
//                 0:begin
//                     max_rgb[in_pic_no_reg][j] <= max_rgb[in_pic_no_reg][j] >> 2;
//                     min_rgb[in_pic_no_reg][j] <= min_rgb[in_pic_no_reg][j] >> 2;
//                 end
//                 1:begin
//                     max_rgb[in_pic_no_reg][j] <= max_rgb[in_pic_no_reg][j] >> 1;
//                     min_rgb[in_pic_no_reg][j] <= min_rgb[in_pic_no_reg][j] >> 1;
//                 end
//                 2:begin
//                     max_rgb[in_pic_no_reg][j] <= max_rgb[in_pic_no_reg][j];
//                     min_rgb[in_pic_no_reg][j] <= min_rgb[in_pic_no_reg][j];
//                 end
//                 3:begin
//                     max_rgb[in_pic_no_reg][j] <= (max_rgb[in_pic_no_reg][j][7] == 1) ? 255 : max_rgb[in_pic_no_reg][j] << 1;
//                     min_rgb[in_pic_no_reg][j] <= (min_rgb[in_pic_no_reg][j][7] == 1) ? 255 : min_rgb[in_pic_no_reg][j] << 1;
//                 end
//                 endcase
//             end
//         end
//     end
// end


// reg [8:0] add_in0_amm, add_in1_amm;
// wire [9:0] add_out0_amm;

// reg [7:0] add_in2_amm;
// wire [9:0] add_out1_amm;

// reg [9:0] amm_max_reg, amm_min_reg;



// // assign add_out0_amm = add_in0_amm + add_in1_amm;
// // // assign add_out1_amm = add_in2_amm + add_out0_amm;

// // always @(*) begin
// //     case(img_cnt)
// //         0:begin
// //             add_in0_amm = max_rgb[in_pic_no_reg][0];
// //             add_in1_amm = max_rgb[in_pic_no_reg][1];
// //         end
// //         1:begin
// //             add_in0_amm = amm_max_reg;
// //             add_in1_amm = max_rgb[in_pic_no_reg][2];
// //         end
// //         2:begin
// //             add_in0_amm = min_rgb[in_pic_no_reg][0];
// //             add_in1_amm = min_rgb[in_pic_no_reg][1];
// //         end
// //         3:begin
// //             add_in0_amm = amm_min_reg;
// //             add_in1_amm = min_rgb[in_pic_no_reg][2];
// //         end
// //         5:begin
// //             add_in0_amm = amm_min_reg;
// //             add_in1_amm = amm_max_reg;
// //         end
// //         default:begin
// //             add_in0_amm = 0;
// //             add_in1_amm = 0;
// //             add_in2_amm = 0;        
// //         end
// //     endcase
// // end

// reg [11:0] div_in0;
// wire [3:0] div_in1;
// wire [11:0] div_out;
// assign div_out = div_in0 / div_in1;
// always @(*) begin
//     if(state == Avg_Min_Max) begin
//         if(img_cnt == 2) div_in0 = amm_max_reg;
//         else div_in0 = amm_min_reg;
//     end
//     else begin
//         div_in0 = sum_6x6 >> 2;
//     end
// end

// assign div_in1 = (state == Avg_Min_Max) ? 3 : 9;



// always @(posedge clk) begin
//     case(img_cnt)
//         0, 1:begin
//             amm_max_reg <= add22_out[0];
//             amm_min_reg <= add22_out[1];
//         end
//         2: begin
//             amm_max_reg <= div_out;
//         end
//         3: begin
//             amm_min_reg <= div_out;
//         end
//         4: begin
//             amm_max_reg <= add22_out[0];
//         end
//     endcase
// end






// assign out_valid = (state == OUT || state == ZERO_OUT || state == SKIP_FOCUS)? 1 : 0;


// reg [7:0] out_data_temp;
// // assign out_data  = (state == OUT)? ((in_mode_reg == 1) ? sum[17:10] : focus_result) : 0;
// assign out_data = out_data_temp;
// always @(*) begin
//     case(state)
//         ZERO_OUT: begin
//             out_data_temp = 0;
//             // $display("000000000000!!");
//         end 
//         OUT: begin
//             // if(in_mode_reg == 1) out_data_temp = sum[17:10];
//             // else out_data_temp = focus_result;
//             case(in_mode_reg)
//                 0:begin
//                     out_data_temp = focus_result;
//                 end
//                 1:begin
//                     out_data_temp = sum[17:10];
//                 end
//                 2:begin
//                     out_data_temp = (amm_max_reg>>1);
//                 end
//                 default: out_data_temp = 0;
//             endcase
//         end
//         SKIP_FOCUS: begin
//             if(in_mode_reg == 0) begin
//                 // out_data_temp = dirty_bit[in_pic_no_reg];
//                 // $display("SKIP FOCUS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//                 case(in_pic_no_reg)
//                     0:begin
//                         out_data_temp = dirty_bit[0];
//                     end
//                     1:begin
//                         out_data_temp = dirty_bit[1];
//                     end
//                     2:begin
//                         out_data_temp = dirty_bit[2];
//                     end
//                     3:begin
//                         out_data_temp = dirty_bit[3];
//                     end
//                     4:begin
//                         out_data_temp = dirty_bit[4];
//                     end
//                     5:begin
//                         out_data_temp = dirty_bit[5];
//                     end
//                     6:begin
//                         out_data_temp = dirty_bit[6];
//                     end
//                     7:begin
//                         out_data_temp = dirty_bit[7];
//                     end
//                     8:begin
//                         out_data_temp = dirty_bit[8];
//                     end
//                     9:begin
//                         out_data_temp = dirty_bit[9];
//                     end
//                     10:begin
//                         out_data_temp = dirty_bit[10];
//                     end
//                     11:begin
//                         out_data_temp = dirty_bit[11];
//                     end
//                     12:begin
//                         out_data_temp = dirty_bit[12];
//                     end
//                     13:begin
//                         out_data_temp = dirty_bit[13];
//                     end
//                     14:begin
//                         out_data_temp = dirty_bit[14];
//                     end
//                     15:begin
//                         out_data_temp = dirty_bit[15];
//                     end
//                     default: out_data_temp = 0;
//                 endcase
//             end 
//             else begin
//                 // out_data_temp = exposure_result[in_pic_no_reg];
//                 // $display("SKIP EXPO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//                 case(in_pic_no_reg)
//                     0: begin
//                         out_data_temp = exposure_result[0];
//                     end
//                     1: begin
//                         out_data_temp = exposure_result[1];
//                     end
//                     2: begin
//                         out_data_temp = exposure_result[2];
//                     end
//                     3: begin
//                         out_data_temp = exposure_result[3];
//                     end
//                     4: begin
//                         out_data_temp = exposure_result[4];
//                     end
//                     5: begin
//                         out_data_temp = exposure_result[5];
//                     end
//                     6: begin
//                         out_data_temp = exposure_result[6];
//                     end
//                     7: begin
//                         out_data_temp = exposure_result[7];
//                     end
//                     8: begin
//                         out_data_temp = exposure_result[8];
//                     end
//                     9: begin
//                         out_data_temp = exposure_result[9];
//                     end
//                     10: begin
//                         out_data_temp = exposure_result[10];
//                     end
//                     11: begin
//                         out_data_temp = exposure_result[11];
//                     end
//                     12: begin
//                         out_data_temp = exposure_result[12];
//                     end
//                     13: begin
//                         out_data_temp = exposure_result[13];
//                     end
//                     14: begin
//                         out_data_temp = exposure_result[14];
//                     end
//                     15: begin
//                         out_data_temp = exposure_result[15];
//                     end
//                 endcase
//             end 
//         end 
//         default: out_data_temp = 0;
//     endcase
// end







// wire [7:0] dram_data [0:15];

// // wire [11:0] table_temp [0:35];
// wire [36*11 - 1 : 0] initial_table_out;

// reg [36*11 - 1 : 0] table_temp;

// always @(*) begin
//     // case(rgb_cnt)
//     //     0:begin
//     //         for(i=0; i<9; i=i+1)begin
//     //             table_temp[44*i  +: 44] = r_exposure_buffer[i];
//     //         end
//     //     end
//     //     1:begin
//     //         for(i=0; i<9; i=i+1)begin
//     //             table_temp[44*i +: 44] = g_exposure_buffer[i];
//     //         end
//     //     end
//     //     2:begin
//     //         for(i=0; i<9; i=i+1)begin
//     //             table_temp[44*i +: 44] = b_exposure_buffer[i];
//     //         end
//     //     end
//     //     default: table_temp = 0;
//     // endcase
//     for(i=0; i<9; i=i+1)begin
//         table_temp[44*i  +: 44] = r_exposure_buffer[i];
//     end
// end

// // INI_TABLE TTT(.din(rdata_s_inf_reg), .ori_full_cnt(full_buffer[img_cnt][rgb_cnt]), .ori_table(table_temp), .new_full_cnt(new_full_cnt), .new_table(initial_table_out));//'b11111111111_01010101010_11001100110_11111111111_01010101010_11001100110

// wire focus_enable = (state == FOCUS);
// wire exposure_enable = (state == EXPOSURE);
// reg [47:0] do_ratio_data;
// // FOCUS JJJ(.clk(clk), .rst_n(rst_n), .din(do_focus_reg), .rgb_cnt(rgb_cnt), .focus_enable(focus_enable), .exposure_enable(exposure_enable), .cnt(focus_cnt), .ratio(in_ratio_mode_reg), .do_index(focus_result), .do_ratio_data(do_ratio_data));

// always @(*) begin
//     case(state)
//         DRAM_ADDR, WAIT_DRAM_DATA, WAIT: begin
//             wen_exposure = (table_cnt != 0) ? 0 : 1;
//         end
//         EXPOSURE: begin
//             // wen_exposure = ((table_cnt >=3) || (table_cnt == 2 &&pixel_cnt >=7)) ? 0 : 1;
//                 wen_exposure = (dram_read_cnt == 1 ) ? 0 : 1;
//         end
//         default: wen_exposure = 1;
//     endcase
// end

// always@(*) begin
//     // case(state)
//     //     DRAM_ADDR, WAIT_DRAM_DATA, WAIT: begin
//     //         // case(rgb_cnt)
//     //         //     0:di_exposure = b_exposure_buffer[0];
//     //         //     1:di_exposure = r_exposure_buffer[0];
//     //         //     2:di_exposure = g_exposure_buffer[0];
//     //         //     default: di_exposure = 0;
//     //         // endcase
//     //         di_exposure = g_exposure_buffer[0];
//     //     end
//     //     EXPOSURE: begin
//     //         // case(img_cnt)
//     //         //     0:di_exposure = r_exposure_buffer[0];
//     //         //     1:di_exposure = g_exposure_buffer[0];
//     //         //     2:di_exposure = b_exposure_buffer[0];
//     //         //     default: di_exposure = 0;
//     //         // endcase
//     //         di_exposure = g_exposure_buffer[0];
//     //     end

//     //     default: di_exposure = 0;
//     // endcase
//     di_exposure = g_exposure_buffer[0];
// end


// always @(*) begin
//     case(state)
//         WAIT_DRAM_DATA: begin
//             case(pixel_cnt)
//                 27,29,31,33,35,37:wen_focus = 0;
//                 default:wen_focus = 1;
//             endcase
//         end
//         EXPOSURE: wen_focus = (rgb_cnt != 3) ? ~wait_sram_flag : 1;
//         default: wen_focus = 1;
//     endcase
// end


// always @(*) begin
//     case(state)
//         WAIT_DRAM_DATA: begin
//             case(pixel_cnt)
//                 27,29,31,33,35,37:di_focus = focus_data_concate;
//                 default: di_focus = 0;
//             endcase
//         end
//         EXPOSURE: di_focus = do_ratio_data;
//         default: di_focus = 0;
//     endcase
// end

// // // DRAM_ADDR
// // wire [15:0] ADDR_LUT [0:10];

// // generate
// //     for(a=0; a<11; a=a+1) begin
// //         assign ADDR_LUT[a] = 4096*(a+1);
// //     end
// // endgenerate

// /////////////////////////
// //////current_state//////
// /////////////////////////
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         state <= IDLE;
//         in_pic_no_reg <= 0;
//         in_mode_reg <= 0;
//         in_ratio_mode_reg <= 0;
//         // araddr_s_inf_reg <= 32'h10000;
//         arvalid_s_inf_reg <= 0;
//         rready_s_inf_reg <= 0;

//         rdata_s_inf_reg <= 0;
//         rvalid_s_inf_reg <= 0;
//         rlast_s_inf_reg <= 0;
        
//         img_cnt <= 0;
//         rgb_cnt <= 0;
//         pixel_cnt <= 0;
//         // focus_buffer <= 0;
//         table_cnt <= 0;
//         addr_exposure <= 0;
//         focus_data_reg <= 0;
//         addr_focus <= 0;
//         wait_sram_flag <= 0;
//         do_exposure_reg <= 0;
//         do_focus_reg <= 0;
//         focus_cnt <= 0;
//         dram_read_cnt <= 0;
//         // read_cnt <= 0;
//         sum <= 0;
//         zero_detect <= 0;
//         for(i=0; i<16; i=i+1) begin
//             dirty_bit[i] <= 0;
//         end
//         dirty_flag <= 16'b1111_1111_1111_1111;
//         for(i=0; i<16; i=i+1) begin
//             exposure_result[i] <= 0;
//         end
//         exposure_flag <= 0;
//     end
//     else begin
//         state <= n_state;
//         in_pic_no_reg <= n_in_pic_no_reg;
//         in_mode_reg <= n_in_mode_reg;
//         in_ratio_mode_reg <= n_in_ratio_mode_reg;
//         // araddr_s_inf_reg <= n_araddr_s_inf_reg;
//         arvalid_s_inf_reg <= n_arvalid_s_inf_reg;
//         rready_s_inf_reg <= n_rready_s_inf_reg;

//         rdata_s_inf_reg <= n_rdata_s_inf_reg;
//         rvalid_s_inf_reg <= n_rvalid_s_inf_reg;
//         rlast_s_inf_reg <= n_rlast_s_inf_reg;
        
//         img_cnt <= n_img_cnt;
//         rgb_cnt <= n_rgb_cnt;
//         pixel_cnt <= n_pixel_cnt;
//         // focus_buffer <= n_focus_buffer;
//         table_cnt <= n_table_cnt;
//         addr_exposure <= n_addr_exposure;
//         focus_data_reg <= n_focus_data_reg;
//         addr_focus <= n_addr_focus;
//         wait_sram_flag <= n_wait_sram_flag;
//         do_exposure_reg <= n_do_exposure_reg;
//         do_focus_reg <= n_do_focus_reg;
//         focus_cnt <= n_focus_cnt;
//         dram_read_cnt <= n_dram_read_cnt;
//         // read_cnt <= n_read_cnt;
//         sum <= n_sum;
//         zero_detect <= n_zero_detect;
//         for(i=0; i<16; i=i+1) begin
//             dirty_bit[i] <= n_dirty_bit[i];
//         end
//         dirty_flag <= n_dirty_flag;
//         for(i=0; i<16; i=i+1) begin
//             exposure_result[i] <= n_exposure_result[i];
//         end
//         exposure_flag <= n_exposure_flag;
//     end
// end
// always @(posedge clk/* or negedge rst_n*/) begin
//     /*if(!rst_n) begin
//         for(i=0; i<9; i=i+1) begin
//             r_exposure_buffer[i] <= 0;
//             g_exposure_buffer[i] <= 0;
//             // b_exposure_buffer[i] <= 0;
//         end
//     end
//     else*/ begin
//         if(state == IDLE) begin
//             for(i=0; i<9; i=i+1) begin
//             r_exposure_buffer[i] <= 0;
//             g_exposure_buffer[i] <= 0;
//             // b_exposure_buffer[i] <= 0;
//         end
//         end
//         else begin
//         for(i=0; i<9; i=i+1) begin
//             r_exposure_buffer[i] <= n_r_exposure_buffer[i];
//             g_exposure_buffer[i] <= n_g_exposure_buffer[i];
//             // b_exposure_buffer[i] <= n_b_exposure_buffer[i];
//         end
//         end
//     end
// end

// // always @(posedge clk or negedge rst_n) begin
// //     if(!rst_n) begin
// //         for(i=0; i<16; i=i+1) begin
// //             for(j=0; j<3; j=j+1) begin
// //                 full_buffer[i][j] <= 0;
// //             end
// //         end
// //     end
// //     else begin
// //         for(i=0; i<16; i=i+1) begin
// //             for(j=0; j<3; j=j+1) begin
// //                 full_buffer[i][j] <= n_full_buffer[i][j];
// //             end
// //         end
// //     end
// // end

// /////////////////////////
// ///////next_state////////
// /////////////////////////

// generate
//     for(a=0; a<16; a=a+1) begin
//         always @(*) begin
//             case(state)
//             IDLE: n_zero_detect[a] = 0;
//             EXPOSURE: begin
//                 if(in_pic_no_reg == a) begin
//                     if(di_exposure != 0 && zero_detect[a] ==0) n_zero_detect[a] = 1;
//                     else n_zero_detect[a] = zero_detect[a];
//                 end
//                 else n_zero_detect[a] = zero_detect[a];
//             end
//             OUT:begin
//                 if(in_pic_no_reg == a && in_mode_reg == 1)n_zero_detect[a] = ~zero_detect[a];
//                 else n_zero_detect[a] = zero_detect[a];
//             end 
//             default: n_zero_detect[a] = zero_detect[a];
//             endcase
//         end
//     end
// endgenerate

// generate
//     for(a=0; a<16; a=a+1) begin
//         always @(*) begin
//             // case(state)
//             //     OUT:begin
//             //         // if(in_mode_reg == 0&& in_pic_no_reg ==a) n_dirty_bit[a] = focus_result;
//             //         // else n_dirty_bit[a] = dirty_bit[a];
//             //         if(in_pic_no_reg ==a) begin
//             //             if(in_mode_reg == 0) n_dirty_bit[a] = focus_result;
//             //             else n_dirty_bit[a] = dirty_bit[a];
//             //         end
//             //         else n_dirty_bit[a] = dirty_bit[a];
//             //     end
//             //     default: n_dirty_bit[a] = dirty_bit[a];
//             // endcase
//             if(state == OUT && in_pic_no_reg ==a) begin
//                 if(in_mode_reg == 0) n_dirty_bit[a] = focus_result;
//                 else n_dirty_bit[a] = dirty_bit[a];
//             end
//             else n_dirty_bit[a] = dirty_bit[a];
//         end
//     end
// endgenerate


// generate
//     for(a=0; a<16; a=a+1) begin
//         always @(*) begin
//             // case(state)
//             //     OUT:begin
//             //         // if(in_mode_reg == 0 && in_pic_no_reg ==a) n_dirty_flag[a] = 0;
//             //         // else n_dirty_flag[a] = 1;
//             //         if(in_pic_no_reg ==a) begin
//             //             if((in_mode_reg == 1'b1 && in_ratio_mode_reg == 2 && dirty_flag[a] == 0) ||in_mode_reg == 0) n_dirty_flag[a] = 0;
//             //             else n_dirty_flag[a] = 1;
//             //         end
//             //         else n_dirty_flag[a] = dirty_flag[a];
//             //     end
//             //     default: n_dirty_flag[a] = dirty_flag[a];
//             // endcase
//             if(state ==OUT && in_pic_no_reg ==a) begin
//                 if((in_mode_reg == 1'b1 && in_ratio_mode_reg == 2 && dirty_flag[a] == 0) ||in_mode_reg == 0) n_dirty_flag[a] = 0;
//                 else n_dirty_flag[a] = 1;
//             end
//             else n_dirty_flag[a] = dirty_flag[a];
//         end
//     end
// endgenerate

// generate
//     for(a=0; a<16; a=a+1) begin
//         always @(*) begin
//             if(state == OUT) begin
//                 if(in_mode_reg == 1'b1 && in_pic_no_reg == a) n_exposure_result[a] = sum[17:10];
//                 else n_exposure_result[a] = exposure_result[a]; 
//             end
//             else n_exposure_result[a] = exposure_result[a];
//         end
//     end
// endgenerate

// generate
//     for(a=0; a<16; a=a+1) begin
//         always @(*) begin
//             if(state == OUT) begin
//                 if(in_mode_reg == 1'b1 && in_pic_no_reg == a) n_exposure_flag[a] = 1;
//                 else n_exposure_flag[a] = exposure_flag[a]; 
//             end
//             else n_exposure_flag[a] = exposure_flag[a];
//         end
//     end
// endgenerate










// always @(*) begin
//     case(state)
//         IDLE: begin
//             if(in_valid) n_state = DRAM_ADDR;
//             else n_state = state;
//         end
//         DRAM_ADDR: begin
//             if(arready_s_inf == 1'b1) n_state = WAIT_DRAM_DATA;
//             else n_state = state;
//         end
//         WAIT_DRAM_DATA: begin
//             if(rlast_s_inf_reg == 1'b1) begin
//                 if(get_final_img) n_state = WAIT;
//                 else n_state = DRAM_ADDR;
//             end 
//             else n_state = state;
//         end
//         WAIT: begin
//             // if(in_valid && zero_detect[in_pic_no] == 1) n_state = ZERO_OUT;
//             if(in_valid) begin
//                 if(in_mode == 2) n_state = Avg_Min_Max;
//                 else n_state = READ_SRAM;
//             end
//             else if(table_cnt==9) begin
//                 if(in_mode_reg == 2) n_state = Avg_Min_Max;
//                 else n_state = READ_SRAM;
//             end
//             else n_state = state;
//         end
//         READ_SRAM: begin
//             // if(zero_detect[in_pic_no_reg] == 1) n_state = ZERO_OUT;
//             // else if(wait_sram_flag == 1'b1) n_state = (in_mode_reg == 1'b0) ? FOCUS : EXPOSURE;
//             // else n_state = state;

//             // if(zero_detect[in_pic_no_reg] == 1) n_state = ZERO_OUT;
//             // else if(in_mode_reg == 1'b0) n_state = FOCUS;
//             // else n_state = (wait_sram_flag == 1'b1) ? EXPOSURE : state;

//             if(zero_detect[in_pic_no_reg] == 1) n_state = ZERO_OUT;
//             else if((in_mode_reg==1'b0 && dirty_flag[in_pic_no_reg] == 0) || (in_mode_reg==1'b1 && exposure_flag[in_pic_no_reg] == 1 && in_ratio_mode_reg == 2)) n_state = SKIP_FOCUS;
//             else if(in_mode_reg == 0) begin
//                 n_state = (wait_sram_flag == 1'b1) ? FOCUS : state;
//             end 
//             else n_state = EXPOSURE; 
            
//         end
//         Avg_Min_Max: begin
//             if(zero_detect[in_pic_no_reg] == 1) n_state = ZERO_OUT;
//             else if(img_cnt == 4) n_state = OUT;
//             else n_state = state;
//         end
//         FOCUS: begin
//             if(focus_cnt == 8) n_state = OUT;
//             else n_state = state;
//         end
//         EXPOSURE: begin
//             // if(table_cnt == 5 && pixel_cnt == 7) n_state = OUT;
//             // else n_state = state;
//             if(table_cnt == 5 && pixel_cnt == 8) n_state = OUT;
//             else n_state = state;
//         end
//         OUT:begin
//             n_state = WAIT;
//         end
//         ZERO_OUT:begin
//             n_state = WAIT;
//             // $display("ZERO_OUT: PIC%d" , in_pic_no_reg);
//         end
//         SKIP_FOCUS: begin
//             n_state = WAIT;
//         end
//         default: n_state = state;
//     endcase
// end


// wire [8:0] addr_exposure_1 = {in_pic_no, 4'b0000} + {in_pic_no, 3'b000} + {in_pic_no, 1'b0} + in_pic_no;
// wire [8:0] addr_exposure_2 = ({in_pic_no_reg, 4'b0000} + {in_pic_no_reg, 3'b000} + {in_pic_no_reg, 1'b0} + in_pic_no_reg);

// always @(*) begin
//     n_addr_exposure = addr_exposure;
//     case(state)
//         DRAM_ADDR, WAIT_DRAM_DATA: begin
//             if(table_cnt != 0) n_addr_exposure = n_addr_exposure + 1;
//             else n_addr_exposure = addr_exposure;
//         end
//         WAIT: begin
//             // if(in_valid && table_cnt==0) n_addr_exposure = in_pic_no_reg * 27;
//             // else if(table_cnt == 9 && in_mode_reg == 1) n_addr_exposure = in_pic_no_reg *27;
//             // else n_addr_exposure = addr_exposure + 1;
//             if(table_cnt == 0) begin
//                 if(in_valid) begin
//                     if(in_mode == 1) n_addr_exposure = addr_exposure_1;
//                     else n_addr_exposure = addr_exposure;
//                 end
//             end
//             else begin
//                 if(table_cnt == 9) n_addr_exposure = addr_exposure_2;
//                 else n_addr_exposure = addr_exposure + 1;
//             end
//         end
//         READ_SRAM: n_addr_exposure = addr_exposure + 1;
//         EXPOSURE: begin
//             // if(table_cnt == 5 && pixel_cnt == 6) n_addr_exposure = addr_exposure;
//             // else if(table_cnt == 2 && pixel_cnt == 6) n_addr_exposure = addr_exposure_2;
//             // else n_addr_exposure = addr_exposure + 1;
//             if(table_cnt == 5 && pixel_cnt >= 7) n_addr_exposure = addr_exposure;
//             else if(dram_read_cnt[0] == 0 && pixel_cnt == 7) n_addr_exposure = addr_exposure - 8;
//             else n_addr_exposure = addr_exposure + 1'b1;
//         end 
//         // n_addr_exposure = (table_cnt == 2 && pixel_cnt == 6) ? ({in_pic_no_reg, 4'b0000} + {in_pic_no_reg, 3'b000} + {in_pic_no_reg, 1'b0} + in_pic_no_reg) : addr_exposure + 1;
//         default: n_addr_exposure = 0;
//     endcase
// end




// always @(*) begin
//     case(state)
//         WAIT_DRAM_DATA: begin
//             case (pixel_cnt) 
//                 27,29,31,33,35:n_addr_focus =addr_focus + 1; 
//                 // 37:n_addr_focus = (img_cnt == 15 && rgb_cnt == 2) ? 0 : addr_focus + 1;
//                 37:n_addr_focus = (addr_focus==287) ? addr_focus : addr_focus + 1;
//                 default: n_addr_focus = addr_focus;
//             endcase
//         end
//         WAIT: begin
//             if(table_cnt == 0) begin
//                 if(in_valid) n_addr_focus = {in_pic_no, 4'b0000} + {in_pic_no, 1'b0};
//                 else n_addr_focus = addr_focus;
//             end
//             else begin
//                 n_addr_focus = {in_pic_no_reg, 4'b0000} + {in_pic_no_reg, 1'b0};
//             end
//         end
//         READ_SRAM: n_addr_focus = addr_focus + 1'b1;
//         FOCUS: begin
//             if((rgb_cnt!=3) && !(rgb_cnt==2 && focus_cnt >=3)) n_addr_focus = addr_focus + 1'b1;
//             else n_addr_focus = addr_focus;
//         end
//         EXPOSURE: begin
//             if(rgb_cnt == 3 || (rgb_cnt == 2 && wait_sram_flag == 1 && focus_cnt == 5)) n_addr_focus = addr_focus;
//             else if(focus_cnt == 5 && wait_sram_flag == 0) n_addr_focus = addr_focus - 5;
//             else n_addr_focus = addr_focus + 1'b1;
//         end
//         default:n_addr_focus = addr_focus;
//     endcase
// end

// // always @(*) begin
// //     for(i=0; i<16; i=i+1) begin
// //         for(j=0; j<3; j=j+1) begin
// //             n_full_buffer[i][j] = full_buffer[i][j];
// //         end
// //     end
// //     case(state)
// //         WAIT_DRAM_DATA: begin
// //             if(rvalid_s_inf_reg) begin
// //                 n_full_buffer[img_cnt][rgb_cnt] = new_full_cnt;
// //             end
// //         end
// //     endcase
// // end


// always @(*)begin
//     case(state)
//         DRAM_ADDR,WAIT_DRAM_DATA, WAIT:begin
//             // if(pixel_cnt == 63 || (table_cnt != 0 && table_cnt != 9)) n_table_cnt = table_cnt + 1;
//             // else n_table_cnt = 0;
            
//             if((pixel_cnt == 0 || (table_cnt != 0 && table_cnt != 9))&& img_cnt[0] == 1) n_table_cnt = table_cnt + 1;
//             else n_table_cnt = 0;
//         end
//         EXPOSURE: begin
//             if(pixel_cnt == 8) n_table_cnt = table_cnt + 1;
//             else n_table_cnt = table_cnt;
//         end
//         default: n_table_cnt = 0;
//     endcase
    
// end

// // wire [10:0] check_r [0:35];

// // generate
// //     for(a=0;a<36;a++) begin
// //         assign check_r[a] = r_exposure_buffer[a/6][(a%6)*11 +:11];
// //     end
        
// // endgenerate

// wire [11:0] check_r [0:7][0:7];
// assign check_r[0][0] = r_exposure_buffer[0][`index0];
// assign check_r[1][0] = r_exposure_buffer[0][`index1];
// assign check_r[1][1] = r_exposure_buffer[0][`index2];
// assign check_r[2][0] = r_exposure_buffer[0][`index3];
// assign check_r[2][1] = r_exposure_buffer[1][`index0];
// assign check_r[2][2] = r_exposure_buffer[1][`index1];
// assign check_r[3][0] = r_exposure_buffer[1][`index2];
// assign check_r[3][1] = r_exposure_buffer[1][`index3];
// assign check_r[3][2] = r_exposure_buffer[2][`index0];
// assign check_r[3][3] = r_exposure_buffer[2][`index1];
// assign check_r[4][0] = r_exposure_buffer[2][`index2];
// assign check_r[4][1] = r_exposure_buffer[2][`index3];
// assign check_r[4][2] = r_exposure_buffer[3][`index0];
// assign check_r[4][3] = r_exposure_buffer[3][`index1];
// assign check_r[4][4] = r_exposure_buffer[3][`index2];
// assign check_r[5][0] = r_exposure_buffer[3][`index3];
// assign check_r[5][1] = r_exposure_buffer[4][`index0];
// assign check_r[5][2] = r_exposure_buffer[4][`index1];
// assign check_r[5][3] = r_exposure_buffer[4][`index2];
// assign check_r[5][4] = r_exposure_buffer[4][`index3];
// assign check_r[5][5] = r_exposure_buffer[5][`index0];
// assign check_r[6][0] = r_exposure_buffer[5][`index1];
// assign check_r[6][1] = r_exposure_buffer[5][`index2];
// assign check_r[6][2] = r_exposure_buffer[5][`index3];
// assign check_r[6][3] = r_exposure_buffer[6][`index0];
// assign check_r[6][4] = r_exposure_buffer[6][`index1];
// assign check_r[6][5] = r_exposure_buffer[6][`index2];
// assign check_r[6][6] = r_exposure_buffer[6][`index3];
// assign check_r[7][0] = r_exposure_buffer[7][`index0];
// assign check_r[7][1] = r_exposure_buffer[7][`index1];
// assign check_r[7][2] = r_exposure_buffer[7][`index2];
// assign check_r[7][3] = r_exposure_buffer[7][`index3];
// assign check_r[7][4] = r_exposure_buffer[8][`index0];
// assign check_r[7][5] = r_exposure_buffer[8][`index1];
// assign check_r[7][6] = r_exposure_buffer[8][`index2];
// assign check_r[7][7] = r_exposure_buffer[8][`index3];

// wire [11:0] check_g [0:7][0:7];
// assign check_g[0][0] = g_exposure_buffer[0][`index0];
// assign check_g[1][0] = g_exposure_buffer[0][`index1];
// assign check_g[1][1] = g_exposure_buffer[0][`index2];
// assign check_g[2][0] = g_exposure_buffer[0][`index3];
// assign check_g[2][1] = g_exposure_buffer[1][`index0];
// assign check_g[2][2] = g_exposure_buffer[1][`index1];
// assign check_g[3][0] = g_exposure_buffer[1][`index2];
// assign check_g[3][1] = g_exposure_buffer[1][`index3];
// assign check_g[3][2] = g_exposure_buffer[2][`index0];
// assign check_g[3][3] = g_exposure_buffer[2][`index1];
// assign check_g[4][0] = g_exposure_buffer[2][`index2];
// assign check_g[4][1] = g_exposure_buffer[2][`index3];
// assign check_g[4][2] = g_exposure_buffer[3][`index0];
// assign check_g[4][3] = g_exposure_buffer[3][`index1];
// assign check_g[4][4] = g_exposure_buffer[3][`index2];
// assign check_g[5][0] = g_exposure_buffer[3][`index3];
// assign check_g[5][1] = g_exposure_buffer[4][`index0];
// assign check_g[5][2] = g_exposure_buffer[4][`index1];
// assign check_g[5][3] = g_exposure_buffer[4][`index2];
// assign check_g[5][4] = g_exposure_buffer[4][`index3];
// assign check_g[5][5] = g_exposure_buffer[5][`index0];
// assign check_g[6][0] = g_exposure_buffer[5][`index1];
// assign check_g[6][1] = g_exposure_buffer[5][`index2];
// assign check_g[6][2] = g_exposure_buffer[5][`index3];
// assign check_g[6][3] = g_exposure_buffer[6][`index0];
// assign check_g[6][4] = g_exposure_buffer[6][`index1];
// assign check_g[6][5] = g_exposure_buffer[6][`index2];
// assign check_g[6][6] = g_exposure_buffer[6][`index3];
// assign check_g[7][0] = g_exposure_buffer[7][`index0];
// assign check_g[7][1] = g_exposure_buffer[7][`index1];
// assign check_g[7][2] = g_exposure_buffer[7][`index2];
// assign check_g[7][3] = g_exposure_buffer[7][`index3];
// assign check_g[7][4] = g_exposure_buffer[8][`index0];
// assign check_g[7][5] = g_exposure_buffer[8][`index1];
// assign check_g[7][6] = g_exposure_buffer[8][`index2];
// assign check_g[7][7] = g_exposure_buffer[8][`index3];

// // wire [11:0] check_b [0:7][0:7];
// // assign check_b[0][0] = b_exposure_buffer[0][`index0];
// // assign check_b[1][0] = b_exposure_buffer[0][`index1];
// // assign check_b[1][1] = b_exposure_buffer[0][`index2];
// // assign check_b[2][0] = b_exposure_buffer[0][`index3];
// // assign check_b[2][1] = b_exposure_buffer[1][`index0];
// // assign check_b[2][2] = b_exposure_buffer[1][`index1];
// // assign check_b[3][0] = b_exposure_buffer[1][`index2];
// // assign check_b[3][1] = b_exposure_buffer[1][`index3];
// // assign check_b[3][2] = b_exposure_buffer[2][`index0];
// // assign check_b[3][3] = b_exposure_buffer[2][`index1];
// // assign check_b[4][0] = b_exposure_buffer[2][`index2];
// // assign check_b[4][1] = b_exposure_buffer[2][`index3];
// // assign check_b[4][2] = b_exposure_buffer[3][`index0];
// // assign check_b[4][3] = b_exposure_buffer[3][`index1];
// // assign check_b[4][4] = b_exposure_buffer[3][`index2];
// // assign check_b[5][0] = b_exposure_buffer[3][`index3];
// // assign check_b[5][1] = b_exposure_buffer[4][`index0];
// // assign check_b[5][2] = b_exposure_buffer[4][`index1];
// // assign check_b[5][3] = b_exposure_buffer[4][`index2];
// // assign check_b[5][4] = b_exposure_buffer[4][`index3];
// // assign check_b[5][5] = b_exposure_buffer[5][`index0];
// // assign check_b[6][0] = b_exposure_buffer[5][`index1];
// // assign check_b[6][1] = b_exposure_buffer[5][`index2];
// // assign check_b[6][2] = b_exposure_buffer[5][`index3];
// // assign check_b[6][3] = b_exposure_buffer[6][`index0];
// // assign check_b[6][4] = b_exposure_buffer[6][`index1];
// // assign check_b[6][5] = b_exposure_buffer[6][`index2];
// // assign check_b[6][6] = b_exposure_buffer[6][`index3];
// // assign check_b[7][0] = b_exposure_buffer[7][`index0];
// // assign check_b[7][1] = b_exposure_buffer[7][`index1];
// // assign check_b[7][2] = b_exposure_buffer[7][`index2];
// // assign check_b[7][3] = b_exposure_buffer[7][`index3];
// // assign check_b[7][4] = b_exposure_buffer[8][`index0];
// // assign check_b[7][5] = b_exposure_buffer[8][`index1];
// // assign check_b[7][6] = b_exposure_buffer[8][`index2];
// // assign check_b[7][7] = b_exposure_buffer[8][`index3];





// always @(*) begin
//     // for(i=0; i<9; i=i+1) begin
//     //     n_r_exposure_buffer[i] = 0;
//     // end
//     case(state)
//         // DRAM_ADDR: begin
//         //     for(i=0; i<9; i=i+1) begin
//         //         n_r_exposure_buffer[i] = 0;
//         //     end
//         // end
//         WAIT_DRAM_DATA: begin
//             // if(pixel_cnt == 0) begin
//             //     for(i=0; i<9; i=i+1) begin
//             //         n_r_exposure_buffer[i] = 0;
//             //     end
//             // end
//             // else begin
//             //     for(i=0; i<9; i=i+1) begin
//             //         n_r_exposure_buffer[i] = initial_table_out[44*i +: 44];
//             //     end
//             // end
//             for(i=0; i<9; i=i+1) begin
//                 n_r_exposure_buffer[i] = initial_table_out[44*i +: 44];
//             end

//         end
//         EXPOSURE:begin
//             n_r_exposure_buffer[8] = do_exposure;
//             for(i=0; i<8; i=i+1) begin
//                 n_r_exposure_buffer[i] = r_exposure_buffer[i+1];
//             end
//         end
//         default: begin
//             for(i=0; i<9; i=i+1) begin
//                 n_r_exposure_buffer[i] = r_exposure_buffer[i];
//             end
//         end
//     endcase
// end
// always @(*) begin
//     // for(i=0; i<9; i=i+1) begin
//     //     n_g_exposure_buffer[i] = g_exposure_buffer[i];
//     // end
//     case(state)
//         // DRAM_ADDR, WAIT: begin
//         //     if(table_cnt == 0) begin
//         //         n_g_exposure_buffer[8] = 0;
//         //         for(i=0; i<8; i=i+1) begin
//         //             n_g_exposure_buffer[i] = g_exposure_buffer[i+1];
//         //         end
//         //     end
            
//         // end
        
//         WAIT_DRAM_DATA,DRAM_ADDR, WAIT: begin
//             if(table_cnt==0) begin
//                 for(i=0; i<9; i=i+1) begin
//                     n_g_exposure_buffer[i] = initial_table_out[44*i +: 44];
//                 end
//             end
//             else begin
//                 n_g_exposure_buffer[8] = 0;
//                 for(i=0; i<8; i=i+1) begin
//                     n_g_exposure_buffer[i] = g_exposure_buffer[i+1];
//                 end
//             end
//         end
//         EXPOSURE:begin
//             n_g_exposure_buffer[8] = 0;
//             for(i=0; i<8; i=i+1) begin
//                 n_g_exposure_buffer[i] = g_exposure_buffer[i+1];
//             end
//             // if(pixel_cnt == 7) begin
//             //     case(in_ratio_mode_reg)
//             //         0:begin
//             //             n_g_exposure_buffer[0][`index0] =  r_exposure_buffer[3][`index1]; 
//             //             n_g_exposure_buffer[0][`index1] =  r_exposure_buffer[4][`index0]; 
//             //             n_g_exposure_buffer[0][`index2] =  r_exposure_buffer[4][`index1]; 
//             //             n_g_exposure_buffer[0][`index3] =  r_exposure_buffer[5][`index0]; 

//             //             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[5][`index1];
//             //             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[5][`index2];
//             //             n_g_exposure_buffer[1][`index2] = r_exposure_buffer[6][`index1];
//             //             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[6][`index2];

//             //             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[6][`index3];
//             //             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[7][`index0];
//             //             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[7][`index3];
//             //             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[8][`index0];

//             //             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[8][`index2];
//             //             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[8][`index3];
//             //             // n_g_exposure_buffer[3][`index3] = r_exposure_buffer[9][`index2];

//             //             // n_g_exposure_buffer[4][`index0] = r_exposure_buffer[9][`index3];
//             //             // n_g_exposure_buffer[4][`index1] = r_exposure_buffer[10][`index0];
//             //             // n_g_exposure_buffer[4][`index2] = r_exposure_buffer[10][`index1];
//             //             // n_g_exposure_buffer[4][`index3] = r_exposure_buffer[10][`index2];

//             //             // n_g_exposure_buffer[5][`index0] = r_exposure_buffer[10][`index3];
//             //             n_g_exposure_buffer[5][`index1] = 0;
//             //             n_g_exposure_buffer[5][`index2] = 0;
//             //             n_g_exposure_buffer[5][`index3] = 0;

//             //             n_g_exposure_buffer[6][`index0] = 0;
//             //             n_g_exposure_buffer[6][`index1] = 0;
//             //             n_g_exposure_buffer[6][`index2] = 0;
//             //             n_g_exposure_buffer[6][`index3] = 0; 

//             //             n_g_exposure_buffer[7][`index0] = 0;
//             //             n_g_exposure_buffer[7][`index1] = 0;
//             //             n_g_exposure_buffer[7][`index2] = 0;
//             //             n_g_exposure_buffer[7][`index3] = 0;

//             //             n_g_exposure_buffer[8][`index0] = 0;
//             //             n_g_exposure_buffer[8][`index1] = 0;
//             //             n_g_exposure_buffer[8][`index2] = 0;
//             //             n_g_exposure_buffer[8][`index3] = 0;
//             //         end
//             //         1: begin
//             //             n_g_exposure_buffer[0][`index0] = r_exposure_buffer[2][`index2];
//             //             n_g_exposure_buffer[0][`index1] = r_exposure_buffer[3][`index0];
//             //             n_g_exposure_buffer[0][`index2] = r_exposure_buffer[3][`index1];
//             //             n_g_exposure_buffer[0][`index3] = r_exposure_buffer[3][`index3];

//             //             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[4][`index0];
//             //             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[4][`index1];
//             //             n_g_exposure_buffer[1][`index2] = r_exposure_buffer[4][`index3];
//             //             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[5][`index0];

//             //             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[5][`index1];
//             //             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[5][`index2];
//             //             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[6][`index0];
//             //             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[6][`index1];

//             //             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[6][`index2];
//             //             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[6][`index3];
//             //             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[7][`index0];
//             //             n_g_exposure_buffer[3][`index3] = r_exposure_buffer[7][`index2];

//             //             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[7][`index3];
//             //             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[8][`index0];
//             //             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[8][`index2];

//             //             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[8][`index3];
//             //             // n_g_exposure_buffer[5][`index1] = r_exposure_buffer[9][`index1];
//             //             // n_g_exposure_buffer[5][`index2] = r_exposure_buffer[9][`index2];
//             //             // n_g_exposure_buffer[5][`index3] = r_exposure_buffer[9][`index3];

//             //             // n_g_exposure_buffer[6][`index0] = r_exposure_buffer[10][`index0];
//             //             // n_g_exposure_buffer[6][`index1] = r_exposure_buffer[10][`index1];
//             //             // n_g_exposure_buffer[6][`index2] = r_exposure_buffer[10][`index2];
//             //             // n_g_exposure_buffer[6][`index3] = r_exposure_buffer[10][`index3]; 

//             //             n_g_exposure_buffer[7][`index0] = 0;
//             //             n_g_exposure_buffer[7][`index1] = 0;
//             //             n_g_exposure_buffer[7][`index2] = 0;
//             //             n_g_exposure_buffer[7][`index3] = 0;
                        
//             //             n_g_exposure_buffer[8][`index0] = 0;
//             //             n_g_exposure_buffer[8][`index1] = 0;
//             //             n_g_exposure_buffer[8][`index2] = 0;
//             //             n_g_exposure_buffer[8][`index3] = 0;
//             //         end
//             //         2: begin
//             //             for (i = 0; i<7; i=i+1) begin
//             //                 n_g_exposure_buffer[i][`index0] = r_exposure_buffer[i+2][`index0];
//             //                 n_g_exposure_buffer[i][`index1] = r_exposure_buffer[i+2][`index1];
//             //                 n_g_exposure_buffer[i][`index2] = r_exposure_buffer[i+2][`index2];
//             //                 n_g_exposure_buffer[i][`index3] = r_exposure_buffer[i+2][`index3]; 
//             //             end
//             //         end 
//             //         // n_g_exposure_buffer = r_exposure_buffer;
//             //         3: begin
//             //             n_g_exposure_buffer[0][`index0] = 0;
//             //             n_g_exposure_buffer[0][`index1] = 0;
//             //             n_g_exposure_buffer[0][`index2] = r_exposure_buffer[2][`index0];
//             //             n_g_exposure_buffer[0][`index3] = 0;

//             //             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[2][`index1];
//             //             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[2][`index2];
//             //             n_g_exposure_buffer[1][`index2] = 0;
//             //             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[2][`index3];

//             //             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[3][`index0];
//             //             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[3][`index1];
//             //             n_g_exposure_buffer[2][`index2] = 0;
//             //             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[3][`index2];

//             //             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[3][`index3];
//             //             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[4][`index0];
//             //             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[4][`index1];
//             //             n_g_exposure_buffer[3][`index3] = 0;

//             //             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[4][`index2];
//             //             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[4][`index3];
//             //             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[5][`index0];
//             //             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[5][`index1];

//             //             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[5][`index2];
//             //             n_g_exposure_buffer[5][`index1] = 0;
//             //             n_g_exposure_buffer[5][`index2] = r_exposure_buffer[5][`index3];
//             //             n_g_exposure_buffer[5][`index3] = r_exposure_buffer[6][`index0];

//             //             n_g_exposure_buffer[6][`index0] = r_exposure_buffer[6][`index1];
//             //             n_g_exposure_buffer[6][`index1] = r_exposure_buffer[6][`index2];
//             //             n_g_exposure_buffer[6][`index2] = r_exposure_buffer[6][`index3];
//             //             n_g_exposure_buffer[6][`index3] = r_exposure_buffer[7][`index0]; 
                        
//             //             // n_g_exposure_buffer[7][`index0] = r_exposure_buffer[8][`index3];
//             //             n_g_exposure_buffer[7][`index1] = r_exposure_buffer[7][`index1];
//             //             n_g_exposure_buffer[7][`index2] = r_exposure_buffer[7][`index2];
//             //             n_g_exposure_buffer[7][`index3] = r_exposure_buffer[7][`index3];
                                                
//             //             n_g_exposure_buffer[8][`index0] = r_exposure_buffer[8][`index0];
//             //             n_g_exposure_buffer[8][`index1] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[8][`index2] = r_exposure_buffer[8][`index2];
//             //             n_g_exposure_buffer[8][`index3] = r_exposure_buffer[8][`index3];
//             //         end     
//             //     endcase

//             // end
//             // else if(pixel_cnt == 0) begin
                
//             //     case(in_ratio_mode_reg)
//             //         0:begin
                    
//             //             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[7][`index2];

//             //             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[7][`index3];
//             //             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[8][`index0];
//             //             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[8][`index2];

//             //             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[8][`index3];

//             //         end
//             //         1: begin

//             //             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[7][`index1];
//             //             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[7][`index2];
//             //             n_g_exposure_buffer[3][`index3] = r_exposure_buffer[7][`index3];

//             //             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[8][`index0];
//             //             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[8][`index2];
//             //             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[8][`index3]; 

//             //         end
//             //         2:begin
//             //             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[7][`index0];
//             //             n_g_exposure_buffer[5][`index1] = r_exposure_buffer[7][`index1];
//             //             n_g_exposure_buffer[5][`index2] = r_exposure_buffer[7][`index2];
//             //             n_g_exposure_buffer[5][`index3] = r_exposure_buffer[7][`index3]; 
//             //             n_g_exposure_buffer[6][`index0] = r_exposure_buffer[8][`index0];
//             //             n_g_exposure_buffer[6][`index1] = r_exposure_buffer[8][`index1];
//             //             n_g_exposure_buffer[6][`index2] = r_exposure_buffer[8][`index2];
//             //             n_g_exposure_buffer[6][`index3] = r_exposure_buffer[8][`index3]; 
//             //         end
//             //         3: begin
                        
                        
//             //             n_g_exposure_buffer[5][`index0] = add22_out[0][`index0];
//             //             n_g_exposure_buffer[5][`index1] = add22_out[0][`index1];
//             //             n_g_exposure_buffer[5][`index2] = add22_out[1][`index0];
//             //             n_g_exposure_buffer[5][`index3] = add22_out[1][`index1];
                                                
//             //             n_g_exposure_buffer[6][`index0] = add22_out[2][`index0];
//             //             n_g_exposure_buffer[6][`index1] = add22_out[2][`index1];
//             //             n_g_exposure_buffer[6][`index2] = add22_out[3][`index0];
//             //             n_g_exposure_buffer[6][`index3] = add22_out[3][`index1]; 
//             //         end     
//             //     endcase
//             // end

//             case(pixel_cnt)
//                 7: begin
//                     case(in_ratio_mode_reg)
//                         0:begin
//                             n_g_exposure_buffer[0][`index0] =  r_exposure_buffer[3][`index1]; 
//                             n_g_exposure_buffer[0][`index1] =  r_exposure_buffer[4][`index0]; 
//                             n_g_exposure_buffer[0][`index2] =  r_exposure_buffer[4][`index1]; 
//                             n_g_exposure_buffer[0][`index3] =  r_exposure_buffer[5][`index0]; 

//                             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[5][`index1];
//                             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[5][`index2];
//                             n_g_exposure_buffer[1][`index2] = r_exposure_buffer[6][`index1];
//                             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[6][`index2];

//                             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[6][`index3];
//                             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[7][`index0];
//                             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[7][`index3];
//                             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[8][`index0];

//                             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[8][`index2];
//                             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[8][`index3];
//                             // n_g_exposure_buffer[3][`index3] = r_exposure_buffer[9][`index2];

//                             // n_g_exposure_buffer[4][`index0] = r_exposure_buffer[9][`index3];
//                             // n_g_exposure_buffer[4][`index1] = r_exposure_buffer[10][`index0];
//                             // n_g_exposure_buffer[4][`index2] = r_exposure_buffer[10][`index1];
//                             // n_g_exposure_buffer[4][`index3] = r_exposure_buffer[10][`index2];

//                             // n_g_exposure_buffer[5][`index0] = r_exposure_buffer[10][`index3];
//                             n_g_exposure_buffer[5][`index1] = 0;
//                             n_g_exposure_buffer[5][`index2] = 0;
//                             n_g_exposure_buffer[5][`index3] = 0;

//                             n_g_exposure_buffer[6][`index0] = 0;
//                             n_g_exposure_buffer[6][`index1] = 0;
//                             n_g_exposure_buffer[6][`index2] = 0;
//                             n_g_exposure_buffer[6][`index3] = 0; 

//                             n_g_exposure_buffer[7][`index0] = 0;
//                             n_g_exposure_buffer[7][`index1] = 0;
//                             n_g_exposure_buffer[7][`index2] = 0;
//                             n_g_exposure_buffer[7][`index3] = 0;

//                             n_g_exposure_buffer[8][`index0] = 0;
//                             n_g_exposure_buffer[8][`index1] = 0;
//                             n_g_exposure_buffer[8][`index2] = 0;
//                             n_g_exposure_buffer[8][`index3] = 0;
//                         end
//                         1: begin
//                             n_g_exposure_buffer[0][`index0] = r_exposure_buffer[2][`index2];
//                             n_g_exposure_buffer[0][`index1] = r_exposure_buffer[3][`index0];
//                             n_g_exposure_buffer[0][`index2] = r_exposure_buffer[3][`index1];
//                             n_g_exposure_buffer[0][`index3] = r_exposure_buffer[3][`index3];

//                             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[4][`index0];
//                             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[4][`index1];
//                             n_g_exposure_buffer[1][`index2] = r_exposure_buffer[4][`index3];
//                             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[5][`index0];

//                             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[5][`index1];
//                             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[5][`index2];
//                             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[6][`index0];
//                             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[6][`index1];

//                             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[6][`index2];
//                             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[6][`index3];
//                             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[7][`index0];
//                             n_g_exposure_buffer[3][`index3] = r_exposure_buffer[7][`index2];

//                             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[7][`index3];
//                             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[8][`index0];
//                             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[8][`index2];

//                             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[8][`index3];
//                             // n_g_exposure_buffer[5][`index1] = r_exposure_buffer[9][`index1];
//                             // n_g_exposure_buffer[5][`index2] = r_exposure_buffer[9][`index2];
//                             // n_g_exposure_buffer[5][`index3] = r_exposure_buffer[9][`index3];

//                             // n_g_exposure_buffer[6][`index0] = r_exposure_buffer[10][`index0];
//                             // n_g_exposure_buffer[6][`index1] = r_exposure_buffer[10][`index1];
//                             // n_g_exposure_buffer[6][`index2] = r_exposure_buffer[10][`index2];
//                             // n_g_exposure_buffer[6][`index3] = r_exposure_buffer[10][`index3]; 

//                             n_g_exposure_buffer[7][`index0] = 0;
//                             n_g_exposure_buffer[7][`index1] = 0;
//                             n_g_exposure_buffer[7][`index2] = 0;
//                             n_g_exposure_buffer[7][`index3] = 0;

//                             n_g_exposure_buffer[8][`index0] = 0;
//                             n_g_exposure_buffer[8][`index1] = 0;
//                             n_g_exposure_buffer[8][`index2] = 0;
//                             n_g_exposure_buffer[8][`index3] = 0;
//                         end
//                         2: begin
//                             for (i = 0; i<7; i=i+1) begin
//                                 n_g_exposure_buffer[i][`index0] = r_exposure_buffer[i+2][`index0];
//                                 n_g_exposure_buffer[i][`index1] = r_exposure_buffer[i+2][`index1];
//                                 n_g_exposure_buffer[i][`index2] = r_exposure_buffer[i+2][`index2];
//                                 n_g_exposure_buffer[i][`index3] = r_exposure_buffer[i+2][`index3]; 
//                             end
//                         end 
//                         // n_g_exposure_buffer = r_exposure_buffer;
//                         3: begin
//                             n_g_exposure_buffer[0][`index0] = 0;
//                             n_g_exposure_buffer[0][`index1] = 0;
//                             n_g_exposure_buffer[0][`index2] = r_exposure_buffer[2][`index0];
//                             n_g_exposure_buffer[0][`index3] = 0;

//                             n_g_exposure_buffer[1][`index0] = r_exposure_buffer[2][`index1];
//                             n_g_exposure_buffer[1][`index1] = r_exposure_buffer[2][`index2];
//                             n_g_exposure_buffer[1][`index2] = 0;
//                             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[2][`index3];

//                             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[3][`index0];
//                             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[3][`index1];
//                             n_g_exposure_buffer[2][`index2] = 0;
//                             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[3][`index2];

//                             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[3][`index3];
//                             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[4][`index0];
//                             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[4][`index1];
//                             n_g_exposure_buffer[3][`index3] = 0;

//                             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[4][`index2];
//                             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[4][`index3];
//                             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[5][`index0];
//                             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[5][`index1];

//                             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[5][`index2];
//                             n_g_exposure_buffer[5][`index1] = 0;
//                             n_g_exposure_buffer[5][`index2] = r_exposure_buffer[5][`index3];
//                             n_g_exposure_buffer[5][`index3] = r_exposure_buffer[6][`index0];

//                             n_g_exposure_buffer[6][`index0] = r_exposure_buffer[6][`index1];
//                             n_g_exposure_buffer[6][`index1] = r_exposure_buffer[6][`index2];
//                             n_g_exposure_buffer[6][`index2] = r_exposure_buffer[6][`index3];
//                             n_g_exposure_buffer[6][`index3] = r_exposure_buffer[7][`index0]; 

//                             // n_g_exposure_buffer[7][`index0] = r_exposure_buffer[8][`index3];
//                             n_g_exposure_buffer[7][`index1] = r_exposure_buffer[7][`index1];
//                             n_g_exposure_buffer[7][`index2] = r_exposure_buffer[7][`index2];
//                             n_g_exposure_buffer[7][`index3] = r_exposure_buffer[7][`index3];

//                             n_g_exposure_buffer[8][`index0] = r_exposure_buffer[8][`index0];
//                             n_g_exposure_buffer[8][`index1] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[8][`index2] = r_exposure_buffer[8][`index2];
//                             n_g_exposure_buffer[8][`index3] = r_exposure_buffer[8][`index3];
//                         end     
//                      endcase
//                 end
//                 0: begin
//                     case(in_ratio_mode_reg)
//                         0:begin
                        
//                             n_g_exposure_buffer[1][`index3] = r_exposure_buffer[7][`index2];
    
//                             n_g_exposure_buffer[2][`index0] = r_exposure_buffer[7][`index3];
//                             n_g_exposure_buffer[2][`index1] = r_exposure_buffer[8][`index0];
//                             n_g_exposure_buffer[2][`index2] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[2][`index3] = r_exposure_buffer[8][`index2];
    
//                             n_g_exposure_buffer[3][`index0] = r_exposure_buffer[8][`index3];
    
//                         end
//                         1: begin
                        
//                             n_g_exposure_buffer[3][`index1] = r_exposure_buffer[7][`index1];
//                             n_g_exposure_buffer[3][`index2] = r_exposure_buffer[7][`index2];
//                             n_g_exposure_buffer[3][`index3] = r_exposure_buffer[7][`index3];
    
//                             n_g_exposure_buffer[4][`index0] = r_exposure_buffer[8][`index0];
//                             n_g_exposure_buffer[4][`index1] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[4][`index2] = r_exposure_buffer[8][`index2];
//                             n_g_exposure_buffer[4][`index3] = r_exposure_buffer[8][`index3]; 
    
//                         end
//                         2:begin
//                             n_g_exposure_buffer[5][`index0] = r_exposure_buffer[7][`index0];
//                             n_g_exposure_buffer[5][`index1] = r_exposure_buffer[7][`index1];
//                             n_g_exposure_buffer[5][`index2] = r_exposure_buffer[7][`index2];
//                             n_g_exposure_buffer[5][`index3] = r_exposure_buffer[7][`index3]; 
//                             n_g_exposure_buffer[6][`index0] = r_exposure_buffer[8][`index0];
//                             n_g_exposure_buffer[6][`index1] = r_exposure_buffer[8][`index1];
//                             n_g_exposure_buffer[6][`index2] = r_exposure_buffer[8][`index2];
//                             n_g_exposure_buffer[6][`index3] = r_exposure_buffer[8][`index3]; 
//                         end
//                         3: begin
                            
                            
//                             n_g_exposure_buffer[5][`index0] = add22_out[0][`index0];
//                             n_g_exposure_buffer[5][`index1] = add22_out[0][`index1];
//                             n_g_exposure_buffer[5][`index2] = add22_out[1][`index0];
//                             n_g_exposure_buffer[5][`index3] = add22_out[1][`index1];
                                                    
//                             n_g_exposure_buffer[6][`index0] = add22_out[2][`index0];
//                             n_g_exposure_buffer[6][`index1] = add22_out[2][`index1];
//                             n_g_exposure_buffer[6][`index2] = add22_out[3][`index0];
//                             n_g_exposure_buffer[6][`index3] = add22_out[3][`index1]; 
//                         end     
//                     endcase
//                 end
//             endcase
                

//         end

//             // else begin
//             //     for(i=0; i<8; i=i+1) begin
//             //         n_g_exposure_buffer[i] = g_exposure_buffer[i+1];
//             //     end
//             // end
//         default: begin
//             for(i=0; i<9; i=i+1) begin
//                 n_g_exposure_buffer[i] = 0;
//             end
//         end
//     endcase
// end
// // always @(*) begin
// //     n_focus_buffer = focus_buffer;
// // end

// always @(*) begin
//     // if(state == READ_SRAM) n_wait_sram_flag = ~wait_sram_flag;
//     // else n_wait_sram_flag = wait_sram_flag;
//     case(state)
//         READ_SRAM : n_wait_sram_flag = (in_mode_reg == 0);
//         EXPOSURE: n_wait_sram_flag = (focus_cnt == 5) ? ~wait_sram_flag : wait_sram_flag;
//         default : n_wait_sram_flag = 0;
//     endcase
// end

// always @(*) begin
//     if(state == WAIT_DRAM_DATA) begin
//         case(pixel_cnt) 
//         26,28,30,32,34,36: n_focus_data_reg = rdata_s_inf_reg[127 : 104] ;//store first 3 pixel
//         default: n_focus_data_reg = 0;
//         endcase
//     end
//     else n_focus_data_reg = 0;
// end


// always @(*) begin
//     case (state)
//         DRAM_ADDR, WAIT_DRAM_DATA, WAIT:begin
//             if(focus_cnt == 1) n_focus_cnt = 0;
//             else if(pixel_cnt == 63) n_focus_cnt = 1;
//             else n_focus_cnt = focus_cnt;
//         end
//         FOCUS: begin
//             if(rgb_cnt==3) begin
//                 n_focus_cnt = focus_cnt + 1;
//             end
//             else if(focus_cnt==5) n_focus_cnt = 0;
//             else n_focus_cnt = focus_cnt + 1;
//         end
//         READ_SRAM: n_focus_cnt = (in_mode_reg==1);
//         EXPOSURE: begin
//             if(focus_cnt==5) n_focus_cnt = 0;
//             else n_focus_cnt = focus_cnt + 1;
//         end
//         default: n_focus_cnt = 0;
//     endcase
// end






// always @(*) begin
//     n_img_cnt = img_cnt;
//     case (state)
//         // IDLE: begin
//         //     n_img_cnt = 0;
//         // end 
//         WAIT: n_img_cnt = (table_cnt == 9) ? 0: img_cnt;
//         // WAIT_DRAM_DATA: begin
//         //     if(rgb_cnt == 2 && pixel_cnt == 63) n_img_cnt = img_cnt + 1;
//         //     else n_img_cnt = img_cnt;
//         // end
//         READ_SRAM:n_img_cnt = 0;
//         WAIT_DRAM_DATA: begin
//             if(img_cnt[0] == 0 && pixel_cnt[3:0] == 9) n_img_cnt[0] = 1;
//             else if(rvalid_s_inf_reg==0 && table_cnt == 8) n_img_cnt[0] = 0;
//         end
//         // WAIT: if(table_cnt == 9) n_img_cnt[0] = 0;
//         EXPOSURE: begin
//             if(dram_read_cnt[0] == 0 && pixel_cnt == 7) n_img_cnt = img_cnt + 1;
//             else if(table_cnt == 5 && pixel_cnt ==8) n_img_cnt = 0;
//         end
//         Avg_Min_Max: begin
//             n_img_cnt = img_cnt + 1;
//         end
//         ZERO_OUT: begin
//             n_img_cnt = 0;
//         end
//         OUT: begin
//             n_img_cnt = 0;
//         end
//         default: n_img_cnt = img_cnt;
//     endcase
// end

// always @(*) begin
//     case(state)
//         IDLE: begin
//             n_rgb_cnt = 0;
//         end
//         WAIT_DRAM_DATA: begin
//             if(pixel_cnt == 63) n_rgb_cnt = (rgb_cnt == 0) ? 1 : 0;
//             else n_rgb_cnt = rgb_cnt;
//         end
//         WAIT: begin
//             n_rgb_cnt = 0;
//         end
//         FOCUS: begin
//             if(focus_cnt == 5) begin
//                 n_rgb_cnt = (rgb_cnt == 3) ? 3 : rgb_cnt + 1;
//             end
//             else n_rgb_cnt = rgb_cnt;
//         end
//         EXPOSURE: begin
//             if(wen_focus==0 && focus_cnt==5) n_rgb_cnt = rgb_cnt + 1;
//             else n_rgb_cnt = rgb_cnt;
//         end
//         default: n_rgb_cnt = rgb_cnt;
//     endcase
// end







// always @(*) begin
//     case (state)
//         // IDLE: begin
//         //     n_pixel_cnt = 0;
//         // end 
//         // WAIT: n_pixel_cnt = pixel_cnt + 1;
//         READ_SRAM: n_pixel_cnt = 0;
//         WAIT_DRAM_DATA: begin
//             if(rvalid_s_inf_reg == 1'b1) n_pixel_cnt = pixel_cnt + 1;
//             else n_pixel_cnt = pixel_cnt;
//         end
//         EXPOSURE: begin
//             n_pixel_cnt = (pixel_cnt == 8) ? 0 : pixel_cnt + 1;
//         end
//         default: n_pixel_cnt = pixel_cnt;
//     endcase
// end



// /////DRAM////////
// always @(*) begin
//     case(state)
//         IDLE: begin
//             if(in_valid) n_arvalid_s_inf_reg = 1;
//             else n_arvalid_s_inf_reg = arvalid_s_inf_reg;
//         end
//         DRAM_ADDR: begin
//             if(arready_s_inf == 1'b1) n_arvalid_s_inf_reg = 0;
//             else n_arvalid_s_inf_reg = arvalid_s_inf_reg;
//         end
//         WAIT_DRAM_DATA: begin
//             if(rlast_s_inf_reg == 1'b1 && !get_final_img) n_arvalid_s_inf_reg = 1;
//             else n_arvalid_s_inf_reg = arvalid_s_inf_reg;
//         end
//         default: n_arvalid_s_inf_reg = arvalid_s_inf_reg;
//     endcase
// end

// always @(*) begin
//     case (state)
//         DRAM_ADDR:begin
//             if(arready_s_inf == 1'b1) n_rready_s_inf_reg = 1;
//             else n_rready_s_inf_reg = rready_s_inf_reg;
//         end 
//         WAIT_DRAM_DATA: begin
//             if(rlast_s_inf_reg == 1'b1) n_rready_s_inf_reg = 0;
//             else n_rready_s_inf_reg = rready_s_inf_reg;
//         end
//         default: n_rready_s_inf_reg = rready_s_inf_reg;
//     endcase
// end



// always @(*) begin
//     n_do_exposure_reg = do_exposure;
// end

// always @(*) begin
//     n_do_focus_reg = do_focus;
// end


// always @(*) begin
//     n_rdata_s_inf_reg = rdata_s_inf;
//     n_rvalid_s_inf_reg = rvalid_s_inf;
//     n_rlast_s_inf_reg = rlast_s_inf;
// end

// always @(*) begin
//     n_dram_read_cnt = dram_read_cnt;
//     // if(rlast_s_inf==1) n_dram_read_cnt = dram_read_cnt + 1;
//     // else n_dram_read_cnt = dram_read_cnt;
//     case(state)
//         WAIT: n_dram_read_cnt = 0;
//         WAIT_DRAM_DATA: n_dram_read_cnt = (rlast_s_inf==1) ? dram_read_cnt + 1 : dram_read_cnt;
//         EXPOSURE: begin
//             // if((table_cnt==2 && pixel_cnt==6)) begin
//             //     n_dram_read_cnt = 1;
//             // end
//             // else if(dram_read_cnt != 0) n_dram_read_cnt = (dram_read_cnt == 9) ? 1 : dram_read_cnt + 1;
//             // else n_dram_read_cnt = 0;


//             if(pixel_cnt == 7) n_dram_read_cnt[0] = ~dram_read_cnt[0];
//             else n_dram_read_cnt[0] = dram_read_cnt[0];
//         end
//         default: n_dram_read_cnt = dram_read_cnt;
//     endcase
// end

// always @(*) begin
//     if(in_valid) n_in_pic_no_reg = in_pic_no;
//     else n_in_pic_no_reg = in_pic_no_reg;
// end

// always @(*) begin
//     if(in_valid) n_in_mode_reg = in_mode;
//     else n_in_mode_reg = in_mode_reg;
// end

// always @(*) begin
//     if(in_valid && in_mode==1'b1) n_in_ratio_mode_reg = in_ratio_mode;
//     else n_in_ratio_mode_reg = in_ratio_mode_reg;
// end



// reg [100:0] global_cnt;
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) global_cnt <= 0;
//     else if(state != IDLE || in_valid) global_cnt <= global_cnt + 1;
// end


// //SRAM_FOCUS
// SUMA180_288X48X1BM1 FOCUS_SRAM(.A0(addr_focus[0]), .A1(addr_focus[1]), .A2(addr_focus[2]), .A3(addr_focus[3]), .A4(addr_focus[4]), .A5(addr_focus[5]), .A6(addr_focus[6]), .A7(addr_focus[7]), .A8(addr_focus[8]),
//                      .DO0(do_focus[0]), .DO1(do_focus[1]), .DO2(do_focus[2]), .DO3(do_focus[3]), .DO4(do_focus[4]), 
//                      .DO5(do_focus[5]), .DO6(do_focus[6]), .DO7(do_focus[7]), .DO8(do_focus[8]), .DO9(do_focus[9]), .DO10(do_focus[10]), .DO11(do_focus[11]), .DO12(do_focus[12]), .DO13(do_focus[13]), .DO14(do_focus[14]), 
//                      .DO15(do_focus[15]), .DO16(do_focus[16]), .DO17(do_focus[17]), .DO18(do_focus[18]), .DO19(do_focus[19]), .DO20(do_focus[20]), .DO21(do_focus[21]), .DO22(do_focus[22]), 
//                      .DO23(do_focus[23]), .DO24(do_focus[24]), .DO25(do_focus[25]), .DO26(do_focus[26]), .DO27(do_focus[27]), .DO28(do_focus[28]), .DO29(do_focus[29]), .DO30(do_focus[30]), 
//                      .DO31(do_focus[31]), .DO32(do_focus[32]), .DO33(do_focus[33]), .DO34(do_focus[34]), .DO35(do_focus[35]), .DO36(do_focus[36]), .DO37(do_focus[37]), .DO38(do_focus[38]), 
//                      .DO39(do_focus[39]), .DO40(do_focus[40]), .DO41(do_focus[41]), .DO42(do_focus[42]), .DO43(do_focus[43]), .DO44(do_focus[44]), .DO45(do_focus[45]), .DO46(do_focus[46]), 
//                      .DO47(do_focus[47]),
//                      .DI0(di_focus[0]), .DI1(di_focus[1]), .DI2(di_focus[2]), .DI3(di_focus[3]), .DI4(di_focus[4]), .DI5(di_focus[5]), .DI6(di_focus[6]), .DI7(di_focus[7]), .DI8(di_focus[8]), 
//                      .DI9(di_focus[9]), .DI10(di_focus[10]), .DI11(di_focus[11]), .DI12(di_focus[12]), .DI13(di_focus[13]), .DI14(di_focus[14]), .DI15(di_focus[15]), .DI16(di_focus[16]), .DI17(di_focus[17]), 
//                      .DI18(di_focus[18]), .DI19(di_focus[19]), .DI20(di_focus[20]), .DI21(di_focus[21]), .DI22(di_focus[22]), .DI23(di_focus[23]), .DI24(di_focus[24]), .DI25(di_focus[25]), 
//                      .DI26(di_focus[26]), .DI27(di_focus[27]), .DI28(di_focus[28]), .DI29(di_focus[29]), .DI30(di_focus[30]), .DI31(di_focus[31]), .DI32(di_focus[32]), .DI33(di_focus[33]), 
//                      .DI34(di_focus[34]), .DI35(di_focus[35]), .DI36(di_focus[36]), .DI37(di_focus[37]), .DI38(di_focus[38]), .DI39(di_focus[39]), .DI40(di_focus[40]), .DI41(di_focus[41]), 
//                      .DI42(di_focus[42]), .DI43(di_focus[43]), .DI44(di_focus[44]), .DI45(di_focus[45]), .DI46(di_focus[46]), .DI47(di_focus[47]), .CK(clk), .WEB(wen_focus), .OE(1'b1), .CS(1'b1));

// //SRAM_EXPOSURE
// SUMA180_432X44X1BM1 EXPOSURE_SRAM(.A0(addr_exposure[0]), .A1(addr_exposure[1]), .A2(addr_exposure[2]), .A3(addr_exposure[3]), .A4(addr_exposure[4]), .A5(addr_exposure[5]), .A6(addr_exposure[6]), .A7(addr_exposure[7]), .A8(addr_exposure[8]),
//                      .DO0(do_exposure[0]), .DO1(do_exposure[1]), .DO2(do_exposure[2]), .DO3(do_exposure[3]), .DO4(do_exposure[4]), .DO5(do_exposure[5]), .DO6(do_exposure[6]), .DO7(do_exposure[7]), .DO8(do_exposure[8]), .DO9(do_exposure[9]), .DO10(do_exposure[10]),
//                      .DO11(do_exposure[11]), .DO12(do_exposure[12]), .DO13(do_exposure[13]), .DO14(do_exposure[14]), 
//                      .DO15(do_exposure[15]), .DO16(do_exposure[16]), .DO17(do_exposure[17]), .DO18(do_exposure[18]), .DO19(do_exposure[19]), .DO20(do_exposure[20]), .DO21(do_exposure[21]), .DO22(do_exposure[22]), 
//                      .DO23(do_exposure[23]), .DO24(do_exposure[24]), .DO25(do_exposure[25]), .DO26(do_exposure[26]), .DO27(do_exposure[27]), .DO28(do_exposure[28]), .DO29(do_exposure[29]), .DO30(do_exposure[30]), 
//                      .DO31(do_exposure[31]), .DO32(do_exposure[32]), .DO33(do_exposure[33]), .DO34(do_exposure[34]), .DO35(do_exposure[35]), .DO36(do_exposure[36]), .DO37(do_exposure[37]), .DO38(do_exposure[38]), 
//                      .DO39(do_exposure[39]), .DO40(do_exposure[40]), .DO41(do_exposure[41]), .DO42(do_exposure[42]), .DO43(do_exposure[43]),
//                      .DI0(di_exposure[0]), .DI1(di_exposure[1]), .DI2(di_exposure[2]), .DI3(di_exposure[3]), 
//                      .DI4(di_exposure[4]), .DI5(di_exposure[5]), .DI6(di_exposure[6]), .DI7(di_exposure[7]), .DI8(di_exposure[8]), .DI9(di_exposure[9]), .DI10(di_exposure[10]), .DI11(di_exposure[11]), .DI12(di_exposure[12]), .DI13(di_exposure[13]), 
//                      .DI14(di_exposure[14]), .DI15(di_exposure[15]), .DI16(di_exposure[16]), .DI17(di_exposure[17]), .DI18(di_exposure[18]), .DI19(di_exposure[19]), .DI20(di_exposure[20]), .DI21(di_exposure[21]), 
//                      .DI22(di_exposure[22]), .DI23(di_exposure[23]), .DI24(di_exposure[24]), .DI25(di_exposure[25]), .DI26(di_exposure[26]), .DI27(di_exposure[27]), .DI28(di_exposure[28]), .DI29(di_exposure[29]), 
//                      .DI30(di_exposure[30]), .DI31(di_exposure[31]), .DI32(di_exposure[32]), .DI33(di_exposure[33]), .DI34(di_exposure[34]), .DI35(di_exposure[35]), .DI36(di_exposure[36]), .DI37(di_exposure[37]), 
//                      .DI38(di_exposure[38]), .DI39(di_exposure[39]), .DI40(di_exposure[40]), .DI41(di_exposure[41]), .DI42(di_exposure[42]), .DI43(di_exposure[43]),
//                      .CK(clk), .WEB(wen_exposure), .OE(1'b1), .CS(1'b1));

// // INI_TABLE TTT(.din(rdata_s_inf_reg), .ori_full_cnt(full_buffer[img_cnt][rgb_cnt]), .ori_table(table_temp), .new_full_cnt(new_full_cnt), .new_table(initial_table_out));//'b11111111111_01010101010_11001100110_11111111111_01010101010_11001100110





// wire [10:0] ori_sum [0:7][0:7];

// generate
//     for(a=0; a<8; a=a+1) begin
//         for(b=0; b<(a+1); b=b+1) begin
//             assign ori_sum[a][b] = table_temp[(((((1+(a))*a)/2) + b) * 11) +: 11];
//         end
//     end
// endgenerate

// // wire [7:0] dram_data [0:15];
// generate
//     for(a=0; a<16; a=a+1) begin
//         assign dram_data[a] = rdata_s_inf_reg[((8*a)+7) : 8*a];
//     end
// endgenerate

// wire [3:0] data_classification [0:15];
// // wire [15:0] full_detect;
// // wire [3:0] full_cnt;
// // assign full_cnt = full_detect[0] + full_detect[1] + full_detect[2] + full_detect[3] + full_detect[4] + full_detect[5] + full_detect[6] + full_detect[7] + full_detect[8] + full_detect[9] + full_detect[10] + full_detect[11] + full_detect[12] + full_detect[13] + full_detect[14] + full_detect[15];
// // assign new_full_cnt = full_buffer[img_cnt][rgb_cnt] + full_cnt;

// // generate
// //     for(a=0; a<16; a=a+1) begin
// //         CLASSIFY CCC(.in_data(dram_data[a]), .level(data_classification[a]));
// //     end
// // endgenerate

// wire [10:0] refresh_sum [0:7][0:7];
// // wire [4:0] partial_sum [0:15][0:7][0:7];
// // generate
// //     assign partial_sum[0][0][0] = (data_classification[0]==0) ? 1: 0;
// //     for(a=0; a<=1; a=a+1) assign partial_sum[0][1][a] = (data_classification[0]==1) ? dram_data[0][a] : 0;
// //     for(a=0; a<=2; a=a+1) assign partial_sum[0][2][a] = (data_classification[0]==2) ? dram_data[0][a] : 0;
// //     for(a=0; a<=3; a=a+1) assign partial_sum[0][3][a] = (data_classification[0]==3) ? dram_data[0][a] : 0;
// //     for(a=0; a<=4; a=a+1) assign partial_sum[0][4][a] = (data_classification[0]==4) ? dram_data[0][a] : 0;
// //     for(a=0; a<=5; a=a+1) assign partial_sum[0][5][a] = (data_classification[0]==5) ? dram_data[0][a] : 0;
// //     for(a=0; a<=6; a=a+1) assign partial_sum[0][6][a] = (data_classification[0]==6) ? dram_data[0][a] : 0;
// //     for(a=0; a<=7; a=a+1) assign partial_sum[0][7][a] = (data_classification[0]==7) ? dram_data[0][a] : 0;
// //     for(a=1; a<16; a=a+1) begin
// //         assign partial_sum[a][0][0] = (data_classification[a]==0) ? partial_sum[a-1][0][0] + dram_data[a] : partial_sum[a-1][0][0];
// //         for(b=0; b<= 1; b=b+1) assign partial_sum[a][1][b] = (data_classification[a]==1) ?  partial_sum[a-1][1][b] + dram_data[a][b]: partial_sum[a-1][1][b];
// //         for(b=0; b<= 2; b=b+1) assign partial_sum[a][2][b] = (data_classification[a]==2) ?  partial_sum[a-1][2][b] + dram_data[a][b]: partial_sum[a-1][2][b];
// //         for(b=0; b<= 3; b=b+1) assign partial_sum[a][3][b] = (data_classification[a]==3) ?  partial_sum[a-1][3][b] + dram_data[a][b]: partial_sum[a-1][3][b];
// //         for(b=0; b<= 4; b=b+1) assign partial_sum[a][4][b] = (data_classification[a]==4) ?  partial_sum[a-1][4][b] + dram_data[a][b]: partial_sum[a-1][4][b];
// //         for(b=0; b<= 5; b=b+1) assign partial_sum[a][5][b] = (data_classification[a]==5) ?  partial_sum[a-1][5][b] + dram_data[a][b]: partial_sum[a-1][5][b];
// //         for(b=0; b<= 6; b=b+1) assign partial_sum[a][6][b] = (data_classification[a]==6) ?  partial_sum[a-1][6][b] + dram_data[a][b]: partial_sum[a-1][6][b];
// //         for(b=0; b<= 7; b=b+1) assign partial_sum[a][7][b] = (data_classification[a]==7) ?  partial_sum[a-1][7][b] + dram_data[a][b]: partial_sum[a-1][7][b];
// //     end
// // endgenerate

// reg [4:0] partial_sum [0:7][0:7];
// reg [4:0] partial_sum_reg [0:7][0:7];
// generate
//     for(a=0; a<8; a=a+1) begin
//         for(b=0; b<8; b=b+1) begin
//             always @(posedge clk ) begin
//                 partial_sum_reg[a][b] <= partial_sum[a][b];
//             end
//         end
//     end
// endgenerate




// // generate
// //     assign refresh_sum[0][0] = ori_sum[0][0] + partial_sum[0][0];
// //     for(b=0; b<= 1; b=b+1) assign refresh_sum[1][b] = ori_sum[1][b] + partial_sum[1][b];
// //     for(b=0; b<= 2; b=b+1) assign refresh_sum[2][b] = ori_sum[2][b] + partial_sum[2][b];
// //     for(b=0; b<= 3; b=b+1) assign refresh_sum[3][b] = ori_sum[3][b] + partial_sum[3][b];
// //     for(b=0; b<= 4; b=b+1) assign refresh_sum[4][b] = ori_sum[4][b] + partial_sum[4][b];
// //     for(b=0; b<= 5; b=b+1) assign refresh_sum[5][b] = ori_sum[5][b] + partial_sum[5][b];
// //     for(b=0; b<= 6; b=b+1) assign refresh_sum[6][b] = ori_sum[6][b] + partial_sum[6][b];
// //     for(b=0; b<= 7; b=b+1) assign refresh_sum[7][b] = ori_sum[7][b] + partial_sum[7][b];
// // endgenerate

// // generate
// //     for(a=0; a<8; a=a+1) begin
// //         for(b=0; b<(a+1); b=b+1) begin
// //             assign initial_table_out[(((((1+(a))*a)/2) + b) * 11) +: 11] = refresh_sum[a][b];
// //         end
// //     end
// // endgenerate;

// reg [7:0] one_detect [0:15][0:7];


// generate
//     for(a=0; a<=15; a=a+1) begin
//         always @(*) begin
//             for(i=0; i<=7; i=i+1) begin//default
//                 one_detect[a][i] = 0;
//             end

//             if(dram_data[a][7]==1'b1) begin
//                 one_detect[a][7] = dram_data[a];
//             end
//             else if(dram_data[a][6]==1'b1) begin
//                 one_detect[a][6] = dram_data[a];
//             end
//             else if(dram_data[a][5]==1'b1) begin
//                 one_detect[a][5] = dram_data[a];
//             end
//             else if(dram_data[a][4]==1'b1) begin
//                 one_detect[a][4] = dram_data[a];
//             end
//             else if(dram_data[a][3]==1'b1) begin
//                 one_detect[a][3] = dram_data[a];
//             end
//             else if(dram_data[a][2]==1'b1) begin
//                 one_detect[a][2] = dram_data[a];
//             end
//             else if(dram_data[a][1]==1'b1) begin
//                 one_detect[a][1] = dram_data[a];
//             end
//             else if(dram_data[a][0]==1'b1) begin
//                 one_detect[a][0] = dram_data[a];
//             end
//         end
//     end
// endgenerate
// always@(*) begin
//         partial_sum[0][0] = ((one_detect[0][0][0] + one_detect[1][0][0]) + (one_detect[2][0][0] + one_detect[3][0][0])) + ((one_detect[4][0][0] + one_detect[5][0][0]) + (one_detect[6][0][0]+ one_detect[7][0][0])) + ((one_detect[8][0][0] + one_detect[9][0][0]) + (one_detect[10][0][0] + one_detect[11][0][0])) + ((one_detect[12][0][0] + one_detect[13][0][0]) + (one_detect[14][0][0] + one_detect[15][0][0]));
//     end
// generate
    
//     for(b=0; b<= 1; b=b+1)begin always @(*) begin  partial_sum[1][b] = (((one_detect[0][1][b] + one_detect[1][1][b]) + (one_detect[2][1][b] + one_detect[3][1][b])) + ((one_detect[4][1][b] + one_detect[5][1][b]) + (one_detect[6][1][b] + one_detect[7][1][b]))) + (((one_detect[8][1][b] + one_detect[9][1][b]) + (one_detect[10][1][b] + one_detect[11][1][b])) + ((one_detect[12][1][b] + one_detect[13][1][b]) + (one_detect[14][1][b] + one_detect[15][1][b])));end end
//     for(b=0; b<= 2; b=b+1)begin always @(*) begin  partial_sum[2][b] = (((one_detect[0][2][b] + one_detect[1][2][b]) + (one_detect[2][2][b] + one_detect[3][2][b])) + ((one_detect[4][2][b] + one_detect[5][2][b]) + (one_detect[6][2][b] + one_detect[7][2][b]))) + (((one_detect[8][2][b] + one_detect[9][2][b]) + (one_detect[10][2][b] + one_detect[11][2][b])) + ((one_detect[12][2][b] + one_detect[13][2][b]) + (one_detect[14][2][b] + one_detect[15][2][b])));end end
//     for(b=0; b<= 3; b=b+1)begin always @(*) begin  partial_sum[3][b] = (((one_detect[0][3][b] + one_detect[1][3][b]) + (one_detect[2][3][b] + one_detect[3][3][b])) + ((one_detect[4][3][b] + one_detect[5][3][b]) + (one_detect[6][3][b] + one_detect[7][3][b]))) + (((one_detect[8][3][b] + one_detect[9][3][b]) + (one_detect[10][3][b] + one_detect[11][3][b])) + ((one_detect[12][3][b] + one_detect[13][3][b]) + (one_detect[14][3][b] + one_detect[15][3][b])));end end
//     for(b=0; b<= 4; b=b+1)begin always @(*) begin  partial_sum[4][b] = (((one_detect[0][4][b] + one_detect[1][4][b]) + (one_detect[2][4][b] + one_detect[3][4][b])) + ((one_detect[4][4][b] + one_detect[5][4][b]) + (one_detect[6][4][b] + one_detect[7][4][b]))) + (((one_detect[8][4][b] + one_detect[9][4][b]) + (one_detect[10][4][b] + one_detect[11][4][b])) + ((one_detect[12][4][b] + one_detect[13][4][b]) + (one_detect[14][4][b] + one_detect[15][4][b])));end end
//     for(b=0; b<= 5; b=b+1)begin always @(*) begin  partial_sum[5][b] = (((one_detect[0][5][b] + one_detect[1][5][b]) + (one_detect[2][5][b] + one_detect[3][5][b])) + ((one_detect[4][5][b] + one_detect[5][5][b]) + (one_detect[6][5][b] + one_detect[7][5][b]))) + (((one_detect[8][5][b] + one_detect[9][5][b]) + (one_detect[10][5][b] + one_detect[11][5][b])) + ((one_detect[12][5][b] + one_detect[13][5][b]) + (one_detect[14][5][b] + one_detect[15][5][b])));end end
//     for(b=0; b<= 6; b=b+1)begin always @(*) begin  partial_sum[6][b] = (((one_detect[0][6][b] + one_detect[1][6][b]) + (one_detect[2][6][b] + one_detect[3][6][b])) + ((one_detect[4][6][b] + one_detect[5][6][b]) + (one_detect[6][6][b] + one_detect[7][6][b]))) + (((one_detect[8][6][b] + one_detect[9][6][b]) + (one_detect[10][6][b] + one_detect[11][6][b])) + ((one_detect[12][6][b] + one_detect[13][6][b]) + (one_detect[14][6][b] + one_detect[15][6][b])));end end
//     for(b=0; b<= 7; b=b+1)begin always @(*) begin  partial_sum[7][b] = (((one_detect[0][7][b] + one_detect[1][7][b]) + (one_detect[2][7][b] + one_detect[3][7][b])) + ((one_detect[4][7][b] + one_detect[5][7][b]) + (one_detect[6][7][b] + one_detect[7][7][b]))) + (((one_detect[8][7][b] + one_detect[9][7][b]) + (one_detect[10][7][b] + one_detect[11][7][b])) + ((one_detect[12][7][b] + one_detect[13][7][b]) + (one_detect[14][7][b] + one_detect[15][7][b])));end end
// endgenerate






// generate
//     for(a=0; a<18; a=a+1) begin
//         // for(b=0; b<2; b=b+1) begin
//             assign initial_table_out[22*a +: 22] = add22_out[a];
//         // end
//     end
// endgenerate;

 
// generate
//     for(a=0; a<18; a=a+1) begin
//         assign add22_out[a] = add22_in0[a] + add22_in1[a];
//     end
// endgenerate;


// always @(*) begin
//     // case (state)
//     //     EXPOSURE: begin
//     //         if(dram_read_cnt[0]!=0) n_sum = add22_out[13];
//     //         else n_sum = sum;
//     //     end
//     //     default: n_sum = 0;
//     // endcase
//     // if(state == EXPOSURE) begin
//     //     if(dram_read_cnt[0]!=0) n_sum = add22_out[13];
//     //     else n_sum = sum;
//     // end
//     // else n_sum = 0;
//     n_sum = add22_out[13];
// end


// always @(*) begin
//     for(i=0; i<18; i=i+1)begin
//         add22_in0[i] = 0;
//     end
//     case(state)
//         WAIT_DRAM_DATA, DRAM_ADDR, WAIT: begin
//             if(pixel_cnt!=1) begin
//                 add22_in0[0]  = {ori_sum[1][0], ori_sum[0][0]};
//                 add22_in0[1]  = {ori_sum[2][0], ori_sum[1][1]};
//                 add22_in0[2]  = {ori_sum[2][2], ori_sum[2][1]};
//                 add22_in0[3]  = {ori_sum[3][1], ori_sum[3][0]};
//                 add22_in0[4]  = {ori_sum[3][3], ori_sum[3][2]};
//                 add22_in0[5]  = {ori_sum[4][1], ori_sum[4][0]};
//                 add22_in0[6]  = {ori_sum[4][3], ori_sum[4][2]};
//                 add22_in0[7]  = {ori_sum[5][0], ori_sum[4][4]};
//                 add22_in0[8]  = {ori_sum[5][2], ori_sum[5][1]};
//                 add22_in0[9]  = {ori_sum[5][4], ori_sum[5][3]};
//                 add22_in0[10] = {ori_sum[6][0], ori_sum[5][5]};
//                 add22_in0[11] = {ori_sum[6][2], ori_sum[6][1]};
//                 add22_in0[12] = {ori_sum[6][4], ori_sum[6][3]};
//                 add22_in0[13] = {ori_sum[6][6], ori_sum[6][5]};
//                 add22_in0[14] = {ori_sum[7][1], ori_sum[7][0]};
//                 add22_in0[15] = {ori_sum[7][3], ori_sum[7][2]};
//                 add22_in0[16] = {ori_sum[7][5], ori_sum[7][4]};
//                 add22_in0[17] = {ori_sum[7][7], ori_sum[7][6]};
//             end
//             else begin
//                 add22_in0[0]  = 0;
//                 add22_in0[1]  = 0;
//                 add22_in0[2]  = 0;
//                 add22_in0[3]  = 0;
//                 add22_in0[4]  = 0;
//                 add22_in0[5]  = 0;
//                 add22_in0[6]  = 0;
//                 add22_in0[7]  = 0;
//                 add22_in0[8]  = 0;
//                 add22_in0[9]  = 0;
//                 add22_in0[10] = 0;
//                 add22_in0[11] = 0;
//                 add22_in0[12] = 0;
//                 add22_in0[13] = 0;
//                 add22_in0[14] = 0;
//                 add22_in0[15] = 0;
//                 add22_in0[16] = 0;
//                 add22_in0[17] = 0;
//             end
            

//         end
//         EXPOSURE: begin
//             add22_in0[0]  = {g_exposure_buffer[6][`index1], g_exposure_buffer[6][`index0]};
//             add22_in0[1]  = {g_exposure_buffer[6][`index3], g_exposure_buffer[6][`index2]};
//             add22_in0[2]  = {g_exposure_buffer[7][`index1], g_exposure_buffer[7][`index0]};
//             add22_in0[3]  = {g_exposure_buffer[7][`index3], g_exposure_buffer[7][`index2]};


//             add22_in0[6] = add22_out[4];
//             add22_in0[9] = add22_out[7];
//             add22_in0[12] = add22_out[10];
//             //r_add
//             case(pixel_cnt)
//                 // 8:begin//0
//                 //     add22_in0[4] = r_exposure_buffer[0][`index0];
//                 //     add22_in0[5] = r_exposure_buffer[0][`index1];
//                 //     
//                 // end
//                 0:begin//1
//                     add22_in0[4] = 0;
//                     add22_in0[5] = g_exposure_buffer[0][`index1];
//                 end
//                 1:begin//2
//                     add22_in0[4] = g_exposure_buffer[0][`index0];
//                     add22_in0[5] = g_exposure_buffer[0][`index1] << 1;//////////////////////
//                 end
//                 2:begin//3
//                     add22_in0[4] = g_exposure_buffer[0][`index0];
//                     add22_in0[5] = g_exposure_buffer[0][`index1] << 1;
//                 end
//                 3:begin//4
//                     add22_in0[4] = 0;
//                     add22_in0[5] = g_exposure_buffer[0][`index1];
//                 end
//                 4:begin//5
//                     add22_in0[4] = g_exposure_buffer[0][`index0] << 3;
//                     add22_in0[5] = 0;
//                 end
//                 5:begin//6
//                     add22_in0[4] = g_exposure_buffer[0][`index0] << 1;
//                     add22_in0[5] = g_exposure_buffer[0][`index1] << 2;
//                 end
//                 6:begin//7
//                     add22_in0[4] = 0;
//                     add22_in0[5] = 0;
//                 end
//                 7:begin
//                     add22_in0[4] = g_exposure_buffer[0][`index0] << 2;
//                     add22_in0[5] = g_exposure_buffer[0][`index1] << 3;
//                 end
//             endcase
//             //g_add
//             case(pixel_cnt)
//                 8:begin
//                     add22_in0[7] = 0;
//                     add22_in0[8] = 0;
//                 end
//                 0:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0];
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 1;
//                 end
//                 1:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0] << 1;
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 2;
//                 end
//                 2:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0] << 1;
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 2; 
//                 end
//                 3:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0];
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 1;
//                 end
//                 4:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0] << 4;
//                     add22_in0[8] = 0;
//                 end
//                 5:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0] << 2;
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 3;
//                 end
//                 6:begin
//                     add22_in0[7] = 0;
//                     add22_in0[8] = g_exposure_buffer[0][`index1];
//                 end
//                 7:begin
//                     add22_in0[7] = g_exposure_buffer[0][`index0] << 3;
//                     add22_in0[8] = g_exposure_buffer[0][`index1] << 4;
//                 end
//             endcase
//             add22_in0[13] = sum;
//         end
//         FOCUS: begin
//             case(rgb_cnt)
//                 2: begin
//                     case(focus_cnt)
//                         2:begin
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         3:begin
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         4:begin
//                             add22_in0[14] = partial_sum_2x2;
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         5:begin
//                             add22_in0[14] = partial_sum_2x2;
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
                         
//                     endcase
//                 end
//                 3:begin
//                     case(focus_cnt)
//                         0:begin
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end
//                         1:begin
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         7:begin
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         2:begin
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         3:begin
//                             add22_in0[14] = partial_sum_2x2;
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         4:begin
//                             add22_in0[14] = partial_sum_2x2;
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         5:begin
//                             add22_in0[15] = partial_sum_4x4;
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                         6:begin
//                             add22_in0[16] = partial_sum_6x6;
//                         end 
//                     endcase
//                 end
//             endcase

//         end
//         Avg_Min_Max: begin
//             case(img_cnt)
//                 0:begin
//                     add22_in0[0] = max_rgb[in_pic_no_reg][0];
//                     add22_in0[1] = min_rgb[in_pic_no_reg][0];
//                 end
//                 1:begin
//                     add22_in0[0] = amm_max_reg;
//                     add22_in0[1] = amm_min_reg;
//                 end
//                 4:begin
//                     add22_in0[0] = amm_max_reg;
//                 end
//             endcase
//         end
//     endcase
// end

// always @(*) begin
//     for(i=0; i<18; i=i+1)begin
//         add22_in1[i] = 0;
//     end
//     case(state)
//         WAIT_DRAM_DATA, DRAM_ADDR, WAIT: begin
//             // if(pixel_cnt!=1) begin
//                 add22_in1[0]  = {6'b000000, partial_sum_reg[1][0], 6'b000000, partial_sum_reg[0][0]};
//                 add22_in1[1]  = {6'b000000, partial_sum_reg[2][0], 6'b000000, partial_sum_reg[1][1]};
//                 add22_in1[2]  = {6'b000000, partial_sum_reg[2][2], 6'b000000, partial_sum_reg[2][1]};
//                 add22_in1[3]  = {6'b000000, partial_sum_reg[3][1], 6'b000000, partial_sum_reg[3][0]};
//                 add22_in1[4]  = {6'b000000, partial_sum_reg[3][3], 6'b000000, partial_sum_reg[3][2]};
//                 add22_in1[5]  = {6'b000000, partial_sum_reg[4][1], 6'b000000, partial_sum_reg[4][0]};
//                 add22_in1[6]  = {6'b000000, partial_sum_reg[4][3], 6'b000000, partial_sum_reg[4][2]};
//                 add22_in1[7]  = {6'b000000, partial_sum_reg[5][0], 6'b000000, partial_sum_reg[4][4]};
//                 add22_in1[8]  = {6'b000000, partial_sum_reg[5][2], 6'b000000, partial_sum_reg[5][1]};
//                 add22_in1[9]  = {6'b000000, partial_sum_reg[5][4], 6'b000000, partial_sum_reg[5][3]};
//                 add22_in1[10] = {6'b000000, partial_sum_reg[6][0], 6'b000000, partial_sum_reg[5][5]};
//                 add22_in1[11] = {6'b000000, partial_sum_reg[6][2], 6'b000000, partial_sum_reg[6][1]};
//                 add22_in1[12] = {6'b000000, partial_sum_reg[6][4], 6'b000000, partial_sum_reg[6][3]};
//                 add22_in1[13] = {6'b000000, partial_sum_reg[6][6], 6'b000000, partial_sum_reg[6][5]};
//                 add22_in1[14] = {6'b000000, partial_sum_reg[7][1], 6'b000000, partial_sum_reg[7][0]};
//                 add22_in1[15] = {6'b000000, partial_sum_reg[7][3], 6'b000000, partial_sum_reg[7][2]};
//                 add22_in1[16] = {6'b000000, partial_sum_reg[7][5], 6'b000000, partial_sum_reg[7][4]};
//                 add22_in1[17] = {6'b000000, partial_sum_reg[7][7], 6'b000000, partial_sum_reg[7][6]};
//             // end
//             // else begin
//             //     add22_in1[0]  = 0;
//             //     add22_in1[1]  = 0;
//             //     add22_in1[2]  = 0;
//             //     add22_in1[3]  = 0;
//             //     add22_in1[4]  = 0;
//             //     add22_in1[5]  = 0;
//             //     add22_in1[6]  = 0;
//             //     add22_in1[7]  = 0;
//             //     add22_in1[8]  = 0;
//             //     add22_in1[9]  = 0;
//             //     add22_in1[10] = 0;
//             //     add22_in1[11] = 0;
//             //     add22_in1[12] = 0;
//             //     add22_in1[13] = 0;
//             //     add22_in1[14] = 0;
//             //     add22_in1[15] = 0;
//             //     add22_in1[16] = 0;
//             //     add22_in1[17] = 0;
//             // end
            
//         end
//         EXPOSURE: begin
//             add22_in1[0]  = {r_exposure_buffer[8][`index3], r_exposure_buffer[8][`index3]};
//             add22_in1[1]  = {r_exposure_buffer[8][`index3], r_exposure_buffer[8][`index3]};
//             add22_in1[2]  = {r_exposure_buffer[8][`index3], r_exposure_buffer[8][`index3]};
//             add22_in1[3]  = {r_exposure_buffer[8][`index3], r_exposure_buffer[8][`index3]};

//             add22_in1[6] = add22_out[5];
//             add22_in1[9] = add22_out[8];
//             add22_in1[12] = add22_out[11];
//             //r_add
//             case(pixel_cnt)
//                 // 8:begin//0
//                 //     add22_in1[4] = r_exposure_buffer[0][`index2];
//                 //     add22_in1[5] = r_exposure_buffer[0][`index3];
//                 //     
//                 // end
//                 0:begin//1
//                     add22_in1[4] = 0;
//                     add22_in1[5] = 0;
//                 end
//                 1:begin//2
//                     add22_in1[4] = 0;
//                     add22_in1[5] = 0;
//                 end
//                 2:begin//3
//                     add22_in1[4] = g_exposure_buffer[0][`index2] << 2;
//                     add22_in1[5] = 0;
//                 end
//                 3:begin//4
//                     add22_in1[4] = g_exposure_buffer[0][`index2] << 1;
//                     add22_in1[5] = g_exposure_buffer[0][`index3] << 2;
//                 end
//                 4:begin//5
//                     add22_in1[4] = 0;
//                     add22_in1[5] = g_exposure_buffer[0][`index3];
//                 end
//                 5:begin//6
//                     add22_in1[4] = g_exposure_buffer[0][`index2] << 3;
//                     add22_in1[5] = g_exposure_buffer[0][`index3] << 4;
//                 end
//                 6:begin//7
//                     add22_in1[4] = g_exposure_buffer[0][`index2];
//                     add22_in1[5] = g_exposure_buffer[0][`index3] << 1;
//                 end
//                 7:begin
//                     add22_in1[4] = g_exposure_buffer[0][`index2] << 4;
//                     add22_in1[5] = g_exposure_buffer[0][`index3] << 5;
//                 end
//             endcase
//             //g_add
//             case(pixel_cnt)
//                 8:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2];
//                     add22_in1[8] = 0;
//                 end
//                 0:begin
//                     add22_in1[7] = 0;
//                     add22_in1[8] = g_exposure_buffer[0][`index3];
//                 end
//                 1:begin
//                     add22_in1[7] = 0;
//                     add22_in1[8] = g_exposure_buffer[0][`index3];
//                 end
//                 2:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2] << 3;
//                     add22_in1[8] = 0;
//                 end
//                 3:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2] << 2;
//                     add22_in1[8] = g_exposure_buffer[0][`index3] << 3;
//                 end
//                 4:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2];
//                     add22_in1[8] = g_exposure_buffer[0][`index3] << 1;
//                 end
//                 5:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2] << 4;
//                     add22_in1[8] = g_exposure_buffer[0][`index3] << 5;
//                 end
//                 6:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2] << 1;
//                     add22_in1[8] = g_exposure_buffer[0][`index3] << 2;
//                 end
//                 7:begin
//                     add22_in1[7] = g_exposure_buffer[0][`index2] << 5;
//                     add22_in1[8] = g_exposure_buffer[0][`index3] << 6;
//                 end
//             endcase

//             // if(dram_read_cnt != 0) begin
//             //     // case (img_cnt)
//             //     //     1: add22_in1[13] = add22_out[6];
//             //     //     2: add22_in1[13] = add22_out[9];
//             //     //     // 3: add22_in1[13] = add22_out[12];
//             //     //     3: add22_in1[13] = add22_out[6];
//             //     //     default: add22_in1[13] = 0;
//             //     // endcase
//             //     case (img_cnt[0])
//             //         1: add22_in1[13] = add22_out[6];
//             //         0: add22_in1[13] = add22_out[9];
//             //         // 3: add22_in1[13] = add22_out[12];
//             //         // 3: add22_in1[13] = add22_out[6];
//             //         default: add22_in1[13] = 0;
//             //     endcase
//             // end
//             add22_in1[13] = exposure_partial_sum;



//         end
//         FOCUS: begin
//             add22_in1[14] = sum_2x2;
//             add22_in1[15] = sum_4x4;
//             add22_in1[16] = sum_6x6;
//         end
//         Avg_Min_Max: begin
//             case(img_cnt)
//                 0:begin
//                     add22_in1[0] = max_rgb[in_pic_no_reg][1];
//                     add22_in1[1] = min_rgb[in_pic_no_reg][1];
//                 end
//                 1:begin
//                     add22_in1[0] = max_rgb[in_pic_no_reg][2];
//                     add22_in1[1] = min_rgb[in_pic_no_reg][2];
//                 end
//                 4:begin
//                     add22_in1[0] = amm_min_reg;
//                 end
//             endcase
//         end
//     endcase
// end



// always @(posedge clk ) begin
//     exposure_partial_sum <= (dram_read_cnt != 0) ? ((img_cnt[0]) ? add22_out[6][17:0] : add22_out[9][17:0]) : 0;
// end


// reg [7:0] buffer [0:5][0:5];
// reg [7:0] n_buffer [0:5][0:5];

// reg [7:0] in_shift [0:5];



// always @(*) begin
//     for(i=0; i<6; i=i+1) begin
//         if(focus_enable) begin
//             if(rgb_cnt!=1) begin
//                 in_shift[i] = do_focus_reg[(i*8)+2 +: 6];
//             end
//             else begin
//                 in_shift[i] = do_focus_reg[(i*8)+1 +: 7];
//             end
//         end
//         else if(in_mode_reg == 1) begin
//             case(in_ratio_mode_reg)
//                 0:begin//0.25
//                     in_shift[i] = do_focus_reg[(i*8)+2 +: 6];
//                 end
//                 1:begin//0.5
//                     in_shift[i] = do_focus_reg[(i*8)+1 +: 7];
//                 end
//                 2:begin//1
//                     in_shift[i] = do_focus_reg[i*8 +: 8];
//                 end
//                 3:begin//2
//                     in_shift[i] = (do_focus_reg[i*8+7]==1) ? 255 : {do_focus_reg[(i*8) +: 7], 1'b0};
//                 end
//             endcase
//         end
//         else in_shift[i] = 0;
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         for(i=0; i<6; i=i+1)begin
//             for(j=0; j<6; j=j+1)begin
//                 buffer[i][j] <= 0;
//             end
//         end
//     end
//     else begin
//         for(i=0; i<6; i=i+1)begin
//             for(j=0; j<6; j=j+1)begin
//                 buffer[i][j] <= n_buffer[i][j];
//             end
//         end
//     end
// end


// always @(*) begin
//     for(i=0; i<6; i=i+1)begin
//         for(j=0; j<6; j=j+1)begin
//             n_buffer[i][j] = buffer[i][j];
//         end
//     end
//     if(rgb_cnt != 3) begin
//         if(focus_enable) begin
//             for(j=0; j<6; j=j+1)begin
//                 n_buffer[5][j] = buffer[0][j] + in_shift[j];
//             end
//             for(i=0; i<5; i=i+1)begin
//                 for(j=0; j<6; j=j+1)begin
//                     n_buffer[i][j] = buffer[i+1][j];
//                 end
//             end
//         end
//         else if(in_mode_reg) begin
//             for(j=0; j<6; j=j+1)begin
//                 n_buffer[5][j] = in_shift[j];
//             end
//             for(i=0; i<5; i=i+1)begin
//                 for(j=0; j<6; j=j+1)begin
//                     n_buffer[i][j] = buffer[i+1][j];
//                 end
//             end
//         end
//         else begin
//             for(i=0; i<6; i=i+1)begin
//                 for(j=0; j<6; j=j+1)begin
//                     n_buffer[i][j] = 0;
//                 end
//             end
//         end 
//     end

//     else begin
//         for(j=0; j<6; j=j+1)begin
//             n_buffer[j][5] = buffer[j][0];
//         end
//         for(i=0; i<5; i=i+1)begin
//             for(j=0; j<6; j=j+1)begin
//                 n_buffer[j][i] = buffer[j][i+1];
//             end
//         end
//     end
// end

// always @(*) begin
//     do_ratio_data = {buffer[2][5], buffer[2][4], buffer[2][3], buffer[2][2], buffer[2][1], buffer[2][0]};
// end

// reg [7:0] sub_abs_in0 [0:4];
// reg [7:0] sub_abs_in1 [0:4];
// wire [7:0] sub_abs_out [0:4];

// generate
//     for(a=0;a<5; a=a+1) begin
//         always @(*) begin
//             if((rgb_cnt==2) || (rgb_cnt==3 && focus_cnt==0)) begin
//                 sub_abs_in0[a] = buffer[5][a];
//                 sub_abs_in1[a] = buffer[5][a+1];
//             end
//             else begin
//                 // case(focus_cnt)
//                 //     1:begin
//                 //         sub_abs_in0[a] = buffer[a][0];
//                 //         sub_abs_in1[a] = buffer[a+1][0];
//                 //     end
//                 //     2:begin
//                 //         sub_abs_in0[a] = buffer[a][1];
//                 //         sub_abs_in1[a] = buffer[a+1][1];
//                 //     end
//                 //     3:begin
//                 //         sub_abs_in0[a] = buffer[a][2];
//                 //         sub_abs_in1[a] = buffer[a+1][2];
//                 //     end
//                 //     4:begin
//                 //         sub_abs_in0[a] = buffer[a][3];
//                 //         sub_abs_in1[a] = buffer[a+1][3];
//                 //     end
//                 //     5:begin
//                 //         sub_abs_in0[a] = buffer[a][4];
//                 //         sub_abs_in1[a] = buffer[a+1][4];
//                 //     end
//                 //     6:begin
//                 //         sub_abs_in0[a] = buffer[a][5];
//                 //         sub_abs_in1[a] = buffer[a+1][5];
//                 //     end
//                 //     default:begin
//                 //         sub_abs_in0[a] = 0;
//                 //         sub_abs_in1[a] = 0;
//                 //     end
//                 // endcase
//                 sub_abs_in0[a] = buffer[a][0];
//                 sub_abs_in1[a] = buffer[a+1][0];
//             end
//         end
//     end
// endgenerate

// generate
//     for(a=0; a<5; a=a+1) begin
//         SUB_w_ABS YM(.clk(clk), .in0(sub_abs_in0[a]), .in1(sub_abs_in1[a]), .out(sub_abs_out[a]));
//     end    
// endgenerate



// assign partial_sum_2x2 = sub_abs_out[2];
// assign partial_sum_4x4 = sub_abs_out[1] + sub_abs_out[2] + sub_abs_out[3];
// assign partial_sum_6x6 = partial_sum_4x4 + (sub_abs_out[0] + sub_abs_out[4]);

// always @(*) begin
//     // if((rgb_cnt==2 && focus_cnt != 0) || (rgb_cnt==3)) begin
//     //     n_sum_2x2 = add22_out[14];
//     //     n_sum_4x4 = add22_out[15];
//     //     n_sum_6x6 = add22_out[16];
//     // end
//     if(focus_enable) begin
//         n_sum_2x2 = add22_out[14];
//         n_sum_4x4 = add22_out[15];
//         n_sum_6x6 = add22_out[16];
//     end
//     else begin
//         n_sum_2x2 = 0;
//         n_sum_4x4 = 0;
//         n_sum_6x6 = 0;
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         sum_6x6 <= 0;
//         sum_4x4 <= 0;
//         sum_2x2 <= 0;
//     end
//     else begin
//         sum_2x2 <= n_sum_2x2;
//         sum_4x4 <= n_sum_4x4;
//         sum_6x6 <= n_sum_6x6;
//     end
// end

// // reg [9:0]   sum_2x2_reg;
// // reg [12:0]  sum_4x4_reg;
// // reg [13:0]  sum_6x6_reg;

// // always @(posedge clk) begin
// //     sum_2x2_reg <= sum_2x2 >> 2;
// //     sum_4x4_reg <= sum_4x4 >> 4;
// //     sum_6x6_reg <= (sum_6x6 >> 2) / 9;
// // end




// wire [1:0] cmp_out;
// wire[13:0] cmp_in0 =  sum_2x2 >> 2;
// wire [12:0] cmp_in1 = sum_4x4 >> 4;
// // wire [13:0] cmp_in2 = (sum_6x6 >> 2) / 9;

// // wire [11:0] div_in0;
// // wire [3:0] div_in1;
// // wire [11:0] div_out;
// // assign div_out = div_in0 / div_in1;
// // always @(*) begin
// //     if(state == Avg_Min_Max) begin
// //         if(img_cnt == 1) div_in0 = amm_max_reg;
// //         else div_in0 = amm_min_reg;
// //     end
// //     else begin
// //         div_in0 = sum_6x6 >> 2;
// //     end
// // end

// // assign div_in1 = (state == Avg_Min_Max) ? 3 : 9;


// wire [13:0] cmp_in2 = div_out;

// CMP3 YM(.in0(cmp_in0), .in1(cmp_in1), .in2(cmp_in2), .out_index(cmp_out));


// always @(posedge clk) begin
//     focus_result <= cmp_out;
// end

// endmodule


// module CMP3(in0, in1,in2, out_index);
//     input [13:0] in0;
//     input [12:0] in1;
//     input [13:0] in2;
//     output [1:0] out_index;

//     wire [13:0] temp = (in0 >= in1) ? in0 : in1;
//     wire [13:0]  big = (temp >= in2) ? temp : in2;
//     assign out_index = (big == in0) ? 0 : (big == in1) ? 1 : 2;



// endmodule


// module SUB_w_ABS(clk,in0,in1,out);
//     input clk;
//     input [7:0] in0,in1;
//     output reg [7:0] out;
//     // wire [7:0] temp = in0 - in1;
//     // assign out = (temp[7] == 1'b1)? ~temp + 1 : temp;
//     wire [7:0] big = (in0 > in1) ? in0 : in1;
//     wire [7:0] little = (in0 > in1) ? in1 : in0;
//     wire [7:0] out_temp = big - little;

//     always @(posedge clk ) begin
//         out <= out_temp;
//     end
//     // always @(* ) begin
//     //     out = out_temp;
//     // end
// endmodule




// // module CLASSIFY(in_data, level);
// //     input [7:0] in_data;
// //     output [3:0] level;
// //     // genvar i;

// //     reg [3:0] level_temp;
// //     always @(*) begin
// //         if(in_data[7]==1'b1) level_temp = 7;
// //         else if(in_data[6]==1'b1) level_temp = 6;
// //         else if(in_data[5]==1'b1) level_temp = 5;
// //         else if(in_data[4]==1'b1) level_temp = 4;
// //         else if(in_data[3]==1'b1) level_temp = 3;
// //         else if(in_data[2]==1'b1) level_temp = 2;
// //         else if(in_data[1]==1'b1) level_temp = 1;
// //         else if(in_data[0]==1'b1) level_temp = 0;
// //         else level_temp = 8; //in_data==0
// //     end
// //     // assign level = full ? 9 : level_temp;//9:full
// //     assign level = level_temp;
// // endmodule



// module Find_Max (
//     clk,
//     max_temp,
//     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
//     max
// );
//     input clk;
//     input [7:0] max_temp;
//     input [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
//     output [7:0] max;

//     wire [7:0] temp0 = (in0 > in1) ? in0 : in1;
//     wire [7:0] temp1 = (in2 > in3) ? in2 : in3;
//     wire [7:0] temp2 = (in4 > in5) ? in4 : in5;
//     wire [7:0] temp3 = (in6 > in7) ? in6 : in7;
//     wire [7:0] temp4 = (in8 > in9) ? in8 : in9;
//     wire [7:0] temp5 = (in10 > in11) ? in10 : in11;
//     wire [7:0] temp6 = (in12 > in13) ? in12 : in13;
//     wire [7:0] temp7 = (in14 > in15) ? in14 : in15;

//     wire [7:0] temp8 = (temp0 > temp1) ? temp0 : temp1;
//     wire [7:0] temp9 = (temp2 > temp3) ? temp2 : temp3;
//     wire [7:0] temp10 = (temp4 > temp5) ? temp4 : temp5;
//     wire [7:0] temp11 = (temp6 > temp7) ? temp6 : temp7;

//     reg [7:0] temp8_reg, temp9_reg, temp10_reg, temp11_reg, max_temp_reg;
//     always @(posedge clk) begin
//         temp8_reg <= temp8;
//         temp9_reg <= temp9;
//         temp10_reg <= temp10;
//         temp11_reg <= temp11;
//         // max_temp_reg <= max_temp;
//     end

//     wire [7:0] temp12 = (temp8_reg > temp9_reg) ? temp8_reg : temp9_reg;
//     wire [7:0] temp13 = (temp10_reg > temp11_reg) ? temp10_reg : temp11_reg;

//     wire [7:0] temp14 = (temp12 > temp13) ? temp12 : temp13;

//     assign max = (temp14 > max_temp) ? temp14 : max_temp;
// endmodule


// module Find_Min (
//     clk,
//     min_temp,
//     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
//     min
// );
//     input clk;
//     input [7:0] min_temp;
//     input [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
//     output [7:0] min;

//     wire [7:0] temp0 = (in0 < in1) ? in0 : in1; 
//     wire [7:0] temp1 = (in2 < in3) ? in2 : in3;
//     wire [7:0] temp2 = (in4 < in5) ? in4 : in5;
//     wire [7:0] temp3 = (in6 < in7) ? in6 : in7;
//     wire [7:0] temp4 = (in8 < in9) ? in8 : in9;
//     wire [7:0] temp5 = (in10 < in11) ? in10 : in11;
//     wire [7:0] temp6 = (in12 < in13) ? in12 : in13;
//     wire [7:0] temp7 = (in14 < in15) ? in14 : in15;


//     wire [7:0] temp8 = (temp0 < temp1) ? temp0 : temp1;
//     wire [7:0] temp9 = (temp2 < temp3) ? temp2 : temp3;
//     wire [7:0] temp10 = (temp4 < temp5) ? temp4 : temp5;
//     wire [7:0] temp11 = (temp6 < temp7) ? temp6 : temp7;

//     reg [7:0] temp8_reg, temp9_reg, temp10_reg, temp11_reg, min_temp_reg;
//     always @(posedge clk) begin
//         temp8_reg <= temp8;
//         temp9_reg <= temp9;
//         temp10_reg <= temp10;
//         temp11_reg <= temp11;
//         // min_temp_reg <= min_temp;
//     end

//     wire [7:0] temp12 = (temp8_reg < temp9_reg) ? temp8_reg : temp9_reg;
//     wire [7:0] temp13 = (temp10_reg < temp11_reg) ? temp10_reg : temp11_reg;

//     wire [7:0] temp14 = (temp12 < temp13) ? temp12 : temp13;

//     assign min = (temp14 < min_temp) ? temp14 : min_temp;
// endmodule
