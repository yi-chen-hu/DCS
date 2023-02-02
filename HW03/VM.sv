
module VM(
    //Input 
    clk,
    rst_n,
    in_item_valid,
    in_coin_valid,
    in_coin,
    in_rtn_coin,
    in_buy_item,
    in_item_price,
    //OUTPUT
    out_monitor,
    out_valid,
    out_consumer,
    out_sell_num
);

    //Input 
input clk;
input rst_n;
input in_item_valid;
input in_coin_valid;
input [5:0] in_coin;
input in_rtn_coin;
input [2:0] in_buy_item;
input [4:0] in_item_price;
    //OUTPUT
output logic [8:0] out_monitor;
output logic out_valid;
output logic [3:0] out_consumer;
output logic [5:0] out_sell_num;

//---------------------------------------------------------------------
//  Your design(Using FSM)                            
//---------------------------------------------------------------------
logic [4:0] item_price [0:5];
logic [4:0] item_price_comb[0:5];
logic less;
logic [8:0] out_monitor_reg, out_monitor_comb, out_monitor_reg_comb;
logic [2:0] in_buy_item_reg, in_buy_item_reg_comb;
logic [5:0] num [0:5];
logic [5:0] num_comb [0:5];
logic [3:0] out_consumer_comb;
logic out_valid_comb;
logic [5:0] out_sell_num_comb;
logic [4:0] state, next_state;

parameter S_idle = 0;
parameter S_item_1 = 1;
parameter S_item_2 = 2;
parameter S_item_3 = 3;
parameter S_item_4 = 4;
parameter S_item_5 = 5;
parameter S_item_6 = 6;
parameter S_wait = 7;
parameter S_coin = 8;
parameter S_rtn = 9;
parameter S_less_1 = 10;
parameter S_less_2 = 11;
parameter S_less_3 = 12;
parameter S_less_4 = 13;
parameter S_less_5 = 14;
parameter S_less_6 = 15;
parameter S_const = 16;
parameter S_buy = 17;
parameter S_out_1 = 18;
parameter S_out_2 = 19;
parameter S_out_3 = 20;
parameter S_out_4 = 21;
parameter S_out_5 = 22;
parameter S_out_6 = 23;

assign less = in_rtn_coin ? 1'b0 : (out_monitor < item_price[in_buy_item - 1'd1] && in_buy_item != 3'd0) ? 1'b1 : 1'b0;

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	state <= 5'b0;
else
	state <= next_state;

always_comb
	case(state)
		S_idle: next_state = in_item_valid ? S_item_1 : S_idle;
		S_item_1: next_state = S_item_2;
		S_item_2: next_state = S_item_3;
		S_item_3: next_state = S_item_4;
		S_item_4: next_state = S_item_5;
		S_item_5: next_state = S_item_6;
		S_item_6: next_state = in_coin_valid ? S_coin : S_wait;
		S_wait: next_state = in_coin_valid ? S_coin : in_item_valid ? S_item_1 : S_wait;
		S_coin: next_state = in_coin_valid ? S_coin : in_rtn_coin ? S_rtn : less ? S_less_1 : S_buy;
		S_less_1: next_state = S_less_2;
		S_less_2: next_state = S_less_3;
		S_less_3: next_state = S_less_4;
		S_less_4: next_state = S_less_5;
		S_less_5: next_state = S_less_6;
		S_less_6: next_state = in_coin_valid ? S_coin : in_item_valid ? S_item_1 : S_const;
		S_const: next_state = in_coin_valid ? S_coin : in_item_valid ? S_item_1 : S_const;
		S_rtn: next_state = S_out_1;
		S_buy: next_state = S_out_1;
		S_out_1: next_state = S_out_2;
		S_out_2: next_state = S_out_3;
		S_out_3: next_state = S_out_4;
		S_out_4: next_state = S_out_5;
		S_out_5: next_state = S_out_6;
		S_out_6: next_state = in_item_valid ? S_item_1 : (in_coin_valid ? S_coin : S_wait);
	default: next_state = S_idle;
	endcase
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[0] <= 5'd0;
else 
	item_price[0] <= item_price_comb[0];

always_comb
if(next_state == S_item_1)
	item_price_comb[0] = in_item_price;
else
	item_price_comb[0] = item_price[0];
 
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[1] <= 5'd0;
else 
	item_price[1] <= item_price_comb[1];
	
always_comb
if(next_state == S_item_2)
	item_price_comb[1] = in_item_price;
else 
	item_price_comb[1] = item_price[1];
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[2] <= 5'd0;
else 
	item_price[2] <= item_price_comb[2];

always_comb
if(next_state == S_item_3)
	item_price_comb[2] = in_item_price;
else
	item_price_comb[2] = item_price[2];
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[3] <= 5'd0;
else 
	item_price[3] <= item_price_comb[3];
	
always_comb
if(next_state == S_item_4)
	item_price_comb[3] = in_item_price;
else
	item_price_comb[3] = item_price[3];
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[4] <= 5'd0;
else 
	item_price[4] <= item_price_comb[4];
	
always_comb
if(next_state == S_item_5)
	item_price_comb[4] = in_item_price;
else
	item_price_comb[4] = item_price[4];
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	item_price[5] <= 5'd0;
else 
	item_price[5] <= item_price_comb[5];

