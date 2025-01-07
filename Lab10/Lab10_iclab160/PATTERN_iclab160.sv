
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE=1000;
parameter SEED = 7777;
parameter PAT_NUM = 5400;
integer pat = 0;
integer index_check_num = 0;
integer update_num = 0;
integer check_valid_date_num = 0;
integer latency = 0;
integer total_latency = 0;
reg[10*8:1] txt_green_prefix  = "\033[1;32m";
reg[9*8:1]  reset_color       = "\033[1;0m";
reg[10*8:1] txt_blue_prefix   = "\033[1;34m";
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box
Action act;
Formula_Type formula;
Mode mode;
Month month;
Day day;
Data_No data_no;
Warn_Msg warn_msg;

Month dram_month;
Day dram_day;


logic [11:0] variations [0:3];
logic [11:0] pattern_index [0:3];
logic [11:0] dram_index [0:3];
logic risk_warning_flag;
logic date_warning_flag;
logic data_warning_flag;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Index_Check, Update, Check_Valid_Date};
    }
endclass



class delay_random;
    rand int delay;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        delay inside{[0 : 3]};
    }
endclass

delay_random delay_r = new(SEED);

class random_date;
    rand Month month;
    rand Day day;
    function new (seed);
        this.srandom(seed);
    endfunction

    constraint limit{
        month inside{[1 :12]};
        if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
            day inside{[1 : 31]};
        else if(month == 4 || month == 6 || month == 9 || month == 11)
            day inside{[1 : 30]};
        else
            day inside{[1 : 28]};
    }
endclass

random_date date_r = new(SEED);

class random_data_no;
    rand Data_No data_no;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        data_no inside{[0 : 255]};
    }
endclass

random_data_no data_no_r = new(SEED);

class random_variations;
    rand int variations;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        variations inside{[0 : 4095]};
    }
endclass

random_variations variations_r = new(SEED);






initial begin
    $readmemh(DRAM_p_r, golden_DRAM);
    rst_task;
    for(pat = 0; pat < PAT_NUM; pat++) begin
        data_warning_flag = 0;
        date_warning_flag = 0;
        risk_warning_flag = 0;
        Determine_Action;
        case(act)
            Index_Check:begin
                Input_Index_Check_task;
            end
            Update:begin
                Input_Update_task;
            end
            Check_Valid_Date:begin
                Input_Check_Valid_Date_task;
            end
        endcase
        
        case(act)
            Index_Check:begin
                Cal_Index_Check;
            end
            Update:begin
                Cal_Update_task;
            end
            Check_Valid_Date:begin
                Cal_Check_Valid_Date_task;
            end
        endcase
        Wait_Output_Valid_task;
        Check_Ans_task;
        $display("%0sPASS PATTERN NO.%4d %0sCycles: %3d%0s",txt_blue_prefix, pat, txt_green_prefix, latency, reset_color);
        @(negedge clk);
    end
    $display("============================================");
    $display("              Congratulations               ");
    $display("        You pass all the test cases!        ");
    $display("        Total Latency: %d              ", total_latency);
    $display("============================================");
    // @(negedge clk);
    $finish;
end


task Determine_Action;
    if(pat >= 2700) begin
        case(pat % 9)
            // 0:act = Index_Check;
            // 1:act = Index_Check;
            // 2:act = Update;
            // 3:act = Update;
            // 4:act = Check_Valid_Date;
            // 5:act = Check_Valid_Date;
            // 6:act = Index_Check;
            // 7:act = Check_Valid_Date;
            // 8:act = Update;
            8:act = Index_Check;
            0:act = Index_Check;
            1:act = Update;
            2:act = Update;
            3:act = Check_Valid_Date;
            4:act = Check_Valid_Date;
            5:act = Index_Check;
            6:act = Check_Valid_Date;
            7:act = Update;
        endcase
    end
    else begin
        act = Index_Check;
    end
endtask

