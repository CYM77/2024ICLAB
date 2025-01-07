/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;
output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;



//////////////////////////////////
//////////1 CYCLE_w/2 state////////////////
//////////////////////////////////
//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
localparam IDLE = 0;
localparam DOWN_and_OUT = 1;

integer i;
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg state;
reg [5:0] map [0:13];
reg [5:0] n_map [0:13];
reg [3:0] top [0:5];
reg [3:0] set_cnt;

wire [11:0] row_full;

assign row_full[0]  = &map[0];
assign row_full[1]  = &map[1];
assign row_full[2]  = &map[2];
assign row_full[3]  = &map[3];
assign row_full[4]  = &map[4];
assign row_full[5]  = &map[5];
assign row_full[6]  = &map[6];
assign row_full[7]  = &map[7];
assign row_full[8]  = &map[8];
assign row_full[9]  = &map[9];
assign row_full[10] = &map[10];
assign row_full[11] = &map[11];

// wire [11:0] n_row_full;

// assign n_row_full[0]  = &n_map[0];
// assign n_row_full[1]  = &n_map[1];
// assign n_row_full[2]  = &n_map[2];
// assign n_row_full[3]  = &n_map[3];
// assign n_row_full[4]  = &n_map[4];
// assign n_row_full[5]  = &n_map[5];
// assign n_row_full[6]  = &n_map[6];
// assign n_row_full[7]  = &n_map[7];
// assign n_row_full[8]  = &n_map[8];
// assign n_row_full[9]  = &n_map[9];
// assign n_row_full[10] = &n_map[10];
// assign n_row_full[11] = &n_map[11];

// wire cut_flag = |n_row_full;

reg [3:0] cut_level;
reg [2:0] temp_score;
reg [3:0] cmp_in0,cmp_in1,cmp_in2,cmp_in3,cmp_out;



//share cmp
always @(*) begin
	case(tetrominoes)
		0: begin
			cmp_in0 = top[position];
			cmp_in1 = top[position+1];
			cmp_in2 = 0;
			cmp_in3 = 0;
		end
		1: begin
			cmp_in0 = top[position];
			cmp_in1 = 0;
			cmp_in2 = 0;
			cmp_in3 = 0;
		end
		2: begin
			cmp_in0 = top[position];
			cmp_in1 = top[position+1];
			cmp_in2 = top[position+2];
			cmp_in3 = top[position+3];
		end
		3: begin
			cmp_in0 = top[position];
			cmp_in1 = top[position+1]+2;
			cmp_in2 = 0;
			cmp_in3 = 0;
		end
		4: begin//+1
			cmp_in0 = top[position] + 1;
			cmp_in1 = top[position+1];
			cmp_in2 = top[position+2];
			cmp_in3 = 1;
		end
		5: begin
			cmp_in0 = top[position];
			cmp_in1 = top[position+1];
			cmp_in2 = 0;
			cmp_in3 = 0;
		end
		6: begin
			cmp_in0 = top[position];
			cmp_in1 = top[position+1]+1;
			cmp_in2 = 0;
			cmp_in3 = 0;			
		end
		7: begin//+1
			cmp_in0 = top[position]+1;
			cmp_in1 = top[position+1]+1;
			cmp_in2 = top[position+2];
			cmp_in3 = 1;
		end
	endcase
end

CMP4 PP0(.in0(cmp_in0), .in1(cmp_in1),.in2(cmp_in2), .in3(cmp_in3), .out(cmp_out));

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end
	else begin
		case(state)
			IDLE: begin
				if(in_valid) begin
					// if(/*(tetrominoes==1 && top[position]>11) ||*/ cut_flag == 0) state <= DOWN_and_OUT;
					state <= DOWN_and_OUT;
				end 
			end
			DOWN_and_OUT: begin
				if(cut_level == 12) state <= IDLE;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i < 15 ; i++) begin
		  	map[i] <= 0;
		end
	end
	else begin
		for(i=0; i < 15 ; i++) begin
		  	map[i] <= n_map[i];
		end
	end
end

