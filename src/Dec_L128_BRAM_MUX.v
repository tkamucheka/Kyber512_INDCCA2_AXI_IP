//////////////////////////////////////////////////////////////////////////////////
// Module Name: Dec_L128_BRAM_MUX
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module Dec_L128_BRAM_MUX(
      input [3 : 0] cstate,
      input mux_enc_dec,
      input P3_Enc_BpV_DecMp_outready,
      input [7 : 0] P3_Enc_BpV_DecMp_WAd,
      input [127 : 0] P3_Enc_BpV_DecMp_WData,      
      input [2 : 0] PACC_EncBp_DecMp_Poly_RAd,
      input P5_Sub_EncBp_DecMp_outready,
      input [7 : 0] P5_Sub_EncBp_DecMp_WAd,
      input [127 : 0] P5_Sub_EncBp_DecMp_WData,      
      input [2 : 0] P6_Add_EncBpV_DecMp_RAd,
      input P9_AtG_WEN,
      input [7 : 0] P9_AtG_WAd,
      input [127 : 0] P9_AtG_WData,
      input [2 : 0] P3_M3_RAd,
      input P10_M3_WEN,
      input [7 : 0] P10_M3_WAd,
      input [127 : 0] P10_M3_WData,         
      output reg M3_WEN,
      output reg [7 : 0] M3_WAd,
      output reg [127 : 0] M3_WData,
      output reg [2 : 0] M3_RAd
);

parameter ENC               = 1'b0;
parameter DEC               = 1'b1;
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
  
always@(*)
begin
     case({cstate,mux_enc_dec})
     {DEC_ENC_PAcc,DEC}: begin // only write
         M3_WEN <= P3_Enc_BpV_DecMp_outready;
         M3_WAd <= P3_Enc_BpV_DecMp_WAd;
         M3_WData <= P3_Enc_BpV_DecMp_WData;
         M3_RAd <= 0;
                         end
     {DEC_ENC_INTT,DEC}: begin // only read
         M3_WEN <= 1'b0;
         M3_WAd <= 0; 
         M3_WData <= 0;
         M3_RAd <= PACC_EncBp_DecMp_Poly_RAd;    
                         end 
     {DEC_Sub,DEC}: begin // only write
         M3_WEN <= P5_Sub_EncBp_DecMp_outready;
         M3_WAd <= P5_Sub_EncBp_DecMp_WAd;
         M3_WData <= P5_Sub_EncBp_DecMp_WData;
         M3_RAd <= 0;
                         end
      {DEC_ENC_Reduce,DEC}: begin // only read
         M3_WEN <= 1'b0;
         M3_WAd <= 0; 
         M3_WData <= 0;
         M3_RAd <= P6_Add_EncBpV_DecMp_RAd;    
                      end          
      {ENC_Hash,ENC}: begin //only write
         M3_WEN <= P9_AtG_WEN;
         M3_WAd <= P9_AtG_WAd;
         M3_WData <= P9_AtG_WData;
         M3_RAd <= 0;
                      end
     {DEC_ENC_PAcc,ENC}: begin // read first, write then
         M3_WEN <= P3_Enc_BpV_DecMp_outready;
         M3_WAd <= P3_Enc_BpV_DecMp_WAd;
         M3_WData <= P3_Enc_BpV_DecMp_WData;
         M3_RAd <= P3_M3_RAd;
                         end                      
     {DEC_ENC_INTT,ENC}: begin // onlyread 
         M3_WEN <= 1'b0;
         M3_WAd <= 0; 
         M3_WData <= 0;
         M3_RAd <= PACC_EncBp_DecMp_Poly_RAd;    
                         end        
      {ENC_Add,ENC}: begin //only write
         M3_WEN <= P10_M3_WEN;
         M3_WAd <= P10_M3_WAd;
         M3_WData <= P10_M3_WData;
         M3_RAd <= 0;
                     end
      {DEC_ENC_Reduce,ENC}: begin // only read
         M3_WEN <= 1'b0;
         M3_WAd <= 0; 
         M3_WData <= 0;
         M3_RAd <= P6_Add_EncBpV_DecMp_RAd;  
                           end
     default:begin
         M3_WEN <= 1'b0;
         M3_WAd <= 0; 
         M3_WData <= 0;
         M3_RAd <= 0;     
             end
     endcase
end 
    
endmodule
