module Maxmin(
    // input signals
	in_num,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out_max,
	out_min
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [7:0] in_num;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [7:0] out_max, out_min;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] counter;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		counter<=4'b0;
	else if(!in_valid)
		counter<=4'b0;
	else 
		counter<=counter+1'b1;

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		out_valid<=1'b0;
	else if(counter==4'd14)
		out_valid<=1'b1;
	else
		out_valid<=1'b0;
		
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		out_max<=8'b0;
	else if(!in_valid)
		out_max<=8'b0;
	else 
		out_max<=(in_num>out_max)?in_num:out_max;

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		out_min<=8'd255;
	else if(!in_valid)
		out_min<=8'd255;
	else 
		out_min<=(out_min<in_num)?out_min:in_num;
		
		

endmodule