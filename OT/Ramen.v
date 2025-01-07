module Ramen(
    // Input Registers
    input clk, 
    input rst_n, 
    input in_valid,
    input selling,
    input portion, 
    input [1:0] ramen_type,

    // Output Signals
    output reg out_valid_order,
    output reg success,

    output reg out_valid_tot,
    output reg [27:0] sold_num,
    output reg [14:0] total_gain
);


//==============================================//
//             Parameter and Integer            //
//==============================================//

// ramen_type
parameter TONKOTSU = 0;
parameter TONKOTSU_SOY = 1;
parameter MISO = 2;
parameter MISO_SOY = 3;

// initial ingredient
parameter NOODLE_INIT = 12000;
parameter BROTH_INIT = 41000;
parameter TONKOTSU_SOUP_INIT =  9000;
parameter MISO_INIT = 1000;
parameter SOY_SAUSE_INIT = 1500;

parameter IDLE = 0;
parameter INPUT = 1;
parameter CAL = 2;
parameter OUT = 3;
parameter OVER = 4;

//==============================================//
//                 reg declaration              //
//==============================================// 
reg [4:0] state;
reg [30:0] noodle,broth,soup,soy_sauce,miso;
reg selling_reg;
reg portion_reg;
reg [1:0] ramen_type_reg;
reg [5:0] cnt;
reg [27:0] sold_num_reg;
reg out_valid_order_reg;
reg success_reg;

wire [15:0] sum = sold_num_reg[27:21] * 200 + sold_num_reg[20:14] * 250 + sold_num_reg[13:7] * 200 + sold_num_reg[6:0] * 250;



//==============================================//
//                    Design                    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                if(in_valid) state <= INPUT;
            end
            INPUT: begin
                state <= CAL;
            end
            CAL: begin
                state <= OUT;
            end
            OUT: begin
                if(selling == 0) state <= OVER;
                else state <= IDLE;
            end
            OVER: begin
                state <= IDLE;
            end
        endcase
    end
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        noodle<= NOODLE_INIT;
        broth<= BROTH_INIT;
        soup<= TONKOTSU_SOUP_INIT;
        soy_sauce<= SOY_SAUSE_INIT;
        miso<= MISO_INIT;
    end
    else begin
        if(state == OVER) begin
            noodle<= NOODLE_INIT;
            broth<= BROTH_INIT;
            soup<= TONKOTSU_SOUP_INIT;
            soy_sauce<= SOY_SAUSE_INIT;
            miso<= MISO_INIT;
        end

        else if(state == CAL)begin
            if(portion_reg == 0) begin
                case(ramen_type_reg) 
                    TONKOTSU:begin
                        if(noodle >= 100 && broth >= 300 && soup >= 150) begin
                            noodle <= noodle - 100;
                            broth <= broth - 300;
                            soup <= soup - 150;
                        end
                    end
                    TONKOTSU_SOY:begin
                        if(noodle >= 100 && broth >= 300 && soup >= 100 && soy_sauce >= 30) begin
                            noodle <= noodle - 100;
                            broth <= broth - 300;
                            soup <= soup - 100;
                            soy_sauce <= soy_sauce - 30;
                        end
                    end
                    MISO:begin
                        if(noodle >= 100 && broth >= 400 && miso >= 30) begin
                            noodle <= noodle - 100;
                            broth <= broth - 400;
                            miso <= miso - 30;
                        end
                    end
                    MISO_SOY:begin
                        if(noodle >= 100 && broth >= 300 && soup >= 70 && soy_sauce >= 15 && miso >= 15) begin
                            noodle <= noodle - 100;
                            broth <= broth - 300;
                            soup <= soup - 70;
                            soy_sauce <= soy_sauce - 15;
                            miso <= miso - 15;
                        end
                    end
                endcase
            end
            else begin
                case(ramen_type_reg) 
                    TONKOTSU:begin
                        if(noodle >= 150 && broth >= 500 && soup >= 200) begin
                            noodle <= noodle - 150;
                            broth <= broth - 500;
                            soup <= soup - 200;
                        end
                    end
                    TONKOTSU_SOY:begin
                        if(noodle >= 150 && broth >= 500 && soup >= 150 && soy_sauce >= 50) begin
                            noodle <= noodle - 150;
                            broth <= broth - 500;
                            soup <= soup - 150;
                            soy_sauce <= soy_sauce - 50;
                        end
                    end
                    MISO:begin
                        if(noodle >= 150 && broth >= 650 && miso >= 50) begin
                            noodle <= noodle - 150;
                            broth <= broth - 650;
                            miso <= miso - 50;
                        end
                    end
                    MISO_SOY:begin
                        if(noodle >= 150 && broth >= 500 && soup >= 100 && soy_sauce >= 25 && miso >= 25) begin
                            noodle <= noodle - 150;
                            broth <= broth - 500;
                            soup <= soup - 100;
                            soy_sauce <= soy_sauce - 25;
                            miso <= miso - 25;
                        end
                    end
                endcase
            end
        end
    end
