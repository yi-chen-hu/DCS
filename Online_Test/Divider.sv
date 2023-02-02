module Divider(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_data,
  // Output signals
    out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] in_data;
output logic out_valid, out_data;
 
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] in_value;
logic [3:0] data[0:3], data_comb[0:3];
logic [2:0] cnt_in, cnt_in_comb;
logic [4:0] state, next_state;

logic [3:0] data1_1, data1_2, data2_1, data2_2, data2_3, data2_4,
			data3_1, data3_2, data3_3, data3_4, data4_1, data4_2;

logic [19:0] dividend, dividend_comb;
logic [3:0] cnt, cnt_comb;
logic [9:0] left, right;


logic [3:0] cnt_out, cnt_out_comb;
logic out_valid_comb;
logic out_data_comb;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
parameter S_IDLE = 0;
parameter S_IN = 1;
parameter S_SWAP = 2;
parameter S_conv10 = 3;
parameter S_step2 = 4;
parameter S_step3 = 5;
parameter S_OUT = 6;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;
		
always_comb
	case(state)
		S_IDLE: next_state = in_valid ? S_IN : S_IDLE;
		S_IN:	next_state = cnt_in == 4 ? S_SWAP : S_IN;
		S_SWAP:	next_state = S_conv10;
		S_conv10:next_state = S_step2;
		S_step2:next_state = S_step3;
		S_step3:next_state = cnt == 10 ? S_OUT : S_step2;
		S_OUT:	next_state = cnt_out == 10 ? (in_valid ? S_IN : S_IDLE) : S_OUT;
		default:next_state = S_IDLE;
	endcase
	
register_file inst1(in_data, in_value);

descend swap1_1(data[0], data[1], data1_1, data2_1);
descend swap1_2(data[2], data[3], data3_1, data4_1);

descend swap2_1(data2_1, data3_1, data2_2, data3_2);

descend swap3_1(data1_1, data2_2, data1_2, data2_3);
descend swap3_2(data3_2, data4_1, data3_3, data4_2);

descend swap4_1(data2_3, data3_3, data2_4, data3_4);


always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(int i = 0; i < 4; i = i + 1)
			data[i] <= 0;
	else
		for(int i = 0; i < 4; i = i + 1)
			data[i] <= data_comb[i];
		
always_comb
	if(next_state == S_IN)
		for(int i = 0; i < 4; i = i + 1)
			if(cnt_in == i)
				data_comb[i] = in_value;
			else
				data_comb[i] = data[i];
	else if(next_state == S_SWAP) begin
		data_comb[0] = data1_2;
		data_comb[1] = data2_4;
		data_comb[2] = data3_4;
		data_comb[3] = data4_2;
	end
	else
		for(int i = 0; i < 4; i = i + 1)
			data_comb[i] = data[i];
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		cnt_in <= 0;
	else
		cnt_in <= cnt_in_comb;

always_comb
	if(next_state == S_IN)
		cnt_in_comb = cnt_in + 1;
	else
		cnt_in_comb = 0;
		
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		dividend <= 0;
	else
		dividend <= dividend_comb;
		
always_comb
	if(next_state == S_conv10)
		dividend_comb = data[0] * 100 + data[2] * 10 + data[3];
	else if(next_state == S_step2)
		dividend_comb = dividend << 1;
	else if(next_state == S_step3)
		if(dividend[19:10] >= data[1])
			dividend_comb = {left, right};
		else
			dividend_comb = dividend;
	else
		dividend_comb = dividend;
	
assign left = dividend[19:10] - data[1];
assign right = dividend[9:0] + 1;

	
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		cnt <= 0;
	else
		cnt <= cnt_comb;
		
always_comb
	if(next_state == S_IDLE)
		cnt_comb = 0;
	else if(next_state == S_step3)
		cnt_comb = cnt + 1;
	else
		cnt_comb = cnt;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_valid <= 0;
	else
		out_valid <= out_valid_comb;
		
always_comb
	if(next_state == S_OUT)
		out_valid_comb = 1;
	else
		out_valid_comb = 0;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_data <= 0;
	else
		out_data <= out_data_comb;
		
always_comb
	if(next_state == S_OUT)
		if(data[1] == 0)
			out_data_comb = 1;
		else 
			out_data_comb = dividend[9 - cnt_out];
	else
		out_data_comb = 0;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		cnt_out <= 0;
	else
		cnt_out <= cnt_out_comb;
	
always_comb
	if(next_state == S_OUT)
		cnt_out_comb = cnt_out + 1;
	else
		cnt_out_comb = 0;
		
		
endmodule

module register_file(
    E,
    value
);
input [3:0] E;
output logic [3:0] value;

always_comb begin
    case(E)
    4'b0011:value = 4'd0;
    4'b0100:value = 4'd1;
    4'b0101:value = 4'd2;
    4'b0110:value = 4'd3;
    4'b0111:value = 4'd4;
    4'b1000:value = 4'd5;
    4'b1001:value = 4'd6;
    4'b1010:value = 4'd7;
    4'b1011:value = 4'd8;
    4'b1100:value = 4'd9;
    default: value = 4'd0;
    endcase
end
endmodule

module descend(
	a, b,
	a_out, b_out
);
input [3:0] a, b;
output logic [3:0] a_out, b_out;

assign a_out = ( a > b ) ? a : b;
assign b_out = ( a > b ) ? b : a;

endmodule