//map
always @(*) begin
	for(i=0; i < 15 ; i++) begin
	  	n_map[i] = map[i];
	end
	case(state)
		IDLE: begin
			if(in_valid) begin
				case(tetrominoes)
					0: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out+1][position] = 1;
						n_map[cmp_out+1][position+1] = 1;
					end
					1: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out+1][position] = 1;
						n_map[cmp_out+2][position] = 1;
						n_map[cmp_out+3][position] = 1;
					end
					2: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out][position+2] = 1;
						n_map[cmp_out][position+3] = 1;
					end
					3: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out-1][position+1] = 1;//-1 = 4'b1111
						n_map[cmp_out-2][position+1] = 1;//-2 = 4'b1110
					end
					4: begin
						/////////CMP////////////-1
						n_map[cmp_out-1][position] = 1;//-1 = 4'b1111
						n_map[cmp_out][position] = 1;
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out][position+2] = 1;
					end
					5: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out+1][position] = 1;
						n_map[cmp_out+2][position] = 1;
						n_map[cmp_out][position+1] = 1;
					end
					6: begin
						n_map[cmp_out][position] = 1;
						n_map[cmp_out+1][position] = 1;
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out-1][position+1] = 1;//-1 = 4'b1111
					end
					7: begin
						/////////CMP////////////-1
						n_map[cmp_out-1][position] = 1;//-1 = 4'b1111
						n_map[cmp_out-1][position+1] = 1;//-1 = 4'b1111
						n_map[cmp_out][position+1] = 1;
						n_map[cmp_out][position+2] = 1;
					end
				endcase
			end
		end
		DOWN_and_OUT: begin
			if((set_cnt == 15 || fail == 1)&&cut_level==12)begin
				for(i=0; i < 15 ; i++) begin
				  	n_map[i] = 0;
				end
			end
			else begin
				if     (row_full[11] )begin
					for(i=11; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[10] )begin
					for(i=10; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[9] )begin
					for(i=9; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[8] )begin
					for(i=8; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[7] )begin
					for(i=7; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[6] )begin
					for(i=6; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[5] )begin
					for(i=5; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[4] )begin
					for(i=4; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[3] )begin
					for(i=3; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[2] )begin
					for(i=2; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[1])begin
					for(i=1; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else if(row_full[0])begin
					for(i=0; i < 13 ; i++) begin
					    n_map[i] = map[i+1];
					end
				end 
				else begin
					for(i=0; i < 13 ; i++) begin
					    n_map[i] = map[i];
					end
				end //don't need to cut
				n_map[13] = 0;
			end
			
		end
	endcase
end

//top
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for(i=0; i < 6 ; i++) begin
// 		  top[i] <= 0;
// 		end
// 	end
// 	else begin
// 		if(state == DOWN_and_OUT) begin//fail or cnt==16 change to 0
// 			if((set_cnt != 15 && fail != 1) && cut_level == 12) begin
// 				for(i=0; i < 6 ; i++) begin
// 					if(map[11][i])      top[i] <= 12;
// 					else if(map[10][i]) top[i] <= 11;
// 					else if(map[9][i])  top[i] <= 10;
// 					else if(map[8][i])  top[i] <= 9;
// 					else if(map[7][i])  top[i] <= 8;
// 					else if(map[6][i])  top[i] <= 7;
// 					else if(map[5][i])  top[i] <= 6;
// 					else if(map[4][i])  top[i] <= 5;
// 					else if(map[3][i])  top[i] <= 4;
// 					else if(map[2][i])  top[i] <= 3;
// 					else if(map[1][i])  top[i] <= 2;
// 					else if(map[0][i])  top[i] <= 1;
// 					else top[i] <= 0; 
// 				end
// 			end
// 			else begin
// 				for(i=0; i < 6 ; i++) begin
// 				  	top[i] <= 0;
// 				end
// 			end
// 		end
// 	end
// end

always @(*) begin
	for(i=0; i < 6 ; i++) begin
	if(map[11][i])      top[i] = 12;
	else if(map[10][i]) top[i] = 11;
	else if(map[9][i])  top[i] = 10;
	else if(map[8][i])  top[i] = 9;
	else if(map[7][i])  top[i] = 8;
	else if(map[6][i])  top[i] = 7;
	else if(map[5][i])  top[i] = 6;
	else if(map[4][i])  top[i] = 5;
	else if(map[3][i])  top[i] = 4;
	else if(map[2][i])  top[i] = 3;
	else if(map[1][i])  top[i] = 2;
	else if(map[0][i])  top[i] = 1;
	else top[i] = 0; 
end
end



//set_cnt
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		  set_cnt <= 0;
	end
	else begin
		if(state == DOWN_and_OUT && cut_level == 12) begin
			if(fail) set_cnt <= 0;
			else set_cnt <= set_cnt + 1;
		end
	end
end

//cut_level
always @(*) begin
	if     (row_full[0] ) cut_level = 0;
	else if(row_full[1] ) cut_level = 1;
	else if(row_full[2] ) cut_level = 2;
	else if(row_full[3] ) cut_level = 3;
	else if(row_full[4] ) cut_level = 4;
	else if(row_full[5] ) cut_level = 5;
	else if(row_full[6] ) cut_level = 6;
	else if(row_full[7] ) cut_level = 7;
	else if(row_full[8] ) cut_level = 8;
	else if(row_full[9] ) cut_level = 9;
	else if(row_full[10]) cut_level = 10;
	else if(row_full[11]) cut_level = 11;
	else cut_level = 12;//don't need to cut
end

//temp_score
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		  temp_score <= 0;
	end
	else begin
		if(state == DOWN_and_OUT) begin
			if(cut_level != 12) begin
				temp_score <= temp_score + 1;
			end
			else if(set_cnt == 15 || fail == 1) begin
				temp_score <= 0;
			end
		end
	end
end

always @(*) begin
	if(state == DOWN_and_OUT && map[12]&& cut_level == 12) begin
		fail = 1;
	end
	else fail = 0;
end

always @(*) begin
	if(state == DOWN_and_OUT && cut_level == 12) begin
		score = temp_score;
	end
	else score = 0;
end

always @(*) begin
	if(state == DOWN_and_OUT && cut_level == 12) begin
		score_valid = 1;
	end
	else score_valid = 0;
end

always @(*) begin
	if(state == DOWN_and_OUT && cut_level == 12 && (set_cnt == 15 || fail == 1)) begin
		tetris_valid = 1;
	end
	else tetris_valid = 0;
end

always @(*) begin
	if(state == DOWN_and_OUT && cut_level == 12 && (set_cnt == 15 || fail)) begin
		tetris = {map[11],map[10],map[9],map[8],map[7],map[6],map[5],map[4],map[3],map[2],map[1],map[0]};
	end
	else tetris = 0;
end

endmodule

module CMP4(input [3:0] in0,
			input [3:0] in1,
			input [3:0] in2,
			input [3:0] in3,
			output [3:0] out
);
	wire [3:0] temp0,temp1;
	CMP2 p0(.in0(in0), .in1(in1), .out(temp0));
	CMP2 p1(.in0(in2), .in1(in3), .out(temp1));
	CMP2 p2(.in0(temp0), .in1(temp1), .out(out));
endmodule


module CMP2 (
	input [3:0] in0,
	input [3:0] in1,
	output [3:0] out
);
    assign out = in0 > in1 ? in0 : in1;
endmodule







































//////////////////////////////////
//////////1 CYCLE/////////////////
//////////////////////////////////
//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
// localparam IDLE = 0;
// localparam DOWN = 1;
// localparam OVER = 2;
// 
// integer i;
// ---------------------------------------------------------------------
//   REG & WIRE DECLARATION
// ---------------------------------------------------------------------
// reg [1:0] state;
// reg [5:0] map [0:14];
// reg [5:0] n_map [0:14];
// reg [3:0] top [0:5];
// reg [3:0] set_cnt;
// 
// wire [11:0] row_full;
// 
// assign row_full[0]  = &map[0];
// assign row_full[1]  = &map[1];
// assign row_full[2]  = &map[2];
// assign row_full[3]  = &map[3];
// assign row_full[4]  = &map[4];
// assign row_full[5]  = &map[5];
// assign row_full[6]  = &map[6];
// assign row_full[7]  = &map[7];
// assign row_full[8]  = &map[8];
// assign row_full[9]  = &map[9];
// assign row_full[10] = &map[10];
// assign row_full[11] = &map[11];
// 
// wire [11:0] n_row_full;
// 
// assign n_row_full[0]  = &n_map[0];
// assign n_row_full[1]  = &n_map[1];
// assign n_row_full[2]  = &n_map[2];
// assign n_row_full[3]  = &n_map[3];
// assign n_row_full[4]  = &n_map[4];
// assign n_row_full[5]  = &n_map[5];
// assign n_row_full[6]  = &n_map[6];
// assign n_row_full[7]  = &n_map[7];
// assign n_row_full[8]  = &n_map[8];
// assign n_row_full[9]  = &n_map[9];
// assign n_row_full[10] = &n_map[10];
// assign n_row_full[11] = &n_map[11];
// assign n_row_full[12] = &n_map[12];
// assign n_row_full[13] = &n_map[13];
// assign n_row_full[14] = &n_map[14];
// // 
// // wire cut_flag = |n_row_full;
// reg [3:0] or_in0,or_in1,or_in2,or_in3;
// // 
// wire cut_flag = or_in0 | or_in1 | or_in2 | or_in3;
// 
// wire [2:0] down_cnt;
// assign down_cnt = row_full[0] + row_full[1] + row_full[2] + 
					// row_full[3] + row_full[4] + row_full[5] +
					// row_full[6] + row_full[7] + row_full[8] +
					// row_full[9] + row_full[10] + row_full[11];
// 
// reg [3:0] cut_level;
// reg [3:0] temp_score;
// reg temp_fail;
// reg [3:0] cmp_in0,cmp_in1,cmp_in2,cmp_in3,cmp_out;
// 
// ---------------------------------------------------------------------
//   DESIGN
// ---------------------------------------------------------------------
//share or gate
// always @(*) begin
// 	case(tetrominoes)
// 		0: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out + 1];
// 			or_in2 = 0;
// 			or_in3 = 0;
// 		end
// 		1: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out + 1];
// 			or_in2 = n_row_full[cmp_out + 2];
// 			or_in3 = top[position]==12 ? 0 : n_row_full[cmp_out + 3]; //for pat41
// 		end
// 		2: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = 0;
// 			or_in2 = 0;
// 			or_in3 = 0;
// 		end
// 		3: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out - 1];
// 			or_in2 = n_row_full[cmp_out - 2];
// 			or_in3 = 0;
// 		end
// 		4: begin//-1
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out - 1];
// 			or_in2 = 0;
// 			or_in3 = 0;
// 		end
// 		5: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out + 1];
// 			or_in2 = n_row_full[cmp_out + 2];
// 			or_in3 = 0;
// 		end
// 		6: begin
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out - 1];
// 			or_in2 = n_row_full[cmp_out + 1];
// 			or_in3 = 0;
// 		end
// 		7: begin//-1
// 			or_in0 = n_row_full[cmp_out];
// 			or_in1 = n_row_full[cmp_out - 1];
// 			or_in2 = 0;
// 			or_in3 = 0;
// 		end
// 	endcase
// end
// 
// 
// 
// 
// 
// 
// 
// share cmp
// always @(*) begin
	// case(tetrominoes)
		// 0: begin
			// cmp_in0 = top[position];
			// cmp_in1 = top[position+1];
			// cmp_in2 = 0;
			// cmp_in3 = 0;
		// end
		// 1: begin
			// cmp_in0 = top[position];
			// cmp_in1 = 0;
			// cmp_in2 = 0;
			// cmp_in3 = 0;
		// end
		// 2: begin
			// cmp_in0 = top[position];
			// cmp_in1 = top[position+1];
			// cmp_in2 = top[position+2];
			// cmp_in3 = top[position+3];
		// end
		// 3: begin
			// cmp_in0 = top[position];
			// cmp_in1 = top[position+1]+2;
			// cmp_in2 = 0;
			// cmp_in3 = 0;
		// end
		// 4: begin//+1
			// cmp_in0 = top[position] + 1;
			// cmp_in1 = top[position+1];
			// cmp_in2 = top[position+2];
			// cmp_in3 = 1;
		// end
		// 5: begin
			// cmp_in0 = top[position];
			// cmp_in1 = top[position+1];
			// cmp_in2 = 0;
			// cmp_in3 = 0;
		// end
		// 6: begin
			// cmp_in0 = top[position];
			// cmp_in1 = top[position+1]+1;
			// cmp_in2 = 0;
			// cmp_in3 = 0;			
		// end
		// 7: begin//+1
			// cmp_in0 = top[position]+1;
			// cmp_in1 = top[position+1]+1;
			// cmp_in2 = top[position+2];
			// cmp_in3 = 1;
		// end
	// endcase
