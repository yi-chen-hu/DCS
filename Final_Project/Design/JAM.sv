module JAM(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_cost,
  // Output signals
	out_valid,
    out_job,
	out_cost
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [6:0] in_cost;
output logic out_valid;
output logic [3:0] out_job;
output logic [9:0] out_cost;
 
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] state, next_state;

logic [6:0] cost[0:63], cost_comb[0:63];
logic [6:0] cnt_in, cnt_in_comb;

//logic [9:0] sum;
logic [9:0] min_cost, min_cost_comb; 
logic [15:0] cnt_compute, cnt_compute_comb;
logic [2:0] p, p_comb;
logic [3:0] idx, idx_comb;
logic [2:0] min_idx, min_idx_comb;
logic [2:0] job[0:7], job_comb[0:7];
logic [2:0] best_job[0:7], best_job_comb[0:7];
logic [3:0] cnt_out, cnt_out_comb;

//output logic 
logic out_valid_comb;
logic [3:0] out_job_comb;
logic [9:0] out_cost_comb;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
parameter S_IDLE = 0;
parameter S_IN = 1;
parameter S_COMPUTE = 2;
parameter S_P = 3;
parameter S_IDX = 4;
parameter S_MINIDX = 5;
parameter S_IDXPLUS = 6;
parameter S_DOSWAP = 7;
parameter S_REVERSE = 8;
parameter S_OUT = 9;
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
		S_IDLE: 		next_state = in_valid ? S_IN : S_IDLE;
		S_IN: 			next_state = cnt_in == 64 ? S_COMPUTE : S_IN;
		S_COMPUTE: 		next_state = cnt_compute == 40320 ? S_OUT : S_P;
		S_P: 			next_state = S_MINIDX;
		S_MINIDX:		next_state = idx >= 8 ? S_DOSWAP : S_MINIDX;
		S_DOSWAP:		next_state = S_REVERSE;
		S_REVERSE:		next_state = S_COMPUTE;
		S_OUT:			next_state = cnt_out == 8 ? S_IDLE : S_OUT;
		default: 		next_state = S_IDLE;
	endcase
	

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(int i = 0; i < 64; i = i + 1)
			cost[i] = 0;
	else
		for(int i = 0; i < 64; i = i + 1)
			cost[i] = cost_comb[i];
		
always_comb
	if(next_state == S_IN)
		for(int i = 0; i < 64; i = i + 1)
			if(i == cnt_in)
				cost_comb[i] = in_cost;
			else
				cost_comb[i] = cost[i];
	else
		for(int i = 0; i < 64; i = i + 1)
			cost_comb[i] = cost[i];
			
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
		min_cost <= 10'b0;
	else
		min_cost <= min_cost_comb;
		
//cost[job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]] + cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]];

always_comb
	if(cnt_compute == 0 && next_state == S_COMPUTE)
		min_cost_comb = cost[0] + cost[9] + cost[18] + cost[27] + cost[36] + cost[45] + cost[54] + cost[63];
	else if(next_state == S_COMPUTE)
		min_cost_comb = cost[job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]] + cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]] < min_cost ? cost[job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]] + cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]] : min_cost;
	else
		min_cost_comb = min_cost;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		cnt_compute <= 0;
	else
		cnt_compute <= cnt_compute_comb;
		
always_comb
	if(next_state == S_IDLE)
		cnt_compute_comb = 0;
	else if(next_state == S_COMPUTE)
		cnt_compute_comb = cnt_compute + 1;
	else
		cnt_compute_comb = cnt_compute;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		p <= 0;
	else
		p <= p_comb;
		
always_comb
	if(next_state == S_P) begin
		if(job[6] < job[7])
			p_comb = 6;
		else if(job[5] < job[6])
			p_comb = 5;
		else if(job[4] < job[5])
			p_comb = 4;
		else if(job[3] < job[4])
			p_comb = 3;
		else if(job[2] < job[3])
			p_comb = 2;
		else if(job[1] < job[2])
			p_comb = 1;
		else if(job[0] < job[1])
			p_comb = 0;
		else
			p_comb = 7;
	end
	else
		p_comb = p;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)	
		idx = 0;
	else
		idx = idx_comb;
		
always_comb
	if(next_state == S_P)	
		idx_comb = p_comb + 1;
	else if(next_state == S_MINIDX)
		idx_comb = idx + 1;
	else
		idx_comb = idx;
		
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		min_idx <= 0;
	else
		min_idx <= min_idx_comb;
		
