module Program(input clk, INF.Program_inf inf);
import usertype::*;

//design state
// localparam IDLE = 0;
// localparam GET_IPUT_INDEX_CHECK = 1;
// localparam GET_IPUT_UPDATE = 2;
// localparam GET_IPUT_CHECK_VALID_DATE = 3;
// localparam WAIT_DATA = 4;
// localparam CAL_IPUT_INDEX_CHECK= 5;
// localparam CAL_IPUT_UPDATE = 6;
// localparam CAL_IPUT_CHECK_VALID_DATE = 7;
// localparam OUTPUT = 8;


//DRAM state
// localparam DRAM_IDLE = 0;
// localparam DRAM_READ_ADDR = 1;
// localparam DRAM_READ_DATA = 2;
// localparam DRAM_WAIT = 3;
// localparam DRAM_WRITE_ADDR = 4;
// localparam DRAM_WRITE_DATA = 5;


STATE state;
DRAM_STATE dram_state;

Action act;
Formula_Type formula;
Mode mode;
Month month;
Day day;
Data_No data_no;
// Index Index_A, Index_B, Index_C, Index_D;
// All_index pattern_index;//{Index_A, Index_B, Index_C, Index_D}
Index pattern_index [0:3];
Index dram_index [0:3];

Index Pattern_Index_A, Pattern_Index_B, Pattern_Index_C, Pattern_Index_D;
Index Dram_Index_A, Dram_Index_B, Dram_Index_C, Dram_Index_D;
Month dram_month;
Day   dram_day;

logic [1:0] index_cnt;
logic [2:0] cal_cnt;

assign Pattern_Index_A = pattern_index[0];
assign Pattern_Index_B = pattern_index[1];
assign Pattern_Index_C = pattern_index[2];
assign Pattern_Index_D = pattern_index[3];

assign Dram_Index_A = dram_index[0];
assign Dram_Index_B = dram_index[1];
assign Dram_Index_C = dram_index[2];
assign Dram_Index_D = dram_index[3];


integer i, j, k;


logic [12:0] add12_in0 [0:3];
logic [12:0] add12_in1 [0:3];
logic [13:0] add12_out [0:3];

logic [13:0] add12_out_reg [0:3];

logic [3:0] exceed_flag;
logic [3:0] below_flag;

logic [11:0] refresh_index [0:3];

logic [11:0] sort4_in [0:3];
logic [11:0] sort4_out [0:3];

logic [11:0] sort_reg [0:3];

logic [11:0] div_out, div_out_reg;

SORT4_MAX_and_MIN JJJ(.clk(clk), .in0(sort4_in[0]), .in1(sort4_in[1]), .in2(sort4_in[2]), .in3(sort4_in[3]), .out0(sort4_out[0]), .out1(sort4_out[1]), .out2(sort4_out[2]), .out3(sort4_out[3]));

logic [11:0] cmp_G_out [0:3]; 
logic [3:0] cmp_G_out_reg;


assign div_out = add12_out_reg[1] / 3;
always_ff @(posedge clk) begin
    div_out_reg <= div_out;
end

assign cmp_G_out[0] = (dram_index[0] >= pattern_index[0]) ? 1 : 0;
assign cmp_G_out[1] = (dram_index[1] >= pattern_index[1]) ? 1 : 0;
assign cmp_G_out[2] = (dram_index[2] >= pattern_index[2]) ? 1 : 0;
assign cmp_G_out[3] = (dram_index[3] >= pattern_index[3]) ? 1 : 0;


always_ff @(posedge clk) begin
    cmp_G_out_reg[0] <= cmp_G_out[0];
    cmp_G_out_reg[1] <= cmp_G_out[1];
    cmp_G_out_reg[2] <= cmp_G_out[2];
    cmp_G_out_reg[3] <= cmp_G_out[3];
end

always_ff @(posedge clk) begin
    sort_reg[0] <= sort4_out[0];
    sort_reg[1] <= sort4_out[1];
    sort_reg[2] <= sort4_out[2];
    sort_reg[3] <= sort4_out[3];
end

