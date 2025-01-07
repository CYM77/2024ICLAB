//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 8) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;
output reg [IP_BIT-1:0] OUT_code;

wire [3:0] ham_in [0:IP_BIT+4-1];
wire [3:0] ham_temp;

genvar i,j;
generate
    for(i = 0; i < IP_BIT+4; i = i+1) begin:loop_ham_in
        assign ham_in[i] = (IN_code[IP_BIT+4-1 - i]==1) ? (i+1) : 4'b0000;
    end
endgenerate

generate
    for(i = 0; i < 4; i = i+1)begin:loop_ham_cal
        wire [IP_BIT+4-1-1:0] add_temp;
        for(j = 0; j < IP_BIT+4-1; j = j+1) begin
            if(j==0) begin
                assign add_temp[0] = ham_in[0][i] ^ ham_in[1][i];
            end
            else begin
                assign add_temp[j] = loop_ham_cal[i].add_temp[j - 1] ^ ham_in[j + 1][i];
            end
        end
        assign ham_temp[i] = add_temp[IP_BIT+4-1-1];
    end
endgenerate

generate
    always@(*) begin
        OUT_code[IP_BIT - 1] = (ham_temp == 4'd3) ? ~IN_code[IP_BIT+4 - 1 - 2] : IN_code[IP_BIT+4 - 1 - 2];
    end    
    for(i = 1; i < IP_BIT; i = i+1) begin
        always @(*) begin
            if(i < 4) begin
                 OUT_code[IP_BIT - 1 - i] = (ham_temp == (i+4))? ~IN_code[IP_BIT+4 - 1 -(i+3)] : IN_code[IP_BIT+4 - 1 -(i+3)];
            end
            else begin
                 OUT_code[IP_BIT - 1 - i] = (ham_temp == (i+5))? ~IN_code[IP_BIT+4 - 1 -(i+4)] : IN_code[IP_BIT+4 - 1 -(i+4)];
            end
        end
    end
endgenerate


// ===============================================================
// Design
// ===============================================================



endmodule