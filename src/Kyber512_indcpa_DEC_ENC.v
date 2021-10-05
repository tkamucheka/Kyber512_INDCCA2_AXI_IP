//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_indcpa_DEC_ENC
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_indcpa_DEC_ENC#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter KYBER_POLYCOMPRESSEDBYTES = 96,
  parameter KYBER_512_SKBytes = 1632, // msb 32'z,32'H(pk),800'pk,768'sk
  parameter Msg_Bytes = 32,
  parameter data_Width_0 = 12,
  parameter data_Width_1 = 16,
  parameter Byte_bits = 8,
  parameter Poly_Size_12 = data_Width_0 * KYBER_N,
  parameter Poly_Size_16 = data_Width_1 * KYBER_N,
  parameter Packed_sk_Size = Byte_bits * 768,
  parameter Packed_pk_Size = Byte_bits * 800,
  parameter Seed_Char_Size = 256,
  parameter Coins_Size = 256,
  parameter KYBER_512_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter Ciphertext_Size = Byte_bits * (KYBER_POLYCOMPRESSEDBYTES + KYBER_512_POLYVECCOMPRESSEDBYTES),
  parameter SK_Size = Byte_bits * KYBER_512_SKBytes,
  parameter o_Msg_Size =  Byte_bits * Msg_Bytes
)(
			input  clk,		
			input  rst_n,
			input  enable,
			input  mux_enc_dec,	
            input  [Ciphertext_Size-1 : 0] i_Ciphertext,
            input  [SK_Size-1 : 0] i_SK,
            input  [Coins_Size-1 : 0] i_Coins,
            output  reg Decryption_Done,
            output  [o_Msg_Size -1 : 0] oMsg,
            output  reg Encryption_Done,
            output  [Ciphertext_Size-1 : 0] o_ReENC_Ciphertext
);

wire [Seed_Char_Size-1 : 0] ENC_Seed_Char = i_SK[Byte_bits*(768+800)-1 -: Seed_Char_Size];
reg  Unpack_Ciphertext_enable;
wire [Byte_bits*KYBER_POLYCOMPRESSEDBYTES-1 :0] P0_iSeed_Char = i_Ciphertext[Ciphertext_Size-1 -: 768];
wire [Byte_bits*KYBER_512_POLYVECCOMPRESSEDBYTES-1 : 0] P0_i_Ciphertext = i_Ciphertext[Ciphertext_Size-1-768 -: 5120];
wire Unpack_Ciphertext_done;
wire [0 : 0] P0_ct_outready;
wire [5 : 0] P0_ct_WAd;
wire [95 : 0] P0_Bp_ct_WData;
wire [0 : 0] P0_Dec_v_outready;
wire [7 : 0] P0_Dec_v_WAd;
wire [11 : 0] P0_Dec_V_WData;

reg  Unpack_enable;
wire Unpack_done;
wire [Packed_pk_Size-1 : 0] Packed_pk = i_SK[Byte_bits*(768+800)-1 -: Packed_pk_Size];
wire [Packed_sk_Size-1 : 0] Packed_sk = i_SK[Byte_bits*768-1 -: Packed_sk_Size];
wire [0 : 0] P1_EncPk_DecSk_PolyVec_outready; 
wire [5 : 0] P1_EncPk_DecSk_PolyVec_WAd; 
wire [127 : 0] P1_EncPk_DecSk_PolyVec_WData; 

reg  NTT_enable;
wire NTT_done;
wire [0 : 0] P2_Bp_ct_RAd;
wire [0 : 0] P2_NTT_Poly_0_outready;
wire [5 : 0] P2_NTT_Poly_0_WAd;
wire [95 : 0] P2_NTT_Poly_0_WData;
wire [1024-1 : 0] P2_Sp_r_RData;
wire [0 : 0] P2_Sp_r_RAd;

