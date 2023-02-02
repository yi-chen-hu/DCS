module CN(
    // Input signals
    opcode,
	in_n0,
	in_n1,
	in_n2,
	in_n3,
	in_n4,
	in_n5,
    // Output signals
    out_n
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
input [4:0] opcode;
output logic [8:0] out_n;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] n0, n1, n2, n3, n4, n5;
logic [4:0] n0_11, n1_11, n2_11, n3_11, n4_11, n5_11;   //ascend result
logic [4:0] n0_10, n1_10, n2_10, n3_10, n4_10, n5_10;	//descebd result
logic [4:0] n0_01, n1_01, n2_01, n3_01, n4_01, n5_01;	//reverse result
logic [4:0] n0_out, n1_out, n2_out, n3_out, n4_out, n5_out;	//the result after mux of opcode[4:3]
//---------------------------------------------------------------------
//   Your design
//---------------------------------------------------------------------
register_file inst0(in_n0, n0);
register_file inst1(in_n1, n1);
register_file inst2(in_n2, n2);
register_file inst3(in_n3, n3);
register_file inst4(in_n4, n4);
register_file inst5(in_n5, n5);

ascend inst6(n0, n1, n2, n3, n4, n5, n0_11, n1_11, n2_11, n3_11, n4_11, n5_11);
descend inst7(n0, n1, n2, n3, n4, n5, n0_10, n1_10, n2_10, n3_10, n4_10, n5_10);

always_comb
	case(opcode[4:3])
		2'b11:begin
		n0_out = n0_11;
		n1_out = n1_11;
		n2_out = n2_11;
		n3_out = n3_11;
		n4_out = n4_11;
		n5_out = n5_11;
		end
		2'b10: begin
		n0_out = n0_10;
		n1_out = n1_10;
		n2_out = n2_10;
		n3_out = n3_10;
		n4_out = n4_10;
		n5_out = n5_10;
		end
		2'b01: begin
		n0_out = n5;
		n1_out = n4;
		n2_out = n3;
		n3_out = n2;
		n4_out = n1;
		n5_out = n0;
		end
		2'b00: begin
		n0_out = n0;
		n1_out = n1;
		n2_out = n2;
		n3_out = n3;
		n4_out = n4;
		n5_out = n5;
		end
	endcase

always_comb
	case(opcode[2:0])
		3'b000:out_n = n2_out - n1_out;
		3'b001:out_n = n0_out + n3_out;
		3'b010:out_n = ( n3_out * n4_out ) / 2;
		3'b011:out_n = n1_out + 2 * n5_out;
		3'b100:out_n = n1_out & n2_out;
		3'b101:out_n = ~ n0_out;
		3'b110:out_n = n3_out ^ n4_out;
		3'b111:out_n = n1_out << 1;
	endcase

endmodule

//---------------------------------------------------------------------
//   My Modules
//---------------------------------------------------------------------
module ascend(
	a, b, c, d, e, f,
	a_out, b_out, c_out, d_out, e_out, f_out
);
input [4:0] a, b, c, d, e, f;
output logic [4:0] a_out, b_out, c_out, d_out, e_out, f_out;

logic [4:0] a_reg [0:2];
logic [4:0] b_reg [0:5];
logic [4:0] c_reg [0:5];
logic [4:0] d_reg [0:5];
logic [4:0] e_reg [0:5];
logic [4:0] f_reg [0:2];

