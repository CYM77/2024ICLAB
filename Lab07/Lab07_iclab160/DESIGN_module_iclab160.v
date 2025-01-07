module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [17:0] in_row;
input [11:0] in_kernel;
input out_idle;
output reg handshake_sready;
output reg [29:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;


parameter IDLE = 0;
parameter WAIT = 1;
parameter SEND_DATA = 2;
parameter READ_DATA = 3;
parameter OUT = 4;

integer i;

reg [2:0] s_state, n_s_state;
reg [29:0] buffer [0:5];//concate img&kernel
reg [29:0] n_buffer [0:5];//concate img&kernel
reg [2:0] input_cnt, n_input_cnt;
reg [2:0] send_cnt, n_send_cnt;
reg n_handshake_sready;
reg [29:0] n_handshake_din;

reg [2:0] r_state, n_r_state;
reg read_cnt, n_read_cnt;
// reg [7:0] out_cnt, n_out_cnt;
// ***********************

assign fifo_rinc = (r_state==WAIT || r_state==READ_DATA) && (!fifo_empty);

////////////////////////////////receive/////////////////////

always @(*) begin
    case(r_state)
        WAIT: begin
            if(!fifo_empty) n_r_state = READ_DATA;
            else n_r_state = r_state;
        end
        READ_DATA: begin
            // if(out_cnt == 149) n_r_state = WAIT;
            if(fifo_empty) n_r_state = OUT;
            else n_r_state = r_state;
        end
        OUT:begin
            n_r_state = WAIT;
        end
        default:n_r_state = r_state;
    endcase
end

// always @(*) begin
//     if(s_state == IDLE) n_out_cnt = 0;
//     else if(out_valid) n_out_cnt = out_cnt + 1;
//     else n_out_cnt = out_cnt;
// end



always @(*) begin
    case(r_state)
        // WAIT: n_read_cnt = 0;
        READ_DATA: begin
            n_read_cnt = 1;
        end
        OUT: begin
            n_read_cnt = 0;
        end
        default: n_read_cnt = read_cnt;
    endcase
end

always @(*) begin
    if(((r_state == OUT) || (r_state == READ_DATA && read_cnt ==1)) /*&& out_cnt <150*/) begin
        out_valid = 1;
        out_data = fifo_rdata;
    end
    else begin
        out_valid = 0;
        out_data = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_state <= WAIT;
        read_cnt <= 0;
        // out_cnt <= 0;
    end
    else begin
        r_state <= n_r_state;
        read_cnt <= n_read_cnt;
        // out_cnt <= n_out_cnt;
    end
end

////////////////////////////////sending/////////////////////
always @(*) begin
    n_s_state = s_state;
    case(s_state)
        IDLE: begin
            if(in_valid) n_s_state = WAIT;
            else n_s_state = s_state;
        end
        // GET_INPUT: begin
        //     if(!in_valid) begin
        //         n_s_state = WAIT;
        //     end
        //     else n_s_state = s_state;
        // end
        WAIT: begin
            if(out_idle == 1'b1 && send_cnt < 6) begin
                n_s_state = SEND_DATA;
            end
            else n_s_state = s_state;
        end
        SEND_DATA: begin
            if(send_cnt == 5) n_s_state = IDLE;
            else n_s_state = WAIT;
        end
    endcase
end

always @(*) begin
    case(s_state)
        WAIT: begin
            if(out_idle == 1'b1 && send_cnt < 6) begin
                n_handshake_sready = 1;
            end
            else n_handshake_sready = 0;
        end
        default: n_handshake_sready = 0;
    endcase    
end
always @(*) begin
    case(s_state)
        WAIT: begin
            if(out_idle == 1'b1) begin
                n_handshake_din = buffer[send_cnt];
            end
            else n_handshake_din = 0;
        end
        default: n_handshake_din = 0;
    endcase    
end

always @(*) begin
    if(s_state == SEND_DATA) n_send_cnt = send_cnt + 1;
    else if(s_state == IDLE) n_send_cnt = 0;
    else n_send_cnt = send_cnt;
end



// always @(*) begin
//     case(s_state)
//         IDLE: begin
//             if(in_valid) n_input_cnt = input_cnt + 1;
//             else n_input_cnt = 0;
//         end
//         GET_INPUT: begin
//             if(input_cnt == 6) n_input_cnt = 0;
//             else if(in_valid) n_input_cnt = input_cnt + 1;
//             else n_input_cnt = input_cnt;
//         end
//         SEND_DATA: begin
//             n_input_cnt = input_cnt + 1;
//         end
//         default: n_input_cnt = input_cnt;
//     endcase
// end
always @(*) begin
    if(input_cnt == 6) n_input_cnt = 0;
    else if(in_valid) begin
        n_input_cnt = input_cnt + 1;
    end
    else n_input_cnt = input_cnt;
end

// always @(*) begin
//     n_buffer = buffer;
//     case(s_state)
//         IDLE: begin
//             if(in_valid) begin
//                 n_buffer[5] = {in_row, in_kernel};
//             end
//         end
//         GET_INPUT: begin
//             if(input_cnt <=5) begin
//                 n_buffer[5] = {in_row, in_kernel};
//                 for(i=0; i<5; i=i+1) begin
//                     n_buffer[i] = buffer[i+1];
//                 end
//             end
//         end
//         WAIT: begin
//             if(out_idle == 1'b1) begin
//                 n_buffer[5] = 0;
//                 for(i=0; i<5; i=i+1) begin
//                     n_buffer[i] = buffer[i+1];
//                 end
//             end
//         end
//     endcase
// end
always @(*) begin
    n_buffer = buffer;
    if(in_valid)begin
        n_buffer[input_cnt] = {in_row, in_kernel};
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_state <= IDLE;
        input_cnt <= 0;
        for(i=0; i<6; i=i+1) begin
            buffer[i] <= 0;
        end
        handshake_sready <= 0;
        handshake_din <= 0;
        send_cnt <= 0;
    end
    else begin
        s_state <= n_s_state;
        input_cnt <= n_input_cnt;
        for(i=0; i<6; i=i+1) begin
            buffer[i] <= n_buffer[i];
        end
        handshake_sready <= n_handshake_sready;
        handshake_din <= n_handshake_din;
        send_cnt <= n_send_cnt;
    end
end




endmodule






module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [29:0] in_data;
output reg out_valid;
output reg [7:0] out_data;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

parameter IDLE = 0;
parameter CNN = 1;
parameter WAIT = 2;


reg [2:0] state, n_state;




reg [11:0] kernel [0:5];
reg [11:0] n_kernel [0:5];
reg [2:0] img [0:5][0:5];
reg [2:0] n_img [0:5][0:5];

reg [2:0] in_cnt, n_in_cnt;
integer i,j;
reg [2:0] x, n_x;
reg [2:0] y, n_y;
reg [2:0] kernel_cnt, n_kernel_cnt;
reg n_out_valid;
reg [7:0] n_out_data;

// wire [7:0] cnn_out = img[y][x] * kernel[kernel_cnt][2:0] + img[y][x + 1] * kernel[kernel_cnt][5:3] + img[y + 1][x] * kernel[kernel_cnt][8:6] + img[y + 1][x + 1] * kernel[kernel_cnt][11:9];
wire [3:0] img0 = img[y][x];
wire [3:0] img1 = img[y][x+1];
wire [3:0] img2 = img[y+1][x];
wire [3:0] img3 = img[y+1][x+1];
wire [3:0] kernel0 = kernel[kernel_cnt][2:0];
wire [3:0] kernel1 = kernel[kernel_cnt][5:3];
wire [3:0] kernel2 = kernel[kernel_cnt][8:6];
wire [3:0] kernel3 = kernel[kernel_cnt][11:9];

wire [7:0] cnn_out = img0 * kernel0 + img1 * kernel1 + img2 * kernel2 + img3 * kernel3;
wire n_busy = busy;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<6; i=i+1)begin
            kernel[i] <= 0;
        end
        for(i=0; i<6; i=i+1) begin
            for (j = 0; j<6 ; j=j+1) begin
                img[i][j] <= 0;
            end
        end
        in_cnt <= 0;
        state <= IDLE;
        x <= 0;
        y <= 0;
        kernel_cnt <= 0;
        // out_valid <= 0;
        // out_data <= 0;
        busy <= 0;
    end
    else begin
        for(i=0; i<6; i=i+1)begin
            kernel[i] <= n_kernel[i];
        end
        for(i=0; i<6; i=i+1) begin
            for (j = 0; j<6 ; j=j+1) begin
                img[i][j] <= n_img[i][j];
            end
        end

        in_cnt <= n_in_cnt;
        state <= n_state;
        x <= n_x;
        y <= n_y;
        kernel_cnt <= n_kernel_cnt;
        // out_valid <= n_out_valid;
        // out_data <= n_out_data;
        busy <= n_busy;
    end
end



always @(*) begin
    case (state)
        IDLE: begin
            if(in_cnt > 1 && in_cnt!=6) begin
                n_state = CNN;
            end
            else n_state = state;
        end 
        CNN: begin
            if(!fifo_full && x==4 && y==4 && kernel_cnt == 5) n_state = IDLE;
            else if(fifo_full || ((x==4 && (y==(in_cnt - 2)) && in_cnt != 6))) n_state = WAIT;
            else n_state = state;
        end
        WAIT: begin
            if(!fifo_full && (y!=(in_cnt - 1)))begin
                n_state = CNN;
            end
            else n_state = state;
        end
        default: begin
            n_state = state;
        end
    endcase
end

// always @(*) begin
//     if(n_state == CNN) begin
//         n_out_valid = 1;
//     end
//     else begin
//         n_out_valid = 0;
//     end
// end
always @(*) begin
    if(state == CNN && fifo_full==0) out_valid = 1;
    else out_valid = 0;
end

always @(*) begin
    if(state == CNN) out_data = cnn_out;
    else out_data = 0;
end
// always @(*) begin
//     if(state == CNN) begin
//         n_out_data = cnn_out;
//     end
//     else begin
//         n_out_data = 0;
//     end
// end


always @(*) begin
    if(state == CNN && !fifo_full) begin
        if(x == 4) n_x = 0;
        else n_x = x + 1;
    end
    else if(state == IDLE) n_x = 0;
    else begin
        n_x = x;
    end
end

always @(*) begin
    if(state == CNN && !fifo_full) begin
        if(x == 4) begin
            if(y==4) n_y = 0;
            else n_y = y + 1;
        end 
        else n_y = y;
    end
    else if(state == IDLE) n_y = 0;
    else begin
        n_y = y;
    end
end

always @(*) begin
    if(state == CNN) begin
        if(x==4 && y==4 && !fifo_full)begin
            if(kernel_cnt == 5) n_kernel_cnt = kernel_cnt;
            else  n_kernel_cnt = kernel_cnt + 1;
        end
        else n_kernel_cnt = kernel_cnt;
    end
    else if(state == IDLE) n_kernel_cnt = 0;
    else begin
        n_kernel_cnt = kernel_cnt;
    end
end

always @(*) begin
    for(i=0; i<6; i=i+1)begin
        n_kernel[i] = kernel[i];
    end
    if(in_valid) begin
        n_kernel[in_cnt] = in_data[11:0];
    end
end

always @(*) begin
    for(i=0; i<6; i=i+1) begin
        for (j = 0; j<6 ; j=j+1) begin
            n_img[i][j] = img[i][j];
        end
    end
    if(in_valid) begin
        // for (j = 0; j<6 ; j=j+1) begin
        //     n_img[in_cnt][j] = in_data[(14 + (3*j)):(12 + (3*j))];
        // end
        n_img[in_cnt][0] = in_data[14:12];
        n_img[in_cnt][1] = in_data[17:15];
        n_img[in_cnt][2] = in_data[20:18];
        n_img[in_cnt][3] = in_data[23:21];
        n_img[in_cnt][4] = in_data[26:24];
        n_img[in_cnt][5] = in_data[29:27];
    end
end

always @(*) begin
    if(in_cnt == 6) n_in_cnt = 0;
    else if(in_valid) begin
        n_in_cnt = in_cnt + 1;
    end
    else begin
        n_in_cnt = in_cnt;
    end
end



// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         busy <= 0;
//     end
//     else begin
//         busy <= busy;
//     end
// end

endmodule
