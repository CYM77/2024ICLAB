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
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
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
integer total_latency;
integer latency;
integer f_in;
integer a,b;
integer pat_num, pat_total;
integer i_pat, i_round, i_clear;
integer t;
integer pos_x,pos_y;
integer put_fail;
integer count;
integer erase;
integer out_num;
integer sel;
integer early_stop;
integer flag;
integer pat_latency;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [2:0] tetrominoes_store;
reg [2:0] position_store;

reg golden_fail;
reg [3:0] golden_score;
reg [89:0] golden_tetris;

reg signed [4:0] high [0:5];
//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------
always @(negedge clk) begin
	if((score_valid ===0 && (fail !== 'd0 || score !== 'd0 || tetris_valid !== 0)) || (tetris_valid === 0 && tetris !== 'd0)) begin
		$display("*************************************************************************");
		$display("*                              FAIL!                                    *");
    	$display("*                        	  SPEC-5 FAIL                                 *");
		$display("*       The out_data should be reset when your out_valid is low.        *");
		$display("*************************************************************************");
		repeat(2) #(CYCLE);
		$finish;
	end
end

initial begin
	f_in = $fopen("/RAID2/COURSE/iclab/iclab145/Lab03/00_TESTBED/input.txt", "r");

	//reset signal
	reset_task; 

	i_pat = 0;
	total_latency = 0;
	$fscanf(f_in, "%d", pat_total);
	for (i_pat = 0; i_pat < pat_total; i_pat = i_pat + 1) begin
		$fscanf(f_in, "%d", pat_num);
		golden_score = 'd0;
		golden_tetris = 'd0;
		golden_fail = 0;
		early_stop = 0;
		high[0] = 'd0;
		high[1] = 'd0;
		high[2] = 'd0;
		high[3] = 'd0;
		high[4] = 'd0;
		high[5] = 'd0;
		pat_latency = 0;
		for(i_round = 0; i_round < 16; i_round = i_round + 1) begin
        	input_task;
        	wait_out_valid_task;
        	check_ans_task;
			total_latency = total_latency + latency;
			pat_latency = pat_latency + latency;
			if(early_stop) begin
				for(count = i_round + 1; count < 16; count = count + 1) begin
					$fscanf(f_in, "%d", tetrominoes_store);
					$fscanf(f_in, "%d", position_store);
				end
				break;
			end
		end
        $display("PASS PATTERN NO.%4d    Cycles = %4d", i_pat, pat_latency);
    end

	$fclose(f_in);

	YOU_PASS_task;

end

task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	tetrominoes = 3'bxxx;
	position = 3'bxxx;

	force clk = 0;

	// Apply reset
    #CYCLE; rst_n = 1'b0; 
    #CYCLE; rst_n = 1'b1;

	// Check initial conditions
    if (tetris_valid !== 1'b0 || score_valid !== 1'b0 || fail !== 1'b0 || score !== 4'b0 || tetris !== 72'b0) begin
        $display("************************************************************");  
        $display("                       SPEC-4 FAIL                          ");    
        $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************");
        repeat (2) #CYCLE;
        $finish;
    end

	#CYCLE; release clk;
end endtask

task input_task; begin
	$fscanf(f_in, "%d", tetrominoes_store);
	$fscanf(f_in, "%d", position_store);

	t = $urandom_range(1,4);
    repeat(t) @(negedge clk);

	in_valid = 1'd1;
	tetrominoes = tetrominoes_store;
	position = position_store;

	@(negedge clk);
	in_valid = 1'd0;
	tetrominoes = 'dx;
	position = 'dx;

	cal_ans;
end
endtask

task wait_out_valid_task; begin
	latency = 1;
	while (score_valid !== 1'b1) begin
		latency = latency + 1;
		if(latency == 1000)begin
            $display("*************************************************************************");
		    $display("*                              FAIL!                                    *");
    	    $display("*                           SPEC-6 FAIL                                 *");
		    $display("*         The execution latency is limited in 1000 cycles.              *");
		    $display("*************************************************************************");
		    repeat(2) @(negedge clk);
		    $finish;
        end

		@(negedge clk);
	end
	
end
endtask

task check_ans_task; begin 
	
	out_num = 0;
	while (score_valid === 1) begin
		if (tetris_valid === 1) begin
			if (tetris !== golden_tetris[71:0] && out_num == 0) begin
            	$display("************************************************************");  
            	$display("                      SPEC-7 FAIL                           ");
            	$display(" Expected: tetris = %b", golden_tetris[71:0]);
            	$display(" Received: tetris = %b", tetris);
            	$display("************************************************************");
            	repeat (5) @(negedge clk);
            	$finish;
        	end
		end

		if ((score !== golden_score || fail !== golden_fail) && out_num == 0) begin
            $display("************************************************************");  
            $display("                      SPEC-7 FAIL                           ");
            $display(" Expected: score = %d, fail = %d", golden_score, golden_fail);
            $display(" Received: score = %d, fail = %d", score, fail);
            $display("************************************************************");
            repeat (5) @(negedge clk);
            $finish;
        end else begin
			if(fail === 1)
				early_stop = 1;
            @(negedge clk);
            out_num = out_num + 1;
        end
	end

	if(out_num !== 1) begin
            $display("************************************************************");  
            $display("                       SPEC-8 FAIL                          ");
            $display(" Expected one valid output, but found %d", out_num);
            $display("************************************************************");
            repeat(9) @(negedge clk);
            $finish;
        end
end endtask

task cal_ans; begin
	put_fail = 1;
	pos_x = position_store;
	//put tetris
	case (tetrominoes_store)
		'd0: begin
			sel = high[pos_x] > high[pos_x+1] ? high[pos_x] : high[pos_x+1];
			for(pos_y = sel; pos_y < 13; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x + 1] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x + 1] = 1;
					high[pos_x] = pos_y + 2;
					high[pos_x+1] = pos_y + 2;
					put_fail = 0;
					break;
				end
			end
		end
		'd1: begin
			for(pos_y = high[pos_x]; pos_y < 12; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 2) * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 3) * 6 + pos_x] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 2) * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 3) * 6 + pos_x] = 1;

					high[pos_x] = pos_y + 4;

					put_fail = 0;
					break;
				end
			end
		end
		'd2: begin
			sel = high[pos_x];
			if(high[pos_x + 1] > sel)
				sel = high[pos_x + 1];
			if(high[pos_x + 2] > sel)
				sel = high[pos_x + 2];
			if(high[pos_x + 3] > sel)
				sel = high[pos_x + 3];
			for(pos_y = sel; pos_y < 14; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0) && (golden_tetris[pos_y * 6 + pos_x + 2] == 0) && (golden_tetris[pos_y * 6 + pos_x + 3] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					golden_tetris[pos_y * 6 + pos_x + 2] = 1;
					golden_tetris[pos_y * 6 + pos_x + 3] = 1;

					high[pos_x] = pos_y + 1;
					high[pos_x + 1] = pos_y + 1;
					high[pos_x + 2] = pos_y + 1;
					high[pos_x + 3] = pos_y + 1;
					put_fail = 0;
					break;
				end
			end
		end
		'd3: begin
			if(high[pos_x] - 2> high[pos_x + 1])
				sel = high[pos_x];
			else
				sel = high[pos_x + 1] + 2;

			for(pos_y = sel; pos_y < 14; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y - 1) * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y - 2) * 6 + pos_x + 1] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y - 1) * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y - 2) * 6 + pos_x + 1] = 1;
					high[pos_x] = pos_y + 1;
					high[pos_x + 1] = pos_y + 1;
					put_fail = 0;
					break;
				end
			end
		end
		'd4: begin
			if((high[pos_x + 1] - 1 > high[pos_x]) && (high[pos_x + 1] > high[pos_x + 2]))
				sel = high[pos_x + 1] - 1;
			else begin
				if(high[pos_x + 2] - 1 > high[pos_x])
					sel = high[pos_x + 2] - 1;
				else
					sel = high[pos_x];
			end

			for(pos_y = sel; pos_y < 13; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x + 2] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x + 2] = 1;

					high[pos_x] = pos_y + 2;
					high[pos_x + 1] = pos_y + 2;
					high[pos_x + 2] = pos_y + 2;
					put_fail = 0;
					break;
				end
			end
		end
		'd5: begin
			sel = high[pos_x] > high[pos_x + 1] ? high[pos_x] : high[pos_x + 1];
			for(pos_y = sel; pos_y < 12; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x] == 0) && (golden_tetris[(pos_y + 2) * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x] = 1;
					golden_tetris[(pos_y + 2) * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					high[pos_x] = pos_y + 3;
					high[pos_x + 1] = pos_y + 1;
					put_fail = 0;
					break;
				end
			end
		end
		'd6: begin
			if(high[pos_x] - 1> high[pos_x + 1])
				sel = high[pos_x];
			else
				sel = high[pos_x + 1] + 1;
			for(pos_y = sel; pos_y < 13; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y - 1) * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y + 1)* 6 + pos_x] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y - 1) * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y + 1)* 6 + pos_x] = 1;
					high[pos_x] = pos_y + 2;
					high[pos_x + 1] = pos_y + 1;
					put_fail = 0;
					break;
				end
			end
		end
		'd7: begin
			if((high[pos_x + 2] - 1 > high[pos_x]) && (high[pos_x + 2] - 1 > high[pos_x + 1]))
				sel = high[pos_x + 2] - 1;
			else begin
				sel = high[pos_x] > high[pos_x + 1] ? high[pos_x] : high[pos_x + 1];
			end
			for(pos_y = sel; pos_y < 13; pos_y = pos_y + 1) begin
				if((golden_tetris[pos_y * 6 + pos_x] == 0) && (golden_tetris[pos_y * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x + 1] == 0) && (golden_tetris[(pos_y + 1) * 6 + pos_x + 2] == 0)) begin
					golden_tetris[pos_y * 6 + pos_x] = 1;
					golden_tetris[pos_y * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x + 1] = 1;
					golden_tetris[(pos_y + 1) * 6 + pos_x + 2] = 1;
					high[pos_x] = pos_y + 1;
					high[pos_x + 1] = pos_y + 2;
					high[pos_x + 2] = pos_y + 2;
					put_fail = 0;
					break;
				end
			end
		end
	endcase

	// clear the row
	if(golden_tetris[5:0] == 6'b111111) begin
		golden_tetris[5:0] = 6'b000000;
		golden_score = golden_score + 1;
	end
	if(golden_tetris[11:6] == 6'b111111) begin
		golden_tetris[11:6] = 6'b000000;
		golden_score = golden_score + 1;
	end
	if(golden_tetris[17:12] == 6'b111111) begin
		golden_tetris[17:12] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[23:18] == 6'b111111) begin
		golden_tetris[23:18] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[29:24] == 6'b111111) begin
		golden_tetris[29:24] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[35:30] == 6'b111111) begin
		golden_tetris[35:30] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[41:36] == 6'b111111) begin
		golden_tetris[41:36] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[47:42] == 6'b111111) begin
		golden_tetris[47:42] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[53:48] == 6'b111111) begin
		golden_tetris[53:48] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[59:54] == 6'b111111) begin
		golden_tetris[59:54] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[65:60] == 6'b111111) begin
		golden_tetris[65:60] = 6'b000000;
		golden_score = golden_score + 1;
		
	end
	if(golden_tetris[71:66] == 6'b111111) begin
		golden_tetris[71:66] = 6'b000000;
		golden_score = golden_score + 1;
		
	end


	//move down
	

	for (erase = 0; erase < 12; erase = erase + 1) begin
		if(golden_tetris[5:0] == 6'b000000) begin
			golden_tetris[83-:84] = golden_tetris[83-: 84] >> 6;
			
		end
		else if(golden_tetris[11:6] == 6'b000000) begin
			golden_tetris[83-:78] = golden_tetris[83-: 78] >> 6;
			
		end
		else if(golden_tetris[17:12] == 6'b000000) begin
			golden_tetris[83-:72] = golden_tetris[83-: 72] >> 6;
			
		end
		else if(golden_tetris[23:18] == 6'b000000) begin
			golden_tetris[83-:66] = golden_tetris[83-: 66] >> 6;
			
		end
		else if(golden_tetris[29:24] == 6'b000000) begin
			golden_tetris[83-:60] = golden_tetris[83-: 60] >> 6;
			
		end
		else if(golden_tetris[35:30] == 6'b000000) begin
			golden_tetris[83-:54] = golden_tetris[83-: 54] >> 6;
			
		end
		else if(golden_tetris[41:36] == 6'b000000) begin
			golden_tetris[83-:48] = golden_tetris[83-: 48] >> 6;
			
		end
		else if(golden_tetris[47:42] == 6'b000000) begin
			golden_tetris[83-:42] = golden_tetris[83-: 42] >> 6;
			
		end
		else if(golden_tetris[53:48] == 6'b000000) begin
			golden_tetris[83-:36] = golden_tetris[83-: 36] >> 6;
			
		end
		else if(golden_tetris[59:54] == 6'b000000) begin
			golden_tetris[83-:30] = golden_tetris[83-: 30] >> 6;
			
		end
		else if(golden_tetris[65:60] == 6'b000000) begin
			golden_tetris[83-:24] = golden_tetris[83-: 24] >> 6;
			
		end
		else if(golden_tetris[71:66] == 6'b000000) begin
			golden_tetris[83-:18] = golden_tetris[83-: 18] >> 6;
			
		end
	end

	high_go_down;
	
	//check fail
	if((golden_tetris[(12 * 6 + 5): 12 * 6] != 6'b000000) || put_fail)
		golden_fail = 1;

end endtask

task high_go_down;begin
	high[0] = 0;
	high[1] = 0;
	high[2] = 0;
	high[3] = 0;
	high[4] = 0; 
	high[5] = 0;

	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6])
			high[0] = pos_y + 1;
	end
	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6 + 1])
			high[1] = pos_y + 1;
	end
	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6 + 2])
			high[2] = pos_y + 1;
	end
	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6 + 3])
			high[3] = pos_y + 1;
	end
	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6 + 4])
			high[4] = pos_y + 1;
	end
	for(pos_y = 0; pos_y < 12; pos_y = pos_y + 1)begin
		if(golden_tetris[pos_y * 6 + 5])
			high[5] = pos_y + 1;
	end
end endtask

task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                           You have passed all patterns!                                               ");
    $display("                                           Your execution cycles = %7d cycles                                          ", total_latency);
    $display("                                           Your clock period = %.1f ns                                                 ", CYCLE);
    $display("                                           Total Latency = %.1f ns                                                    ", total_latency * CYCLE);
    $display("----------------------------------------------------------------------------------------------------------------------");
    repeat (2) @(negedge clk);
    $finish;
end endtask



endmodule
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