// end
// 
// CMP4 PP0(.in0(cmp_in0), .in1(cmp_in1),.in2(cmp_in2), .in3(cmp_in3), .out(cmp_out));
// 
// always @(posedge clk or negedge rst_n) begin
	// if(!rst_n) begin
		// state <= IDLE;
	// end
	// else begin
		// case(state)
			// IDLE: begin
				// if(in_valid) begin
					// if(/*(tetrominoes==1 && top[position]>11) ||*/ cut_flag == 0) state <= OVER;
					// else state <= DOWN;
				// end 
			// end
			// DOWN: begin
				// if(down_cnt == 1) state <= OVER;
			// end
			// OVER: state <= IDLE;
		// endcase
	// end
// end
// 
// always @(posedge clk or negedge rst_n) begin
	// if(!rst_n) begin
		// for(i=0; i < 15 ; i++) begin
		  	// map[i] <= 0;
		// end
	// end
	// else begin
		// for(i=0; i < 15 ; i++) begin
		  	// map[i] <= n_map[i];
		// end
	// end
// end
// 
// map
// always @(*) begin
	// for(i=0; i < 15 ; i++) begin
	  	// n_map[i] = map[i];
	// end
	// case(state)
		// IDLE: begin
			// if(in_valid) begin
				// case(tetrominoes)
					// 0: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out+1][position] = 1;
						// n_map[cmp_out+1][position+1] = 1;
					// end
					// 1: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out+1][position] = 1;
						// n_map[cmp_out+2][position] = 1;
						// n_map[cmp_out+3][position] = 1;
					// end
					// 2: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out][position+2] = 1;
						// n_map[cmp_out][position+3] = 1;
					// end
					// 3: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out-1][position+1] = 1;
						// n_map[cmp_out-2][position+1] = 1;
					// end
					// 4: begin
						///////CMP////////////-1
						// n_map[cmp_out-1][position] = 1;
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out][position+2] = 1;
					// end
					// 5: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out+1][position] = 1;
						// n_map[cmp_out+2][position] = 1;
						// n_map[cmp_out][position+1] = 1;
					// end
					// 6: begin
						// n_map[cmp_out][position] = 1;
						// n_map[cmp_out+1][position] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out-1][position+1] = 1;
					// end
					// 7: begin
						///////CMP////////////-1
						// n_map[cmp_out-1][position] = 1;
						// n_map[cmp_out-1][position+1] = 1;
						// n_map[cmp_out][position+1] = 1;
						// n_map[cmp_out][position+2] = 1;
					// end
				// endcase
			// end
		// end
		// DOWN: begin
			// case(cut_level)
			// 	0: begin
			// 		for(i=0; i < 14 ; i++) begin
			// 			n_map[i] = map[i+1];
			// 		end
			// 	end
			// 	1: begin
			// 		for(i=1; i < 14 ; i++) begin
			// 			n_map[i] = map[i+1];
			// 		end
			// 	end
			// 	2: begin
            //         for(i=2; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	3: begin
            //         for(i=3; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	4: begin
            //         for(i=4; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	5: begin
            //         for(i=5; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	6: begin
            //         for(i=6; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	7: begin
            //         for(i=7; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	8: begin
            //         for(i=8; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	9: begin
            //         for(i=9; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	10: begin
            //         for(i=10; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// 	11: begin
            //         for(i=11; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
				// 12: begin
                //     for(i=12; i < 14 ; i++) begin
                //         n_map[i] = map[i+1];
                //     end
                // end
			// 	13: begin
            //         for(i=13; i < 14 ; i++) begin
            //             n_map[i] = map[i+1];
            //         end
            //     end
			// endcase
			// if     (row_full[11] )begin
				// for(i=11; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[10] )begin
				// for(i=10; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[9] )begin
				// for(i=9; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[8] )begin
				// for(i=8; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[7] )begin
				// for(i=7; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[6] )begin
				// for(i=6; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[5] )begin
				// for(i=5; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[4] )begin
				// for(i=4; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[3] )begin
				// for(i=3; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[2] )begin
				// for(i=2; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[1])begin
				// for(i=1; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else if(row_full[0])begin
				// for(i=0; i < 14 ; i++) begin
				    // n_map[i] = map[i+1];
				// end
			// end 
			// else begin
				// for(i=0; i < 14 ; i++) begin
				    // n_map[i] = map[i];
				// end
			// end //don't need to cut
			// n_map[14] = 0;
		// end
		// OVER: begin
			// if(set_cnt == 15 || fail == 1)begin
				// for(i=0; i < 15 ; i++) begin
				  	// n_map[i] = 0;
				// end
			// end
		// end
	// endcase
// end
// 
// top
// always @(posedge clk or negedge rst_n) begin
	// if(!rst_n) begin
		// for(i=0; i < 6 ; i++) begin
		//   top[i] <= 0;
		// end
	// end
	// else begin
		// if(state == OVER) begin//fail or cnt==16 change to 0
			// if(set_cnt != 15 && fail != 1) begin
				// for(i=0; i < 6 ; i++) begin
					// if(map[11][i])      top[i] <= 12;
					// else if(map[10][i]) top[i] <= 11;
					// else if(map[9][i])  top[i] <= 10;
					// else if(map[8][i])  top[i] <= 9;
					// else if(map[7][i])  top[i] <= 8;
					// else if(map[6][i])  top[i] <= 7;
					// else if(map[5][i])  top[i] <= 6;
					// else if(map[4][i])  top[i] <= 5;
					// else if(map[3][i])  top[i] <= 4;
					// else if(map[2][i])  top[i] <= 3;
					// else if(map[1][i])  top[i] <= 2;
					// else if(map[0][i])  top[i] <= 1;
					// else top[i] <= 0; 
				// end
			// 
			// end
			// else begin
				// for(i=0; i < 6 ; i++) begin
				  	// top[i] <= 0;
				// end
			// end
		// end
	// end
// end
// 
// set_cnt
// always @(posedge clk or negedge rst_n) begin
	// if(!rst_n) begin
		//   set_cnt <= 0;
	// end
	// else begin
		// if(state == OVER) begin
			// if(fail) set_cnt <= 0;
			// else set_cnt <= set_cnt + 1;
		// end
	// end
