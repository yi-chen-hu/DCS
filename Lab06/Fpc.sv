module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
logic out_valid_comb;
logic [15:0] out_comb, out_add, out_multiply;
logic [15:0] a_reg, b_reg, a_reg_comb, b_reg_comb;
logic mode_reg, mode_reg_comb;

logic [1:0] state, next_state;
parameter S_idle = 2'd0;
parameter S_in = 2'd1;
parameter S_out = 2'd2;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= S_idle;
	else
		state <= next_state;

always_comb
	case(state)
		S_idle:	next_state = in_valid ? S_in : S_idle;
		S_in : 	next_state = S_out;
		S_out:	next_state = in_valid ? S_in : S_idle;
		default:next_state = S_idle;
	endcase
	
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_valid <= 1'b0;
	else
		out_valid <= out_valid_comb;
	
always_comb
	if(next_state == S_out)
		out_valid_comb = 1'b1;
	else
		out_valid_comb = 1'b0;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		a_reg <= 16'b0;
	else
		a_reg <= a_reg_comb;
		
always_comb
	if(next_state == S_in)
		a_reg_comb = in_a;
	else
		a_reg_comb = a_reg;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		b_reg <= 16'b0;
	else
		b_reg <= b_reg_comb;
		
always_comb
	if(next_state == S_in)
		b_reg_comb = in_b;
	else
		b_reg_comb = b_reg;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		mode_reg <= 1'b0;
	else
		mode_reg <= mode_reg_comb;

always_comb
	if(next_state == S_in)
		mode_reg_comb = mode;
	else
		mode_reg_comb = mode_reg;

//instance declaration	
add inst1(a_reg, b_reg, out_add);
multiply inst2(a_reg, b_reg, out_multiply);
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out <= 16'b0;
	else
		out <= out_comb;
		
