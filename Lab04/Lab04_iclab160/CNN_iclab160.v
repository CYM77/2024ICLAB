//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

parameter IDLE    = 3'd0;
parameter MAP     = 3'd1;
parameter CNN     = 3'd2;
parameter MP      = 3'd3;
parameter ACT     = 3'd4;
parameter FC      = 3'd5;
parameter SOFTMAX = 3'd6;
parameter OUT     = 3'd7;
parameter fp_min = 32'b1_1111_1110_111_1111_1111_1111_1111_1111;

integer i, j;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [3:0] state,n_state;
reg [1:0] option,n_option;
reg [10:0] local_cnt,n_local_cnt;
reg [2:0] img_x,img_y,n_img_x,n_img_y;
 
// reg [inst_sig_width+inst_exp_width:0] fm [0:5][0:5];
reg [inst_sig_width+inst_exp_width:0] fm [0:35];
reg [inst_sig_width+inst_exp_width:0] mp [0:1];
reg [inst_sig_width+inst_exp_width:0] img [0:4][0:4];
reg [inst_sig_width+inst_exp_width:0] kernel1 [0:11];
reg [inst_sig_width+inst_exp_width:0] kernel2 [0:11];


reg [inst_sig_width+inst_exp_width:0] weight [0:23];

reg [2:0] fm_x, fm_y;
reg [2:0] fm_x_reg0, fm_y_reg0;

reg [inst_sig_width+inst_exp_width:0] act_temp [0:3]; //store act result 

reg [inst_sig_width+inst_exp_width:0] FC_mul_select [0:1];

reg [inst_sig_width+inst_exp_width:0] fc_soft_temp [0:3];



// reg [2:0] fm_x_reg1, fm_y_reg1;

// reg [inst_sig_width+inst_exp_width:0] mul_in00, mul_in01, mul_in10, mul_in11, mul_in20, mul_in21, mul_in30, mul_in31, mul_in40, mul_in41, mul_in50, mul_in51, mul_in60, mul_in61, mul_in70, mul_in71, mul_in80, mul_in81;
// wire [inst_sig_width+inst_exp_width:0] mul_out0, mul_out1, mul_out2, mul_out3;

reg [inst_sig_width+inst_exp_width:0] mul_in0 [0:7];
reg [inst_sig_width+inst_exp_width:0] mul_in1 [0:7];
wire [inst_sig_width+inst_exp_width:0] mul_out [0:7];
reg [inst_sig_width+inst_exp_width:0] mul_out_reg [0:7];

reg [inst_sig_width+inst_exp_width:0] add_in0 [0:7];
reg [inst_sig_width+inst_exp_width:0] add_in1 [0:7];
wire [inst_sig_width+inst_exp_width:0] add_temp0 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_temp1 [0:1];
wire [inst_sig_width+inst_exp_width:0]add_temp2 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_out[0:1] ;
reg [inst_sig_width+inst_exp_width:0] add_out_reg [0:1];

reg [inst_sig_width+inst_exp_width:0] cmp_in0 [0:1];
reg [inst_sig_width+inst_exp_width:0] cmp_in1 [0:1];
wire [inst_sig_width+inst_exp_width:0] cmp_out [0:1];
reg [inst_sig_width+inst_exp_width:0] cmp_out_reg;

reg [inst_sig_width+inst_exp_width:0] exp_in ;
wire [inst_sig_width+inst_exp_width:0] exp_out ;
reg [inst_sig_width+inst_exp_width:0] exp_out_reg ;

reg [inst_sig_width+inst_exp_width:0] div_in [0:1];
wire [inst_sig_width+inst_exp_width:0] div_out;
reg [inst_sig_width+inst_exp_width:0] div_out_reg;

reg [inst_sig_width+inst_exp_width:0] add_act_in0 [0:1];
reg [inst_sig_width+inst_exp_width:0] add_act_in1 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_act_out [0:1];
reg [inst_sig_width+inst_exp_width:0] add_act_out_reg [0:1];




/////////////////
/////////////////
// _parallel//
////////////////
// reg [inst_sig_width+inst_exp_width:0] fm_p2 [0:5][0:5];
reg [inst_sig_width+inst_exp_width:0] fm_p2 [0:35];
reg [inst_sig_width+inst_exp_width:0] mp_p2 [0:1];


reg [inst_sig_width+inst_exp_width:0] mul_in0_p2 [0:7];
reg [inst_sig_width+inst_exp_width:0] mul_in1_p2 [0:7];
wire [inst_sig_width+inst_exp_width:0] mul_out_p2 [0:7];
reg [inst_sig_width+inst_exp_width:0] mul_out_reg_p2 [0:7];

reg [inst_sig_width+inst_exp_width:0] add_in0_p2 [0:7];
reg [inst_sig_width+inst_exp_width:0] add_in1_p2 [0:7];
wire [inst_sig_width+inst_exp_width:0] add_temp0_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_temp1_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0]add_temp2_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_out_p2[0:1] ;
reg [inst_sig_width+inst_exp_width:0] add_out_reg_p2 [0:1];

reg [inst_sig_width+inst_exp_width:0] cmp_in0_p2 [0:1];
reg [inst_sig_width+inst_exp_width:0] cmp_in1_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0] cmp_out_p2 [0:1];
reg [inst_sig_width+inst_exp_width:0] cmp_out_reg_p2;

reg [inst_sig_width+inst_exp_width:0] exp_in_p2 ;
wire [inst_sig_width+inst_exp_width:0] exp_out_p2 ;
reg [inst_sig_width+inst_exp_width:0] exp_out_reg_p2 ;

reg [inst_sig_width+inst_exp_width:0] div_in_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0] div_out_p2;
reg [inst_sig_width+inst_exp_width:0] div_out_reg_p2;

reg [inst_sig_width+inst_exp_width:0] add_act_in0_p2 [0:1];
reg [inst_sig_width+inst_exp_width:0] add_act_in1_p2 [0:1];
wire [inst_sig_width+inst_exp_width:0] add_act_out_p2 [0:1];
reg [inst_sig_width+inst_exp_width:0] add_act_out_reg_p2 [0:1];


