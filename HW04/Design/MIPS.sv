
module MIPS(
    //Input 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //OUTPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);

    //Input 
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
    //OUTPUT
output logic out_valid, instruction_fail;
output logic [31:0] out_1, out_2, out_3, out_4;


//my declaration
logic [31:0] instruction_1_reg, instruction_1_reg_comb, instruction_2_reg;
logic [20:0] output_1_reg, output_1_reg_comb, output_2_reg, output_3_reg;
logic in_valid_1_reg, in_valid_1_reg_comb, in_valid_2_reg, in_valid_3_reg;
logic [4:0] Rs, Rt;
logic [31:0] rs, rt, rs_comb, rt_comb;
logic [4:0] Rs_address, Rt_address, Rd_address, Shamt;
logic [5:0] Opcode, Funct;
logic [15:0] imm;
logic [31:0] value;

logic opcode_valid, rs_valid, rt_valid, rd_valid, funct_valid;
logic fail, fail_comb;
logic [31:0] value_10001, value_10001_comb;
logic [31:0] value_10010, value_10010_comb;
logic [31:0] value_01000, value_01000_comb;
logic [31:0] value_10111, value_10111_comb;
logic [31:0] value_11111, value_11111_comb;
logic [31:0] value_10000, value_10000_comb;


logic out_valid_comb;
logic [31:0] out_1_comb, out_2_comb, out_3_comb, out_4_comb;

//fisrt DFF
always_ff@(posedge clk, negedge rst_n)
	if (!rst_n) begin
		instruction_1_reg <= 32'b0;
		output_1_reg <= 20'b0;
		in_valid_1_reg <= 1'b0;
	end
	else begin
		instruction_1_reg <= instruction_1_reg_comb;
		output_1_reg <= output_1_reg_comb;
		in_valid_1_reg <= in_valid_1_reg_comb;
	end

always_comb
	if (in_valid) begin
		instruction_1_reg_comb = instruction;
		output_1_reg_comb = output_reg;
		in_valid_1_reg_comb = 1'b1;
	end
	else begin
		instruction_1_reg_comb = 32'b0;
		output_1_reg_comb = 20'b0;
		in_valid_1_reg_comb = 1'b0;
	end

//second DFF
always_ff@(posedge clk, negedge rst_n)
	if (!rst_n) begin
		rs <= 32'b0;
		rt <= 32'b0;
		instruction_2_reg <= 32'b0;
		output_2_reg <= 32'b0;
		in_valid_2_reg <= 1'b0;
	end
	else begin
		rs <= rs_comb;
		rt <= rt_comb;
		instruction_2_reg <= instruction_1_reg;
		output_2_reg <= output_1_reg;
		in_valid_2_reg <= in_valid_1_reg;
	end

assign Rs = instruction_1_reg[25:21];
assign Rt = instruction_1_reg[20:16];

always_comb begin
	case (Rs)
		5'b10001:	rs_comb = value_10001;
		5'b10010:	rs_comb = value_10010;
		5'b01000:	rs_comb = value_01000;
		5'b10111:	rs_comb = value_10111;
		5'b11111:	rs_comb = value_11111;
		5'b10000:	rs_comb = value_10000;
		default:	rs_comb = 32'b0;
	endcase
	case (Rt)
		5'b10001:	rt_comb = value_10001;
		5'b10010:	rt_comb = value_10010;
		5'b01000:	rt_comb = value_01000;
		5'b10111:	rt_comb = value_10111;
		5'b11111:	rt_comb = value_11111;
		5'b10000:	rt_comb = value_10000;
		default: 	rt_comb = 32'b0;
	endcase
end

//third DFF
always_ff@(posedge clk, negedge rst_n)
	if (!rst_n) begin
		value_10001 <= 32'b0;
		value_10010 <= 32'b0;
		value_01000 <= 32'b0;
		value_10111 <= 32'b0;
		value_11111 <= 32'b0;
		value_10000 <= 32'b0;
		output_3_reg <= 20'b0;
		fail <= 1'b0;
		in_valid_3_reg <= 1'b0;
	end
	else begin
		value_10001 <= value_10001_comb;
		value_10010 <= value_10010_comb;
		value_01000 <= value_01000_comb;
		value_10111 <= value_10111_comb;
		value_11111 <= value_11111_comb;
		value_10000 <= value_10000_comb;
		output_3_reg <= output_2_reg;
		fail <= fail_comb;
		in_valid_3_reg <= in_valid_2_reg;
	end

assign Funct = instruction_2_reg[5:0];
assign Opcode = instruction_2_reg[31:26];
assign Rs_address = instruction_2_reg[25:21];
assign Rt_address = instruction_2_reg[20:16];
assign Rd_address = instruction_2_reg[15:11];
assign Shamt = instruction_2_reg[10:6];
assign imm = instruction_2_reg[15:0];

always_comb
	case (Funct)
		6'b100000:	value = rs + rt;
		6'b100100:	value = rs & rt;
		6'b100101:	value = rs | rt;
		6'b100111:	value = ~(rs | rt);
		6'b000000:	value = rt << Shamt;
		6'b000010:	value = rt >> Shamt;
		default: 	value = 32'b0;
	endcase	
//valids'
always_comb begin
	case (Opcode)
		6'b000000:	opcode_valid = 1'b1;
		6'b001000:	opcode_valid = 1'b1;
		default:	opcode_valid = 1'b0;
	endcase
	case (Rs_address)
		5'b10001:	rs_valid = 1'b1;
		5'b10010:	rs_valid = 1'b1;
		5'b01000:	rs_valid = 1'b1;
		5'b10111:	rs_valid = 1'b1;
		5'b11111:	rs_valid = 1'b1;
		5'b10000:	rs_valid = 1'b1;
		default:	rs_valid = 1'b0;
	endcase
	case (Rt_address)
		5'b10001:	rt_valid = 1'b1;
		5'b10010:	rt_valid = 1'b1;
		5'b01000:	rt_valid = 1'b1;
		5'b10111:	rt_valid = 1'b1;
		5'b11111:	rt_valid = 1'b1;
		5'b10000:	rt_valid = 1'b1;
		default:	rt_valid = 1'b0;
	endcase
	case (Rd_address)
		5'b10001:	rd_valid = 1'b1;
		5'b10010:	rd_valid = 1'b1;
		5'b01000:	rd_valid = 1'b1;
		5'b10111:	rd_valid = 1'b1;
		5'b11111:	rd_valid = 1'b1;
		5'b10000:	rd_valid = 1'b1;
		default:	rd_valid = 1'b0;
	endcase
	case (Funct)
		6'b100000:	funct_valid = 1'b1;
		6'b100100:	funct_valid = 1'b1;
		6'b100101:	funct_valid = 1'b1;
		6'b100111:	funct_valid = 1'b1;
		6'b000000:	funct_valid = 1'b1;
		6'b000010:	funct_valid = 1'b1;
		default: 	funct_valid = 1'b0;
	endcase	
end	

//fail
always_comb 
	if (!opcode_valid && in_valid_2_reg)
		fail_comb = 1'b1;
	else if (Opcode == 6'b000000 && in_valid_2_reg && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		fail_comb = 1'b1;
	else if (Opcode == 6'b001000 && in_valid_2_reg && (!rs_valid || !rt_valid))
		fail_comb = 1'b1;
	else
		fail_comb = 1'b0;
		
//value of address 10001
always_comb
	if (!opcode_valid)
		value_10001_comb = value_10001;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_10001_comb = value_10001;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_10001_comb = value_10001;
	else if (Opcode == 6'b000000 && Rd_address == 5'b10001)
		value_10001_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b10001)
		value_10001_comb = rs + imm;
	else
		value_10001_comb = value_10001;

//value of address 10010
always_comb
	if (!opcode_valid)
		value_10010_comb = value_10010;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_10010_comb = value_10010;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_10010_comb = value_10010;
	else if (Opcode == 6'b000000 && Rd_address == 5'b10010)
		value_10010_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b10010)
		value_10010_comb = rs + imm;
	else
		value_10010_comb = value_10010;
		
//value of address 01000
always_comb
	if (!opcode_valid)
		value_01000_comb = value_01000;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_01000_comb = value_01000;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_01000_comb = value_01000;
	else if (Opcode == 6'b000000 && Rd_address == 5'b01000)
		value_01000_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b01000)
		value_01000_comb = rs + imm;
	else
		value_01000_comb = value_01000;

