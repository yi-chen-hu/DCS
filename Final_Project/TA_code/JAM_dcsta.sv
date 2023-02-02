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
logic valid_d1, valid_d2;
logic [6:0] in_cost_d1;
logic [6:0] cost[0:63], cost_nxt[0:63];
logic [6:0] reduced_cost[0:63], reduced_cost_nxt[0:63];
logic [6:0] row_cost_f[0:7], row_cost_s[0:7], sub_cost[0:7];
logic [6:0] trans_cost[0:63];
logic [6:0] minimum, minimum_nxt, minimum_unmask, minimum_unmask_nxt, minimum_row;
logic mask[0:63], mask_nxt[0:63];
logic [7:0] mask_row, mask_row_nxt, mask_col, mask_col_nxt;
logic mask_row_min, mask_row_sub;
logic [3:0] r_cnt, r_cnt_nxt;
logic [3:0] step, step_nxt;

logic [7:0] stripe_row, stripe_col;
logic stripe_valid;
logic [3:0] stripe_sum;
logic out_valid_d1;
integer cycles;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
enum logic [2:0] {IDLE  = 3'b000,
				  R_MIN = 3'b001,
				  TRANS = 3'b011,
				  ZERO  = 3'b010,
				  WAIT  = 3'b110,
				  F_MIN = 3'b111,
				  R_UMIN= 3'b101,
				  DFS  = 3'b100
				 } curr_state, next_state;
				 
//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		valid_d1 <= 0;
		valid_d2 <= 0;
		in_cost_d1 <= 0;
		out_valid_d1 <= 0;
		// cycles <= 0;
	end
	else begin
		valid_d1 <= in_valid;
		valid_d2 <= valid_d1;
		in_cost_d1 <= in_cost;
		out_valid_d1 <= out_valid;
		// case (curr_state)
		// R_MIN, TRANS: begin
			// cycles = cycles+1;
			// $display("cycle:", cycles);
		// end
		// endcase
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always_comb begin
	case (curr_state)
	IDLE: begin
		if (!valid_d1 && valid_d2) 
			next_state = R_MIN;
		else 
			next_state = IDLE;
	end
	R_MIN: begin
		if (r_cnt == 8)
			next_state = TRANS;
		else
			next_state = R_MIN;
	end
	TRANS: begin
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", reduced_cost[8*j], reduced_cost[8*j+1], reduced_cost[8*j+2], reduced_cost[8*j+3], reduced_cost[8*j+4], reduced_cost[8*j+5], reduced_cost[8*j+6], reduced_cost[8*j+7]);
		// end
		if (step==3'd1)
			next_state = ZERO;
		else
			next_state = R_MIN;
	end
	ZERO: begin
		next_state = WAIT;
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", reduced_cost[8*j], reduced_cost[8*j+1], reduced_cost[8*j+2], reduced_cost[8*j+3], reduced_cost[8*j+4], reduced_cost[8*j+5], reduced_cost[8*j+6], reduced_cost[8*j+7]);
		// end
	end
	WAIT: begin
		if (stripe_valid)
			if (stripe_sum<8)
				next_state = F_MIN;
			else
				next_state = DFS;
		else
			next_state = WAIT;
	end
	F_MIN: begin
		if (r_cnt == 7)
			next_state = R_UMIN;
		else
			next_state = F_MIN;
	end
	R_UMIN: begin
		if (r_cnt == 8)
			next_state = ZERO;
		else
			next_state = R_UMIN;
	end
	DFS: begin
		// if (!out_valid && out_valid_d1)
			next_state = IDLE;
		// else
			// next_state = DFS;
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", reduced_cost[8*j], reduced_cost[8*j+1], reduced_cost[8*j+2], reduced_cost[8*j+3], reduced_cost[8*j+4], reduced_cost[8*j+5], reduced_cost[8*j+6], reduced_cost[8*j+7]);
		// end
	end
	default: begin
		next_state = IDLE;
	end
	endcase
end
//---------------------------------------------------------------------
//   Input                  
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<64; i=i+1) 
			cost[i] <= 0;
	end
	else begin
		for (int i=0; i<64; i=i+1)
			cost[i] <= cost_nxt[i];
	end
end

always_comb begin
	if (valid_d1) begin
		cost_nxt[63] = in_cost_d1;
		for (int j=0; j<63; j=j+1)
			cost_nxt[j] = cost[j+1];
	end
	else begin
		for (int j=0; j<64; j=j+1)
			cost_nxt[j] = cost[j];
	end
end
//---------------------------------------------------------------------
//   Reduced matrix                  
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<64; i=i+1) 
			reduced_cost[i] <= 0;
	end
	else begin
		for (int i=0; i<64; i=i+1)
			reduced_cost[i] <= reduced_cost_nxt[i];
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<64; i=i+1) 
			mask[i] <= 0;
	end
	else begin
		for (int i=0; i<64; i=i+1)
			mask[i] <= mask_nxt[i];
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		mask_row <= 0;
		mask_col <= 0;
	end
	else begin
		mask_row <= mask_row_nxt;
		mask_col <= mask_col_nxt;
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		minimum <= 0;
	end
	else begin
		minimum <= minimum_nxt;
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_cnt <= 0;
		step <= 0;
	end
	else begin
		r_cnt <= r_cnt_nxt;
		step <= step_nxt;
	end
end

always_comb begin
	case (curr_state)
	R_MIN: 
		r_cnt_nxt = r_cnt + 1;
	F_MIN: begin
		if (r_cnt == 7)
			r_cnt_nxt = 1;
		else
			r_cnt_nxt = r_cnt + 1;
	end
	R_UMIN: begin
		if (r_cnt == 8)
			r_cnt_nxt = 0;
		else
			r_cnt_nxt = r_cnt + 1;
	end
	default: 
		r_cnt_nxt = 0;
	endcase
