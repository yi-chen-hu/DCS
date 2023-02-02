module Checkdigit(
    // Input signals
    in_num,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid,
    out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_num;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [3:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] counter;
logic [4:0] num;
logic [4:0] num_reg;
logic [3:0] answer;
logic [7:0] sum;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff@(posedge clk , negedge rst_n)
if(!rst_n)
	out_valid <= 1'b0;
else if(counter == 4'd15)
	out_valid <= 1'b1;
else
	out_valid <= 1'b0;

always_ff@(posedge clk , negedge rst_n)
if(!rst_n)
	out <= 4'b0;
else if(counter == 4'd15) begin
	if(answer == 4'd10)
		out <= 4'd15;
	else
		out <= answer;
	end
else
	out <= 4'b0;
	
always_ff@(posedge clk , negedge rst_n)
if(!rst_n)
	counter <= 4'b0;
else if(in_valid)
	counter <= counter + 1'b1;
else 
	counter <= 4'b0;

assign num = in_num * ((counter % 2 == 0) ? 2 : 1);

always_comb
	case(num)
		5'd18: num_reg = 5'd9;
		5'd16: num_reg = 5'd7;
		5'd14: num_reg = 5'd5;
		5'd12: num_reg = 5'd3;
		5'd10: num_reg = 5'd1;
		default: num_reg = num;
	endcase

always_ff@(posedge clk , negedge rst_n)
if(!rst_n)
	sum <= 7'd0;
else if(!in_valid)
	sum <= 7'd0;
else
	sum <= sum + num_reg;

assign answer = 10 - (sum % 10);

	

endmodule