// end
// 
// cut_level
// always @(*) begin
// 	if     (row_full[0] ) cut_level = 0;
// 	else if(row_full[1] ) cut_level = 1;
// 	else if(row_full[2] ) cut_level = 2;
// 	else if(row_full[3] ) cut_level = 3;
// 	else if(row_full[4] ) cut_level = 4;
// 	else if(row_full[5] ) cut_level = 5;
// 	else if(row_full[6] ) cut_level = 6;
// 	else if(row_full[7] ) cut_level = 7;
// 	else if(row_full[8] ) cut_level = 8;
// 	else if(row_full[9] ) cut_level = 9;
// 	else if(row_full[10]) cut_level = 10;
// 	else if(row_full[11]) cut_level = 11;
// 	else cut_level = 12;//don't need to cut
// end
// 
// 
// temp_score
// always @(posedge clk or negedge rst_n) begin
	// if(!rst_n) begin
		//   temp_score <= 0;
	// end
	// else begin
		// case(state)
			// DOWN: begin
				// temp_score <= temp_score + 1;
			// end
			// OVER: begin
				// if(set_cnt == 15 || fail == 1) begin
					// temp_score <= 0;
				// end
			// end
		// endcase
	// end
// end
// 
//////////////fail ver1////////////////
// fail////////can be optimized
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		  temp_fail <= 0;
// 	end
// 	else begin
// 		case(state)
// 			IDLE: begin
// 				if(in_valid && (/*(tetrominoes==1 && top[position]>11) ||*/ n_map[12])) begin//////can be change
// 					temp_fail <= 1;
// 				end 
// 			end
// 			DOWN: begin
// 				if(n_map[12] ) begin
// 					temp_fail <= 1;
// 				end
// 				else begin
// 					temp_fail <= 0;
// 				end
// 			end
// 			OVER: temp_fail <= 0;
// 		endcase
// 	end
// end
// always @(*) begin
	// if(state == OVER && map[12]) begin
		// fail = 1;
	// end
	// else fail = 0;
// end
// 
//////////////fail ver2////////////////
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 	  	fail <= 0;
// 	end
// 	else begin
// 		case(state)
// 			IDLE: begin
// 				if(in_valid && n_map[12] && cut_flag==0) begin
// 					fail <= 1;
// 				end
// 			end
// 			DOWN: begin
// 				if(down_cnt==1 && n_map[12]) begin
// 					fail <= 1;
// 				end
// 			end
// 			default:fail <=0;
// 		endcase
// 	end
// end
// 
// always @(*) begin
	// if(state == OVER) begin
		// score = temp_score;
	// end
	// else score = 0;
// end
// 
// always @(*) begin
	// if(state == OVER) begin
		// score_valid = 1;
	// end
	// else score_valid = 0;
// end
// 
// always @(*) begin
	// if(state == OVER && (set_cnt == 15 || fail == 1)) begin
		// tetris_valid = 1;
	// end
	// else tetris_valid = 0;
// end
// 
// always @(*) begin
	// if(state == OVER && (set_cnt == 15 || fail)) begin
		// tetris = {map[11],map[10],map[9],map[8],map[7],map[6],map[5],map[4],map[3],map[2],map[1],map[0]};
	// end
	// else tetris = 0;
// end
// 
// 
// 
// endmodule
// 
// 
// 
// 
// 
// 
// module CMP4(input [3:0] in0,
			// input [3:0] in1,
			// input [3:0] in2,
			// input [3:0] in3,
			// output [3:0] out
// );
	// wire [3:0] temp0,temp1;
	// CMP2 p0(.in0(in0), .in1(in1), .out(temp0));
	// CMP2 p1(.in0(in2), .in1(in3), .out(temp1));
	// CMP2 p2(.in0(temp0), .in1(temp1), .out(out));
// endmodule
// 
// 
// module CMP2 (
	// input [3:0] in0,
	// input [3:0] in1,
	// output [3:0] out
// );
    // assign out = in0 > in1 ? in0 : in1;
// endmodule
// 
// 
// 
// 
















//////////////////////////////////
//////////2 CYCLE/////////////////
//////////////////////////////////
// //---------------------------------------------------------------------
// //   PARAMETER & INTEGER DECLARATION
// //---------------------------------------------------------------------
// localparam IDLE = 0;
// localparam DTERMINE_CUT = 1;
// localparam DOWN = 2;
// localparam OVER = 3;

// integer i;
// //---------------------------------------------------------------------
// //   REG & WIRE DECLARATION
// //---------------------------------------------------------------------
// reg [1:0] state;
// reg [5:0] map [0:14];
// reg [5:0] n_map [0:14];
// reg [3:0] top [0:5];
// reg [3:0] set_cnt;

// reg [2:0] tetrominoes_reg;
// reg [2:0] position_reg;



// wire [11:0] row_full,n_row_full;
// assign row_full[0]  = &map[0];
// assign row_full[1]  = &map[1];
// assign row_full[2]  = &map[2];
// assign row_full[3]  = &map[3];
// assign row_full[4]  = &map[4];
// assign row_full[5]  = &map[5];
// assign row_full[6]  = &map[6];
// assign row_full[7]  = &map[7];
// assign row_full[8]  = &map[8];
// assign row_full[9]  = &map[9];
// assign row_full[10] = &map[10];
// assign row_full[11] = &map[11];

// assign n_row_full[0]  = &n_map[0];
// assign n_row_full[1]  = &n_map[1];
// assign n_row_full[2]  = &n_map[2];
// assign n_row_full[3]  = &n_map[3];
// assign n_row_full[4]  = &n_map[4];
// assign n_row_full[5]  = &n_map[5];
// assign n_row_full[6]  = &n_map[6];
// assign n_row_full[7]  = &n_map[7];
// assign n_row_full[8]  = &n_map[8];
// assign n_row_full[9]  = &n_map[9];
// assign n_row_full[10] = &n_map[10];
// assign n_row_full[11] = &n_map[11];

// wire cut_flag = |n_row_full;



// wire [2:0] down_cnt;
// assign down_cnt = row_full[0] + row_full[1] + row_full[2] + 
// 					row_full[3] + row_full[4] + row_full[5] +
// 					row_full[6] + row_full[7] + row_full[8] +
// 					row_full[9] + row_full[10] + row_full[11];


// reg [3:0] cut_level;
// // wire fail_test = ((state==OVER) && ((map[12]!=0)||(tetrominoes==1 && top[position]>11)));

