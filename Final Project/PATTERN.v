
// `ifdef RTL
//     `define CYCLE_TIME 10.7
// `endif
// `ifdef GATE
//     `define CYCLE_TIME 3.7
// `endif
// `ifdef POST 
//     `define CYCLE_TIME 3.7
// `endif


// `define DRAM_PATH "../00_TESTBED/DRAM/dram1.dat"
// `define PATNUM 1000
// `define SEED 123456789.0

// `include "../00_TESTBED/pseudo_DRAM.v"

// module PATTERN(
//     // Input Signals
//     clk,
//     rst_n,
//     in_valid,
//     in_pic_no,
//     in_mode,
//     in_ratio_mode,
//     out_valid,
//     out_data
// );

// /* Input for design */
// output reg        clk, rst_n;
// output reg        in_valid;

// output reg [3:0] in_pic_no;
// output reg [1:0]      in_mode;
// output reg [1:0] in_ratio_mode;

// input out_valid;
// input [7:0] out_data;
// //////////////////////////////////////////////////////////////////////
// parameter DRAM_p_r = `DRAM_PATH;
// parameter CYCLE = `CYCLE_TIME;

// reg [7:0] DRAM_r[0:196607];
// reg [7:0] image [0:2][0:31][0:31];
// integer patcount;
// integer latency, total_latency;
// integer file;
// integer PATNUM = `PATNUM;
// integer seed = `SEED;

// reg [1:0] golden_in_ratio_mode;
// reg [3:0] golden_in_pic_no;
// reg [1:0] golden_in_mode;
// reg [7:0] golden_out_data;

// reg [7:0] two_by_two [0:1][0:1];
// reg [7:0] four_by_four [0:3][0:3];
// reg [7:0] six_by_six [0:5][0:5];

// reg [31:0] out_data_temp;
// reg [31:0] D_constrate [0:2];
// reg [31:0] D_constrate_add [0:2];


// // testing focus and exposure
// integer focus_num;
// integer exposure_num;
// integer avg_max_min_num;
// reg focus_flag [0:15];
// reg exposure_flag [0:15];
// reg [3:0] dram_all_zero_flag [0:15];
// integer read_dram_times;

// //////////////////////////////////////////////////////////////////////
// // Write your own task here
// //////////////////////////////////////////////////////////////////////
// initial clk=0;
// always #(CYCLE/2.0) clk = ~clk;

// // Do it yourself, I believe you can!!!

// /* Check for invalid overlap */
// always @(*) begin
//     if (in_valid && out_valid) begin
//         display_fail;
//         $display("************************************************************");  
//         $display("                          FAIL!                           ");    
//         $display("*  The out_valid signal cannot overlap with in_valid.   *");
//         $display("************************************************************");
//         $finish;            
//     end    
// end







// initial begin
//     reset_task;
//     $readmemh(DRAM_p_r,DRAM_r);
//     file = $fopen("../00_TESTBED/debug.txt", "w");
//     focus_num = 0;
//     exposure_num = 0;
//     avg_max_min_num = 0;
//     read_dram_times = 0;
//     for(integer i = 0; i < 16; i = i + 1)begin
//         focus_flag[i] = 0;
//         exposure_flag[i] = 0;
//         dram_all_zero_flag[i] = 0;
//     end

//     for( patcount = 0; patcount < PATNUM; patcount++) begin 
//         repeat(2) @(negedge clk); 
//         input_task;
//         write_dram_file;
//         calculate_ans;
//         write_to_file;
//         wait_out_valid_task;
//         check_ans;
//         $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Cycle: %3d \033[0m", patcount + 1, latency);
  
//     end
//     display_pass;
//     repeat (3) @(negedge clk);
//     $finish;
// end

// task reset_task; begin 
//     rst_n = 1'b1;
//     in_valid = 1'b0;
//     in_ratio_mode = 2'bx;
//     in_pic_no = 4'bx;
//     in_mode = 1'bx;
//     total_latency = 0;

//     force clk = 0;

//     // Apply reset
//     #CYCLE; rst_n = 1'b0; 
//     #(2*CYCLE); rst_n = 1'b1;
    
//     // Check initial conditions
//     if (out_valid !== 1'b0 || out_data !== 'b0) begin
//         display_fail;
//         $display("************************************************************");  
//         $display("                          FAIL!                           ");    
//         $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
//         $display("************************************************************");
//         repeat (2) #CYCLE;
//         $finish;
//     end
//     #CYCLE; release clk;
// end endtask


// task input_task; begin
//     integer i,j;
//     in_valid = 1'b1;
    
    
//     // in_pic_no = 15;
//     // in_mode = 1;
//     in_pic_no = $random(seed) % 'd16;
//     in_mode = $random(seed) % 'd2;
//     // in_mode = 1'b1;
//     in_ratio_mode = (in_mode==1) ? $random(seed) % 'd4 : 2'bx;
//     golden_in_ratio_mode = in_ratio_mode;
//     golden_in_pic_no = in_pic_no;
//     golden_in_mode = in_mode;

//     // count focus and exposure

//     if(in_mode == 2'b00)begin
//         focus_num = focus_num + 1;
//     //     if(focus_flag[in_pic_no] == 1'b0)begin
//     //         focus_flag[in_pic_no] = 1'b1;
//     //         if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //             read_dram_times = read_dram_times + 1;
//     //         end
//     //     end
//     end
//     else if(in_mode == 2'b01)begin
//         exposure_num = exposure_num + 1;
//     end 
//     else begin
//         avg_max_min_num = avg_max_min_num + 1;
//     end   
        

//     //     if(focus_flag[in_pic_no] == 1'b0)begin
//     //         focus_flag[in_pic_no] = 1'b1;
//     //     end
//     //     if(exposure_flag[in_pic_no] != 1'b1 || (in_ratio_mode != 2 && in_ratio_mode != 0 && in_ratio_mode != 1))begin
//     //         exposure_flag[in_pic_no] = 1'b1;
//     //         if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //             read_dram_times = read_dram_times + 1;
//     //         end
//     //     end

//     //     if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //         if(in_ratio_mode == 0)begin
//     //             dram_all_zero_flag[in_pic_no] = (dram_all_zero_flag[in_pic_no] >= 6) ? 8 : dram_all_zero_flag[in_pic_no] + 2;
//     //         end
//     //         else if(in_ratio_mode == 1)begin
//     //             dram_all_zero_flag[in_pic_no] = dram_all_zero_flag[in_pic_no] + 1;
//     //         end
//     //         else if(in_ratio_mode == 3)begin
//     //             dram_all_zero_flag[in_pic_no] = (dram_all_zero_flag[in_pic_no] == 0) ? 0 : dram_all_zero_flag[in_pic_no] - 1;
//     //         end
//     //     end

        
//     // end

    

    

//     for(integer i = 0; i < 3; i = i + 1)begin
//         for(integer j = 0; j < 32; j = j + 1)begin
//             for(integer k = 0; k < 32; k = k + 1)begin
//                 image[i][j][k] = DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3];
//             end
//         end
//     end   
    

//     @(negedge clk);

//     in_valid = 1'b0;
//     in_ratio_mode = 2'bx;
//     in_pic_no = 4'bx;
//     in_mode = 1'bx;
    
// end endtask

// reg [7:0] r_max, r_min, g_max, g_min, b_max, b_min;


// task calculate_ans;begin
   

//     if(golden_in_mode == 2'b00)begin
//         for(integer i = 0; i < 3; i = i + 1)begin
//             D_constrate_add[i] = 0;
//         end
        
//         for(integer j = 0; j < 2; j = j + 1)begin
//             for(integer k = 0; k < 2; k = k + 1)begin
//                 two_by_two[j][k] = (image[0][15 + j][15 + k] ) / 4 + (image[1][15 + j][15 + k]) / 2 + 
//                                         (image[2][15 + j][15 + k] ) / 4 ;
//             end
//         end

//         for(integer j = 0; j < 4; j = j + 1)begin
//             for(integer k = 0; k < 4; k = k + 1)begin
//                 four_by_four[j][k] = (image[0][14 + j][14 + k] ) / 4 + (image[1][14 + j][14 + k]) / 2 + 
//                                         (image[2][14 + j][14 + k] ) / 4 ;
//             end
//         end

//         for(integer j = 0; j < 6; j = j + 1)begin
//             for(integer k = 0; k < 6; k = k + 1)begin
//                 six_by_six[j][k] = (image[0][13 + j][13 + k] ) / 4 + (image[1][13 + j][13 + k]) / 2 + 
//                                         (image[2][13 + j][13 + k] ) / 4 ;
//             end
//         end