end

// assign r_cnt_nxt = (curr_state==R_MIN) ? r_cnt + 1 : 0;
// assign step_nxt = (curr_state==TRANS) ? step + 1 : step;
always_comb begin
	case (curr_state)
	IDLE:
		step_nxt = 0;
	TRANS: 
		step_nxt = step + 1;
	default: 
		step_nxt = step;
	endcase
end


always_comb begin
	mask_row_nxt = mask_row;
	mask_col_nxt = mask_col;
	case (curr_state)
	IDLE: begin
		mask_row_nxt = 0;
		mask_col_nxt = 0;
	end
	WAIT: begin
		if (stripe_valid) begin
			mask_row_nxt = ~stripe_row;
			mask_col_nxt = stripe_col;
		end
	end
	endcase
end

always_comb begin
	minimum_nxt = minimum_row;
	case (curr_state)
	IDLE: begin
		minimum_nxt = minimum_row;
	end
	R_MIN: begin
		minimum_nxt = minimum_row;
	end
	WAIT: begin
		minimum_nxt = 127;
	end
	F_MIN: begin
		if (minimum > minimum_row)
			minimum_nxt = minimum_row;
		else
			minimum_nxt = minimum;
	end
	R_UMIN: begin
		minimum_nxt = minimum;
	end
	endcase
end

assign stripe_sum = stripe_col[0] + stripe_col[1] + stripe_col[2] + stripe_col[3] + 
				    stripe_col[4] + stripe_col[5] + stripe_col[6] + stripe_col[7] + 
				   !stripe_row[0] +!stripe_row[1] +!stripe_row[2] +!stripe_row[3] + 
				   !stripe_row[4] +!stripe_row[5] +!stripe_row[6] +!stripe_row[7];

always_comb begin
	for (int i=0; i<8; i=i+1) begin
		case(r_cnt)
			4'd0: row_cost_f[i] = reduced_cost[i];
			4'd1: row_cost_f[i] = reduced_cost[i+8];
			4'd2: row_cost_f[i] = reduced_cost[i+16];
			4'd3: row_cost_f[i] = reduced_cost[i+24];
			4'd4: row_cost_f[i] = reduced_cost[i+32];
			4'd5: row_cost_f[i] = reduced_cost[i+40];
			4'd6: row_cost_f[i] = reduced_cost[i+48];
			4'd7: row_cost_f[i] = reduced_cost[i+56];
			default: row_cost_f [i] = 0;
		endcase
		case(r_cnt)
			4'd1: row_cost_s[i] = reduced_cost[i];
			4'd2: row_cost_s[i] = reduced_cost[i+8];
			4'd3: row_cost_s[i] = reduced_cost[i+16];
			4'd4: row_cost_s[i] = reduced_cost[i+24];
			4'd5: row_cost_s[i] = reduced_cost[i+32];
			4'd6: row_cost_s[i] = reduced_cost[i+40];
			4'd7: row_cost_s[i] = reduced_cost[i+48];
			4'd8: row_cost_s[i] = reduced_cost[i+56];
			default: row_cost_s [i] = 0;
		endcase
	end 
	case(r_cnt)
		4'd0: mask_row_min = mask_row[0];
		4'd1: mask_row_min = mask_row[1];
		4'd2: mask_row_min = mask_row[2];
		4'd3: mask_row_min = mask_row[3];
		4'd4: mask_row_min = mask_row[4];
		4'd5: mask_row_min = mask_row[5];
		4'd6: mask_row_min = mask_row[6];
		4'd7: mask_row_min = mask_row[7];
		default: mask_row_min = 1;
	endcase
	case(r_cnt)
		4'd1: mask_row_sub = mask_row[0];
		4'd2: mask_row_sub = mask_row[1];
		4'd3: mask_row_sub = mask_row[2];
		4'd4: mask_row_sub = mask_row[3];
		4'd5: mask_row_sub = mask_row[4];
		4'd6: mask_row_sub = mask_row[5];
		4'd7: mask_row_sub = mask_row[6];
		4'd8: mask_row_sub = mask_row[7];
		default: mask_row_sub = 1;
	endcase
end

always_comb begin
	for (int j=0; j<64; j=j+1)
		reduced_cost_nxt[j] = reduced_cost[j];
		
	case (curr_state)
	IDLE: begin
		if (valid_d1) begin
			reduced_cost_nxt[63] = in_cost_d1;
			for (int j=0; j<63; j=j+1)
				reduced_cost_nxt[j] = reduced_cost[j+1];
		end
		else begin
			for (int j=0; j<64; j=j+1)
				reduced_cost_nxt[j] = reduced_cost[j];
		end
	end
	R_MIN, R_UMIN: begin
		for (int i=0; i<8; i=i+1) begin
			case(r_cnt)
				4'd1: reduced_cost_nxt[i]    = sub_cost[i];
				4'd2: reduced_cost_nxt[i+8]  = sub_cost[i];
				4'd3: reduced_cost_nxt[i+16] = sub_cost[i];
				4'd4: reduced_cost_nxt[i+24] = sub_cost[i];
				4'd5: reduced_cost_nxt[i+32] = sub_cost[i];
				4'd6: reduced_cost_nxt[i+40] = sub_cost[i];
				4'd7: reduced_cost_nxt[i+48] = sub_cost[i];
				4'd8: reduced_cost_nxt[i+56] = sub_cost[i];
			endcase
		end 
	end
	TRANS: begin
		reduced_cost_nxt = trans_cost;
	end
	endcase
end

Transpose_7 Transpose_7(
	.matrix_in	(reduced_cost), 
	.matrix_out	(trans_cost)
);

