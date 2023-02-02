module Conv(
  // Input signals
  clk,
  rst_n,
  image_valid,
  filter_valid,
  in_data,
  // Output signals
  out_valid,
  out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, image_valid, filter_valid;
input [3:0] in_data;
output logic [15:0] out_data;
output logic out_valid;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
logic signed [3:0] filter[0:9], filter_comb[0:9];
logic signed [3:0] image[0:63], image_comb[0:63];
logic [6:0] counter, counter_comb;
logic [6:0] counter_image;
logic signed [11:0] conv1[0:31],conv1_comb[0:31];
logic signed [15:0] conv2[0:15], conv2_comb[0:15];
logic out_valid_comb;
logic signed [15:0] out_data_comb;
integer idx_1, idx_2, idx_3, idx_4, idx_5, idx_6, idx_7;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		counter <= 7'd0;
	else
		counter <= counter_comb;
		
always_comb
	if(filter_valid || image_valid)
		counter_comb = counter + 1'b1;
	else if(counter >= 7'd74) begin
		if(counter == 7'd89)
			counter_comb = 0;
		else
			counter_comb = counter + 1'b1;
	end
	else
		counter_comb = 0;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(idx_1 = 0; idx_1 < 10; idx_1 = idx_1 + 1)
			filter[idx_1] <= 4'd0;
	else
		for(idx_1 = 0; idx_1 < 10; idx_1 = idx_1 + 1)
			filter[idx_1] <= filter_comb[idx_1];
			
			
always_comb
	if(filter_valid) begin
		for(idx_2 = 0; idx_2 < 10; idx_2 = idx_2 + 1) begin
			if(idx_2 == counter)
				filter_comb[idx_2] = in_data;
			else	
				filter_comb[idx_2] = filter[idx_2];
		end
	end
	else
		for(idx_2 = 0; idx_2 < 10; idx_2 = idx_2 + 1)
			filter_comb[idx_2] = filter[idx_2];

assign counter_image = counter - 10;

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(idx_3 = 0; idx_3 < 64; idx_3 = idx_3 + 1)
			image[idx_3] <= 4'd0;
	else
		for(idx_3 = 0; idx_3 < 64; idx_3 = idx_3 + 1)
			image[idx_3] <= image_comb[idx_3];
			
always_comb
	if(image_valid) begin
		for(idx_4 = 0; idx_4 < 63; idx_4 = idx_4 + 1) begin
			if(idx_4 == counter_image)
				image_comb[idx_4] = in_data;
			else
				image_comb[idx_4] = image[idx_4];
		end
		image_comb[63] = in_data;
	end
	else
		for(idx_4 = 0; idx_4 < 64; idx_4 = idx_4 + 1)
			image_comb[idx_4] = image[idx_4];

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(idx_5 = 0; idx_5 < 32; idx_5 = idx_5 + 1)
			conv1[idx_5] <= 16'd0;
	else
		for(idx_5 = 0; idx_5 < 32; idx_5 = idx_5 + 1)
			conv1[idx_5] <= conv1_comb[idx_5];
				
always_comb
	for(idx_6 = 0; idx_6 < 32; idx_6 = idx_6 + 1)
		conv1_comb[idx_6] = filter[0] * image[idx_6 + idx_6 / 4 * 4] + filter[1] * image[idx_6 + idx_6 / 4 * 4 + 1] + filter[2] * image[idx_6 + idx_6 / 4 * 4 + 2] + filter[3] * image[idx_6 + idx_6 / 4 * 4 + 3] + filter[4] * image[idx_6 + idx_6 / 4 * 4 + 4];


/*
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		for(int i = 0; i < 16; i = i + 1)
			conv2[i] <= 16'd0;
	else
		for(int i = 0; i < 16; i = i + 1)
			conv2[i] <= conv2_comb[i];
			
always_comb
	for(int i = 0; i < 16; i = i + 1)
		conv2_comb[i] = filter[5] * conv1[i] + filter[6] * conv1[i+4] + filter[7] * conv1[i + 8] + filter[8] * conv1[i + 12] + filter[9] * conv1[i + 16];
*/


always_comb
	for(idx_7 = 0; idx_7 < 16; idx_7 = idx_7 + 1)
		conv2[idx_7] = filter[5] * conv1[idx_7] + filter[6] * conv1[idx_7 + 4] + filter[7] * conv1[idx_7 + 8] + filter[8] * conv1[idx_7 + 12] + filter[9] * conv1[idx_7 + 16];

always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_valid <= 1'b0;
	else
		out_valid <= out_valid_comb;

always_comb 
	if(counter >=74 && counter <= 89)
		out_valid_comb = 1'b1;
	else
		out_valid_comb = 1'b0;

		
always_ff@(posedge clk, negedge rst_n)
	if(!rst_n)
		out_data <= 16'd0;
	else
		out_data <= out_data_comb;

always_comb 
	if(counter >=74 && counter <= 89)
		out_data_comb = conv2[counter - 74];
	else
		out_data_comb = 16'd0;
		
endmodule
