module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [7:0] score_A,  // Score of team A (guest team)
    output reg [7:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
// Example: parameter IDLE = 3'b000;


localparam IDLE = 0;
localparam A = 1;
localparam B = 3;
localparam OVER = 2;

//==============================================//
//                 reg declaration              //
//==============================================//
reg [1:0] out,n_out;
reg [2:0] act,n_act;
reg [2:0] base,n_base;
reg change, n_change;
reg [1:0] state,n_state;
reg early_stop,n_early_stop;

reg [3:0] A_point,n_A_point;
reg [2:0] B_point,n_B_point;

wire [2:0] add_score;
wire [2:0] new_base;
wire [1:0] new_out;

reg change_side;
always @(*) begin
    case(state)
        IDLE: change_side = 1;
        A: change_side = (half);
        B: change_side = (!half);
        OVER: change_side = 1;
        default: change_side = 1;
    endcase
end




//==============================================//
//             Current State Block              //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state      <= IDLE;
        A_point    <= 0;
        B_point    <= 0;
        out        <= 0;
        act        <= 0;
        base       <= 0;
        early_stop <= 0;
    end
    else begin
        state      <= n_state;
        A_point    <= n_A_point;
        B_point    <= n_B_point;
        out        <= n_out;
        act        <= n_act;
        base       <= n_base;
        early_stop <= n_early_stop;
    end
end

// always @(posedge clk) begin
//     out        <= n_out;
//     act        <= n_act;
//     base       <= n_base;
//     early_stop <= n_early_stop;
// end

//==============================================//
//              Next State Block                //
//==============================================//
//state
always @(*) begin
    case(state)
        IDLE: begin
            if(in_valid) n_state = A;
            else n_state = state;
        end
        A: begin
            if(half==1'b1) n_state = B;
            else n_state = state;
        end
        B: begin
            if(!in_valid) n_state = OVER;
            else if(half==1'b0) n_state = A;
            else n_state = state;
        end
        OVER: begin
            n_state = IDLE;
        end
        default: begin
            n_state = state;
        end
    endcase
end

//share adder
wire [3:0] add_out,add_select;
assign add_select = (state[1]) ? B_point : A_point;
assign add_out = add_score + add_select;
//A point
always @(*) begin
    case(state)
        OVER: n_A_point = 0;
        A: n_A_point = add_out;
        default: n_A_point = A_point;
    endcase
end
//B point
always @(*) begin
    case(state)
        OVER: n_B_point = 0;
        B: begin
            if(early_stop) n_B_point = B_point;
            else n_B_point = add_out;
        end 
        default: n_B_point = B_point; 
    endcase
end
//early_stop
always @(*) begin
    case(state)
        IDLE: n_early_stop = 0;
        A: begin
            if(inning == 3 && half==1 && (A_point < B_point)) n_early_stop = 1;
            else n_early_stop = early_stop;
        end
        B:n_early_stop = early_stop;
        OVER:n_early_stop = 0;
    endcase
    
end

//base
always @(*) begin
    case(state) 
        A,B: begin
            if(change_side) n_base = 0;
            else n_base = new_base;
        end
        IDLE: begin
            n_base = 0;
        end
        OVER: begin
            n_base = 0;
        end
        default: n_base = base;
    endcase
    
end

//out_num
always @(*) begin
    if(change_side) n_out = 0;
    else n_out = new_out;
end
//act 
always @(*) begin
    n_act = action;
end

//==============================================//
//             Base and Score Logic             //
//==============================================//
// Handle base runner movements and score calculation.
// Update bases and score depending on the action:
// Example: Walk, Hits (1H, 2H, 3H), Home Runs, etc.

Base_Score BS(.action(act), .base(base), .out_num(out), .add_score(add_score), .new_base(new_base), .new_out(new_out));

//==============================================//
//                Output Block                  //
//==============================================//
// Decide when to set out_valid high, and output score_A, score_B, and result.
always @(*) begin
    if(state == OVER) out_valid = 1;
    else out_valid = 0;
end


always @(*) begin
    score_A = A_point;
end
always @(*) begin
    score_B = B_point;
end
always@(*) begin
    if(state == OVER) begin
        if(A_point > B_point) result = 0;
        else if(A_point < B_point) result = 1;
        else result = 2;
    end 
    else result = 0;
end
endmodule




module Base_Score (
    input [2:0] action,
    input [2:0] base,
    input [1:0] out_num,
    output reg [2:0] add_score,
    output reg [2:0] new_base,
    output reg [1:0] new_out
);
    localparam Walk        = 3'd0;
    localparam Single      = 3'd1;
    localparam Double      = 3'd2;
    localparam Triple      = 3'd3;
    localparam HR          = 3'd4;
    localparam Bunt        = 3'd5;
    localparam Ground_ball = 3'd6;
    localparam Fly_ball    = 3'd7;
    wire out1 = out_num[0];
    wire out2 = out_num[1];
    //base
    always @(*) begin
        case(action)
            Walk: begin
                new_base[0] = 1;
                if(base[0]) new_base[1] = 1;
                else new_base[1] = base[1];
                if(base[1] &base[0]) new_base[2] = 1;
                else new_base[2] = base[2];
            end
            Single: begin
                if(out2) new_base = {base[0],2'b01};
                else new_base = {base[1],base[0],1'b1};
            end
            Double: begin
                if(out2) new_base = 3'b010;
                else new_base = {base[0],2'b10};
            end
            Triple: begin
                new_base =3'b100;
            end
            HR: begin
                new_base = 3'b000;
            end
            Bunt: begin
                new_base = {base[1],base[0],1'b0};
            end
            Ground_ball: begin
                new_base = {base[1],2'b00};
            end
            Fly_ball: begin
                new_base = {1'b0, base[1], base[0]};
            end
            default: begin
                new_base = base;
            end
        endcase
    end

    wire [1:0] base12 = base[1] + base[2];
    wire [1:0] base012 = base[0] + base[1] + base[2];
    
    //score
    always @(*) begin
        case(action)
            Walk: begin       
                if(&(base)) add_score = 1;
                else add_score = 0;
            end
            Single: begin
                if(out2) begin
                    add_score = base[1] + base[2];
                end
                else begin
                    if(base[2]) add_score = 1;
                    else add_score = 0;
                end
                
            end
            Double: begin
                if(out2) begin
                    add_score = base[2] + base[1] + base[0];
                end
                else begin
                   add_score = base[1] + base[2];
                end
                
            end
            Triple: begin
                add_score = base[0] + base[1] + base[2];
            end
            HR: begin
                add_score = base[0] + base[1] + base[2] + 1'b1;
            end 
            Bunt: begin
                if(base[2]) add_score = 1;
                else add_score = 0;
            end
            Ground_ball: begin
                if((( out_num==0) || (!base[0] && out_num==1)) && base[2]) begin
                    add_score = 1;
                end
                else begin
                    add_score = 0;
                end
            end
            Fly_ball: begin
                if(base[2] && !out2) begin
                    add_score = 1;
                end
                else begin
                    add_score = 0;
                end
            end
            default: begin
                add_score = 0;
            end
        endcase
    end
    //out_num
    always @(*) begin
        case(action)
            Walk, Single: begin
                new_out = out_num;
            end
            
            Double: begin
                new_out = out_num;
            end
            Triple: begin
                new_out = out_num;
            end
            HR: begin
                new_out = out_num;
            end
            Bunt: begin
                new_out = out_num + 1;
            end
            Ground_ball: begin
                if(!out1 && base[0]) begin
                    new_out = out_num + 2;
                end
                else begin
                    new_out = out_num + 1;
                end
            end
            Fly_ball: begin
                new_out = out_num + 1;
            end
            default: begin
                new_out = out_num;
            end
        endcase
    end
endmodule