//         for(integer i = 0; i < 2; i = i + 1)begin
//             for(integer j = 0; j < 1; j = j + 1)begin
//                 D_constrate_add[0] = D_constrate_add[0] + diff_abs(two_by_two[i][j + 1], two_by_two[i][j]) + diff_abs(two_by_two[j + 1][i], two_by_two[j][i]);
//             end
//         end

//         for(integer i = 0; i < 4; i = i + 1)begin
//             for(integer j = 0; j < 3; j = j + 1)begin
//                 D_constrate_add[1] = D_constrate_add[1] + diff_abs(four_by_four[i][j + 1], four_by_four[i][j]) + diff_abs(four_by_four[j + 1][i], four_by_four[j][i]);
//             end
//         end

//         for(integer i = 0; i < 6; i = i + 1)begin
//             for(integer j = 0; j < 5; j = j + 1)begin
//                 D_constrate_add[2] = D_constrate_add[2] + diff_abs(six_by_six[i][j + 1], six_by_six[i][j]) + diff_abs(six_by_six[j + 1][i], six_by_six[j][i]);
//             end
//         end

//         D_constrate[0] = D_constrate_add[0] / (2 * 2);
//         D_constrate[1] = D_constrate_add[1] / (4 * 4);
//         D_constrate[2] = D_constrate_add[2] / (6 * 6);

//         if(D_constrate[0] >= D_constrate[1] && D_constrate[0] >= D_constrate[2])begin
//             golden_out_data = 8'b00000000;
//         end
//         else if(D_constrate[1] >= D_constrate[2])begin
//             golden_out_data = 8'b00000001;
//         end
//         else begin
//             golden_out_data = 8'b00000010;
//         end

//     end
//     else if(golden_in_mode == 2'b01) begin
//         for(integer i = 0; i < 3; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     if(golden_in_ratio_mode == 0)begin
//                         image[i][j][k] = image[i][j][k] / 4;
//                     end
//                     else if(golden_in_ratio_mode == 1)begin
//                         image[i][j][k] = image[i][j][k] / 2;
//                     end
//                     else if(golden_in_ratio_mode == 2)begin
//                         image[i][j][k] = image[i][j][k];
//                     end
//                     else begin
//                         image[i][j][k] = (image[i][j][k] < 128)  ? image[i][j][k] * 2 : 255;
//                         // MSB is 1, image = 255, else shift left 1;
//                     end
                    
//                 end
//             end
//         end

//         for(integer i = 0; i < 3; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3] = image[i][j][k];
//                 end
//             end
//         end
        
//         out_data_temp = 0;
//         for(integer i = 0; i < 32; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 out_data_temp = out_data_temp + image[0][i][j] / 4 + image[1][i][j] / 2 + image[2][i][j] / 4;
//             end
//         end
//         golden_out_data = out_data_temp / 1024;
//     end
//         else if(golden_in_mode == 2'b10) begin
//             r_max = 0; r_min = 255; g_max = 0; g_min = 255; b_max = 0; b_min = 255;

//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     r_max =  image[0][j][k] > r_max ? image[0][j][k] : r_max;
//                     r_min =  image[0][j][k] < r_min ? image[0][j][k] : r_min;
//                 end
//             end
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     g_max =  image[1][j][k] > g_max ? image[1][j][k] : g_max;
//                     g_min =  image[1][j][k] < g_min ? image[1][j][k] : g_min;
//                 end
//             end
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     b_max =  image[2][j][k] > b_max ? image[2][j][k] : b_max;
//                     b_min =  image[2][j][k] < b_min ? image[2][j][k] : b_min;
//                 end
//             end
//             golden_out_data = ((r_max + g_max + b_max) / 3 + (r_min + g_min + b_min) / 3) / 2;

//         end
//     end


//  endtask

// task wait_out_valid_task; begin
//     latency = 0;
//     while (out_valid !== 1'b1) begin
//         latency = latency + 1;
//         if (latency == 20000) begin
//             display_fail;
//             $display("********************************************************");     
//             $display("                          FAIL!                           ");
//             $display("*  The execution latency exceeded 20000 cycles at %8t   *", $time);
//             $display("********************************************************");
//             repeat (2) @(negedge clk);
//             $finish;
//         end
//         @(negedge clk);
//     end
//     total_latency = total_latency + latency;
// end endtask



// task check_ans; begin
//     if(golden_in_mode == 0)begin
//         if(out_data !== golden_out_data)begin
//             display_fail;
//             $display("********************************************************");     
//             $display("                          FAIL!                           ");
//             $display("*               The golden_in_mode is %d               *", golden_in_mode);
//             $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//             $display("********************************************************");
//             repeat (2) @(negedge clk);
//             $finish;
//         end
//     end
//     else if (golden_in_mode == 1) begin
//         if(golden_out_data == 0)begin
//             if(out_data !== 1 && out_data !== 0)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
//         else if(golden_out_data == 255)begin
//             if(out_data !== 255 && out_data !== 254)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
//         else begin
//             if(out_data > golden_out_data + 1 || out_data < golden_out_data - 1)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
//     end
//     else begin
//          if(out_data !== golden_out_data)begin
//             display_fail;
//             $display("********************************************************");     
//             $display("                          FAIL!                           ");
//             $display("*               The golden_in_mode is %d               *", golden_in_mode);
//             $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//             $display("********************************************************");
//             repeat (2) @(negedge clk);
//             $finish;
//         end
//     end

// end endtask

// task write_dram_file; begin
//     $fwrite(file, "===========  PATTERN NO.%4d  ==============\n", patcount);
//     $fwrite(file, "==========  GOLDEN_PIC_NO.%2d  ==============\n", golden_in_pic_no);
//     $fwrite(file, "===========    RED IMAGE     ==============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[0][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "===========    GREEN IMAGE     ============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[1][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "===========    BLUE IMAGE     ============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[2][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "\n");
// end endtask












// task write_to_file; begin
    
//     $fwrite(file, "==========  GOLDEN_IN_MODE is %b  ==============\n", golden_in_mode);   
//     if(golden_in_mode == 1'b0)begin
//         $fwrite(file, "===========    TWO_BY_TWO     ============\n");
//         for(integer i = 0; i < 2; i = i + 1) begin
//             for(integer j = 0; j < 2; j = j + 1) begin
//                 $fwrite(file, "%5d ", two_by_two[i][j]);
//             end
//             $fwrite(file, "\n");
//         end

//         $fwrite(file, "===========    FOUR_BY_FOUR     ============\n");
//         for(integer i = 0; i < 4; i = i + 1) begin
//             for(integer j = 0; j < 4; j = j + 1) begin
//                 $fwrite(file, "%5d ", four_by_four[i][j]);
//             end
//             $fwrite(file, "\n");
//         end

//         $fwrite(file, "===========    SIX_BY_SIX     ============\n");
//         for(integer i = 0; i < 6; i = i + 1) begin
//             for(integer j = 0; j < 6; j = j + 1) begin
//                 $fwrite(file, "%5d ", six_by_six[i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========   D_CONSTRATE(ADD)  ============\n");
//         for(integer i = 0; i < 3; i = i + 1) begin
//             $fwrite(file, "%10d", D_constrate_add[i]);
//         end
//         $fwrite(file, "\n");
//         $fwrite(file, "===========    D_CONSTRATE     ============\n");
//         for(integer i = 0; i < 3; i = i + 1) begin
//             $fwrite(file, "%10d", D_constrate[i]);
//         end
//         $fwrite(file, "\n");
//     end
//     else begin
//         $fwrite(file, "=========  IMAGE_AFTER_AUTO_EXPOSURE  ============\n");
//         $fwrite(file, "=========  GOLDEN_RATIO is %d  ============\n",golden_in_ratio_mode);
//         $fwrite(file, "===========    RED IMAGE     ==============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[0][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========    GREEN IMAGE     ============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[1][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========    BLUE IMAGE     ============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[2][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "\n");

//         $fwrite(file, "===========  DATA_SUM (not divide 1024)  ============\n");
//         $fwrite(file, "%10d\n", out_data_temp);
//     end
//     $fwrite(file, "===========  GOLDEN_OUT_DATA  ============\n");
//     $fwrite(file, "%10d\n", golden_out_data);

//     $fwrite(file, "\n\n\n");
// end endtask






// function [7:0]diff_abs; 
//     input [7:0]a;
//     input [7:0]b;
//     begin
//         if(a > b)begin
//             diff_abs = a - b;
//         end
//         else begin
//             diff_abs = b - a;
//         end
//     end
// endfunction





















