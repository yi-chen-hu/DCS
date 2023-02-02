module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [46:0] in_1, in_2;
input [47:0] in_3;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [95:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
//first DFF
logic [46:0] num1, num2, num1_comb, num2_comb;
logic [47:0] num3, num3_comb;
logic valid_1, valid_comb;

//second DFF
logic [47:0] A, B, A_comb;
logic valid_2;

//third DFF
logic [31:0] P1, P2, P3, P4, P5, P6, P7, P8, P9;
logic [31:0] P1_comb, P2_comb, P3_comb, P4_comb, P5_comb, P6_comb, P7_comb, P8_comb, P9_comb;
logic valid_3;
//forth DFF
logic [95:0] out_comb;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//first DFF
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n) begin
		num1 <= 47'b0;
		num2 <= 47'b0;
		num3 <= 48'b0;
		valid_1 <= 1'b0;
	end
	else begin
		num1 <= num1_comb;
		num2 <= num2_comb;
		num3 <= num3_comb;
		valid_1 <= valid_comb;
	end
	
always_comb
	if(in_valid) begin
		num1_comb = in_1;
		num2_comb = in_2;
		num3_comb = in_3;
		valid_comb = 1'b1;
	end
	else begin
		num1_comb = 47'b0;
		num2_comb = 47'b0;
		num3_comb = 48'b0;
		valid_comb = 1'b0;
	end
	
//second DFF
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n) begin
		A <= 48'b0;
		B <= 48'b0;
		valid_2 <= 1'b0;
	end
	else begin
		A <= A_comb;
		B <= num3;
		valid_2 <= valid_1;
	end
	
assign A_comb = num1 + num2;

//third DFF
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n) begin
		P1 <= 24'b0;
		P2 <= 24'b0;
		P3 <= 24'b0;
		P4 <= 24'b0;
		P5 <= 24'b0;
		P6 <= 24'b0;
		P7 <= 24'b0;
		P8 <= 24'b0;
		P9 <= 24'b0;
		valid_3 <= 1'b0;
	end
	else begin
		P1 <= P1_comb;
		P2 <= P2_comb;
		P3 <= P3_comb;
		P4 <= P4_comb;
		P5 <= P5_comb;
		P6 <= P6_comb;
		P7 <= P7_comb;
		P8 <= P8_comb;
		P9 <= P9_comb;
		valid_3 <= valid_2;
	end
	
always_comb begin
	P1_comb = A[15:0] * B[15:0];
	P2_comb = A[31:16] * B[15:0];
	P3_comb = A[47:32] * B[15:0];
	
	P4_comb = A[15:0] * B[31:16];
	P5_comb = A[31:16] * B[31:16];
	P6_comb = A[47:32] * B[31:16];
	
	P7_comb = A[15:0] * B[47:32];
	P8_comb = A[31:16] * B[47:32];
	P9_comb = A[47:32] * B[47:32];
	
end
		
//forth DFF
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n) begin
		out <= 96'b0;
		out_valid <= 1'b0;
	end
	else begin
		out <= out_comb;
		out_valid <= valid_3;
	end

assign out_comb = P1 + {P2, 16'b0} + {P3, 32'b0} + {P4, 16'b0} + {P5, 32'b0} + {P6, 48'b0} + {P7, 32'b0} + {P8, 48'b0} + {P9, 64'b0};


endmodule