// reg [3:0] temp_score;
// reg [2:0] temp_max0,temp_max1, max;

// reg temp_fail;

// reg [3:0] cmp_in0,cmp_in1,cmp_in2,cmp_in3,cmp_out;
// //---------------------------------------------------------------------
// //   DESIGN
// //---------------------------------------------------------------------
// always @(*) begin
// 	case(tetrominoes_reg)
// 		0: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = top[position_reg+1];
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;
// 		end
// 		1: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = 0;
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;
// 		end
// 		2: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = top[position_reg+1];
// 			cmp_in2 = top[position_reg+2];
// 			cmp_in3 = top[position_reg+3];
// 		end
// 		3: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = top[position_reg+1]+2;
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;
// 		end
// 		4: begin//+1
// 			cmp_in0 = top[position_reg] + 1;
// 			cmp_in1 = top[position_reg+1];
// 			cmp_in2 = top[position_reg+2];
// 			cmp_in3 = 1;
// 		end
// 		5: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = top[position_reg+1];
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;
// 		end
// 		6: begin
// 			cmp_in0 = top[position_reg];
// 			cmp_in1 = top[position_reg+1]+1;
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;			
// 		end
// 		7: begin//+1
// 			cmp_in0 = top[position_reg]+1;
// 			cmp_in1 = top[position_reg+1]+1;
// 			cmp_in2 = top[position_reg+2];
// 			cmp_in3 = 1;
// 		end
// 		default: begin
// 			cmp_in0 = 0;
// 			cmp_in1 = 0;
// 			cmp_in2 = 0;
// 			cmp_in3 = 0;
// 		end
// 	endcase
// end

// CMP4 PP0(.in0(cmp_in0), .in1(cmp_in1),.in2(cmp_in2), .in3(cmp_in3), .out(cmp_out));



// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		tetrominoes_reg <= 0;
// 		position_reg <= 0;
// 	end
// 	else begin
// 		if(state == IDLE && in_valid) begin
// 			tetrominoes_reg <= tetrominoes;
// 			position_reg <= position;
// 		end
// 		// else begin
// 		// 	tetrominoes_reg <= tetrominoes_reg;
// 		// 	position_reg <= position_reg;
// 		// end
// 	end
// end



// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		state <= IDLE;
// 	end
// 	else begin
// 		case(state)
// 			IDLE: begin
// 				if(in_valid) begin
// 					if(tetrominoes==1 && top[position]>11) state <= OVER;
// 					else state <= DTERMINE_CUT;
// 				end 
// 			end
// 			DTERMINE_CUT: begin 
// 				if(cut_flag) state <= DOWN;
// 				else state <= OVER;
// 			end
// 			DOWN: begin
// 				if(down_cnt == 1) state <= OVER;
// 			end
// 			OVER: state <= IDLE;
// 			default: begin
// 				state <= state;
// 			end
// 		endcase
// 	end
// end
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for(i=0; i < 15 ; i++) begin
// 		  	map[i] <= 0;
// 		end
// 	end
// 	else begin
// 		for(i=0; i < 15 ; i++) begin
// 		  	map[i] <= n_map[i];
// 		end
// 	end
// end








// //map
// always @(*) begin
// 		for(i=0; i < 15 ; i++) begin
// 		  	n_map[i] = map[i];
// 		end
// 		temp_max0 = 0;
// 		temp_max1 = 0;
// 		max = 0;
// 		case(state)
// 			IDLE: begin
// 				for(i=0; i < 15 ; i++) begin
// 					n_map[i] = map[i];
// 				end
// 			end
// 			DTERMINE_CUT: begin
// 				// if(in_valid) begin
// 					case(tetrominoes_reg)
// 						0: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out+1][position_reg] = 1;
// 							n_map[cmp_out+1][position_reg+1] = 1;

// 							//////////ori/////////////
// 							// if(top[position_reg] >= top[position_reg+1]) begin
// 							// 	n_map[top[position_reg]]  [position_reg]   = 1;//map[top[position_reg]<<2 + top[position_reg]<<1 + position_reg]
// 							// 	n_map[top[position_reg]]  [position_reg+1] = 1;
// 							// 	n_map[top[position_reg]+1][position_reg]   = 1;
// 							// 	n_map[top[position_reg]+1][position_reg+1] = 1;
// 							// end
// 							// else begin
// 							// 	n_map[top[position_reg+1]][position_reg]     = 1;
// 							// 	n_map[top[position_reg+1]][position_reg+1]   = 1;
// 							// 	n_map[top[position_reg+1]+1][position_reg]   = 1;
// 							// 	n_map[top[position_reg+1]+1][position_reg+1] = 1;
// 							// end
// 						end
// 						1: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out+1][position_reg] = 1;
// 							n_map[cmp_out+2][position_reg] = 1;
// 							n_map[cmp_out+3][position_reg] = 1;

// 							//////////ori/////////////
// 							// if(top[position_reg] <= 12) begin
// 							// 	n_map[top[position_reg]][position_reg]   = 1;
// 							// 	n_map[top[position_reg]+1][position_reg] = 1;
// 							// 	n_map[top[position_reg]+2][position_reg] = 1;
// 							// 	n_map[top[position_reg]+3][position_reg] = 1;
// 							// end
// 						end
// 						2: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out][position_reg+2] = 1;
// 							n_map[cmp_out][position_reg+3] = 1;

// 							//////////ori/////////////
// 								// temp_max0 = top[position_reg] > top[position_reg+1] ? position_reg : position_reg+1;
// 								// temp_max1 = top[position_reg+2] > top[position_reg+3] ? position_reg+2 : position_reg+3;
// 								// max = top[temp_max0] > top[temp_max1] ? temp_max0 : temp_max1;