Find_min Find_min_row (
	.row_0		(row_cost_f[0]),
	.row_1		(row_cost_f[1]),
	.row_2		(row_cost_f[2]),
	.row_3		(row_cost_f[3]),
	.row_4		(row_cost_f[4]),
	.row_5		(row_cost_f[5]),
	.row_6		(row_cost_f[6]),
	.row_7		(row_cost_f[7]),
	.mask_row	(mask_row_min),
	.mask_col	(mask_col),
	.minimum	(minimum_row)
);

Sub_min Sub_min_row (
	.row_0		(row_cost_s[0]),
	.row_1		(row_cost_s[1]),
	.row_2		(row_cost_s[2]),
	.row_3		(row_cost_s[3]),
	.row_4		(row_cost_s[4]),
	.row_5		(row_cost_s[5]),
	.row_6		(row_cost_s[6]),
	.row_7		(row_cost_s[7]),
	.mask_row	(mask_row_sub),
	.mask_col	(mask_col),
	.minimum	(minimum),	
	.row_nxt_0	(sub_cost[0]),
	.row_nxt_1	(sub_cost[1]),
	.row_nxt_2	(sub_cost[2]),
	.row_nxt_3	(sub_cost[3]),
	.row_nxt_4	(sub_cost[4]),
	.row_nxt_5	(sub_cost[5]),
	.row_nxt_6	(sub_cost[6]),
	.row_nxt_7	(sub_cost[7])
);

Zero_stripe Zero_stripe_0(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(curr_state==ZERO),
	.matrix_in	(reduced_cost),
	.out_valid	(stripe_valid),
	.mask_row	(stripe_row),
	.mask_col	(stripe_col)
);

Find_sol Find_sol_0(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(curr_state==DFS),
	.matrix_in	(reduced_cost),
	.matrix_cost(cost),
	.out_valid	(out_valid),
	.out_job	(out_job),
	.out_cost	(out_cost)
);


//---------------------------------------------------------------------
//   Output                        
//---------------------------------------------------------------------
// always@(posedge clk or negedge rst_n) begin
	// if (!rst_n) begin
		// out_valid <= 0;
		// out_job   <= 0;
		// out_cost  <= 0;
	// end
	// else begin
		// out_valid <= 0;
		// out_job   <= 0;
		// out_cost  <= 0;
	// end
// end


endmodule


module Find_min(
  // Input signals
	row_0,
	row_1,
	row_2,
	row_3,
	row_4,
	row_5,
	row_6,
	row_7,
	mask_row,
	mask_col,
  // Output signals
	minimum
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [6:0] row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7;
input mask_row;
input [7:0] mask_col;
output logic [6:0] minimum;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] comp_lv0 [0:7];
logic [6:0] comp_lv1 [0:3];
logic [6:0] comp_lv2 [0:1];
integer i;

assign comp_lv0[0] = (mask_col[0]) ? 7'd127 : row_0;
assign comp_lv0[1] = (mask_col[1]) ? 7'd127 : row_1;
assign comp_lv0[2] = (mask_col[2]) ? 7'd127 : row_2;
assign comp_lv0[3] = (mask_col[3]) ? 7'd127 : row_3;
assign comp_lv0[4] = (mask_col[4]) ? 7'd127 : row_4;
assign comp_lv0[5] = (mask_col[5]) ? 7'd127 : row_5;
assign comp_lv0[6] = (mask_col[6]) ? 7'd127 : row_6;
assign comp_lv0[7] = (mask_col[7]) ? 7'd127 : row_7;

always_comb begin
	for (i=0; i<4; i=i+1) begin
		if (comp_lv0[2*i] > comp_lv0[2*i+1])
			comp_lv1[i] = comp_lv0[2*i+1];
		else
			comp_lv1[i] = comp_lv0[2*i];
	end
	
	for (i=0; i<2; i=i+1) begin
		if (comp_lv1[2*i] > comp_lv1[2*i+1])
			comp_lv2[i] = comp_lv1[2*i+1];
		else
			comp_lv2[i] = comp_lv1[2*i];
	end
	
	if (mask_row)
		minimum = 7'd127;
	else begin
		if (comp_lv2[0] > comp_lv2[1])
			minimum = comp_lv2[1];
		else
			minimum = comp_lv2[0];
	end
end

endmodule


