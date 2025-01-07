/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

`ifdef RTL
    `define CYCLE_TIME 8.0
`endif
`ifdef GATE
    `define CYCLE_TIME 7.1
`endif

module PATTERN(
	//OUTPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//INPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg			rst_n, clk, in_valid;
output reg	[2:0]	tetrominoes;
output reg  [2:0]	position;
input 				tetris_valid, score_valid, fail;
input 		[3:0]	score;
input		[71:0]	tetris;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------

real CYCLE = `CYCLE_TIME;

integer pat_read;
integer PAT_NUM,PAT_ROUND;
integer total_latency, latency;
integer i_pat, i_set;
integer i;
integer a, b;
integer cnt; 
reg [2:0] t,p;
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [5:0] map [0:14];
reg [3:0] top [0:5];
reg fail_round;
reg [3:0] score_total;
wire [71:0] tetris_correct =  {map[11],map[10],map[9],map[8],map[7],map[6],map[5],map[4],map[3],map[2],map[1],map[0]} ;

reg check_flag;
reg [3:0] temp_max0, temp_max1, max; 

reg [100:0] cut_num [0:4];


//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
always #(CYCLE/2.0) clk = ~clk;
//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------

always @(negedge clk) begin
	// if((score_valid === 1'b0 && score !== 0) || (score_valid === 1'b0 && fail !== 0) || (score_valid === 1'b0 && tetris_valid !== 0) || (tetris_valid === 0 && tetris !== 0)) begin
	if(((score_valid === 1'b0) && (score !== 0 ||  fail !== 0 || tetris_valid !== 0)) || (tetris_valid === 0&& tetris !== 0)) begin
		$display("                    SPEC-5 FAIL                   ");
		$finish;
	end
end

initial begin
	pat_read = $fopen("../00_TESTBED/input.txt", "r");
    $fscanf(pat_read, "%d", PAT_NUM);
    i_pat = 0;
	i_set = 0;
    total_latency = 0;
	reset_signal_task;
	for(i=0; i < 5 ; i++) begin
		  cut_num[i] = 0;
	end
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
		a = $fscanf(pat_read, "%d", PAT_ROUND);
		cnt = 0;
		fail_round = 0;
		score_total = 0;
		for(i=0; i<15 ; i++) begin
		  map[i] = 0;
		end
		for(i=0; i<6 ; i++) begin
		  top[i] = 0;
		end
		for(i_set=0; i_set < 16; i_set=i_set + 1) begin
		  	input_task;
			
       		wait_out_valid_task;
			check_ans_task;

			// total_latency = total_latency + latency;
			if(fail_round) break;
			cnt = cnt + 1;
			if(i_set<15) begin
				repeat({$random()} % 4 ) @(negedge clk);
			end
		end
        //jump to next round
		for(i=0; i<15-cnt; i=i+1) begin
		  a = $fscanf(pat_read, "%d %d", t, p);
		//   $display("pos:%d ter:%d",p, t);
		end
		repeat({$random()} % 4 ) @(negedge clk);
        $display("PASS PATTERN NO.%4d", i_pat);
    end
	$display("                  Congratulations!               ");
	$display("              execution cycles = %7d", total_latency);
	$display("              clock period = %4fns", CYCLE);

	
	// $display("cut0", cut_num[0]);
	// $display("cut1", cut_num[1]);
	// $display("cut2", cut_num[2]);
	// $display("cut3", cut_num[3]);
	// $display("cut4", cut_num[4]);


	$finish;
end



// for spec check
// $display("                    SPEC-4 FAIL                   ");
// $display("                    SPEC-5 FAIL                   ");
// $display("                    SPEC-6 FAIL                   ");
// $display("                    SPEC-7 FAIL                   ");
// $display("                    SPEC-8 FAIL                   ");
// for successful design
// $display("                  Congratulations!               ");
// $display("              execution cycles = %7d", total_latency);
// $display("              clock period = %4fns", CYCLE);



//reset_signal_task
task reset_signal_task; begin
    force clk = 0;
    rst_n = 1;
    in_valid = 'd0;
    total_latency = 0;
	cnt = 0;

    #(CYCLE/2) rst_n = 0;
    #(CYCLE/2) rst_n = 1;
    #(100-(CYCLE/2));
    if (tetris_valid !== 0 || score_valid !== 0 || fail!==0 || score!==0 || tetris!==0) begin
        $display("                    SPEC-4 FAIL                   ");
        repeat(5) #(CYCLE);
        $finish;
    end
    #(CYCLE) release clk;
	repeat(5) #(CYCLE);
end endtask

task input_task;begin
	a = $fscanf(pat_read, "%d %d", t, p);
	
	@(negedge clk);
	// repeat(({$random()} % 3)) @(negedge clk);
	tetrominoes = t;
	position = p;
	in_valid = 1;
	Get_Answer;///////////////////////////////////////////can detect one cycle out
	@(negedge clk);
	tetrominoes = 3'bxxx;
	position = 3'bxxx;
	in_valid = 0;

end
endtask

task wait_out_valid_task; begin
    latency = 1;
    while(score_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == 1000) begin
            $display("                    SPEC-6 FAIL                   ");
			repeat(2) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

task check_ans_task; begin
	if((score_valid === 1 &&  (score !== score_total || fail !== fail_round)) /*|| (tetris_valid === 1 && tetris !== tetris_correct)*/) begin
		$display("                    SPEC-7 FAIL                   ");
		$finish;
	end
	if(tetris_valid === 1 && tetris !== tetris_correct) begin
		$display("                    SPEC-7 FAIL                   ");
		$display("CORRECT:%h, YOU:%h", tetris_correct, tetris);
		$finish;
	end
end
endtask



task Get_Answer;begin
	Place;
	Cut_and_Add_Score;
	Get_Top;
	Check_fail;
end
endtask


task Place;begin//place tetrominoes and determine failure
	
	// always @(*) begin
		case(t)
			0: begin
				// if(top[p] <= 11 && top[p+1] <= 11) begin
					if(top[p] >= top[p+1]) begin
						map[top[p]]  [p]   = 1;//map[top[p]<<2 + top[p]<<1 + p]
						map[top[p]]  [p+1] = 1;
						map[top[p]+1][p]   = 1;
						map[top[p]+1][p+1] = 1;
						//////////////////
						// top[p] 	 <= top[p]+2;
						// top[p+1] <= top[p]+2;
					end
					else begin
						map[top[p+1]][p]     = 1;
						map[top[p+1]][p+1]   = 1;
						map[top[p+1]+1][p]   = 1;
						map[top[p+1]+1][p+1] = 1;
						//////////////////
						// top[p]   <= top[p+1]+2;
						// top[p+1] <= top[p+1]+2;
					end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			1: begin
				if(top[p] <= 11) begin
					map[top[p]][p]   = 1;
					map[top[p]+1][p] = 1;
					map[top[p]+2][p] = 1;
					map[top[p]+3][p] = 1;
					/////////////////////
					// top[p] <= top[p] + 4;
				end
				else begin
					fail_round = 1;
				end
			end
			2: begin
				// if(top[p] <= 11 && top[p+1] <= 11 && top[p+2] <= 11 && top[p+3] <= 11) begin
					temp_max0 = top[p] > top[p+1] ? p : p+1;
					temp_max1 = top[p+2] > top[p+3] ? p+2 : p+3;
					max = top[temp_max0] > top[temp_max1] ? temp_max0 : temp_max1;

					map[top[max]][p]   = 1;
					map[top[max]][p+1] = 1;
					map[top[max]][p+2] = 1;
					map[top[max]][p+3] = 1;
					/////////////////////
					// top[p]   <= top[max] + 1;
                    // top[p+1] <= top[max] + 1;
                    // top[p+2] <= top[max] + 1;
                    // top[p+3] <= top[max] + 1;
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			3: begin
				// if(top[p+1] <= 10) begin
					if(top[p] >= top[p+1]+2) begin
						map[top[p]][p]     = 1;
						map[top[p]][p+1]   = 1;
						map[top[p]-1][p+1] = 1;
						map[top[p]-2][p+1] = 1;
						/////////////////////
						// top[p]   <= top[p]+1;
						// top[p+1] <= top[p]+1;
					end
					else begin
						map[top[p+1]][p+1]   = 1;
						map[top[p+1]+1][p+1] = 1;
						map[top[p+1]+2][p+1] = 1;
						map[top[p+1]+2][p]   = 1;
						/////////////////////
                        // top[p]   <= top[p+1]+3;
                        // top[p+1] <= top[p+1]+3;
                    end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			4: begin
				// if(top[p] <= 11) begin
					if((top[p]+2 >= top[p+1]+1) && (top[p]+2 >= top[p+2]+1)) begin
						map[top[p]][p]     = 1;
						map[top[p]+1][p]   = 1;
						map[top[p]+1][p+1] = 1;
						map[top[p]+1][p+2] = 1;
						/////////////////////
						// top[p]   <= top[p]+2;
                        // top[p+1] <= top[p]+2;
						// top[p+2] <= top[p]+2;
					end
					else if((top[p+1]+1 >= top[p]+2) && (top[p+1]+1 >= top[p+2]+1))begin
						map[top[p+1]][p]   = 1;
						map[top[p+1]][p+1] = 1;
						map[top[p+1]][p+2] = 1;
						map[top[p+1]-1][p] = 1;
						/////////////////////
					    // top[p]   <= top[p+1]+1;
						// top[p+1] <= top[p+1]+1;
						// top[p+2] <= top[p+1]+1;
					end
						
					else begin
						map[top[p+2]][p]   = 1;
						map[top[p+2]][p+1] = 1;
						map[top[p+2]][p+2] = 1;
						map[top[p+2]-1][p] = 1;
						/////////////////////
						// top[p]   <= top[p+2]+1;
						// top[p+1] <= top[p+2]+1;
						// top[p+2] <= top[p+2]+1;
					end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			5: begin
				// if(top[p] <= 10 && top[p+1] <= 10) begin
					if(top[p] >= top[p+1]) begin
						map[top[p]][p]   = 1;
						map[top[p]+1][p] = 1;
						map[top[p]+2][p] = 1;
						map[top[p]][p+1] = 1;
						/////////////////////
						// top[p]   <= top[p] + 3;
						// top[p+1] <= top[p] + 1;
					end
					else begin
						map[top[p+1]][p]   = 1;
						map[top[p+1]+1][p] = 1;
						map[top[p+1]+2][p] = 1;
						map[top[p+1]][p+1] = 1;
						/////////////////////
                        // top[p]   <= top[p+1] + 3;
                        // top[p+1] <= top[p+1] + 1;
                    end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			6: begin
				// if(top[p] <= 11 && top[p+1] <= 10) begin
					if(top[p] >= top[p+1] + 1) begin
						map[top[p]][p]     = 1;
						map[top[p]+1][p]   = 1;
						map[top[p]][p+1]   = 1;
						map[top[p]-1][p+1] = 1;
						/////////////////////
						// top[p]   <= top[p] + 2;
						// top[p+1] <= top[p] + 1;
					end
					else begin
						map[top[p+1]][p+1]   = 1;
						map[top[p+1]+1][p+1] = 1;
						map[top[p+1]+1][p]   = 1;
						map[top[p+1]+2][p]   = 1;
						/////////////////////
						// top[p]   <= top[p+1] + 3;
						// top[p+1] <= top[p+1] + 2;
					end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
			7: begin
				// if(top[p] <= 11 && top[p+1] <= 11) begin
					if(top[p] >= top[p+1] && top[p]+1 >= top[p+2]) begin
						map[top[p]][p]     = 1;
						map[top[p]][p+1]   = 1;
						map[top[p]+1][p+1] = 1;
						map[top[p]+1][p+2] = 1;
						/////////////////////
						// top[p]   <= top[p] + 1;
						// top[p+1] <= top[p] + 2;
						// top[p+2] <= top[p] + 2;
					end
					else if(top[p+1] >= top[p] && top[p+1] +1 >= top[p+2]) begin
						map[top[p+1]][p]     = 1;
						map[top[p+1]][p+1]   = 1;
						map[top[p+1]+1][p+1] = 1;
						map[top[p+1]+1][p+2] = 1;
						/////////////////////
						// top[p]   <= top[p+1] + 1;
						// top[p+1] <= top[p+1] + 2;
						// top[p+2] <= top[p+1] + 2;
					end
					else begin
						map[top[p+2]-1][p]   = 1;
						map[top[p+2]-1][p+1] = 1;
						map[top[p+2]][p+1]   = 1;
						map[top[p+2]][p+2]   = 1;
						/////////////////////
						// top[p]   <= top[p+2];
						// top[p+1] <= top[p+2] +1;
						// top[p+2] <= top[p+2] + 1;
					end
				// end
				// else begin
				// 	fail_round = 1;
				// end
			end
		endcase
	end

// end
endtask
integer cnt_;
task Cut_and_Add_Score;begin
	
	integer i,j,k;
	check_flag = 0;
	cnt_ = 0;
	while(!check_flag) begin
		for(i=0; i<12; i=i+1) begin
			if(map[i]===6'b111111) begin
				cnt_++;
				check_flag = 1;
				score_total = score_total + 1;
				for(j=i;j<14;j++) begin
					map[j] = map[j+1];
				end
				// for(k=0;k<6;k++) begin
				// 	top[k] = top[k] - 1;
				// end
				map[14] = 6'b000000;
				break;
			end
		end
		
		// check_flag = 1;
		if(check_flag) check_flag = 0;
		else check_flag = 1;
	end
	case(cnt_)
		0:cut_num[0]+=1;
		1:cut_num[1]+=1;
		2:cut_num[2]+=1;
		3:cut_num[3]+=1;
		4:cut_num[4]+=1;
	endcase
	
end
endtask

task Check_fail;begin
	if(map[12] !== 6'b000000 || map[13] !== 6'b000000 || map[14] !== 6'b000000) begin
		fail_round = 1;
	end
end
endtask


task Get_Top; begin
	integer i,j,k;
	reg flag;

	for(i=0; i<6; i++) begin
		for(j=0;j<12;j++) begin
			//$display("map[j][i]: %d",map[j][i]);
			if(map[11-j][i]==1) begin
				top[i] = 12-j;
				break;
			end
			else top[i] = 0;
		end
		//$display("TOP[%d]: %d",i, top[i]);
	end	
end
endtask

always @(negedge clk) begin
	if(score_valid===1 || tetris_valid===1) begin
		@(negedge clk);
		if(score_valid !== 0 || tetris_valid !==0) begin
			$display("                    SPEC-8 FAIL                   ");
            $finish;
		end
	end
end







endmodule