task Determine_Formula;
    if(act == Index_Check) begin
        case((index_check_num%24) / 3)
            0:formula = Formula_A;
            1:formula = Formula_B;
            2:formula = Formula_C;
            3:formula = Formula_D;
            4:formula = Formula_E;
            5:formula = Formula_F;
            6:formula = Formula_G;
            7:formula = Formula_H;
        endcase
    end
endtask

task Determine_Mode;
    if(act == Index_Check) begin
        case(index_check_num % 3)
            0:mode = Insensitive;
            1:mode = Normal;
            2:mode = Sensitive;
        endcase
    end
endtask

task Wait_Output_Valid_task;
    latency = 0;
    while(inf.out_valid !== 1) begin
        latency++;    
        if(latency === MAX_CYCLE) begin
            // $display("Wrong Answer");
            $display("Latency >= 1000!!!!!!!!!!!");
            // $finish;
        end
        @(negedge clk);
    end
    total_latency += latency;
endtask

task InValid_Delay;
    delay_r.randomize();
    repeat(0)@(negedge clk);
endtask



task Input_Index_Check_task;
    Determine_Formula;
    Determine_Mode;
    inf.sel_action_valid = 1'b1;
    inf.D.d_act[0] = act;
    @(negedge clk);

    inf.sel_action_valid = 1'b0;
    inf.D.d_act[0] = 'dx;
    InValid_Delay;
    inf.formula_valid = 1'b1;
    inf.D.d_formula[0] = formula;
    @(negedge clk);

    inf.formula_valid = 1'b0;
    inf.D.d_formula[0] = 'dx;
    InValid_Delay;
    inf.mode_valid = 1'b1;
    inf.D.d_mode[0] = mode;
    @(negedge clk);

    inf.mode_valid = 1'b0;
    inf.D.d_mode[0] = 'dx;
    InValid_Delay;
    inf.date_valid = 1'b1;
    date_r.randomize();
    // if(pat<410) begin
        inf.D.d_date[0] = {date_r.month, date_r.day};
        {month, day} = {date_r.month, date_r.day};
    // end
    // else begin
    //     inf.D.d_date[0] = {4'b0001, 5'b00001};
    //     {month, day} = {4'b0001, 5'b00001};
    // end
    
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D.d_date[0] = 'dx;
    InValid_Delay;
    inf.data_no_valid = 1'b1;
    data_no_r.randomize();
    inf.D.d_data_no[0] = data_no_r.data_no;
    data_no = data_no_r.data_no;
    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D.d_data_no[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    pattern_index[0] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_data_no[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    pattern_index[1] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_data_no[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    pattern_index[2] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_data_no[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    pattern_index[3] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    index_check_num++;
endtask

task Input_Update_task;
    inf.sel_action_valid = 1'b1;
    inf.D.d_act[0] = act;
    @(negedge clk);

    inf.sel_action_valid = 1'b0;
    inf.D.d_act[0] = 'dx;
    InValid_Delay;
    inf.date_valid = 1'b1;
    date_r.randomize();
    inf.D.d_date[0] = {date_r.month, date_r.day};
    {month, day} = {date_r.month, date_r.day};
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D.d_date[0] = 'dx;
    InValid_Delay;
    inf.data_no_valid = 1'b1;
    data_no_r.randomize();
    inf.D.d_data_no[0] = data_no_r.data_no;
    data_no = data_no_r.data_no;
    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D.d_data_no[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    variations[0] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    InValid_Delay;
    inf.D.d_index[0] = 'dx;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    variations[1] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_index[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    variations[2] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_index[0] = 'dx;
    InValid_Delay;
    inf.index_valid = 1'b1;
    variations_r.randomize();
    inf.D.d_index[0] = variations_r.variations;
    variations[3] = variations_r.variations;
    @(negedge clk);

    inf.index_valid = 1'b0;
    inf.D.d_index[0] = 'dx;
    update_num++;
endtask

task Input_Check_Valid_Date_task;
    inf.sel_action_valid = 1'b1;
    inf.D.d_act[0] = act;
    @(negedge clk);

    inf.sel_action_valid = 1'b0;
    inf.D.d_act[0] = 'dx;
    InValid_Delay;
    inf.date_valid = 1'b1;
    date_r.randomize();
    inf.D.d_date[0] = {date_r.month, date_r.day};
    {month, day} = {date_r.month, date_r.day};
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D.d_date[0] = 'dx;
    InValid_Delay;
    inf.data_no_valid = 1'b1;
    data_no_r.randomize();
    inf.D.d_data_no[0] = data_no_r.data_no;
    data_no = data_no_r.data_no;
    @(negedge clk);

    inf.data_no_valid = 1'b0;
    check_valid_date_num++;
endtask

// task Get_dram_data;
assign dram_day = golden_DRAM[17'h10000 + (8*data_no)];
assign dram_index[3] = {golden_DRAM[17'h10000 + (8*data_no) + 2][3:0], golden_DRAM[17'h10000 + (8*data_no) + 1]};
assign dram_index[2] = {golden_DRAM[17'h10000 + (8*data_no) + 3], golden_DRAM[17'h10000 + (8*data_no) + 2][7:4]};
assign dram_month    = golden_DRAM[17'h10000 + (8*data_no) + 4];
assign dram_index[1] = {golden_DRAM[17'h10000 + (8*data_no) + 6][3:0], golden_DRAM[17'h10000 + (8*data_no) + 5]};
assign dram_index[0] = {golden_DRAM[17'h10000 + (8*data_no) + 7], golden_DRAM[17'h10000 + (8*data_no) + 6][7:4]};
// endtask

logic [13:0] R;
logic [11:0] dram_sort_result [0:3];
logic [11:0] G [0:3];
logic [11:0] G_sort_result [0:3];

assign G[0] = (dram_index[0] >= pattern_index[0]) ? (dram_index[0] - pattern_index[0]) : (pattern_index[0] - dram_index[0]);
assign G[1] = (dram_index[1] >= pattern_index[1]) ? (dram_index[1] - pattern_index[1]) : (pattern_index[1] - dram_index[1]);
assign G[2] = (dram_index[2] >= pattern_index[2]) ? (dram_index[2] - pattern_index[2]) : (pattern_index[2] - dram_index[2]);
assign G[3] = (dram_index[3] >= pattern_index[3]) ? (dram_index[3] - pattern_index[3]) : (pattern_index[3] - dram_index[3]);


// SORT4_MAX_and_MIN I(.in0(dram_index[0]), .in1(dram_index[1]), .in2(dram_index[2]), .in3(dram_index[3]), .out0(dram_sort_result[0]), .out1(dram_sort_result[1]), .out2(dram_sort_result[2]), .out3(dram_sort_result[3]));
// SORT4_MAX_and_MIN G(.in0(G[0]), .in1(G[1]), .in2(G[2]), .in3(G[3]), .out0(G_sort_result[0]), .out1(G_sort_result[1]), .out2(G_sort_result[2]), .out3(G_sort_result[3]));

assign {dram_sort_result[0], dram_sort_result[1], dram_sort_result[2], dram_sort_result[3]} = sort_max_min(dram_index[0], dram_index[1], dram_index[2], dram_index[3]);
assign {G_sort_result[0], G_sort_result[1], G_sort_result[2], G_sort_result[3]} = sort_max_min(G[0], G[1], G[2], G[3]);


logic [11:0] threadhold;




task Determine_Threadhold;
    threadhold = 0;
    case(formula)
        Formula_A, Formula_C: begin
            case(mode)
                Insensitive: threadhold = 2047;
                Normal: threadhold = 1023;
                Sensitive: threadhold = 511;
            endcase
        end
        Formula_B: begin
            case(mode)
                Insensitive: threadhold = 800;
                Normal: threadhold = 400;
                Sensitive: threadhold = 200;
            endcase
        end
        Formula_D, Formula_E: begin
            case(mode)
                Insensitive: threadhold = 3;
                Normal: threadhold = 2;
                Sensitive: threadhold = 1;
            endcase
        end
        Formula_F, Formula_G, Formula_H: begin
            case(mode)
                Insensitive: threadhold = 800;
                Normal: threadhold = 400;
                Sensitive: threadhold = 200;
            endcase
        end
    endcase
endtask

task Cal_Index_Check;
    
    case(formula)
        Formula_A:begin
            R = (dram_index[0] + dram_index[1] + dram_index[2] + dram_index[3]) / 4;
        end
        Formula_B:begin
           R = dram_sort_result[0] - dram_sort_result[3];
        end 
        Formula_D:begin
            R = (dram_index[0] >= 2047) + (dram_index[1] >= 2047) + (dram_index[2] >= 2047) + (dram_index[3] >= 2047);
        end
        Formula_C:begin
            R = dram_sort_result[3];
        end
        Formula_E:begin
            R = (dram_index[0] >= pattern_index[0]) + (dram_index[1] >= pattern_index[1]) + (dram_index[2] >= pattern_index[2]) + (dram_index[3] >= pattern_index[3]);
        end
        Formula_F:begin
            R = (G_sort_result[1] + G_sort_result[2] + G_sort_result[3]) / 3;
        end
        Formula_G:begin
            R = (G_sort_result[3] / 2) + (G_sort_result[2] / 4) + (G_sort_result[1] / 4);
        end
        Formula_H:begin
            R = (G[0] + G[1] + G[2] + G[3]) / 4;
        end
    endcase

    Determine_Threadhold;           

    if(R >= threadhold) begin
        risk_warning_flag = 1;
    end
    else begin
        risk_warning_flag = 0;
    end

    if(month < dram_month || (month == dram_month && day < dram_day)) begin
        date_warning_flag = 1;
    end
    else begin
        date_warning_flag = 0;
    end
endtask

task Cal_Check_Valid_Date_task;
    if(month < dram_month || (month == dram_month && day < dram_day)) begin
        date_warning_flag = 1;
    end
    else begin
        date_warning_flag = 0;
    end
endtask

logic [12:0] update_result [0:3];
logic [11:0] write_back_index [0:3];
task Cal_Update_task;


    update_result[0] = {1'b0, dram_index[0]} + {variations[0][11], variations[0]};
    update_result[1] = {1'b0, dram_index[1]} + {variations[1][11], variations[1]};
    update_result[2] = {1'b0, dram_index[2]} + {variations[2][11], variations[2]};
    update_result[3] = {1'b0, dram_index[3]} + {variations[3][11], variations[3]};

    write_back_index[0] = (update_result[0][12]) ? (variations[0][11] ? 0 : 4095) : update_result[0][11:0];
    write_back_index[1] = (update_result[1][12]) ? (variations[1][11] ? 0 : 4095) : update_result[1][11:0];
    write_back_index[2] = (update_result[2][12]) ? (variations[2][11] ? 0 : 4095) : update_result[2][11:0];
    write_back_index[3] = (update_result[3][12]) ? (variations[3][11] ? 0 : 4095) : update_result[3][11:0];

    data_warning_flag = (update_result[0][12] | update_result[1][12] | update_result[2][12] | update_result[3][12]) ? 1 : 0;

    //write back to dram
    golden_DRAM[17'h10000 + (8*data_no)] = day;
    {golden_DRAM[17'h10000 + (8*data_no) + 2][3:0], golden_DRAM[17'h10000 + (8*data_no) + 1]} = write_back_index[3];
    {golden_DRAM[17'h10000 + (8*data_no) + 3], golden_DRAM[17'h10000 + (8*data_no) + 2][7:4]} = write_back_index[2];
    golden_DRAM[17'h10000 + (8*data_no) + 4] = month;
    {golden_DRAM[17'h10000 + (8*data_no) + 6][3:0], golden_DRAM[17'h10000 + (8*data_no) + 5]} = write_back_index[1];
    {golden_DRAM[17'h10000 + (8*data_no) + 7], golden_DRAM[17'h10000 + (8*data_no) + 6][7:4]} = write_back_index[0];


endtask







task Check_Ans_task;
    case(act)
        Index_Check:begin
            if(date_warning_flag === 1 && (inf.warn_msg !==Date_Warn || inf.complete !== 0)) begin
                $display("Wrong Answer");
                $display("Date_Warn_Index_Check");
                $finish;
            end
            else if((risk_warning_flag === 1 && date_warning_flag !== 1) && (inf.warn_msg !==Risk_Warn || inf.complete !== 0)) begin
                $display("Wrong Answer");
                $display("Risk_Warn_Index_Check");
                $finish;
            end
            else if((risk_warning_flag === 0 && date_warning_flag === 0) && (inf.warn_msg !== No_Warn || inf.complete !== 1)) begin
                $display("Wrong Answer");
                $display("No_Warn_Index_Check");
                $display("formula: %d", formula);
                $display("mode: %d", mode);
                $finish;
            end
        end
        Update:begin
            if((data_warning_flag === 1) && (inf.warn_msg !== Data_Warn || inf.complete !== 0)) begin
                $display("Wrong Answer");
                $display("Update_Data_Warn");
                $finish;
            end
            else if((data_warning_flag === 0 )&&(inf.warn_msg !== No_Warn || inf.complete !== 1)) begin
                $display("Wrong Answer");
                $display("Update_No_Warn");
                $finish;
            end
        end
        Check_Valid_Date:begin
            if(date_warning_flag === 1 && (inf.warn_msg !== Date_Warn || inf.complete !== 0)) begin
                $display("Wrong Answer");
                $display("Date_Warn_Check_Valid_Date");
                $finish;
            end
            else if((date_warning_flag === 0) &&(inf.warn_msg !== No_Warn || inf.complete !== 1)) begin
                $display("Wrong Answer");
                $display("No_Warn_Check_Valid_Date");
                $finish;
            end
        end
    endcase


endtask











task rst_task;
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.formula_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.data_no_valid = 1'b0;
    inf.index_valid = 1'b0;
    inf.D = 'bx;
    
    #1;
    inf.rst_n = 1'b0;
    #(15);
    inf.rst_n = 1'b1;
    #1;
    if(inf.out_valid !== 0 || inf.warn_msg !== 0 || inf.complete !== 0) begin
        $display("Wrong Answer");
        $display("RST");
        $finish;
    end
    repeat(1)@(negedge clk);
endtask





function [47:0] sort_max_min;
    input [11:0] in0, in1, in2, in3;

    logic [11:0] max,max00, max01,max02, max03, mid0,mid1, min, min00, min01, min02, min03;
    begin
        max00 = in0 >= in1 ? in0 : in1;
        min00 = in0 >= in1 ? in1 : in0;
        max01 = in2 >= in3 ? in2 : in3;
        min01 = in2 >= in3 ? in3 : in2;

        max = max00 >= max01 ? max00 : max01;
        mid0 = max00 >= max01 ? max01 : max00;
        min = min00 >= min01 ? min01 : min00;
        mid1 = min00 >= min01 ? min00 : min01;

        sort_max_min = {max, mid0, mid1, min};
    end
    
endfunction













endprogram


// module SORT4_MAX_and_MIN(in0, in1, in2, in3, out0, out1, out2, out3);//0-3//max->min
// input [11:0] in0, in1, in2, in3;
// output [11:0] out0, out1, out2, out3;

// logic [11:0] max00, max01, min00, min01;
// logic [11:0] max10, min10;

// CMP cmp0(.in0(in0), .in1(in1), .out0(max00), .out1(min00));
// CMP cmp1(.in0(in2), .in1(in3), .out0(max01), .out1(min01));
// CMP cmp2(.in0(max00), .in1(max01), .out0(out0), .out1(out1));
// CMP cmp3(.in0(min00), .in1(min01), .out0(out2), .out1(out3));
// // CMP cmp4(.in0(min10), .in1(max10), .out0(out1), .out1(out2));

// endmodule


// module CMP (
// 	input [11:0] in0,
// 	input [11:0] in1,
// 	output [11:0] out0,
// 	output [11:0] out1
// );
//     assign out0 = in0 < in1 ? in1 : in0;
//     assign out1 = in0 < in1 ? in0 : in1;
// endmodule