reg  PAcc_enable;
wire PAcc_done;
wire [4095 : 0] P3_EncPk_DecSk_PolyVec_RData;
wire [0 : 0] P3_NTT_Poly_0_RAd;
wire [0 : 0] P3_EncPk_DecSk_PolyVec_RAd;
wire [0 : 0] P3_Enc_BpV_DecMp_outready;
wire [7 : 0] P3_Enc_BpV_DecMp_WAd;
wire [127 : 0] P3_Enc_BpV_DecMp_WData;

reg  INTT_enable;
wire INTT_done;
wire [2 : 0] PACC_EncBp_DecMp_Poly_RAd;
wire [2 : 0] P3_M3_RAd;
wire [0 : 0] INTT_Enc_BpV_DecMp_outready;
wire [6 : 0] INTT_Enc_BpV_DecMp_WAd;
wire [127 : 0]INTT_Enc_BpV_DecMp_WData;

reg  Sub_enable;
wire Sub_done;
wire [0 : 0] Sub_EncBp_DecMp_outready;
wire [7 : 0] Sub_EncBp_DecMp_WAd;
wire [128 : 0] Sub_EncBp_DecMp_WData;
wire [4 : 0]Dec_v_RAd;
wire [6 : 0] INTT_DecMp_RAd;
wire [6 : 0]INTT_Enc_BpV_RAd;
wire [6 : 0]INTT_Enc_BpV_DecMp_RAd = mux_enc_dec? INTT_DecMp_RAd : INTT_Enc_BpV_RAd;
wire [127: 0]INTT_Enc_BpV_DecMp_RData;

reg  Reduce_enable;
wire Reduce_done;
wire [2 : 0] Sub_EncBpV_DecMp_RAd;
wire [0 : 0] Reduce_DecMp_outready;
wire [4 : 0] Reduce_DecMp_WAd;
wire [95 : 0] Reduce_DecMp_WData;

wire From_Msg_done;
wire [0 : 0] P8_out_ready;
wire [7 : 0] P8_Poly_WAd;
wire [11 : 0] P8_WData;
reg  From_Msg_enable;

reg  To_Msg_enable;	
wire To_Msg_done;
wire [7 : 0] Reduce_DecMp_RAd;
wire [11 : 0] Reduce_DecMp_RData;	
wire [0 : 0] Reduce_EncBp_outready;
wire [5 : 0] Reduce_EncBp_WAd;
wire [96-1 : 0] Reduce_EncBp_WData;
wire [0 : 0] Reduce_EncV_outready;
wire [4 : 0] Reduce_EncV_WAd;
wire [96-1 : 0] Reduce_EncV_WData;

wire Hash_Done;
reg Hash_enable;
wire [2 : 0] P9_AtG_WEN;
wire [7 : 0] P9_AtG_WAd;
wire [128-1 : 0] P9_AtG_WData;
wire [0 : 0] Sp_r_outready;
wire [5 : 0] Sp_r_WAd;
wire [32-1 : 0] Sp_r_WData;
wire [0 : 0] eG_outready;
wire [6 : 0] eG_WAd;
wire [32-1 : 0] eG_WData;

wire Add_done;
reg Add_enable;
wire [4 : 0] P10_Add_k_RAd;
wire [32-1 : 0] P10_eG_RData;
wire [6 : 0] P10_eG_RAd; 
wire P10_M3_WEN;
wire [7 : 0] P10_M3_WAd;
wire [127 : 0] P10_M3_WData;

wire Pack_done;
reg Pack_enable;
wire [48-1 : 0] P11_Reduce_EncBp_RData;
wire [96-1 : 0] P11_Reduce_EncV_RData;
wire [6 : 0] P11_Reduce_EncBp_RAd;
wire [4 : 0] P11_Reduce_EncV_RAd;
wire [2560-1 : 0] P11_o_Ciphertext0_0;
wire [2560-1 : 0] P11_o_Ciphertext0_1;
wire [768-1 : 0] P11_o_Ciphertext1;
assign o_ReENC_Ciphertext = {P11_o_Ciphertext1,P11_o_Ciphertext0_1,P11_o_Ciphertext0_0};