always_comb
	if(next_state == S_out) begin
		if(mode_reg == 1'b0)
			out_comb = out_add;
		else
			out_comb = out_multiply;
		end
	else
		out_comb = 16'b0;

endmodule



module add(
		a_reg, b_reg, 
		out_add
);
input [15:0] a_reg, b_reg;
output logic [15:0] out_add;

logic a_sign, b_sign, sign;
logic signed [9:0] a_exp, b_exp, max_exp;
logic [7:0] a_frac, b_frac;
logic [8:0] a_frac_comp, b_frac_comp, a_frac_shift, b_frac_shift;
logic [8:0] sum;
logic [8:0] sum_comp;
logic [8:0] sum_shift1;
logic [6:0] sum_shift;
logic signed [10:0] out_exp;
logic signed [11:0] exp;

assign a_sign = a_reg[15];
assign b_sign = b_reg[15];
assign a_exp = ({1'b0, a_reg[14:7]}) - ({1'b0, 7'd127});	
assign b_exp = ({1'b0, b_reg[14:7]}) - ({1'b0, 7'd127});
assign a_frac = {1'b1, a_reg[6:0]};
assign b_frac = {1'b1, b_reg[6:0]};

assign max_exp = (a_exp > b_exp) ? a_exp : b_exp;

always_comb
	if(a_sign)
		a_frac_comp = ~{1'b0, a_frac_shift} + 1'b1;
	else
		a_frac_comp = {1'b0, a_frac_shift};
	
always_comb
	if(b_sign)
		b_frac_comp = ~{1'b0, b_frac_shift} + 1'b1;
	else
		b_frac_comp = {1'b0, b_frac_shift};

always_comb
	if(a_exp < max_exp)
		a_frac_shift = a_frac >> (max_exp - a_exp);
	else	
		a_frac_shift = a_frac;
		
always_comb
	if(b_exp < max_exp)
		b_frac_shift = b_frac >> (max_exp - b_exp);
	else
		b_frac_shift = b_frac;

assign sum = a_frac_comp + b_frac_comp;

always_comb
	if(a_sign == 1'b0 && b_sign == 1'b0)
		sign = 1'b0;
	else if(a_sign == 1'b1 && b_sign == 1'b1)
		sign = 1'b1;
	else if(a_sign == 1'b1 && b_sign == 1'b0 && a_frac_shift > b_frac_shift)
		sign = 1'b1;
	else if(a_sign == 1'b0 && b_sign == 1'b1 && a_frac_shift < b_frac_shift)
		sign = 1'b1;
	else
		sign = 1'b0;

always_comb
	if(sign)
		sum_comp = ~sum + 1'b1;
	else
		sum_comp = sum;

always_comb
	casez(sum_comp)
		9'b1????????: 	begin
						sum_shift1 = sum_comp << 1;
						out_exp = max_exp + 2'b01;
						end
		9'b01???????:	begin
						sum_shift1 = sum_comp << 2;
						out_exp = max_exp;
						end
		9'b001??????:	begin
						sum_shift1 = sum_comp << 3;
						out_exp = max_exp - 2'b01;
						end
		9'b0001?????:	begin	
						sum_shift1 = sum_comp << 4;
						out_exp = max_exp - 3'b010;
						end
		9'b00001????:	begin
						sum_shift1 = sum_comp << 5;
						out_exp = max_exp - 3'b011;
						end
		9'b000001???:	begin
						sum_shift1 = sum_comp << 6;
						out_exp = max_exp - 4'b0100;
						end
		9'b0000001??:	begin
						sum_shift1 = sum_comp << 7;
						out_exp = max_exp - 4'b0101;
						end
		9'b00000001?:	begin
						sum_shift1 = sum_comp << 8;
						out_exp = max_exp - 4'b0110;
						end
		9'b000000001:	begin
						sum_shift1 = sum_comp << 9;
						out_exp = max_exp - 4'b0111;
						end
		9'b000000000:	begin
						sum_shift1 = 9'b0;
						out_exp = max_exp;
						end
		default:		begin
						sum_shift1 = 9'b0;
						out_exp = max_exp;
						end
	endcase

assign sum_shift = sum_shift1[8:2];
assign exp = out_exp + {1'b0, 7'd127};
assign out_add = {sign, exp[7:0], sum_shift};

endmodule

module multiply(
		a_reg, b_reg,
		out_multiply
);
input [15:0] a_reg, b_reg;
output logic [15:0] out_multiply;

logic a_sign, b_sign, sign;
logic signed [8:0] a_exp, b_exp;
logic signed [9:0] out_exp;
logic signed [10:0] exp;
logic [7:0] a_frac, b_frac;
logic [15:0] result, result_shift1;
logic [6:0] result_shift;

assign a_sign = a_reg[15];
assign b_sign = b_reg[15];
assign a_exp = ({1'b0, a_reg[14:7]}) - ({2'b00, 7'd127});	
assign b_exp = ({1'b0, b_reg[14:7]}) - ({2'b00, 7'd127});	
	
assign a_frac = {1'b1, a_reg[6:0]};
assign b_frac = {1'b1, b_reg[6:0]};	

assign result = a_frac * b_frac;

always_comb
	casez(result)
		16'b1???????????????:	begin
								result_shift1 = result << 1;
								out_exp = a_exp + b_exp + 2'b01;
								end
		16'b01??????????????: 	begin
								result_shift1 = result << 2;
								out_exp = a_exp + b_exp;
								end
		16'b001?????????????:	begin
								result_shift1 = result << 3;
								out_exp = a_exp + b_exp - (2'b01);
								end
		16'b0001????????????:	begin
								result_shift1 = result << 4;
								out_exp = a_exp + b_exp - (3'b010);
								end
		16'b00001???????????:	begin
								result_shift1 = result << 5;
								out_exp = a_exp + b_exp - (3'b011);
								end
		16'b000001??????????:	begin
								result_shift1 = result << 6;
								out_exp = a_exp + b_exp - (4'b0100); 
								end
		16'b0000001?????????:	begin
								result_shift1 = result << 7;
								out_exp = a_exp + b_exp - (4'b0101);
								end
		16'b00000001????????:	begin
								result_shift1 = result << 8;
								out_exp = a_exp + b_exp - (4'b0110);
								end
		16'b000000001???????:	begin
								result_shift1 = result << 9;
								out_exp = a_exp + b_exp - (4'b0111);
								end
		16'b0000000001??????:	begin
								result_shift1 = result << 10;
								out_exp = a_exp + b_exp - (5'b01000);
								end
		16'b00000000001?????:	begin
								result_shift1 = result << 11;
								out_exp = a_exp + b_exp - (5'b01001);
								end
		16'b000000000001????:	begin
								result_shift1 = result << 12;
								out_exp = a_exp + b_exp - (5'b01010);
								end
		16'b0000000000001???:	begin
								result_shift1 = result << 13;
								out_exp = a_exp + b_exp - (5'b01011);
								end
		16'b00000000000001??:	begin
								result_shift1 = result << 14;
								out_exp = a_exp + b_exp - (5'b01100);
								end
		16'b000000000000001?:	begin
								result_shift1 = result << 15;
								out_exp = a_exp + b_exp - (5'b01101);
								end
		16'b0000000000000001:	begin
								result_shift1 = result << 16;					
								out_exp = a_exp + b_exp - (5'b01110);
								end
		16'b0000000000000000:	begin
								result_shift1 = 9'b0;
								out_exp = a_exp + b_exp;
								end
		default:				begin
								result_shift1 = 9'b0;
								out_exp = a_exp + b_exp;
								end
	endcase
	
assign result_shift[6:0] = result_shift1[15:9];
assign exp = out_exp + {1'b0, 7'd127};
assign sign = a_sign ^ b_sign;
assign out_multiply = {sign, exp[7:0], result_shift};

endmodule 							