// task display_fail; begin

//     /*$display("        ----------------------------               ");
//     $display("        --                        --       |\__||  ");
//     $display("        --  OOPS!!                --      / X,X  | ");
//     $display("        --                        --    /_____   | ");
//     $display("        --  \033[0;31mSimulation FAIL!!\033[m   --   /^ ^ ^ \\  |");
//     $display("        --                        --  |^ ^ ^ ^ |w| ");
//     $display("        ----------------------------   \\m___m__|_|");
//     $display("\n");*/
// end endtask

// /*task display_pass; begin
//         $display("\n");
//         $display("\n");
//         $display("        ----------------------------               ");
//         $display("        --                        --       |\__||  ");
//         $display("        --  Congratulations !!    --      / O.O  | ");
//         $display("        --                        --    /_____   | ");
//         $display("        --  \033[0;32mSimulation PASS!!\033[m     --   /^ ^ ^ \\  |");
//         $display("        --                        --  |^ ^ ^ ^ |w| ");
//         $display("        ----------------------------   \\m___m__|_|");
//         $display("\n");
// end endtask*/

// task display_pass; begin
//     $display("-----------------------------------------------------------------");
//     $display("                       Congratulations!                          ");
//     $display("                You have passed all patterns!                     ");
//     $display("                Your execution cycles = %5d cycles                ", total_latency);
//     $display("                Your clock period = %.1f ns                       ", CYCLE);
//     $display("                Total Latency = %.1f ns                          ", total_latency * CYCLE);
//     $display("    Focus number = %4d, Exposure number = %4d, Avg number = %4d       ", focus_num, exposure_num, avg_max_min_num);
//     // $display("                Total Read DRAM times = %4d                             ", read_dram_times);
//     // $display("                DRAM all zero number %d = %d                            ", 0, dram_all_zero_flag[0]);
//     // $display("                DRAM all zero number %d = %d                            ", 1, dram_all_zero_flag[1]);
//     // $display("                DRAM all zero number %d = %d                            ", 2, dram_all_zero_flag[2]);
//     // $display("                DRAM all zero number %d = %d                            ", 3, dram_all_zero_flag[3]);
//     // $display("                DRAM all zero number %d = %d                            ", 4, dram_all_zero_flag[4]);
//     // $display("                DRAM all zero number %d = %d                            ", 5, dram_all_zero_flag[5]);
//     // $display("                DRAM all zero number %d = %d                            ", 6, dram_all_zero_flag[6]);
//     // $display("                DRAM all zero number %d = %d                            ", 7, dram_all_zero_flag[7]);
//     // $display("                DRAM all zero number %d = %d                            ", 8, dram_all_zero_flag[8]);
//     // $display("                DRAM all zero number %d = %d                            ", 9, dram_all_zero_flag[9]);
//     // $display("                DRAM all zero number %d = %d                            ", 10, dram_all_zero_flag[10]);
//     // $display("                DRAM all zero number %d = %d                            ", 11, dram_all_zero_flag[11]);
//     // $display("                DRAM all zero number %d = %d                            ", 12, dram_all_zero_flag[12]);
//     // $display("                DRAM all zero number %d = %d                            ", 13, dram_all_zero_flag[13]);
//     // $display("                DRAM all zero number %d = %d                            ", 14, dram_all_zero_flag[14]);
//     // $display("                DRAM all zero number %d = %d                            ", 15, dram_all_zero_flag[15]);
//     $display("-----------------------------------------------------------------");
//     repeat (2) @(negedge clk);
//     $finish;
// end endtask


// endmodule




//PH
`define CYCLE_TIME 3.7

`define DRAM_PATH "../00_TESTBED/DRAM/dram_corner.dat"
`define PATNUM 1000
`define SEED 54870123