//BRAM
wire [0 : 0] M0_WEN;
wire [5 : 0] M0_WAd;
wire [95 : 0] M0_WData;
wire [0 : 0] M0_RAd;
wire [3071 : 0] M0_RData;

wire [0 : 0] M1_WEN;
wire [7 : 0] M1_WAd;
wire [11 : 0] M1_WData;
wire [4 : 0] M1_RAd;
wire [95 : 0] M1_RData;

wire [0 : 0] M3_WEN;
wire [7 : 0] M3_WAd;
wire [127 : 0] M3_WData;
wire [2 : 0] M3_RAd;
wire [4095 : 0] M3_RData;

reg [3:0] cstate,nstate;											
parameter IDLE		        = 4'd0;
parameter DEC_ENC_Unpack    = 4'd1;
parameter DEC_ENC_NTT   	= 4'd2;
parameter DEC_ENC_PAcc      = 4'd3;
parameter DEC_ENC_INTT      = 4'd4;
parameter DEC_Sub    		= 4'd5;
parameter DEC_ENC_Reduce    = 4'd6;
parameter DEC_To_Msg        = 4'd7;
parameter ENC_From_Msg      = 4'd8;
parameter ENC_Hash          = 4'd9;
parameter ENC_Add        	= 4'd10;
parameter ENC_Pack          = 4'd11;