// 								// n_map[top[max]][position_reg]   = 1;
// 								// n_map[top[max]][position_reg+1] = 1;
// 								// n_map[top[max]][position_reg+2] = 1;
// 								// n_map[top[max]][position_reg+3] = 1;
// 						end
// 						3: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out-1][position_reg+1] = 1;
// 							n_map[cmp_out-2][position_reg+1] = 1;

// 							//////////ori/////////////
// 								// if(top[position_reg] >= top[position_reg+1]+2) begin
// 								// 	n_map[top[position_reg]][position_reg]     = 1;
// 								// 	n_map[top[position_reg]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg]-1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg]-2][position_reg+1] = 1;
// 								// end
// 								// else begin
// 								// 	n_map[top[position_reg+1]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+1]+2][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+1]+2][position_reg]   = 1;
//             			        // end
// 						end
// 						4: begin
// 							/////////CMP////////////-1
// 							n_map[cmp_out-1][position_reg] = 1;
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out][position_reg+2] = 1;

// 							//////////ori/////////////
// 								// if((top[position_reg]+2 >= top[position_reg+1]+1) && (top[position_reg]+2 >= top[position_reg+2]+1)) begin
// 								// 	n_map[top[position_reg]][position_reg]     = 1;
// 								// 	n_map[top[position_reg]+1][position_reg]   = 1;
// 								// 	n_map[top[position_reg]+1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg]+1][position_reg+2] = 1;
// 								// end
// 								// else if((top[position_reg+1]+1 >= top[position_reg]+2) && (top[position_reg+1]+1 >= top[position_reg+2]+1))begin
// 								// 	n_map[top[position_reg+1]][position_reg]   = 1;
// 								// 	n_map[top[position_reg+1]][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+1]][position_reg+2] = 1;
// 								// 	n_map[top[position_reg+1]-1][position_reg] = 1;
// 								// end

// 								// else begin
// 								// 	n_map[top[position_reg+2]][position_reg]   = 1;
// 								// 	n_map[top[position_reg+2]][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+2]][position_reg+2] = 1;
// 								// 	n_map[top[position_reg+2]-1][position_reg] = 1;
// 								// end
// 						end
// 						5: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out+1][position_reg] = 1;
// 							n_map[cmp_out+2][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;

// 							//////////ori/////////////
// 								// if(top[position_reg] >= top[position_reg+1]) begin
// 								// 	n_map[top[position_reg]][position_reg]   = 1;
// 								// 	n_map[top[position_reg]+1][position_reg] = 1;
// 								// 	n_map[top[position_reg]+2][position_reg] = 1;
// 								// 	n_map[top[position_reg]][position_reg+1] = 1;
// 								// end
// 								// else begin
// 								// 	n_map[top[position_reg+1]][position_reg]   = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg] = 1;
// 								// 	n_map[top[position_reg+1]+2][position_reg] = 1;
// 								// 	n_map[top[position_reg+1]][position_reg+1] = 1;
//             			        // end
// 						end
// 						6: begin
// 							/////////CMP////////////
// 							n_map[cmp_out][position_reg] = 1;
// 							n_map[cmp_out+1][position_reg] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out-1][position_reg+1] = 1;

// 							//////////ori/////////////
// 								// if(top[position_reg] >= top[position_reg+1] + 1) begin
// 								// 	n_map[top[position_reg]][position_reg]     = 1;
// 								// 	n_map[top[position_reg]+1][position_reg]   = 1;
// 								// 	n_map[top[position_reg]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg]-1][position_reg+1] = 1;
// 								// end
// 								// else begin
// 								// 	n_map[top[position_reg+1]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg]   = 1;
// 								// 	n_map[top[position_reg+1]+2][position_reg]   = 1;
// 								// end
// 						end
// 						7: begin
// 							/////////CMP////////////-1
// 							n_map[cmp_out-1][position_reg] = 1;
// 							n_map[cmp_out-1][position_reg+1] = 1;
// 							n_map[cmp_out][position_reg+1] = 1;
// 							n_map[cmp_out][position_reg+2] = 1;

// 							//////////ori/////////////
// 								// if(top[position_reg] >= top[position_reg+1] && top[position_reg]+1 >= top[position_reg+2]) begin
// 								// 	n_map[top[position_reg]][position_reg]     = 1;
// 								// 	n_map[top[position_reg]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg]+1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg]+1][position_reg+2] = 1;
// 								// end
// 								// else if(top[position_reg+1] >= top[position_reg] && top[position_reg+1] +1 >= top[position_reg+2]) begin
// 								// 	n_map[top[position_reg+1]][position_reg]     = 1;
// 								// 	n_map[top[position_reg+1]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+1]+1][position_reg+2] = 1;
// 								// end
// 								// else begin
// 								// 	n_map[top[position_reg+2]-1][position_reg]   = 1;
// 								// 	n_map[top[position_reg+2]-1][position_reg+1] = 1;
// 								// 	n_map[top[position_reg+2]][position_reg+1]   = 1;
// 								// 	n_map[top[position_reg+2]][position_reg+2]   = 1;
// 								// end
// 						end
// 					endcase
// 				// end
// 			end
// 			DOWN: begin
// 				case(cut_level)
// 					0: begin
// 						for(i=0; i < 14 ; i++) begin
// 							n_map[i] = map[i+1];
// 						end
// 					end
// 					1: begin
// 						for(i=1; i < 14 ; i++) begin
// 							n_map[i] = map[i+1];
// 						end
// 					end
// 					2: begin
//                         for(i=2; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					3: begin
//                         for(i=3; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					4: begin
//                         for(i=4; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					5: begin
//                         for(i=5; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					6: begin
//                         for(i=6; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					7: begin
//                         for(i=7; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					8: begin
//                         for(i=8; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					9: begin
//                         for(i=9; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					10: begin
//                         for(i=10; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					11: begin
//                         for(i=11; i < 14 ; i++) begin
//                             n_map[i] = map[i+1];
//                         end
//                     end
// 					// 12: begin
//                     //     for(i=12; i < 14 ; i++) begin
//                     //         n_map[i] = map[i+1];
//                     //     end
//                     // end
// 					// 13: begin
//                     //     for(i=13; i < 14 ; i++) begin
//                     //         n_map[i] = map[i+1];
//                     //     end
//                     // end
					