//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
//par
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL0 ( .a(mul_in0[0]), .b(mul_in1[0]), .rnd(3'b0), .z(mul_out[0]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL1 ( .a(mul_in0[1]), .b(mul_in1[1]), .rnd(3'b0), .z(mul_out[1]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL2 ( .a(mul_in0[2]), .b(mul_in1[2]), .rnd(3'b0), .z(mul_out[2]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL3 ( .a(mul_in0[3]), .b(mul_in1[3]), .rnd(3'b0), .z(mul_out[3]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL4 ( .a(mul_in0[4]), .b(mul_in1[4]), .rnd(3'b0), .z(mul_out[4]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL5 ( .a(mul_in0[5]), .b(mul_in1[5]), .rnd(3'b0), .z(mul_out[5]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL6 ( .a(mul_in0[6]), .b(mul_in1[6]), .rnd(3'b0), .z(mul_out[6]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_ieee_compliance)CNN_MUL7 ( .a(mul_in0[7]), .b(mul_in1[7]), .rnd(3'b0), .z(mul_out[7]), .status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD0 (.a(add_in0[0]),.b(add_in1[0]),.rnd(3'b0),.z(add_temp0[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD1 (.a(add_in0[1]),.b(add_in1[1]),.rnd(3'b0),.z(add_temp1[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD2 (.a(add_in0[2]),.b(add_in1[2]),.rnd(3'b0),.z(add_temp2[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD3 (.a(add_in0[3]),.b(add_in1[3]),.rnd(3'b0),.z(add_out[0]),.status() );//

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD4 (.a(add_in0[4]),.b(add_in1[4]),.rnd(3'b0),.z(add_temp0[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD5 (.a(add_in0[5]),.b(add_in1[5]),.rnd(3'b0),.z(add_temp1[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD6 (.a(add_in0[6]),.b(add_in1[6]),.rnd(3'b0),.z(add_temp2[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD7 (.a(add_in0[7]),.b(add_in1[7]),.rnd(3'b0),.z(add_out[1]),.status() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CMP0 ( .a(cmp_in0[0]), .b(cmp_in1[0]), .zctr(1'b0), .aeqb(),.altb(), .agtb(), .unordered(), .z0(), .z1(cmp_out[0]), .status0(),.status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CMP1 ( .a(cmp_in0[1]), .b(cmp_in1[1]), .zctr(1'b0), .aeqb(),.altb(), .agtb(), .unordered(), .z0(), .z1(cmp_out[1]), .status0(),.status1() );

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) EXP0 (.a(exp_in),.z(exp_out),.status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)ACT_ADD0 (.a(add_act_in0[0]),.b(add_act_in1[0]),.rnd(3'b0),.z(add_act_out[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)ACT_ADD1 (.a(add_act_in0[1]),.b(add_act_in1[1]),.rnd(3'b0),.z(add_act_out[1]),.status() );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_faithful_round) DIV( .a(div_in[0]), .b(div_in[1]), .rnd(3'b0), .z(div_out), .status());


//mul_in for IMG
always @(*) begin
    if(state == CNN || (state == MP && local_cnt <=15)) begin
        if(fm_y == 0) begin
            if(fm_x == 0) begin
                mul_in0[0] = option ? img[0][0] : 0;
                mul_in0[1] = option ? img[0][0] : 0;
                mul_in0[2] = option ? img[0][0] : 0;
                mul_in0[3] = img[0][0];
            end
            else begin
                mul_in0[0] = option ?img[0][fm_x-1] : 0;
                mul_in0[1] = option ?img[0][fm_x]   : 0;
                mul_in0[2] = img[0][fm_x-1];
                mul_in0[3] = img[0][fm_x];
            end
        end
        // else if(fm_y == 5) begin
        //     if(fm_x == 0) begin
        //         mul_in0[0] = option ? img[4][0] : 0;
        //         mul_in0[1] = img[4][0];
        //         mul_in0[2] = option ? img[4][0] : 0;
        //         mul_in0[3] = option ? img[4][0] : 0;
        //     end
        //     else begin
        //         mul_in0[0] = img[4][fm_x-1];
        //         mul_in0[1] = img[4][fm_x];
        //         mul_in0[2] = option ? img[4][fm_x-1] : 0;
        //         mul_in0[3] = option ? img[4][fm_x]   : 0;
        //     end
        // end
        else if(fm_y == 4) begin
            case(fm_x)
                0:begin
                    mul_in0[0] = option ? img[3][0] : 0;
                    mul_in0[1] = img[3][0];
                    mul_in0[2] = option ? img[4][0] : 0;
                    mul_in0[3] = img[4][0];
                end
                5: begin
                    mul_in0[0] = img[3][4];
                    mul_in0[1] = option ? img[3][4] : 0;
                    mul_in0[2] = img[4][4];
                    mul_in0[3] = option ? img[4][4] : 0;
                end
                default: begin
                    mul_in0[0] = img[3][fm_x-1];
                    mul_in0[1] = img[3][fm_x];
                    mul_in0[2] = img[4][fm_x-1];
                    mul_in0[3] = img[4][fm_x]  ;
                end
            endcase
        end
        else begin
            if(fm_x == 0) begin
                mul_in0[0] = option ? img[fm_y - 1][fm_x] : 0;
                mul_in0[1] = img[fm_y - 1][fm_x];
                mul_in0[2] = option ? img[fm_y][fm_x] : 0;
                mul_in0[3] = img[fm_y][fm_x];
            end
            else begin
                mul_in0[0] = img[fm_y - 1][fm_x - 1];
                mul_in0[1] = img[fm_y - 1][fm_x];
                mul_in0[2] = img[fm_y][fm_x - 1];
                mul_in0[3] = img[fm_y][fm_x];
            end
        end
    end
    else begin
        mul_in0[0] = weight[17];
        mul_in0[1] = weight[21];
        mul_in0[2] = weight[1];
        mul_in0[3] = 0;
        // $display("G:%d", global_cnt);
    end
end

always @(*) begin
    if(fm_y == 0) begin
        if(fm_x == 4) begin
            mul_in0[4] = option ? img[0][4] : 0;
            mul_in0[5] = option ? img[0][4] : 0;
            mul_in0[6] = img[0][4];
            mul_in0[7] = option ? img[0][4] : 0;
        end
        else begin
            mul_in0[4] = option ?img[0][fm_x] : 0;
            mul_in0[5] = option ?img[0][fm_x + 1]   : 0;
            mul_in0[6] = img[0][fm_x];
            mul_in0[7] = img[0][fm_x + 1];
        end
    end
    // else if(fm_y == 5) begin
    //     if(fm_x == 4) begin
    //         mul_in0[4] = img[4][4];
    //         mul_in0[5] = option ? img[4][4] : 0;
    //         mul_in0[6] = option ? img[4][4] : 0;
    //         mul_in0[7] = option ? img[4][4] : 0;
    //     end
    //     else begin
    //         mul_in0[4] = img[4][fm_x];
    //         mul_in0[5] = img[4][fm_x + 1];
    //         mul_in0[6] = option ? img[4][fm_x] : 0;
    //         mul_in0[7] = option ? img[4][fm_x + 1]   : 0;
    //     end
    // end
    else if(fm_y == 4) begin
        case(fm_x)
                0:begin
                    mul_in0[4] = option ? img[4][0] : 0;
                    mul_in0[5] = img[4][0];
                    mul_in0[6] = option ? img[4][0] : 0;
                    mul_in0[7] = option ? img[4][0] : 0;
                end
                5: begin
                    mul_in0[4] = img[4][4];
                    mul_in0[5] = option ? img[4][4] : 0;
                    mul_in0[6] = option ? img[4][4] : 0;
                    mul_in0[7] = option ? img[4][4] : 0;
                end
                default: begin
                    mul_in0[4] = img[4][fm_x-1];
                    mul_in0[5] = img[4][fm_x]  ;
                    mul_in0[6] = option ? img[4][fm_x-1] : 0;
                    mul_in0[7] = option ? img[4][fm_x]   : 0;
                end
            endcase
    end
    else begin
        if(fm_x == 4) begin
            mul_in0[4] = img[fm_y - 1][4];
            mul_in0[5] = option ? img[fm_y - 1][4] : 0;
            mul_in0[6] = img[fm_y][4];
            mul_in0[7] = option ? img[fm_y][4] : 0;
        end
        else begin
            mul_in0[4] = img[fm_y - 1][fm_x];
            mul_in0[5] = img[fm_y - 1][fm_x + 1];
            mul_in0[6] = img[fm_y][fm_x];
            mul_in0[7] = img[fm_y][fm_x + 1];
        end
    end
end

//mul_in for kernel
always @(*) begin
    if(state == CNN || (state == MP && local_cnt <=15)) begin
        mul_in1[0] = kernel1[0];
        mul_in1[1] = kernel1[1];
        mul_in1[2] = kernel1[2];
        mul_in1[3] = kernel1[3];
        mul_in1[4] = kernel1[0];
        mul_in1[5] = kernel1[1];
        mul_in1[6] = kernel1[2];
        mul_in1[7] = kernel1[3];
    end
    else begin
        mul_in1[0] = FC_mul_select[0];
        mul_in1[1] = FC_mul_select[1];
        mul_in1[2] = FC_mul_select[0];
        /////
        mul_in1[3] = kernel1[3];
        mul_in1[4] = kernel1[0];
        mul_in1[5] = kernel1[1];
        mul_in1[6] = kernel1[2];
        mul_in1[7] = kernel1[3];
    end
end

//add_in
always @(*) begin
    // if(state == CNN || (state == MAP && local_cnt ==1) || (state == MP && local_cnt <=16)) begin
    if((state != MP) || local_cnt <= 16) begin
        add_in0[0] = mul_out_reg[0];
        add_in0[1] = mul_out_reg[2];
        add_in0[2] = add_temp1[0];
        add_in0[3] = add_temp0[0];/////////////////////////////

        add_in0[4] = mul_out_reg[4];
        add_in0[5] = mul_out_reg[6];
        add_in0[6] = add_temp1[1];
        add_in0[7] = add_temp0[1];
    end
    else begin
        add_in0[1] = mul_out_reg[0];
        add_in0[2] = add_temp1[0];

        add_in0[5] = mul_out_reg[2];
        add_in0[6] = add_temp1[1];/////////////////////////////

        add_in0[0] = mul_out_reg[0];
        add_in0[3] = add_temp0[0];
        add_in0[4] = mul_out_reg[4];
        add_in0[7] = add_temp0[1];
    end
end

always @(*) begin
    if((state != MP) || local_cnt <= 16) begin 
        add_in1[0] = mul_out_reg[1];
        add_in1[1] = mul_out_reg[3];
        add_in1[2] = fm[0];
        add_in1[3] = add_temp2[0];

        add_in1[4] = mul_out_reg[5];
        add_in1[5] = mul_out_reg[7];
        add_in1[6] = fm[1];
        add_in1[7] = add_temp2[1];
    end
    else begin
        add_in1[1] = mul_out_reg[1];
        add_in1[2] = fc_soft_temp[0];

        add_in1[5] = mul_out_reg_p2[0];
        add_in1[6] = fc_soft_temp[1];
        ///////
        add_in1[0] = mul_out_reg[1];
        add_in1[3] = add_temp2[0];
        add_in1[4] = mul_out_reg[5];
        add_in1[7] = add_temp2[1];
    end
end

// cmp_in
always @(*) begin
    // case(local_cnt)
    //     0: begin
    //         cmp_in0[0] = fm[0][0];
    //         cmp_in1[0] = fm[0][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     3: begin
    //         cmp_in0[0] = fm[1][0];
    //         cmp_in1[0] = fm[1][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     6: begin
    //         cmp_in0[0] = fm[2][0];
    //         cmp_in1[0] = fm[2][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     1: begin
    //         cmp_in0[0] = fm[0][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[0][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     4: begin
    //         cmp_in0[0] = fm[1][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[1][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     7: begin
    //         cmp_in0[0] = fm[2][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[2][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     2:begin
    //         cmp_in0[0] = fm[0][4];
    //         cmp_in1[0] = fm[0][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     5:begin
    //         cmp_in0[0] = fm[1][4];
    //         cmp_in1[0] = fm[1][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     8:begin
    //         cmp_in0[0] = fm[2][4];
    //         cmp_in1[0] = fm[2][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end

    //     9: begin
    //         cmp_in0[0] = fm[3][0];
    //         cmp_in1[0] = fm[3][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     12: begin
    //         cmp_in0[0] = fm[4][0];
    //         cmp_in1[0] = fm[4][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     15: begin
    //         cmp_in0[0] = fm[5][0];
    //         cmp_in1[0] = fm[5][1];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     10: begin
    //         cmp_in0[0] = fm[3][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[3][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     13: begin
    //         cmp_in0[0] = fm[4][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[4][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     16: begin
    //         cmp_in0[0] = fm[5][2];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[5][3];
    //         cmp_in1[1] = mp[1];
    //     end
    //     11:begin
    //         cmp_in0[0] = fm[3][4];
    //         cmp_in1[0] = fm[3][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     14:begin
    //         cmp_in0[0] = fm[4][4];
    //         cmp_in1[0] = fm[4][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     17:begin
    //         cmp_in0[0] = fm[5][4];
    //         cmp_in1[0] = fm[5][5];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     default: begin
    //         cmp_in0[0] = 0;
    //         cmp_in1[0] = 0;
    //         cmp_in0[1] = 0;
    //         cmp_in1[1] = 0;
    //     end
    // endcase

    //ori
    // case(local_cnt)
    //     0: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     3: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     6: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     1: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     4: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     7: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     2:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     5:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     8:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end

    //     9: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     12: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     15: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[0];
    //     end
    //     10: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     13: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     16: begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = mp[0];
    //         cmp_in0[1] = fm[35];
    //         cmp_in1[1] = mp[1];
    //     end
    //     11:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     14:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     17:begin
    //         cmp_in0[0] = fm[34];
    //         cmp_in1[0] = fm[35];
    //         cmp_in0[1] = cmp_out[0];
    //         cmp_in1[1] = mp[1];
    //     end
    //     default: begin
    //         cmp_in0[0] = 0;
    //         cmp_in1[0] = 0;
    //         cmp_in0[1] = 0;
    //         cmp_in1[1] = 0;
    //     end
    // endcase

    //new
    case(local_cnt)
        0: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        3: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        6: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        1: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = mp[0];
            cmp_in0[1] = fm[35];
            cmp_in1[1] = mp[1];
        end
        4: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = mp[0];
            cmp_in0[1] = fm[35];
            cmp_in1[1] = mp[1];
        end
        7: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = mp[0];
            cmp_in0[1] = fm[35];
            cmp_in1[1] = mp[1];
        end
        2:begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        5:begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        8:begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end

        9: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        12: begin//////////////////////////
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        15: begin//////////////////////////////-1
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        10: begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = mp[0];
            cmp_in0[1] = fm[35];
            cmp_in1[1] = mp[1];
        end
        13: begin////////////////////////////-1 
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        16: begin////////////////////////////
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        11:begin
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        14:begin/////////////////////////////////////
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[0];
        end
        17:begin///////////////////////////////////////////
            cmp_in0[0] = fm[34];
            cmp_in1[0] = fm[35];
            cmp_in0[1] = cmp_out[0];
            cmp_in1[1] = mp[1];
        end
        default: begin
            cmp_in0[0] = 0;
            cmp_in1[0] = 0;
            cmp_in0[1] = 0;
            cmp_in1[1] = 0;
        end
    endcase
end

//exp_in
always @(*) begin
    if(state == MP) begin
        case(local_cnt)
            23: exp_in = fc_soft_temp[0];
            24: exp_in = fc_soft_temp[2];
            default:exp_in = option==0 ? {~cmp_out_reg[31],cmp_out_reg[30:0]} : {cmp_out_reg[31], (cmp_out_reg[30:23]+1'b1), cmp_out_reg[22:0]};//e**(-z)
        endcase
    end
    else begin
        exp_in = 0;
    end
end
//add_act_in
always @(*) begin
    add_act_in0[0] = option==0 ? 32'b0_01111111_00000000000000000000000 : 32'b1_01111111_00000000000000000000000;//1;-1
    add_act_in0[1] = 32'b0_01111111_00000000000000000000000;
end

always @(*) begin
    add_act_in1[0] = option==0 ? 32'b0_00000000_00000000000000000000000 : exp_out_reg;
    add_act_in1[1] = exp_out_reg;
end
//div_in
always @(*) begin
    if(state == MP) begin
        case(local_cnt)
            26:div_in[0] = fc_soft_temp[0];
            27:div_in[0] = fc_soft_temp[1];
            28:div_in[0] = fc_soft_temp[2];
            default:div_in[0] = add_act_out_reg[0];
        endcase
    end
    else begin
        div_in[0] = 0;
    end
end
always @(*) begin
    if(state == MP) begin
        case(local_cnt)
            26,27,28:div_in[1] = fc_soft_temp[3];
            default:div_in[1] = add_act_out_reg[1];
        endcase
    end
    else begin
        div_in[1] = 0;
    end
end

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
//temp_reg
always @(posedge clk) begin
    if(state == MP) begin
        if(local_cnt == 10) begin
            act_temp[0] <= div_out;
        end
    end
    else if(state == IDLE) act_temp[0] <= 0;
end
always @(posedge clk) begin
    if(state == MP) begin
        if(local_cnt == 11) begin
            act_temp[1] <= div_out;
        end
    end
    else if(state == IDLE) act_temp[1] <= 0;
end

//div_reg
always @(posedge clk) begin
    div_out_reg <= div_out;
end
//add_act_reg
always @(posedge clk) begin
    for(i = 0; i < 2; i++) begin
        add_act_out_reg[i] <= add_act_out[i];
    end
end

//exp_out_reg
always @(posedge clk) begin
    exp_out_reg <= exp_out;

end
//cmp_reg
always @(posedge clk ) begin
    if(local_cnt == 7 ) cmp_out_reg <= cmp_out[0];
    else if(local_cnt == 8 || local_cnt == 17 || local_cnt == 14) cmp_out_reg <= cmp_out[1];
end
// mul_out_reg
always @(posedge clk) begin
    for(i = 0; i < 8; i++) begin
        mul_out_reg[i] <= mul_out[i];
    end
end
//add_out_reg
always @(posedge clk) begin
    for(i = 0; i < 2; i++) begin
        add_out_reg[i] <= add_out[i];
    end
end



/////////////////
/////////////////
// _parallel//
////////////////

//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
//par
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL0_p2 ( .a(mul_in0_p2[0]), .b(mul_in1_p2[0]), .rnd(3'b0), .z(mul_out_p2[0]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL1_p2 ( .a(mul_in0_p2[1]), .b(mul_in1_p2[1]), .rnd(3'b0), .z(mul_out_p2[1]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL2_p2 ( .a(mul_in0_p2[2]), .b(mul_in1_p2[2]), .rnd(3'b0), .z(mul_out_p2[2]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL3_p2 ( .a(mul_in0_p2[3]), .b(mul_in1_p2[3]), .rnd(3'b0), .z(mul_out_p2[3]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL4_p2 ( .a(mul_in0_p2[4]), .b(mul_in1_p2[4]), .rnd(3'b0), .z(mul_out_p2[4]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL5_p2 ( .a(mul_in0_p2[5]), .b(mul_in1_p2[5]), .rnd(3'b0), .z(mul_out_p2[5]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL6_p2 ( .a(mul_in0_p2[6]), .b(mul_in1_p2[6]), .rnd(3'b0), .z(mul_out_p2[6]), .status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_ieee_compliance)CNN_MUL7_p2 ( .a(mul_in0_p2[7]), .b(mul_in1_p2[7]), .rnd(3'b0), .z(mul_out_p2[7]), .status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD0_p2 (.a(add_in0_p2[0]),.b(add_in1_p2[0]),.rnd(3'b0),.z(add_temp0_p2[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD1_p2 (.a(add_in0_p2[1]),.b(add_in1_p2[1]),.rnd(3'b0),.z(add_temp1_p2[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD2_p2 (.a(add_in0_p2[2]),.b(add_in1_p2[2]),.rnd(3'b0),.z(add_temp2_p2[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD3_p2 (.a(add_in0_p2[3]),.b(add_in1_p2[3]),.rnd(3'b0),.z(add_out_p2[0]),.status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD4_p2 (.a(add_in0_p2[4]),.b(add_in1_p2[4]),.rnd(3'b0),.z(add_temp0_p2[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD5_p2 (.a(add_in0_p2[5]),.b(add_in1_p2[5]),.rnd(3'b0),.z(add_temp1_p2[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD6_p2 (.a(add_in0_p2[6]),.b(add_in1_p2[6]),.rnd(3'b0),.z(add_temp2_p2[1]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CNN_ADD7_p2 (.a(add_in0_p2[7]),.b(add_in1_p2[7]),.rnd(3'b0),.z(add_out_p2[1]),.status() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CMP0_p2 ( .a(cmp_in0_p2[0]), .b(cmp_in1_p2[0]), .zctr(1'b0), .aeqb(),.altb(), .agtb(), .unordered(), .z0(), .z1(cmp_out_p2[0]), .status0(),.status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)CMP1_p2 ( .a(cmp_in0_p2[1]), .b(cmp_in1_p2[1]), .zctr(1'b0), .aeqb(),.altb(), .agtb(), .unordered(), .z0(), .z1(cmp_out_p2[1]), .status0(),.status1() );

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) EXP0_p2 (.a(exp_in_p2),.z(exp_out_p2),.status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)ACT_ADD0_p2 (.a(add_act_in0_p2[0]),.b(add_act_in1_p2[0]),.rnd(3'b0),.z(add_act_out_p2[0]),.status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)ACT_ADD1_p2 (.a(add_act_in0_p2[1]),.b(add_act_in1_p2[1]),.rnd(3'b0),.z(add_act_out_p2[1]),.status() );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_faithful_round) DIV_p2( .a(div_in_p2[0]), .b(div_in_p2[1]), .rnd(3'b0), .z(div_out_p2), .status());


//mul_in for IMG
always @(*) begin
    if(state == CNN || (state == MP && local_cnt <=15))begin
        mul_in0_p2[0] = mul_in0[0];
        mul_in0_p2[1] = mul_in0[1];
        mul_in0_p2[2] = mul_in0[2];
        mul_in0_p2[3] = mul_in0[3];
        // if(fm_y == 0) begin
        //     if(fm_x == 0) begin
        //         mul_in0_p2[0] = option ? img[0][0] : 0;
        //         mul_in0_p2[1] = option ? img[0][0] : 0;
        //         mul_in0_p2[2] = option ? img[0][0] : 0;
        //         mul_in0_p2[3] = img[0][0];
        //     end
        //     else begin
        //         mul_in0_p2[0] = option ?img[0][fm_x-1] : 0;
        //         mul_in0_p2[1] = option ?img[0][fm_x]   : 0;
        //         mul_in0_p2[2] = img[0][fm_x-1];
        //         mul_in0_p2[3] = img[0][fm_x];
        //     end
        // end
        // else if(fm_y == 5) begin
        //     if(fm_x == 0) begin
        //         mul_in0_p2[0] = option ? img[4][0] : 0;
        //         mul_in0_p2[1] = img[4][0];
        //         mul_in0_p2[2] = option ? img[4][0] : 0;
        //         mul_in0_p2[3] = option ? img[4][0] : 0;
        //     end
        //     else begin
        //         mul_in0_p2[0] = img[4][fm_x-1];
        //         mul_in0_p2[1] = img[4][fm_x];
        //         mul_in0_p2[2] = option ? img[4][fm_x-1] : 0;
        //         mul_in0_p2[3] = option ? img[4][fm_x]   : 0;
        //     end
        // end
        // else begin
        //     if(fm_x == 0) begin
        //         mul_in0_p2[0] = option ? img[fm_y - 1][fm_x] : 0;
        //         mul_in0_p2[1] = img[fm_y - 1][fm_x];
        //         mul_in0_p2[2] = option ? img[fm_y][fm_x] : 0;
        //         mul_in0_p2[3] = img[fm_y][fm_x];
        //     end
        //     else begin
        //         mul_in0_p2[0] = img[fm_y - 1][fm_x - 1];
        //         mul_in0_p2[1] = img[fm_y - 1][fm_x];
        //         mul_in0_p2[2] = img[fm_y][fm_x - 1];
        //         mul_in0_p2[3] = img[fm_y][fm_x];
        //     end
        // end
    end
    else begin
        mul_in0_p2[0] = weight[5];
        mul_in0_p2[1] = weight[9];
        mul_in0_p2[2] = weight[13];
        mul_in0_p2[3] = 0;
    end

    
end

always @(*) begin

    mul_in0_p2[4] = mul_in0[4];
    mul_in0_p2[5] = mul_in0[5];
    mul_in0_p2[6] = mul_in0[6];
    mul_in0_p2[7] = mul_in0[7];
        // if(fm_y == 0) begin
        //     if(fm_x == 4) begin
        //         mul_in0_p2[4] = option ? img[0][4] : 0;
        //         mul_in0_p2[5] = option ? img[0][4] : 0;
        //         mul_in0_p2[6] = img[0][4];
        //         mul_in0_p2[7] = option ? img[0][4] : 0;
        //     end
        //     else begin
        //         mul_in0_p2[4] = option ?img[0][fm_x] : 0;
        //         mul_in0_p2[5] = option ?img[0][fm_x + 1]   : 0;
        //         mul_in0_p2[6] = img[0][fm_x];
        //         mul_in0_p2[7] = img[0][fm_x + 1];
        //     end
        // end
        // else if(fm_y == 5) begin
        //     if(fm_x == 4) begin
        //         mul_in0_p2[4] = img[4][4];
        //         mul_in0_p2[5] = option ? img[4][4] : 0;
        //         mul_in0_p2[6] = option ? img[4][4] : 0;
        //         mul_in0_p2[7] = option ? img[4][4] : 0;
        //     end
        //     else begin
        //         mul_in0_p2[4] = img[4][fm_x];
        //         mul_in0_p2[5] = img[4][fm_x + 1];
        //         mul_in0_p2[6] = option ? img[4][fm_x] : 0;
        //         mul_in0_p2[7] = option ? img[4][fm_x + 1]   : 0;
        //     end
        // end
        // else begin
        //     if(fm_x == 4) begin
        //         mul_in0_p2[4] = img[fm_y - 1][4];
        //         mul_in0_p2[5] = option ? img[fm_y - 1][4] : 0;
        //         mul_in0_p2[6] = img[fm_y][4];
        //         mul_in0_p2[7] = option ? img[fm_y][4] : 0;
        //     end
        //     else begin
        //         mul_in0_p2[4] = img[fm_y - 1][fm_x];
        //         mul_in0_p2[5] = img[fm_y - 1][fm_x + 1];
        //         mul_in0_p2[6] = img[fm_y][fm_x];
        //         mul_in0_p2[7] = img[fm_y][fm_x + 1];
        //     end
        // end

    
    
end

//mul_in for kernel
always @(*) begin
    if(state == CNN || (state == MP && local_cnt <=15)) begin
        mul_in1_p2[0] = kernel2[0];
        mul_in1_p2[1] = kernel2[1];
        mul_in1_p2[2] = kernel2[2];
        mul_in1_p2[3] = kernel2[3];
        mul_in1_p2[4] = kernel2[0];
        mul_in1_p2[5] = kernel2[1];
        mul_in1_p2[6] = kernel2[2];
        mul_in1_p2[7] = kernel2[3];
    end
    else begin
        mul_in1_p2[0] = FC_mul_select[1];
        mul_in1_p2[1] = FC_mul_select[0];
        mul_in1_p2[2] = FC_mul_select[1];
        ///
        mul_in1_p2[3] = kernel1[3];
        mul_in1_p2[4] = kernel1[0];
        mul_in1_p2[5] = kernel1[1];
        mul_in1_p2[6] = kernel1[2];
        mul_in1_p2[7] = kernel1[3];
    end
end

//add_in
always @(*) begin
    // if(local_cnt <= 61 || (state == MP || local_cnt <=16)) begin
    // if(state == CNN || (state == MAP && local_cnt ==1) || (state == MP && local_cnt <=16)) begin
    // if(in_valid  || local_cnt <=16) begin  
    if((state != MP) || local_cnt <= 16) begin 
        add_in0_p2[0] = mul_out_reg_p2[0];
        add_in0_p2[1] = mul_out_reg_p2[2];
        add_in0_p2[2] = add_temp1_p2[0];
        add_in0_p2[3] = add_temp0_p2[0];
        add_in0_p2[4] = mul_out_reg_p2[4];
        add_in0_p2[5] = mul_out_reg_p2[6];
        add_in0_p2[6] = add_temp1_p2[1];
        add_in0_p2[7] = add_temp0_p2[1];
    end
    else begin
        add_in0_p2[1] = mul_out_reg_p2[1];
        add_in0_p2[2] = add_temp1_p2[0];

        add_in0_p2[5] = fc_soft_temp[0];
        add_in0_p2[6] = add_temp1_p2[1];
        //////
        add_in0_p2[0] = mul_out_reg[0];
        add_in0_p2[3] = add_temp0[0];
        add_in0_p2[4] = mul_out_reg[4];
        add_in0_p2[7] = add_temp0[1];

    end
end

always @(*) begin
    if((state != MP) || local_cnt <= 16) begin 
        add_in1_p2[0] = mul_out_reg_p2[1];
        add_in1_p2[1] = mul_out_reg_p2[3];
        add_in1_p2[2] = fm_p2[0];
        add_in1_p2[3] = add_temp2_p2[0];

        add_in1_p2[4] = mul_out_reg_p2[5];
        add_in1_p2[5] = mul_out_reg_p2[7];
        add_in1_p2[6] = fm_p2[1];
        add_in1_p2[7] = add_temp2_p2[1];
    end
    else begin
        add_in1_p2[1] = mul_out_reg_p2[2];
        add_in1_p2[2] = fc_soft_temp[2];

        add_in1_p2[5] = fc_soft_temp[1];
        add_in1_p2[6] = fc_soft_temp[2];

        ///////
        add_in1_p2[0] = mul_out_reg[1];
        add_in1_p2[3] = add_temp2[0];
        add_in1_p2[4] = mul_out_reg[5];
        add_in1_p2[7] = add_temp2[1];
    end
end

// cmp_in
always @(*) begin
    // case(local_cnt)
    //     0: begin
    //         cmp_in0_p2[0] = fm_p2[0][0];
    //         cmp_in1_p2[0] = fm_p2[0][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     3: begin
    //         cmp_in0_p2[0] = fm_p2[1][0];
    //         cmp_in1_p2[0] = fm_p2[1][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     6: begin
    //         cmp_in0_p2[0] = fm_p2[2][0];
    //         cmp_in1_p2[0] = fm_p2[2][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     1: begin
    //         cmp_in0_p2[0] = fm_p2[0][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[0][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     4: begin
    //         cmp_in0_p2[0] = fm_p2[1][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[1][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     7: begin
    //         cmp_in0_p2[0] = fm_p2[2][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[2][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     2:begin
    //         cmp_in0_p2[0] = fm_p2[0][4];
    //         cmp_in1_p2[0] = fm_p2[0][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     5:begin
    //         cmp_in0_p2[0] = fm_p2[1][4];
    //         cmp_in1_p2[0] = fm_p2[1][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     8:begin
    //         cmp_in0_p2[0] = fm_p2[2][4];
    //         cmp_in1_p2[0] = fm_p2[2][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end

    //     9: begin
    //         cmp_in0_p2[0] = fm_p2[3][0];
    //         cmp_in1_p2[0] = fm_p2[3][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     12: begin
    //         cmp_in0_p2[0] = fm_p2[4][0];
    //         cmp_in1_p2[0] = fm_p2[4][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     15: begin
    //         cmp_in0_p2[0] = fm_p2[5][0];
    //         cmp_in1_p2[0] = fm_p2[5][1];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     10: begin
    //         cmp_in0_p2[0] = fm_p2[3][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[3][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     13: begin
    //         cmp_in0_p2[0] = fm_p2[4][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[4][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     16: begin
    //         cmp_in0_p2[0] = fm_p2[5][2];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[5][3];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     11:begin
    //         cmp_in0_p2[0] = fm_p2[3][4];
    //         cmp_in1_p2[0] = fm_p2[3][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     14:begin
    //         cmp_in0_p2[0] = fm_p2[4][4];
    //         cmp_in1_p2[0] = fm_p2[4][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     17:begin
    //         cmp_in0_p2[0] = fm_p2[5][4];
    //         cmp_in1_p2[0] = fm_p2[5][5];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     default: begin
    //         cmp_in0_p2[0] = 0;
    //         cmp_in1_p2[0] = 0;
    //         cmp_in0_p2[1] = 0;
    //         cmp_in1_p2[1] = 0;
    //     end
    // endcase
    // case(local_cnt)
    //     0: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     3: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     6: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     1: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     4: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     7: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     2:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     5:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     8:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end

    //     9: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     12: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     15: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[0];
    //     end
    //     10: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     13: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     16: begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = mp_p2[0];
    //         cmp_in0_p2[1] = fm_p2[35];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     11:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     14:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     17:begin
    //         cmp_in0_p2[0] = fm_p2[34];
    //         cmp_in1_p2[0] = fm_p2[35];
    //         cmp_in0_p2[1] = cmp_out_p2[0];
    //         cmp_in1_p2[1] = mp_p2[1];
    //     end
    //     default: begin
    //         cmp_in0_p2[0] = 0;
    //         cmp_in1_p2[0] = 0;
    //         cmp_in0_p2[1] = 0;
    //         cmp_in1_p2[1] = 0;
    //     end
    // endcase

    //new
    case(local_cnt)
        0: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        3: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        6: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        1: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = mp_p2[0];
            cmp_in0_p2[1] = fm_p2[35];
            cmp_in1_p2[1] = mp_p2[1];
        end
        4: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = mp_p2[0];
            cmp_in0_p2[1] = fm_p2[35];
            cmp_in1_p2[1] = mp_p2[1];
        end
        7: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = mp_p2[0];
            cmp_in0_p2[1] = fm_p2[35];
            cmp_in1_p2[1] = mp_p2[1];
        end
        2:begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        5:begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        8:begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end

        9: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        12: begin//////////////////////////
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        15: begin//////////////////////////////-1
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        10: begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = mp_p2[0];
            cmp_in0_p2[1] = fm_p2[35];
            cmp_in1_p2[1] = mp_p2[1];
        end
        13: begin////////////////////////////-1 
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        16: begin////////////////////////////
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        11:begin
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        14:begin/////////////////////////////////////
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[0];
        end
        17:begin///////////////////////////////////////////
            cmp_in0_p2[0] = fm_p2[34];
            cmp_in1_p2[0] = fm_p2[35];
            cmp_in0_p2[1] = cmp_out_p2[0];
            cmp_in1_p2[1] = mp_p2[1];
        end
        default: begin
            cmp_in0_p2[0] = 0;
            cmp_in1_p2[0] = 0;
            cmp_in0_p2[1] = 0;
            cmp_in1_p2[1] = 0;
        end
    endcase
end

//exp_in
always @(*) begin
    if(state == MP) begin
        case(local_cnt)
            23:exp_in_p2 = fc_soft_temp[1];
            default:exp_in_p2 = option==0 ? {~cmp_out_reg_p2[31],cmp_out_reg_p2[30:0]} : {cmp_out_reg_p2[31], (cmp_out_reg_p2[30:23]+1'b1), cmp_out_reg_p2[22:0]};//e**(-z)
        endcase
    end
    else begin
        exp_in_p2 = 0;
    end
end
//add_act_in
always @(*) begin
    add_act_in0_p2[0] = option==0 ? 32'b0_01111111_00000000000000000000000 : 32'b1_01111111_00000000000000000000000;//1;-1
    add_act_in0_p2[1] = 32'b0_01111111_00000000000000000000000;
end

always @(*) begin
    add_act_in1_p2[0] = option==0 ? 32'b0_00000000_00000000000000000000000 : exp_out_reg_p2;
    add_act_in1_p2[1] = exp_out_reg_p2;
end
//div_in
always @(*) begin
    if(state == MP) begin
        div_in_p2[0] = add_act_out_reg_p2[0];
    end
    else begin
        div_in_p2[0] = 0;
    end
end
always @(*) begin
    if(state == MP) begin
        div_in_p2[1] = add_act_out_reg_p2[1];
    end
    else begin
      div_in_p2[1] = 0;
    end
end

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
//temp_reg
always @(posedge clk) begin
    if(state == MP) begin
        if(local_cnt == 10) begin
            act_temp[2] <= div_out_p2;
        end
        else if(state == IDLE) act_temp[2] <= 0;
    end
end
always @(posedge clk) begin
    if(state == MP) begin
        if(local_cnt == 11) begin
            act_temp[3] <= div_out_p2;
        end
        else if(state == IDLE) act_temp[3] <= 0;
    end
end
//dic_reg
always @(posedge clk) begin
    div_out_reg_p2 <= div_out_p2;
end
//add_act_reg
always @(posedge clk) begin
    for(i = 0; i < 2; i++) begin
        add_act_out_reg_p2[i] <= add_act_out_p2[i];
    end
end

//exp_out_reg
always @(posedge clk) begin
    exp_out_reg_p2 <= exp_out_p2;

end
//cmp_reg
always @(posedge clk ) begin
    if(local_cnt == 7) cmp_out_reg_p2 <= cmp_out_p2[0];
    else if(local_cnt == 8 || local_cnt == 17  || local_cnt == 14) cmp_out_reg_p2 <= cmp_out_p2[1];
end
// mul_out_reg
always @(posedge clk) begin
    for(i = 0; i < 8; i++) begin
        mul_out_reg_p2[i] <= mul_out_p2[i];
    end
end
//add_out_reg
always @(posedge clk) begin
    for(i = 0; i < 2; i++) begin
        add_out_reg_p2[i] <= add_out_p2[i];
    end
end

reg [10:0] global_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) global_cnt<=0;
    else begin
      if(state == IDLE) global_cnt <= 0;
      else if(in_valid || state != IDLE) global_cnt<=global_cnt+1;
    end
end


























//fm_x,y reg
always @(posedge clk) begin
    fm_x_reg0 <= fm_x;
    fm_y_reg0 <= fm_y;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                if(in_valid) state <= MAP;
            end
            MAP: begin
                if(img_x == 3 && img_y == 1) state <= CNN;
            end
            CNN:begin
                if(local_cnt == 60) state <= MP;
                else if(fm_x == 5 && fm_y == 4) state <= MAP;
            end 
            MP: begin
                if(local_cnt == 29) state <= IDLE;
            end
        endcase
    end
end
//img_x, img_y
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      img_x <= 0;
    end
    else if(in_valid) begin
        if(img_x == 4) img_x <= 0;
        else img_x <= img_x + 1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      img_y <= 0;
    end
    else if(in_valid) begin
        if(img_x == 4) begin
            if(img_y == 4) img_y <= 0;
            else img_y <= img_y + 1;
        end
    end
end

//fm_x,fm_y
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      fm_x <= 0;
    end
    else if(state == IDLE) fm_x <= 0;
    // else if(state != IDLE && state != MAP) begin
    //     if(fm_x == 4) fm_x <= 0;
    //     else fm_x <= fm_x + 2;
    // end
    else if(state != IDLE && state != MAP) begin
        if(fm_y == 4) begin
            if(fm_x==5) fm_x <= 0;
            else fm_x <= fm_x + 1;
        end 
        else begin
            if(fm_x == 4) fm_x <= 0;
            else fm_x <= fm_x + 2;
        end 
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      fm_y <= 0;
    end
    else if(state == IDLE) fm_y <= 0;
    else if(state != IDLE && state != MAP) begin
        // if(fm_x == 4) begin
        //     if(fm_y == 5) fm_y <= 0;
        //     else fm_y <= fm_y + 1;
        // end
        if(fm_y == 4 && fm_x == 5)begin
          fm_y <= 0;
        end
        else if(fm_x == 4 && fm_y != 4) begin
          fm_y <= fm_y + 1;
        end
    end
    
end
//fm
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         for(i = 0; i < 6; i++) begin
//             for(j = 0; j < 6; j++) begin
//                 fm[i][j] <= 0;
//             end
//         end
//     end
//     else begin
//         // if(state == CNN || ((fm_x_reg1==2 || fm_x_reg1==4) && fm_y_reg1==5)) begin
//         if(state == IDLE) begin
//             for(i = 0; i < 6; i++) begin
//                 for(j = 0; j < 6; j++) begin
//                     fm[i][j] <= 0;
//                 end
//             end
//         end
//         else if(((local_cnt>=12&&local_cnt<=29) || (local_cnt>=37&&local_cnt<=54) || (local_cnt>=62)) || (state == MP && local_cnt <=16)) begin
//             fm[fm_y_reg0][fm_x_reg0]     <= add_out[0];///////////////////
//             fm[fm_y_reg0][fm_x_reg0 + 1] <= add_out[1];
//         end
//     end
// end
//shift_fm
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 36; i++) begin
            fm[i] <= 0;
        end
    end
    else begin
        // if(state == CNN || ((fm_x_reg1==2 || fm_x_reg1==4) && fm_y_reg1==5)) begin
        if(state == IDLE) begin
            for(i = 0; i < 36; i++) begin
                fm[i] <= 0;
            end
        end
        else if(((local_cnt>=10&&local_cnt<=27) || (local_cnt>=35&&local_cnt<=52) || (local_cnt>=60)) || (state == MP && local_cnt <=16)) begin
            fm[34] <= add_out[0];
            fm[35] <= add_out[1];
            for(i = 0; i < 34; i++) begin
                fm[i] <= fm[i + 2];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 36; i++) begin
            fm_p2[i] <= 0;
        end
    end
    else begin
        // if(state == CNN || ((fm_x_reg1==2 || fm_x_reg1==4) && fm_y_reg1==5)) begin
        if(state == IDLE) begin
            for(i = 0; i < 36; i++) begin
                fm_p2[i] <= 0;
            end
        end
        else if(((local_cnt>=10&&local_cnt<=27) || (local_cnt>=35&&local_cnt<=52) || (local_cnt>=60)) || (state == MP && local_cnt <=16)) begin
            fm_p2[34] <= add_out_p2[0];
            fm_p2[35] <= add_out_p2[1];
            for(i = 0; i < 34; i++) begin
                fm_p2[i] <= fm_p2[i + 2];
            end
        end
    end
end

// //fm_p2
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         for(i = 0; i < 6; i++) begin
//             for(j = 0; j < 6; j++) begin
//                 fm_p2[i][j] <= 0;
//             end
//         end
//     end
//     else begin
//         if(state == IDLE) begin
//             for(i = 0; i < 6; i++) begin
//                 for(j = 0; j < 6; j++) begin
//                     fm_p2[i][j] <= 0;
//                 end
//             end
//         end
//         // if(state == CNN || ((fm_x_reg1==2 || fm_x_reg1==4) && fm_y_reg1==5)) begin
//         else if(((local_cnt>=12&&local_cnt<=29) || (local_cnt>=37&&local_cnt<=54) || (local_cnt>=62)) || (state == MP&& local_cnt <=16)) begin
//             fm_p2[fm_y_reg0][fm_x_reg0]     <= add_out_p2[0];
//             fm_p2[fm_y_reg0][fm_x_reg0 + 1] <= add_out_p2[1];
//         end
//     end
// end

//img
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 5; i++) begin
            for(j = 0; j < 5; j++) begin
                img[i][j] <= 0;
            end
        end
    end
    else begin
        if(in_valid) begin
            img[img_y][img_x] <= Img;
        end
        // else if(state ==MP && local_cnt == 29) begin
        //     for(i = 0; i < 5; i++) begin
        //         for(j = 0; j < 5; j++) begin
        //             img[i][j] <= 0;
        //         end
        //     end
        // end
        // else if(state == MP) begin/////////////////*********************//////////////////////////////
        //     img[0][0] <= add_temp0[0];
        //     img[0][1] <= add_temp1[0];
        //     img[0][2] <= div_out;
        // end
    end 
end

//kernel
always @(posedge clk or negedge rst_n) begin/////cut rst
    if(!rst_n) begin
        for(j = 0; j < 12; j++) begin
            kernel1[j] <= 0;
            kernel2[j] <= 0;
        end
    end
    else begin
        if(state != MP && local_cnt < 16) begin
            kernel1[local_cnt] <= Kernel_ch1;
            kernel2[local_cnt] <= Kernel_ch2;    
        end
        // else if(fm_x == 4 && fm_y == 5) begin
        else if(local_cnt==33 || local_cnt==58) begin
            kernel1[0] <= kernel1[4];
            kernel2[0] <= kernel2[4];
            kernel1[1] <= kernel1[5];
            kernel2[1] <= kernel2[5];
            kernel1[2] <= kernel1[6];
            kernel2[2] <= kernel2[6];
            kernel1[3] <= kernel1[7];
            kernel2[3] <= kernel2[7];
            kernel1[4] <= kernel1[8];
            kernel2[4] <= kernel2[8];
            kernel1[5] <= kernel1[9];
            kernel2[5] <= kernel2[9];
            kernel1[6] <= kernel1[10];
            kernel2[6] <= kernel2[10];
            kernel1[7] <= kernel1[11];
            kernel2[7] <= kernel2[11];
        end
    end 
end

//max_pooling act_temp max

always @(posedge clk) begin
    if(state == IDLE) begin
        mp[0] <= fp_min;
    end
    // else if(local_cnt == 7) mp[0] <= fp_min;
    // else if(state == MP) begin
    //     case (local_cnt % 3)
    //         0:mp[0] <= cmp_out[1];
    //         1:begin
    //             mp[0] <= cmp_out[0];
    //         end
    //         default:mp[0] <=mp[0];
    //     endcase
    // end
    else begin
        case(local_cnt)
            0,3,6,9,12,13,14: begin
              mp[0] <= cmp_out[1];
            end
            1,4,10: begin
              mp[0] <= cmp_out[0];
            end
            7:mp[0] <= fp_min;
            60:mp[0] <= fp_min;
        endcase
    end
end

always @(posedge clk) begin
    if(state == IDLE) begin
        mp[1] <= fp_min;
    end
    // else if(local_cnt == 8) mp[1] <= fp_min;
    // else if(state == MP) begin
    //     case (local_cnt % 3)
    //         1:begin
    //             mp[1] <= cmp_out[1];
    //         end
    //         2:mp[1] <= cmp_out[1];
    //         default:mp[1] <=mp[1];
    //     endcase
    // end
    else begin
        case(local_cnt)
            1,4,7,10: begin
              mp[1] <= cmp_out[1];
            end
            2,5,11,15,16,17: begin
              mp[1] <= cmp_out[1];
            end
            8:mp[1] <= fp_min;
            60:mp[1] <= fp_min;
        endcase
    end
end

//max_pooling act_temp max p2
always @(posedge clk) begin
    if(state == IDLE) begin
        mp_p2[0] <= fp_min;
    end
    // else if(local_cnt == 7) mp_p2[0] <= fp_min;
    // else if(state == MP) begin
    //     case (local_cnt % 3)
    //         0:mp_p2[0] <= cmp_out_p2[1];
    //         1:begin
    //             mp_p2[0] <= cmp_out_p2[0];
    //         end
    //         default:mp_p2[0] <=mp_p2[0];
    //     endcase
    // end
    else begin
        case(local_cnt)
            0,3,6,9,12,13,14: begin
              mp_p2[0] <= cmp_out_p2[1];
            end
            1,4,10: begin
              mp_p2[0] <= cmp_out_p2[0];
            end
            7:mp_p2[0] <= fp_min;
            60:mp_p2[0] <= fp_min;
        endcase
    end
end

always @(posedge clk) begin
    if(state == IDLE) begin
        mp_p2[1] <= fp_min;
    end
    // else if(local_cnt == 8) mp_p2[1] <= fp_min;
    // else if(state == MP) begin
    //     case (local_cnt % 3)
    //         1:begin
    //             mp_p2[1] <= cmp_out_p2[1];
    //         end
    //         2:mp_p2[1] <= cmp_out_p2[1];
    //         default:mp_p2[1] <=mp_p2[1];
    //     endcase
    // end
    else begin
        case(local_cnt)
            1,4,7,10: begin
              mp_p2[1] <= cmp_out_p2[1];
            end
            2,5,11,15,16,17: begin
              mp_p2[1] <= cmp_out_p2[1];
            end
            8:mp_p2[1] <= fp_min;
            60:mp_p2[1] <= fp_min;
        endcase
    end
end






//op
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        option <= 0;
    end
    else begin
        if(in_valid && state == IDLE) begin
            option <= Opt;
        end
    end 
end
//weight
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(j = 0; j < 24; j++) begin
            weight[j] <= 0;
        end
    end
    else begin
        if(in_valid && local_cnt < 24 && state != MP) begin
            weight[23] <= Weight;
            for(j = 0; j < 23; j++) begin
                weight[j] <= weight[j+1]; //shift_reg
            end
        end
        else begin
            weight[23] <= weight[0];
            for(j = 0; j < 23; j++) begin
                weight[j] <= weight[j+1]; //shift_reg
            end
        end
    end 
end
//local_cnt
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_cnt <= 0;
    end
    else begin
        case(state)
            IDLE: begin
              if(in_valid) local_cnt <= local_cnt + 1;
            end
            MAP,CNN: begin
                if(local_cnt == 60) local_cnt <= 0;
                else local_cnt <= local_cnt + 1;
            end
            MP: begin
                if(local_cnt == 29) local_cnt <= 0;
                else local_cnt <= local_cnt + 1;
            end
        endcase
    end 
end

always @(*) begin
    // if(state ==OUT) begin
    //     out_valid = 1;
    //     out = 0;
    // end
    // else begin
    //     out_valid = 0;
    //     out = 0;
    // end
    if(state ==MP && (local_cnt >= 27)) begin
        out_valid = 1;
        out = div_out_reg;
    end
    else begin
        out_valid = 0;
        out = 0;
    end
end







always @(*) begin
    case(local_cnt)
        18: begin
            FC_mul_select[0] = act_temp[0];
            FC_mul_select[1] = act_temp[2];
        end
        19: begin
            FC_mul_select[0] = act_temp[1];
            FC_mul_select[1] = act_temp[3];
        end
        20,21: begin
            FC_mul_select[0] = div_out_reg;
            FC_mul_select[1] = div_out_reg_p2;
        end
        default: begin
            FC_mul_select[0] = 0;
            FC_mul_select[1] = 0;
        end
    endcase
end

always @(posedge clk ) begin
    case(local_cnt)
        0:begin
          for(j = 0; j < 4; j++) begin
            fc_soft_temp[j] <= 0;
            end
        end
        19,20,21,22: begin
            fc_soft_temp[0] <= add_temp2[0];
            fc_soft_temp[1] <= add_temp2[1];
            fc_soft_temp[2] <= add_temp2_p2[0];
        end 
        23: begin
            fc_soft_temp[0] <= exp_out;
            fc_soft_temp[1] <= exp_out_p2;
        end 
        24: begin
            fc_soft_temp[2] <= exp_out;
        end
        25: begin
           fc_soft_temp[3] <= add_temp2_p2[1];
        end
    endcase
end

// reg [31:0] max_cooling[0:7];
// always @(posedge clk ) begin
//     if (global_cnt == 71) begin
//         max_cooling[0] = exp_in;
//         max_cooling[4] = exp_in_p2;
//     end
//     else if (global_cnt == 72) begin
//         max_cooling[1] = exp_in;
//         max_cooling[5] = exp_in_p2;
//     end
//     else if (global_cnt == 80) begin
//         max_cooling[2] = exp_in;
//         max_cooling[6] = exp_in_p2;
//     end
//     else if (global_cnt == 81) begin
//         max_cooling[3] = exp_in;
//         max_cooling[7] = exp_in_p2;
//     end
// end

endmodule


