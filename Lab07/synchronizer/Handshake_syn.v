module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;


parameter IDLE         = 3'b001;
parameter WAIT_DST     = 3'b011;
parameter SEND_DATA    = 3'b010;
parameter OUT       = 3'b100;

reg [2:0] src_state, dst_state;
// reg [WIDTH-1:0] sreq, dreq, sack, dack;

reg [WIDTH-1:0] src_reg, dst_reg;

assign handshake_clk1_flag = (sreq && sack);
assign handshake_clk2_flag = (!dreq && dack);


assign sidle = (src_state == IDLE);

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) begin
        src_state <= IDLE;
        sreq <= 0;
        src_reg <= 0;

    end
    else begin
        case(src_state)
            IDLE: begin
                src_state <= (sready && !sreq) ? SEND_DATA : IDLE;
                sreq <= (sready && !sreq) ? 1 : 0;
                src_reg <= din;

            end
            SEND_DATA: begin
                src_state <= handshake_clk1_flag ? WAIT_DST : SEND_DATA;
                sreq <= handshake_clk1_flag ? 0 : 1;
            end
            WAIT_DST: begin
                src_state <= (!sreq && !sack) ? IDLE :WAIT_DST;

            end
        endcase
    end
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dst_state <= IDLE;
        dst_reg <= 0;
        dack <= 0;
        dvalid <= 0;
    end
    else begin
        case (dst_state)
            // IDLE: begin
            //     dst_state <= (!dbusy && dreq) ? SEND_DATA : IDLE;
            //     dack <= (!dbusy && dreq) ? 1 : 0;
            //     dout <= 0;
            //     dvalid <= 0;
            // end 
            // SEND_DATA: begin
            //     dst_state <= handshake_clk2_flag ? OUT : SEND_DATA;
            //     dack <= handshake_clk2_flag ? 0 : 1;
            //     dst_reg <= handshake_clk2_flag ? src_reg : dst_reg;
            // end
            // OUT: begin
            //     dst_state <= IDLE;
            //     dvalid <= 1;
            //     dout <= dst_reg;
            // end
            IDLE: begin
                dst_state <= (!dbusy && dreq) ? OUT : IDLE;
                dack <= (!dbusy && dreq) ? 1 : 0;
                dout <= 0;
                dvalid <= 0;
                dst_reg <= (!dbusy && dreq) ? src_reg : dst_reg;
            end 
            SEND_DATA: begin
                dst_state <= handshake_clk2_flag ? IDLE : SEND_DATA;
                dack <= handshake_clk2_flag ? 0 : 1;
                // dst_reg <= handshake_clk2_flag ? src_reg : dst_reg;
                dvalid <= 0;
                dout <= 0;
            end
            OUT: begin
                dst_state <= SEND_DATA;
                dvalid <= 1;
                dout <= dst_reg;
            end
        endcase
    end
end











// Synchronizers
NDFF_syn sreq_dreq(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn dack_sack(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

endmodule