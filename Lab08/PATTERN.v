/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

module PATTERN(
	// Output signals
	clk,
	rst_n,
	in_valid,
	T,
	in_data,
	w_Q,
	w_K,
	w_V,

	// Input signals
	out_valid,
	out_data
);

output reg clk;
output reg rst_n;
output reg in_valid;
output reg [3:0] T;
output reg signed [7:0] in_data;
output reg signed [7:0] w_Q;
output reg signed [7:0] w_K;
output reg signed [7:0] w_V;

input out_valid;
input signed [63:0] out_data;

//================================================================
// Clock
//================================================================
real CYCLE = 50;
always #(CYCLE/2.0) clk = ~clk;

//================================================================
// parameters & integer
//================================================================
integer i,j, i_pat;
integer total_latency, latency;
integer total_pattern = 100;
integer SEED = 1234;
integer out_num;


//================================================================
// Wire & Reg Declaration
//================================================================
reg [3:0] T_in;
reg signed [7:0] in_data_in[0:7][0:7];
reg signed [7:0] w_Q_in[0:7][0:7];
reg signed [7:0] w_K_in[0:7][0:7];
reg signed [7:0] w_V_in[0:7][0:7];

reg signed [63:0] w_Q_linear[0:7][0:7];
reg signed [63:0] w_K_linear[0:7][0:7];
reg signed [63:0] w_V_linear[0:7][0:7];

reg signed [63:0] matmul_1_out[0:7][0:7];
reg signed [63:0] scale_out[0:7][0:7];
reg signed [63:0] ReLu_out[0:7][0:7];
reg signed [63:0] matmul_2_out[0:7][0:7];