always @(posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or Unpack_Ciphertext_done or NTT_done or From_Msg_done
or PAcc_done or INTT_done or Sub_done or Reduce_done or To_Msg_done or Hash_Done or Add_done or Pack_done) 
 begin				
	case(cstate)
		IDLE: 	           if(enable) nstate <= DEC_ENC_Unpack;
				             else nstate <= IDLE;
		DEC_ENC_Unpack:    if(Unpack_Ciphertext_done && mux_enc_dec) nstate <= DEC_ENC_NTT;
		                    else if(Unpack_Ciphertext_done)	nstate <= ENC_From_Msg;	       
				             else nstate <= DEC_ENC_Unpack;
        ENC_From_Msg:      if(From_Msg_done) nstate <= ENC_Hash;
                             else nstate <= ENC_From_Msg;
        ENC_Hash:          if(Hash_Done) nstate <= DEC_ENC_NTT;
                             else nstate <= ENC_Hash;
		DEC_ENC_NTT:       if(NTT_done) nstate <= DEC_ENC_PAcc;
				            else nstate <= DEC_ENC_NTT;
		DEC_ENC_PAcc: 	   if(PAcc_done) nstate <= DEC_ENC_INTT;
				            else nstate <= DEC_ENC_PAcc;
		DEC_ENC_INTT:      if(INTT_done && mux_enc_dec) nstate <= DEC_Sub;
		                    else if(INTT_done)	nstate <= ENC_Add;		       
				             else nstate <= DEC_ENC_INTT;		
		DEC_Sub:           if(Sub_done) nstate <= DEC_ENC_Reduce;
				            else nstate <= DEC_Sub;
		ENC_Add:           if(Add_done) nstate <= DEC_ENC_Reduce;
		                    else nstate <= ENC_Add;		            
		DEC_ENC_Reduce:    if(Reduce_done && mux_enc_dec) nstate <= DEC_To_Msg;
				            else if(Reduce_done) nstate <= ENC_Pack;
				            else nstate <= DEC_ENC_Reduce;
		DEC_To_Msg:        if(To_Msg_done) nstate <= IDLE;		       
				            else nstate <= DEC_To_Msg;
		ENC_Pack:          if(Pack_done) nstate <= IDLE;
		                    else nstate <= ENC_Pack;		            					
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
		Decryption_Done <= 1'b0;
		Encryption_Done <= 1'b0;
		Unpack_Ciphertext_enable <= 1'b0;
		Unpack_enable <= 1'b0;
		From_Msg_enable <= 1'b0;
		NTT_enable <= 1'b0;
		PAcc_enable <= 1'b0;
		INTT_enable <= 1'b0;
		Sub_enable <= 1'b0;
		Reduce_enable <= 1'b0;
		To_Msg_enable <= 1'b0;
		Hash_enable <= 1'b0;
		Add_enable <= 1'b0;
		Pack_enable <= 1'b0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Decryption_Done <= 1'b0;
					Encryption_Done <= 1'b0;
				end
			{IDLE,DEC_ENC_Unpack}:  begin	        			        
					Unpack_Ciphertext_enable <= 1'b1;
					Unpack_enable <= 1'b1; 									
				end				
			{DEC_ENC_Unpack,DEC_ENC_Unpack}: begin
					Unpack_Ciphertext_enable <= 1'b0;
					Unpack_enable <= 1'b0; 
				end					
			{DEC_ENC_Unpack,DEC_ENC_NTT}: begin
					NTT_enable <= 1'b1;                      	
				end
			{DEC_ENC_Unpack,ENC_From_Msg}: begin
					From_Msg_enable <= 1'b1;                      	
				end
			{ENC_From_Msg,ENC_From_Msg}: begin
			        From_Msg_enable <= 1'b0;                      	
				                         end
			{ENC_From_Msg,ENC_Hash}: begin
			        Hash_enable <= 1'b1;                      	
				                         end
			{ENC_Hash,ENC_Hash}: begin
			        Hash_enable <= 1'b0;                      	
				                 end
			{ENC_Hash,DEC_ENC_NTT}: begin
			        NTT_enable <= 1'b1;                      	
				                    end
			{DEC_ENC_NTT,DEC_ENC_NTT}: begin
			        NTT_enable <= 1'b0;                      	
				                       end
			{DEC_ENC_NTT,DEC_ENC_PAcc}: begin
			        PAcc_enable <= 1'b1;                      	
				                        end				                       
			{DEC_ENC_PAcc,DEC_ENC_PAcc}: begin
			        PAcc_enable <= 1'b0;                      	
				                         end	
			{DEC_ENC_PAcc,DEC_ENC_INTT}: begin
			        INTT_enable <= 1'b1;                      	
				                       end	
			{DEC_ENC_INTT,DEC_ENC_INTT}: begin
			        INTT_enable <= 1'b1;                      	
				                       end	
			{DEC_ENC_INTT,DEC_Sub}: begin
			        INTT_enable <= 1'b0;
			        Sub_enable  <= 1'b1;                      	
				                     end	
			{DEC_ENC_INTT,ENC_Add}: begin
			        INTT_enable <= 1'b0;
			        Add_enable  <= 1'b1;                      	
				                     end
			{DEC_Sub,DEC_Sub}: begin
			        Sub_enable <= 1'b0;                      	
				               end	
			{DEC_Sub,DEC_ENC_Reduce}: begin
			        Reduce_enable <= 1'b1;                      	
				                      end	
			{ENC_Add,ENC_Add}: begin
			        Add_enable  <= 1'b0;
			                   end
			{ENC_Add,DEC_ENC_Reduce}: begin
			        Reduce_enable <= 1'b1;                      	
				                      end
			{DEC_ENC_Reduce,DEC_ENC_Reduce}: begin
			        Reduce_enable <= 1'b0;                      	
				                             end
			{DEC_ENC_Reduce,DEC_To_Msg}: begin
			        To_Msg_enable <= 1'b1;                      	
				                     end
			{DEC_ENC_Reduce,ENC_Pack}: begin
			        Pack_enable <= 1'b1;                      	
				                     end
			{DEC_To_Msg,DEC_To_Msg}: begin
			        To_Msg_enable <= 1'b0;                      	
				                     end
			{ENC_Pack,ENC_Pack}: begin
			        Pack_enable <= 1'b0;                      	
				                     end
			{DEC_To_Msg,IDLE}: begin
			        Decryption_Done  <= 1'b1;                     	
				                     end
			{ENC_Pack,IDLE}: begin
			        Encryption_Done  <= 1'b1;                     	
				                     end				                     
			default: ;
			endcase
		end


 //BRAM