//第1輪比較
compare_ascend compare_a_b_1(a, b, a_reg[0], b_reg[0]);
compare_ascend compare_c_d_1(c, d, c_reg[0], d_reg[0]);
compare_ascend compare_e_f_1(e, f, e_reg[0], f_reg[0]);
//第3輪比較
compare_ascend compare_b_c_1(b_reg[0], c_reg[0], b_reg[1], c_reg[1]);
compare_ascend compare_d_e_1(d_reg[0], e_reg[0], d_reg[1], e_reg[1]);
//第3輪比較
compare_ascend compare_a_b_2(a_reg[0], b_reg[1], a_reg[1], b_reg[2]);
compare_ascend compare_c_d_2(c_reg[1], d_reg[1], c_reg[2], d_reg[2]);
compare_ascend compare_e_f_2(e_reg[1], f_reg[0], e_reg[2], f_reg[1]);
//第4輪比較
compare_ascend compare_b_c_2(b_reg[2], c_reg[2], b_reg[3], c_reg[3]);
compare_ascend compare_d_e_2(d_reg[2], e_reg[2], d_reg[3], e_reg[3]);
//第5輪比較
compare_ascend compare_a_b_3(a_reg[1], b_reg[3], a_reg[2], b_reg[4]);
compare_ascend compare_c_d_3(c_reg[3], d_reg[3], c_reg[4], d_reg[4]);
compare_ascend compare_e_f_3(e_reg[3], f_reg[1], e_reg[4], f_reg[2]);
//第6輪比較
compare_ascend compare_b_c_3(b_reg[4], c_reg[4], b_reg[5], c_reg[5]);
compare_ascend compare_d_e_3(d_reg[4], e_reg[4], d_reg[5], e_reg[5]);

assign a_out = a_reg[2];
assign b_out = b_reg[5];
assign c_out = c_reg[5];
assign d_out = d_reg[5];
assign e_out = e_reg[5];
assign f_out = f_reg[2];

endmodule

module compare_ascend(
	a, b,
	a_out, b_out
);
input [4:0] a, b;
output logic [4:0] a_out, b_out;

assign a_out = ( a < b ) ? a : b;
assign b_out = ( a < b ) ? b : a;

endmodule

module descend(
	a, b, c, d, e, f,
	a_out, b_out, c_out, d_out, e_out, f_out
);
input [4:0] a, b, c, d, e, f;
output logic [4:0] a_out, b_out, c_out, d_out, e_out, f_out;

logic [4:0] a_reg [0:2];
logic [4:0] b_reg [0:5];
logic [4:0] c_reg [0:5];
logic [4:0] d_reg [0:5];
logic [4:0] e_reg [0:5];
logic [4:0] f_reg [0:2];

//第1輪比較
compare_descend compare_a_b_1(a, b, a_reg[0], b_reg[0]);
compare_descend compare_c_d_1(c, d, c_reg[0], d_reg[0]);
compare_descend compare_e_f_1(e, f, e_reg[0], f_reg[0]);
//第3輪比較
compare_descend compare_b_c_1(b_reg[0], c_reg[0], b_reg[1], c_reg[1]);
compare_descend compare_d_e_1(d_reg[0], e_reg[0], d_reg[1], e_reg[1]);
//第3輪比較
compare_descend compare_a_b_2(a_reg[0], b_reg[1], a_reg[1], b_reg[2]);
compare_descend compare_c_d_2(c_reg[1], d_reg[1], c_reg[2], d_reg[2]);
compare_descend compare_e_f_2(e_reg[1], f_reg[0], e_reg[2], f_reg[1]);
//第4輪比較
compare_descend compare_b_c_2(b_reg[2], c_reg[2], b_reg[3], c_reg[3]);
compare_descend compare_d_e_2(d_reg[2], e_reg[2], d_reg[3], e_reg[3]);
//第5輪比較
compare_descend compare_a_b_3(a_reg[1], b_reg[3], a_reg[2], b_reg[4]);
compare_descend compare_c_d_3(c_reg[3], d_reg[3], c_reg[4], d_reg[4]);
compare_descend compare_e_f_3(e_reg[3], f_reg[1], e_reg[4], f_reg[2]);
//第6輪比較
compare_descend compare_b_c_3(b_reg[4], c_reg[4], b_reg[5], c_reg[5]);
compare_descend compare_d_e_3(d_reg[4], e_reg[4], d_reg[5], e_reg[5]);

assign a_out = a_reg[2];
assign b_out = b_reg[5];
assign c_out = c_reg[5];
assign d_out = d_reg[5];
assign e_out = e_reg[5];
assign f_out = f_reg[2];

endmodule

module compare_descend(
	a, b,
	a_out, b_out
);
input [4:0] a, b;
output logic [4:0] a_out, b_out;

assign a_out = ( a > b ) ? a : b;
assign b_out = ( a > b ) ? b : a;

endmodule


//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule



