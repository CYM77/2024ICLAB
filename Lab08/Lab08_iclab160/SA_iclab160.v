/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / SA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SA(
    //Input signals
    clk,
    rst_n,
    cg_en,
    in_valid,
    T,
    in_data,
    w_Q,
    w_K,
    w_V,

    //Output signals
    out_valid,
    out_data
    );

input clk;
input rst_n;
input in_valid;
input cg_en;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
localparam IDLE = 0;
localparam GET_IMG = 1;
localparam CAL_K = 2;
localparam CAL_Q = 3;
localparam CAL_V = 4;
localparam MATMUL2 = 5;
localparam OUT = 6;

genvar a,b;
integer i,j,k;



//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [3:0] T_reg;
reg signed [7:0] img [0:7][0:7];
reg signed [7:0] weight_k [0:7][0:7];
reg signed [7:0] weight_qv [0:7][0:7];
reg signed [7:0] weight_v [0:7][0:7];

reg [2:0] state;
reg [5:0] cnt63;
reg [2:0] cnt7;
reg [1:0] cnt3;
reg [2:0] img_y, img_x;
reg [3:0] T_y;
reg [2:0] T_x;


reg signed [39:0] A [0:7][0:7];
reg signed [18:0] Q [0:7][0:7];
reg signed [18:0] K [0:7][0:7];
reg signed [18:0] V [0:7][0:7];


//==============================================//
wire [7:0] G_img_sleep;
wire [7:0] G_img_clk;

wire [7:0] G_weightQV_sleep;
wire [7:0] G_weightK_sleep;

wire [7:0] G_weightQV_clk;
wire [7:0] G_weightK_clk;


wire [7:0] G_Q_sleep;
wire [7:0] G_Q_clk;
wire [7:0] G_K_sleep;
wire [7:0] G_K_clk;
wire [7:0] G_V_sleep;
wire [7:0] G_V_clk;

wire [7:0] G_A_sleep;
wire [7:0] G_A_clk;

//==============================================//
//                 GATED_OR                     //
//==============================================//
generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_img_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_img_clk[a])
        );
    end
endgenerate

generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_weightQV_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_weightQV_clk[a])
        );
    end
endgenerate
generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_weightK_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_weightK_clk[a])
        );
    end
endgenerate

generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_Q_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_Q_clk[a])
        );
    end
endgenerate
generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_K_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_K_clk[a])
        );
    end
endgenerate
generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_V_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_V_clk[a])
        );
    end
endgenerate
generate
    for(a=0; a<8; a=a+1) begin
        GATED_OR GATED_OR_0(
            // Input signals
            .CLOCK(clk),
            .SLEEP_CTRL(cg_en && G_A_sleep[a]),
            .RST_N(rst_n),
            // Output signals
            .CLOCK_GATED(G_A_clk[a])
        );
    end
endgenerate
//==============================================//
//                  design                      //
//==============================================//
wire y0 = img_y == 0;
wire T4 = T_reg[0] != 1;
wire T8 = T_reg[3] == 1;

generate
    assign G_img_sleep[0] = !((state == IDLE || state == GET_IMG) );
    for(a=1; a<4; a=a+1) begin
        assign G_img_sleep[a] = !((state == GET_IMG));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_img_sleep[a] = !((state == GET_IMG));
    end
endgenerate

generate
    assign G_Q_sleep[0] = !((state == CAL_Q));
    for(a=1; a<4; a=a+1) begin
        assign G_Q_sleep[a] = !((state == CAL_Q));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_Q_sleep[a] = !((state == CAL_Q));
    end
endgenerate

generate
    assign G_K_sleep[0] = !((state == CAL_K));
    for(a=1; a<4; a=a+1) begin
        assign G_K_sleep[a] = !((state == CAL_K));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_K_sleep[a] = !((state == CAL_K));
    end
endgenerate

generate
    assign G_V_sleep[0] = !((state == CAL_V));
    for(a=1; a<4; a=a+1) begin
        assign G_V_sleep[a] = !((state == CAL_V));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_V_sleep[a] = !((state == CAL_V));
    end
endgenerate

generate
    assign G_weightQV_sleep[0] = !((state == IDLE || state == GET_IMG || state == CAL_K));
    for(a=1; a<4; a=a+1) begin
        assign G_weightQV_sleep[a] = !((state == GET_IMG || state == CAL_K));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_weightQV_sleep[a] = !((state == GET_IMG || state == CAL_K));
    end
endgenerate

generate
    assign G_weightK_sleep[0] = !((state == CAL_Q));
    for(a=1; a<4; a=a+1) begin
        assign G_weightK_sleep[a] = !((state == CAL_Q));
    end
    for(a=4; a<8; a=a+1) begin
        assign G_weightK_sleep[a] = !((state == CAL_Q));
    end
endgenerate

generate
    assign G_A_sleep[0] = !(((state == CAL_V))||state==IDLE);
    for(a=1; a<4; a=a+1) begin
        assign G_A_sleep[a] = !((state == CAL_V)||state==IDLE);
    end
    for(a=4; a<8; a=a+1) begin
        assign G_A_sleep[a] = !((state == CAL_V)||state==IDLE);
    end
endgenerate










// generate
//     assign G_weightQV_sleep[0] = !((state == IDLE || state == GET_IMG || state == CAL_V) && img_y == 0);
//     for(a=1; a<8; a=a+1) begin
//         assign G_weightQV_sleep[a] = !((state == GET_IMG || state == CAL_V) && img_y == a);
//     end
// endgenerate

// generate
//     for(a=0; a<8; a=a+1) begin
//         assign G_weightK_sleep[a] = !((state == CAL_Q) && img_y == a);
//     end
// endgenerate




//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////


// //==============================================//
// //       parameter & integer declaration        //
// //==============================================//
// localparam IDLE = 0;
// localparam GET_IMG = 1;
// localparam CAL_K = 2;
// localparam CAL_Q = 3;
// localparam CAL_V = 4;
// localparam MATMUL2 = 5;
// localparam OUT = 6;

// genvar a,b;
// integer i,j,k;
// //==============================================//
// //           reg & wire declaration             //
// //==============================================//
// reg [3:0] T_reg;
// reg signed [7:0] img [0:7][0:7];
// reg signed [7:0] weight_k [0:7][0:7];
// reg signed [7:0] weight_qv [0:7][0:7];
// reg signed [7:0] weight_v [0:7][0:7];

// reg [2:0] state;
// reg [5:0] cnt63;
// reg [2:0] cnt7;
// reg [1:0] cnt3;
// reg [2:0] img_y, img_x;
// reg [3:0] T_y;
// reg [2:0] T_x;


// reg signed [39:0] A [0:7][0:7];
// reg signed [18:0] Q [0:7][0:7];
// reg signed [18:0] K [0:7][0:7];
// reg signed [18:0] V [0:7][0:7];
//==============================================//
//                  design                      //
//==============================================//
reg signed [7:0] mul8_in0 [0:7];
reg signed [7:0] mul8_in1 [0:7];
wire signed [15:0] mul8_out [0:7];

reg signed [15:0] add8_in0 [0:7];
reg signed [15:0] add8_in1 [0:7];
wire signed [18:0] add8_out ;

reg signed [39:0] mul40x19_in0 [0:7];
reg signed [18:0] mul40x19_in1 [0:7];
wire signed [58:0] mul40x19_out [0:7]; 

wire signed [61:0] add40x19_out;

reg signed [61:0] add40x19_out_reg;
// reg signed []

always @(*) begin
	for(i=0; i<8; i=i+1) begin
				mul40x19_in0[i] = 0;
				mul40x19_in1[i] = 0;
			end
	case(state)
		CAL_V: begin
			for(i=0; i<8; i=i+1) begin
				mul40x19_in0[i] = Q[T_y][i];
				mul40x19_in1[i] = K[T_x][i];
			end
		end 
		MATMUL2: begin
			for(i=0; i<8; i=i+1) begin
				mul40x19_in0[i] = A[0][i];
				mul40x19_in1[i] = V[i][T_x];
			end
		end
		OUT: begin
		  	for(i=0; i<8; i=i+1) begin
				mul40x19_in0[i] = A[T_y][i];
				mul40x19_in1[i] = V[i][T_x];
			end
		end
	endcase
end

generate
	for(a=0; a<8; a=a+1) begin
		assign mul40x19_out[a] = mul40x19_in0[a] * mul40x19_in1[a];
	end
endgenerate

assign add40x19_out = (((mul40x19_out[0] + mul40x19_out[1]) + (mul40x19_out[2] + mul40x19_out[3])) + ((mul40x19_out[4] + mul40x19_out[5]) + (mul40x19_out[6] + mul40x19_out[7]))); 
wire signed [39:0] div_out = add40x19_out / 3;

wire signed [39:0] relu_out = (div_out[39] == 1) ? 0 : div_out;

always @(posedge clk) begin
	add40x19_out_reg <= add40x19_out;
end



// always @(*) begin
// 	case(state)
// 		CAL_Q, CAL_K, CAL_V: mul8_in0[0] = img[img_y][img_x];
// 	endcase
// end
// always @(*) begin
// 	case(state)
// 		CAL_Q: mul8_in1[0] = weight_qv[0][0];
// 		CAL_K: mul8_in1[0] = weight_k[0][0];
// 		CAL_V: mul8_in1[0] = weight_qv[0][0];
// 	endcase
// end
// always @(*) begin
// 	for(i=0; i<3; i=i+1) begin
// 		case(state)
// 			CAL_Q, CAL_K, CAL_V: mul8_in0[i+1] = img[img_y][img_x];
// 		endcase
// 	end
// end
// always @(*) begin
// 	for(i=0; i<3; i=i+1) begin
// 		case(state)
// 			CAL_Q: mul8_in1[i+1] = weight_qv[0][i+1];
// 			CAL_K: mul8_in1[i+1] = weight_k[0][i+1];
// 			CAL_V: mul8_in1[i+1] = weight_qv[0][i+1];
// 		endcase
// 	end
// end
// always @(*) begin
// 	for(i=0; i<4; i=i+1) begin
// 		case(state)
// 			CAL_Q, CAL_K, CAL_V: mul8_in0[i+4] = img[img_y][img_x];
// 		endcase
// 	end
// end
// always @(*) begin
// 	for(i=0; i<4; i=i+1) begin
// 		case(state)
// 			CAL_Q: mul8_in1[i+4] = weight_qv[0][i+4];
// 			CAL_K: mul8_in1[i+4] = weight_k[0][i+4];
// 			CAL_V: mul8_in1[i+4] = weight_qv[0][i+4];
// 		endcase
// 	end
// end

always @(*) begin
	for(i=0; i<8; i=i+1) begin
		case(state)
			CAL_Q, CAL_K, CAL_V:  mul8_in0[i] = img[img_y][i];
			default: mul8_in0[i] = 0;
		endcase
	end
end
always @(*) begin
	for(i=0; i<8; i=i+1) begin
		case(state)
			CAL_Q, CAL_V: mul8_in1[i] = weight_qv[i][img_x];
			CAL_K: mul8_in1[i] = weight_k[i][img_x];
			default: mul8_in1[i] = 0;
		endcase
	end
end

generate
	for(a=0; a<8; a=a+1) begin
		assign mul8_out[a] = mul8_in0[a] * mul8_in1[a];
	end
endgenerate

assign add8_out = (((mul8_out[0] + mul8_out[1]) + (mul8_out[2] + mul8_out[3])) + ((mul8_out[4] + mul8_out[5]) + (mul8_out[6] + mul8_out[7])));






always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end
	else begin
		case (state)
			IDLE: begin
				if(in_valid) state <= GET_IMG;
			end 
			GET_IMG: begin
				if(img_y[2:0]==7 && img_x==7 ) state <= CAL_Q;
				else state <= GET_IMG;
			end
			CAL_Q: begin
				if(img_y[2:0]==7 && img_x==7) state <= CAL_K;
				else state <= CAL_Q;
			end
			CAL_K: begin
				if(img_y[2:0]==7 && img_x==7) state <= CAL_V;
				else state <= CAL_K;
			end
			CAL_V: begin
				if(img_y[2:0]==(T_reg-1) && img_x==7) state <= MATMUL2;
				else state <= CAL_V;
			end
			MATMUL2: begin
				state <= OUT;
			end
			OUT: begin
				if(T_y==(T_reg) && T_x==0 ) state <= IDLE;
				else state <= OUT;
			end
		endcase
	end
end


always @(posedge G_A_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for (i = 0; i<8; i=i+1) begin
			A[0][i] <= 0;
		end
	end
	else begin
		if(state == CAL_V) begin
			case ({T_y, T_x})
				{3'd0, 3'd0}: A[0][0] <= relu_out;
				{3'd0, 3'd1}: A[0][1] <= relu_out;
				{3'd0, 3'd2}: A[0][2] <= relu_out;
				{3'd0, 3'd3}: A[0][3] <= relu_out;
				{3'd0, 3'd4}: A[0][4] <= relu_out;
				{3'd0, 3'd5}: A[0][5] <= relu_out;
				{3'd0, 3'd6}: A[0][6] <= relu_out;
				{3'd0, 3'd7}: A[0][7] <= relu_out;
			endcase
		end
		else if(state == IDLE) begin
			for (i = 0; i<8; i=i+1) begin
				A[0][i] <= 0;
			end
		end
	end
end

// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for (i=0; i<3 ; i=i+1) begin
// 			for(j=0; j<8 ; j=j+1) begin
// 				A[i+1][j] <= 0;
// 			end
// 		end
// 	end
// 	else begin
// 		case(state)
// 			IDLE: begin
// 				for (i=0; i<3 ; i=i+1) begin
// 					for(j=0; j<8 ; j=j+1) begin
// 						A[i+1][j] <= 0;
// 					end
// 				end
// 			end
// 			CAL_V: begin
// 				case ({T_y, T_x})
// 				    {3'd1, 3'd0}: A[1][0] <= relu_out;
// 				    {3'd1, 3'd1}: A[1][1] <= relu_out;
// 				    {3'd1, 3'd2}: A[1][2] <= relu_out;
// 				    {3'd1, 3'd3}: A[1][3] <= relu_out;
// 				    {3'd1, 3'd4}: A[1][4] <= relu_out;
// 				    {3'd1, 3'd5}: A[1][5] <= relu_out;
// 				    {3'd1, 3'd6}: A[1][6] <= relu_out;
// 				    {3'd1, 3'd7}: A[1][7] <= relu_out;
// 					{3'd2, 3'd0}: A[2][0] <= relu_out;
// 					{3'd2, 3'd1}: A[2][1] <= relu_out;
// 					{3'd2, 3'd2}: A[2][2] <= relu_out;
// 					{3'd2, 3'd3}: A[2][3] <= relu_out;
// 					{3'd2, 3'd4}: A[2][4] <= relu_out;
// 					{3'd2, 3'd5}: A[2][5] <= relu_out;
// 					{3'd2, 3'd6}: A[2][6] <= relu_out;
// 					{3'd2, 3'd7}: A[2][7] <= relu_out;
// 					{3'd3, 3'd0}: A[3][0] <= relu_out;
// 					{3'd3, 3'd1}: A[3][1] <= relu_out;
// 					{3'd3, 3'd2}: A[3][2] <= relu_out;
// 					{3'd3, 3'd3}: A[3][3] <= relu_out;
// 					{3'd3, 3'd4}: A[3][4] <= relu_out;
// 					{3'd3, 3'd5}: A[3][5] <= relu_out;
// 					{3'd3, 3'd6}: A[3][6] <= relu_out;
// 					{3'd3, 3'd7}: A[3][7] <= relu_out;

// 				endcase
// 			end
// 		endcase
// 	end
// end
generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_A_clk[a] or negedge rst_n) begin
        	if(!rst_n) begin
        		for (i=0; i<8 ; i=i+1) begin
        			A[a][i] <= 0;
        		end
        	end
        	else begin
        		case(state)
        			IDLE: begin
        				for (i=0; i<8 ; i=i+1) begin
        					A[a][i] <= 0;
        				end
        			end
        			CAL_V: begin
        				case ({T_y, T_x})
        				    {a, 3'd0}: A[a][0] <= relu_out;
        				    {a, 3'd1}: A[a][1] <= relu_out;
        				    {a, 3'd2}: A[a][2] <= relu_out;
        				    {a, 3'd3}: A[a][3] <= relu_out;
        				    {a, 3'd4}: A[a][4] <= relu_out;
        				    {a, 3'd5}: A[a][5] <= relu_out;
        				    {a, 3'd6}: A[a][6] <= relu_out;
        				    {a, 3'd7}: A[a][7] <= relu_out;
        				endcase
        			end
        		endcase
        	end
        end
    end
endgenerate
generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_A_clk[a] or negedge rst_n) begin
        	if(!rst_n) begin
        		for (i=0; i<8 ; i=i+1) begin
        			A[a][i] <= 0;
        		end
        	end
        	else begin
        		case(state)
        			IDLE: begin
        				for (i=0; i<8 ; i=i+1) begin
        					A[a][i] <= 0;
        				end
        			end
        			CAL_V: begin
        				case ({T_y, T_x})
        				    {a, 3'd0}: A[a][0] <= relu_out;
        				    {a, 3'd1}: A[a][1] <= relu_out;
        				    {a, 3'd2}: A[a][2] <= relu_out;
        				    {a, 3'd3}: A[a][3] <= relu_out;
        				    {a, 3'd4}: A[a][4] <= relu_out;
        				    {a, 3'd5}: A[a][5] <= relu_out;
        				    {a, 3'd6}: A[a][6] <= relu_out;
        				    {a, 3'd7}: A[a][7] <= relu_out;
        				endcase
        			end
        		endcase
        	end
        end
    end
endgenerate

// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for (i=0; i<4 ; i=i+1) begin
// 			for(j=0; j<8 ; j=j+1) begin
// 				A[i+4][j] <= 0;
// 			end
// 		end
// 	end
// 	else begin
// 		case(state)
// 			IDLE:begin
// 				for (i=0; i<4 ; i=i+1) begin
// 					for(j=0; j<8 ; j=j+1) begin
// 						A[i+4][j] <= 0;
// 					end
// 				end
// 			end
// 			CAL_V: begin
// 				// if(T_y[2] == 1) begin
// 				//   A[T_y][T_x] <= relu_out;
// 				// end	
// 				case({T_y, T_x})
// 					{3'd4, 3'd0}: A[4][0] <= relu_out;
// 					{3'd4, 3'd1}: A[4][1] <= relu_out;
// 					{3'd4, 3'd2}: A[4][2] <= relu_out;
// 					{3'd4, 3'd3}: A[4][3] <= relu_out;
// 					{3'd4, 3'd4}: A[4][4] <= relu_out;
// 					{3'd4, 3'd5}: A[4][5] <= relu_out;
// 					{3'd4, 3'd6}: A[4][6] <= relu_out;
// 					{3'd4, 3'd7}: A[4][7] <= relu_out;
// 					{3'd5, 3'd0}: A[5][0] <= relu_out;
// 					{3'd5, 3'd1}: A[5][1] <= relu_out;
// 					{3'd5, 3'd2}: A[5][2] <= relu_out;
// 					{3'd5, 3'd3}: A[5][3] <= relu_out;
// 					{3'd5, 3'd4}: A[5][4] <= relu_out;
// 					{3'd5, 3'd5}: A[5][5] <= relu_out;
// 					{3'd5, 3'd6}: A[5][6] <= relu_out;
// 					{3'd5, 3'd7}: A[5][7] <= relu_out;
// 					{3'd6, 3'd0}: A[6][0] <= relu_out;
// 					{3'd6, 3'd1}: A[6][1] <= relu_out;
// 					{3'd6, 3'd2}: A[6][2] <= relu_out;
// 					{3'd6, 3'd3}: A[6][3] <= relu_out;
// 					{3'd6, 3'd4}: A[6][4] <= relu_out;
// 					{3'd6, 3'd5}: A[6][5] <= relu_out;
// 					{3'd6, 3'd6}: A[6][6] <= relu_out;
// 					{3'd6, 3'd7}: A[6][7] <= relu_out;
// 					{3'd7, 3'd0}: A[7][0] <= relu_out;
// 					{3'd7, 3'd1}: A[7][1] <= relu_out;
// 					{3'd7, 3'd2}: A[7][2] <= relu_out;
// 					{3'd7, 3'd3}: A[7][3] <= relu_out;
// 					{3'd7, 3'd4}: A[7][4] <= relu_out;
// 					{3'd7, 3'd5}: A[7][5] <= relu_out;
// 					{3'd7, 3'd6}: A[7][6] <= relu_out;
// 					{3'd7, 3'd7}: A[7][7] <= relu_out;
// 				endcase
// 			end
// 		endcase
// 	end
// end

wire stop = img_y >= T_reg;

always @(posedge G_Q_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<8; i=i+1) begin
			Q[0][i] <= 0;
		end
	end
	else begin
		case(state)
			// IDLE:begin
			//   	for(i=0; i<8; i=i+1) begin
			// 		for(j=0; j<8; j=j+1) begin
			// 			Q[i][j] <= 0;
			// 		end
			// 	end
			// end
			CAL_Q: begin
                if(!stop)begin
			    	// Q[img_y][img_x] <= add8_out;
                    case ({img_y, img_x})
                    	{3'd0, 3'd0}: Q[0][0] <= add8_out;
                    	{3'd0, 3'd1}: Q[0][1] <= add8_out;
                    	{3'd0, 3'd2}: Q[0][2] <= add8_out;
                    	{3'd0, 3'd3}: Q[0][3] <= add8_out;
                    	{3'd0, 3'd4}: Q[0][4] <= add8_out;
                    	{3'd0, 3'd5}: Q[0][5] <= add8_out;
                    	{3'd0, 3'd6}: Q[0][6] <= add8_out;
                    	{3'd0, 3'd7}: Q[0][7] <= add8_out;
                    endcase
			    end
            end 
		endcase
	end
end

generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_Q_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	Q[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_Q: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: Q[a][0] <= add8_out;
                            	{a, 3'd1}: Q[a][1] <= add8_out;
                            	{a, 3'd2}: Q[a][2] <= add8_out;
                            	{a, 3'd3}: Q[a][3] <= add8_out;
                            	{a, 3'd4}: Q[a][4] <= add8_out;
                            	{a, 3'd5}: Q[a][5] <= add8_out;
                            	{a, 3'd6}: Q[a][6] <= add8_out;
                            	{a, 3'd7}: Q[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate


generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_Q_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	Q[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_Q: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: Q[a][0] <= add8_out;
                            	{a, 3'd1}: Q[a][1] <= add8_out;
                            	{a, 3'd2}: Q[a][2] <= add8_out;
                            	{a, 3'd3}: Q[a][3] <= add8_out;
                            	{a, 3'd4}: Q[a][4] <= add8_out;
                            	{a, 3'd5}: Q[a][5] <= add8_out;
                            	{a, 3'd6}: Q[a][6] <= add8_out;
                            	{a, 3'd7}: Q[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate


always @(posedge G_K_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<8; i=i+1) begin
			K[0][i] <= 0;
		end
	end
	else begin
		case(state)
			// IDLE:begin
			//   	for(i=0; i<8; i=i+1) begin
			// 		for(j=0; j<8; j=j+1) begin
			// 			Q[i][j] <= 0;
			// 		end
			// 	end
			// end
			CAL_K: begin
                if(!stop)begin
			    	// Q[img_y][img_x] <= add8_out;
                    case ({img_y, img_x})
                    	{3'd0, 3'd0}: K[0][0] <= add8_out;
                    	{3'd0, 3'd1}: K[0][1] <= add8_out;
                    	{3'd0, 3'd2}: K[0][2] <= add8_out;
                    	{3'd0, 3'd3}: K[0][3] <= add8_out;
                    	{3'd0, 3'd4}: K[0][4] <= add8_out;
                    	{3'd0, 3'd5}: K[0][5] <= add8_out;
                    	{3'd0, 3'd6}: K[0][6] <= add8_out;
                    	{3'd0, 3'd7}: K[0][7] <= add8_out;
                    endcase
			    end
            end 
		endcase
	end
end

generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_K_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	K[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_K: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: K[a][0] <= add8_out;
                            	{a, 3'd1}: K[a][1] <= add8_out;
                            	{a, 3'd2}: K[a][2] <= add8_out;
                            	{a, 3'd3}: K[a][3] <= add8_out;
                            	{a, 3'd4}: K[a][4] <= add8_out;
                            	{a, 3'd5}: K[a][5] <= add8_out;
                            	{a, 3'd6}: K[a][6] <= add8_out;
                            	{a, 3'd7}: K[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate
generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_K_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	K[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_K: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: K[a][0] <= add8_out;
                            	{a, 3'd1}: K[a][1] <= add8_out;
                            	{a, 3'd2}: K[a][2] <= add8_out;
                            	{a, 3'd3}: K[a][3] <= add8_out;
                            	{a, 3'd4}: K[a][4] <= add8_out;
                            	{a, 3'd5}: K[a][5] <= add8_out;
                            	{a, 3'd6}: K[a][6] <= add8_out;
                            	{a, 3'd7}: K[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate


always @(posedge G_V_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<8; i=i+1) begin
			V[0][i] <= 0;
		end
	end
	else begin
		case(state)
			// IDLE:begin
			//   	for(i=0; i<8; i=i+1) begin
			// 		for(j=0; j<8; j=j+1) begin
			// 			Q[i][j] <= 0;
			// 		end
			// 	end
			// end
			CAL_V: begin
                if(!stop)begin
			    	// Q[img_y][img_x] <= add8_out;
                    case ({img_y, img_x})
                    	{3'd0, 3'd0}: V[0][0] <= add8_out;
                    	{3'd0, 3'd1}: V[0][1] <= add8_out;
                    	{3'd0, 3'd2}: V[0][2] <= add8_out;
                    	{3'd0, 3'd3}: V[0][3] <= add8_out;
                    	{3'd0, 3'd4}: V[0][4] <= add8_out;
                    	{3'd0, 3'd5}: V[0][5] <= add8_out;
                    	{3'd0, 3'd6}: V[0][6] <= add8_out;
                    	{3'd0, 3'd7}: V[0][7] <= add8_out;
                    endcase
			    end
            end 
		endcase
	end
end

generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_V_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	V[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_V: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: V[a][0] <= add8_out;
                            	{a, 3'd1}: V[a][1] <= add8_out;
                            	{a, 3'd2}: V[a][2] <= add8_out;
                            	{a, 3'd3}: V[a][3] <= add8_out;
                            	{a, 3'd4}: V[a][4] <= add8_out;
                            	{a, 3'd5}: V[a][5] <= add8_out;
                            	{a, 3'd6}: V[a][6] <= add8_out;
                            	{a, 3'd7}: V[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate
generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_V_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	V[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	// IDLE:begin
		        	//   	for(i=0; i<8; i=i+1) begin
		        	// 		for(j=0; j<8; j=j+1) begin
		        	// 			Q[i][j] <= 0;
		        	// 		end
		        	// 	end
		        	// end
		        	CAL_V: begin
                        if(!stop)begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: V[a][0] <= add8_out;
                            	{a, 3'd1}: V[a][1] <= add8_out;
                            	{a, 3'd2}: V[a][2] <= add8_out;
                            	{a, 3'd3}: V[a][3] <= add8_out;
                            	{a, 3'd4}: V[a][4] <= add8_out;
                            	{a, 3'd5}: V[a][5] <= add8_out;
                            	{a, 3'd6}: V[a][6] <= add8_out;
                            	{a, 3'd7}: V[a][7] <= add8_out;
                            endcase
		        	    end
                    end 
		        endcase
            end
        end
    end
endgenerate


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt63 <= 0;
	end
	else begin
		case (state)
			IDLE: cnt63 <= (in_valid) ? 1 : 0;
			default: cnt63 <= cnt63 + 1;
		endcase
	end
end


always @(posedge G_img_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[0][i] <= 0;
		end
	end
	else begin
		case(state)
			IDLE: begin
				img[0][0] <= (in_valid) ? in_data : 0;
			end
			GET_IMG: begin
				case ({img_y, img_x})
					{3'd0, 3'd0}: img[0][0] <= in_data;
					{3'd0, 3'd1}: img[0][1] <= in_data;
					{3'd0, 3'd2}: img[0][2] <= in_data;
					{3'd0, 3'd3}: img[0][3] <= in_data;
					{3'd0, 3'd4}: img[0][4] <= in_data;
					{3'd0, 3'd5}: img[0][5] <= in_data;
					{3'd0, 3'd6}: img[0][6] <= in_data;
					{3'd0, 3'd7}: img[0][7] <= in_data;
				endcase
			end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[0][i] <= ~img[0][i];
		    //     end
            // end
		endcase
	end
end


always @(posedge G_img_clk[1] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[1][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd1, 3'd0}: img[1][0] <= in_data;
                    {3'd1, 3'd1}: img[1][1] <= in_data;
                    {3'd1, 3'd2}: img[1][2] <= in_data;
                    {3'd1, 3'd3}: img[1][3] <= in_data;
                    {3'd1, 3'd4}: img[1][4] <= in_data;
                    {3'd1, 3'd5}: img[1][5] <= in_data;
                    {3'd1, 3'd6}: img[1][6] <= in_data;
                    {3'd1, 3'd7}: img[1][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[1][i] <= ~img[1][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[2] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[2][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd2, 3'd0}: img[2][0] <= in_data;
                    {3'd2, 3'd1}: img[2][1] <= in_data;
                    {3'd2, 3'd2}: img[2][2] <= in_data;
                    {3'd2, 3'd3}: img[2][3] <= in_data;
                    {3'd2, 3'd4}: img[2][4] <= in_data;
                    {3'd2, 3'd5}: img[2][5] <= in_data;
                    {3'd2, 3'd6}: img[2][6] <= in_data;
                    {3'd2, 3'd7}: img[2][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[2][i] <= ~img[2][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[3] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[3][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd3, 3'd0}: img[3][0] <= in_data;
                    {3'd3, 3'd1}: img[3][1] <= in_data;
                    {3'd3, 3'd2}: img[3][2] <= in_data;
                    {3'd3, 3'd3}: img[3][3] <= in_data;
                    {3'd3, 3'd4}: img[3][4] <= in_data;
                    {3'd3, 3'd5}: img[3][5] <= in_data;
                    {3'd3, 3'd6}: img[3][6] <= in_data;
                    {3'd3, 3'd7}: img[3][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[3][i] <= ~img[3][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[4] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[4][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd4, 3'd0}: img[4][0] <= in_data;
                    {3'd4, 3'd1}: img[4][1] <= in_data;
                    {3'd4, 3'd2}: img[4][2] <= in_data;
                    {3'd4, 3'd3}: img[4][3] <= in_data;
                    {3'd4, 3'd4}: img[4][4] <= in_data;
                    {3'd4, 3'd5}: img[4][5] <= in_data;
                    {3'd4, 3'd6}: img[4][6] <= in_data;
                    {3'd4, 3'd7}: img[4][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[4][i] <= ~img[4][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[5] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[5][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd5, 3'd0}: img[5][0] <= in_data;
                    {3'd5, 3'd1}: img[5][1] <= in_data;
                    {3'd5, 3'd2}: img[5][2] <= in_data;
                    {3'd5, 3'd3}: img[5][3] <= in_data;
                    {3'd5, 3'd4}: img[5][4] <= in_data;
                    {3'd5, 3'd5}: img[5][5] <= in_data;
                    {3'd5, 3'd6}: img[5][6] <= in_data;
                    {3'd5, 3'd7}: img[5][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[5][i] <= ~img[5][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[6] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[6][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd6, 3'd0}: img[6][0] <= in_data;
                    {3'd6, 3'd1}: img[6][1] <= in_data;
                    {3'd6, 3'd2}: img[6][2] <= in_data;
                    {3'd6, 3'd3}: img[6][3] <= in_data;
                    {3'd6, 3'd4}: img[6][4] <= in_data;
                    {3'd6, 3'd5}: img[6][5] <= in_data;
                    {3'd6, 3'd6}: img[6][6] <= in_data;
                    {3'd6, 3'd7}: img[6][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[6][i] <= ~img[6][i];
		    //     end
            // end
        endcase
	end
end
always @(posedge G_img_clk[7] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			img[7][i] <= 0;
		end
	end
	else begin
		case(state)
            GET_IMG: begin
                case ({img_y, img_x})
                    {3'd7, 3'd0}: img[7][0] <= in_data;
                    {3'd7, 3'd1}: img[7][1] <= in_data;
                    {3'd7, 3'd2}: img[7][2] <= in_data;
                    {3'd7, 3'd3}: img[7][3] <= in_data;
                    {3'd7, 3'd4}: img[7][4] <= in_data;
                    {3'd7, 3'd5}: img[7][5] <= in_data;
                    {3'd7, 3'd6}: img[7][6] <= in_data;
                    {3'd7, 3'd7}: img[7][7] <= in_data;
			    endcase
            end
            // MATMUL2, OUT: begin
            //     for (i=0; i<8 ; i=i+1) begin
		    //     	img[7][i] <= ~img[7][i];
		    //     end
            // end
        endcase
	end
end



always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		img_x <= 0;
	end
	else begin
		case (state)
			IDLE: begin
				img_x <= (in_valid) ? 1: 0;
			end 
			GET_IMG, CAL_K, CAL_Q, CAL_V, OUT: begin
				img_x <= img_x + 1;
			end
			// CAL_V: begin
			// 	case(T_reg)
			// 		0: img_x <= (img_x == 0) ? 0 : img_x + 1;
			// 		1: img_x <= (img_x == 3) ? 0 : img_x + 1;
			// 		2: img_x <= (img_x == 7) ? 0 : img_x + 1;
			// 	endcase
			// end
			default: img_x <= 0;
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		img_y <= 0;
	end
	else begin
		case (state)
			GET_IMG, CAL_K, CAL_Q, CAL_V, OUT : begin
				img_y <= (img_x == 7) ? img_y + 1 : img_y;
			end
			// MATMUL2: begin
			// 	case(T_reg)
			// 		0: img_y <= (img_x == 0) ? 0 : img_y + 1;
			// 		1: img_y <= (img_x == 3) ? 0 : img_y + 1;
			// 		2: img_y <= (img_x == 7) ? 0 : img_y + 1;
			// 	endcase
			// end
			default: img_y <= 0;
		endcase
	end
end

wire T_stop = (T_y >= T_reg) ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		T_y <= 0;
	end
	else begin
		case(state)
			CAL_V: begin
				if(!T_stop) begin
					case(T_reg)
						1: T_y <= (T_x == 0) ? T_y + 1 : T_y;
						4: T_y <= (T_x == 3) ? T_y + 1 : T_y;
						8: T_y <= (T_x == 7) ? T_y + 1 : T_y;
					endcase
				end
			end
			OUT:begin
				// T_y <= (T_x == 7) ? T_y + 1 : T_y;
				if(T_x == 7) begin
					  T_y <= T_y + 1;
				end
			end
			default: T_y <= 0;
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		T_x <= 0;
	end
	else begin
		case(state)
			CAL_V: begin
				if(!T_stop) begin
					case(T_reg)
						1: T_x <= (T_x == 0) ? 0 : T_x + 1;
						4: T_x <= (T_x == 3) ? 0 : T_x + 1;
						8: T_x <= (T_x == 7) ? 0 : T_x + 1;
					endcase
				end
			end
			MATMUL2: T_x <= 1;
			OUT: T_x <= (T_x == 7) ? 0 : T_x + 1;
			default: T_x <= 0;
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		T_reg <= 0;
	end
	else begin
		if(state == IDLE && in_valid) begin
			// case(T)
			// 	1: T_reg <= 0;
			// 	4: T_reg <= 1;
			// 	8: T_reg <= 2;
			// endcase
			T_reg <= T;
		end
	end
end

// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for (i=0; i<8 ; i=i+1) begin
// 			for (j=0; j<8 ; j=j+1) begin
// 				weight_qv[i][j] <= 0;
// 			end
// 		end
// 	end
// 	else begin
// 		case (state)
// 			IDLE: weight_qv[0][0] <= (in_valid==1) ? w_Q : 0;
// 			GET_IMG: begin
// 				weight_qv[img_y][img_x] <= w_Q;
// 			end
// 			CAL_K:weight_qv[img_y][img_x] <= w_V;
// 		endcase

// 	end
// end

always @(posedge G_weightQV_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
			weight_qv[0][i] <= 0;
		end
	end
	else begin
		case (state)
			IDLE: weight_qv[0][0] <= (in_valid==1) ? w_Q : 0;
			GET_IMG: begin
                case ({img_y, img_x})
                	{3'd0, 3'd0}: weight_qv[0][0] <= w_Q;
                	{3'd0, 3'd1}: weight_qv[0][1] <= w_Q;
                	{3'd0, 3'd2}: weight_qv[0][2] <= w_Q;
                	{3'd0, 3'd3}: weight_qv[0][3] <= w_Q;
                	{3'd0, 3'd4}: weight_qv[0][4] <= w_Q;
                	{3'd0, 3'd5}: weight_qv[0][5] <= w_Q;
                	{3'd0, 3'd6}: weight_qv[0][6] <= w_Q;
                	{3'd0, 3'd7}: weight_qv[0][7] <= w_Q;
                endcase
				// weight_qv[img_y][img_x] <= w_Q;
			end
			CAL_K:begin
                case ({img_y, img_x})
                	{3'd0, 3'd0}: weight_qv[0][0] <= w_V;
                	{3'd0, 3'd1}: weight_qv[0][1] <= w_V;
                	{3'd0, 3'd2}: weight_qv[0][2] <= w_V;
                	{3'd0, 3'd3}: weight_qv[0][3] <= w_V;
                	{3'd0, 3'd4}: weight_qv[0][4] <= w_V;
                	{3'd0, 3'd5}: weight_qv[0][5] <= w_V;
                	{3'd0, 3'd6}: weight_qv[0][6] <= w_V;
                	{3'd0, 3'd7}: weight_qv[0][7] <= w_V;
                endcase
            end
            // weight_qv[img_y][img_x] <= w_V;
		endcase

	end
end

generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_weightQV_clk[a] or negedge rst_n) begin
        	if(!rst_n) begin
        		for (i=0; i<8 ; i=i+1) begin
        			weight_qv[a][i] <= 0;
        		end
        	end
        	else begin
        		case (state)
        			GET_IMG: begin
                        case ({img_y, img_x})
                        	{a, 3'd0}: weight_qv[a][0] <= w_Q;
                        	{a, 3'd1}: weight_qv[a][1] <= w_Q;
                        	{a, 3'd2}: weight_qv[a][2] <= w_Q;
                        	{a, 3'd3}: weight_qv[a][3] <= w_Q;
                        	{a, 3'd4}: weight_qv[a][4] <= w_Q;
                        	{a, 3'd5}: weight_qv[a][5] <= w_Q;
                        	{a, 3'd6}: weight_qv[a][6] <= w_Q;
                        	{a, 3'd7}: weight_qv[a][7] <= w_Q;
                        endcase
        				// weight_qv[img_y][img_x] <= w_Q;
        			end
        			CAL_K:begin
                        case ({img_y, img_x})
                        	{a, 3'd0}: weight_qv[a][0] <= w_V;
                        	{a, 3'd1}: weight_qv[a][1] <= w_V;
                        	{a, 3'd2}: weight_qv[a][2] <= w_V;
                        	{a, 3'd3}: weight_qv[a][3] <= w_V;
                        	{a, 3'd4}: weight_qv[a][4] <= w_V;
                        	{a, 3'd5}: weight_qv[a][5] <= w_V;
                        	{a, 3'd6}: weight_qv[a][6] <= w_V;
                        	{a, 3'd7}: weight_qv[a][7] <= w_V;
                        endcase
                    end
                    // weight_qv[img_y][img_x] <= w_V;
        		endcase

        	end
        end
    end
endgenerate

generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_weightQV_clk[a] or negedge rst_n) begin
        	if(!rst_n) begin
        		for (i=0; i<8 ; i=i+1) begin
        			weight_qv[a][i] <= 0;
        		end
        	end
        	else begin
        		case (state)
        			GET_IMG: begin
                        case ({img_y, img_x})
                        	{a, 3'd0}: weight_qv[a][0] <= w_Q;
                        	{a, 3'd1}: weight_qv[a][1] <= w_Q;
                        	{a, 3'd2}: weight_qv[a][2] <= w_Q;
                        	{a, 3'd3}: weight_qv[a][3] <= w_Q;
                        	{a, 3'd4}: weight_qv[a][4] <= w_Q;
                        	{a, 3'd5}: weight_qv[a][5] <= w_Q;
                        	{a, 3'd6}: weight_qv[a][6] <= w_Q;
                        	{a, 3'd7}: weight_qv[a][7] <= w_Q;
                        endcase
        				// weight_qv[img_y][img_x] <= w_Q;
        			end
        			CAL_K:begin
                        case ({img_y, img_x})
                        	{a, 3'd0}: weight_qv[a][0] <= w_V;
                        	{a, 3'd1}: weight_qv[a][1] <= w_V;
                        	{a, 3'd2}: weight_qv[a][2] <= w_V;
                        	{a, 3'd3}: weight_qv[a][3] <= w_V;
                        	{a, 3'd4}: weight_qv[a][4] <= w_V;
                        	{a, 3'd5}: weight_qv[a][5] <= w_V;
                        	{a, 3'd6}: weight_qv[a][6] <= w_V;
                        	{a, 3'd7}: weight_qv[a][7] <= w_V;
                        endcase
                    end
                    // weight_qv[img_y][img_x] <= w_V;
        		endcase

        	end
        end
    end
endgenerate






always @(posedge G_weightK_clk[0] or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<8 ; i=i+1) begin
				weight_k[0][i] <= 0;
		end
	end
	else begin
		if(state == CAL_Q) begin
            case ({img_y, img_x})
            	{3'd0, 3'd0}: weight_k[0][0] <= w_K;
            	{3'd0, 3'd1}: weight_k[0][1] <= w_K;
            	{3'd0, 3'd2}: weight_k[0][2] <= w_K;
            	{3'd0, 3'd3}: weight_k[0][3] <= w_K;
            	{3'd0, 3'd4}: weight_k[0][4] <= w_K;
            	{3'd0, 3'd5}: weight_k[0][5] <= w_K;
            	{3'd0, 3'd6}: weight_k[0][6] <= w_K;
            	{3'd0, 3'd7}: weight_k[0][7] <= w_K;
            endcase
        end 
	end
end

generate
    for(a=1; a<4; a=a+1) begin
        always @(posedge G_weightK_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	weight_k[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	CAL_Q: begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: weight_k[a][0] <= w_K;
                            	{a, 3'd1}: weight_k[a][1] <= w_K;
                            	{a, 3'd2}: weight_k[a][2] <= w_K;
                            	{a, 3'd3}: weight_k[a][3] <= w_K;
                            	{a, 3'd4}: weight_k[a][4] <= w_K;
                            	{a, 3'd5}: weight_k[a][5] <= w_K;
                            	{a, 3'd6}: weight_k[a][6] <= w_K;
                            	{a, 3'd7}: weight_k[a][7] <= w_K;
                            endcase
                    end 
		        endcase
            end
        end
    end
endgenerate

generate
    for(a=4; a<8; a=a+1) begin
        always @(posedge G_weightK_clk[a] or negedge rst_n) begin
            if(!rst_n) begin
		        for (i=0; i<8 ; i=i+1) begin
		        	weight_k[a][i] <= 0;
		        end
	        end
            else begin
                case(state)
		        	CAL_Q: begin
		        	    	// Q[img_y][img_x] <= add8_out;
                            case ({img_y, img_x})
                            	{a, 3'd0}: weight_k[a][0] <= w_K;
                            	{a, 3'd1}: weight_k[a][1] <= w_K;
                            	{a, 3'd2}: weight_k[a][2] <= w_K;
                            	{a, 3'd3}: weight_k[a][3] <= w_K;
                            	{a, 3'd4}: weight_k[a][4] <= w_K;
                            	{a, 3'd5}: weight_k[a][5] <= w_K;
                            	{a, 3'd6}: weight_k[a][6] <= w_K;
                            	{a, 3'd7}: weight_k[a][7] <= w_K;
                            endcase
		        	    end
		        endcase
            end
        end
    end
endgenerate



always @(*) begin
	if(state == OUT) begin
		out_valid = 1;
		out_data = add40x19_out_reg;
	end
	else begin
		out_valid = 0;
		out_data = 0;
	end
end
endmodule

