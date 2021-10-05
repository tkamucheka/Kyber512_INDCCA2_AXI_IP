//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_pre_post_indcpa_ENC
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_pre_post_indcpa_ENC #(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter State_Width = 64,
  parameter State_Array = 25,
  parameter State_Size = State_Width * State_Array,
  parameter Byte_bits = 8,
  parameter Random_Bytes = 32,
  parameter Pk_Bytes = 800,
  parameter Ct_Bytes = 736,  
  parameter Buf_Bytes_Half = 32,
  parameter Kr_Bytes = 64,
  parameter SS_Bytes = 32,
  parameter iRandom_Size = Byte_bits * Random_Bytes,
  parameter iCt_Size = Byte_bits * Ct_Bytes,
  parameter iPk_Size = Byte_bits * Pk_Bytes,  
  parameter o_Buf_Half_Size = Byte_bits * Buf_Bytes_Half,
  parameter o_Kr_Size = Byte_bits * Kr_Bytes,
  parameter o_SS_Size = Byte_bits * SS_Bytes
)(
input  clk,
input  rst_n,
input  enable,
input  mode,//0 for pre, 1 for post
input  [iRandom_Size-1 : 0]  iRandom,
input  [iPk_Size-1 : 0]  iPk,
input  [iCt_Size-1 : 0]  iCt,
input  [(o_Kr_Size/2) - 1 : 0] i_post_Kr_Low,
output reg  Pre_Post_indcpa_done,
output reg  [o_Buf_Half_Size - 1 : 0] oBuf_Low,
output reg  [o_Kr_Size - 1 : 0] o_Kr,
output reg  [o_SS_Size - 1 : 0] o_post_SS
);
      
reg  P0_Permutation_Cal_enable;
reg  [State_Size-1 : 0] P0_Permutation_Cal_iState;
wire  P0_Permutation_Cal_done;
wire [State_Size-1 : 0] P0_Permutation_Cal_oState;

reg [3:0] cstate,nstate;
parameter IDLE		                    = 4'd0;
parameter Permutation_Buf_Squeeze     = 4'd1;
parameter Permutation_PK_Round0_Cal   = 4'd2;
parameter Permutation_PK_Round1_Cal   = 4'd3;
parameter Permutation_PK_Round2_Cal   = 4'd4;
parameter Permutation_PK_Round3_Cal   = 4'd5;
parameter Permutation_PK_Round4_Cal   = 4'd6;
parameter Permutation_PK_Squeeze      = 4'd7;
parameter Permutation_Kr_Squeeze      = 4'd8;
parameter Permutation_Ct_Round0_Cal   = 4'd9;
parameter Permutation_Ct_Round1_Cal   = 4'd10;
parameter Permutation_Ct_Round2_Cal   = 4'd11;
parameter Permutation_Ct_Round3_Cal   = 4'd12;
parameter Permutation_Ct_Round4_Cal   = 4'd13;
parameter Permutation_Ct_Squeeze      = 4'd14;
parameter Permutation_SS_Squeeze      = 4'd15;

