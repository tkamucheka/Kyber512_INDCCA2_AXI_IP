//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2019 03:06:06 PM
// Design Name: 
// Module Name: State_Hash__Permutation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 17292
// 
//////////////////////////////////////////////////////////////////////////////////

`define low_pos(w,b)    ((w)*64 + (b)*8)
`define low_pos2(w,b)   `low_pos(w,7-b)
`define high_pos(w,b)   (`low_pos(w,b) + 7)
`define high_pos2(w,b)  (`low_pos2(w,b) + 7)
`define fill_byte(a)		(8'b0 | a)

module State_Hash__Permutation#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter State_Width = 64,
  parameter State_Array = 25,
  parameter State_Size = State_Width * State_Array,
  parameter Seed_Bytes = 32,
  parameter Coins_Bytes = 32,
  parameter seed_Width = 64,
  parameter Byte_bits = 8,
  parameter At_Char_Bytes = 672,
  parameter Noise_Bytes = 128,
  parameter iSeed_Size = Byte_bits * Seed_Bytes,
  parameter iCoins_Size = Byte_bits * Coins_Bytes, 
  parameter o_At_Char_Size = Byte_bits * At_Char_Bytes,
  parameter o_Noist_Char_Size = Byte_bits * Noise_Bytes
)(
input  clk,
input  reset_n,
input  enable,
input  permutation_only_noise,
input  [iSeed_Size-1 : 0]  iSeed,
input  [1:0] elements_num, // i, j
input  [iCoins_Size-1 : 0]  iCoins,
input  [3:0] nonce,
output reg  Permutation_done,
output reg  [o_At_Char_Size - 1 : 0] oAt_Char,
output reg  [o_Noist_Char_Size - 1 : 0] oNoise_Char
);

reg 										clear = 0;
reg  										P0_Permutation_Cal_enable, P1_Permutation_Cal_enable;
reg  [State_Size-1 : 0] P0_Permutation_Cal_iState;
reg  [1344-1 : 0]  			temp_Char [3:0];

wire  									P0_Permutation_Cal_done, P1_Permutation_Cal_done;
wire [State_Size-1 : 0] P0_Permutation_Cal_oState_noise, P0_Permutation_Cal_oState_At;

reg [2:0] cstate,nstate;
localparam IDLE		          	 = 3'd0;
localparam Permutation_Noise_0 = 3'd1;
localparam Permutation_reset	 = 3'd2;
localparam Permutation_At_0    = 3'd3;
localparam Permutation_At_1    = 3'd4;
localparam Permutation_At_2    = 3'd5;
localparam Permutation_At_3    = 3'd6;
localparam Store               = 3'd7;

// Reverse byte order in 64-bit block
function [319:0] pad_seed(input [255:0] seed, input i, input j);
	pad_seed = {seed, (8'h0 | i), (8'h0 | j), 8'h1f, 40'h0000000000};
endfunction

function [319:0] pad_coins(input [255:0] a, input [3:0] nonce);
	pad_coins = {a, (8'h0 | nonce), 8'h1f, 48'h000000000000};
endfunction

wire 	[1023:0] 	noise, noise_reordered;
wire	[1343:0] 	At, At_reordered;
wire 	[319:0] 	seed_padded_reordered, coins_padded_reordered;
reg 	[319:0] 	seed_padded, coins_padded;

assign noise 	= P0_Permutation_Cal_oState_noise[1599 -: 1024];
assign At 		= P0_Permutation_Cal_oState_At[1599 -: 1344];

genvar w, b;
generate
	for(w=0; w<5; w=w+1) begin : L0
		for(b=0; b<8; b=b+1) begin : L1
			assign seed_padded_reordered[`high_pos(w,b):`low_pos(w,b)] = seed_padded[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

generate
	for(w=0; w<5; w=w+1) begin : L2
		for(b=0; b<8; b=b+1) begin : L3
			assign coins_padded_reordered[`high_pos(w,b):`low_pos(w,b)] = coins_padded[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

// reorder bytes in noise 
generate
	for(w=0; w<16; w=w+1) begin : L4
		for(b=0; b<8; b=b+1) begin : L5
			assign noise_reordered[`high_pos(w,b):`low_pos(w,b)] = noise[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

// reorder bytes in At
generate
	for(w=0; w<21; w=w+1) begin : L6
		for(b=0; b<8; b=b+1) begin : L7
			assign At_reordered[`high_pos(w,b):`low_pos(w,b)] = At[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

always @(*) begin
	seed_padded 	<= pad_seed(iSeed, elements_num[1], elements_num[0]);
	coins_padded 	<= pad_coins(iCoins, nonce);
end

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or permutation_only_noise or P0_Permutation_Cal_done or P1_Permutation_Cal_done)
begin				
	case(cstate)
		IDLE: 	             	if(enable) 																						nstate <= Permutation_Noise_0;
				              		else 																									nstate <= IDLE;
		Permutation_Noise_0: 	if(P0_Permutation_Cal_done && permutation_only_noise) nstate <= IDLE;
		                      else if(P0_Permutation_Cal_done) 											nstate <= Permutation_At_0;
	                        else 																									nstate <= Permutation_Noise_0;
		Permutation_At_0:    	if(P1_Permutation_Cal_done) 													nstate <= Permutation_At_1;
													else 																									nstate <= Permutation_At_0;
		Permutation_At_1:    	if(P1_Permutation_Cal_done) 													nstate <= Permutation_At_2;
													else 																									nstate <= Permutation_At_1;	  	                           	                           
		Permutation_At_2:    	if(P1_Permutation_Cal_done) 													nstate <= Permutation_At_3;
													else 																									nstate <= Permutation_At_2;	  	
		Permutation_At_3:    	if(P1_Permutation_Cal_done) 													nstate <= Store;
													else 																									nstate <= Permutation_At_3;
		Store:                																											nstate <= IDLE;                     				
		default: 																																		nstate <= IDLE;
	endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
		Permutation_done <= 1'b0;
		oAt_Char <= 0;
		oNoise_Char <= 0;
		P0_Permutation_Cal_enable <= 1'b0;
		P1_Permutation_Cal_enable <= 1'b0;
	end
	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					clear 						<= 1'b0;
					Permutation_done 	<= 1'b0;
				end
			{IDLE,Permutation_Noise_0}: begin
					// BUG: Incorrect byte ordering
					// P0_Permutation_Cal_iState <= {iCoins[63:0],iCoins[127:64],iCoins[191:128],iCoins[255:192],48'h0,8'h1f,4'h0,nonce,704'h0,64'h8000000000000000,512'h0};
					P0_Permutation_Cal_iState <= {coins_padded_reordered, 704'h0, 64'h8000000000000000, 512'h0};
					P0_Permutation_Cal_enable <= 1'b1;                          			    
				end			
			{Permutation_Noise_0,Permutation_Noise_0}: begin
					P0_Permutation_Cal_enable <= 1'b0;
				end
			{Permutation_Noise_0,IDLE}: begin
					Permutation_done <= 1'b1;
					// BUG: Incorrect byte ordering
					// oNoise_Char <= {P0_Permutation_Cal_oState[640-1 -: 64],P0_Permutation_Cal_oState[704-1 -: 64],P0_Permutation_Cal_oState[768-1 -: 64],P0_Permutation_Cal_oState[832-1 -: 64],P0_Permutation_Cal_oState[896-1 -: 64],P0_Permutation_Cal_oState[960-1 -: 64],P0_Permutation_Cal_oState[1024-1 -: 64],P0_Permutation_Cal_oState[1088-1 -: 64],P0_Permutation_Cal_oState[1152-1 -: 64],P0_Permutation_Cal_oState[1216-1 -: 64],P0_Permutation_Cal_oState[1280-1 -: 64],P0_Permutation_Cal_oState[1344-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
					oNoise_Char <= noise_reordered;					
				  oAt_Char 		<= 0;
				end
			{Permutation_Noise_0,Permutation_At_0}: begin
					// BUG: Incorrect byte ordering
					// oNoise_Char <= {P0_Permutation_Cal_oState[640-1 -: 64],P0_Permutation_Cal_oState[704-1 -: 64],P0_Permutation_Cal_oState[768-1 -: 64],P0_Permutation_Cal_oState[832-1 -: 64],P0_Permutation_Cal_oState[896-1 -: 64],P0_Permutation_Cal_oState[960-1 -: 64],P0_Permutation_Cal_oState[1024-1 -: 64],P0_Permutation_Cal_oState[1088-1 -: 64],P0_Permutation_Cal_oState[1152-1 -: 64],P0_Permutation_Cal_oState[1216-1 -: 64],P0_Permutation_Cal_oState[1280-1 -: 64],P0_Permutation_Cal_oState[1344-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
					oNoise_Char <= noise_reordered;
					// Bug: incorrect construction of padded then reordered iSeed and elements_num. 					
					// P0_Permutation_Cal_iState <= {iSeed[63:0],iSeed[127:64],iSeed[191:128],iSeed[255:192]),40'h0, 8'h1f ,7'h0, elements_num[0] ,7'h0, elements_num[1] , 960'h0,64'h8000000000000000, 256'h0};
					P0_Permutation_Cal_iState <= {seed_padded_reordered, 960'h0, 64'h8000000000000000, 256'h0};
					P1_Permutation_Cal_enable <= 1'b1;
				end
			{Permutation_At_0,Permutation_At_0}: begin
					P1_Permutation_Cal_enable <= 1'b0;				        
				end					                   				 					           					
			{Permutation_At_0,Permutation_At_1}: begin
					// Bug: Incorrect byte ordering 
					// temp_Char[0] <= {P0_Permutation_Cal_oState[319 -: 64],P0_Permutation_Cal_oState[383 -: 64],P0_Permutation_Cal_oState[447 -: 64],P0_Permutation_Cal_oState[511 -: 64],P0_Permutation_Cal_oState[575 -: 64],P0_Permutation_Cal_oState[639 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1151 -: 64],P0_Permutation_Cal_oState[1215 -: 64],P0_Permutation_Cal_oState[1279 -: 64],P0_Permutation_Cal_oState[1343 -: 64],P0_Permutation_Cal_oState[1407 -: 64],P0_Permutation_Cal_oState[1471 -: 64],P0_Permutation_Cal_oState[1535 -: 64],P0_Permutation_Cal_oState[1599 -: 64]};
					temp_Char[0] <= At_reordered;
					// Bug: No input should be given to state. Because new input is xor'ed with state.
					// P0_Permutation_Cal_iState <= P0_Permutation_Cal_oState
					P0_Permutation_Cal_iState <= 0;
					P1_Permutation_Cal_enable <= 1'b1;
				end
			{Permutation_At_1,Permutation_At_1}: begin
					P1_Permutation_Cal_enable <= 1'b0;				        
				end	
			{Permutation_At_1,Permutation_At_2}: begin
					// Bug: Incorrect byte ordering
					// temp_Char[1] <= {P0_Permutation_Cal_oState[319 -: 64],P0_Permutation_Cal_oState[383 -: 64],P0_Permutation_Cal_oState[447 -: 64],P0_Permutation_Cal_oState[511 -: 64],P0_Permutation_Cal_oState[575 -: 64],P0_Permutation_Cal_oState[639 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1151 -: 64],P0_Permutation_Cal_oState[1215 -: 64],P0_Permutation_Cal_oState[1279 -: 64],P0_Permutation_Cal_oState[1343 -: 64],P0_Permutation_Cal_oState[1407 -: 64],P0_Permutation_Cal_oState[1471 -: 64],P0_Permutation_Cal_oState[1535 -: 64],P0_Permutation_Cal_oState[1599 -: 64]};
					temp_Char[1] 							<= At_reordered;
					// Bug: No input should be given to state. Because new input is xor'ed with state.
					// P0_Permutation_Cal_iState <= P0_Permutation_Cal_oState
					P0_Permutation_Cal_iState <= 0;
					P1_Permutation_Cal_enable <= 1'b1;
				end
			{Permutation_At_2,Permutation_At_2}: begin
					P1_Permutation_Cal_enable <= 1'b0;				        
				end
			{Permutation_At_2,Permutation_At_3}: begin
					// Bug: Incorrect byte ordering
					// temp_Char[2] <= {P0_Permutation_Cal_oState[319 -: 64],P0_Permutation_Cal_oState[383 -: 64],P0_Permutation_Cal_oState[447 -: 64],P0_Permutation_Cal_oState[511 -: 64],P0_Permutation_Cal_oState[575 -: 64],P0_Permutation_Cal_oState[639 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1151 -: 64],P0_Permutation_Cal_oState[1215 -: 64],P0_Permutation_Cal_oState[1279 -: 64],P0_Permutation_Cal_oState[1343 -: 64],P0_Permutation_Cal_oState[1407 -: 64],P0_Permutation_Cal_oState[1471 -: 64],P0_Permutation_Cal_oState[1535 -: 64],P0_Permutation_Cal_oState[1599 -: 64]};
					temp_Char[2] 							<= At_reordered;
					// Bug: No input should be given to state. Because new input is xor'ed with state.
					// P0_Permutation_Cal_iState <= P0_Permutation_Cal_oState
					P0_Permutation_Cal_iState <= 0;
					P1_Permutation_Cal_enable <= 1'b1;
				end
			{Permutation_At_3,Permutation_At_3}: begin
					P1_Permutation_Cal_enable <= 1'b0;				        
				end
			{Permutation_At_3,Store}: begin
					// temp_Char[3] <= {P0_Permutation_Cal_oState[319 -: 64],P0_Permutation_Cal_oState[383 -: 64],P0_Permutation_Cal_oState[447 -: 64],P0_Permutation_Cal_oState[511 -: 64],P0_Permutation_Cal_oState[575 -: 64],P0_Permutation_Cal_oState[639 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1151 -: 64],P0_Permutation_Cal_oState[1215 -: 64],P0_Permutation_Cal_oState[1279 -: 64],P0_Permutation_Cal_oState[1343 -: 64],P0_Permutation_Cal_oState[1407 -: 64],P0_Permutation_Cal_oState[1471 -: 64],P0_Permutation_Cal_oState[1535 -: 64],P0_Permutation_Cal_oState[1599 -: 64]};
					temp_Char[3] <= At_reordered;
				end
			{Store,IDLE}: begin
					Permutation_done 	<= 1'b1;
					// Bug: Incorrect concatenation of state output
					// oAt_Char 			<= {temp_Char[3],temp_Char[2],temp_Char[1],temp_Char[0]};
					oAt_Char 					<= {temp_Char[0],temp_Char[1],temp_Char[2],temp_Char[3]};
					// Bug: permutation modules must be cleared
					clear 						<= 1'b1;
				end						  
			default: ;
			endcase
		end                             
                                        
// Bug:
// Implements only shake256, nothing for shake128                         
// State_Hash_Permutation_Cal P1(
// .clk(clk),
// .reset_n(reset_n),
// .enable(P0_Permutation_Cal_enable),
// .iState(P0_Permutation_Cal_iState),
// .out_ready(P0_Permutation_Cal_done),
// .oState(P0_Permutation_Cal_oState_At)
// );

f_permutation #(.r(1088), .c(512))
	f_permutation_P0 (
		.clk(clk), 
		.resetn(~reset_n | clear),
		.in(P0_Permutation_Cal_iState[1599 -: 1088]),
		.in_ready(P0_Permutation_Cal_enable),
		.ack(),
		.out(P0_Permutation_Cal_oState_noise), 
		.out_ready(P0_Permutation_Cal_done)
	);

f_permutation #(.r(1344), .c(256))
	f_permutation_P1 (
		.clk(clk), 
		.resetn(~reset_n | clear),
		.in(P0_Permutation_Cal_iState[1599 -: 1344]),
		.in_ready(P1_Permutation_Cal_enable),
		.ack(),
		.out(P0_Permutation_Cal_oState_At), 
		.out_ready(P1_Permutation_Cal_done)
	);

endmodule

`undef low_pos
`undef low_pos2
`undef high_pos
`undef high_pos2
`undef fill_byte