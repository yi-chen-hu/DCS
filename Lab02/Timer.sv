module Timer(
    // Input signals
    in,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [4:0] in;
input in_valid,	rst_n,	clk;
output logic out_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0]in_;
logic [4:0]cnt;
logic [4:0]counter;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)
if(!rst_n)
	out_valid<=1'b0;
else if (cnt==counter+1'b1 && cnt!=5'b0)
	out_valid<=1'b1;
else
	out_valid<=1'b0;

assign in_=in_valid?in:5'b0;

always@(posedge clk or negedge rst_n)
if(!rst_n)
	cnt<=5'b0;
else if(in_)
	cnt<=in_;
else
	cnt<=cnt;
	
always@(posedge clk or negedge rst_n)
if(!rst_n)
	counter<=5'b0;
else if(in_)
	counter<=5'b0;
else
	counter<=counter+1'b1;

endmodule