//value of address 10111
always_comb
	if (!opcode_valid)
		value_10111_comb = value_10111;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_10111_comb = value_10111;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_10111_comb = value_10111;
	else if (Opcode == 6'b000000 && Rd_address == 5'b10111)
		value_10111_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b10111)
		value_10111_comb = rs + imm;
	else
		value_10111_comb = value_10111;	

//value of address 11111
always_comb
	if (!opcode_valid)
		value_11111_comb = value_11111;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_11111_comb = value_11111;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_11111_comb = value_11111;
	else if (Opcode == 6'b000000 && Rd_address == 5'b11111)
		value_11111_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b11111)
		value_11111_comb = rs + imm;
	else
		value_11111_comb = value_11111;

//value of address 10000
always_comb
	if (!opcode_valid)
		value_10000_comb = value_10000;
	else if (Opcode == 6'b000000 && (!rs_valid || !rt_valid || !rd_valid || !funct_valid))
		value_10000_comb = value_10000;
	else if (Opcode == 6'b001000 && (!rs_valid || !rt_valid))
		value_10000_comb = value_10000;
	else if (Opcode == 6'b000000 && Rd_address == 5'b10000)
		value_10000_comb = value;
	else if (Opcode == 6'b001000 && Rt_address == 5'b10000)
		value_10000_comb = rs + imm;
	else
		value_10000_comb = value_10000;

//forth DFF
always_ff@(posedge clk, negedge rst_n)
	if (!rst_n) begin
		out_1 <= 32'b0;
		out_2 <= 32'b0;
		out_3 <= 32'b0;
		out_4 <= 32'b0;
		instruction_fail <= 1'b0;
		out_valid <= 1'b0;
	end
	else begin
		out_1 <= out_1_comb;
		out_2 <= out_2_comb;
		out_3 <= out_3_comb;
		out_4 <= out_4_comb;
		instruction_fail <= fail;
		out_valid <= in_valid_3_reg;
	end
		
//out_1
always_comb
	if (fail)
		out_1_comb = 32'b0;
	else if (in_valid_3_reg)
		case (output_3_reg[4:0])
			5'b10001:	out_1_comb = value_10001;
			5'b10010:	out_1_comb = value_10010;
			5'b01000:	out_1_comb = value_01000;
			5'b10111:	out_1_comb = value_10111;
			5'b11111:	out_1_comb = value_11111;
			5'b10000:	out_1_comb = value_10000;
			default:	out_1_comb = value_10001;
		endcase
	else
		out_1_comb = 32'b0;

//out_2
always_comb
	if (fail)
		out_2_comb = 32'b0;
	else if (in_valid_3_reg)
		case (output_3_reg[9:5])
			5'b10001:	out_2_comb = value_10001;
			5'b10010:	out_2_comb = value_10010;
			5'b01000:	out_2_comb = value_01000;
			5'b10111:	out_2_comb = value_10111;
			5'b11111:	out_2_comb = value_11111;
			5'b10000:	out_2_comb = value_10000;
			default:	out_2_comb = value_10001;
		endcase
	else
		out_2_comb = 32'b0;
//out_3		
always_comb
	if (fail)
		out_3_comb = 32'b0;
	else if (in_valid_3_reg)
		case (output_3_reg[14:10])
			5'b10001:	out_3_comb = value_10001;
			5'b10010:	out_3_comb = value_10010;
			5'b01000:	out_3_comb = value_01000;
			5'b10111:	out_3_comb = value_10111;
			5'b11111:	out_3_comb = value_11111;
			5'b10000:	out_3_comb = value_10000;
			default:	out_3_comb = value_10001;
		endcase
	else
		out_3_comb = 32'b0;
		
//out_4
always_comb
	if (fail)
		out_4_comb = 32'b0;
	else if (in_valid_3_reg)
		case (output_3_reg[19:15])
			5'b10001:	out_4_comb = value_10001;
			5'b10010:	out_4_comb = value_10010;
			5'b01000:	out_4_comb = value_01000;
			5'b10111:	out_4_comb = value_10111;
			5'b11111:	out_4_comb = value_11111;
			5'b10000:	out_4_comb = value_10000;
			default:	out_4_comb = value_10001;
		endcase				
	else
		out_4_comb = 32'b0;

endmodule


