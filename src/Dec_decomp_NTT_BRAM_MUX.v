//////////////////////////////////////////////////////////////////////////////////
// Module Name: Dec_decomp_NTT_BRAM_MUX
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module Dec_decomp_NTT_BRAM_MUX(
  input [3 : 0] cstate,
  input mux_enc_dec,
  input P0_ct_outready,
  input [5 : 0] P0_ct_WAd,
  input [95 : 0] P0_Bp_ct_WData,      
  input [0 : 0] P2_Bp_ct_RAd,
  input [0 : 0] P2_NTT_Poly_0_outready,
  input [5 : 0] P2_NTT_Poly_0_WAd,
  input [95 : 0] P2_NTT_Poly_0_WData,
  input [0 : 0] P3_NTT_RAd,
  output reg [0 : 0] M0_WEN,
  output reg [5 : 0] M0_WAd,
  output reg [95 : 0] M0_WData,
  output reg [0 : 0] M0_RAd
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
     {DEC_ENC_Unpack,DEC}: begin //only write
         M0_WEN <= P0_ct_outready;
         M0_WAd <= P0_ct_WAd;
         M0_WData <= P0_Bp_ct_WData;
         M0_RAd <= 0;
                           end
     {DEC_ENC_NTT,DEC}: begin // read first, write then
         M0_WEN <= P2_NTT_Poly_0_outready;
         M0_WAd <= P2_NTT_Poly_0_WAd;
         M0_WData <= P2_NTT_Poly_0_WData;
         M0_RAd <= P2_Bp_ct_RAd;        
                           end
     {DEC_ENC_PAcc,DEC}: begin //only read
         M0_WEN <= 1'b0;
         M0_WAd <= 0; 
         M0_WData <= 0;
         M0_RAd <= P3_NTT_RAd;         
                        end
     {DEC_ENC_NTT,ENC}: begin //only write
         M0_WEN <= P2_NTT_Poly_0_outready;
         M0_WAd <= P2_NTT_Poly_0_WAd;
         M0_WData <= P2_NTT_Poly_0_WData;
         M0_RAd <= 0;
                        end 
      {DEC_ENC_PAcc,ENC}: begin //only read
         M0_WEN <= 1'b0;
         M0_WAd <= 0; 
         M0_WData <= 0;
         M0_RAd <= P3_NTT_RAd;         
                        end
     default:begin
         M0_WEN <= 1'b0;
         M0_WAd <= 0; 
         M0_WData <= 0;
         M0_RAd <= 0;     
             end
     endcase
end 
    
endmodule