module Sub_min(
  // Input signals
	row_0,
	row_1,
	row_2,
	row_3,
	row_4,
	row_5,
	row_6,
	row_7,
	mask_row,
	mask_col,
	minimum,
  // Output signals
	row_nxt_0,
	row_nxt_1,
	row_nxt_2,
	row_nxt_3,
	row_nxt_4,
	row_nxt_5,
	row_nxt_6,
	row_nxt_7
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [6:0] row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7;
input mask_row;
input [7:0] mask_col;
input [6:0] minimum;
output logic [6:0] row_nxt_0, row_nxt_1, row_nxt_2, row_nxt_3, row_nxt_4, row_nxt_5, row_nxt_6, row_nxt_7;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
assign row_nxt_0 = (mask_row && mask_col[0]) ? row_0 + minimum :
				   (!mask_row&&!mask_col[0]) ? row_0 - minimum :
					                           row_0 ;
assign row_nxt_1 = (mask_row && mask_col[1]) ? row_1 + minimum :
				   (!mask_row&&!mask_col[1]) ? row_1 - minimum :
					                           row_1 ;
assign row_nxt_2 = (mask_row && mask_col[2]) ? row_2 + minimum :
				   (!mask_row&&!mask_col[2]) ? row_2 - minimum :
					                           row_2 ;
assign row_nxt_3 = (mask_row && mask_col[3]) ? row_3 + minimum :
				   (!mask_row&&!mask_col[3]) ? row_3 - minimum :
					                           row_3 ;
assign row_nxt_4 = (mask_row && mask_col[4]) ? row_4 + minimum :
				   (!mask_row&&!mask_col[4]) ? row_4 - minimum :
					                           row_4 ;
assign row_nxt_5 = (mask_row && mask_col[5]) ? row_5 + minimum :
				   (!mask_row&&!mask_col[5]) ? row_5 - minimum :
					                           row_5 ;
assign row_nxt_6 = (mask_row && mask_col[6]) ? row_6 + minimum :
				   (!mask_row&&!mask_col[6]) ? row_6 - minimum :
					                           row_6 ;
assign row_nxt_7 = (mask_row && mask_col[7]) ? row_7 + minimum :
				   (!mask_row&&!mask_col[7]) ? row_7 - minimum :
					                           row_7 ;

// assign row_nxt_1 = (mask_row || mask_col[1]) ? row_1 : row_1 - minimum;
// assign row_nxt_2 = (mask_row || mask_col[2]) ? row_2 : row_2 - minimum;
// assign row_nxt_3 = (mask_row || mask_col[3]) ? row_3 : row_3 - minimum;
// assign row_nxt_4 = (mask_row || mask_col[4]) ? row_4 : row_4 - minimum;
// assign row_nxt_5 = (mask_row || mask_col[5]) ? row_5 : row_5 - minimum;
// assign row_nxt_6 = (mask_row || mask_col[6]) ? row_6 : row_6 - minimum;
// assign row_nxt_7 = (mask_row || mask_col[7]) ? row_7 : row_7 - minimum;
 
endmodule

module Transpose_2(
  // Input signals
	matrix_in,
  // Output signals
	matrix_out
);
parameter BIT = 2;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [BIT-1:0] matrix_in [0:63];
output logic [BIT-1:0] matrix_out [0:63];
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
integer i, j;

always_comb begin
	for (j=0; j<8; j=j+1)
		for (i=0; i<8; i=i+1)
			matrix_out[8*j+i] = matrix_in[8*i+j];
end
 
endmodule

module Transpose_7(
  // Input signals
	matrix_in,
  // Output signals
	matrix_out
);

parameter BIT = 7;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [BIT-1:0] matrix_in [0:63];
output logic [BIT-1:0] matrix_out [0:63];
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
integer i, j;

always_comb begin
	for (j=0; j<8; j=j+1)
		for (i=0; i<8; i=i+1)
			matrix_out[8*j+i] = matrix_in[8*i+j];
end
 
endmodule

module Zero_stripe(
  // Input signals
	clk,
	rst_n,
	in_valid,
	matrix_in,
  // Output signals
	out_valid,
	mask_row,
	mask_col
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [6:0] matrix_in [0:63];
output logic [7:0] mask_row;
output logic [7:0] mask_col;
output logic out_valid;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [1:0] zero_map [0:63], zero_map_nxt [0:63], trans_map [0:63]; 
logic free_zero [0:63];
//0: non-zero, 1: free zero, 2: circled zero, 3: scribed zero 
logic [3:0] z_cnt, z_cnt_nxt;
logic step, step_nxt;
logic [1:0] zero_row [0:7], scribed_zero_col[0:7];
logic [7:0] free_zero_row, circled_zero, circled_zero_col;
logic [7:0] circled_zero_row;
// logic [2:0] circled_zero;
logic [63:0] scribed_zero;
logic [2:0] free_znum, circled_znum, zero_num;
logic only_zero, found, found_nxt;
logic [7:0] mark;
logic [7:0] mask_row_nxt, mask_col_nxt;
logic out_valid_nxt;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
enum logic [2:0] {IDLE  = 3'b000,
				  FREEZ = 3'b001,
				  TRANS = 3'b011,
				  CROSS = 3'b010,
				  LINE1 = 3'b110,
				  LINE2 = 3'b111,
				  LINE3 = 3'b101,
				  STOP  = 3'b100
				 } curr_state, next_state;
				 
//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		curr_state <= IDLE;
	else 
		curr_state <= next_state;
end

always_comb begin
	case(curr_state)
	IDLE: begin
		if (in_valid) 
			next_state = FREEZ;
		else 
			next_state = IDLE;
	end
	FREEZ: begin
		if (z_cnt[2:0] == 7)
			next_state = TRANS;
		else
			next_state = FREEZ;
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", zero_map[8*j], zero_map[8*j+1], zero_map[8*j+2], zero_map[8*j+3], zero_map[8*j+4], zero_map[8*j+5], zero_map[8*j+6], zero_map[8*j+7]);
		// end
	end
	TRANS: begin
		if (step == 0) begin
			if (z_cnt == 8)
				next_state = FREEZ;
			else // if (z_cnt == 0)
				next_state = CROSS;
		end
		else begin
			if (z_cnt == 8)
				next_state = LINE3;
			else // if (z_cnt == 0)
				if (found)
					next_state = LINE2;
				else
					next_state = STOP;
		end
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", zero_map[8*j], zero_map[8*j+1], zero_map[8*j+2], zero_map[8*j+3], zero_map[8*j+4], zero_map[8*j+5], zero_map[8*j+6], zero_map[8*j+7]);
		// end
	end
	CROSS: begin
		if (z_cnt[2:0] == 7) begin
			if (found_nxt)
				next_state = FREEZ;
			else
				next_state = LINE1;
		end
		else
			next_state = CROSS;
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", zero_map[8*j], zero_map[8*j+1], zero_map[8*j+2], zero_map[8*j+3], zero_map[8*j+4], zero_map[8*j+5], zero_map[8*j+6], zero_map[8*j+7]);
		// end
	end
	LINE1: begin
		if (z_cnt[2:0] == 7)
			next_state = LINE2;
		else
			next_state = LINE1;
	end
	LINE2: begin
		if (z_cnt[2:0] == 7) begin
			if (found_nxt)
				next_state = TRANS;
			else
				next_state = STOP;
		end
		else
			next_state = LINE2;
	end
	LINE3: begin
		if (z_cnt[2:0] == 7) 
			next_state = TRANS;
		else
			next_state = LINE3;
	end
	STOP: begin
		next_state = IDLE;
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", zero_map[8*j], zero_map[8*j+1], zero_map[8*j+2], zero_map[8*j+3], zero_map[8*j+4], zero_map[8*j+5], zero_map[8*j+6], zero_map[8*j+7]);
		// end
		// $display("-");
		// for (int j=0;j<8;j=j+1) begin
		// $display("%3d %3d %3d %3d %3d %3d %3d %3d", 
		// !mask_row[j]||mask_col[0], !mask_row[j]||mask_col[1], !mask_row[j]||mask_col[2], !mask_row[j]||mask_col[3], 
		// !mask_row[j]||mask_col[4], !mask_row[j]||mask_col[5], !mask_row[j]||mask_col[6], !mask_row[j]||mask_col[7]);
		// end
	end
	endcase
end
//---------------------------------------------------------------------
//   Design
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<64; i=i+1)
			zero_map[i] <= 0;
	end
	else begin
		zero_map <= zero_map_nxt;
	end
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		z_cnt <= 0;
	else 
		z_cnt <= z_cnt_nxt;
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		step <= 0;
	else 
		step <= step_nxt;
end

always_comb begin
	case(curr_state)
	IDLE:  step_nxt = 0;
	FREEZ: step_nxt = 0;
	TRANS: step_nxt = step;
	CROSS: step_nxt = 0;
	LINE1: step_nxt = 1;
	LINE2: step_nxt = 1;
	LINE3: step_nxt = 1;
	STOP:  step_nxt = 1;
	endcase
end

always_comb begin
	case(curr_state)
	IDLE:  z_cnt_nxt = 0;
	FREEZ: z_cnt_nxt = z_cnt + 1;
	TRANS: z_cnt_nxt = z_cnt;
	CROSS: begin
		if (z_cnt==7)
			z_cnt_nxt = 0;
		else
			z_cnt_nxt = z_cnt + 1;
	end
	LINE1: begin
		if (z_cnt==7)
			z_cnt_nxt = 0;
		else
			z_cnt_nxt = z_cnt + 1;
	end
	LINE2: z_cnt_nxt = z_cnt + 1;
	LINE3: z_cnt_nxt = z_cnt + 1;
	STOP: z_cnt_nxt = z_cnt;
	endcase
end

always_comb begin
	zero_map_nxt = zero_map;
	case(curr_state)
	IDLE: begin
		if (in_valid) begin
			for (int i=0; i<64; i=i+1)
				zero_map_nxt[i] = (matrix_in[i]==0);
		end
		else begin
			for (int i=0; i<64; i=i+1)
				zero_map_nxt[i] = zero_map[i];
		end
	end
	FREEZ: begin
		if (only_zero) begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+8]  + scribed_zero[i+8] *2;
				zero_map_nxt[i+8]  = zero_map[i+16] + scribed_zero[i+16]*2;
				zero_map_nxt[i+16] = zero_map[i+24] + scribed_zero[i+24]*2;
				zero_map_nxt[i+24] = zero_map[i+32] + scribed_zero[i+32]*2;
				zero_map_nxt[i+32] = zero_map[i+40] + scribed_zero[i+40]*2;
				zero_map_nxt[i+40] = zero_map[i+48] + scribed_zero[i+48]*2;
				zero_map_nxt[i+48] = zero_map[i+56] + scribed_zero[i+56]*2;
				zero_map_nxt[i+56] = zero_map[i]    + scribed_zero[i]     ;
				// case (z_cnt[2:0])
				// 3'd0: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]     ;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd1: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8]   ;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd2: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]  ;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd3: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]  ;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd4: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]  ;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd5: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]  ;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd6: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]  ;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]*2;
				// end
				// 3'd7: begin 
					// zero_map_nxt[i]    = zero_map[i]    + scribed_zero[i]   *2;
					// zero_map_nxt[i+8]  = zero_map[i+8]  + scribed_zero[i+8] *2;
					// zero_map_nxt[i+16] = zero_map[i+16] + scribed_zero[i+16]*2;
					// zero_map_nxt[i+24] = zero_map[i+24] + scribed_zero[i+24]*2;
					// zero_map_nxt[i+32] = zero_map[i+32] + scribed_zero[i+32]*2;
					// zero_map_nxt[i+40] = zero_map[i+40] + scribed_zero[i+40]*2;
					// zero_map_nxt[i+48] = zero_map[i+48] + scribed_zero[i+48]*2;
					// zero_map_nxt[i+56] = zero_map[i+56] + scribed_zero[i+56]  ;
				// end
				// endcase
			end
		end
		else begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+8] ;
				zero_map_nxt[i+8]  = zero_map[i+16];
				zero_map_nxt[i+16] = zero_map[i+24];
				zero_map_nxt[i+24] = zero_map[i+32];
				zero_map_nxt[i+32] = zero_map[i+40];
				zero_map_nxt[i+40] = zero_map[i+48];
				zero_map_nxt[i+48] = zero_map[i+56];
				zero_map_nxt[i+56] = zero_map[i]   ;
			end
			// zero_map_nxt = zero_map;
		end
	end
	TRANS: begin
		zero_map_nxt = trans_map;
	end
	CROSS: begin
		if (found) begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+8] ;
				zero_map_nxt[i+8]  = zero_map[i+16];
				zero_map_nxt[i+16] = zero_map[i+24];
				zero_map_nxt[i+24] = zero_map[i+32];
				zero_map_nxt[i+32] = zero_map[i+40];
				zero_map_nxt[i+40] = zero_map[i+48];
				zero_map_nxt[i+48] = zero_map[i+56];
				zero_map_nxt[i+56] = zero_map[i]   ;
			end
		end
		else begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+8]  + scribed_zero[i+8] *2;
				zero_map_nxt[i+8]  = zero_map[i+16] + scribed_zero[i+16]*2;
				zero_map_nxt[i+16] = zero_map[i+24] + scribed_zero[i+24]*2;
				zero_map_nxt[i+24] = zero_map[i+32] + scribed_zero[i+32]*2;
				zero_map_nxt[i+32] = zero_map[i+40] + scribed_zero[i+40]*2;
				zero_map_nxt[i+40] = zero_map[i+48] + scribed_zero[i+48]*2;
				zero_map_nxt[i+48] = zero_map[i+56] + scribed_zero[i+56]*2;
				zero_map_nxt[i+56] = zero_map[i]    + scribed_zero_col[i];
			end
		end
	end
	LINE1, LINE2, LINE3: begin
		for (int i=0; i<8; i=i+1) begin
			zero_map_nxt[i]    = zero_map[i+8] ;
			zero_map_nxt[i+8]  = zero_map[i+16];
			zero_map_nxt[i+16] = zero_map[i+24];
			zero_map_nxt[i+24] = zero_map[i+32];
			zero_map_nxt[i+32] = zero_map[i+40];
			zero_map_nxt[i+40] = zero_map[i+48];
			zero_map_nxt[i+48] = zero_map[i+56];
			zero_map_nxt[i+56] = zero_map[i]   ;
		end
	end
	endcase