end




always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        success_reg <= 0;
    end
    else begin
        if(state == CAL)begin
            if(portion_reg == 0) begin
                case(ramen_type_reg) 
                    TONKOTSU:begin
                        // noodle <= noodle - 100;
                        // broth <= broth - 300;
                        // soup <= soup - 150;
                        if(noodle >= 100 && broth >= 300 && soup >= 150) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    TONKOTSU_SOY:begin
                        // noodle <= noodle - 100;
                        // broth <= broth - 300;
                        // soup <= soup - 100;
                        // soy_sauce <= soy_sauce - 30;
                        if(noodle >= 100 && broth >= 300 && soup >= 100 && soy_sauce >= 30) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    MISO:begin
                        // noodle <= noodle - 100;
                        // broth <= broth - 400;
                        // miso <= miso - 30;
                        if(noodle >= 100 && broth >= 400 && miso >= 30) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    MISO_SOY:begin
                        // noodle <= noodle - 100;
                        // broth <= broth - 300;
                        // soup <= soup - 70;
                        // soy_sauce <= soy_sauce - 15;
                        // miso <= miso - 15;
                        if(noodle >= 100 && broth >= 300 && soup >= 70 && soy_sauce >= 15 && miso >= 15) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                endcase
            end
            else begin
                case(ramen_type_reg) 
                    TONKOTSU:begin
                        // noodle <= noodle - 150;
                        // broth <= broth - 500;
                        // soup <= soup - 200;
                        if(noodle >= 150 && broth >= 500 && soup >= 200) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    TONKOTSU_SOY:begin
                        // noodle <= noodle - 150;
                        // broth <= broth - 500;
                        // soup <= soup - 150;
                        // soy_sauce <= soy_sauce - 50;
                        if(noodle >= 150 && broth >= 500 && soup >= 150 && soy_sauce >= 50) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    MISO:begin
                        // noodle <= noodle - 150;
                        // broth <= broth - 650;
                        // miso <= miso - 50;
                        if(noodle >= 150 && broth >= 650 && miso >= 50) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                    MISO_SOY:begin
                        // noodle <= noodle - 150;
                        // broth <= broth - 500;
                        // soup <= soup - 100;
                        // soy_sauce <= soy_sauce - 25;
                        // miso <= miso - 25;
                        if(noodle >= 150 && broth >= 500 && soup >= 100 && soy_sauce >= 25 && miso >= 25) begin
                            success_reg <= 1;
                        end
                        else begin
                            success_reg <= 0;
                        end
                    end
                endcase
            end
        end
        else if(state == IDLE) success_reg <= 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sold_num_reg <= 0;
    end
    else begin
        case(state)
            OUT: begin
                if(success_reg) begin
                    case(ramen_type_reg) 
                        TONKOTSU:begin
                            sold_num_reg[27:21] <= sold_num_reg[27:21] + 1;
                        end
                        TONKOTSU_SOY:begin
                            sold_num_reg[20:14] <= sold_num_reg[20:14] + 1;
                        end
                        MISO:begin
                            sold_num_reg[13:7] <= sold_num_reg[13:7] + 1;
                        end
                        MISO_SOY:begin
                            sold_num_reg[6:0] <= sold_num_reg[6:0] + 1;
                        end
                    endcase
                end
            end
            OVER: begin
                sold_num_reg <= 0;
            end
        endcase
    end
end




always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        selling_reg <= 0;
    end
    else begin
        case(state)
            OUT: begin
                selling_reg <= selling;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ramen_type_reg <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                if(in_valid) ramen_type_reg <= ramen_type;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        portion_reg <= 0;
    end
    else begin
        case(state)
            INPUT: begin
                portion_reg <= portion;
            end
        endcase
    end
end

always @(*) begin
    if(state == OUT)  out_valid_order = 1;
    else out_valid_order = 0;
end

always @(*) begin
    if(state == OUT)  success = success_reg;
    else success = 0;
end

always @(*) begin
    if(state == OVER)  out_valid_tot = 1;
    else out_valid_tot = 0;
end

always @(*) begin
    if(state == OVER)  sold_num = sold_num_reg;
    else sold_num = 0;
end

always @(*) begin
    if(state == OVER)  total_gain = sum;
    else total_gain = 0;
end


endmodule