always_comb
if(next_state == S_item_6)
	item_price_comb[5] = in_item_price;
else
	item_price_comb[5] = item_price[5];

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	out_monitor <= 9'd0;
else 
	out_monitor <= out_monitor_comb;
	
always_comb
if(next_state == S_coin)
	out_monitor_comb = out_monitor + in_coin;
else if(next_state == S_buy || next_state == S_rtn)
	out_monitor_comb = 9'd0;
else
	out_monitor_comb = out_monitor;


always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	out_monitor_reg <= 9'd0;
else 
	out_monitor_reg <= out_monitor_reg_comb;

always_comb
if(next_state == S_buy)
	out_monitor_reg_comb = out_monitor - item_price[in_buy_item - 1'd1];
else if(next_state == S_rtn)
	out_monitor_reg_comb = out_monitor;
else if(next_state == S_out_1)
	out_monitor_reg_comb = out_monitor_reg;
else if(next_state == S_out_2)
	out_monitor_reg_comb = out_monitor_reg % 50;
else if(next_state == S_out_3)
	out_monitor_reg_comb = out_monitor_reg % 20;
else if(next_state == S_out_4)
	out_monitor_reg_comb = out_monitor_reg % 10;
else if(next_state == S_out_5)
	out_monitor_reg_comb = out_monitor_reg % 5;
else
	out_monitor_reg_comb = 9'd0;
	
always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	in_buy_item_reg <= 3'd0;
else
	in_buy_item_reg <= in_buy_item_reg_comb;
	
always_comb
if(next_state == S_buy)
	in_buy_item_reg_comb = in_buy_item;
else
	in_buy_item_reg_comb = 3'd0;

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	for(int i = 0; i < 6; i = i + 1)
		num[i] <= 6'd0;
else
	for(int i = 0; i < 6; i = i + 1)
		num[i] <= num_comb[i];

always_comb
if(next_state == S_item_1)
	num_comb[0] = 6'd0;
else if(next_state == S_buy && in_buy_item == 1) 
	num_comb[0] = num[0] + 1'd1;
else
	num_comb[0] = num[0];

always_comb
if(next_state == S_item_1)
	num_comb[1] = 6'd0;
else if(next_state == S_buy && in_buy_item == 2) 
	num_comb[1] = num[1] + 1'd1;
else
	num_comb[1] = num[1];
	
always_comb
if(next_state == S_item_1)
	num_comb[2] = 6'd0;
else if(next_state == S_buy && in_buy_item == 3) 
	num_comb[2] = num[2] + 1'd1;
else
	num_comb[2] = num[2];
	
always_comb
if(next_state == S_item_1)
	num_comb[3] = 6'd0;
else if(next_state == S_buy && in_buy_item == 4) 
	num_comb[3] = num[3] + 1'd1;
else
	num_comb[3] = num[3];
	
always_comb
if(next_state == S_item_1)
	num_comb[4] = 6'd0;
else if(next_state == S_buy && in_buy_item == 5) 
	num_comb[4] = num[4] + 1'd1;
else
	num_comb[4] = num[4];
	
always_comb
if(next_state == S_item_1)
	num_comb[5] = 6'd0;
else if(next_state == S_buy && in_buy_item == 6) 
	num_comb[5] = num[5] + 1'd1;
else
	num_comb[5] = num[5];

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	out_valid <= 1'b0;
else 
	out_valid <= out_valid_comb;
	
always_comb
if(next_state == S_out_1 || next_state == S_out_2 || next_state == S_out_3 
		|| next_state == S_out_4 || next_state == S_out_5 || next_state == S_out_6
		|| next_state == S_less_1 || next_state == S_less_2 || next_state == S_less_3
		|| next_state == S_less_4 || next_state == S_less_5 || next_state == S_less_6)
	out_valid_comb = 1'b1;
else
	out_valid_comb = 1'b0;


always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	out_consumer <= 4'd0;
else 
	out_consumer <= out_consumer_comb;
	
always_comb
if(next_state == S_out_1)
	out_consumer_comb = in_buy_item_reg;
else if(next_state == S_out_2)
	out_consumer_comb = out_monitor_reg / 50;
else if(next_state == S_out_3)
	out_consumer_comb = out_monitor_reg / 20;
else if(next_state == S_out_4)
	out_consumer_comb = out_monitor_reg / 10;
else if(next_state == S_out_5)
	out_consumer_comb = out_monitor_reg / 5;
else if(next_state == S_out_6)
	out_consumer_comb = out_monitor_reg;
else
	out_consumer_comb = 4'd0;

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
	out_sell_num <= 6'd0;
else 
	out_sell_num <= out_sell_num_comb;
	
always_comb
if(next_state == S_less_1 || next_state == S_out_1)
	out_sell_num_comb = num[0];
else if(next_state == S_less_2 || next_state == S_out_2)
	out_sell_num_comb = num[1];
else if(next_state == S_less_3 || next_state == S_out_3)
	out_sell_num_comb = num[2];
else if(next_state == S_less_4 || next_state == S_out_4)
	out_sell_num_comb = num[3];
else if(next_state == S_less_5 || next_state == S_out_5)
	out_sell_num_comb = num[4];
else if(next_state == S_less_6 || next_state == S_out_6)
	out_sell_num_comb = num[5];
else
	out_sell_num_comb = 6'd0;

endmodule