end


always_comb begin
	mask_row_nxt = mask_row;
	mask_col_nxt = mask_col;
	case(curr_state)
	IDLE: begin
		mask_row_nxt = mask_row;
		mask_col_nxt = mask_col;
	end
	FREEZ: begin
		mask_row_nxt = 0;
		mask_col_nxt = 0;
	end
	TRANS: begin
		mask_row_nxt = mask_col;
		mask_col_nxt = mask_row;
	end
	CROSS: begin
		mask_row_nxt = 0;
		mask_col_nxt = 0;
	end
	LINE1: begin
		for (int i=0; i<7; i=i+1) 
			mask_row_nxt[i] = mask_row[i+1];
		mask_row_nxt[7] = (mark == 0);
		mask_col_nxt = 0;
	end
	LINE2, LINE3: begin
		for (int i=0; i<7; i=i+1) 
			mask_row_nxt[i] = mask_row[i+1];
		mask_row_nxt[7] = mask_row[0];
		// if (mask_row[0])
			mask_col_nxt = mask_col | mark;
		// else
			// mask_col_nxt = mask_col;
	end
	endcase
end

always_comb begin
	case(curr_state)
	FREEZ: begin
		for (int i=0; i<8; i=i+1) 
			mark[i] = zero_map[i] == 1;
	end
	CROSS: begin
		for (int i=0; i<8; i=i+1) 
			mark[i] = zero_map[i] == 1;
	end
	LINE1: begin
		for (int i=0; i<8; i=i+1) 
			mark[i] = zero_map[i] == 2;
	end
	LINE2: begin
		for (int i=0; i<8; i=i+1) 
			mark[i] = (zero_map[i] == 3) && !mask_col[i] && mask_row[0];
	end
	LINE3:begin
		for (int i=0; i<8; i=i+1) 
			mark[i] = (zero_map[i] == 2) && !mask_col[i] && mask_row[0];
	end
	default: mark = 0;
	endcase
