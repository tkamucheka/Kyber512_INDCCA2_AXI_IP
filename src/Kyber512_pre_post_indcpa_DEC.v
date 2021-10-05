//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_pre_post_indcpa_DEC
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_pre_post_indcpa_DEC#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter State_Width = 64,
  parameter State_Array = 25,
  parameter State_Size = State_Width * State_Array,
  parameter Byte_bits = 8,
  parameter Sk_Bytes = 1632,
  parameter Ct_Bytes = 736,  
  parameter Buf_Bytes_Half = 32,
  parameter Kr_Bytes = 64,
  parameter SS_Bytes = 32,
  parameter iCt_Size = Byte_bits * Ct_Bytes,
  parameter iSk_Size = Byte_bits * Sk_Bytes, 
  parameter iCmp_Size = Byte_bits * Ct_Bytes,  
  parameter Buf_Half_Size = Byte_bits * Buf_Bytes_Half,
  parameter o_Kr_Size = Byte_bits * Kr_Bytes,
  parameter o_SS_Size = Byte_bits * SS_Bytes
)(
input  clk,
input  rst_n,
input  enable,
input  mode,//0 for pre, 1 for post
input  [iSk_Size-1 : 0]  iSk,
input  [iCt_Size-1 : 0]  iCt,
input  [Buf_Half_Size-1 : 0] iBuf_Low_pre_msg_post_K,
input  [iCmp_Size - 1 : 0] iCmp_post,
output reg  Pre_Post_indcpa_DEC_done,
output reg  [o_Kr_Size - 1 : 0] oKr_pre,
output reg  [o_SS_Size - 1 : 0] o_post_SS_post,
output reg  Verify_fail
);
      
reg  P0_Permutation_Cal_enable;
reg  [State_Size-1 : 0] P0_Permutation_Cal_iState;
wire P0_Permutation_Cal_done;
wire [State_Size-1 : 0] P0_Permutation_Cal_oState;

reg [3:0] cstate,nstate;
parameter IDLE		                  = 4'd0;
parameter Permutation_G_Buf_Squeeze   = 4'd1;
parameter Campare                     = 4'd2;
parameter Permutation_H_Ct_Round0_Cal = 4'd3;
parameter Permutation_H_Ct_Round1_Cal = 4'd4;
parameter Permutation_H_Ct_Round2_Cal = 4'd5;
parameter Permutation_H_Ct_Round3_Cal = 4'd6;
parameter Permutation_H_Ct_Round4_Cal = 4'd7;
parameter Permutation_H_Ct_Squeeze    = 4'd8;
parameter Copy_Z_2_Kr_Low             = 4'd9;
parameter Permutation_KDF_Squeeze     = 4'd10;

always @(posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or P0_Permutation_Cal_done)
begin	
   if(!mode) begin			
	case(cstate)
		IDLE:                       if(enable) nstate <= Permutation_G_Buf_Squeeze;
				                     else nstate <= IDLE;
		Permutation_G_Buf_Squeeze:  if(P0_Permutation_Cal_done) nstate <= IDLE;
		                             else nstate <= Permutation_G_Buf_Squeeze;               				
		default: nstate <= IDLE;
		endcase
		       end
    else begin
	case(cstate)
		IDLE:                        if(enable) nstate <= Campare;
				                      else nstate <= IDLE;
		Campare:                     nstate <= Permutation_H_Ct_Round0_Cal;
		Permutation_H_Ct_Round0_Cal: if(P0_Permutation_Cal_done) nstate <= Permutation_H_Ct_Round1_Cal;
	                                  else nstate <= Permutation_H_Ct_Round0_Cal;
		Permutation_H_Ct_Round1_Cal: if(P0_Permutation_Cal_done) nstate <= Permutation_H_Ct_Round2_Cal;
	                                  else nstate <= Permutation_H_Ct_Round1_Cal;
		Permutation_H_Ct_Round2_Cal: if(P0_Permutation_Cal_done) nstate <= Permutation_H_Ct_Round3_Cal;
	                                  else nstate <= Permutation_H_Ct_Round2_Cal;
		Permutation_H_Ct_Round3_Cal: if(P0_Permutation_Cal_done) nstate <= Permutation_H_Ct_Round4_Cal;
	                                  else nstate <= Permutation_H_Ct_Round3_Cal;
		Permutation_H_Ct_Round4_Cal: if(P0_Permutation_Cal_done) nstate <= Permutation_H_Ct_Squeeze;
	                                  else nstate <= Permutation_H_Ct_Round4_Cal;	                                 	
		Permutation_H_Ct_Squeeze:    if(P0_Permutation_Cal_done) nstate <= Copy_Z_2_Kr_Low;		                             
	                                   else nstate <= Permutation_H_Ct_Squeeze;
	    Copy_Z_2_Kr_Low:             nstate <= Permutation_KDF_Squeeze;                               	  	
		Permutation_KDF_Squeeze:     if(P0_Permutation_Cal_done) nstate <= IDLE;
	                                  else nstate <= Permutation_KDF_Squeeze;                  				
		default: nstate <= IDLE;
		endcase
		   end
