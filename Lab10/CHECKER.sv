/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Formula_and_mode;
    Formula_Type f_type;
    Mode f_mode;
endclass

Formula_and_mode fm_info = new();

always_ff @(posedge clk) begin
    if(inf.formula_valid) begin
        fm_info.f_type = inf.D.d_formula;
    end
end

always_ff @(posedge clk) begin
    if(inf.mode_valid) begin
        fm_info.f_mode = inf.D.d_mode;
    end
end

Action act;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        act <= 0;
    end
    else begin
        if(inf.sel_action_valid) begin
            act <= inf.D.d_act[0];
        end
    end 
end

Month month;
Day day;
always_ff @(posedge clk) begin
    if(inf.date_valid) begin
        month = inf.D.d_date[0].M;
        day = inf.D.d_date[0].D;
    end
end


logic [1:0] index_cnt;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        index_cnt <= 0;
    end
    else begin
        if(inf.index_valid) begin
            index_cnt <= index_cnt + 1;
        end
    end
end


covergroup Spec1 @(posedge clk iff(inf.formula_valid));
    option.per_instance = 1;
    option.at_least = 150;

    bin_formula: coverpoint fm_info.f_type {
        bins f1 [] = {[Formula_A:Formula_H]};
    }
endgroup: Spec1

covergroup Spec2 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;

    bin_mode: coverpoint fm_info.f_mode {
        bins m1 [] = {[Insensitive:Sensitive]};
    }
endgroup: Spec2

covergroup Spec3 @(posedge clk iff(inf.date_valid && act == Index_Check));
    option.per_instance = 1;
    option.at_least = 150;

    cross fm_info.f_type, fm_info.f_mode;
endgroup: Spec3

covergroup Spec4 @(posedge clk iff(inf.out_valid));
    option.per_instance = 1;
    option.at_least = 50;

    bin_out_msg: coverpoint inf.warn_msg {
        bins w1 [] = {[No_Warn:Data_Warn]};
    }
endgroup: Spec4

covergroup Spec5 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 300;

    bin_act: coverpoint inf.D.d_act[0] {
        bins a1 [] = ([Index_Check : Check_Valid_Date] => [Index_Check : Check_Valid_Date]);
    }
endgroup: Spec5

covergroup Spec6 @(posedge clk iff(inf.index_valid));
    option.per_instance = 1;
    option.auto_bin_max = 32;
    bin_index: coverpoint inf.D.d_index[0] {
        option.at_least = 1;
    }
endgroup: Spec6

Spec1 s1 = new();
Spec2 s2 = new();
Spec3 s3 = new();
Spec4 s4 = new();
Spec5 s5 = new();
Spec6 s6 = new();


///Asertion1
always @(negedge inf.rst_n) begin
    // @(posedge clk);
    #2;
    Assertion1: assert (inf.out_valid === 0 && inf.warn_msg === 0 && inf.complete === 0 && inf.AR_VALID === 0 && inf.AR_ADDR === 0 && inf.R_READY === 0 && inf.AW_VALID === 0 && inf.AW_ADDR === 0 && inf.W_VALID === 0 && inf.W_DATA === 0 && inf.B_READY === 0)
        else begin
            // $error("Assertion 1 is violated");
            $fatal(0, "Assertion 1 is violated");
        end 
        // $fatal("Assertion 1 is violated");
end

Assertion2: assert property (Latency1000)
    else begin
        // $error("Assertion 2 is violated");
        $fatal(0, "Assertion 2 is violated");
    end

// always @(*) begin
//     $display("act=%0d, index_cnt=%0d, month:%d, day:%d", act, index_cnt, month, day);
// end