end

// always_comb begin
	// for (int i=0; i<8; i=i+1) begin
		// case (z_cnt[2:0])
		// 3'd0: zero_row[i] = zero_map[i];
		// 3'd1: zero_row[i] = zero_map[i+8];
		// 3'd2: zero_row[i] = zero_map[i+16];
		// 3'd3: zero_row[i] = zero_map[i+24];
		// 3'd4: zero_row[i] = zero_map[i+32];
		// 3'd5: zero_row[i] = zero_map[i+40];
		// 3'd6: zero_row[i] = zero_map[i+48];
		// 3'd7: zero_row[i] = zero_map[i+56];
		// endcase
	// end
// end

always_comb begin
	// for (int i=0; i<8; i=i+1) 
		// free_zero_row[i] = zero_map[i] == 1;
	// free_znum = free_zero_row[0] + free_zero_row[1] + free_zero_row[2] + free_zero_row[3] + free_zero_row[4] + free_zero_row[5] + free_zero_row[6] + free_zero_row[7];
	zero_num = mark[0] + mark[1] + mark[2] + mark[3] + mark[4] + mark[5] + mark[6] + mark[7];
	only_zero = zero_num == 1;
	
	if (mark[0]) begin
		circled_zero = 1;       //8'b0000_0001
		circled_zero_col = 254; //8'b1111_1110
	end
	else if (mark[1]) begin
		circled_zero = 2;       //8'b0000_0010
		circled_zero_col = 252; //8'b1111_1100
	end
	else if (mark[2]) begin
		circled_zero = 4;       //8'b0000_0100
		circled_zero_col = 248; //8'b1111_1000
	end
	else if (mark[3]) begin
		circled_zero = 8;       //8'b0000_1000
		circled_zero_col = 240; //8'b1111_0000
	end
	else if (mark[4]) begin
		circled_zero = 16;      //8'b0001_0000
		circled_zero_col = 224; //8'b1110_0000
	end
	else if (mark[5]) begin
		circled_zero = 32;      //8'b0010_0000
		circled_zero_col = 192; //8'b1100_0000
	end
	else if (mark[6]) begin
		circled_zero = 64;      //8'b0100_0000
		circled_zero_col = 128; //8'b1000_0000
	end
	else if (mark[7]) begin
		circled_zero = 128;     //8'b1000_0000
		circled_zero_col = 0;   //8'b0000_0000
	end
	else begin
		circled_zero = 0;
		circled_zero_col = 0;
	end
		
	for (int j=0; j<8; j=j+1) 
		for (int i=0; i<8; i=i+1) 
			free_zero[8*j+i] = (zero_map[8*j+i]==1);
			
	for (int j=0; j<8; j=j+1) 
		for (int i=0; i<8; i=i+1) 
			scribed_zero[8*j+i] = free_zero[8*j+i] && circled_zero[i];
	for (int i=0; i<8; i=i+1)
		scribed_zero_col[i] = ((zero_map[i]==1) && circled_zero[i]) + 2*((zero_map[i]==1) && circled_zero_col[i]);
