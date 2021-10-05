//////////////////////////////////////////////////////////////////////////////////
// Module Name: L12_k_MUX
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module L12_k_MUX(
      input [3 : 0] cstate,
      input mux_enc_dec,
      input P0_Dec_v_outready,
      input [7 : 0] P0_Dec_v_WAd,
      input [11 : 0] P0_Dec_V_WData,
      input [4 : 0] Dec_v_RAd,
      input P8_out_ready,
      input [7 : 0] P8_Poly_WAd,
      input [11 : 0] P8_WData,
      input [4 : 0] P10_k_RAd, 
      output reg [0 : 0] M1_WEN,
      output reg [7 : 0] M1_WAd,
      output reg [11 : 0] M1_WData,
      output reg [4 : 0] M1_RAd
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
         M1_WEN <= P0_Dec_v_outready;
         M1_WAd <= P0_Dec_v_WAd;
         M1_WData <= P0_Dec_V_WData;
         M1_RAd <= 0;
                           end
     {DEC_Sub,DEC}: begin //only read
         M1_WEN <= 1'b0;
         M1_WAd <= 0;
         M1_WData <= 0;
         M1_RAd <= Dec_v_RAd;
                    end 
      {ENC_From_Msg,ENC}: begin //only write
         M1_WEN <= P8_out_ready;
         M1_WAd <= P8_Poly_WAd;
         M1_WData <= P8_WData;
         M1_RAd <= 0;
                          end
     {ENC_Add,ENC}: begin //only read
         M1_WEN <= 1'b0;
         M1_WAd <= 0;
         M1_WData <= 0;
         M1_RAd <= P10_k_RAd;
                    end                                                      
     default:begin
         M1_WEN <= 1'b0;
         M1_WAd <= 0; 
         M1_WData <= 0;
         M1_RAd <= 0;     
             end
     endcase
end 

endmodule    