always_comb
	if(state == S_P && next_state == S_MINIDX)
		min_idx_comb = idx;
	else if(next_state == S_MINIDX && job[idx] < job[min_idx] && job[idx] > job[p])
		min_idx_comb = idx;
	else
		min_idx_comb = min_idx;
		
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(int i = 0; i < 8; i = i + 1)
			job[i] <= 0;
	else
		for(int i = 0; i < 8; i = i + 1)
			job[i] <= job_comb[i];
			
always_comb
	if(next_state == S_IDLE)
		for(int i = 0; i < 8; i = i + 1)
			job_comb[i] = i;
	else if(next_state == S_DOSWAP) begin
		for(int i = 0; i < 8; i = i + 1)
			if(i == p)
				job_comb[i] = job[min_idx];
			else if(i == min_idx)
				job_comb[i] = job[p];
			else
				job_comb[i] = job[i];
	end
	else if(next_state == S_REVERSE) begin
		case(p)
			0: begin
				job_comb[0] = job[0];
				job_comb[1] = job[7];
				job_comb[2] = job[6];
				job_comb[3] = job[5];
				job_comb[4] = job[4];
				job_comb[5] = job[3];
				job_comb[6] = job[2];
				job_comb[7] = job[1];
			end
			1: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[7];
				job_comb[3] = job[6];
				job_comb[4] = job[5];
				job_comb[5] = job[4];
				job_comb[6] = job[3];
				job_comb[7] = job[2];
			end
			2: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[7];
				job_comb[4] = job[6];
				job_comb[5] = job[5];
				job_comb[6] = job[4];
				job_comb[7] = job[3];
			end
			3: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[3];
				job_comb[4] = job[7];
				job_comb[5] = job[6];
				job_comb[6] = job[5];
				job_comb[7] = job[4];
			end
			4: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[3];
				job_comb[4] = job[4];
				job_comb[5] = job[7];
				job_comb[6] = job[6];
				job_comb[7] = job[5];
			end
			5: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[3];
				job_comb[4] = job[4];
				job_comb[5] = job[5];
				job_comb[6] = job[7];
				job_comb[7] = job[6];
			end
			6: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[3];
				job_comb[4] = job[4];
				job_comb[5] = job[5];
				job_comb[6] = job[6];
				job_comb[7] = job[7];
			end
			7: begin
				job_comb[0] = job[0];
				job_comb[1] = job[1];
				job_comb[2] = job[2];
				job_comb[3] = job[3];
				job_comb[4] = job[4];
				job_comb[5] = job[5];
				job_comb[6] = job[6];
				job_comb[7] = job[7];
			end	
		endcase
	end
	else
		for(int i = 0; i < 8; i = i + 1)
			job_comb[i] = job[i];

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(int i = 0; i < 8; i = i + 1)
			best_job[i] <= 0;
	else
		for(int i = 0; i < 8; i = i + 1)
			best_job[i] <= best_job_comb[i];
		
		
//cost[job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]] + cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]];

always_comb
	if(next_state == S_IDLE)
		for(int i = 0; i < 8; i = i + 1)
				best_job_comb[i] = i;
	else if(next_state == S_COMPUTE) begin
		if(cost[job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]] + cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]] < min_cost) begin
			for(int i = 0; i < 8; i = i + 1)
				best_job_comb[i] = job[i];	
		end
		else
			for(int i = 0; i < 8; i = i + 1)
				best_job_comb[i] = best_job[i];
	end	
	else
		for(int i = 0; i < 8; i = i + 1)
			best_job_comb[i] = best_job[i];

			
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

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_valid <= 0;
	else
		out_valid <= out_valid_comb;

always_comb
	if(next_state == S_OUT)
		out_valid_comb = 1'b1;
	else
		out_valid_comb = 0;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_cost <= 0;
	else
		out_cost <= out_cost_comb;
		
always_comb
	if(next_state == S_OUT)
		out_cost_comb = min_cost;
	else
		out_cost_comb = 0;
		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_job <= 0;
	else
		out_job <= out_job_comb;
		
always_comb
	if(next_state == S_OUT)
		out_job_comb <= best_job[cnt_out] + 1;
	else
		out_job_comb <= 0;

		
endmodule