end

// always_comb begin
	// for (int i=0; i<8; i=i+1) 
		// circled_zero_row[i] = zero_map[i] == 2;
	// circled_znum = circled_zero_row[0] + circled_zero_row[1] + circled_zero_row[2] + circled_zero_row[3] + circled_zero_row[4] + circled_zero_row[5] + circled_zero_row[6] + circled_zero_row[7];
// end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		found <= 0;
	else 
		found <= found_nxt;
end

always_comb begin
	case(curr_state)
	CROSS, LINE2, LINE3: 
		found_nxt = found || (zero_num!=0);
	// LINE2, LINE3: 
		// found_nxt = found || (zero_num!=0);
	default: 
		found_nxt = 0;
	endcase
end

Transpose_2 Transpose_2(
	.matrix_in	(zero_map), 
	.matrix_out	(trans_map)
);

assign out_valid_nxt = curr_state == STOP;

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		mask_row <= 0;
		mask_col <= 0;
		out_valid <= 0;
	end
	else begin
		mask_row <= mask_row_nxt;
		mask_col <= mask_col_nxt;
		out_valid <= out_valid_nxt;
	end
end

endmodule

module Find_sol(
  // Input signals
	clk,
	rst_n,
	in_valid,
	matrix_in,
	matrix_cost,
  // Output signals
	out_valid,
	out_job,
	out_cost
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [6:0] matrix_in [0:63];
input [6:0] matrix_cost [0:63];
output logic out_valid;
output logic [3:0] out_job;
output logic [9:0] out_cost;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic zero_map [0:63], zero_map_nxt [0:63]; 
logic [7:0] zero_row;
logic [7:0] job_mask, job_mask_nxt;
logic [3:0] out_job_reg [0:7];
logic [3:0] out_job_nxt [0:7], sel_job;
logic [2:0] r_cnt, r_cnt_nxt;
logic [7:0] unmask, mask, remain_zero, rear_zero;
logic [6:0] worker_cost[0:7];
logic found;
logic [9:0] total_cost, total_cost_nxt;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
enum logic [1:0] {IDLE  = 2'b00,
				  SEARCH= 2'b01,
				  CAL   = 2'b11,
				  STOP  = 2'b10
				 } curr_state, next_state;
				 
//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		curr_state <= IDLE;
	else 
		curr_state <= next_state;
end

always_comb begin
	case(curr_state)
	IDLE: begin
		if (in_valid) 
			next_state = SEARCH;
		else 
			next_state = IDLE;
	end
	SEARCH: begin
		if (found && r_cnt==7)
			next_state = CAL;
		else
			next_state = SEARCH;
	end
	CAL: begin
		next_state = STOP;
	end
	STOP: begin
		if (r_cnt==7)
			next_state = IDLE;
		else
			next_state = STOP;
	end
	endcase
end
//---------------------------------------------------------------------
//   Design
//---------------------------------------------------------------------

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<64; i=i+1)
			zero_map[i] <= 0;
	end
	else begin
		zero_map <= zero_map_nxt;
	end
end

always_comb begin
	zero_map_nxt = zero_map;
	case(curr_state)
	IDLE: begin
		if (in_valid) begin
			for (int i=0; i<64; i=i+1)
				zero_map_nxt[i] = (matrix_in[i]==0);
		end
		else begin
			for (int i=0; i<64; i=i+1)
				zero_map_nxt[i] = zero_map[i];
		end
	end
	SEARCH: begin
		if (found) begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+8] ;
				zero_map_nxt[i+8]  = zero_map[i+16];
				zero_map_nxt[i+16] = zero_map[i+24];
				zero_map_nxt[i+24] = zero_map[i+32];
				zero_map_nxt[i+32] = zero_map[i+40];
				zero_map_nxt[i+40] = zero_map[i+48];
				zero_map_nxt[i+48] = zero_map[i+56];
				zero_map_nxt[i+56] = zero_map[i]   ;
			end
		end
		else begin
			for (int i=0; i<8; i=i+1) begin
				zero_map_nxt[i]    = zero_map[i+56] ;
				zero_map_nxt[i+8]  = zero_map[i];
				zero_map_nxt[i+16] = zero_map[i+8] ;
				zero_map_nxt[i+24] = zero_map[i+16];
				zero_map_nxt[i+32] = zero_map[i+24];
				zero_map_nxt[i+40] = zero_map[i+32];
				zero_map_nxt[i+48] = zero_map[i+40];
				zero_map_nxt[i+56] = zero_map[i+48];
			end
		end
	end
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (int i=0; i<8; i=i+1)
			out_job_reg[i] <= 0;
	end
	else begin
		out_job_reg <= out_job_nxt;
	end
end