// 				endcase
// 				n_map[14] = 0;
// 			end
// 			OVER: begin
// 				if(set_cnt == 15 || fail == 1)begin
// 					for(i=0; i < 15 ; i++) begin
// 					  	n_map[i] = 0;
// 					end
// 				end
// 			end
// 		endcase
// end

// //top
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		for(i=0; i < 6 ; i++) begin
// 		  top[i] <= 0;
// 		end
// 	end
// 	else begin
// 		if(state == OVER) begin//fail or cnt==16 change to 0
// 			if(set_cnt != 15 && fail != 1) begin
// 				for(i=0; i < 6 ; i++) begin
// 					if(map[11][i])      top[i] <= 12;
// 					else if(map[10][i]) top[i] <= 11;
// 					else if(map[9][i])  top[i] <= 10;
// 					else if(map[8][i])  top[i] <= 9;
// 					else if(map[7][i])  top[i] <= 8;
// 					else if(map[6][i])  top[i] <= 7;
// 					else if(map[5][i])  top[i] <= 6;
// 					else if(map[4][i])  top[i] <= 5;
// 					else if(map[3][i])  top[i] <= 4;
// 					else if(map[2][i])  top[i] <= 3;
// 					else if(map[1][i])  top[i] <= 2;
// 					else if(map[0][i])  top[i] <= 1;
// 					else top[i] <= 0; 
// 				end
// 			end
// 			else begin
// 				for(i=0; i < 6 ; i++) begin
// 				  	top[i] <= 0;
// 				end
// 			end
// 		end
// 	end
// end

// //set_cnt
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		  set_cnt <= 0;
// 	end
// 	else begin
// 		if(state == OVER) begin
// 			if(fail) set_cnt <= 0;
// 			else set_cnt <= set_cnt + 1;
// 		end
// 	end
// end

// //cut_level
// always @(*) begin
// 	if     (row_full[0] ) cut_level = 0;
// 	else if(row_full[1] ) cut_level = 1;
// 	else if(row_full[2] ) cut_level = 2;
// 	else if(row_full[3] ) cut_level = 3;
// 	else if(row_full[4] ) cut_level = 4;
// 	else if(row_full[5] ) cut_level = 5;
// 	else if(row_full[6] ) cut_level = 6;
// 	else if(row_full[7] ) cut_level = 7;
// 	else if(row_full[8] ) cut_level = 8;
// 	else if(row_full[9] ) cut_level = 9;
// 	else if(row_full[10]) cut_level = 10;
// 	else if(row_full[11]) cut_level = 11;
// 	else cut_level = 12;//don't need to cut
// end

// //fail////////can be optimized
// // always @(posedge clk or negedge rst_n) begin
// // 	if(!rst_n) begin
// // 		  temp_fail <= 0;
// // 	end
// // 	else begin
// // 		case(state)
// // 			IDLE: begin
// // 				if(tetrominoes==1 && top[position]>11) begin//////can be change
// // 					temp_fail <= 1;
// // 				end 
// // 			end
// // 			DTERMINE_CUT, DOWN: begin
// // 				if(n_map[12] ) begin
// // 					temp_fail <= 1;
// // 				end
// // 				else begin
// // 					temp_fail <= 0;
// // 				end
// // 			end
// // 			OVER: temp_fail <= 0;
// // 		endcase
// // 	end
// // end
// // always @(*) begin
// // 	if(state == OVER) begin
// // 		fail = temp_fail;
// // 	end
// // 	else fail = 0;
// // end


// always @(*) begin
// 	if(state == OVER && (map[12] || (tetrominoes_reg==1 && top[position_reg]>11))) begin
// 		fail = 1;
// 	end
// 	else fail = 0;
// end


// //temp_score
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		  temp_score <= 0;
// 	end
// 	else begin
// 		// case(state)
// 		// 	DOWN: begin
// 		// 		temp_score <= temp_score + 1;
// 		// 	end
// 		// 	OVER: begin
// 		// 		if(set_cnt == 15 || fail == 1) begin
// 		// 			temp_score <= 0;
// 		// 		end
// 		// 	end
// 		// endcase
// 		if(state == DOWN) temp_score <= temp_score + 1;
// 		else if(state == OVER) begin
// 			if(set_cnt == 15 || fail == 1) begin
// 				temp_score <= 0;
// 			end
// 		end
// 	end
// end





// always @(*) begin
// 	if(state == OVER) begin
// 		score = temp_score;
// 	end
// 	else score = 0;
// end

// always @(*) begin
// 	if(state == OVER) begin
// 		score_valid = 1;
// 	end
// 	else score_valid = 0;
// end

// always @(*) begin
// 	if(state == OVER && (set_cnt == 15 || fail == 1)) begin
// 		tetris_valid = 1;
// 	end
// 	else tetris_valid = 0;
// end

// always @(*) begin
// 	if(state == OVER && (set_cnt == 15 || fail)) begin
// 		tetris = {map[11],map[10],map[9],map[8],map[7],map[6],map[5],map[4],map[3],map[2],map[1],map[0]};
// 	end
// 	else tetris = 0;
// end
// endmodule


// module CMP4(input [3:0] in0,
// 			input [3:0] in1,
// 			input [3:0] in2,
// 			input [3:0] in3,
// 			output [3:0] out
// );
// 	wire [3:0] temp0,temp1;
// 	CMP2 p0(.in0(in0), .in1(in1), .out(temp0));
// 	CMP2 p1(.in0(in2), .in1(in3), .out(temp1));
// 	CMP2 p2(.in0(temp0), .in1(temp1), .out(out));
// endmodule


// module CMP2 (
// 	input [3:0] in0,
// 	input [3:0] in1,
// 	output [3:0] out
// );
//     assign out = in0 > in1 ? in0 : in1;
// endmodule
