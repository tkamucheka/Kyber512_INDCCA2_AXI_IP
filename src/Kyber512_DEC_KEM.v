//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_DEC_KEM
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// *NOTICE*
// i_SK need load from SRAM
// i_Ct need load from SRAM
// o_Ciphertext need store to SRAM
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_DEC_KEM#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Byte_bits = 8,
  parameter KYBER_512_SKBytes = 1632,
  parameter KYBER_512_CtBytes = 736,
  parameter KYBER_512_SSBytes = 32,
  parameter i_Ciphertext_Size =  Byte_bits * KYBER_512_CtBytes,
  parameter i_SK_Size = Byte_bits * KYBER_512_SKBytes,
  parameter o_SharedSecret_Size =  Byte_bits * KYBER_512_SSBytes
)(
			input  clk,		
			input  rst_n,
			input  enable,
			input  [i_Ciphertext_Size-1 : 0] i_Ct,
            input  [i_SK_Size-1 : 0] i_SK,
            output  Cal_flag,
            output  Verify_fail,
            output  Decryption_Done,
            output [o_SharedSecret_Size -1 : 0] o_SharedSecret,
            output  [2:0] cstate_flag            
);

reg Decryption_Done_R;
reg Cal_flag_R;
assign Decryption_Done = Decryption_Done_R;
assign Cal_flag = Cal_flag_R;  

reg  T0_enable;
reg  mux_enc_dec; // 0 for enc, 1 for dec
wire T0_indcpa_DEC_done;
wire T0_indcpa_ENC_done;
wire [256-1 : 0] T0_dec_omsg;
wire [i_Ciphertext_Size-1 : 0] T0_enc_oReENC_cmp;

reg  T1_pre_post_indcpa_DEC_enable;
reg  T1_pre_post_indcpa_DEC_mode;//0 for pre, 1 for post
reg  [256-1 : 0] T1_iBuf_Low;
wire T1_pre_post_indcpa_DEC_done;
wire [512-1 : 0] T1_oKr_pre;

reg [2:0] cstate,nstate;											
parameter IDLE		        = 3'd0;
parameter indcpa_dec        = 3'd1;
parameter Pre_indcpa        = 3'd2;
parameter indcpa_enc        = 3'd3;
parameter Post_indcpa       = 3'd4;

assign cstate_flag = cstate;
always @(posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or T0_indcpa_DEC_done or T1_pre_post_indcpa_DEC_done or T0_indcpa_ENC_done) 
 begin				
	case(cstate)
		IDLE: 	           if(enable) nstate <= indcpa_dec;
				            else nstate <= IDLE;
		indcpa_dec: 	   if(T0_indcpa_DEC_done) nstate <= Pre_indcpa;
				            else nstate <= indcpa_dec;
		Pre_indcpa:        if(T1_pre_post_indcpa_DEC_done) nstate <= indcpa_enc;		       
				            else nstate <= Pre_indcpa;
		indcpa_enc:        if(T0_indcpa_ENC_done) nstate <= Post_indcpa;
				            else nstate <= indcpa_enc;
		Post_indcpa: 	   if(T1_pre_post_indcpa_DEC_done) nstate <= IDLE;
				            else nstate <= Post_indcpa;				
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
	        Decryption_Done_R <= 1'b0;
	        Cal_flag_R <= 1'b0;

		       end
	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Decryption_Done_R <= Decryption_Done_R;
				         end
			{IDLE,indcpa_dec}: begin
			        Cal_flag_R <= 1'b1;
			        Decryption_Done_R <= 1'b0;
					T0_enable <= 1'b1;
					mux_enc_dec <= 1'b1;
				                end				         
			{indcpa_dec,indcpa_dec}: begin
					T0_enable <= 1'b0;
				                     end					         
			{indcpa_dec,Pre_indcpa}:  begin 
				    T1_pre_post_indcpa_DEC_enable <= 1'b1;
                    T1_pre_post_indcpa_DEC_mode <= 1'b0;
                    T1_iBuf_Low <= 	T0_dec_omsg;		
				                end				
			{Pre_indcpa,Pre_indcpa}: begin
				    T1_pre_post_indcpa_DEC_enable <= 1'b0;
                    T1_pre_post_indcpa_DEC_mode <= 1'b0;   
				                     end					
			{Pre_indcpa,indcpa_enc}: begin			        
               	    T0_enable <= 1'b1;
               	    mux_enc_dec <= 1'b0;              	
				                     end
			{indcpa_enc,indcpa_enc}: begin
                 	T0_enable <= 1'b0;  
				                      end
			{indcpa_enc,Post_indcpa}: begin
				    T1_pre_post_indcpa_DEC_enable <= 1'b1;
                    T1_pre_post_indcpa_DEC_mode <= 1'b1;
                    T1_iBuf_Low <= 	T1_oKr_pre[255 : 0];		   	
				                       end				                       
			{Post_indcpa,Post_indcpa}: begin
                  	T1_pre_post_indcpa_DEC_enable <= 1'b0;
                    T1_pre_post_indcpa_DEC_mode <= 1'b1;	
				                       end	
			{Post_indcpa,IDLE}: begin
			        Decryption_Done_R  <= 1'b1;
			        Cal_flag_R <= 1'b0;                      	
				                     end
			default: ;
			endcase
		end

Kyber512_indcpa_DEC_ENC T0(
.clk(clk),		
.rst_n(rst_n),
.enable(T0_enable),
.mux_enc_dec(mux_enc_dec),	
.i_Ciphertext(i_Ct),
.i_SK(i_SK),
.i_Coins(T1_oKr_pre[511 : 256]),
.Decryption_Done(T0_indcpa_DEC_done),
.oMsg(T0_dec_omsg),
.Encryption_Done(T0_indcpa_ENC_done),
.o_ReENC_Ciphertext(T0_enc_oReENC_cmp)
);

Kyber512_pre_post_indcpa_DEC T1(
.clk(clk),		
.rst_n(rst_n),
.enable(T1_pre_post_indcpa_DEC_enable),
.mode(T1_pre_post_indcpa_DEC_mode),//0 for pre, 1 for post
.iSk(i_SK),
.iCt(i_Ct),
.iBuf_Low_pre_msg_post_K(T1_iBuf_Low),
.iCmp_post(T0_enc_oReENC_cmp),
.Pre_Post_indcpa_DEC_done(T1_pre_post_indcpa_DEC_done),
.oKr_pre(T1_oKr_pre),
.o_post_SS_post(o_SharedSecret),
.Verify_fail(Verify_fail)
);

endmodule