property Latency1000;
    @(posedge clk) ((((act === Index_Check || act === Update) && index_cnt === 3 && inf.index_valid===1) || (act === Check_Valid_Date && inf.data_no_valid===1)) |-> (##[1:1000] inf.out_valid === 1));
endproperty

Assertion3: assert property (Complete_with_No_Warn)
    else begin 
        // $error("Assertion 3 is violated");
        $fatal(0, "Assertion 3 is violated");
    end 

property Complete_with_No_Warn;
    @(negedge clk) (inf.complete===1 |-> inf.warn_msg === No_Warn);
endproperty


Assertion4_0: assert property (Invalid_Index_Check_Action_to_formula)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_1: assert property (Invalid_Index_Check_formula_to_mode)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_2: assert property (Invalid_Index_Check_mode_to_date)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_3: assert property (Invalid_Index_Check_date_to_data_no)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_4: assert property (Invalid_Index_Check_data_no_to_index0)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_5: assert property (Invalid_Index_Check_index0_to_index1)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_6: assert property (Invalid_Index_Check_index1_to_index2)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

Assertion4_7: assert property (Invalid_Index_Check_index2_to_index3)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end 

property Invalid_Index_Check_Action_to_formula;
    @(posedge clk)(((inf.D.d_act[0] == Index_Check) && (inf.sel_action_valid)) |-> (##[1:4] inf.formula_valid === 1));
endproperty

property Invalid_Index_Check_formula_to_mode;
    @(negedge clk)(((act == Index_Check) && (inf.formula_valid)) |-> (##[1:4] inf.mode_valid === 1));
endproperty

property Invalid_Index_Check_mode_to_date;
    @(negedge clk) (((act == Index_Check) && (inf.mode_valid)) |-> (##[1:4] inf.date_valid === 1));
endproperty

property Invalid_Index_Check_date_to_data_no;
    @(negedge clk) (((act == Index_Check) && (inf.date_valid)) |-> (##[1:4] inf.data_no_valid === 1));
endproperty

property Invalid_Index_Check_data_no_to_index0;
    @(negedge clk) (((act == Index_Check) && (inf.data_no_valid) && (index_cnt == 0)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Index_Check_index0_to_index1;
    @(negedge clk) (((act == Index_Check) && (inf.index_valid) && (index_cnt == 1)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Index_Check_index1_to_index2;
    @(negedge clk) (((act == Index_Check) && (inf.index_valid) && (index_cnt == 2)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Index_Check_index2_to_index3;
    @(negedge clk) (((act == Index_Check) && (inf.index_valid) && (index_cnt == 3)) |-> (##[1:4] inf.index_valid === 1));
endproperty




Assertion4_8: assert property (Invalid_Update_Action_to_date)
    // $display("ACT to date");
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_9: assert property (Invalid_Update_date_to_date_no)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_10: assert property (Invalid_Update_data_no_to_index0)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_11: assert property (Invalid_Update_index0_to_index1)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_12: assert property (Invalid_Update_index1_to_index2)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_13: assert property (Invalid_Update_index2_to_index3)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end


property Invalid_Update_Action_to_date;
    @(negedge clk)(((inf.D.d_act[0] == Update) && (inf.sel_action_valid)) |-> (##[1:4] inf.date_valid === 1));
endproperty


property Invalid_Update_date_to_date_no;
    @(negedge clk)(((act == Update) && (inf.date_valid)) |-> (##[1:4] inf.data_no_valid === 1));
endproperty

property Invalid_Update_data_no_to_index0;
    @(negedge clk) (((act == Update) && (inf.data_no_valid) && (index_cnt == 0)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Update_index0_to_index1;
    @(negedge clk) (((act == Update) && (inf.index_valid) && (index_cnt == 1)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Update_index1_to_index2;
    @(negedge clk) (((act == Update) && (inf.index_valid) && (index_cnt == 2)) |-> (##[1:4] inf.index_valid === 1));
endproperty

property Invalid_Update_index2_to_index3;
    @(negedge clk) (((act == Update) && (inf.index_valid) && (index_cnt == 3)) |-> (##[1:4] inf.index_valid === 1));
endproperty



Assertion4_14: assert property (Invalid_Check_Date_Action_to_date)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end

Assertion4_15: assert property (Invalid_Check_Date_date_to_date_no)
    else begin 
        // $error("Assertion 4 is violated");
        $fatal(0, "Assertion 4 is violated");
    end


property Invalid_Check_Date_Action_to_date;
    @(negedge clk)(((inf.D.d_act[0] == Check_Valid_Date) && (inf.sel_action_valid)) |-> (##[1:4] inf.date_valid === 1));
endproperty


property Invalid_Check_Date_date_to_date_no;
    @(negedge clk)(((act == Check_Valid_Date) && (inf.date_valid)) |-> (##[1:4] inf.data_no_valid === 1));
endproperty


Assertion5: assert property (Input_Overlap)
    else begin 
        // $error("Assertion 5 is violated");
        $fatal(0, "Assertion 5 is violated");
    end

wire none_1 = !((inf.sel_action_valid ===1) ||( inf.formula_valid ===1) || (inf.mode_valid ===1) || (inf.date_valid ===1) || (inf.data_no_valid ===1) || (inf.index_valid ===1));
logic [2:0] in_add = (inf.sel_action_valid+ inf.formula_valid+ inf.mode_valid+ inf.date_valid+ inf.data_no_valid+ inf.index_valid + none_1);

// always @(*) begin
//     $display("sel=%0d", inf.sel_action_valid);
//     $display("form=%0d", inf.formula_valid);
//     $display("mode=%0d", inf.mode_valid);
//     $display("date=%0d", inf.date_valid);
//     $display("data=%0d", inf.data_no_valid);
//     $display("index=%0d", inf.index_valid);
//     $display("none=%0d", none_1);
//     $display("************************");
// end


property Input_Overlap;
    @(posedge clk) $onehot({inf.sel_action_valid, inf.formula_valid, inf.mode_valid, inf.date_valid, inf.data_no_valid, inf.index_valid, none_1});
    // @(posedge clk) (inf.sel_action_valid+ inf.formula_valid+ inf.mode_valid+ inf.date_valid+ inf.data_no_valid+ inf.index_valid + none_1) === 1;

endproperty


Assertion6: assert property (Outvalid_1_Cycle)
    else begin 
        // $error("Assertion 6 is violated");
        $fatal(0,"Assertion 6 is violated");
    end

property Outvalid_1_Cycle;
    @(negedge clk) (inf.out_valid === 1 |-> ##1 inf.out_valid === 0); 
endproperty

Assertion7: assert property (Next_Operation_After_1to4_Cycle)
    else begin 
        // $error("Assertion 7 is violated");
        $fatal(0, "Assertion 7 is violated");
    end

property Next_Operation_After_1to4_Cycle;
    @(posedge clk) (inf.out_valid===1) |-> ##[1:4] (inf.sel_action_valid === 1) ;
    // (@(negedge clk) $fell(inf.out_valid) |-> ##[1:4] inf.sel_action_valid === 1);
endproperty



Assertion8_0: assert property (Check_Freburary)
    else begin 
        // $error("Assertion 8 is violated");
        $fatal(0, "Assertion 8 is violated");
    end

Assertion8_1: assert property (Check_Big_month)
    else begin 
        // $error("Assertion 8 is violated");
        $fatal(0, "Assertion 8 is violated");
    end

Assertion8_2: assert property (Check_Little_month)
    else begin 
        // $error("Assertion 8 is violated");
        $fatal(0, "Assertion 8 is violated");
    end

Assertion8_3: assert property (Check_Legal_Month)
    else begin 
        // $error("Assertion 8 is violated");
        $fatal(0, "Assertion 8 is violated");
    end

    

property Check_Freburary;
    @(negedge clk) (inf.date_valid && inf.D.d_date[0].M == 2) |-> (inf.D.d_date[0].D >=1 && inf.D.d_date[0].D <= 28); 
endproperty

property Check_Big_month;
    @(negedge clk) (inf.date_valid && (inf.D.d_date[0].M == 1 || inf.D.d_date[0].M == 3 || inf.D.d_date[0].M == 5 || inf.D.d_date[0].M == 7|| inf.D.d_date[0].M == 8 || inf.D.d_date[0].M == 10 || inf.D.d_date[0].M == 12)) |-> (inf.D.d_date[0].D >=1 && inf.D.d_date[0].D <= 31);
endproperty

property Check_Little_month;
    @(negedge clk) (inf.date_valid && (/*inf.D.d_date[0].M == 2 || */inf.D.d_date[0].M == 4|| inf.D.d_date[0].M == 6 || inf.D.d_date[0].M == 9 || inf.D.d_date[0].M == 11)) |-> (inf.D.d_date[0].D >=1 && inf.D.d_date[0].D <= 30);
endproperty

property Check_Legal_Month;
    @(negedge clk) (inf.date_valid) |-> (inf.D.d_date[0].M >=1 && inf.D.d_date[0].M <= 12);
endproperty

Assertion9_0: assert property (AR_AW_Valid_Overlap)
    else begin 
        // $error("Assertion 9 is violated");
        $fatal(0, "Assertion 9 is violated");
    end

Assertion9_1: assert property (AW_AR_Valid_Overlap)
    else begin 
        // $error("Assertion 9 is violated");
        $fatal(0, "Assertion 9 is violated");
    end


// always @(posedge inf.AR_VALID) begin
//     assert (inf.AW_VALID === 0)
//     else begin
//         $error("Assertion 9 is violated");
//         $fatal;
//     end
// end

// property AR_AW_Valid_Overlap;
//     @(negedge clk) ((!(inf.AR_VALID==1 &&inf.AW_VALID==1)) && ());
// endproperty
property AW_AR_Valid_Overlap;
    @(negedge clk) (inf.AW_VALID) |-> (inf.AR_VALID === 0);
endproperty
property AR_AW_Valid_Overlap;
    @(negedge clk) (inf.AR_VALID) |-> (inf.AW_VALID === 0);
endproperty

endmodule