`include "../00_TESTBED/pseudo_DRAM.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    in_pic_no,
    in_mode,
    in_ratio_mode,
    out_valid,
    out_data
);

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;

output reg [3:0] in_pic_no;
output reg [1:0] in_mode;
output reg [1:0] in_ratio_mode;

input out_valid;
input [7:0] out_data;


//////////////////////////////////////////////////////////////////////
parameter DRAM_p_r = `DRAM_PATH;
parameter CYCLE = `CYCLE_TIME;

reg [7:0] DRAM_r[0:196607];
reg [7:0] image [0:2][0:31][0:31];
integer patcount;
integer latency, total_latency;
integer file;
integer PATNUM = `PATNUM;
integer seed = `SEED;
integer out_num;

reg [1:0] golden_in_ratio_mode;
reg [3:0] golden_in_pic_no;
reg [1:0] golden_in_mode;
reg [7:0] golden_out_data;

reg [7:0] two_by_two [0:1][0:1];
reg [7:0] four_by_four [0:3][0:3];
reg [7:0] six_by_six [0:5][0:5];

reg [31:0] out_data_temp;
reg [31:0] D_constrate [0:2];
reg [31:0] D_constrate_add [0:2];


// testing focus and exposure
integer focus_num;
integer exposure_num;
reg focus_flag [0:15];
reg exposure_flag [0:15];
reg [3:0] dram_all_zero_flag [0:15];
integer read_dram_times;

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
initial clk=0;
always #(CYCLE/2.0) clk = ~clk;

// Do it yourself, I believe you can!!!
always @(*) begin
    if (in_valid && out_valid) begin
        $display("*************************************************************************");
		$display("*                              \033[1;31mFAIL!\033[1;0m                                    *");   
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("*************************************************************************");
        repeat (1) #CYCLE;
        $finish;            
    end    
end

initial begin
    reset_task;
    $readmemh(DRAM_p_r,DRAM_r);
    file = $fopen("../00_TESTBED/debug.txt", "w");
    focus_num = 0;
    exposure_num = 0;
    read_dram_times = 0;
    for(integer i = 0; i < 16; i = i + 1)begin
        focus_flag[i] = 0;
        exposure_flag[i] = 0;
        dram_all_zero_flag[i] = 0;
    end

    for( patcount = 0; patcount < PATNUM; patcount++) begin 
        repeat(2) @(negedge clk); 
        input_task;
        write_dram_file;
        calculate_ans_task;
        write_to_file;
        wait_out_valid_task;
        check_ans_task;
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Cycle: %3d \033[0m", patcount + 1, latency);
    end
    YOU_PASS_task;
    repeat (2) @(negedge clk);
    $finish;
end

task reset_task; begin 
    rst_n = 1'b1;
    in_valid = 1'b0;
    in_ratio_mode = 2'bx;
    in_pic_no = 4'bx;
    in_mode = 2'bx;
    total_latency = 0;

    force clk = 0;

    // Apply reset
    #CYCLE; rst_n = 1'b0; 
    #(2*CYCLE); rst_n = 1'b1;
    
    // Check initial conditions
    if (out_valid !== 1'b0 || out_data !== 'b0) begin
        
        $display("*************************************************************************");
		$display("*                              \033[1;31mFAIL!\033[1;0m                                    *");  
        $display("*  Output signals should be 0 after initial RESET at %8t           *", $time);
        $display("*************************************************************************");
        repeat (1) #CYCLE;
        $finish;
    end
    #CYCLE; release clk;
end endtask


task input_task; begin
    integer i,j;
    in_valid = 1'b1;
    
    in_pic_no = {$random(seed)} % 'd16;
    in_mode = {$random(seed)} % 'd3;
    // in_mode = 1;

    in_ratio_mode = (in_mode == 'd1) ? {$random(seed)} % 'd4 : 2'bx;
    // in_ratio_mode = 3;
    golden_in_ratio_mode = in_ratio_mode;
    golden_in_pic_no = in_pic_no;
    golden_in_mode = in_mode;

    // count focus and exposure

    if(in_mode == 'd0)begin
        focus_num = focus_num + 1;
    end
    else if(in_mode == 'd1) begin
        exposure_num = exposure_num + 1;
    end    
        
    for(integer i = 0; i < 3; i = i + 1)begin
        for(integer j = 0; j < 32; j = j + 1)begin
            for(integer k = 0; k < 32; k = k + 1)begin
                image[i][j][k] = DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3];
            end
        end
    end   

    @(negedge clk);

    in_valid = 1'b0;
    in_ratio_mode = 2'bx;
    in_pic_no = 4'bx;
    in_mode = 2'bx;
end endtask


task calculate_ans_task;begin
    if(golden_in_mode == 'd0)begin
        for(integer i = 0; i < 3; i = i + 1)begin
            D_constrate_add[i] = 0;
        end
        
        for(integer j = 0; j < 2; j = j + 1)begin
            for(integer k = 0; k < 2; k = k + 1)begin
                two_by_two[j][k] = (image[0][15 + j][15 + k] ) / 4 + (image[1][15 + j][15 + k]) / 2 + 
                                        (image[2][15 + j][15 + k] ) / 4 ;
            end
        end

        for(integer j = 0; j < 4; j = j + 1)begin
            for(integer k = 0; k < 4; k = k + 1)begin
                four_by_four[j][k] = (image[0][14 + j][14 + k] ) / 4 + (image[1][14 + j][14 + k]) / 2 + 
                                        (image[2][14 + j][14 + k] ) / 4 ;
            end
        end

        for(integer j = 0; j < 6; j = j + 1)begin
            for(integer k = 0; k < 6; k = k + 1)begin
                six_by_six[j][k] = (image[0][13 + j][13 + k] ) / 4 + (image[1][13 + j][13 + k]) / 2 + 
                                        (image[2][13 + j][13 + k] ) / 4 ;
            end
        end



        for(integer i = 0; i < 2; i = i + 1)begin
            for(integer j = 0; j < 1; j = j + 1)begin
                D_constrate_add[0] = D_constrate_add[0] + diff_abs(two_by_two[i][j + 1], two_by_two[i][j]) + diff_abs(two_by_two[j + 1][i], two_by_two[j][i]);
            end
        end

        for(integer i = 0; i < 4; i = i + 1)begin
            for(integer j = 0; j < 3; j = j + 1)begin
                D_constrate_add[1] = D_constrate_add[1] + diff_abs(four_by_four[i][j + 1], four_by_four[i][j]) + diff_abs(four_by_four[j + 1][i], four_by_four[j][i]);
            end
        end

        for(integer i = 0; i < 6; i = i + 1)begin
            for(integer j = 0; j < 5; j = j + 1)begin
                D_constrate_add[2] = D_constrate_add[2] + diff_abs(six_by_six[i][j + 1], six_by_six[i][j]) + diff_abs(six_by_six[j + 1][i], six_by_six[j][i]);
            end
        end

        D_constrate[0] = D_constrate_add[0] / (2 * 2);
        D_constrate[1] = D_constrate_add[1] / (4 * 4);
        D_constrate[2] = D_constrate_add[2] / (6 * 6);

        if(D_constrate[0] >= D_constrate[1] && D_constrate[0] >= D_constrate[2])begin
            golden_out_data = 8'b00000000;
        end
        else if(D_constrate[1] >= D_constrate[2])begin
            golden_out_data = 8'b00000001;
        end
        else begin
            golden_out_data = 8'b00000010;
        end

    end
    else if((golden_in_mode == 'd1))begin
        for(integer i = 0; i < 3; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                for(integer k = 0; k < 32; k = k + 1)begin
                    if(golden_in_ratio_mode == 0)begin
                        image[i][j][k] = image[i][j][k] / 4;
                    end
                    else if(golden_in_ratio_mode == 1)begin
                        image[i][j][k] = image[i][j][k] / 2;
                    end
                    else if(golden_in_ratio_mode == 2)begin
                        image[i][j][k] = image[i][j][k];
                    end
                    else begin
                        image[i][j][k] = (image[i][j][k] < 128)  ? image[i][j][k] * 2 : 255;
                        // MSB is 1, image = 255, else shift left 1;
                    end
                    
                end
            end
        end

        for(integer i = 0; i < 3; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                for(integer k = 0; k < 32; k = k + 1)begin
                    DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3] = image[i][j][k];
                end
            end
        end
        
        out_data_temp = 0;
        for(integer i = 0; i < 32; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                out_data_temp = out_data_temp + image[0][i][j] / 4 + image[1][i][j] / 2 + image[2][i][j] / 4;
            end
        end
        golden_out_data = out_data_temp / 1024;
    end
    else begin
        reg [7:0] max_R, min_R, max_G, min_G, max_B, min_B;
        reg [9:0] temp_max, temp_min;

        for(integer i = 0; i < 32; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                if(i == 0 && j == 0)begin
                    max_R = image[0][i][j];
                    min_R = image[0][i][j];
                    max_G = image[1][i][j];
                    min_G = image[1][i][j];
                    max_B = image[2][i][j];
                    min_B = image[2][i][j];
                end
                else begin
                    if(image[0][i][j] > max_R)begin
                        max_R = image[0][i][j];
                    end
                    if(image[0][i][j] < min_R)begin
                        min_R = image[0][i][j];
                    end
                    if(image[1][i][j] > max_G)begin
                        max_G = image[1][i][j];
                    end
                    if(image[1][i][j] < min_G)begin
                        min_G = image[1][i][j];
                    end
                    if(image[2][i][j] > max_B)begin
                        max_B = image[2][i][j];
                    end
                    if(image[2][i][j] < min_B)begin
                        min_B = image[2][i][j];
                    end
                end
            end
        end

        temp_max = (max_R + max_G + max_B) / 3;
        temp_min = (min_R + min_G + min_B) / 3;
        out_data_temp = temp_max + temp_min;
        golden_out_data = out_data_temp / 2;
    end
end endtask

task wait_out_valid_task; begin
    latency = 0;
    while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 20000) begin
            $display("*************************************************************************");
		    $display("*                              \033[1;31mFAIL!\033[1;0m                                    *");
		    $display("*         The execution latency is limited in 20000 cycles.              *");
		    $display("*************************************************************************");
            repeat (1) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

task check_ans_task; begin
    out_num = 0;

    if(golden_in_mode == 0)begin
        if(out_data !== golden_out_data)begin
            $display("*************************************************************************");
		    $display("*                              \033[1;31mFAIL!\033[1;0m                                    *");
            $display("*               The golden_in_mode is %d               *", golden_in_mode);
            $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
            $display("*************************************************************************");
            repeat (1) @(negedge clk);
            $finish;
        end
        else begin
            @(negedge clk);
            out_num = out_num + 1;
        end
    end
    else if(golden_in_mode == 1)begin
        if(golden_out_data == 0)begin
            if(out_data !== 1 && out_data !== 0)begin
                $display("*************************************************************************");
		        $display("*                       \033[1;31mFAIL!\033[1;0m                                    *");  
                $display("                FAIL error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("*************************************************************************");
                repeat (2) @(negedge clk);
                $finish;
            end
            else begin
                @(negedge clk);
                out_num = out_num + 1;
            end
        end
        else if(golden_out_data == 255)begin
            if(out_data !== 255 && out_data !== 254)begin
                
                $display("*************************************************************************");
		        $display("*                       \033[1;31mFAIL!\033[1;0m                                    *");    
                $display("                 Error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("*************************************************************************");
                repeat (1) @(negedge clk);
                $finish;
            end
            else begin
                @(negedge clk);
                out_num = out_num + 1;
            end
        end
        else begin
            if(out_data > golden_out_data + 1 || out_data < golden_out_data - 1)begin
                $display("*************************************************************************");
		        $display("*                       \033[1;31mFAIL!\033[1;0m                                    *");       
                $display("                 Error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("*************************************************************************");
                repeat (1) @(negedge clk);
                $finish;
            end
            else begin
                @(negedge clk);
                out_num = out_num + 1;
            end
        end
    end
    else begin
        if(out_data !== golden_out_data)begin
            $display("*************************************************************************");
		    $display("*                       \033[1;31mFAIL!\033[1;0m                                    *");
            $display("*               The golden_in_mode is %d               *", golden_in_mode);
            $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
            $display("*************************************************************************");
            repeat (1) @(negedge clk);
            $finish;
        end
        else begin
            @(negedge clk);
            out_num = out_num + 1;
        end
    end

    if(out_num !== 1) begin
        $display("************************************************************");  
        $display("                            \033[1;31mFAIL!\033[1;0m                            ");
        $display(" Expected %d out_valid, but found %d", 1, out_num);
        $display("************************************************************");
        repeat(1) @(negedge clk);
        $finish;
    end
end endtask

task write_dram_file; begin
    $fwrite(file, "===========  PATTERN NO.%4d  ==============\n", patcount);
    $fwrite(file, "==========  GOLDEN_PIC_NO.%2d  ==============\n", golden_in_pic_no);
    $fwrite(file, "===========    RED IMAGE     ==============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        for(integer j = 0; j < 32; j = j + 1) begin
            $fwrite(file, "%5d ", image[0][i][j]);
        end
        $fwrite(file, "\n");
    end
    $fwrite(file, "===========    GREEN IMAGE     ============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        for(integer j = 0; j < 32; j = j + 1) begin
            $fwrite(file, "%5d ", image[1][i][j]);
        end
        $fwrite(file, "\n");
    end
    $fwrite(file, "===========    BLUE IMAGE     ============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        for(integer j = 0; j < 32; j = j + 1) begin
            $fwrite(file, "%5d ", image[2][i][j]);
        end
        $fwrite(file, "\n");
    end
    $fwrite(file, "\n");
end endtask


task write_to_file; begin
    
    $fwrite(file, "==========  GOLDEN_IN_MODE is %b  ==============\n", golden_in_mode);   
    if(golden_in_mode == 'd0)begin
        $fwrite(file, "===========    TWO_BY_TWO     ============\n");
        for(integer i = 0; i < 2; i = i + 1) begin
            for(integer j = 0; j < 2; j = j + 1) begin
                $fwrite(file, "%5d ", two_by_two[i][j]);
            end
            $fwrite(file, "\n");
        end

        $fwrite(file, "===========    FOUR_BY_FOUR     ============\n");
        for(integer i = 0; i < 4; i = i + 1) begin
            for(integer j = 0; j < 4; j = j + 1) begin
                $fwrite(file, "%5d ", four_by_four[i][j]);
            end
            $fwrite(file, "\n");
        end

        $fwrite(file, "===========    SIX_BY_SIX     ============\n");
        for(integer i = 0; i < 6; i = i + 1) begin
            for(integer j = 0; j < 6; j = j + 1) begin
                $fwrite(file, "%5d ", six_by_six[i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========   D_CONSTRATE(ADD)  ============\n");
        for(integer i = 0; i < 3; i = i + 1) begin
            $fwrite(file, "%10d", D_constrate_add[i]);
        end
        $fwrite(file, "\n");
        $fwrite(file, "===========    D_CONSTRATE     ============\n");
        for(integer i = 0; i < 3; i = i + 1) begin
            $fwrite(file, "%10d", D_constrate[i]);
        end
        $fwrite(file, "\n");
    end
    else if(golden_in_mode == 'd1)begin
        $fwrite(file, "=========  IMAGE_AFTER_AUTO_EXPOSURE  ============\n");
        $fwrite(file, "=========  GOLDEN_RATIO is %d  ============\n",golden_in_ratio_mode);
        $fwrite(file, "===========    RED IMAGE     ==============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[0][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    GREEN IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[1][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    BLUE IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[2][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "\n");

        $fwrite(file, "===========  DATA_SUM (not divide 1024)  ============\n");
        $fwrite(file, "%10d\n", out_data_temp);
    end
    $fwrite(file, "===========  GOLDEN_OUT_DATA  ============\n");
    $fwrite(file, "%10d\n", golden_out_data);

    $fwrite(file, "\n\n\n");
end endtask

function [7:0]diff_abs; 
    input [7:0]a;
    input [7:0]b;
    begin
        if(a > b)begin
            diff_abs = a - b;
        end
        else begin
            diff_abs = b - a;
        end
    end
endfunction


task YOU_PASS_task; begin
    $display("\033[37m                                  .$&X.      x$$x              \033[32m      :BBQvi.");
    $display("\033[37m                                .&&;.X&$  :&&$+X&&x            \033[32m     BBBBBBBBQi");
    $display("\033[37m                               +&&    &&.:&$    .&&            \033[32m    :BBBP :7BBBB.");
    $display("\033[37m                              :&&     &&X&&      $&;           \033[32m    BBBB     BBBB");
    $display("\033[37m                              &&;..   &&&&+.     +&+           \033[32m   iBBBv     BBBB       vBr");
    $display("\033[37m                             ;&&...   X&&&...    +&.           \033[32m   BBBBBKrirBBBB.     :BBBBBB:");
    $display("\033[37m                             x&$..    $&&X...    +&            \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB");
    $display("\033[37m                             X&;...   &&&....    &&            \033[32m  BBBB   .::.      EBBBi :BBU");
    $display("\033[37m                             $&...    &&&....    &&            \033[32m MBBBr           vBBBu   BBB.");
    $display("\033[37m                             $&....   &&&...     &$            \033[32m i7PB          iBBBBB.  iBBB");
    $display("\033[37m                             $&....   &&& ..    .&x                        \033[32m  vBBBBPBBBBPBBB7       .7QBB5i");
    $display("\033[37m                             $&....   &&& ..    x&+                        \033[32m :RBBB.  .rBBBBB.      rBBBBBBBB7");
    $display("\033[37m                             X&;...   x&&....   &&;                        \033[32m    .       BBBB       BBBB  :BBBB");
    $display("\033[37m                             x&X...    &&....   &&:                        \033[32m           rBBBr       BBBB    BBBU");
    $display("\033[37m                             :&$...    &&+...   &&:                        \033[32m           vBBB        .BBBB   :7i.");
    $display("\033[37m                              &&;...   &&$...   &&:                        \033[32m             .7  BBB7   iBBBg");
    $display("\033[37m                               && ...  X&&...   &&;                                         \033[32mdBBB.   5BBBr");
    $display("\033[37m                               .&&;..  ;&&x.    $&;.$&$x;                                   \033[32m ZBBBr  EBBBv     YBBBBQi");
    $display("\033[37m                               ;&&&+   .+xx;    ..  :+x&&&&&&&x                             \033[32m  iBBBBBBBBD     BBBBBBBBB.");
    $display("\033[37m                        +&&&&&&X;..             .          .X&&&&&x                         \033[32m    :LBBBr      vBBBi  5BBB");
    $display("\033[37m                    $&&&+..                                    .:$&&&&.                     \033[32m          ...   :BBB:   BBBu");
    $display("\033[37m                 $&&$.                                             .X&&&&.                  \033[32m         .BBBi   BBBB   iMBu");
    $display("\033[37m              ;&&&:                                               .   .$&&&                x\033[32m          BBBX   :BBBr");
    $display("\033[37m            x&&x.      .+&&&&&.                .x&$x+:                  .$&&X         $+  &x  ;&X   \033[32m  .BBBv  :BBBQ");
    $display("\033[37m          .&&;       .&&&:                      .:x$&&&&X                 .&&&        ;&     +&.    \033[32m   .BBBBBBBBB:");
    $display("\033[37m         $&&       .&&$.                             ..&&&$                 x&& x&&&X+.          X&x\033[32m     rBBBBB1.");
    $display("\033[37m        &&X       ;&&:                                   $&&x                $&x   .;x&&&&:                       ");
    $display("\033[37m      .&&;       ;&x                                      .&&&                &&:       .$&&$    ;&&.             ");
    $display("\033[37m      &&;       .&X                                         &&&.              :&$          $&&x                   ");
    $display("\033[37m     x&X       .X& .                                         &&&.              .            ;&&&  &&:             ");
    $display("\033[37m     &&         $x                                            &&.                            .&&&                 ");
    $display("\033[37m    :&&                                                       ;:                              :&&X                ");
    $display("\033[37m    x&X                 :&&&&&;                ;$&&X:                                          :&&.               ");
    $display("\033[37m    X&x .              :&&&  $&X              &&&  X&$                                          X&&               ");
    $display("\033[37m    x&X                x&&&&&&&$             :&&&&$&&&                                          .&&.              ");
    $display("\033[37m    .&&    \033[38;2;255;192;203m      ....\033[37m  .&&X:;&&+              &&&++;&&                                          .&&               ");
    $display("\033[37m     &&    \033[38;2;255;192;203m  .$&.x+..:\033[37m  ..+Xx.                 :&&&&+\033[38;2;255;192;203m  .;......    \033[37m                             .&&");
    $display("\033[37m     x&x   \033[38;2;255;192;203m .x&:;&x:&X&&.\033[37m              .             \033[38;2;255;192;203m .&X:&&.&&.:&.\033[37m                             :&&");
    $display("\033[37m     .&&:  \033[38;2;255;192;203m  x;.+X..+.;:.\033[37m         ..  &&.            \033[38;2;255;192;203m &X.;&:+&$ &&.\033[37m                             x&;");
    $display("\033[37m      :&&. \033[38;2;255;192;203m    .......   \033[37m         x&&&&&$++&$        \033[38;2;255;192;203m .... ......: \033[37m                             && ");
    $display("\033[37m       ;&&                          X&  .x.              \033[38;2;255;192;203m .... \033[37m                               .&&;                ");
    $display("\033[37m        .&&x                        .&&$X                                          ..         .x&&&               ");
    $display("\033[37m          x&&x..                                                                 :&&&&&+         +&X              ");
    $display("\033[37m            ;&&&:                                                                     x&&$XX;::x&&X               ");
    $display("\033[37m               &&&&&:.                                                              .X&x    +xx:                  ");
    $display("\033[37m                  ;&&&&&&&&$+.                                  :+x&$$X$&&&&&&&&&&&&&$                            ");
    $display("\033[37m                       .+X$&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$X+xXXXxxxx+;.                                   ");
    $display("----------------------------------------------------------------------------------------------------------------------"); 
    $display("                       Congratulations!                          ");
    $display("                You have passed all patterns!                     ");
    $display("                Your execution cycles = %5d cycles                ", total_latency);
    $display("                Your clock period = %.1f ns                       ", CYCLE);
    $display("                Total Latency = %.1f ns                          ", total_latency * CYCLE);
    $display("                Focus number = %5d, Exposure number = %5d, Average of Min and Max number = %5d           ", focus_num, exposure_num, PATNUM - focus_num - exposure_num);
    $display("----------------------------------------------------------------------------------------------------------------------"); 
    repeat (1) @(negedge clk);
    $finish;
end endtask


endmodule





//TA

// `ifdef DRAM_PAT1
//     `define DRAM_PAT "../00_TESTBED/DRAM/dram1.dat"
// `elsif DRAM_PAT2
//     `define DRAM_PAT "../00_TESTBED/DRAM/dram2.dat"
// `elsif DRAM_PAT3
//     `define DRAM_PAT "../00_TESTBED/DRAM/dram3.dat"
// `else
//     `define DRAM_PAT "../00_TESTBED/DRAM/dram1.dat"
// `endif