always @(posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else       cstate <= nstate;
	
always @(cstate or enable or P0_Permutation_Cal_done)
begin
   if(!mode) begin			
	case(cstate)
		IDLE:                       if(enable) nstate <= Permutation_Buf_Squeeze;
				                     else nstate <= IDLE;
		Permutation_Buf_Squeeze:    if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Round0_Cal;
		                             else nstate <= Permutation_Buf_Squeeze;
		Permutation_PK_Round0_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Round1_Cal;
	                                 else nstate <= Permutation_PK_Round0_Cal;
		Permutation_PK_Round1_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Round2_Cal;
	                                 else nstate <= Permutation_PK_Round1_Cal;
		Permutation_PK_Round2_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Round3_Cal;
	                                 else nstate <= Permutation_PK_Round2_Cal;
		Permutation_PK_Round3_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Round4_Cal;
	                                 else nstate <= Permutation_PK_Round3_Cal;
		Permutation_PK_Round4_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_PK_Squeeze;
	                                 else nstate <= Permutation_PK_Round4_Cal;	                                 	
		Permutation_PK_Squeeze:     if(P0_Permutation_Cal_done) nstate <= Permutation_Kr_Squeeze;
	                                 else nstate <= Permutation_PK_Squeeze;	  	
		Permutation_Kr_Squeeze:     if(P0_Permutation_Cal_done) nstate <= IDLE;
	                                 else nstate <= Permutation_Kr_Squeeze;                  				
		default: nstate <= IDLE;
		endcase
		       end
    else begin
	case(cstate)
		IDLE:                       if(enable) nstate <= Permutation_Ct_Round0_Cal;
				                     else nstate <= IDLE;
		Permutation_Ct_Round0_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round1_Cal;
	                                 else nstate <= Permutation_Ct_Round0_Cal;
		Permutation_Ct_Round1_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round2_Cal;
	                                 else nstate <= Permutation_Ct_Round1_Cal;
		Permutation_Ct_Round2_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round3_Cal;
	                                 else nstate <= Permutation_Ct_Round2_Cal;
		Permutation_Ct_Round3_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round4_Cal;
	                                 else nstate <= Permutation_Ct_Round3_Cal;
		Permutation_Ct_Round4_Cal:  if(P0_Permutation_Cal_done) nstate <= Permutation_Ct_Squeeze;
	                                 else nstate <= Permutation_Ct_Round4_Cal;	                                 	
		Permutation_Ct_Squeeze:     if(P0_Permutation_Cal_done) nstate <= Permutation_SS_Squeeze;
	                                 else nstate <= Permutation_Ct_Squeeze;	  	
		Permutation_SS_Squeeze:     if(P0_Permutation_Cal_done) nstate <= IDLE;
	                                 else nstate <= Permutation_SS_Squeeze;                  				
		default: nstate <= IDLE;
		endcase
		   end
end          


always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
	        Pre_Post_indcpa_done <= 1'b0;
	        oBuf_Low <= 0;
	        o_Kr <= 0;
	        o_post_SS <= 0;
	        P0_Permutation_Cal_enable <= 1'b0;
		         end
	else if(!mode) begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
				   Pre_Post_indcpa_done <=  1'b0;	
				  end
			{IDLE,Permutation_Buf_Squeeze}: begin			        
			       P0_Permutation_Cal_iState <= {iRandom[63:0],iRandom[127:64],iRandom[191:128],iRandom[255:192],64'h6,704'h0,64'h8000000000000000,512'h0};
			       P0_Permutation_Cal_enable <= 1'b1;			                              			    
				                            end			
			{Permutation_Buf_Squeeze,Permutation_Buf_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;
                                                               end
			{Permutation_Buf_Squeeze,Permutation_PK_Round0_Cal}: begin
	               oBuf_Low <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};					
                   P0_Permutation_Cal_iState <= {iPk[63:0],iPk[127:64],iPk[191:128],iPk[255:192],iPk[319:256],iPk[383:320],iPk[447:384],iPk[511:448],iPk[575:512],iPk[639:576],iPk[703:640],iPk[767:704],iPk[831:768],iPk[895:832],iPk[959:896],iPk[1023:960],iPk[1087:1024],512'h0};
                   P0_Permutation_Cal_enable <= 1'b1;
				                                    end	  
			{Permutation_PK_Round0_Cal,Permutation_PK_Round0_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end					                   				 					           					
			{Permutation_PK_Round0_Cal,Permutation_PK_Round1_Cal}: begin
			       P0_Permutation_Cal_iState <= {(iPk[1151 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iPk[1215 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iPk[1279 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iPk[1343 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iPk[1407 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iPk[1471 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iPk[1535 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iPk[1599 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iPk[1663 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iPk[1727 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iPk[1791 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iPk[1855 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iPk[1919 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iPk[1983 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iPk[2047 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iPk[2111 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iPk[2175 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};	
                   P0_Permutation_Cal_enable <= 1'b1;
				                                 end	  
			{Permutation_PK_Round1_Cal,Permutation_PK_Round1_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end	
			{Permutation_PK_Round1_Cal,Permutation_PK_Round2_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iPk[2239 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iPk[2303 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iPk[2367 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iPk[2431 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iPk[2495 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iPk[2559 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iPk[2623 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iPk[2687 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iPk[2751 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iPk[2815 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iPk[2879 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iPk[2943 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iPk[3007 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iPk[3071 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iPk[3135 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iPk[3199 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iPk[3263 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1;
                                                                   end
			{Permutation_PK_Round2_Cal,Permutation_PK_Round2_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_PK_Round2_Cal,Permutation_PK_Round3_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iPk[3327 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iPk[3391 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iPk[3455 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iPk[3519 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iPk[3583 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iPk[3647 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iPk[3711 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iPk[3775 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iPk[3839 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iPk[3903 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iPk[3967 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iPk[4031 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iPk[4095 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iPk[4159 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iPk[4223 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iPk[4287 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iPk[4351 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_PK_Round3_Cal,Permutation_PK_Round3_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_PK_Round3_Cal,Permutation_PK_Round4_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iPk[4415 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iPk[4479 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iPk[4543 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iPk[4607 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iPk[4671 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iPk[4735 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iPk[4799 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iPk[4863 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iPk[4927 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iPk[4991 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iPk[5055 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iPk[5119 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iPk[5183 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iPk[5247 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iPk[5311 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iPk[5375 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iPk[5439 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_PK_Round4_Cal,Permutation_PK_Round4_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_PK_Round4_Cal,Permutation_PK_Squeeze}: begin
                   P0_Permutation_Cal_iState <= {(iPk[5503 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iPk[5567 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iPk[5631 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iPk[5695 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iPk[5759 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iPk[5823 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iPk[5887 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iPk[5951 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iPk[6015 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iPk[6079 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iPk[6143 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iPk[6207 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iPk[6271 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iPk[6335 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iPk[6399 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(64'h0000000000000006 ^ P0_Permutation_Cal_oState[639 -: 64]),(64'h8000000000000000 ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_PK_Squeeze,Permutation_PK_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                             end
			{Permutation_PK_Squeeze,Permutation_Kr_Squeeze}: begin
                   P0_Permutation_Cal_iState <= {oBuf_Low[63 -: 64],oBuf_Low[127 -: 64],oBuf_Low[191 -: 64],oBuf_Low[255 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],64'h8000000000000006,1024'h0};
                   P0_Permutation_Cal_enable <= 1'b1; 
									                         end
			{Permutation_Kr_Squeeze,Permutation_Kr_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                             end
			{Permutation_Kr_Squeeze,IDLE}: begin
			       Pre_Post_indcpa_done <= 1'b1;
				   o_Kr <= {P0_Permutation_Cal_oState[1152-1 -: 64],P0_Permutation_Cal_oState[1216-1 -: 64],P0_Permutation_Cal_oState[1280-1 -: 64],P0_Permutation_Cal_oState[1344-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
					                       end						  
			default: ;
			endcase
		              end  
		else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
				   Pre_Post_indcpa_done <=  1'b0;	
				  end
			{IDLE,Permutation_Ct_Round0_Cal}: begin			        
                   P0_Permutation_Cal_iState <= {iCt[63:0],iCt[127:64],iCt[191:128],iCt[255:192],iCt[319:256],iCt[383:320],iCt[447:384],iCt[511:448],iCt[575:512],iCt[639:576],iCt[703:640],iCt[767:704],iCt[831:768],iCt[895:832],iCt[959:896],iCt[1023:960],iCt[1087:1024],512'h0};
                   P0_Permutation_Cal_enable <= 1'b1;
				                                    end	  
			{Permutation_Ct_Round0_Cal,Permutation_Ct_Round0_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end					                   				 					           					
			{Permutation_Ct_Round0_Cal,Permutation_Ct_Round1_Cal}: begin
			       P0_Permutation_Cal_iState <= {(iCt[1151 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[1215 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[1279 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[1343 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[1407 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[1471 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[1535 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[1599 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[1663 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[1727 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[1791 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[1855 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[1919 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[1983 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[2047 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[2111 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[2175 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};	
                   P0_Permutation_Cal_enable <= 1'b1;
				                                 end	  
			{Permutation_Ct_Round1_Cal,Permutation_Ct_Round1_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end	
			{Permutation_Ct_Round1_Cal,Permutation_Ct_Round2_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[2239 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[2303 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[2367 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[2431 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[2495 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[2559 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[2623 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[2687 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[2751 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[2815 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[2879 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[2943 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[3007 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[3071 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[3135 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[3199 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[3263 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1;
                                                                   end
			{Permutation_Ct_Round2_Cal,Permutation_Ct_Round2_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_Ct_Round2_Cal,Permutation_Ct_Round3_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[3327 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[3391 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[3455 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[3519 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[3583 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[3647 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[3711 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[3775 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[3839 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[3903 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[3967 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[4031 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[4095 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[4159 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[4223 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[4287 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[4351 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_Ct_Round3_Cal,Permutation_Ct_Round3_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_Ct_Round3_Cal,Permutation_Ct_Round4_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[4415 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[4479 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[4543 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[4607 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[4671 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[4735 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[4799 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[4863 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[4927 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[4991 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[5055 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[5119 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[5183 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[5247 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[5311 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[5375 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[5439 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_Ct_Round4_Cal,Permutation_Ct_Round4_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_Ct_Round4_Cal,Permutation_Ct_Squeeze}: begin                  
                   P0_Permutation_Cal_iState <= {(iCt[5503 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[5567 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[5631 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[5695 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[5759 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[5823 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[5887 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(64'h0000000000000006 ^ P0_Permutation_Cal_oState[1151 -: 64]),P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[639 -: 64],(64'h8000000000000000 ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_Ct_Squeeze,Permutation_Ct_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                             end
			{Permutation_Ct_Squeeze,Permutation_SS_Squeeze}: begin
			       o_Kr <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64],i_post_Kr_Low};
			       P0_Permutation_Cal_iState <= {i_post_Kr_Low[63 -: 64],i_post_Kr_Low[127 -: 64],i_post_Kr_Low[191 -: 64],i_post_Kr_Low[255 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],64'h000000000000001f,448'h0,64'h8000000000000000,512'h0};
                   P0_Permutation_Cal_enable <= 1'b1; 
									                         end
			{Permutation_SS_Squeeze,Permutation_SS_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                             end
			{Permutation_SS_Squeeze,IDLE}: begin
			       Pre_Post_indcpa_done <= 1'b1;
				   o_post_SS <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
					                       end						  
			default: ;
			endcase					
		     end                                         
                                                                           
State_Hash_Permutation_Cal P0(
.clk(clk),
.reset_n(rst_n),
.enable(P0_Permutation_Cal_enable),
.iState(P0_Permutation_Cal_iState),
.out_ready(P0_Permutation_Cal_done),
.oState(P0_Permutation_Cal_oState)
);

endmodule
