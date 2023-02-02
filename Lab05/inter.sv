module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  in_valid_3,
  data_in_1,
  data_in_2,
  data_in_3,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2, in_valid_3;
input [6:0] data_in_1, data_in_2, data_in_3; 
input ready_slave1, ready_slave2;
output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;
//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
parameter S_idle = 3'd0; 
parameter S_master1 = 3'd1;
parameter S_master2 = 3'd2;
parameter S_master3 = 3'd3;
parameter S_handshake = 3'd4;

logic [2:0] state, next_state;
logic [6:0] data_in_1_reg, data_in_2_reg, data_in_3_reg;
logic in_valid_1_reg, in_valid_2_reg, in_valid_3_reg;

always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		in_valid_1_reg <= 1'b0;
	else if(state == S_master1)
		in_valid_1_reg <= 1'b0;
	else if(in_valid_1)
		in_valid_1_reg <= in_valid_1;
	else
		in_valid_1_reg <= in_valid_1_reg;

always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		in_valid_2_reg <= 1'b0;
	else if(state == S_master2)
		in_valid_2_reg <= 1'b0;
	else if(in_valid_2)
		in_valid_2_reg <= in_valid_2;
	else
		in_valid_2_reg <= in_valid_2_reg;

always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		in_valid_3_reg <= 1'b0;
	else if(state == S_master3)
		in_valid_3_reg <= 1'b0;
	else if(in_valid_3)
		in_valid_3_reg <= in_valid_3;
	else
		in_valid_3_reg <= in_valid_3_reg;

always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		data_in_1_reg <= 7'b0;
	else if(in_valid_1)
		data_in_1_reg <= data_in_1;
	else
		data_in_1_reg <= data_in_1_reg;
		
always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		data_in_2_reg <= 7'b0;
	else if(in_valid_2)
		data_in_2_reg <= data_in_2;
	else
		data_in_2_reg <= data_in_2_reg;

always_ff@( posedge clk, negedge rst_n)
	if(!rst_n)
		data_in_3_reg <= 7'b0;
	else if(in_valid_3)
		data_in_3_reg <= data_in_3;
	else
		data_in_3_reg <= data_in_3_reg;

always_comb
	case(state)
		S_idle: next_state = ( in_valid_1_reg == 1 ) ? S_master1 : (( in_valid_2_reg == 1 ) ? S_master2 : ( in_valid_3_reg == 1 ) ? S_master3 : S_idle );
		S_master1: next_state = ( !data_in_1_reg[6] && ready_slave1 ) ? S_handshake : (( data_in_1_reg[6] && ready_slave2 ) ? S_handshake : S_master1 );
		S_master2: next_state = ( !data_in_2_reg[6] && ready_slave1 ) ? S_handshake : (( data_in_2_reg[6] && ready_slave2 ) ? S_handshake : S_master2 );
		S_master3: next_state = ( !data_in_3_reg[6] && ready_slave1 ) ? S_handshake : (( data_in_3_reg[6] && ready_slave2 ) ? S_handshake : S_master3 );
		S_handshake: next_state = ( !in_valid_1_reg && in_valid_2_reg ) ? S_master2 : (( !in_valid_1_reg && !in_valid_2_reg && in_valid_3_reg ) ? S_master3 : S_idle );
		default: next_state = S_idle;
	endcase

always_ff@( posedge clk, negedge rst_n )
	if(!rst_n)
		state <= 3'd0;
	else
		state <= next_state;

always_ff@( posedge clk, negedge rst_n)	//handshake_slave1
	if(!rst_n)
		handshake_slave1 <= 1'b0;
	else if(next_state == S_handshake && (!data_in_1_reg[6] || !data_in_2_reg[6] || !data_in_3_reg[6]))
		handshake_slave1 <= 1'b1; 
	else
		handshake_slave1 <= 1'b0;
		
always_ff@( posedge clk, negedge rst_n)	//handshake_slave2
	if(!rst_n)
		handshake_slave2 <= 1'b0;
	else if(next_state == S_handshake && (data_in_1_reg[6] || data_in_2_reg[6] || data_in_3_reg[6]))
		handshake_slave2 <= 1'b1;
	else
		handshake_slave2 <= 1'b0;
		
always_ff@( posedge clk, negedge rst_n)	//valid_slave1
	if(!rst_n)
		valid_slave1 <= 1'b0;
	else if(next_state == S_master1 && !data_in_1_reg[6])
		valid_slave1 <= 1'b1;
	else if(next_state == S_master2 && !data_in_2_reg[6])
		valid_slave1 <= 1'b1;
	else if(next_state == S_master3 && !data_in_3_reg[6])
		valid_slave1 <= 1'b1;
	else
		valid_slave1 <= 1'b0;

always_ff@( posedge clk, negedge rst_n)	//valid_slave2
	if(!rst_n)
		valid_slave2 <= 1'b0;
	else if(next_state == S_master1 && data_in_1_reg[6])
		valid_slave2 <= 1'b1;
	else if(next_state == S_master2 && data_in_2_reg[6])
		valid_slave2 <= 1'b1;
	else if(next_state == S_master3 && data_in_3_reg[6])
		valid_slave2 <= 1'b1;
	else
		valid_slave2 <= 1'b0;
		
always_ff@( posedge clk, negedge rst_n)	//addr_out
	if(!rst_n)
		addr_out <= 3'b0;
	else if(next_state == S_master1)
		addr_out <= data_in_1_reg[5:3];
	else if(next_state == S_master2)
		addr_out <= data_in_2_reg[5:3];
	else if(next_state == S_master3)
		addr_out <= data_in_3_reg[5:3];
	else
		addr_out <= 3'b0;

always_ff@( posedge clk, negedge rst_n)	//value_out
	if(!rst_n)
		value_out <= 3'b0;
	else if(next_state == S_master1)
		value_out <= data_in_1_reg[2:0];
	else if(next_state == S_master2)
		value_out <= data_in_2_reg[2:0];
	else if(next_state == S_master3)
		value_out <= data_in_3_reg[2:0];
	else
		value_out <= 3'b0;


endmodule