end          


always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
	        Pre_Post_indcpa_DEC_done <= 1'b0;
	        oKr_pre <= 0;
	        o_post_SS_post <= 0;
	        P0_Permutation_Cal_enable <= 1'b0;
	        Verify_fail <= 1'b0;
		         end
	else if(!mode) begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
				   Pre_Post_indcpa_DEC_done <=  1'b0;	
				  end
			{IDLE,Permutation_G_Buf_Squeeze}: begin			        
			       P0_Permutation_Cal_iState <= {iBuf_Low_pre_msg_post_K[63:0],iBuf_Low_pre_msg_post_K[127:64],iBuf_Low_pre_msg_post_K[191:128],iBuf_Low_pre_msg_post_K[255:192],iSk[12607 : 12544],iSk[12671 : 12608],iSk[12735 : 12672],iSk[12799 : 12736],64'h8000000000000006,1024'h0};
			       P0_Permutation_Cal_enable <= 1'b1;			                              			    
				                            end			
			{Permutation_G_Buf_Squeeze,Permutation_G_Buf_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;
                                                               end
			{Permutation_G_Buf_Squeeze,IDLE}: begin
			       Pre_Post_indcpa_DEC_done <= 1'b1;
				   oKr_pre <= {P0_Permutation_Cal_oState[1152-1 -: 64],P0_Permutation_Cal_oState[1216-1 -: 64],P0_Permutation_Cal_oState[1280-1 -: 64],P0_Permutation_Cal_oState[1344-1 -: 64],P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
				                              end	  
			default: ;
			endcase
		              end  
		else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
				   Pre_Post_indcpa_DEC_done <=  1'b0;	
				  end
			{IDLE,Campare}: begin			        
                   if(iCt == iCmp_post) begin
                     Verify_fail <= 1'b0;
                                        end
                   else begin
                     Verify_fail <= 1'b1;
                        end           
				            end	  
			{Campare,Permutation_H_Ct_Round0_Cal}: begin
                  P0_Permutation_Cal_iState <= {iCt[63:0],iCt[127:64],iCt[191:128],iCt[255:192],iCt[319:256],iCt[383:320],iCt[447:384],iCt[511:448],iCt[575:512],iCt[639:576],iCt[703:640],iCt[767:704],iCt[831:768],iCt[895:832],iCt[959:896],iCt[1023:960],iCt[1087:1024],512'h0};
                   P0_Permutation_Cal_enable <= 1'b1;
                                                    end	
  			{Permutation_H_Ct_Round0_Cal,Permutation_H_Ct_Round0_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                       end	                                                  				                   				 					           					
			{Permutation_H_Ct_Round0_Cal,Permutation_H_Ct_Round1_Cal}: begin
			       P0_Permutation_Cal_iState <= {(iCt[1151 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[1215 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[1279 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[1343 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[1407 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[1471 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[1535 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[1599 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[1663 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[1727 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[1791 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[1855 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[1919 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[1983 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[2047 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[2111 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[2175 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};	
                   P0_Permutation_Cal_enable <= 1'b1;
				                                 end	  
			{Permutation_H_Ct_Round1_Cal,Permutation_H_Ct_Round1_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end	
			{Permutation_H_Ct_Round1_Cal,Permutation_H_Ct_Round2_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[2239 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[2303 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[2367 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[2431 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[2495 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[2559 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[2623 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[2687 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[2751 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[2815 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[2879 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[2943 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[3007 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[3071 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[3135 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[3199 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[3263 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1;
                                                                   end
			{Permutation_H_Ct_Round2_Cal,Permutation_H_Ct_Round2_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_H_Ct_Round2_Cal,Permutation_H_Ct_Round3_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[3327 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[3391 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[3455 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[3519 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[3583 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[3647 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[3711 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[3775 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[3839 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[3903 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[3967 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[4031 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[4095 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[4159 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[4223 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[4287 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[4351 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_H_Ct_Round3_Cal,Permutation_H_Ct_Round3_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_H_Ct_Round3_Cal,Permutation_H_Ct_Round4_Cal}: begin
                   P0_Permutation_Cal_iState <= {(iCt[4415 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[4479 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[4543 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[4607 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[4671 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[4735 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[4799 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(iCt[4863 -: 64] ^ P0_Permutation_Cal_oState[1151 -: 64]),(iCt[4927 -: 64] ^ P0_Permutation_Cal_oState[1087 -: 64]),(iCt[4991 -: 64] ^ P0_Permutation_Cal_oState[1023 -: 64]),(iCt[5055 -: 64] ^ P0_Permutation_Cal_oState[959 -: 64]),(iCt[5119 -: 64] ^ P0_Permutation_Cal_oState[895 -: 64]),(iCt[5183 -: 64] ^ P0_Permutation_Cal_oState[831 -: 64]),(iCt[5247 -: 64] ^ P0_Permutation_Cal_oState[767 -: 64]),(iCt[5311 -: 64] ^ P0_Permutation_Cal_oState[703 -: 64]),(iCt[5375 -: 64] ^ P0_Permutation_Cal_oState[639 -: 64]),(iCt[5439 -: 64] ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_H_Ct_Round4_Cal,Permutation_H_Ct_Round4_Cal}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                                   end
			{Permutation_H_Ct_Round4_Cal,Permutation_H_Ct_Squeeze}: begin                  
                   P0_Permutation_Cal_iState <= {(iCt[5503 -: 64] ^ P0_Permutation_Cal_oState[1599 -: 64]),(iCt[5567 -: 64] ^ P0_Permutation_Cal_oState[1535 -: 64]),(iCt[5631 -: 64] ^ P0_Permutation_Cal_oState[1471 -: 64]),(iCt[5695 -: 64] ^ P0_Permutation_Cal_oState[1407 -: 64]),(iCt[5759 -: 64] ^ P0_Permutation_Cal_oState[1343 -: 64]),(iCt[5823 -: 64] ^ P0_Permutation_Cal_oState[1279 -: 64]),(iCt[5887 -: 64] ^ P0_Permutation_Cal_oState[1215 -: 64]),(64'h0000000000000006 ^ P0_Permutation_Cal_oState[1151 -: 64]),P0_Permutation_Cal_oState[1087 -: 64],P0_Permutation_Cal_oState[1023 -: 64],P0_Permutation_Cal_oState[959 -: 64],P0_Permutation_Cal_oState[895 -: 64],P0_Permutation_Cal_oState[831 -: 64],P0_Permutation_Cal_oState[767 -: 64],P0_Permutation_Cal_oState[703 -: 64],P0_Permutation_Cal_oState[639 -: 64],(64'h8000000000000000 ^ P0_Permutation_Cal_oState[575 -: 64]),P0_Permutation_Cal_oState[511 -: 512]};
                   P0_Permutation_Cal_enable <= 1'b1; 
                                                                   end
			{Permutation_H_Ct_Squeeze,Permutation_H_Ct_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                             end
			{Permutation_H_Ct_Squeeze,Copy_Z_2_Kr_Low}: begin
			      if(Verify_fail) begin
			        oKr_pre <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64],iSk[13055 -: 256]};
			                      end
			      else begin
			        oKr_pre <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64],iBuf_Low_pre_msg_post_K};   
			           end
									                     end
            {Copy_Z_2_Kr_Low,Permutation_KDF_Squeeze}: begin
			       P0_Permutation_Cal_iState <= {oKr_pre[63 -: 64],oKr_pre[127 -: 64],oKr_pre[191 -: 64],oKr_pre[255 -: 64],oKr_pre[319 -: 64],oKr_pre[383 -: 64],oKr_pre[447 -: 64],oKr_pre[511 -: 64],64'h000000000000001f,448'h0,64'h8000000000000000,512'h0};
                   P0_Permutation_Cal_enable <= 1'b1; 
									                            end
			{Permutation_KDF_Squeeze,Permutation_KDF_Squeeze}: begin
                   P0_Permutation_Cal_enable <= 1'b0;				        
                                                               end
			{Permutation_KDF_Squeeze,IDLE}: begin
			       Pre_Post_indcpa_DEC_done <= 1'b1;
				   o_post_SS_post <= {P0_Permutation_Cal_oState[1408-1 -: 64],P0_Permutation_Cal_oState[1472-1 -: 64],P0_Permutation_Cal_oState[1536-1 -: 64],P0_Permutation_Cal_oState[1600-1 -: 64]};
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