// mux
L96_NTT_Poly_0 M0( 
.clka(clk),
.wea(M0_WEN),
.addra(M0_WAd),   //(5 DOWNTO 0);
.dina(M0_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(M0_RAd),//(0 DOWNTO 0);
.doutb(M0_RData)//(3071 DOWNTO 0)
);
// mux
L12_k M1(
.clka(clk),
.wea(M1_WEN),
.addra(M1_WAd),   //(7 DOWNTO 0);
.dina(M1_WData), //(11 DOWNTO 0);
.clkb(clk),
.addrb(M1_RAd),//(4 DOWNTO 0);
.doutb(M1_RData)//(95 DOWNTO 0)
);

 L128_EncPk_DecSk_PolyVec M2(
.clka(clk),
.wea(P1_EncPk_DecSk_PolyVec_outready),
.addra(P1_EncPk_DecSk_PolyVec_WAd),   //(5 DOWNTO 0);
.dina(P1_EncPk_DecSk_PolyVec_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(P3_EncPk_DecSk_PolyVec_RAd),
.doutb(P3_EncPk_DecSk_PolyVec_RData)//(4095 DOWNTO 0)
);
// mux
L128_AtG M3(
.clka(clk),
.wea(M3_WEN),
.addra(M3_WAd),   //(7 DOWNTO 0);
.dina(M3_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(M3_RAd),//(2 DOWNTO 0);
.doutb(M3_RData)//(4095 DOWNTO 0)
);

L128_INTT_Enc_BpV_DecMp M4(
.clka(clk),
.wea(INTT_Enc_BpV_DecMp_outready),
.addra(INTT_Enc_BpV_DecMp_WAd),   //(6 DOWNTO 0);
.dina(INTT_Enc_BpV_DecMp_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(INTT_Enc_BpV_DecMp_RAd),//(6 DOWNTO 0);
.doutb(INTT_Enc_BpV_DecMp_RData)//(127 DOWNTO 0)
);

L96_Reduce_DecMp M5(
.clka(clk),
.wea(Reduce_DecMp_outready),
.addra(Reduce_DecMp_WAd),   //(4 DOWNTO 0);
.dina(Reduce_DecMp_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(Reduce_DecMp_RAd),//(7 DOWNTO 0);
.doutb(Reduce_DecMp_RData)//(11 DOWNTO 0)
);

L32_noise_r_PolyVec M6(
.clka(clk),
.wea(Sp_r_outready),
.addra(Sp_r_WAd),   //(5 DOWNTO 0);
.dina(Sp_r_WData), //(31 DOWNTO 0);
.clkb(clk),
.addrb(P2_Sp_r_RAd),//(0 DOWNTO 0);
.doutb(P2_Sp_r_RData)//(1023 DOWNTO 0)
);

L32_noise_eG M7(
.clka(clk),
.wea(eG_outready),
.addra(eG_WAd),   //(6 DOWNTO 0);
.dina(eG_WData), //(31 DOWNTO 0);
.clkb(clk),
.addrb(P10_eG_RAd),//(6 DOWNTO 0);
.doutb(P10_eG_RData)//(31 DOWNTO 0)
);

L96_Reduce_EncBp M8(
.clka(clk),
.wea(Reduce_EncBp_outready),
.addra(Reduce_EncBp_WAd),   //(5 DOWNTO 0);
.dina(Reduce_EncBp_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(P11_Reduce_EncBp_RAd),//(6 DOWNTO 0);
.doutb(P11_Reduce_EncBp_RData)//(47 DOWNTO 0)
);

L96_Reduce_EncV M9(
.clka(clk),
.wea(Reduce_EncV_outready),
.addra(Reduce_EncV_WAd),   //(4 DOWNTO 0);
.dina(Reduce_EncV_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(P11_Reduce_EncV_RAd),//(4 DOWNTO 0);
.doutb(P11_Reduce_EncV_RData)//(95 DOWNTO 0)
);

//BRAM MUX
Dec_decomp_NTT_BRAM_MUX MUX0(
.cstate(cstate),
.mux_enc_dec(mux_enc_dec),
.P0_ct_outready(P0_ct_outready),
.P0_ct_WAd(P0_ct_WAd),
.P0_Bp_ct_WData(P0_Bp_ct_WData),      
.P2_Bp_ct_RAd(P2_Bp_ct_RAd),
.P2_NTT_Poly_0_outready(P2_NTT_Poly_0_outready),
.P2_NTT_Poly_0_WAd(P2_NTT_Poly_0_WAd),
.P2_NTT_Poly_0_WData(P2_NTT_Poly_0_WData),
.P3_NTT_RAd(P3_NTT_Poly_0_RAd),
.M0_WEN(M0_WEN),
.M0_WAd(M0_WAd),
.M0_WData(M0_WData),
.M0_RAd(M0_RAd)
);

L12_k_MUX MUX1(
.cstate(cstate),
.mux_enc_dec(mux_enc_dec),
.P0_Dec_v_outready(P0_Dec_v_outready),
.P0_Dec_v_WAd(P0_Dec_v_WAd),
.P0_Dec_V_WData(P0_Dec_V_WData),
.Dec_v_RAd(Dec_v_RAd),
.P8_out_ready(P8_out_ready),
.P8_Poly_WAd(P8_Poly_WAd),
.P8_WData(P8_WData),
.P10_k_RAd(P10_Add_k_RAd), 
.M1_WEN(M1_WEN),
.M1_WAd(M1_WAd),
.M1_WData(M1_WData),
.M1_RAd(M1_RAd)
);

Dec_L128_BRAM_MUX MUX2(
.cstate(cstate),
.mux_enc_dec(mux_enc_dec),
.P3_Enc_BpV_DecMp_outready(P3_Enc_BpV_DecMp_outready),
.P3_Enc_BpV_DecMp_WAd(P3_Enc_BpV_DecMp_WAd),
.P3_Enc_BpV_DecMp_WData(P3_Enc_BpV_DecMp_WData),      
.PACC_EncBp_DecMp_Poly_RAd(PACC_EncBp_DecMp_Poly_RAd),
.P5_Sub_EncBp_DecMp_outready(Sub_EncBp_DecMp_outready),
.P5_Sub_EncBp_DecMp_WAd(Sub_EncBp_DecMp_WAd),
.P5_Sub_EncBp_DecMp_WData(Sub_EncBp_DecMp_WData),      
.P6_Add_EncBpV_DecMp_RAd(Sub_EncBpV_DecMp_RAd),
.P9_AtG_WEN(P9_AtG_WEN),
.P9_AtG_WAd(P9_AtG_WAd),
.P9_AtG_WData(P9_AtG_WData),
.P3_M3_RAd(P3_M3_RAd),
.P10_M3_WEN(P10_M3_WEN),
.P10_M3_WAd(P10_M3_WAd),
.P10_M3_WData(P10_M3_WData),       
.M3_WEN(M3_WEN),
.M3_WAd(M3_WAd),
.M3_WData(M3_WData),
.M3_RAd(M3_RAd)
);


//Entity 
State_Decompressed_Ciphertext P0(
.clk(clk),
.rst_n(rst_n),
.enable(Unpack_Ciphertext_enable),
.iSeed_Char(P0_iSeed_Char),    
.iPolyvec_Char(P0_i_Ciphertext),
.Function_done(Unpack_Ciphertext_done),
.Bp_ct_outready(P0_ct_outready),
.Bp_ct_WAd(P0_ct_WAd),//[5 : 0]
.Bp_ct_WData(P0_Bp_ct_WData), //[95 : 0]
.Dec_v_outready(P0_Dec_v_outready),
.Dec_v_WAd(P0_Dec_v_WAd),//[7 : 0]
.Dec_V_WData(P0_Dec_V_WData) //[11 : 0]
);

State_Unpack P1(
.clk(clk),
.rst_n(rst_n),
.enable(Unpack_enable),
.mux_enc_dec(mux_enc_dec),
.ipackedpk(Packed_pk),
.ipackedsk(Packed_sk),
.Function_Done(Unpack_done),
.EncPk_DecSk_PolyVec_outready(P1_EncPk_DecSk_PolyVec_outready),
.EncPk_DecSk_PolyVec_WAd(P1_EncPk_DecSk_PolyVec_WAd), //[5:0]
.EncPk_DecSk_PolyVec_WData(P1_EncPk_DecSk_PolyVec_WData) //[127 : 0]
);	

State_ntt P2(
.clk(clk),
.rst_n(rst_n),
.enable(NTT_enable),
.mux_enc_dec(mux_enc_dec),
.Sp_r_RData(P2_Sp_r_RData),
.Bp_ct_RData(M0_RData),
.Sp_r_RAd(P2_Sp_r_RAd),
.Bp_ct_RAd(P2_Bp_ct_RAd),
.Function_done(NTT_done),
.NTT_Poly_0_outready(P2_NTT_Poly_0_outready),
.NTT_Poly_0_WAd(P2_NTT_Poly_0_WAd),
.NTT_Poly_0_WData(P2_NTT_Poly_0_WData)
);

State_PAcc P3(
.clk(clk),
.rst_n(rst_n),
.enable(PAcc_enable),
.mux_enc_dec(mux_enc_dec),//enc0,dec1
.NTT_Poly_0_RData(M0_RData),
.EncPk_DecSk_PolyVec_RData(P3_EncPk_DecSk_PolyVec_RData),
.AtG_RData(M3_RData),
.NTT_Poly_0_RAd(P3_NTT_Poly_0_RAd),
.EncPk_DecSk_PolyVec_RAd(P3_EncPk_DecSk_PolyVec_RAd),
.AtG_RAd(P3_M3_RAd),
.Function_done(PAcc_done),
.Enc_BpV_DecMp_outready(P3_Enc_BpV_DecMp_outready),
.Enc_BpV_DecMp_WAd(P3_Enc_BpV_DecMp_WAd),
.Enc_BpV_DecMp_WData(P3_Enc_BpV_DecMp_WData)
);

State_Invntt P4(
.clk(clk),		
.rst_n(rst_n),
.enable(INTT_enable),
.mux_enc_dec(mux_enc_dec),//enc0,dec1	
.PACC_EncBp_DecMp_Poly_RData(M3_RData),
.PACC_EncBp_DecMp_Poly_RAd(PACC_EncBp_DecMp_Poly_RAd),
.Function_done(INTT_done),
.INTT_Enc_BpV_DecMp_outready(INTT_Enc_BpV_DecMp_outready),
.INTT_Enc_BpV_DecMp_WAd(INTT_Enc_BpV_DecMp_WAd),
.INTT_Enc_BpV_DecMp_WData(INTT_Enc_BpV_DecMp_WData)
);

State_Poly_Sub P5(
.clk(clk),
.rst_n(rst_n),
.enable(Sub_enable),
.INTT_Enc_BpV_DecMp_RData(INTT_Enc_BpV_DecMp_RData),
.Dec_v_RData(M1_RData),
.INTT_Enc_BpV_DecMp_RAd(INTT_DecMp_RAd),
.Dec_v_RAd(Dec_v_RAd),
.Function_done(Sub_done),
.Sub_EncBp_DecMp_outready(Sub_EncBp_DecMp_outready),
.Sub_EncBp_DecMp_WAd(Sub_EncBp_DecMp_WAd), //[7 : 0]
.Sub_EncBp_DecMp_WData(Sub_EncBp_DecMp_WData) // [127 : 0]
);

State_Reduce P6(
.clk(clk),		
.rst_n(rst_n),
.enable(Reduce_enable),
.mux_enc_dec(mux_enc_dec),//enc0,dec1	 	
.Add_EncBpV_DecMp_RData(M3_RData),
.Add_EncBpV_DecMp_RAd(Sub_EncBpV_DecMp_RAd),
.Function_done(Reduce_done),
.Reduce_DecMp_outready(Reduce_DecMp_outready),
.Reduce_DecMp_WAd(Reduce_DecMp_WAd),
.Reduce_DecMp_WData(Reduce_DecMp_WData),
.Reduce_EncBp_outready(Reduce_EncBp_outready),
.Reduce_EncBp_WAd(Reduce_EncBp_WAd),
.Reduce_EncBp_WData(Reduce_EncBp_WData),
.Reduce_EncV_outready(Reduce_EncV_outready),
.Reduce_EncV_WAd(Reduce_EncV_WAd),
.Reduce_EncV_WData(Reduce_EncV_WData)
);

State_Polytomsg P7(
.clk(clk),		
.rst_n(rst_n),
.enable(To_Msg_enable),	
.Reduce_DecMp_RData(Reduce_DecMp_RData),
.Function_done(To_Msg_done),
.Reduce_DecMp_RAd(Reduce_DecMp_RAd),
.oMsg(oMsg)		
);

State_Poly_frommsg P8(
.clk(clk),
.rst_n(rst_n),
.enable(From_Msg_enable),
.iMsg_byte_array(oMsg),
.out_ready(P8_out_ready),
.Function_Done(From_Msg_done),
.Poly_Ad(P8_Poly_WAd),
.Poly_Data(P8_WData)
);	

State_Hash P9(
.clk(clk),	
.rst_n(rst_n),
.enable(Hash_enable),	
.iSeed(ENC_Seed_Char),
.iCoins(i_Coins),
.Function_done(Hash_Done),
.AtG_outready(P9_AtG_WEN),
.AtG_WAd(P9_AtG_WAd),
.AtG_WData(P9_AtG_WData),
.Sp_r_outready(Sp_r_outready),
.Sp_r_WAd(Sp_r_WAd),
.Sp_r_WData(Sp_r_WData),
.eG_outready(eG_outready),
.eG_WAd(eG_WAd),
.eG_WData(eG_WData)
);

State_Add P10(
.clk(clk),		
.rst_n(rst_n),
.enable(Add_enable),	
.INTT_Enc_BpV_DecMp_RData(INTT_Enc_BpV_DecMp_RData),
.eG_RData(P10_eG_RData),
.k_RData(M1_RData),
.INTT_Enc_BpV_DecMp_RAd(INTT_Enc_BpV_RAd),
.eG_RAd(P10_eG_RAd),
.k_RAd(P10_Add_k_RAd),
.Function_done(Add_done),
.Add_EncBp_DecMp_outready(P10_M3_WEN),
.Add_EncBp_DecMp_WAd(P10_M3_WAd),
.Add_EncBp_DecMp_WData(P10_M3_WData)
);
                     
State_Pack_Cit P11(
.clk(clk),		
.rst_n(rst_n),
.enable(Pack_enable),	
.Reduce_EncBp_RData(P11_Reduce_EncBp_RData),
.Reduce_EncV_RData(P11_Reduce_EncV_RData),
.Reduce_EncBp_RAd(P11_Reduce_EncBp_RAd),
.Reduce_EncV_RAd(P11_Reduce_EncV_RAd),
.Function_done(Pack_done),
.o_Ciphertext0_0(P11_o_Ciphertext0_0),
.o_Ciphertext0_1(P11_o_Ciphertext0_1),
.o_Ciphertext1(P11_o_Ciphertext1)
);

endmodule