// `ifdef RTL
//     `define CYCLE_TIME 10.0
// `elsif GATE
//     `ifndef CYCLE_TIME
//         `define CYCLE_TIME 20.0
//     `endif
// `elsif POST
//     `ifndef CYCLE_TIME
//         `define CYCLE_TIME 20.0
//     `endif
// `else
//     `define CYCLE_TIME 20.0
// `endif

// `include "../00_TESTBED/pseudo_DRAM.v"

// module PATTERN(
//     // Input Signals
//     clk,
//     rst_n,
//     in_valid,
//     in_pic_no,
//     in_mode,
//     in_ratio_mode,
//     out_valid,
//     out_data
// );


// `protected
// TV:#dB/I+RF_UegY[)1_6AcbPEb//Jd3Va;KD++AO=2-gSTCb/.]-)7YCQ7#aHP[
// 191+EX[L9M,[T9Jb(GEF03HX+[>YD)J-@$
// `endprotected
// output reg        clk, rst_n;
// output reg        in_valid;

// output reg [3:0] in_pic_no;
// output reg [1:0] in_mode;
// output reg [1:0] in_ratio_mode;

// input out_valid;
// input [7:0] out_data;


// `protected
// ,1;dBNNeGAgeU7J(4P^0,EXGV]YXWMQfV>:6R6[]W)1_ZBWc4.9]7)QHI=9>SEU.
// C:[(YJ+Y07+fSca\5e[?S];?@VXGA:6A:JYdKCHW:EWJ/+OV4g+BD(=K3<d<-Sbg
// gWQM)?=c-A=.V>.cIf+FIZ;:)9-&6cfQ^\&]DXI8MT#bU674\3S&>U>QD/:;FK/?
// BRD<HTB74OU;?RF0_eRada&,Hg_>>^4&+D9Z5SGHbca_C;aW5M((S#(D;5R-S,J6
// I.c78VAZg6?:P\fcAYeE,f.C>^Wc5WXcNB9OWE8_OE\5dKPXI-GRdTEW^gD1(^c_
// 8IeR7MZNf:eI?508>PZg9;T.O/cbVg2C3Jf02>HW3a2?0dZDDbPPO7:>610fPIYc
// 87RJ\SE9W98Y#WH:8FeDFT@DR8D<7[,FP(Z4+S<G3e[Q9.cSRAb(DEUEIa<N6)cJ
// X]a\D[?KY@(R?-P/00@2:,_,\>=@c5Rb/8LD2]2gSQ8O?b2V]gX?Ec-]^D1)I6BU
// ]]VV6-.]=?DDf2M-dD,8NV9#Ad4aG3&c20EZ-&4aGJ;K:BcMG8f_R[gRcCU2?8O4
// R?;\54N6+e_G__@M44Z#N;[OX@6a]XQ7Mcc2g[NP.(1&4]M>QKJ_INV,J6)^R6KL
// [W9U_)MfNG1+/_D&^>-#K73RG>(Pd[1_5(M0]B.\J-UFUVgN-;.#BJ7U0;IU]>(a
// C=3f7WQ5^RdRB91FbU-5EW[>.GC3IW;CNZ3((Yc9DPdN<c<O^0<I,([#;0(W0Y7#
// 0;]FPb7BY&#OcD7)a;<[;O8bOEbV&29?L(4]:()P+&G8Id9#E;\9=+HJdW;fgH:b
// Y&2SV3a0G4c<VJ0\e7\O>ETS)A.&D=H[:PN7_).AN+UOWAY7;(R/FU2Zf][:80L#
// 1AbYS>>V<X5RI;:[-;6B7>8OeBW[38A(SXQTS21=^=XPIEC:Q2>EE01U#A^.X9VW
// ?EQXS06[D@;IHB_:.^<PfMQMa).7859Q23.2RE;QbYO_\c;97[O\3+=ae-[4NV)F
// (=@d:ab+\b2ZJ\WGX=FJddKeZK2D(6CcV+R9T2Hb@1bIG(4:(UC8F:eb-8PVa1dM
// L^@adH6:L99eC)#a4d79L.94M.UQ-OJWX6^bDTgIEN:dAWDI:-ege^Y59?@^G81)
// /g0/gS;7+/8O3aW)6_7SH?H\,,Sf7H#g]6<GRQ]GJ,,fC_=;>a,2S&1@KNCG(_Og
// V2cMY=3^@M5XW((B<7HP8MLGTP^78;45Ug^BK\ff>492^U.J]Mg?3H#Qc6a;74=L
// 20^=]RU[>64dHVfR1<40Of<f[/XMG_.Ff4bC-</:GQY,:<,[LQSGOI><BR^)8dEN
// fOOI_<+)JMaKU?A1f^GFJ(PC3YJ=fB\?K<N2(FE7#>:Icg[>^M8b5^FXJ?5HFL2@
// NK;W&I-8-^1#0R@eY)B&,OT:P\SI+_1IQ4#>b\_6XKLHX+RYXT\Y9fVB:A.TJe#Y
// &6:(KSZ_-IN,JXb;E+N#):CN[BgaQEf)[MS->7U:1,T\\@:UK:LLPU[XaVHgSPd/
// D1+Ag]X?.Z0MgcJ-\Y\8>,]eK@O:;]K=W=A4J;M(MX\LF>SVM&A/B8]F7#^=AZ?E
// 6::3PF3@1IPF4KRL=<I203bSOH2gJ6e6H,6Z^K#P.]Sf.6+C1_X/eXEfcD>f704.
// g])2PWEd?8=Le<<bLf>+>M&PPSDGbTL3eYB#67_QLeS-ae7A9,9S)b>5[4_2&EP)
// X7I0N&HGc(U^&CN1]?291fL2F\+fS:g4Vb#8Z=9-SaMXM7#]SS_QZ4NC5afXIcB(
// cCWfZEg_F&/FJ,d^85^RZ1A41;R#].MHHEJ#MG?HXg&]7P)<&gC46;ZI4#cg\dE,
// a4d>?_d^QCJF99^Q;MLP7ZY3)4-Xg.D0+ScT51N..S_9:&<ZZCJ4c8a8Y9?ZB5J[
// G,50d.^^\/9?.J<(@JXc&e1eK9N;.6YIZdeXVEUOYaU+,^-<]cG-9I9bO6MbZ2aO
// LPAZ</QSBV6<491S,><\9SeOS+VWZV9.<KeCP9V120[Y)SKgW6Jcb<@I0C1>bdbL
// gb6M9gQ(d.-W4L([)C4@@(5&\/92U\fV]Vg2e+Fa_TSH0F10f)I5&LOF<PQ+BDV[
// I>5&UeAZUFRWI2fbNgV)HAX8#+\GRP-3/\C\+)M#0ZCP\=XE-(0T##(WBIB0S^e.
// OJ5MM]HXILOX6NVNO3FIa^RSDQE[]SV?IgLV<gOEgUG&ZO[@Q>&c)US8](2=1cDe
// 5dZfL\de\g]aOX/G&X\HHU[;b__,P<T_SD87dROWcC?#DK2\F.\AgP0@[GC)XTfS
// JE:_BNE/P35a+Z0S?(eWL&RW52?LA)6:=@(+/7@(77;/(MG;?9(Ta];-5:WZ2EGN
// Y=^_V\c;9_AdBeO]VMf/9MA)9c2V/6KX)0>I-@YWeJ6<BDLWIT:ECCe#MIWLA][I
// BG/+\Lc#XE=@/B)CGT=I211)3LOP72AI]8<<FL[S@Vf-/M,2U0S.K^:ISJ;cEQ2>
// &_KF/D=7?C2F3V?YHG^LND0C&4<_?cS/:D=J#V4\W>__dA>PVd]:EH64d+_b[bfJ
// +c?VX7Cc#XDJ0cURXU3W=/g:\EFLD(Y3+\2&g6gd;2&?S/gbCVFd[\Y,bJI?LXJN
// XeV9((;7g&5,>5/,Hfd8T\?QQ/9L+8Xd1)ae2_0a]@GKI9eR0O,&S7WHg8e16Z-N
// .K5C]^@9EO.7AK/=;+A;M]NN_E(@O6eg,@LDCS_-?#5R9^OX5R?5eaa-5;&ZJ;,?
// 2V2Z;g.PLMI_4F0O:aUGSYRcGV3aT_&O,+EGXX?B_9CE#MDYc^YL\DVN+FVcObK4
// LXDI&>geJ#Lef2a+1U#XZ(=RIJYWLg8&<A<=_]<S=:b9D;7K6,[-RI7#)>/T[7R3
// -;G(gS^Oc_ed/;#>,79Q4]>T7=M=?W>U,+,\-(<GAUIg@:,2XW7J=L.YO(DFeTMc
// .GC4P/b6.a_.UfWQ-D1]Z12)O;\R)DC8S&4^I_=EP:#c3H,LTO]da):)Bb5P/4^c
// KX.+^A@E1aM;?]85g<LOKLb90EMF@3K-\YN1/\3@S_-<F1c>gK(5FfQ^c8O[=CH7
// ^Ge\XHO?(:@H7a(gF,6:AaMe&9_6QEL)0cV_&/(0JC5I1HU[E^J;aRaK6I,b<^DB
// +bRaE2U23b,]>6]7[]fG)+[d52RfTg7X6:I[91=b,<2X?[G?R6#^18/+B)#Z99FI
// 8F#.&?ZLM9dNf:[9-B3:@6gS\DI<cPd3#Sc]Q)G[]^+RHga]@KcC[(WPCFZe6Re8
// I)Sc-=Ra1/Yed1CVAD0./-:DdSSJeO91B_,5U__e-\EW;.a4M).gXY\4[A_>.^M4
// aZ..I;LVOM>Y5&&IO#;78PL0R_&3\AWd53BaW?VDe6QIK:?D.AGd:;&UTL7K0Mg;
// E8)Qg:-)BXB;PH=QdOX;;QQ-DNO-M[VBCO6YEXIL2-e8ZB_SRN:3BZdGF,?+Q/bM
// -D)\TO4&A_B(T=@S@19I4aJ#U<F2\6>Y<LJ4M5829&gf9UPdZS73HYYQ?-b^+IX)
// MV^8RP:&M.;Y]Y/#:7[3ML,26ecRcWVSC5(Q#FF4C]E2,<9ge.8G\d4GW6@e6K#Y
// f?b=LL@a#EPEQKUgT/?SHQdbZ(e>218(KOPNN)G9\bM:dRZ4>-PgMMc,/LL+UNPO
// 1;EXdM:GIGXBed@?aT10eEX(XCA35EL[d?HHT)6H#]/Y6=O-P]cLEOAX+>)5[LeM
// ;5NNW7a;=)YC#444USS4\dWUKgQd2e8fO>cfI3.=&cVB8O]^84dcNTGYASDF+VP-
// T)@(cIHJe^45Y?>&2^4Z,-U.gc^KZ3Q)fd9c?eeV--_VFE_AK#Z3d^Te:[JE(ScW
// WRE0ZPb7;.?dU1(J#+cPW\1MUQ;XKE,UYa1&78:P4>^5]DVLaOXF^gIE4+>4)Z7M
// XY)M&eS(W,YS,WH0+BI?df@7)7+e_DH^GIF;UdM=.cYD6a<)..._<]IZCE2=G3(S
// =\/]UQaV0F5D66]BW=RDKHd,,YBD_/XTc(YQOP>P8B9BA4WJYC^9BF2HfO3aaKaI
// bfW0_Md[Z26/F1:IF8Eg5_P:8.+S[D>?]^d7R3JAYW,XG3]/[e5_L74Z,.K(OZ8f
// K4(Y0?f_S\1d6LL7PE?1K<:CQPFcC,9T\,-M9+c@\O6>]\Pb_VYJ-[\IRGd=E?9Q
// )OEbS>UW@+DE+)J<5&5CJc68>T(CB4.>FYM[Pf(f<B>4eDX,,ZV6S/ODgCJ.#>29
// ./ZHU,#6C:K@OGaQDN8@&HA(I.BXO/E,1,8(?_gYF?BW\A9Z1FV>/DZRURA5(L>A
// 8WGAJDEI6^XOJO79Oe>=Xg0@eGI?LcPN;gKV(L0/(bH3I&<>VB6(MTa)K-R(P0@c
// BeO@LI=T)K3#_YDDD81IeHY@\O>=M\\K[_<]_g;QF(8&?S@C\WI]GV1_1LD6Z&66
// K-:fdQ=/FF^,2B;E0-ZFbY)TacX&>OY;-E+gAW-[@[gX>^_]d>@WNZCTc:O\E,Z)
// F6-)9;)J1LaXU]V\@LY#JPA-+[9&:-b6\X::;VcLcX:0Ze<,>dU4Sc4_Z(8+g2=K
// X9W6CaZ\O#UMNS3Q.U;bc/E8bYJPAN)?OA&1A3U@63_,&Hg193UU/R-6,^gS^J0E
// fbNE(fLWde@b5eQ_;AN>OJ5>(<LX<4fC<MN4DJ@RDbc_\SDTP_76_ZK,Yf1#(Z5C
// ._E1#?KXAagA)D/gUHZ0MQI-e0F#)gML)c#Fd]4W21+FAWZC+XV]V3L^GZKG:5GL
// C5?)>I;&WbV+\0d:X5AI9WFcSf&AfMQJ?FXb5S/7G.:V^f0[5EUZYPF;DLG,QA\e
// b+1PQ<a0B_>\BfUgERf-0\Y.H:/IIU75X.WUcfR_<9)BHT2S4TgFJLeg7[(?Q9ML
// -(?69&AX_fH,]gSJd#(5SW.f144=5RQ8V.1#1YZM<^ONZP,V(;41:6=BO@;M)N&Q
// YGHBW2O+C[,ZU5If_ReLb\GP^OT[F&4#DH,KL5E7=TKG_QQ(XCKQ(/]\Lf),[^e(
// ;JKDOB<XUMR[aeH8\6IG2G9O_3L/#9MEN5V2G]5HYTRT<6DR=cFaa..Ta)LPCWb6
// \8JJb#Z0M#7CR?7@Z6Q+IeQ9N0acPZ+#X6d?aT):9(<+^6Ba1^e)BdYd:JXe-#f3
// <WWE5\R8),1XZX2D3Z@8NW5\^II\HNT1EdGbQ)DOJ4[#8Q^@b]>>G2\DM^]c12?.
// +fUXR0]@W3E0XJO7T5Q+#,9aA?3#;E#YS81WV\/4K99-Jd)J_bH\e@:/OYPTe<Q/
// E,SN)WLVGJ,\9>/XR;6PVHLMaN0>a32QO)dU,6-]ZP@X[]8-g./,f9K4BKL1<D+D
// 0bC4]Q+fFDfgc33.>Q7(bI\U#g>2gGS^@@6B+BGS[##]&JfE32(ef^?=a1EeP7/G
// gb0Ya7)a/d29-9#T\/aD/7KF]ZgfG;TTT7XVfPef(7e;MAd8EKgL0@b&/(Xg9Nc8
// +@Rg+7<0IJO&b&W^,-gPCdUefA^N>GA7Y<VD2Q)^<=G/.d:.HcTf#)C@GG>C@(,=
// Ee-:e+.,ZFX-)D;:I.[(6HQTR@6\@c10I8PBB(:0ID5d5RTA]\K0:0@;LC2[1)8f
// XA2W?JFc@PK1(5&N_?L<-\A)UcHe]M6TbMEMfOR,(0N:cHL7ZbF<R]+^<EZRG-]W
// 6SYgLE.]SDJJP7^48U7ZAAeIf:(dOS/A(Y#;)^&HOX?<BBQNJ&>PS>;U:]?0??>f
// E@/efF.OR[(5K36accR9VBGW<.;/&OCI36H7RF2+W7DZ1I5B\6V0aQ[C7HgCRBD/
// (febA1\33>YCa:NKJ+?;6Ge3A^8.WLHO3YO-fFY):W/T;@5#\dLCGa(a<50#[G@5
// ;LBaXZcW=c2XF&dJI;/+?7GaB?S9,Ug7b:J2+>JF-18[8_E)Ra>S@c?G@150C=KS
// MVeOJXXVETG2@GbH.US.?g+3&7,=NJV<ULW:<dNF4N?L/BT.CU5\NIPFQPEJ.&YI
// &3b?1[IbVL8DI.Je6ZaS,_J6\4]B6KR2J@\<HAT^G;T6UXCWeX49/1fSO-RJKW0f
// :E.^&4Z33DEV51P2D)eMgEN1HC3(,-IW9)\[D6eg(]C^,W07-98a&)^@IC+-_ZZD
// GXW\_\B8dA]&O]<#@^LC2BaWNYN4F+f/J(0)JDQM<UK1c\:HFPN/HY2)#O&.,A0-
// &Q8\H-1OH>[3CRQVCUIM,7KR??.[]YH-)aR^P_>7=HI>SEAL08ZSCg7PNdZgFQYP
// 8F&HWEKe\J+T,CaS_9ObaQTB+N7Af^#9U=KTT+Yd?4(H6X0:-UFC4ZCJ5IY+3U9Q
// bK6U8).N7gDKK;Z6J@2YY07QI[LZQJGW9[]_adG0)):FIf2?Ub,?-&@OHSJ?;eTW
// _11;fgHA/UOC8>8.+L?DG#9O2W,^&f4;,6Xd0@&+=-?5=Y0P1V:<#-C6d/UN-@e(
// 4bBWeMAb/Y])GZaJL>P[G^714G=TL)/(f<;69L>2T+^._:YU2>&81X7QDF9A2CB4
// a-NgH-IV?1gPVe3ORTM6/U3-6=Y);IS.069&C)K(Ced=A[#LbU/W>Y+9[J1e>O6J
// R.G0Z@13gW=J?)(U+)<70QF<_\H>1Q#b]f^NUJ&:gSO_&)@S5A3Wg3UI7CBE[@P&
// _TR4e4Q&B?b7[RE4SR>944^9Y.7Y;/OJFV;\:/7De8(Q/2#L^)#)2[KdZI[TN[Z>
// BW5cG<^cI++^WF#Z.0J7]_EQUHD92c\J4\dL#08gMEW][J^?G3(-9G(_[]:A\1[E
// 7T,cQ?Ya>F>becH^9Q[PU)U)fJ.O_Pe7#[YcA\?RG8[IRYQDB,J0JPA6b3^^Zd[:
// &Yc=;[(V>[Q;DW\HO,<d8a^3C;A_4>^UF;cbVI=HP:(\>bLb2d0+#O\VeQgBPB=J
// TT&K0>FE.\e0RY#F+H4K0DfJe[CR<40X)QP@8@+QdG7#RdM1UK-O;fP>=PBY<=eE
// K::aJXTDBS-2cG(K70PZ/R:A6W.&?K/)@@LXb<(JW0PO1J>fcUTe5\/Ge]V7ZO=,
// a?Y6&<bZ+;\[5-.H-KdB9b/<Z>a>HCFB9g[2b](^JQ)^J2Ibe+H30E)(^,]PU_4B
// ;).2/K7RI@&E[JZF.^F@16@<93QaB;5dMU>[9^1]7O;-LTdd)/6=H9?0LV:7?+2_
// EL6Q9-P07JK_R5bQZ,S^N^eWUgD4PN,V7g(LP+1fbF/LU\VgX[=CI?+a8R\B_I_O
// /dB15N8X2eOGeSO,GTKb)Z9ESSPF.C/+C9=VF[[Y<9=fZ6[6MKd2\]IW#_)dbI6b
// BIeCfX.JTP,=(8=R4dLK=G9P5NcRCfdTMdZ7G1=-THQSJMPIb>cI[_^eXa6W<9,F
// ;I:5D?U0(b0[?8cQH#SNc]L+/S[@N4GGGAJ)FYdXb7OO;59LFMF<OIZ8/Sb:Ta4H
// X3/U1OPB\2bc]>-C\gT)YS5@<GSJef/EWeQ6N94e&[KXDI<1C->E3@,F1_0&&H2[
// b4/+c#dCQ5R8,Yf:=8X:.3@I4eD-;?B3Pe1+Q3c-Jf>0SQQX<+IbG0N7[A\4gW-U
// TJ9N:f?g)1X9<_&[MT]d-JeKU3<g,g,MUVN48\#?>+I;FL+#7D@[5YTKVea^4H^J
// \+e;0H)Ce12bK-]N&Y^2cU:DD;N]2;UN>/F]:XZP,@=e^6<e??gY=B,^GC:+fPLL
// eFJ&aDXTC9S?<g<gA_UKV;g>?M_Q4PAFLfeXWfM2#JYE84U+c7VQ3+_ffMLEScS7
// [FXc#7B;c>>J?JQg(OOE-E&JD/5/\25#>g;,2d18#7,))..ZGc091P7]#C96#O:0
// aENGZU<7M_BA):)&CY0:B-2DN#B,?NV]X6@Y]Q^,Y?[>54@+<YLA76@1X[7Jd9_P
// M+g;fO,)Fa-(a6;.\<SSBEP]22:SIF-4^4ePJ3Fa/8g@>^^U=eOQHSW7V4gR1WJX
// -e:c>FWX&<52(SP.9[:PcLBgB^D36VV?&<P_,d=IO+d>]Y&Y;.S168ZQQLB]Aa.:
// /)IK8;GWIJ2.GL-T5)H1()AWQIRb+(+GHQKM4fKATPXe+@ZU2DHNN<LY5CCcQJ5#
// 9dGG8/):db\O<]]7=-:V\M:;:]LYe=1@L_-4F^,ZN7D<Jed8NSN6Y>N3&A<77Vg1
// [ZL=WLOQ;@R;)DZ&BVL6Ee9d?FO&HWFC/.66M[]g^;+<25dB&]_K2f(7(L2JF9VV
// ^#9:<d;AG72Qa<Y-?&K_Se<d&&:g=6@Z+LbWAG0(K#H\J51XKWX]JVJ#Y7194F77
// d\CHZ;E_6R)NC0c7WE8U<K[_DU3G]VDVIVZNX=YIe;8(PcMW=c0]_=>HMOe^I7N\
// _<[L53@\eJPL[@DWc>V]Pb)=-)?/2@.Z3Z;S)cT49/KYDNJ0NKCRP7A4b/2_S@JH
// ^/?K]]+IDYK2fafJDS9(]LG9I?eNbagB+[6&_RYJAG:eRJ;Y@dP(3Tb&>^^G/@KB
// 62a94:-P3e>(OOG/VF(#cKAV&c>L<GFg5,NL/VFCcYLP3^P#4M7K<E0[^Z&P5He#
// 018a69\[MG;PWC-JE/U-2_MM,^Xd#(=JE;QM\)<=JZeJ_L.Q-QIG?5G0BU/96:,B
// =XaMgAE->@:8Y+/8:2BbeYC-[^fVQIA9JY8&,0J9OBDRR3BLRD.?HB\3P58Pd@21
// Te)D_:1A1E0Q2>)P2A_A\\B96<K_b1#+aWYUB)1&CJGCXM9<PP(U#RHeGE,2XZ>0
// <0fbBQL6R\Q)d<#>V.d<=Uga>P>##ZR+Z#<M-U:eQd+cZDa=&6XPG-ZMRGgP?4[A
// aWK9OCD3gaI]\LUB@.>5/6G8U,?=_L#>LYNUQ/F1I.V)R:)V(OfgfB_NAGLf;ZAH
// >dL,F=M1X44U.HKY>ReT5[HA@0P&0[&C#-(FbK0F4Z=IE?VX@FfVJ]_LW=PFH6F-
// d9Qg;?bI+2G0,JZA&TT[c\XN0J1f.W.8</^THU,L]^B-1&E=>U;f/<DX1(7f1WU,
// ,H5PUWL5VBcSGVU?b/+@&72[/&UO]89.A#Hf-(4