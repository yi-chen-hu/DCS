`include "synchronizer.v"
module CDC(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			in_a,
			mode,
			in_b,
		  //  Output signals
			out_valid,
			out
			);		
input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_a,in_b;
input mode;
output logic out_valid;
output logic [7:0]out; 			




//---------------------------------------------------------------------
//   your design  (Using synchronizer)       
// Example :
//logic P,Q,Y;
//synchronizer x5(.D(P),.Q(Y),.clk(clk_2),.rst_n(rst_n));           
//---------------------------------------------------------------------		
logic [1:0] state, next_state;
logic p, p_comb, q, q_comb;
logic [3:0] in_1, in_1_comb, in_2, in_2_comb;
logic Mode, Mode_comb;
logic out_valid_comb;
logic [7:0]out_comb;
logic CDC_res;
logic [7:0] result, result_comb; 
//FSM
parameter S_IDLE = 2'd0;
parameter S_COMPUTE = 2'd1;
parameter S_OUT = 2'd2;

always_ff@(posedge clk_2, negedge rst_n)
	if(!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;

always_comb
	case(state)
		S_IDLE: 	next_state = CDC_res ? S_COMPUTE : S_IDLE;
		S_COMPUTE: 	next_state = S_OUT;
		S_OUT :		next_state = S_IDLE;
		default:	next_state = S_IDLE;
	endcase
	
always_ff@(posedge clk_1, negedge rst_n)
	if(!rst_n)
		p <= 1'b0;
	else
		p <= p_comb;

assign p_comb = p ^ in_valid;

always_ff@(posedge clk_2, negedge rst_n)
	if(!rst_n)
		q <= 1'b0;
	else
		q <= q_comb;

synchronizer x5(.D(p),.Q(q_comb),.clk(clk_2),.rst_n(rst_n));

assign CDC_res = q ^ q_comb;

//input DFF		
always_ff@(posedge clk_1, negedge rst_n)
	if(!rst_n)
		in_1 <= 4'b0;
	else
		in_1 <= in_1_comb;
		
always_comb
	if(in_valid)
		in_1_comb = in_a;
	else
		in_1_comb = in_1;
		
always_ff@(posedge clk_1, negedge rst_n)
	if(!rst_n)
		in_2 <= 4'b0;
	else
		in_2 <= in_2_comb;
		
always_comb
	if(in_valid)
		in_2_comb = in_b;
	else
		in_2_comb = in_2;

always_ff@(posedge clk_1, negedge rst_n)
	if(!rst_n)
		Mode <= 1'b0;
	else
		Mode <= Mode_comb;
		
always_comb
	if(in_valid)
		Mode_comb = mode;
	else
		Mode_comb = Mode;

//output DFF		
always_ff@(posedge clk_2, negedge rst_n)
	if(!rst_n)
		out_valid <= 1'b0;
	else
		out_valid <= out_valid_comb;
			
always_comb
	if(next_state == S_OUT)
		out_valid_comb = 1'b1;
	else
		out_valid_comb = 1'b0;
		
always_ff@(posedge clk_2, negedge rst_n)
	if(!rst_n)
		out <= 8'b0;
	else
		out <= out_comb;
		
always_comb
	if(next_state == S_OUT )
		out_comb = result;
	else
		out_comb = 8'b0;

always_ff@(posedge clk_2, negedge rst_n)
	if(!rst_n)
		result <= 8'b0;
	else
		result <= result_comb;
		
always_comb
	if(next_state == S_COMPUTE)begin
		if(Mode == 1'b1)
			result_comb = in_1 * in_2;
		else
			result_comb = in_1 + in_2;
	end
	else
		result_comb = 8'b0;


		
endmodule