always_comb begin
	out_job_nxt = out_job_reg;
	case(curr_state)
	IDLE: begin
		if (in_valid) begin
			for (int i=0; i<8; i=i+1)
				out_job_nxt[i] = 0;
		end
		else 
			out_job_nxt = out_job_reg;
	end
	SEARCH: begin
		if (found) begin
			for (int i=0; i<7; i=i+1)
				out_job_nxt[i] = out_job_reg[i+1];
			out_job_nxt[7] = sel_job;
		end
		else begin
			for (int i=1; i<7; i=i+1)
				out_job_nxt[i+1] = out_job_reg[i];
			out_job_nxt[1] = sel_job;
			out_job_nxt[0] = out_job_reg[7];
		end
	end
	STOP: 
		out_job_nxt = out_job_reg;
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		job_mask <= 0;
	end
	else begin
		job_mask <= job_mask_nxt;
	end
end

always_comb begin
	for (int i=0; i<8; i=i+1)
		zero_row[i] = zero_map[i] ;
		
	case (out_job_reg[7])
	4'd1: unmask = 8'b1111_1110;
	4'd2: unmask = 8'b1111_1101;
	4'd3: unmask = 8'b1111_1011;
	4'd4: unmask = 8'b1111_0111;
	4'd5: unmask = 8'b1110_1111;
	4'd6: unmask = 8'b1101_1111;
	4'd7: unmask = 8'b1011_1111;
	4'd8: unmask = 8'b0111_1111;
	default: unmask = 8'b1111_1111;
	endcase
	
	case (out_job_reg[0])
	4'd0: rear_zero = 8'b1111_1111;
	4'd1: rear_zero = 8'b1111_1110;
	4'd2: rear_zero = 8'b1111_1100;
	4'd3: rear_zero = 8'b1111_1000;
	4'd4: rear_zero = 8'b1111_0000;
	4'd5: rear_zero = 8'b1110_0000;
	4'd6: rear_zero = 8'b1100_0000;
	4'd7: rear_zero = 8'b1000_0000;
	default: rear_zero = 8'b0000_0000;
	endcase
	
	remain_zero = ~job_mask & zero_row & rear_zero;
	
	if (remain_zero[0]) begin 
		mask = 8'b0000_0001; 
		sel_job = 1;
	end
	else if (remain_zero[1]) begin 
		mask = 8'b0000_0010; 
		sel_job = 2;
	end
	else if (remain_zero[2]) begin 
		mask = 8'b0000_0100; 
		sel_job = 3;
	end
	else if (remain_zero[3]) begin 
		mask = 8'b0000_1000; 
		sel_job = 4;
	end
	else if (remain_zero[4]) begin 
		mask = 8'b0001_0000; 
		sel_job = 5;
	end
	else if (remain_zero[5]) begin 
		mask = 8'b0010_0000; 
		sel_job = 6;
	end
	else if (remain_zero[6]) begin 
		mask = 8'b0100_0000;
		sel_job = 7;
	end
	else if (remain_zero[7]) begin 
		mask = 8'b1000_0000; 
		sel_job = 8;
	end
	else begin
		mask = 8'b0000_0000;
		sel_job = 0;
	end
	
	if (remain_zero == 0)
		found = 0;
	else
		found = 1;
end

always_comb begin
	job_mask_nxt = job_mask;
	case (curr_state)
	IDLE: begin
		if (in_valid) 
			job_mask_nxt = 0;
		else
			job_mask_nxt = job_mask;
	end
	SEARCH: begin
		if (found) begin
			job_mask_nxt = job_mask | mask;
		end
		else begin
			job_mask_nxt = job_mask & unmask;
		end
	end
	STOP: job_mask_nxt = job_mask;
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		r_cnt <= 0;
	else 
		r_cnt <= r_cnt_nxt;
end

always_comb begin
	case (curr_state)
	IDLE: 
		r_cnt_nxt = 0;
	SEARCH: begin
		if (found)
			r_cnt_nxt = r_cnt + 1;
		else
			r_cnt_nxt = r_cnt - 1;
	end
	STOP: r_cnt_nxt = r_cnt + 1;
	default: 
		r_cnt_nxt = 0;
	endcase
end

always_comb begin
	for (int i=0; i<8; i=i+1) begin
		case (out_job_reg[i][2:0])
		3'd0: worker_cost[i] = matrix_cost[7+8*i];
		3'd1: worker_cost[i] = matrix_cost[0+8*i];
		3'd2: worker_cost[i] = matrix_cost[1+8*i];
		3'd3: worker_cost[i] = matrix_cost[2+8*i];
		3'd4: worker_cost[i] = matrix_cost[3+8*i];
		3'd5: worker_cost[i] = matrix_cost[4+8*i];
		3'd6: worker_cost[i] = matrix_cost[5+8*i];
		3'd7: worker_cost[i] = matrix_cost[6+8*i];
		endcase
	end
	total_cost_nxt = worker_cost[0] + worker_cost[1] + worker_cost[2] + worker_cost[3] + 
					 worker_cost[4] + worker_cost[5] + worker_cost[6] + worker_cost[7];
end

always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		total_cost <= 0;
	else 
		total_cost <= total_cost_nxt;
end

always_comb begin
	if (curr_state == STOP) begin
		out_valid = 1;
		case(r_cnt)
		3'd0: out_job = out_job_reg[0];
		3'd1: out_job = out_job_reg[1];
		3'd2: out_job = out_job_reg[2];
		3'd3: out_job = out_job_reg[3];
		3'd4: out_job = out_job_reg[4];
		3'd5: out_job = out_job_reg[5];
		3'd6: out_job = out_job_reg[6];
		3'd7: out_job = out_job_reg[7];
		endcase
		out_cost = total_cost;
	end
	else begin
		out_valid = 0;
		out_job = 0;
		out_cost = 0;
	end
end

endmodule