always_comb begin
    // sort4_in[0] = 0;
    // sort4_in[1] = 0;
    // sort4_in[2] = 0;
    // sort4_in[3] = 0;
    case(formula)
        Formula_B, Formula_C:begin
            sort4_in[0] = dram_index[0];
            sort4_in[1] = dram_index[1];
            sort4_in[2] = dram_index[2];
            sort4_in[3] = dram_index[3];
        end
        // Formula_G, Formula_F:begin
        //     sort4_in[0] = add12_out_reg[0];
        //     sort4_in[1] = add12_out_reg[1];
        //     sort4_in[2] = add12_out_reg[2];
        //     sort4_in[3] = add12_out_reg[3];
        // end
        default:begin
            sort4_in[0] = add12_out_reg[0];
            sort4_in[1] = add12_out_reg[1];
            sort4_in[2] = add12_out_reg[2];
            sort4_in[3] = add12_out_reg[3];
        end
    endcase
end

always_comb begin
    for(i=0; i<4; i++) begin
        exceed_flag[i] = ((add12_out_reg[i][12]) && pattern_index[i][11] == 1'b0) ? 1 : 0;
        below_flag[i]  = ((add12_out_reg[i][12]) && pattern_index[i][11] == 1'b1) ? 1 : 0;
    end
end


always_comb begin
    refresh_index[0] = (exceed_flag[0] == 1'b1) ? 12'hFFF : (below_flag[0] == 1'b1) ? 12'h000 : add12_out_reg[0][11:0];
    refresh_index[1] = (exceed_flag[1] == 1'b1) ? 12'hFFF : (below_flag[1] == 1'b1) ? 12'h000 : add12_out_reg[1][11:0];
    refresh_index[2] = (exceed_flag[2] == 1'b1) ? 12'hFFF : (below_flag[2] == 1'b1) ? 12'h000 : add12_out_reg[2][11:0];
    refresh_index[3] = (exceed_flag[3] == 1'b1) ? 12'hFFF : (below_flag[3] == 1'b1) ? 12'h000 : add12_out_reg[3][11:0];
end

always_ff @(posedge clk) begin
    add12_out_reg[0] <= add12_out[0];
    add12_out_reg[1] <= add12_out[1];
    add12_out_reg[2] <= add12_out[2];
    add12_out_reg[3] <= add12_out[3];
end

always_comb begin
    add12_out[0] = add12_in0[0] + add12_in1[0];
    add12_out[1] = add12_in0[1] + add12_in1[1];
    add12_out[2] = add12_in0[2] + add12_in1[2];
    add12_out[3] = add12_in0[3] + add12_in1[3];
end


always_comb begin
    for(j=0; j<4; j++) begin
        add12_in0[j] = 0;
    end
    case(act)
        Index_Check:begin
            case(formula)
                Formula_A: begin
                    add12_in0[0] = dram_index[0];
                    add12_in0[1] = dram_index[2];
                    add12_in0[2] = add12_out_reg[0];//14bit adder
                end
                Formula_B: begin
                    add12_in0[0] = sort_reg[0];
                end
                // Formula_C: begin
                    
                // end
                // Formula_D: begin
                    
                // end
                Formula_E: begin
                    add12_in0[0] = dram_index[0];
                    add12_in0[1] = dram_index[1];
                    add12_in0[2] = dram_index[2];
                    add12_in0[3] = dram_index[3];
                end
                Formula_F: begin
                    case(cal_cnt)
                        0,1,2,3:begin
                            add12_in0[0] = (cmp_G_out_reg[0]) ? dram_index[0] : pattern_index[0];
                            add12_in0[1] = (cmp_G_out_reg[1]) ? dram_index[1] : pattern_index[1];
                            add12_in0[2] = (cmp_G_out_reg[2]) ? dram_index[2] : pattern_index[2];
                            add12_in0[3] = (cmp_G_out_reg[3]) ? dram_index[3] : pattern_index[3];
                        end
                        4: begin
                            add12_in0[0] = sort_reg[1];
                        end
                        5:begin
                            add12_in0[1] = sort_reg[3];
                        end
                    endcase
                    // add12_in0[0] = sort_reg[2];
                    // add12_in0[1] = sort_reg[4];
                end
                Formula_G: begin
                    case(cal_cnt)
                        0,1,2,3: begin
                            add12_in0[0] = (cmp_G_out_reg[0]) ? dram_index[0] : pattern_index[0];
                            add12_in0[1] = (cmp_G_out_reg[1]) ? dram_index[1] : pattern_index[1];
                            add12_in0[2] = (cmp_G_out_reg[2]) ? dram_index[2] : pattern_index[2];
                            add12_in0[3] = (cmp_G_out_reg[3]) ? dram_index[3] : pattern_index[3];
                        end
                        4: begin
                            add12_in0[0] = sort_reg[1][11:0] >> 2;
                        end
                        5:begin
                            add12_in0[1] = sort_reg[3][11:0] >> 1;
                        end
                    endcase
                    // add12_in0[0] = sort_reg[2] >> 1;
                    // add12_in0[1] = sort_reg[4] >> 2;
                end
                Formula_H: begin
                    case(cal_cnt)
                        0,1: begin
                            add12_in0[0] = (cmp_G_out_reg[0]) ? dram_index[0] : pattern_index[0];
                            add12_in0[1] = (cmp_G_out_reg[1]) ? dram_index[1] : pattern_index[1];
                            add12_in0[2] = (cmp_G_out_reg[2]) ? dram_index[2] : pattern_index[2];
                            add12_in0[3] = (cmp_G_out_reg[3]) ? dram_index[3] : pattern_index[3];
                        end
                        2: begin
                            add12_in0[0] = add12_out_reg[0];
                            add12_in0[1] = add12_out_reg[2];
                        end
                        3:begin
                            add12_in0[1] = add12_out_reg[0];
                        end
                    endcase
                end    
            endcase
        end
        Update: begin
            for(j=0; j<4; j++) begin
                add12_in0[j] = dram_index[j];
            end
        end
    endcase
end

logic [12:0] sub_abs_in0 [0:3];
logic [12:0] sub_abs_in1 [0:3];

// assign sub_abs_in0[0] = (cmp_G_out[0]) ? ~pattern_index[0] + 1 : ~dram_index[0] + 1;
// assign sub_abs_in0[1] = (cmp_G_out[1]) ? ~pattern_index[1] + 1 : ~dram_index[1] + 1;
// assign sub_abs_in0[2] = (cmp_G_out[2]) ? ~pattern_index[2] + 1 : ~dram_index[2] + 1;
// assign sub_abs_in0[3] = (cmp_G_out[3]) ? ~pattern_index[3] + 1 : ~dram_index[3] + 1;

// assign sub_abs_in1[0] = (cmp_G_out[0]) ? dram_index[0] : pattern_index[0];
// assign sub_abs_in1[1] = (cmp_G_out[1]) ? dram_index[1] : pattern_index[1];
// assign sub_abs_in1[2] = (cmp_G_out[2]) ? dram_index[2] : pattern_index[2];
// assign sub_abs_in1[3] = (cmp_G_out[3]) ? dram_index[3] : pattern_index[3];




always_comb begin
    for(k=0; k<4; k++) begin
        add12_in1[k] = 0;
    end
    case(act)
        Index_Check:begin
            case(formula)
                Formula_A: begin
                    add12_in1[0] = dram_index[1];
                    add12_in1[1] = dram_index[3];
                    add12_in1[2] = add12_out_reg[1];//14bit adder
                end
                Formula_B: begin
                    add12_in1[0] = ~sort_reg[3] + 1;
                end
                // Formula_C: begin
                    
                // end
                // Formula_D: begin
                    
                // end
                Formula_E: begin
                    add12_in1[0] = ~pattern_index[0] + 1;
                    add12_in1[1] = ~pattern_index[1] + 1;
                    add12_in1[2] = ~pattern_index[2] + 1;
                    add12_in1[3] = ~pattern_index[3] + 1;
                    
                end
                Formula_F: begin
                    case(cal_cnt)
                        0,1,2,3:begin
                            add12_in1[0] = (cmp_G_out_reg[0]) ? ~pattern_index[0] + 1 : ~dram_index[0] + 1;
                            add12_in1[1] = (cmp_G_out_reg[1]) ? ~pattern_index[1] + 1 : ~dram_index[1] + 1;
                            add12_in1[2] = (cmp_G_out_reg[2]) ? ~pattern_index[2] + 1 : ~dram_index[2] + 1;
                            add12_in1[3] = (cmp_G_out_reg[3]) ? ~pattern_index[3] + 1 : ~dram_index[3] + 1;
                        end
                        4: begin
                            add12_in1[0] = sort_reg[2];
                        end
                        5:begin
                            add12_in1[1] = add12_out_reg[0];
                        end
                    endcase
                end
                Formula_G: begin
                    case(cal_cnt)
                        0,1,2,3: begin
                            add12_in1[0] = (cmp_G_out_reg[0]) ? ~pattern_index[0] + 1 : ~dram_index[0] + 1;
                            add12_in1[1] = (cmp_G_out_reg[1]) ? ~pattern_index[1] + 1 : ~dram_index[1] + 1;
                            add12_in1[2] = (cmp_G_out_reg[2]) ? ~pattern_index[2] + 1 : ~dram_index[2] + 1;
                            add12_in1[3] = (cmp_G_out_reg[3]) ? ~pattern_index[3] + 1 : ~dram_index[3] + 1;
                        end
                        4: begin
                            add12_in1[0] = sort_reg[2][11:0] >> 2;
                            
                        end
                        5:begin
                            add12_in1[1] = add12_out_reg[0];
                        end
                    endcase
                    // add12_in1[0] = sort_reg[3] >> 2;
                    // add12_in1[1] = add12_out_reg[0];
                end
                Formula_H: begin
                    case(cal_cnt)
                        0,1: begin
                            add12_in1[0] = (cmp_G_out_reg[0]) ? ~pattern_index[0] + 1 : ~dram_index[0] + 1;
                            add12_in1[1] = (cmp_G_out_reg[1]) ? ~pattern_index[1] + 1 : ~dram_index[1] + 1;
                            add12_in1[2] = (cmp_G_out_reg[2]) ? ~pattern_index[2] + 1 : ~dram_index[2] + 1;
                            add12_in1[3] = (cmp_G_out_reg[3]) ? ~pattern_index[3] + 1 : ~dram_index[3] + 1;
                        end
                        2: begin
                            add12_in1[0] = add12_out_reg[1][11:0];
                            add12_in1[1] = add12_out_reg[3][11:0];
                        end
                        3:begin
                            add12_in1[1] = add12_out_reg[1];
                        end
                    endcase
                end    
            endcase
        end
        Update: begin
            for(k=0; k<4; k++) begin
                add12_in1[k] = $signed(pattern_index[k]);
            end
        end
    endcase
end

logic [11:0] R, R_reg;
always_ff @(posedge clk) begin
    R_reg <= R;
end


always_comb begin
    case(formula)
        Formula_A: begin
            R = add12_out_reg[2] >> 2;
        end
        Formula_B: begin
            R = add12_out_reg[0];
        end
        Formula_C: begin
            R = sort_reg[3];
        end
        Formula_D: begin
            R = (dram_index[0][11] || &dram_index[0][10:0]) + (dram_index[1][11] || &dram_index[1][10:0]) + (dram_index[2][11] || &dram_index[2][10:0]) + (dram_index[3][11] || &dram_index[3][10:0]);
        end
        Formula_E: begin
            R = (add12_out_reg[0][12] != 1) + (add12_out_reg[1][12] != 1) + (add12_out_reg[2][12] != 1) + (add12_out_reg[3][12] != 1);
        end
        Formula_F: begin
            R = div_out_reg;
        end
        Formula_G: begin
            R = add12_out_reg[1];
        end
        Formula_H: begin
            R = add12_out_reg[1] >> 2;
        end
    endcase
end


logic [11:0] threadhold;
logic risk_warning_flag;

always_comb begin
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
end




logic time_to_check_risk;
always_comb begin
    time_to_check_risk = 0;
    case(formula)
        Formula_A:time_to_check_risk = (cal_cnt == 2) ? 1 : 0; 
        Formula_B:time_to_check_risk = (cal_cnt == 3) ? 1 : 0; 
        Formula_C:time_to_check_risk = (cal_cnt == 2) ? 1 : 0; 
        Formula_D:time_to_check_risk = (cal_cnt == 1) ? 1 : 0; 
        Formula_E:time_to_check_risk = (cal_cnt == 1) ? 1 : 0; 
        Formula_F:time_to_check_risk = (cal_cnt == 7) ? 1 : 0; 
        Formula_G:time_to_check_risk = (cal_cnt == 6) ? 1 : 0; 
        Formula_H:time_to_check_risk = (cal_cnt == 4) ? 1 : 0; 
    endcase
end


assign risk_warning_flag = (R >= threadhold && time_to_check_risk) ? 1 : 0;



logic date_warning_flag;
assign date_warning_flag = ((state == CAL_IPUT_INDEX_CHECK || state == CAL_IPUT_CHECK_VALID_DATE) &&((month < dram_month) || ((month == dram_month) && (day < dram_day)))) ? 1 : 0;










always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cal_cnt <= 0;
    else begin
        case(state)
            CAL_IPUT_UPDATE, CAL_IPUT_INDEX_CHECK, CAL_IPUT_CHECK_VALID_DATE: begin
                cal_cnt <= cal_cnt + 1;
            end 
            IDLE: cal_cnt <= 0;
        endcase
    end
end




always_ff @( posedge clk or negedge inf.rst_n ) begin : design_state
    if(!inf.rst_n) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                if(inf.sel_action_valid) begin
                    case(inf.D.d_act[0])
                        Index_Check: begin
                            state <= GET_IPUT_INDEX_CHECK;
                        end
                        Update: begin
                            state <= GET_IPUT_UPDATE;
                        end
                        Check_Valid_Date: begin
                            state <= GET_IPUT_CHECK_VALID_DATE;
                        end
                    endcase
                end
            end
            GET_IPUT_UPDATE, GET_IPUT_INDEX_CHECK: begin
                if(inf.index_valid == 1'b1 && index_cnt == 3) state <= WAIT_DATA;
            end
            GET_IPUT_CHECK_VALID_DATE: begin
                if(inf.date_valid == 1'b1) state <= WAIT_DATA;
            end
            WAIT_DATA: if(dram_state == DRAM_WAIT) begin
                case(act)
                    Index_Check: state <= CAL_IPUT_INDEX_CHECK;
                    Update: state <= CAL_IPUT_UPDATE;
                    Check_Valid_Date: state <= CAL_IPUT_CHECK_VALID_DATE;
                endcase
            end
            CAL_IPUT_CHECK_VALID_DATE: begin
                if(date_warning_flag) state <= DATE_WARNING_OUT;
                else state <= NO_WARNING_OUT;
            end
            CAL_IPUT_UPDATE: begin
                // if(|exceed_flag || |below_flag) state <= DATA_WARNING_OUT;
                // else if(dram_state == DRAM_WRITE_RESPONSE && inf.B_VALID == 1'b1) state <= NO_WARNING_OUT;
                
                if(dram_state == DRAM_WRITE_RESPONSE && inf.B_VALID == 1'b1) begin
                    if(|exceed_flag || |below_flag) state <= DATA_WARNING_OUT;
                    else state <= NO_WARNING_OUT;
                end 
            end
            CAL_IPUT_INDEX_CHECK: begin
                if(date_warning_flag) state <= DATE_WARNING_OUT;
                else if(risk_warning_flag) state <= RISK_WARNING_OUT;
                else begin
                    case(formula)
                        Formula_A: begin
                            state <= (cal_cnt == 2) ? NO_WARNING_OUT : state;
                        end
                        Formula_B: begin
                            state <= (cal_cnt == 3) ? NO_WARNING_OUT : state;
                        end
                        Formula_C: begin
                            state <= (cal_cnt == 2) ? NO_WARNING_OUT : state;
                        end
                        Formula_D: begin
                            state <= (cal_cnt == 1) ? NO_WARNING_OUT : state;
                        end
                        Formula_E: begin
                            state <= (cal_cnt == 1) ? NO_WARNING_OUT : state;
                        end
                        Formula_F: begin
                            state <= (cal_cnt == 7) ? NO_WARNING_OUT : state;
                        end
                        Formula_G: begin
                            state <= (cal_cnt == 6) ? NO_WARNING_OUT : state;
                        end
                        Formula_H: begin
                            state <= (cal_cnt == 4) ? NO_WARNING_OUT : state;
                        end
                    endcase
                end
            end
            DATA_WARNING_OUT, DATE_WARNING_OUT, RISK_WARNING_OUT, NO_WARNING_OUT: state <= IDLE;
        endcase
    end
end



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

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        formula <= 0;
    end
    else begin
        if(inf.formula_valid) begin
            formula <= inf.D.d_formula[0];
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        mode <= 0;
    end
    else begin
        if(inf.mode_valid) begin
            mode <= inf.D.d_mode[0];
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        {month, day} <= 0;
    end
    else begin
        if(inf.date_valid) begin
            // {month, day} <= inf.D.d_date[0];
            month <= inf.D.d_date[0].M;
            day <= inf.D.d_date[0].D;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        data_no <= 0;
    end
    else begin
        if(inf.data_no_valid) begin
            data_no <= inf.D.d_data_no[0];
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        pattern_index[0] <= 0;
        pattern_index[1] <= 0;
        pattern_index[2] <= 0;
        pattern_index[3] <= 0;
    end
    else begin
        if(inf.index_valid) begin
            pattern_index[3] <= inf.D.d_index[0];
            pattern_index[2] <= pattern_index[3];
            pattern_index[1] <= pattern_index[2];
            pattern_index[0] <= pattern_index[1];
            
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        dram_index[0] <= 0;
        dram_index[1] <= 0;
        dram_index[2] <= 0;
        dram_index[3] <= 0;
        dram_month <= 0;
        dram_day <= 0;
    end
    else begin
        if(inf.R_VALID == 1'b1) begin
            dram_index[0]  <= inf.R_DATA[63:52];
            dram_index[1] <= inf.R_DATA[51:40];
            dram_month <= inf.R_DATA[39:32];
            dram_index[2] <= inf.R_DATA[31:20];
            dram_index[3] <= inf.R_DATA[19:8];
            dram_day <= inf.R_DATA[7:0];
        end
    end
end

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



always_ff @( posedge clk or negedge inf.rst_n ) begin : d_state
    if(!inf.rst_n) begin
        dram_state <= DRAM_IDLE;
    end
    else begin
        case(dram_state)
            DRAM_IDLE: begin
                if(inf.data_no_valid) dram_state <= DRAM_READ_ADDR;
            end
            DRAM_READ_ADDR: begin
                if(inf.AR_READY) dram_state <= DRAM_READ_DATA;
            end
            DRAM_READ_DATA: begin
                if(inf.R_VALID) dram_state <= DRAM_WAIT;
            end
            DRAM_WAIT: begin
                if(state == WAIT_DATA) begin
                    if(act == Update) dram_state <= DRAM_WRITE_ADDR;
                    else dram_state <= DRAM_IDLE;
                end 
            end
            DRAM_WRITE_ADDR: begin
                if(inf.AW_READY) dram_state <= DRAM_WRITE_DATA;
            end
            DRAM_WRITE_DATA: begin
                if(inf.W_READY) dram_state <= DRAM_WRITE_RESPONSE;
            end
            DRAM_WRITE_RESPONSE: begin
                if(inf.B_VALID) dram_state <= DRAM_IDLE;
            end
        endcase
    end
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AR_VALID <= 0;
    end
    else begin
        case(dram_state)
            DRAM_IDLE: begin
                inf.AR_VALID <= (inf.data_no_valid == 1'b1);
            end
            DRAM_READ_ADDR: begin
                inf.AR_VALID <= (inf.AR_READY == 1'b1) ? 0 : 1;
            end
        endcase
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AR_ADDR <= 0;
    end
    else begin
        case(dram_state)
            DRAM_IDLE: begin
                // inf.AR_ADDR <= (inf.data_no_valid == 1'b1) ? (17'h10000 + (inf.D.d_data_no[0] << 3)) : 17'h10000;
                inf.AR_ADDR <= (inf.data_no_valid == 1'b1) ? {6'b100000,inf.D.d_data_no[0], 3'b000} : 17'h10000;

            end
            DRAM_READ_ADDR: begin
                inf.AR_ADDR <= (inf.AR_READY == 1'b1) ? 0 : inf.AR_ADDR;
            end
        endcase
    end
    
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.R_READY <= 0;
    end
    else begin
        case (dram_state)
            DRAM_READ_ADDR: begin
                inf.R_READY <= (inf.AR_READY == 1'b1) ? 1 : 0;
            end
            DRAM_READ_DATA: begin
                inf.R_READY <= (inf.R_VALID == 1'b1) ? 0 : inf.R_READY;
            end
        endcase
    end
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AW_VALID <= 0;
    end
    else begin
        case(dram_state)
            DRAM_WAIT: begin
                inf.AW_VALID <= (state == WAIT_DATA && act == Update) ? 1 : 0;
            end
            DRAM_WRITE_ADDR: begin
                inf.AW_VALID <= (inf.AW_READY == 1'b1) ? 0 : 1;
            end
        endcase
    end
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AW_ADDR <= 0;
    end
    else begin
        case(dram_state)
            DRAM_WAIT: begin
                inf.AW_ADDR <= (state == WAIT_DATA) ? {6'b100000,data_no, 3'b000} : 17'h10000;
            end
            DRAM_WRITE_ADDR: begin
                inf.AW_ADDR <= (inf.AW_READY == 1'b1) ? 0 : inf.AW_ADDR;
            end
        endcase
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.W_VALID <= 0;
    end
    else begin
        case(dram_state)
            DRAM_WRITE_ADDR: begin
                inf.W_VALID <= (inf.AW_READY == 1'b1) ? 1 : 0;
            end
            DRAM_WRITE_DATA: begin
                inf.W_VALID <= (inf.W_READY == 1'b1) ? 0 : inf.W_VALID;
            end
        endcase
    end
end

always_comb begin
    if(dram_state == DRAM_WRITE_DATA) begin
        inf.W_DATA = {refresh_index[0], refresh_index[1], 4'b000, month, refresh_index[2], refresh_index[3], 3'b000, day};
    end
    else inf.W_DATA = 0;
end


// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if(!inf.rst_n) begin
//         inf.W_DATA <= 0;
//     end
// end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.B_READY <= 0;
    end
    else begin
        case(dram_state)
            DRAM_WRITE_DATA: begin
                inf.B_READY <= (inf.W_READY == 1'b1) ? 1 : 0;
            end
            DRAM_WRITE_RESPONSE: begin
                inf.B_READY <= (inf.B_VALID == 1'b1) ? 0 : inf.B_READY;
            end
        endcase
    end
end







always_comb begin
    inf.out_valid = (state == DATA_WARNING_OUT || state == DATE_WARNING_OUT || state == RISK_WARNING_OUT || state == NO_WARNING_OUT) ? 1 : 0;
end
always_comb begin
    // inf.warn_msg = No_Warn;
    case(state)
        NO_WARNING_OUT:inf.warn_msg = No_Warn;
        DATA_WARNING_OUT:inf.warn_msg = Data_Warn;
        DATE_WARNING_OUT:inf.warn_msg = Date_Warn;
        RISK_WARNING_OUT:inf.warn_msg = Risk_Warn;
        default: inf.warn_msg = No_Warn;
    endcase
end
always_comb begin
    // inf.complete = 0;
    if(state == NO_WARNING_OUT) inf.complete = 1;
    else inf.complete = 0;
end


endmodule





module SORT4_MAX_and_MIN(clk, in0, in1, in2, in3, out0, out1, out2, out3);//0-3//max->min
input [11:0] in0, in1, in2, in3;
input clk;
output [11:0] out0, out1, out2, out3;

logic [11:0] max00, max01, min00, min01;
logic [11:0] max00_reg, max01_reg, min00_reg, min01_reg;

logic [11:0] max10, min10;

CMP cmp0(.in0(in0), .in1(in1), .out0(max00), .out1(min00));
CMP cmp1(.in0(in2), .in1(in3), .out0(max01), .out1(min01));

always_ff@(posedge clk) begin
    max00_reg <= max00;
    max01_reg <= max01;
    min00_reg <= min00;
    min01_reg <= min01;
end


CMP cmp2(.in0(max00_reg), .in1(max01_reg), .out0(out0), .out1(out1));
CMP cmp3(.in0(min00_reg), .in1(min01_reg), .out0(out2), .out1(out3));
// CMP cmp4(.in0(min10), .in1(max10), .out0(out1), .out1(out2));

endmodule


module CMP (
	input [11:0] in0,
	input [11:0] in1,
	output [11:0] out0,
	output [11:0] out1
);
    assign out0 = in0 < in1 ? in1 : in0;
    assign out1 = in0 < in1 ? in0 : in1;
endmodule