//================================================================
// Task & Function Declaration
//================================================================
always @(negedge clk) begin
	if(out_valid === 0 && out_data !== 'd0) begin
		$display("*************************************************************************");
		$display("*                              \033[1;31mFAIL!\033[1;0m                                    *");
		$display("*       The out_data should be reset when your out_valid is low.        *");
		$display("*************************************************************************");
		repeat(1) #(CYCLE);
		$finish;
	end
end

initial begin
	//reset signal
	reset_task; 
    repeat (4) @(negedge clk);
	i_pat = 0;
	total_latency = 0;

	for (i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
		total_latency = total_latency + latency;
        $display("\033[1;34mPASS PATTERN \033[1;32mNO.%4d  Cycles = %4d\033[m", i_pat,latency);
    end

	YOU_PASS_task;

end

task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	T = 'bx;
	in_data = 'bx;
	w_Q = 'bx;
	w_K = 'bx;
	w_V = 'bx;

	force clk = 0;

	// Apply reset
    #CYCLE; rst_n = 1'b0; 
    repeat(2) #(CYCLE); rst_n = 1'b1;

	// Check initial conditions
    if (out_valid !== 'd0 || out_data !== 'd0) begin
        $display("************************************************************");  
        $display("                           \033[1;31mFAIL!\033[1;0m                             ");    
        $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************");
        repeat (1) #CYCLE;
        $finish;
    end

	#CYCLE; release clk;
end endtask

task input_task; 
	integer m;
begin
    random_input;

    in_valid = 1;

    for(i = 0; i < 192; i = i + 1)begin
        if(i == 0)begin
			T = T_in;
		end
		else begin
			T = 'bx;
		end
		
		if((i/8) < T_in) begin
			in_data = in_data_in[i/8][i%8];
		end
		else begin
			in_data = 'bx;
		end

		if(i < 64) begin
			w_Q = w_Q_in[i/8][i%8];
			w_K = 'bx;
			w_V = 'bx;
		end
		else if(i < 128) begin
			w_Q = 'bx;
			w_K = w_K_in[(i/8) % 8][i%8];
			w_V = 'bx;
		end
		else begin
			w_Q = 'bx;
			w_K = 'bx;
			w_V = w_V_in[(i/8) % 8][i%8];
		end

		if(out_valid !== 0 || out_data !== 'd0) begin
			$display("*************************************************************************");
			$display("*                              \033[1;31mFAIL!\033[1;0m                                    *");
			$display("*       Output signal out_valid and out_data should be zero when in_valid is high.        *");
			$display("*************************************************************************");
			repeat(1) #(CYCLE);
			$finish;
		end

		@(negedge clk);
    end

	in_valid = 1'b0;
	T = 'bx;
	in_data = 'bx;
	w_Q = 'bx;
	w_K = 'bx;
	w_V = 'bx;

    cal_ans;
end
endtask

task wait_out_valid_task; begin
	latency = 0;
	while (out_valid !== 1'b1) begin
		latency = latency + 1;
		if(latency == 2000)begin
            $display("*************************************************************************");
		    $display("*                              \033[1;31mFAIL!\033[1;0m                                    *");
		    $display("*         The execution latency is limited in 2000 cycles.              *");
		    $display("*************************************************************************");
		    repeat(1) @(negedge clk);
		    $finish;
        end

		@(negedge clk);
	end
	
end
endtask

task check_ans_task; begin 
    out_num = 0;
    while(out_valid === 1) begin
	    if (out_data !== matmul_2_out[out_num/8][out_num%8] && (out_num < (T_in) * 8)) begin
                $display("************************************************************");  
                $display("                          \033[1;31mFAIL!\033[1;0m                              ");
                $display(" Expected: data = %d", matmul_2_out[out_num/8][out_num%8]);
                $display(" Received: data = %d", out_data);
                $display("************************************************************");
                repeat (1) @(negedge clk);
                $finish;

        end
        else begin
            @(negedge clk);
            out_num = out_num + 1;
        end
    end

    if(out_num !== (T_in * 8)) begin
            $display("************************************************************");  
            $display("                            \033[1;31mFAIL!\033[1;0m                            ");
            $display(" Expected %d out_valid, but found %d",(T_in * 8), out_num);
            $display("************************************************************");
            repeat(2) @(negedge clk);
            $finish;
    end

    repeat({$random(SEED)} % 4 + 2)@(negedge clk);
end endtask 

task random_input; 
    integer idx,idy, x, y;
    
begin
	x = {$random(SEED)} % 3;

	if(x == 0)
		T_in = 'd1;
	else if(x == 1)
		T_in = 'd8;
	else 
		T_in = 'd4;
	
	if(i_pat < 10) begin // simple case
		for(idy = 0; idy < 8; idy = idy + 1) begin
        	for(idx = 0; idx < 8; idx = idx + 1)begin
        	    in_data_in[idy][idx] = ({$random(SEED)} % 19) - 9;
				w_Q_in[idy][idx] = ({$random(SEED)} % 19) - 9;
				w_K_in[idy][idx] = ({$random(SEED)} % 19) - 9;
				w_V_in[idy][idx] = ({$random(SEED)} % 19) - 9;
        	end
    	end
	end
	else if(i_pat == 10)begin // max case
		T_in = 'd8;
		for(idy = 0; idy < 8; idy = idy + 1) begin
        	for(idx = 0; idx < 8; idx = idx + 1)begin
        	    in_data_in[idy][idx] = 127;
				w_Q_in[idy][idx] = 127;
				w_K_in[idy][idx] = 127;
				w_V_in[idy][idx] = 127;
        	end
    	end
	end
	else if(i_pat == 11)begin // min case
		T_in = 'd8;
		for(idy = 0; idy < 8; idy = idy + 1) begin
        	for(idx = 0; idx < 8; idx = idx + 1)begin
        	    in_data_in[idy][idx] = 0 - 128;
				w_Q_in[idy][idx] = 0 - 128;
				w_K_in[idy][idx] = 0 - 128;
				w_V_in[idy][idx] = 0 - 128;
        	end
    	end
	end
	else begin
		for(idy = 0; idy < 8; idy = idy + 1) begin
        	for(idx = 0; idx < 8; idx = idx + 1)begin
        	    in_data_in[idy][idx] = ({$random(SEED)} % 256) - 128;
				w_Q_in[idy][idx] = ({$random(SEED)} % 256) - 128;
				w_K_in[idy][idx] = ({$random(SEED)} % 256) - 128;
				w_V_in[idy][idx] = ({$random(SEED)} % 256) - 128;
        	end
    	end
	end

    
end
endtask



task cal_ans; 
begin 
	linear_transformation;
	matmul_1;
	scale;
	ReLu;
	matmul_2;
end
endtask

task linear_transformation; 
	integer i,j,k;
	reg signed [63:0] sum;
	reg signed [63:0] temp[0:7][0:7];
begin
	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end
	for(i = 0; i < T_in; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			sum = 0;
			for(k = 0; k < 8; k = k + 1) begin
				sum = sum + in_data_in[i][k] * w_Q_in[k][j];
			end
			temp[i][j] = sum;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			w_Q_linear[i][j] = temp[i][j];
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end

	for(i = 0; i < T_in; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			sum = 0;
			for(k = 0; k < 8; k = k + 1) begin
				sum = sum + in_data_in[i][k] * w_K_in[k][j];
			end
			temp[i][j] = sum;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			w_K_linear[i][j] = temp[i][j];
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end

	for(i = 0; i < T_in; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			sum = 0;
			for(k = 0; k < 8; k = k + 1) begin
				sum = sum + in_data_in[i][k] * w_V_in[k][j];
			end
			temp[i][j] = sum;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			w_V_linear[i][j] = temp[i][j];
		end
	end
end
endtask

task matmul_1; 
	integer i,j,k;
	reg signed [63:0] sum;
	reg signed [63:0] temp[0:7][0:7];
begin
	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end
	// Q * K transpose
	for(i = 0; i < T_in; i = i + 1) begin
		for(j = 0; j < T_in; j = j + 1) begin
			sum = 0;
			for(k = 0; k < 8; k = k + 1) begin
				sum = sum + w_Q_linear[i][k] * w_K_linear[j][k];
			end
			temp[i][j] = sum;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			matmul_1_out[i][j] = temp[i][j];
		end
	end
end
endtask

task scale; 
	integer i,j;
	reg signed [63:0] temp[0:7][0:7];
begin
	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = matmul_1_out[i][j] / 3;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			scale_out[i][j] = temp[i][j];
		end
	end
end
endtask

task ReLu; 
	integer i,j;
begin
	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			ReLu_out[i][j] = 0;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			if(scale_out[i][j] < 0)
				ReLu_out[i][j] = 0;
			else
				ReLu_out[i][j] = scale_out[i][j];
		end
	end
end
endtask

task matmul_2; 
	integer i,j,k;
	reg signed [63:0] sum;
	reg signed [63:0] temp[0:7][0:7];
begin
	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			temp[i][j] = 0;
		end
	end
	// ReLu_out * V
	for(i = 0; i < T_in; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			sum = 0;
			for(k = 0; k < T_in; k = k + 1) begin
				sum = sum + ReLu_out[i][k] * w_V_linear[k][j];
			end
			temp[i][j] = sum;
		end
	end

	for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			matmul_2_out[i][j] = temp[i][j];
		end
	end
end
endtask

task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  \033[0;32mCongratulations!\033[m                                                     ");
    $display("                                           You have passed all patterns!                                               ");
    $display("                                           Your execution cycles = %7d cycles                                          ", total_latency);
    $display("                                           Your clock period = %.1f ns                                                 ", CYCLE);
    $display("                                           Total Latency = %.1f ns                                                    ", total_latency * CYCLE);
    $display("----------------------------------------------------------------------------------------------------------------------");
    repeat (2) @(negedge clk);
    $finish;
end endtask

endmodule




//TA

// /**************************************************************************/
// // Copyright (c) 2024, OASIS Lab
// // MODULE: PATTERN
// // FILE NAME: PATTERN.v
// // VERSRION: 1.0
// // DATE: Nov 06, 2024
// // AUTHOR: Yen-Ning Tung, NYCU AIG
// // CODE TYPE: RTL or Behavioral Level (Verilog)
// // DESCRIPTION: 2024 Spring IC Lab / Exersise Lab08 / SA
// // MODIFICATION HISTORY:
// // Date                 Description
// // 11/06                SA Pattern w/ CG (cg_en = 0)
// /**************************************************************************/

// `define CYCLE_TIME 50.0
// `define PAT_NUM    100
// `define SEED       2024
// `define CG_EN      0
// `define DEBUG      0

// module PATTERN
// `protected
// O;Y03KcfS1E[Ee:J>SCc_cJZg6)B5ZcZb#>3MN^[][cK[\S8TgU/.)[cN-F>?(A_
// 2/OUc0gL,3KYV/f3-&O\&b7bYYZY&3>YXT>YEU:Zb8/+<X0E:4#<DccB:?\c<;8(
// ?GL>T]Z\ZbL&^O,:DO7&0H<ELM65#P5<]/;0a]g(F#]?PN^gOV,A/acSg-\c6L8#
// 2653(\=2B4@>[A0PDWXIR9A?a@FgYSCI_Rc1B4S0K?eTIgO(T3T@Da^=0;.TeZ<;
// 6A^1\)O:C_U<bHZM<eK72\WWS\O4PZ?N<bP1R;4A-M;#T(g(5#]->F(+5gN?1&.R
// >Nc?/^_;PWBU9F)9ec)R,/Z_cOa]@J],FffB-eABb&?U1_0=FA\d;Vdb:3V,Da;X
// U:?[Y>):HG,EQ^4I:,gCX?0b:9AYEO)a(GRN3&/1.c-@d]N8dXQHWBg\NZH[>>]+
// :08MAULW?7O,J#YKcWDZCRC?R[^P+BV:Oe#c2=<@e,7F+4L7,1Q<d.XR4B;(RX&;
// .&;\+&eOFSS&+-EJ@\dU1CE,b.0B0>FL)GQb_G78JfQT+<=K17bPAP4B/[G5Ea^P
// =af9BN4-Q5S65NQf[(>K7LUN0F#._1cRA5?G#c53:T&?4g+FN+=;.RF\;VKB@]EE
// ]6]Kg/)DI,)dKa1J#R-YF\_g1gA0QASUI>QUg#J2K[YG+R_^S369,FFXHUV/EcUG
// PT7VJ?]fb/b.Wg.SSL:W?,(M=c,MTAF9Mf3=UE963(Z=f.GKVDJ.8dD5K973d<8W
// X@_M&S+13L;:)^J9W#5XdD^Yed\W+b0X]@L-1].-d]b,e]T<#US/IW4:6UW+9J,+
// P2)-LBP4#dSgfc^bEV))#Egf^>L)&UTXPL+,+GOD].ANVDeR7gOVHEWT9b(2@<J6
// eV+].:TW&g?^aN5^fATOdY2YFd==_]=#2O5A&LM3^#bJKcL_:+QW\=0G?ML@HGF?
// A)B7)^S25YHI265TKSO,DXZb:fDQK[ULNEMJ8d>W2_R=GI?c/-E:TH9J?2cPCL3&
// 0BE/ZZ+-&c87c+)9NQEOQ6FWLfE&LS,719OK[;&0N=g8)M+0WX.0QdU+KSSNB_aE
// =Z:@RR+J0Pc?O]:VKa8N444Me#32b.F?(#5<^=g3S_A[d>5#C^b4a:O^:5PFbAYI
// (e/EUS6g1bg]5G0C]CZcXO(?-OFN-TAXL<RF37Md>+7cY)5\,[3Z7aO_Y5c)HLWK
// @W41KdLbe4fJ=N+22L-1aH+>YEXCb1?SP1e2)4815.&(KfYA5AA:1+E&PNF=Y?N9
// -a@6Q_U_CF>R_9?8XH&VgBe3V=QR?V5.:U[PB?9]f,c2I_f+93;P.;UMf&b696CD
// gJ1BZ=#FF8WaY<^B9W+W+3.I?-2<Ycab\NXF1R7gIMf_a@-DH2UZRL/W4JVC<1S(
// =V)^F?cOS>U^+>5QU>[:ECFA?R&W@6LQTBCQ,NMI1-fSF?L:8P#(>&bU.WY@A).Z
// +1>18eK1UWYPeE4?\c0GI>5d>9MN2G:76gHV6F+Ifa9;.5J[Kbg=,@bB3HPKI+WT
// 1;>UfcZ_gdV[f9SQS^>-bbCN_I-IOQYQ)c&;@bca:dWYBLE0Qc;:(V)_KU07#5_U
// NBZ>a2LGFQ3&0Z5X9XINB4GM2;WO=/X>8)6<Yda^>4FOJ@+KRE2d8^]1gJ2b)-U+
// #X.1-;:X_8bc2)?J4-G[Tg<H)I>&+<Re^Ie1g[Z8e7R5NDU+ADL_cNY/fD4:YQ;_
// -JV0d#GXG1LVf8VNI87(XP@WW@ZJ8-,]QQ4;W.^/G87JOEcA+0DU\OKce<b)X7R;
// AMP+X0b3QHN?WX-PFK=,c;/_Q&0f.7-0+&808b5VX.KEIMA-H@KN<A?TQDH,-f#.
// EKC,\d#IIR)/L?OZOLUe0;G<JFS:N<@@5I.aK;6DYX]ISG3^^&HY>@e7#Zf#3-RT
// 09.4.P#1)(4M:(e\AC;N6OWRI_g8I<cX4SQB:[?RW5=:.Fe]d?51?;,@XIN+[+W:
// fIYE1=)A3[).ED2[Yb)B?^ec<_/_C[QB_WBO+A\,.5+Q.[&[+:[.7RW;4MdJQHNV
// e&BaVR5]X>U[K7IOMNK]Lc+>75D,WKPAg-YS3TQB4bU.6--d71fY[2NeAED^1(.g
// ;L4SRF[SHLNX^=D?1(1]&Kc9[23?[TS^^/VI\.X]Ra)EH1^>PY_N,/2@:B1^C/YF
// 0D4GX^VaZ7>29_>@W9H_4NI=I2R5+S)Y?MHdD8_]Z/^@7]_],Ha#_\:W2]NDdYS<
// [R(_@a[3U6FeG=d[KUg3W-@Ma,0DYP?BaZe(@1g=YCgKKLH\D&Ga:QNc26UQJ8W^
// 5a3aDQ6(C#.cS9F;Cf8^WHZZ73T2&8&Y49e5=)MRER:M0O8d/?9>HHW;WODQG6bc
// QS@cP]R\=K:B8->ECc9Zb[G/XL)?V&_>VeW_@#6-bbg=43=-7f5_(-P+MQ(Lea>4
// &;?Ce1-+(6[,GF43S#B2gPGTGa#\EV#9&/(Vb\>)/H7]=)A^FcPG(J,8Lf\.XW^1
// Y\RZV+g4^E9?R\NUcQ>PO/0X(M7R/@E:_ed7d-dc[FU\;B=f[&G7YGRc+N9O4H=8
// +9U4[/M-RQ)c/N(14I7?_3-YXW(.&(F82f#CDA>>Ze#+\[.f_(\.DS2IH&Q6/Ccf
// J+:#Pd?3GNOE\Sa^8VDX^Q:L:<2eQL-^9)_(QT?gba;6DI0/0H-1_W2E2UO\@2#_
// >c<f>f,TG@NB28eeR@15X<8fRcdWL/g.:?e\e,2T7BSF6H6&7=W;JHNR54YeMd-?
// T\DPg]/.S&ER0J8V)7P(:eEJ+:cPe-[:ZM-c)G4XN9;\O&N,\fcB8QEZD=U=44L(
// XfHa4+H?H_6#T7AIc[;7_)T0T0#IY+T6=Y8_GD0ESN<a.+T)2PAO\9V[26gVQgfS
// b]BVW,M].bS-<=M#O+KQFU\G-7JS@ef@0<ecM8U61Y04O<6?,AC,Z5B8([\8&/L&
// bZ04C)J9dM1L,-M1MZ)DLG/K2PeUc]\.\)0QJJ99PQ-P1M[Z>9&=)JF^J//Ug\:-
// MC&HNVge,RKN9382S2Y.bVCI<C4^ZXOga+HJgQV,aWeV.CbaIPU8Q@VY3>,6UAGB
// 82CdcNf@7eF.bM,QBQ==7SR\P?25F5UG@T4Wc=PcdU[PLL?\>^Xb/,?HNJUX(>U.
// DH&8NNV3Kb-U(GDEC;[U;Y1#G<<bUJXBART]AFOZ,H<)@0@G=f4.P,@#TV#,I.VS
// _FT96-f[-@T&6E6MKDY[g2TN0;MBP7TKMa(2J;6130IS:_HR;LCUgW5^=dXaM_;3
// ^9/@.=eR^gg1@,H)5NPab,[1Ze9/Q/#ecM8DI.IKTC>a#Q);.\dK.H4<)g4e7g[E
// R4Dg<&G?.4I@DVON2[Wb+FA3e^DX/457Mc^IgR46X,(O:MIVFOJ(K8_U2&B]g,I3
// 0-+ZGPL?,,[;bL+BA_3SJ20,XDB0Z9K7GC4H6/0B^XCcKNRRBYga-6XDJRP1FIYZ
// X[285UD.c9Z\][M;:3I(ZX[dKO\a4E),/:+5ZK0#]Z8N7DDRfaVadSXd^]HZF&7H
// 1XL43e9N<M2(1:_T?)H5@3IP4,CA][RS5C<TUZ_OKNf0D&bVEc?P[WB^[Z:V6;)-
// e-30g>2W)3_6FZYB7L--CPJ0c99eHKVKYL.bPKAJ+X50.VK\O[7g(da;3H6Y5,\A
// W0L8-?F]36K#B?R\[JLB9d>g.&C0B;:9N:E6?.6b=V\[UB)79g:>W:Q2M_=O3ZG&
// Q@c=@d.3HEOK>RX0+#;:74O-0^_>X;4BbTL5C.BZ\PNAL/M[7#CY@/5@ZW8gKd]Q
// ?e@SJRVA)K^b9EW^INOc68M&>AM>2fL._I(bA=MQVdP3S7AeT1RK\^V:]BNCfI@;
// AKg6,7[2G921:=RU6U5#MOcdY^RSWea28YOGSUBfX0]T0V)E?:X7VX&+]5)?QH#P
// ><@R8QV+0A,C5B&3?aa\Y-&_7751a:/e?Zf.8S^d-]/Hgf0C<^:KSBc.ZLW<A\/;
// 7KK5dg^8A-A,7.0PF/RJ+&]AP\d]77Y8ZBJN,GJY7gB&+EA8DDIBDTU.1C=YL^JE
// \66EWZ._??OfJ6/4H[.bP5DbdD^FA]8YS,+?_@4EdC8N<9\Wf^HP1AZf2=+cC+JU
// RSe<aFf_Q-F14GA_O+122f-IYa)Fe+R4P=W:Q,c)S7QOL,)O1G1(e2YU]USf+C8P
// &g:W;HK4@D?E_Z^6^DY)C@c/9PJ<WB1Q7\@>8Kc&d45)C10/AGIFD:8f+M[5?605
// a9[Ag_4XKXC:_QXfM1S&+#bQ.3DEOK#J/2=@9LPRQf/TMe9bWb+cDBIJ2\M1PTKQ
// DD3@a:O(_?K>&T4SF/da<MFO#e-K_0fc>J9JQ+KW#V-G]G_c<d^@1\N?a-18[A2_
// B6P17:E]]SE#L0S]9V\DI^QDc^5?(N34Z/?GHXT]TBHTG\BTT&^<8UQW#b]@AV(f
// Dc4J8AVgXgg\b/Z49G?<O>FfQ@+cMBV63C(U8(^XE9L7Nd(N=0=?1R-:IAJT</[c
// (b^-g;-3[8PY;K5gG^G7PZ5=,S:@OION_/QCT<\b>TSb<?4,;99#O)0B<>MGP9A>
// T]e@.GCO8ABO#15<=OHCB.MDc5FE>BX;#R7H#J]7&YPNd=DU3NAB,<bA=>1ZNM5N
// ZFJ;T7ZOR];6>(GN+Y2;M#=7>+AG00=L9-#H5OM/e[&LX\@2<?V>7)_E/065ZFQ-
// =dXZ.=?B#E+=#WSVDg5]D-\Ae>I_0FOCS@J=R8G&/VWEG/6.C&0N(+Vd6S.cVI7=
// .E]<aCIK:JV55QUEMWfKa7cXKI?BLPF<\VX,YI_,_dC-X9Y^O3F9g]3288Y?+XVY
// 3U@.>6S1TVH6<1(&:Q@CJ60XG+XG:1>g@G8C.F(70b2a3/U3eU0?FL_@<6^IIb:2
// H<ER54P;IB3B4)404:MJ;S\_;cM_a-O\=V21&XJL_#U\7)?^2H)+f6[D(\7DQTE)
// VXcM0f,IC)EG6M?_GGVGc+#CPQA.Y<32c5-:aTc^<<bYLEO,.0<##L\,N4OI&HaL
// V]P]LcG,[FB[))T/M68BP84.L^R8=>-<@D)X1[81E3TI7&1@TEZ?OdJe^BO.=eC3
// [86c)gI^?8]BaYHO0\B[]6YH+WaFQ&YG[#I6T@X@@87Q00D:J/E?RP6,HJ5DV[RQ
// O)bXfZW]O)47.B0b>^Ee2=3+D2N:F\W8A=38]UQ=XXD6V=4:G4KH5W)--]aZO>b9
// gY=](O5TK2)cFK?,YL>F;7E][eR8<0H^cPd,\[2QC#O67,b1#R<HdM_L?3F2#L4J
// HMCfP[+@IdJ)P)2a?UIgJKGg\cKZELa:8^V:,(2/E8XQ+&35@e>AR]VIHXJ7]Tg(
// W;Ua9LG0I(Q(T4Fg8R<)8?f#0Z(cTH5)<=9LC.1c6d??8A,f+@=<T.8SIa(I_XXb
// SK<4b^^S1(B&.F^)P-U?KOP=]V4IbTIf6]=U@]IaO1N<Pfg,Ccf,aC1ce<I])VV8
// VEU+Db,.+LE@VN3>6;/[_;OT(dTMBOY(e>9F3BW18-5A(GbbX<8aDELJc#[OaU,T
// 18O3HIQf/dSV=3I0T3RNG.cO+M1J/eFYSLbE6MW@CJ8#\CVUMa&<3NHQF,0VcDd6
// f7_W6:Q?T7O@9>0;5.MN7>(;4aDDF-_M-BADG+1>_a))4HX\1M:2[&>]),6:>)S9
// 8\I^dO.XK18@(gW]3a2TTD6F@)PDM):JM.MgDA.\N-_?Y@:Lb[0V#&/BUXJTR:Cb
// 97DIG_M-921YcD6Rf+^5R^:6bIE@3@CGBXRK6_cWgN)eb2YS[e9gTD.=G]f\Md_-
// I9OcD#NV/11CBV,1-D-VSA86Y>_2/#_8gNJCYaF&K<aJ1eHCW\T_\VPAcX?aD[S]
// +G>15<8JGWe(bY8M]O.H4PcI(+=W6:6aUg?35;7_f_=XR-75.LGaY+.?@/+&+SR,
// -1+VB/JHVD0#VcG^?XWWSb^+IV=VYN0(UIB93;g;G\MY1Q6QC4W]FA-K^O;SQ29T
// F0X\&^[10(T(M<DC:#AcG<ga+ea#35,>d0E)\FeI:3D&]F#T>^\A1R+O^9,M3G+F
// P5:W.HgGC4_]GT5-?&eKJd_)^+DD+Se2UJ#ZXGW83Z4;.eNc-VW;6bTQ+?c?9cMB
// e/T/V(&C]ZFQZaQa,4KgEg4MJ&-f]4)A7Z3d59>X(H(,OU1PR).40b</[\HFbMB]
// [EVgAJfGaWWODX@)M@PgLU3DcF1@GA+@Nf2f-?V9>?EMgDK/R?GN_C9BKA)(ea@6
// ,:J;Q@c7H=eJTBC)bG[ZBP<X(,8cB8918B7FE2g9/S57aX27R8F,)FX_/2<Z-().
// >>@g9;FSYH&eA-[6-QW/>;0dLDB3K1]G)7(LQPAg=)b_+cQ.JP^Q?[.:g;>;^A3T
// -QdD#fdML,EXS80MMQ+0H[#-4+I?H6TWH3Z_DB.b491;VV_^fO<C(3>K#[HF=E5C
// 3,gMLgCADS:&.^Vf,f?K2V&X#+TBHO6Q^YD=<D=N7dE@;f3UgfHbfY<^\B31[NV&
// )C9EM=&=.LB,]&T?YX@XTM,d,6cZYKZ.JKN12\P=f.Zacd5@C#X^?EATW,)GV9:O
// ;?Y:fXc:RKC2=bAJFb1[II&VV-Wc[Y25TH^&9#X>IGE<S8@MB/b])[?#Y)Vf;>2P
// &?ba>eC^FdLD?c2P?WH6+_H<V?)Z1gEZ6LDGe25F(2fEHPHW10a.C3RE@4H9)d&/
// VP/=2Id.MEN9T54JB=7)N.,@DV4^S=J,>,GA\#+/&WV[SU^47JZ]AdgM7a5Y)Z&:
// A=-R<K.K/d8.5>BR7L-IX3#78]<>LeYbBDfPf]=-UQ)7f.(:Q(4e4b^fG=^UT,_M
// P<<K1SD#dSWZSKK]_[F#_+9P9A&GbeH2@1?&9cH5AC^F95NB+3d\aR+T(;[H>F0D
// UO?;=N26^^MY^T&9;acCNDH(/W:T@5da_P3V+_OKU[Y>PTQ8&1:YOTH=?GbS)a.>
// 1YT8>0a5GW2eZ/g@:8VOO,G;0+-#ZJ3N#Jc6M[=E34e<C@gVe?3P^fCgbU+8Z7=B
// E@JRQX?,OLc(eEU,N3)P2P[0DQU-E.+N=4)VTI#:.^a+KVG4Z]S>LM#ffJ1N6f&+
// c]CcdBKNQGX[H1fAVP>@a\@ARYWca6(PG=F>dRFD+&6Z<;:dXReP?>d/05-:W,_<
// NNfF<TWAce/&e.<_cZ[N)X.=9;??-bB=HY,MO=\=UF.[TI:CQ7)5A/Sb]c^Bb<3R
// WeR;SHZ^V\MASH.)GIC:-FW@UJI>g\CUZ(bE/1+LI]1A<UI<g90,OOF&HI&&HE].
// AMG[f-R&4QJ]AN/fc?5+2B+X<cN,K04;(RQ75f]()_)+3WdSBQ]277b/6CNVJOPN
// 9YLXB9>MPB[cE\7)G?7PXUf@00MO.GRPPED7Q_45,+,2IdOCGGN93Q(f,>(9_geQ
// 1WRO?YCWJdb4XH=B;3f)S/5Wf^VP.cHMAWUSe,OfdZJ?4dg^3[:M<T1(>?7>_fV&
// _T_@3MH6<#5,.QR.gY2K&FPE8XJ8Fd^eBfC9R+=G8H9\E5]E9K)(Z?41SeUOK)>D
// LgP\:JC5^#\GFDbb^HKBN.O+U1\QY>(@d,aH(D@<;@GK:V>DS+\YL/].@2K)<YH<
// =K/;TB+]#e\P,cJ[OH+DH_237eWL.Ob<T:>EZMV^@\=,ba^\,.2,X5H;/N/#5/aM
// >b1Lc,TWW/:.G@99YI;?V^Tc4f/7Fg;KR5Z=5(I9c>2@QX[Z=0)>7):&?Q;7)RKP
// AI1Y7+A#,-:_])<g7R#=M^-e.B=-2>LQ>UH;;GC7+4<8Y&<bF4[c<g5^c6>?>adS
// +fH5>[L#Hdg5b[(_RD:7XO)T-8L60PM+9:]C3d;,G,-HTL+QBOK.SD4Qf]+KF:9(
// (9WA8>fYN_PVCRT\^BIRNTdBa(ge);XG(g>G]f)/+>^;.@c&=HU:N2EM?(O+>F7G
// G_2XFTeX>@&(c64.NQ.3H\[2cW@]3J^AO(\PI^ZS8fJ1V#>Q49F@eL[UZU^E7BG&
// g695?_G@4VNA=4K6MRf]cB@_1;e2beH)C4bHE93IP/BcfT(6e@+N0cb0HZNbB@?5
// W\b<@FDdec8XEB:;d(FB=O0W_-J54#a+F1TL0f,:0VLVT>X\1dXY#eT3b:S(-6(,
// \660[EBYeAc_I3FU(?1OfdDX+F7=R2:UK>JeU6A)=M;d]A@H_.V&<a6_R>0])5YT
// ?0O#=],0CJ5);;+bYI,#8QF6^bBd0CIM42[4V)3X.bD9^)TcfXM=d>=?^Qb&B)^=
// PN1N&E]ZE4X#d)gO;DLI+7[=<8V[d7Z3P]4P^H^U&GH5AWX]^R#3)P5(^_#_:>DZ
// >PObJfCD[)2>#6LgHKbHL::-0UeN(=Q@[4XJIY^C>G\Q/7G^#)9J(&N5^b8-YE8M
// Z?URdX9RfB_CV.;8bM6#&1O(1FHRZT93]&H9[e7.;6SPG&H97;c;Qe285.dTZ\(T
// ]B1OZ?/0-I7WRZ=@eOHI11#d::97cF;\)f];6>CB((U+P=ETL?QfQVcb1L>#DG@2
// BM7-I(Qa79>-@=Vd:(E0T;BI0\UG<WVY0<A14UIaG>:eE[UTFf^5K;AcZ)^9W76G
// Z0Oc0>0GTBF>60Z@6X:[>^/_f\K\X0#cILMR&KgLFEAbOCB>g/-H>1#1ff[@(IYg
// b4N5P6/>-_=)7J1_Fb(@RTH]?1&J42/GCR-gU^O+69XZ?.9BY1^a;48:IHC;__.<
// P#YI1E1Ie&R/DDOKEa#fC/[IB>MW&A6YKE6OGXE#+[-AZSY>UX?ac:M5@:WQD10O
// F\WT+c\@(Ta^2<:^RDPPJT)d-(SL.VdNO(0;6bKI7eR#]J,@PEY;NBKQaF42#e5U
// Gc[YYV@L#6;D^4L[<57DbAe[[=]M&R92M6B^]A441[INZAZEW7=-.SWM?OB]K>\]
// dYXc,RgaeV=Z[?2+0BGFMa01Vd1)5L#9Z<<OPeO@^6;^[KaJH6GO[YRH)IVF][B_
// X,Z/1fGPXIJ9TB?53a,VN^0TE#DP27MKI(.L3^-S<e[?PI)83#e>N)L+3-:AgEEJ
// 5g1-E\SVC:AN_Y>8RaK)Q1Y_b7U@gF4ZK6[cF;]XHNVc7bU_Vba^bEGM#7&HBADI
// OK10g&7?.Ld:/Q_?<R3FO+EO7J&XN0Ha+^^^2D_3AgDE\U-O7-G=b3XfJ1TA=-EX
// aBI_H5VNX/1@4NGBJ&S[(3Z<:RSLE/]eg5(c:=[]Q?6U]IFUg?A0F1[de^DfYMZ9
// K70_;3__X=[@1a\&C<9FMZT]0-C+=&bQ\<da[UN#+(-#c^1NK==E9.K5SILUJ^24
// 0W:\_:(OY.&<NPKQaBRQB_#aAY^Qd(X/8(&c8dD:528YRHb.D:LO+LF&U35FbV\+
// D<--,EQA>^<&F\SDR@fX_N<2dE4a/6dgP_\T9c]2?2TBO>=+@:T9aZWKDe70=-GM
// M_./75XV;aX\gMJOS\c]ePI7,K]AE[M&;D)eQX[RT_H)N#D0^-Cfe;L19b#XF2,[
// JV^B311)T4#W#=MC^>A1?,Fg8P]4JZUU8>d8[YGTb_F8+f]IQ.6>A2Z\D]CNK\6_
// UR@3R/D6HB&=G:C]]2>REg?1SHZRX2b2W)GeX^L.0aC\/?[DeHQFY7gWf&[<6/LD
// )FB-_+\5_P(1V>LTgQ6/C0:ZHM]&]=Hg==gd\UZN9#B;7DP[E8\2QH,Nf3EbaGTb
// K_EZKaKLa^/ALZfb7E-P.AL-8?41DH\^BTEIW+DG;ZNO=eFdX&KJgH-3V]&[7gfJ
// 0+2552I[Jc,:?Q/I35Z(U3G@RZA)(Wf.C1?,((?\>C6CR;S:.\D@[dcJgeC)#@5F
// bBfEY2RXgdG]FJ5Ue[OH(H<N>H]^,)S-?FaLDbI7RcFf?<ZMI7XG0DScc9ZDbFDH
// -#^L]C=&SKV[DeF<4HP<&7\GbV5ZTO@D2Ub6RFc3,)801H<_SAV0MG9U_1BfOg>0
// ]A>UGgBWQ&5#5=:&P3(B>bC),\6[?W&a<..(3ccOIBF&VE1LaPKJb:fY:4\><;42
// @cZ3E>8R.>f3I7Af?_+V:LPQeJBE.8SJ33AdaL4N/_0gaKZOEVRZD[U?[UcHc<<M
// X?f?&g^S08_H;K\HP1c=@Z)^Y2f-ZZ0da/A2RV/[5D7EPDS+5V@N#K3)9E\XPOHY
// a/Hf\[-<8?M130Y][<+T[:L0=Rg:);c4SPe\LW_EQ+E;7Y0RLEaY.KUDZX?&\9UF
// b1f\.-_4-0d-5[CP=H4\QKBe?7MPWaPQU\L,^Ve0+;&]dKg:;\.=50?)S-.48+Va
// DdM,?YJ\_fP]3JFa)c@?NRa+dOCgLFQ/^K],#6@G&C9=X]][a1QaEOB612SBQB^6
// EMN\X7..D=>dWM-C6T.WTS-Y7><NRY.UJZG^J:P?YK]g#BKPb3Rd1JJ>)G=P[N?;
// g\9(_>45:_g>?:TTWcW@H7YS?&P,JMRg^ZHG)-&af@Lg=UZ6G_CODP8@-3/ZHc0N
// QKTS5VQI0^GOM-6M)\CcS2[Ib3E=IX^[)5Z9[Oa(.WgJ[d4@ZPI6_=@+eg3g[5e0
// gdKA>,;;+U3(d=CP?\_N,2F),)M-UE8\cLOMW&9@4OOYc[]<X&-9A3=_5II#VcOR
// 9[6/)2d3_R8?Y4ER-W7)REZ2<c/c:]73=?H)VA&T&W+fe(5IS]U-^Z(R7ZNccZNV
// Q8L1@0W9LQ.f(B^/WFIa6g>0&Y-K9>TN1Sf[D)LEbe/K;6:cYN0DS\MM=/XIFM5S
// ;MXe]ZGA/QTYb<(dVS^+;Z@6]OM>B63OMX43B=6F;+O>JO2:P-7=91cIg_+&(\:f
// Dd\RO:A>0V,W]<<V8C3/X4QbZaeE(9WP7PDGfHDUQeA7fZ+R?>-K2UE2?87g_O-H
// T,f&;34CC>KN\gN@_AIDS.ZY#KVE?^MA]_#2_[O[--P5/e]A4Q<(Z:TbOP9,XLgc
// \)LFe#Q;_BTYWLPDJI>.J_EXYP@ZdR=44Z9,>VX(K71dQ+TH5TWSJ3;#GX]EU<JT
// 41c/7C68</8QJ4WKdfD]3I[+O_YH5FXK/EFZ?2dI@;5-gFWMAgM.f-c,\a?-_=T3
// K(-cP5FG@X17>9=^+L7UAd3&]EA4E712g0@bG2#_M][YZA?SLD[bBJYR>;3B90Sc
// V&Sa_L0V>KW</N\A]@(]V1NfR6BL4,3gS_KI9W:@aNY#-;^-B6X(29H12E\;Y6P+
// UH92fDfa-ISWYJPc3(RVR<TO?J6#+[[-;]TJXBb_L[D=6,G.-YHW8<>VaI(6=;\1
// VUJ0Vc6WK3#,IdMe?S0)8CY^+SY?,K<Q/bgVW,FE##c>9;Db+B1RYQQ-1dCU0MA>
// #IKU.=P)C.([Z]&1feeYdWHIQf?T3(OW4EC&D;)UfJV]OO\cE2c+/YAEFK)\>CTe
// P\R,2ea^J6A021MVROV;TdaH\--eYX@SPeV#eUW@O]/MaP]5D&/c1[TPdYE831]b
// VdCCbD/>&A/+CLMTDS<E>Z-PGVBELTN@M0R^SM.C]XaFROL].5-dE8P=Y(_1c[+U
// 4gGTGAWR/DR;<B37OXBWHYegEYI[bTVLU=e@T7\R>VU:62E0)aUKeFU7).FZ(+Z-
// Ua-+,R_-^Q=;M0V<K3&-M(HHZK\((NZ&<ZXa3T^CG[.#?@H05/K?YQc0dQ:?5#IW
// b25W5..TN^C[(]OC1e=CPeJT1UdG@R0_-?>1VgbJ_,S5cMR2^ME\^EA79;0K.3XC
// e)ZRW?MVVN-<W2_AeI01X?X<:.Y,:MF9c+b4,6e#+.6d-eLVe)d:B2/&fg]ZbZ,V
// ff.-I^C661.OHbZRFgdI_ca.X7fHU;a.N.c\JMG0^6WK(SRZ,FPLLCV^)P(2I)>>
// @d^cAO(6@c>B1H.ae1@AJ6f=7N8+Vf/_J/aVP,1JGe:8U(YY;g&DQLfJCGV#^/LN
// RQe[f57DIJ^5=(E9aT6W[69OII\O.FK;I9V@7/LD34<bcIA=>LOaJH<cL#ScIg\>
// IR)Q[(79DE//V>Y?Q_,2#-87_?A4M/N#CcN#,ZH#^NB=JKIM?NFcZWF44XA2PdFg
// SR:#7e:7HN,?5AH,&&1</M_Z>B;f/,3X/41NZZaY><0FRH71YC\bDP/.g^4C<M=F
// C\QA7GPW@>[d/aC(O;CQN6HYFOK8MO/4UJW2-,E^?9La084XM5\e4?a.+_/(6J=P
// f1PI0Q/4aOHTSf03)LI=dUX94B7Ne]&RDZCI]Y7>PBS^RD>=BXGa<9_c_6#LPY1P
// WgbK7.K,AbR_Ie3S8b1Ve_=WC<S#=DI,Y=KH0(/=K#,ZEd\D#9LA)Q5A(??&;6/5
// @d#LT0]N)E.Y3eaYfA/D&W)c)60:Ra=Od6U+dH?\c>7Y86;.]LS>PG=T6\d4#^E>
// (-;00W4XY_F@<]d&dCFC]+6>-_;<QHe=>&RE\5YCOVCfEf-(8B.;daX8JQ182AcZ
// #((T9=2N,R9PbW?_9J>;T-M0e89<V4^IB2V?0GXD)R6H9[D5GgTFb=AI+bEKRb>N
// 1G=AgH6I)-E7>OO4A#dbZ[Y&Z>1.]NTBaFfN3I>1GWS][EKM?)SP0,T+2+7+<M.L
// [\P18:#62[SaAKJb=FAFH3J:9DD,NdF+60FVUAEAL6\H:L1E#ZMD6E-1Q2IBI@f]
// d^<?[+T[EI7IWDF#A;#;?C&-<8UF.46F_XcLOQH(QXGf_6e98DR3F7)5a=5:RHJB
// 9(;48W4SZ>9OUX,4OI?,F7>;WKY/Q_QM_0J#Z)NcT<MT]-d,@faE&e[C.<>X/AYD
// QM7]US4@UC^(V.8Q&),=aY-8^BI:KF&2)(^F4_>GL#]=SS<7EF:;&W&b;O@.558L
// ,V3^XWa_8H<YJ&S8@N&IJMX::A;B^ZX\EC/O=g@_(^Y7.EKZZg3VJ^>cW;:TFW+W
// cN.GN=HDg1Y&81KA]_CAA[:WE9G3)0Rb8;Z\@R7<b[Q:4.1+38\()L52)&K(C:1c
// be1d94<51IJ<^F(LUM?,RV/Feb,VZO7@>V47@3bdP]N1],EL66H/ce9,K>_ZTO)L
// [)J=GS8>d>3-72Q6#]b8;0=?M/H[1]AV.&C6YY)6I1KBI;D]:MKV-ecTe#I(<9IX
// g53IbK4H4+dF7A/XM<fHY[#f4@&4&@MN]<E4U_72LGQWM\363b)]5cIA/?CFV<9g
// Y+>>ZPNAE44\-Y&IY0X^J(R,TCO/HXCXfM,#-.Y=2EP9]a=e6[OLV+N@O--B3&8D
// (70E4[>CX&5SRXFT[A;(g_GAB]-D6N.]4>bE.?K,Ob.)#H?E[eYJ-+2TZ>MKgaL0
// Q1F4aQ=?J;U0=S9-2Y05.e#a\[[+OXJ7X]+HU+OF(3?9KL@/+:E,<Of(AG^J:@],
// A\#SNd8aXAfd#O#6-Y)IG7<->+2ZL_K])A/V&dNN=O?.SN\Q\KV:NNWDCAaXe;A7
// ]@O6/M8;?dc=IL)O^RQSRT.c7e[E3CAe<&_KP8U()]gU..L@Q4gP-DaFbbf-gT>/
// VMb&B/PN9^U08/R@XeDTOPVBN8c_XAV3JG:DW+(B8_B0U7EE-1_+#[HL.7aB1F/X
// Bb8fU16=_J8)Bg(L5IQ8[DCRMS2ffD83Q6_JIEXe+EYA.FO4/3R4=aMOF<@_8]d1
// SA=HM(&]VQ+LeW+X_#CcdMD?0^>7W2=g7@^:Oa?^J_1Y;VQT>1369C\fB=ECDJ16
// @^P->=2:\YX.CNGJ,I6VS?)1bBS0\>B^]4fZBM5D.C,JF<,\OP-B7T2g#g&F;SXe
// CRH0ff84-OU=OH#\UN@6cR^)]_+NgcdY4M>\9[NG]VdP2H:58=Ea)_=.X:=EX:AX
// E,.8ES?U-=(UgUJYROS+\<ZZ/:A9]PIAe#<RK4EgF=PZ:F[/>07dMTGaHb0CY,FG
// ]89gg(F1H<(7HcGQ(,aWdN#;_\^ffX)2L[\&KJGYE4UVa#e)CR8g0B6]AEdadWJ@
// W49[)8:32NSHA,H9UQGT0?HIJ/BMNHVPKAQA/DIV&#Ae,3]2]30^=OZO+).ce.g=
// DB4\]44K(?J&2K__^ZIUIYX_GbPB#?L)P02(c>E3-ffMQIQ^3a>C?JLMAL=Z@.K@
// >/U^+KM=?Sg6Y7[>U7[WgJ,8II,a_#^_6)H\CHCgKV?E<?KRZ4]>&N])e(3IB)FU
// E#;N.cRO\K2&<Oe@(TH+aH@[].6B:1aCAaV)7X1^1SJcOQGG2Bb?/)f#C9Ue-]L>
// b4]?+A_VIVXEIF12Z/MB,XGf8=,^+W:KPcGDKR8e3eIfC)C9,U?g#EDA@f\H&.38
// /^ZIbS47:MgBL5;/_N_)e--cC^JNCNVVg.(E:e(G&,;a8g37UH]H[V84Na/bLK]<
// ?7(>:=bHDcZDQ8J7EY1+]d6@NA4]-bU+)Y&;I]P@._>C(S@,TZ#2TZ]^Y@<.VH=B
// \aObV<a_E@?b\W@WM]G/D(2RY+SE57#D6WfKJPA0TO/X\#G5U+^[J>2ZD,eI7R[E
// TO.2V?7MG]Ygb7g1eRSf^EF?d[2Pc@E#&88OTgZ_,bL-2?A0a)#9WU[W=>+)feS:
// ?_=_146G;>U2(Pg[K[-GF@MSX@-Ee5IWT27B(WBYV(b+d/1:^bM,[YI]a(P3bBgR
// b=THKAZ&JXQ1BD7&DO+#2P3c-[Z9\YV=-=Y.E:.=IM(35T:?M32W,\a/9.TK6)5\
// FO>bDF\1CXEPCWbaEY->(0@)DaXTZ>H#<B+eGdTE(RHXabX[AT-DF)YP>4?#//M[
// 9J?dZEVS\-(T+]3<I:IL,cQO<aKQ<KO]6__DUTV/OOVFXK819f>0KS??9_UIZGR&
// BYcT8E4/Mgb/+L>c6A-D\<6aZ^,+:QQdZgIb6GE(fJ?=<cgK(CVO;eU/</PGcR]?
// +C)bB>I0dZ>VKDZ4&&)d.=?L#04+7K#a#H&6=(T<9Yc#GD[0N\_XP+e6N-dJ=bOb
// KQ#4QY-NB(:?G#1^?(LOH6-eOF2_I&25<YQV^YIR<5b0/]X(V5XT+C1dAN=-B1;O
// ZI7:NB,cFP]O1#EK9I(YO=(DQ,U)IK\RA4N^).-:#9PKG<IE5aYP6YgW&?A11X)g
// G)fG@gC7aR9g(3_&2JR.WAU\5&UGgFce9OYL.AUA\OA\S#RV_Pe6M0g1?C68W.W@
// 7I5-\HeB#2#9\W:VVd6/;<fZRKfC>ca/T[Yc)UXTHJEIQ+I28,X>DN/.C_UVd_G4
// P6DUR]FMQ+8=?aaWY@FeP@UMMF4RZ+WZK?Ze1&d-;Q-Icb5a#1U_SVPN=^8L;<ba
// 1F<@WV4],OF9[M-?377bQ6=94LN5Hf#G_IL&C]CC\1@8K7SD7Pg07;I3fWT,T0WX
// MFIH#@(O/6_I4,6HVG6?(MV_BQ7.I8aT)feNFaaUE4LG=NG/S_CKD)B)WW,/LM-X
// Ld(EKggJX\7@EH8MI2ZEH8P?,?M>OS,]^GTRg.84&YI;WV^T/DUC1Obd,_=CIF^:
// BeHH,HXcKNE#>MT[E175Dg7(3/NPdX^C^^[.QH30cG)Q<3C=PRIK;8G6c7BdSK[d
// 3b)<XBQ#fI9ZfII]<Y:KU@P7WdTU23DIV2<QX06X&ULH)cV-=A.)UL(9V4cEG/D-
// ;Z84+>@,eSD+=#gHY0@3.CSG^5B.Pe\H)4E61U-;?W>I2KTL,G56gCSP&Tg2M<LW
// GM&N?4)LD#b,U/172IT_gUdEgS[X&\3gO?P4W[K]2e<U^=)Dfc+I822d/J1EBU]-
// Q0:1BRf@C>CNMHUE:YN5/(Ya;.UPNbY]44dcTFYP#^DBD_(BWOF35ZF+608<0/-N
// -7^:fg3EU<D)4N4V_K-c;>a/6I=T?9]b+EW(>_eZagBea^S:d7^c,=+5K84QX:e<
// 7Q#HYDWe:dMAMGAV0R4LSYH--&)J@-:<NMeB@;8A,e,YFbF@UNRDLKgGFLXN&Q1Z
// 8(JD[=ZP=_(.+RL+IHWEA:_VQ(U,([<-MB_E-2/:U):+5g[GB]4&Tf<IT1FcXNf0
// @=c85BAc22<?[A><3,X03>:S2?.H:WgdBA2GI)Q0LN3TH]e;(WaZe[TfJ[b@[Q4.
// 3BKT-21SFRZ9@bcC2^W?cNJM@9C;af<NaQH((&V51QZA5YN#RZ#KFP=,4=,R\K4\
// 7G9/[Aa<+>BD=YHgBHM2W^C9[L>P[)4L[#_?3Od-Ga\D@Xc115S3GV@>@1Y>0Te]
// ;e-(2QHaA\^ZPN0PE>D61gJ<-Sf#?5M>Y<JOF&>WUG_)=+/K0.67^<OVZZZG=/g/
// (IE]U@Tf/Q3]I&fJ>bUM>2fL67Z^QM_?U\U13C<58g(A8ZM<\cZP?KJ1P&a>f=_d
// [G4]CRWXOJV059S\EaBT8N=S88bPRDMFWEXDB))2<faT#:aN]34>>#C:N[1\BP^J
// KL8@Ta06PMQ;P4KNd)fK4DSg:Nfc\LAMg-5fBX6JPJ^/,)VFd88OD&(C.RD52T86
// F7[+-D2:]@?\VJ@>]:aT9RS(-(_+X_NRabM3,D,CG(SCFfC>6McJJCEDQ>ED,EaV
// g:8L)#bF.L:gAUG>S<ME2^T;YM3#A_We]U?V12,JZWQHVe@3\#09e0Idd/77e[Z:
// W2B_<-DNZ;NTbC&PJ[/40KcH52L[>5/f:+8[9\g)&M6YX2+-FGJ\Se^aIHRXd@>6
// N>CgZWab9NI[18A0FaHC_\EX2+HK_XWNE#_UR2/?OXDH3FMT\fD;&:>3+>5+VcGH
// 4884JE,OI3#<&dGd<&<TfRP:D-_;(<JK:Aa8HN9GbIXVCO([P+,^M8\e1&/R9Fac
// gMXV0]KA7Y/:a#d5/J.Y6MbW4UF89M3U1@\FVQUEIA#eLTX+d#c3[SF90Y861_;Z
// S40<7KEL[SX=C:WO=J4>#SG>X[cFEZH-PK-f[EE\[-ePAgg-TCV20K\B<eK+LAGN
// JS39())7->A4<<QEb4;OGLAE6J.Wb8;f+aO9[]Z7Q#C5+dW;]d]f3>b6V4D+D.2O
// G=?OLR=Kc?IU>ab5L9U=7N/df-Vc]fV:PVO/CW:GEFL=Fb(Ga_C#,(b46=DgDb.#
// 3f;G(P2FPga#b0&cgKLTZ8cTgS2>fS]\^7+W9^/4:-c>^b?OL#4KJ3L+R>;A^VB6
// -SF:#?^8IIg=EKJ98WB/G=9Z&:bgaO5\+5TZ<FLAV6_D>H@KCDOS;AR1&IQK3U=a
// dYgRICc#Ta/NBae(aN,e&f7[PdGC;d837A_AP=3F1(47IZ_5<^9b=09N=I\+L-D&
// S^,F^S\2X7dA,8(>7e,AK)LYBWZgeHHIRQageL)JW@DL^_B4AbP;8g^R@JYUMB&N
// =?+;9)PYVF@+J<3ba&]@J6c3@[Q71JEU9+D7U&I_gN:#IdCR]H&SGg1AcEL-8)@R
// F\G=C/Y3>SYN#9E8&>^PXcNATY#V&+TFZ&--(>eJZcDPe-CPUc^M#PHDOJG<F/US
// 7\HU>L+70&6SKVO],\6_;5?262Y@C5?7,/cN]=IWII]]A>.)a&?0]>XLV\V]^=#]
// g5^3F@HQ/&/g=VC&IG#EGB>5:7WP(&dAS9//AUK#8OSVWH,<Md::CUON.OX.<Dd@
// AF+gg&&5Ac_Y;cN+YG_LQK(F+F?A^QPZGb87#eB07V>1:/C.AN@0DZZ4E/J=eM;_
// PIR:JBD]\GG0Y\^Ia@?W-:5FUS>cWPOAY4BHa;>aRWKXTe<X>D2LPLOK#98)/ZB(
// EZ91b<XWgP2?gLg>I[][[>a?MST\6SF^0^TdV]A@V-)]cY2T89DF1)?C;NQYbI>P
// JX0Zb?TfO<Z+T43f,Q]D/#Y)05939C:+.BMDH+.G2V7>CREA0+C=a4BDC<>RQ6bZ
// 2aG^Sg?f2GA+UZ_[SA7_ATdZfGXL34]]]6D2T\+ZHC[#M=<D9IZ+GI=&&e9S^dWK
// ;^(_eE09T]BY0JWG,L_3gDVX4R9-b)&YV6=V5:.OW_7:d1QGRQFAbAY&LdYa<[AI
// 5Xab7b5(N=4E=WIIO(.8PS^6b^bV7>5cA(2,EbFG]RaZ(?PFO_/5:e313=e#1#+&
// U9(Y?]:L3C@a\DF,K@3CGbUa1FEQB=4PQ81DLYM7UY<K)<(Y#4.=F18Uc14].dF@
// ^/.)YPf\]PD=)^6dZb]:YdG/-W@)BSUSRI2Xf\4MB:JRfaEXZ#-Ac8LX62YZPc^E
// C_/c2cc\J^A6K.(OVT<F,]LUN^DZY-UKTZA59E/[9Te4L=]W8L.I.5f]Y1LTaI74
// g-<D?6PA/+b^RQ1X]ODOf0GE]cN7PgWN?BRV/R6R1>E+4cG<3/:#+19Nb<CJ/CS.
// SbbHCEM;3Mf_;dcOEO/GP)gEf:9)L?DZ^V;)S@#4aR3F2/M/0.6YG)-6CQa)E>6E
// XB+D:01.bJ:N^6V_/.SGJMIM&5OBZA);g/PJWg3@MQ2=;C[A,2:D?_dRZQ?7U_(]
// YEb^,.7#D?U?@E2-0NZO:VFB=LI6KT]/cA9c.DF<+/BD)@Qb_1#LEL8BCQFAR=Me
// YLRDd9+I0MGYUS>K)MLG=:?bd?@SC:.1ET8FEN-H&3FA2c/HKCL2Y]#W(7:G;R5+
// 0[LU;TDCO+_3VUGMF;7V6c-HI+\16MWc<eI=a+4&N([4be^aa,2-1>+fW7TFV7d&
// &:CZ3KEbK1H4R@Cg1U2RZ]6T^Sg01;\7)/Q)[5@<NVb;eTFP#(G?.V7D4g:[<#]F
// <KUe=T49c4TV;[W>GgLP]_:d&;M8;8OT:M.F45-M:XY4;RF:04)Uf]c@5]L^<G9O
// &2gW\:A9c/Cf_5EaF2]E5QXN+;QPXM\,-3-)@WLY.c.BI5_;29(7N+Z^H-/\NVXS
// 3O,F16^S7#BOUdaC-7[f,;E>3X&Pab1VT;;-M3G8@W&D,-EUGKH)--5Z3Y+cFB.#
// 5c5]a/Q;LKb&NJ66NPFdREWX?UE>.,NDWbW8F+E6P?QdWD\?3ANO>:2<2aCT<+K-
// 9]]9b[6TTU@V.4[G_X,#5CPJLG(=R)+aMCV:C(]^(RVU4:;@GXbZ+J8]JABRM/UW
// ^Q.-VLb3IV<PDXJc1DM)1WJf2@^3I6ZRN)>ZK6:PZ]eFfHN5\aLfA@b;=\)gfdg3
// ?U78&cUE-#JcJZ0HVQWfAc)1H/BH)d?+_P-EN[?_]VOAJf?&L)BKOdS9d>,e+[]A
// YDY?+6;Nb5ONYGZM+d;1AH+d9S&:O->E-D\D7X^g];W&./WN;bKHE_\8NIUMV2:+
// G)<7K]KG4:,L0W7/\D/M1EA&X0X)3DMDfZZQacB>&C0H3gDCbL-N@E?Na[[VTHPN
// &,B,TE^=e<J5YH958Uc#7,+CaNLGLZMAb1.b.RgZS_QKBK#H=#MCMOd\d\D-<(]_
// 3#8<&A/KT@J#eFYd5BGZJKD#PH5;]Y1NAEd-TgaW?BfRU0ZIRK^@aJZ:PAMA33R8
// ZVQSZJD;(EEMY&8?PEI3#T\N2d#5_\F(TfD/CV<3AJJWZ]1#OP]Y9AD^_9?d7SfR
// Z[K4^.Kb[bD>[4Ne1A<J4QC5SW1Ke3&cH8;b#Ma=fDBAc00I9:OKP9TKd>2L8LR1
// BI#AL8XBYKBZNY<T=XY[)W].E(A7N_G>,\bW1AdJZa6IC9V;XN8&3N48LK;[=PIH
// _C]\b9AMaE3a+7H=3C.)Z;L+Z2[KSH3G9bR5DfM#8&c4Y.F3&OdK?c&70^\??@-F
// S<QOeE&YX0:\3(d;_><R5K-NF8>8I:bY7396]PRf6Qa9_NY^-(\Ed&(aEd@c]#Q#
// 1I34b(:9ZY/abC?^,C-KUWAY-a,WVY;S]\bO)(8H3d:1L#HJCKd+WV68I+-eGL5Z
// bHX.e2b4S4Hb8E]#Rc7(+IIQ1K15W+P8A]dV4--M>?&/<MDYdF,gUK53B\@C3D_E
// [CYbd.)f9PGTC9NM4UV12+Q,9?-05E04dba,K2>^e(/V/,?H77dU_baLNdTW4#.d
// f1d=aaS,@,SI1d8X;8Z#0A/)VWY(V=[b+CXI1UQL->ebCI0L/?0[c[_W<JOKaZO/
// (DLfe)3L23T@b@;VMg.TVB[A34_OO1[[C<^g++1>@N=@UZ(&VEbVV(DJ<4LA[T);
// H>cb@](#M?S47P),+]eZQLNC9J>)LZ09Z^._;<R,9/LRP,T(2MGTMK3J2TF+9B)b
// H04E<<3U8f9<:dcM?W_PF(dUAYQ[T5S:J<,<1M.?UPM/#JN>BL6:1aMS-)PR[E=T
// ccS6KeL35Xg5JH,E:S6O>3K#RN:3Hf;f+e/O:&H>TL70@I(/6G66F_8,@VPG:5SB
// e_Q\(6@2U:YZ<=N5OOYaY/A^g_;e9?B?/cJb)RQCJ[+_g_/56^gF;F,/aZaJH\6]
// 5&V)&JaBX4VJ?121/B5O(:;/#HaMa\S1b3/<P/YS;&FRQ8fDJJ_c^a2NfP7A27gS
// @f:S;)TKd[3G_&0RPNO<I0YbD^>cXWNK9abeZ76F]TcS/aHO4(B3b_]XQG,S^Rf<
// OQ8U8E9<_)<6@[6(:]D>Xd[939VaGc\YZ\M5Bf?A1^>]G2R9Y141egCA)BIOg;U_
// RGfS#@Vg?76_VB2W\&D)IB,3ZR\6:d0ZTT1U?U2^;P7g&S(.Za\d7+-GXE^FgPLW
// PfJPI--T(Y5b?V&J..^>#U,bI,Fb,,-BD/(+8]75Zc+cC.C5QT,g[3eD_3[VLF^Z
// O-Fc-50^Ca2=;bM^Td4_/L]M\>=Ma/,R\1Xe:T3H^f^Z#d]K,e#I@ZHe9+1b(CKD
// 7fNFc^MR@4M8,b]OP0+Vb90MY&E3@S5?TH\G74dX\HT9ZN0>?[BB6RcU@VHB;W:0
// cb#4>0b[eX<RN(H7=PY.fIDXNUW2d^cZIf>a;#bB5&/a6GTLL5CDRXHR/W[@c488
// 2U)+@ac=?4J-a<GBWF?Me^,E[C<?gGYQf<cCJ1b,2Q(?(D0I[L3I;=L74GCdM.&-
// PBK(.S<)#KP:L,^KV_;>4]dT69_8YB:@=YEc<@6[^AD/=0]C<EGP9^=9/8OP@Lb#
// )/J[4LS[Q2SD/5/7#&8P0JCOS#QP#XfbI]_?X?Bg\b_(A[f]A-90)4S@NQFaPR2K
// 8gC&I0:R72-Ua_0CP[_/\L:;cTadL34Ba@c871Zg(CHYAE\CV7X\X)gGFc.3S#.O
// <f5-ICEX=gS].e_&[WO#;-bA6W;86MDN@ZeA-85+HO(\QG06+&S=RA;+6cIKUJ^L
// JNBQN:fc#QHKK7:J4T)MXZ194AUPRb+fI]Nb#GVV-ZM.B&UK[Te\:\P8fbU\GMg+
// B8N]0[QYE:5f=,6)f--9OKT@X?V@5WA[#8F(QMTgD#W3_?,O<7^<:DCQ2:BUNG..
// ,AGH-QTOCX2bHgg0C<S6>1@^U:SIN+<8g7HN#;(HPEWU@2]CPLS^E;2L>ceE?7ag
// 0eB./T[^;a),7^SN(2PDT7@FcZ:KUGbLIWW_+(:N<EZ^dN+?IJga7C9D;7J)1G[Z
// :TD5BF\JU4,^W\FFg-QbMPc[QML_LE6Fg;6_+:XM^]G>?V2;5gERCgdYDcJ,:&f5
// ^cE@HMS9FEG9]dJ]&>]Y&e/HKS<C0=4I41DVAREGR(HGZa.A9D._D+5-LT31BKW7
// AN0;F^PE0g<A\J6;&/T^UMU5EYX7gfe8QESXS_:NC#e_R8BB1R13SfQ3gETSG@@+
// 3fHCZEO<)L+YDX_G>+)]9+f9/BObFd/O6g8ZR8BR8;M\\.f+226XbUHR403?=FC[
// W89Q6eUXZ2P#(ZFc+UQ5N\VM5VU+W.LV&WgQ,R-^3R0M4bgVBLCWGF(d3QbZ<+J^
// J[D0S>Y(K_87;g5-NP2&I#IJ#CAc?^BH02T(2<HNKTSSP;J4VJ-.d4H6RcbW(VDY
// 4PcYR?>V^0FR7_f3<WDO.>9#beWQ[NGZ.L(1e7#<2Z:Sd3@V>7.gdfEe9[N:&&JX
// +8K@Q<@+FA:V\:;=RW.=C(S;0aI&KdN7T?2(XX\dGO[T<@7a>,QZ+CY\?TGgFfEX
// LPHJdS)9@G/SF9F:ISB;3e,,O8RES1g4,Ib3eYATb0cN@EZ,cO63bZKbZ>=O+Ic0
// 9N2,;FUK9Ha6LE6#?0Cg&AMO5=/@f.>I,EFSI_c5_AU9+JQG)5(QdZ\P-YTE,C1E
// #TB+F\>LROeX8+4&2<EcE.&E6+R4&,_8,75<fed8^c#_MRRc_/7/K[\b,&ag[da9
// \)QNG+a\Q2AEb;G6ZL^8bL>9aP]O9>,14CZ]=fY<=U0<0.:S2B;BH=(+C4,(I-6B
// #8\CQ/H+:H=6]^YT,b1.HCZ>+@>B^.c1dBN.-&Pc6FA2L#RD_CP]E5AXCBQS.-1(
// H#^@_).2G]ffWb/J180O3?=cI?->MG,[AbNUbUf27d168YZDW_JeT/QO?MB^5<=]
// Z4&?R9R0-3H7S)#[499IO3A,_V0W<1NI)^AHP^dQ(gO]@L)6MB,f#^NG/adK797Q
// -W9F_AUd;Nb<11DSJ7N9/AGf3E1/0EJ,Q6))EL7]eA0@(f\L?WR,U_Pe/M#<5PR[
// >C@,)HS;7QMFW?cg^[gYIR8f.d9.J&d)D=&G4^2Z57:QQ4ae<QX1##ZT6NC_.;TP
// 425b@b?Hb@C=\YK_O/S&L5D7-0?:#G7<+M_a>WB^3NUcV,8[,Y6J4VG]fCQ)^fT+
// fIe,42Q<@9J@8C,U5TREQ4D\-Cecc\Q>4TdD5BKRF-:N#/-eFeML<8dP6L.O=QL=
// KLS,dK5RH;MXX6a9&[ZOe3?Ta8)H/PR;]=O1H0N23[JFePP7RgT@b_>&N@e[/Z@7
// b=c4@a[HQ0?<J;&2CbY=/6LeaD=3g)+TJK((W&D5[7T-AQT9<W.FSCT0EN@\>g1a
// <=2X6FD#(N/.JICNNY\XJ8<5^T5Y6Z=)3B\8LR0)>c8gO2,&(&PZ>/XHR,2/ARIM
// f.gP86D?N7O>Lb=E4d8W@?XMKY>6WDHb=Af2NcNW+g#(VaX;O?67#_YSTf-D&SVd
// (Z30J3T27V>&?U4WP2ag+=2=RWQXUQPKT3g_@&6gaHBHAF+F_cHFFDZ=8&5fd,6P
// 0bQL;:.#<>;4]O<;4bGc:eI6Bg2:SG1XS[I,dRSD_?a<GcK#48^:K=14QJ8OAcZM
// 03Of\T/Hg5Q#>)RT0,ACHR\2eKaA2YRbNL-=N^W8P?-EHKO;S+eN\a1-F:I;S;/W
// _Pg;AfWF,9#>;MJ)d8I^C<[N#W3e7).Q[+,fJ=bP.BegXd1A77egW]/@0Ce<g#N5
// 8Ge#0a6M3eFB<\[^[I]a:bWIFD7c?02Q[39/FL-..f<&;YSbU#bZ67-A=OMQH9B?
// @\5;I-2@)RB5MG=RG9e\KEWU.QG77.#b.9Sa>=ZKQ3Y4X>_dDFb.PXI^=>JI,ScY
// _=Z-M1+5O&K2DH];JOO05U6J/bZ[[A?FONYS&/.M8C0>8,W#-0bOA5YI_TRG<\]^
// )?E-=PAD:=<dJL7S&>IKH&-_DTPV.eGJ/@?/^4GbHU8]MS),->.@0d+B:aRff]25
// cYXcaGJXgUc[&8FdWdaCacX,G4Y+4=;<]1KIIBR-82F=,L_FcT08</O3e9R.2cT1
// -aL]S:OI?7_-^],&I8CEN[TEL+:6Q?JF+?5EK3(RF9;6[6a-MQJ+gO.BC0d5>[ca
// 9_X0?WO)G06LNbFbD@;^=RSCaDD&W3M@6Y-=?=6CG=DINZ=gY1/b941_-6[I6M-]
// Z;WJNTK6[&=g9=T_;,11.HfW0;-1O/:CYZRFAX-AJ8-MM8\f=..U^FW][D[ET-,K
// ]d;(:AH(c6Z-DFB^DVRd;;5(:DV]P1DZB+P1/EG:H+).1AB)PYMLV4:4cD9+:?-?
// -I-/F[>5PNc>9UT1Y.3d=U@ag3Lb\R?9MBggZeDX<9_DIFL>M=aL&,AWWd?a5K<D
// <>#4A>)UD/dV\EQG>GG>ITD4(HLBK17R,U4:.MXD#TYgaBYXO\2A7/ATXC^c4<ZG
// IM&KHT]^=1UH1::Z3Z92e=4Vcg=;^da/V#cGcW4BLQKHXaD-,=1fY9(FaL:B=NAD
// U-;YHXN,A8U&9W)F9ISa3X&_EB0f^D^e]/N4Fg\_3K:@..d_5d>Z0eDRbe]#V5AH
// 2I24X0QN<2PB=&ae#b0K@<K)>Q0N;Z#e:6[P^3^[dee;C]fM)5HZ.JQAYWA1<_UD
// >_@NYI?fE-@10LXDMG3,&2R5a0M/ECN5gca8.^RRLf#&#b\eL8[T=\++1VE=;??]
// dE/+84C)](1D,@LGC=2<7CJ@&^EJ=dHG)W_^;aQ9e?e)3B+G)C[&/Pe4aS+gf8b7
// (&]TD:=Pf\E@E#[Q?8<PHHARC^[N-#[NVXXP9gRC]^6eG4,YJ,1JU10NE,@eQ-RE
// I1<5R/][?HO;]@S<.56:&V>0Sg#5B,8)\K1[K]Y1Z10MXY9cTfX#aQE3YFQ?gB,W
// N4QfZ]C__<./1<0IKNI),RS4N]L_gP=ObTM2\LZcXKE;YTA8e:I?,<_OK:8#dDA\
// =dROLW,gVd3/0I3XJ2XP:B(1VI?V)D+X/IY15MNUR(Qfb7=ARQ?YML^SS.:_Mf\8
// MMYaE=Hc(K_3[/4+?cI2Ke^=+\I+Z\:5BGDW;2LS7[,Yb44BN:,-MN1R[1,9,,Y9
// OFKL^6<c]#F8,Y344Ufa\AaA46e#4UJ0aSBf5b51Q&g84W_&M1f8M\De=#/0CC=)
// .-V3,=F8SNb\0BbTa@f\>;:9c9D0>af?b:VVO^e<QY?2P1RLB::G;]a<b2:+L<P2
// IA@Rg>=[OD5A(/)5@NM<KU<ZA@UIf[VHKB,W5->If>>9KGL?;]CFN>)F>L#?g>:,
// AM&8?UR\B7a=a]C][_J>3d&3L5bfP-LZ.&AO/Q8=B.5DI6<GCG0WL\,bCMfV3UDZ
// 5EH:fBU1:_LO2;b_+7/\9)KSVfe>6M+^@\NS(2+Ta/bRU.TFH-M@Y#1+>9_X5IbR
// =S]IK0,Sf/CJ]?gB7dCd/\c<^-:@>URNN\N[/,;-N5f4MAE)YAb,79Bb(#?[JLR=
// +K8W05#)][H7ZVXH)PJ?>F+b6/eVHe][[Y#]fU61@XeB)=S=ID;Y-gBAN(KbVZ(;
// [SV9,fc/?R09UXPH#K7CK6=0GF2C)Re^fc/72,dTMZ+OgZ\fXKK/.dEGD.d[:U01
// \+4BH+-.\<:+M&PHJAZdEK][Oe0c8RQX:&05OF6]bPI3NfK/@bF#4J\MEZM_C]\N
// ,1KJ:1#SE0,d09:\)]).6QX)MB)#X1YY3FgNKNRFY5JaI+?])fJ3\,D_MI<^g2\L
// 8B>E>4Zb_NELUXf3SKbMIQ+W6RaI&fNNc=IGD-\^XW#R\eU5dLb24#76Q\OB/dM+
// &J?b4NdZX)NWDA^fS#E7f@KHVM+-fK[[=Y2JU>aEK[5+5g=KY.;=BH4)8Zd;fG.:
// ?;LXU7>/G\[\J57F/75X8R@,(KT6]a2>&5TEbbXNWY[eF[d9OR-=<+U4:S+d2#7c
// L4R&>8[UfE7-HG5X^PV-;1M5J32;GWd5QCUU-3&-UOPB7eMGSc23.Y3Q:c?)K&.M
// /T(O[GO.42OIXb.gR)YT-E8&N)Z^Y1+>NL#AXGSd#MZBBeVQ+,-&^,XIIFP#HXfQ
// /1G=_]cFN4b8.;9EDL]cH8Xf6YOO_#D/-_ID(K-(4IUKf7IKJ4K/e>T2:dC#M2J?
// f_3&C6WO\Z/SV,IN2D&If0^1C]d)J?-@2B9V0ZLc.S[JcVg6cUU+<&U&^T(C/)]D
// D30]?D&d7D:[)e98eg@RIeSV_M<WNQJ@J-a3=8F>M/^55=bKL[8097=U#KD<)Ra1
// AIb:T[1;H+XUf4;F2M.FMI)[f>0_)TBT+8>ZRQ3Tec;6;3-.:DM:[PSG4e>ZgZT5
// aU3YK)>U/H/I(VLF:IbCUMIYC84J?K^/gWC7=PAAa<W54>51WMSMWMX?Y)<G</d6
// XY/B=C:I;Yaf#=;R386H<ABOAJ-Ea5Wd0NOTC4HDf4QaUFTT@HLM<YHg0TY[ZD-2
// \3/9M+OgJDeMF_\D3<f3JcW1_Z,ZCg\VG<(8g_NLX&W5E/O(CRD\;7RT97g5.LOM
// (L(M[8M,+0V4+?98FOA=<QB@4&5?9_+S=FIHT72XM4V<_KFQ-W,AC96RFU(1d:^6
// 9TRd[6d)#:dVV_:>QLgF(CE(Kfc?V.e@I6NLB/[7+R/&FW6P/a8eLTKE9.,,a[JT
// S]R#HQF\RbNRM<RIa)9Vd-+G9Y#LJ&Ng3I+AA)2_#A,;/,8(&_?TTfAGR+2@I[F@
// >J?T+C/ac/=.D1P4._F99^B.K@XgR-]e]\;U3F8[:?XH@>2KJFgULbB/g;?&7>C5
// c43a2166),GQ:P1AR8/aBN#>.TV=OMGH[NY9_J;:F0cPf+S0)GX5@92S?SZ@::03
// <J/<\N\()8&XQ-;QWZ/P\5#G6[.S2&?5=>.da=T>Y=I^ZJXB8VQ,&LbHGY^6_db+
// 2c4R0fFGM0_Ue;\=0+0[3_eF[BdE-5W9?cdQ^9aaa_CZIVSJYIJOOS6.3T(-NG,S
// ;-12)T7fBNBC;>TU@W=F]_9=&K.C.]OfC>9XG2?D3P,SGfMR+CQ)#LR>)W+XW:W#
// I7L861M^##_&A@JN;T&./J6I9@I+BfF.PXT&MbH:93fdT+&aTJB7G-:K8,J,^U>^
// (QfdQT]4&dUL.Q4)FBD?2=.9SCE<G=9LHSP]ZCQ/)#MIU?\:#IV_UOFXUR>c7@<C
// TE[:AZ^N,ZC/3bG&);EY@^bGMIV6F(^=)7C67Eb<@5+/^Y7?OK34Q,W,@FEX)MJ=
// H2NZ=aaXM]6:>dEE&cM^VXR/20(7(27:]]gEff/_HOOe,;?NgO3K##74S+.94GZ]
// _,,AD8+OafSM?T428c[,#0.4>5:fVg>1W[G,V3UFg-VIKfPM8]P0O^6E@E@,8^))
// ,V/C9V;SEUAdQ[d_F,.&4GU5aWf\a<./,=Le+Kf_/K:Ac?(_fNV(R<-_dT[Ha#<G
// 0dJR[^R8N;&)aM&[<5_Jg?IFM#L]MBYT^fD<_?^Mf>@,d9Y#c;S2[6ATbY7D&3_>
// UeRaMc-J>8BE=O=[a@@1?Jg=bC8XUPA_M#5PcQ.J[(gP9dK]Z>G7S5Hg_.C0<ce1
// MZ-W@^P(1;f&Y0@TKG<=CFB.>4aFegHD;4O6__D=+X5+bYD>()VAg#0a6FY1Q>5-
// \c4SV=KUMEM9eL>Z)cBF4C]AW=B<P>+f75NI53M)H^@MJ?:J1WYJYTb2b5/#C4X>
// ;I9LQC?(9=29Y2d[@UH90Z\3]1GG/JW+:;WI9)OHM[;J)>6H.],9>EOM89fdIKc8
// =I[G<8UDS1L)>aVGK]?#fd,<aHHDV9.UA@gG5_K9U7f\PKXc?b?9BF>d]78Y)X9]
// G/4f48^Xg<<cMVgD_f0]E)AU?=W=5@g43?Z?VD;S\??FE)8I.((c>OPg<B@LaQ3X
// W_KdM/ee:-M)AM&_FFP2[5J8H(b686/X>7P;eg[4M?#:&.6?_5W_ePU.E8().Cc<
// P,=bS9)Ce\AgI02e[LVc3NNb:g5eD&?_9G=KL:>V+0#,6?MfBf(b0a/-+d7UWRTC
// g8U4F+Md,T1X->UXM8.#-3eE+S4a#cI)3ICMF=Y9E1:^B[U/<JWcFba5N,?UMC;e
// TGPGgD_Q)7G72WF-:0-7Bd]5&CN]G/E[<3_AYe)+\G0[OfM(&\AMY6SO5Z:18b02
// ;b-]Ecd?-5#<S#7(UZ1I(-FPM=g)EG?-&f2ZNg3^Ud.3.a]:LcV;AcS/dc3A:Z=W
// RYUW73f[W@8cM4DY2?8a9^]<M=DPWJ_[]Q,L(^24NH;GQOMR<DF7##+6;M^b,1<0
// D,ZCF\.#fVWb8OP74a0(5/7\VA)THQ<INR#LI\KBQWH6VO.BgK8NW<L\3KF-EW/7
// EX[=S93P7e7TDJ9NYa+;>]9(FS=45HO_CDNQL_BMc;QMV\\-fW[-M=ea<Of=W^V5
// FEJ5UAVHK]9d?037dLH+M-AI4K0QF<fD>55G//fb\?<5&2a_NJ2;IK#-CBW/9T4J
// U.B<(Gb[@O4c(M2,EY:\0(74X<#69cCNJQJ^a].:JLZa)bS]249OFe=3QD>]SUVL
// UQTZ;6D5dNHH22+@g\<5JDY31Da=W9F4SUTS>C;\UR+VRXd5.7<(;)3IHU5D:bg/
// :&aS?d20@LV[X@LYE3((@7;F&F6VQ:;D9Y)[efD2P>dAUGg&ET,7)Bd#\4WJ+Q3Z
// 309A@c9@,T(L(:C0;8=EH&<)+a/\89BNZ(&_IX-7^KJ7HIG8P;-==;e29<)d1cAT
// PTd@:)B3J;S&b)W#fg49Ma\,1,>PANV#gTf4I:=0&C[>HRU41d_>:0HDO;S1A_,D
// ?IYQ;fbV3\F>68ENJ30G#5eQQE[I,7D\0^<VRSW40aDe7X]-^#ELDJ)[E0J)a(?X
// UA#M2/fJHH#ODT9Ra^6&c4a9-4W]];&c&]2NF9>QUTGTBBe?H=&d_fD@2?_XL.(^
// dbg9X\RAe+b;5N_cBYaA^RLB]3P//f9U-;&]0bb0]7bc)<+&[cY2^/AdgbWMVIV)
// H])ff-)NI2GQIMGP&eH5Cf5DLW?S5T\@-.:9A/c^9>2FC__C=cTOH7/FX398N1XG
// ^IL4?KCS938U#[8,?fTGN9Q2&ec:NG&ZV4/f(A06cSg+F5S;^eg\PORB4<c/Wg#)
// 5BWZa?X:./F-[5aTK9+)EY-cHBQ7<,1(0U9E_JKOBIe<;+d;@R#gND+3C2U:7RWM
// B0@5#X@ODG5SJ0757ZZRTP?RECTUVg3Q#SBBT=&+VU<dW9\[_HHc32Q7RQd>7TN_
// NF)4&/]e_SKbZSgTBQ;,C<a2-AO8AN2Ud?(GE5K\W8]bV:aIF&b=VX5=Oa6KJ7^M
// U.J;@).P)?SfdKAI+/-@4X##;O+@V=Vb-^L+;Y9R3UQHM.)?M2P3_1bUX#gSe2Mb
// E4B7N-YfZ7FgMI#6M+aeQ3UUHI+8YcBf0A+<R8CfAL:R?D#KL=JJ=49G>&W/U;NG
// C3abUT9L;PY/&<IMc@f_e==CYO6BfDI^#Z::CU08_7Y;#@FO8E\bUd/0FO=Z>([.
// -<4_(_-Xd3(:BB(WZ]V)gY=NEH,O_FXY?.IV^Z8Y+c/gJ\W@<B4ZfM=<QJV2Q[L?
// YWFV.d\,97(\,]QHFM.[</bag2/@1O5TR8\6P:G84eaDFTf\[?48eYa[e[HIABG,
// @@Q-FZV2LKOK21HWRaZdDT[\7?Y(dJS&_QY:9--;,BWB^-PW/PU5eO/J=@R>Y?)A
// D,+B5O+F_/+)_8dIMJ[HA&c7LR1>FYVZI(eEQ.\1GE;JP>GRg[ZL5eLKR5F>,7Q/
// /&FaKg<7;9cbYZ&>S_S8#QU8YRV4U/Z,H#&]9+()H>1SSZg@;[9e6<5BF6[;24=Y
// cb^@Z?.3TYN:,^AdGd9X1IG[5e=8(4KBX>Wd7e_)6GA&Rb09S_Q<3d,cbb6OH8>K
// /R2>S[e<G83&(>ZR7=?BF1bUQ4@2E4)Q:2GcQMMKZMaYdT/e8a#.1U<Rb91J-ZBb
// ,XCL;C81[CFPIV5c7B&afL6K4I0f&JR-8I35Y.b8G8?c-[5JdfWCL6Vg??@\X)[H
// 6T<XIF1.J:&8fQEY.b@8<#:.?(Q_U6g)EW]3e/ETF_Ab[.6CBTE9M75UF2eB1NbW
// PJXC\8NgTI5/ccfO_^N.T,f]6:Wg=f\8..aI0H/=(W2M.3OE#US\[CB_X2P95M^a
// H(;DD6/;[9YE/.Og6>+7K(L>V?(,-FY_B#+766#@(1&(4_YY4+?]KQXP3Y:CHc7>
// )+^K5V(>B-QDUfW[5a:7B^03FOV@X+;XB/=eO8PF^;X<>)-CW^C^)bc(RYec-G<N
// 9-@_fbG0RDFG<Z;SfUGb&NZ3AZT)a<5HT3RVI=+I@<+)7ABJWafU+gG&Zf\/d#\P
// WXIQO1HV?Q8[FVACJW6efM6d.1b1XJV6^>0,8E>#(=#)D$
// `endprotected
// endmodule

