//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_ENC_KEM
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// *NOTICE*
// i_PK need load from SRAM
// o_Ciphertext need store to SRAM
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_ENC_KEM #(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Byte_bits = 8,
  parameter KYBER_512_PKBytes = 800,
  parameter KYBER_512_CtBytes = 736,
  parameter KYBER_512_SSBytes = 32,
  parameter Random_Bytes = 32,
  parameter i_Random_Size = Byte_bits * Random_Bytes,  
  parameter i_PK_Size = Byte_bits * KYBER_512_PKBytes,
  parameter o_Ciphertext_Size =  Byte_bits * KYBER_512_CtBytes,
  parameter o_SharedSecret_Size =  Byte_bits * KYBER_512_SSBytes
)(
	input  clk,		
	input  rst_n,
	input  enable,
	input  [i_Random_Size-1 : 0] i_Random,
	input  [i_PK_Size-1 : 0] i_PK,
	output  Cal_flag,
	output  Encryption_Done,
	output  [o_Ciphertext_Size -1 : 0]  o_Ciphertext,
	output  [o_SharedSecret_Size -1 : 0] o_SharedSecret,    
	output [1:0] cstate_flag,
	// DEBUG:
//	output [3:0] state,
	// output [255:0] o_message,
  // output [255:0] o_coins,
  // output [511:0] o_Kr,
	// output [127:0] unpackedpk_debug,
	// output [255:0] seed_debug,
	// output [191:0] msgpoly_debug
	// output [1023:0] At_debug,
	// output [255:0] Sp_debug,
	// output [255:0] eG_debug,
//	output [4095:0] ntt_debug,
//	output [1023:0] Bp_debug,
//	output [511:0] V_debug,
//	output [255:0] reduceV_debug,
//	output [255:0] reduceBp_debug
	output trigger1,
	output trigger2
);

reg Encryption_Done_R;
reg Cal_flag_R;
assign Encryption_Done = Encryption_Done_R;
assign Cal_flag = Cal_flag_R;  

reg  T0_pre_post_indcpa_ENC_enable;
reg  T0_pre_post_indcpa_ENC_mode;
reg  [256-1 : 0] T0_i_post_Kr_Hi;
wire T0_pre_post_indcpa_ENC_done;
wire [256-1 : 0] T0_oBuf_Hi;
wire [512-1 : 0] T0_o_Kr;

reg  T1_indcpa_ENC_enable;
wire T1_indcpa_ENC_done;

reg start;

reg [1:0] cstate,nstate;											
localparam IDLE		        = 2'd0;
localparam Pre_indcpa     = 2'd1;
localparam indcpa_ENC     = 2'd2;
localparam Post_indcpa    = 2'd3;

assign cstate_flag = cstate;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 	cstate <= IDLE;
	else 				cstate <= nstate;

// always @(posedge enable)
// 	start <= 1;

// always @(posedge clk) begin
always @(cstate or enable or T0_pre_post_indcpa_ENC_done or T1_indcpa_ENC_done) begin
	case(cstate)
		IDLE: 	    	if(enable) 											nstate <= Pre_indcpa;
				          else 			 											nstate <= IDLE;                  
		Pre_indcpa: 	if(T0_pre_post_indcpa_ENC_done) nstate <= indcpa_ENC;		       
				          else 			 											nstate <= Pre_indcpa;
		indcpa_ENC: 	if(T1_indcpa_ENC_done) 					nstate <= Post_indcpa;
				          else 			 											nstate <= indcpa_ENC;
		Post_indcpa: 	if(T0_pre_post_indcpa_ENC_done) nstate <= IDLE;
				          else 			 											nstate <= Post_indcpa;				
		default: 																			nstate <= IDLE;
	endcase
end

always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
		Encryption_Done_R 						<= 1'b0;
		Cal_flag_R        						<= 1'b0;
		T0_pre_post_indcpa_ENC_mode 	<= 1'b0;
		T0_pre_post_indcpa_ENC_enable <= 1'b0;
		T0_i_post_Kr_Hi 		 					<= 0;
		T1_indcpa_ENC_enable 					<= 1'b0;
		start 												<= 1'b0;
	end	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Encryption_Done_R <= Encryption_Done_R;
				end
			{IDLE,Pre_indcpa}:  begin
					start 												<= 1'b0;
					Cal_flag_R 										<= 1'b1;  
					T0_pre_post_indcpa_ENC_enable <= 1'b1;
					T0_pre_post_indcpa_ENC_mode 	<= 1'b0;				
				end				
			{Pre_indcpa,Pre_indcpa}: begin
					T0_pre_post_indcpa_ENC_enable <= 1'b0;
					T0_pre_post_indcpa_ENC_mode 	<= 1'b0;   
				end					
			{Pre_indcpa,indcpa_ENC}: begin
					T0_i_post_Kr_Hi 		 <= T0_o_Kr[511 -: 256];
					T1_indcpa_ENC_enable <= 1'b1;              	
				end
			{indcpa_ENC,indcpa_ENC}: begin
					T1_indcpa_ENC_enable <= 1'b0;  
				end
			{indcpa_ENC,Post_indcpa}: begin
					T0_pre_post_indcpa_ENC_enable <= 1'b1;
					T0_pre_post_indcpa_ENC_mode 	<= 1'b1;	   	
				end				                       
			{Post_indcpa,Post_indcpa}: begin
					T0_pre_post_indcpa_ENC_enable <= 1'b0;
					T0_pre_post_indcpa_ENC_mode 	<= 1'b1;	
				end	
			{Post_indcpa,IDLE}: begin
					Encryption_Done_R  <= 1'b1;
					Cal_flag_R 				 <= 1'b0;                      	
				end
			default: ;
		endcase
	end

// BUG: Discard, Unusable
// Kyber512_pre_post_indcpa_ENC T0(
// .clk(clk),		
// .rst_n(rst_n),
// .enable(T0_pre_post_indcpa_ENC_enable),	
// .mode(T0_pre_post_indcpa_ENC_mode),
// .iRandom(i_Random),
// .iPk(i_PK),
// .iCt(o_Ciphertext),
// .i_post_Kr_Low(T0_i_post_Kr_Low),
// .Pre_Post_indcpa_done(T0_pre_post_indcpa_ENC_done),
// .oBuf_Low(T0_oBuf_Low),
// .o_Kr(T0_o_Kr),
// .o_post_SS(o_SharedSecret)
// );

//assign o_message = T0_oBuf_Hi;
//assign o_coins   = T0_o_Kr[255 -: 256];
//assign o_Kr      = {T0_o_Kr[511 -: 256], T0_o_Kr[255 -: 256]};

// reg [255:0] expected_message = 256'hc20634f357f421fb8b596413cdc3158f05dcba9cf384c3e0a17168e8cc4a0ff7;
// reg [255:0] expected_coins = 256'h40f247bee2d0c4f73329b33df04131f46befb2fcaee5a382afc2e8e299cd20a4;

Kyber512_pre_post_hash_ENC T0 (
  .clk(clk),
  .reset_n(rst_n),
  .enable(T0_pre_post_indcpa_ENC_enable),
  .mode(T0_pre_post_indcpa_ENC_mode),
  .pre_post_hash_done(T0_pre_post_indcpa_ENC_done),
  .i_buf(i_Random),
  .i_Pk(i_PK),
  .i_Ct(o_Ciphertext),
  .i_post_Kr_Hi(T0_i_post_Kr_Hi),
  .o_post_Kr_Hi(T0_o_Kr[511 -: 256]),
  .o_message(T0_oBuf_Hi),
  .o_coins(T0_o_Kr[255 -: 256]),
  .o_SS(o_SharedSecret)
);

// Kyber512_indcpa_ENC T1(
// 	.clk(clk),
// 	.rst_n(rst_n),
// 	.enable(T1_indcpa_ENC_enable),
// 	// .enable(enable),
// 	.mux_enc_dec(0),	
// 	.i_PK(i_PK),
// 	.i_Msg(T0_oBuf_Hi),
// 	// .i_Msg(expected_message),
// 	.i_Coins(T0_o_Kr[255 -: 256]),
// 	// .i_Coins(expected_coins),
// 	.Encryption_Done(T1_indcpa_ENC_done),
// 	// .Encryption_Done(Encryption_Done),
// 	.o_Ciphertext(o_Ciphertext),
// 	// DEBUG:
// 	// .state(state),
// 	// .unpackedpk_debug(unpackedpk_debug),
// 	// .seed_debug(seed_debug),
// 	// .msgpoly_debug(msgpoly_debug)
// 	// .At_debug(At_debug),
// 	// .Sp_debug(Sp_debug),
// 	// .eG_debug(eG_debug),
// 	// .ntt_debug(ntt_debug),
// 	// .Bp_debug(Bp_debug),
// 	// .V_debug(V_debug),
// 	// .reduceV_debug(reduceV_debug),
// 	// .reduceBp_debug(reduceBp_debug)
// 	.trigger(trigger)
// );

Kyber512_INDCPA T1 (
	.clk(clk),
	.rst_n(rst_n),
	.mux_enc_dec(0),
	// INDCPA_ENC
	.i_indcpa_enc_enable(T1_indcpa_ENC_enable),
	.i_PK(i_PK),
	.i_Msg(T0_oBuf_Hi),
	.i_Coins(T0_o_Kr[255 -: 256]),
	.o_indcpa_enc_done(T1_indcpa_ENC_done),
	.o_CT(o_Ciphertext),
	// INDCPA_DEC
	// DEBUG:
	.trigger1(trigger1),
	.trigger2(trigger2)
);

endmodule
