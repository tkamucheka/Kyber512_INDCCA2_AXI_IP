//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Hash
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
// Additional Comments: Integration SHAKE-128,SHA3-256,SHA3-512 etc.
//////////////////////////////////////////////////////////////////////////////////

module State_Hash#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter At_CharArray_Width = 8,
  parameter At_Char_Array_Num = 672,
  parameter At_CharArray_Size = At_CharArray_Width * At_Char_Array_Num,
  parameter noise_CharArray_Width = 8,
  parameter noise_Char_Array_Num = 128,
  parameter noise_CharArray_Size = noise_CharArray_Width * noise_Char_Array_Num,
  parameter Seed_Bytes = 32,
  parameter Coins_Bytes = 32,
  parameter Byte_bits = 8,
  parameter oAt_Poly_Length = 16,
  parameter oAtG_BRAM_Length = 128,
  parameter onoise_Poly_Length = 4,
  parameter onoise_BRAM_Length = 32,
  parameter iSeed_Size = Byte_bits * Seed_Bytes,
  parameter iCoins_Size = Byte_bits * Coins_Bytes,
  parameter Poly_At_Size = oAt_Poly_Length * KYBER_N,
  parameter Poly_noise_Size = onoise_Poly_Length * KYBER_N
)(
input  clk,
input  rst_n,
input  enable,
input  [iSeed_Size-1 : 0]  iSeed,
input  [iCoins_Size-1 : 0]  iCoins,
output reg  Function_done,
output reg  AtG_outready,
output reg  [7 : 0] AtG_WAd, // 0-31 At00, 32-63 At01, 64-95 At10, 96-127 At11
output reg  [oAtG_BRAM_Length-1 : 0] AtG_WData,
output reg  Sp_r_outready,
output reg  [5 : 0] Sp_r_WAd, // 0-31 r0, 32-63 r1
output reg  [onoise_BRAM_Length-1 : 0] Sp_r_WData,
output reg  eG_outready,
output reg  [6 : 0] eG_WAd, // 0-31 e0_0, 32-63 e0_1, 64-95 e1
output reg  [onoise_BRAM_Length-1 : 0] eG_WData
// DEBUG:
// output reg [1023:0] At_debug,
// output reg [255:0] Sp_debug,
// output reg [255:0] eG_debug
);

reg  P0_Permutation_enable;
reg  P0_permutation_only_noise;
reg  [1 : 0] P0_permutation_elements_num; //i,j
reg  [3 : 0] P0_permutation_nonce;
wire P0_permutation_done;
wire [At_CharArray_Size-1 : 0] P0_permutation_At_Char;
wire [noise_CharArray_Size-1 : 0] P0_permutation_Noise_Char;

reg  P1_Rej_Uniform_enable;
reg  P1_Rej_Uniform_clear;
wire P1_Rej_Uniform_done;
wire [Poly_At_Size -1 : 0] P1_Rej_Uniform_oPoly;

reg  P2_CBD_enable;
reg  P2_CBD_clear;		
wire P2_CBD_done;
wire [Poly_noise_Size -1 : 0] P2_CBD_oPoly;

reg [3:0] cstate,nstate;
localparam IDLE		       = 4'd0;
localparam Permutation_0 = 4'd1;
localparam Rej_CBD_0     = 4'd2;
localparam Push_0        = 4'd11;
localparam Permutation_1 = 4'd3;
localparam Rej_CBD_1     = 4'd4;
localparam Push_1        = 4'd12;
localparam Permutation_2 = 4'd5;
localparam Rej_CBD_2     = 4'd6;
localparam Push_2        = 4'd13;
localparam Permutation_3 = 4'd7;
localparam Rej_CBD_3     = 4'd8;
localparam Push_3        = 4'd14;
localparam Permutation_4 = 4'd9;
localparam CBD_4         = 4'd10;
localparam Push_4        = 4'd15;

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or P0_permutation_done or P1_Rej_Uniform_done or 
        P2_CBD_done or AtG_WAd or Sp_r_WAd or eG_WAd)
begin				
	case(cstate)
		IDLE: 	        if(enable)                              nstate <= Permutation_0;
				            else                                    nstate <= IDLE;
		Permutation_0:  if(P0_permutation_done)                 nstate <= Rej_CBD_0;
				            else                                    nstate <= Permutation_0;
		Rej_CBD_0:      if(P1_Rej_Uniform_done && P2_CBD_done)  nstate <= Push_0;
	                  else                                    nstate <= Rej_CBD_0;
    Push_0:         if((AtG_WAd == 31) && (Sp_r_WAd == 31)) nstate <= Permutation_1;
                    else                                    nstate <= Push_0;
		Permutation_1:  if(P0_permutation_done)                 nstate <= Rej_CBD_1;
				            else                                    nstate <= Permutation_1;
		Rej_CBD_1:      if(P1_Rej_Uniform_done && P2_CBD_done)  nstate <= Push_1;
                    else                                    nstate <= Rej_CBD_1;
    Push_1:         if((AtG_WAd == 63) && (Sp_r_WAd == 63)) nstate <= Permutation_2;
                    else                                    nstate <= Push_1;	                    
		Permutation_2:  if(P0_permutation_done)                 nstate <= Rej_CBD_2;
				            else                                    nstate <= Permutation_2;
		Rej_CBD_2:      if(P1_Rej_Uniform_done && P2_CBD_done)  nstate <= Push_2;
                    else                                    nstate <= Rej_CBD_2;		
    Push_2:         if((AtG_WAd == 95) && (eG_WAd == 31))   nstate <= Permutation_3;
                    else                                    nstate <= Push_2;	                                        	  	                           	                           
		Permutation_3:  if(P0_permutation_done)                 nstate <= Rej_CBD_3;
				            else                                    nstate <= Permutation_3;
		Rej_CBD_3:      if(P1_Rej_Uniform_done && P2_CBD_done)  nstate <= Push_3;
                    else                                    nstate <= Rej_CBD_3;
    Push_3:         if((AtG_WAd == 127) && (eG_WAd == 63))  nstate <= Permutation_4;
                    else                                    nstate <= Push_3;	
    Permutation_4:  if(P0_permutation_done)                 nstate <= CBD_4;
				            else                                    nstate <= Permutation_4;
		CBD_4:          if(P2_CBD_done)                         nstate <= Push_4;
                    else                                    nstate <= CBD_4;
    Push_4:         if(eG_WAd == 95)                        nstate <= IDLE;
                    else                                    nstate <= Push_4;	
	  default:                                                nstate <= IDLE;
  endcase
end

always @(posedge clk)										
	if(!rst_n) begin
    Function_done                   <= 1'b0;
    AtG_outready                    <= 1'b0;
    AtG_WAd                         <= 0;
    AtG_WData                       <= 0;
    Sp_r_outready                   <= 1'b0;
    Sp_r_WAd                        <= 0;
    Sp_r_WData                      <= 0;
    eG_outready                     <= 1'b0;
    eG_WAd                          <= 0;
    eG_WData                        <= 0;	        
    P0_Permutation_enable           <= 1'b0;
    P0_permutation_only_noise       <= 1'b0;
    P1_Rej_Uniform_enable           <= 1'b0;
    P1_Rej_Uniform_clear            <= 1'b0;
    P2_CBD_enable                   <= 1'b0;
    P2_CBD_clear                    <= 1'b0;
  end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
        Function_done               <=  1'b0;	
      end
			{IDLE,Permutation_0}: begin
        P0_permutation_elements_num <= 2'b00;
        P0_permutation_nonce        <= 4'd0;
        P0_permutation_only_noise   <= 1'b0;
        P0_Permutation_enable       <= 1'b1;
        P1_Rej_Uniform_clear        <= 1'b0;
        P2_CBD_clear                <= 1'b0;
      end
			{Permutation_0,Permutation_0}: begin
        P0_Permutation_enable       <= 1'b0;  			                              			    
      end				                  			
			{Permutation_0,Rej_CBD_0}: begin
        P1_Rej_Uniform_enable       <= 1'b1;
        P2_CBD_enable               <= 1'b1;
      end
			{Rej_CBD_0,Rej_CBD_0}: begin
        P1_Rej_Uniform_enable       <= 1'b0;
        P2_CBD_enable               <= 1'b0;
      end
			{Rej_CBD_0,Push_0}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= 0;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[oAtG_BRAM_Length-1 : 0];
        Sp_r_outready               <= 1'b1; 
        Sp_r_WAd                    <= 0;
        Sp_r_WData                  <= P2_CBD_oPoly[onoise_BRAM_Length-1 : 0];
        // DEBUG:
        // At_debug[1023 -: 512]  <= P1_Rej_Uniform_oPoly[4095 -: 512];
        // At_debug[511  -: 512]  <= P1_Rej_Uniform_oPoly[511  -: 512];
        // Sp_debug               <= P2_CBD_oPoly[255:0];
      end                                       
			{Push_0,Push_0}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= AtG_WAd + 1;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[(AtG_WAd+2)*oAtG_BRAM_Length -1 -: oAtG_BRAM_Length];
        Sp_r_outready               <= 1'b1; 
        Sp_r_WAd                    <= Sp_r_WAd + 1;
        Sp_r_WData                  <= P2_CBD_oPoly[(Sp_r_WAd+2)*onoise_BRAM_Length -1 -: onoise_BRAM_Length];
      end    	                                                   
			{Push_0,Permutation_1}: begin
        AtG_outready                <= 1'b0;
        Sp_r_outready               <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b1;
        P2_CBD_clear                <= 1'b1;
        P0_permutation_elements_num <= 2'b01;
        P0_permutation_nonce        <= 4'd1;
        P0_permutation_only_noise   <= 1'b0;
        P0_Permutation_enable       <= 1'b1;  
      end
			{Permutation_1,Permutation_1}: begin			
        P0_Permutation_enable       <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b0;
        P2_CBD_clear                <= 1'b0;
      end
			{Rej_CBD_1,Rej_CBD_1}: begin
        P1_Rej_Uniform_enable       <= 1'b0;
        P2_CBD_enable               <= 1'b0;
      end
			{Permutation_1,Rej_CBD_1}: begin
        P1_Rej_Uniform_enable       <= 1'b1;
        P2_CBD_enable               <= 1'b1;
      end
			{Rej_CBD_1,Push_1}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= 32;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[oAtG_BRAM_Length-1 : 0];
        Sp_r_outready               <= 1'b1; 
        Sp_r_WAd                    <= 32;
        Sp_r_WData                  <= P2_CBD_oPoly[onoise_BRAM_Length-1 : 0];
      end                                       
			{Push_1,Push_1}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= AtG_WAd + 1;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[(AtG_WAd-32+2)*oAtG_BRAM_Length -1 -: oAtG_BRAM_Length];
        Sp_r_outready               <= 1'b1; 
        Sp_r_WAd                    <= Sp_r_WAd + 1;
        Sp_r_WData                  <= P2_CBD_oPoly[(Sp_r_WAd-32+2)*onoise_BRAM_Length -1 -: onoise_BRAM_Length];
      end 
			{Push_1,Permutation_2}: begin
      AtG_outready                  <= 1'b0;
        Sp_r_outready               <= 1'b0;                   
        P1_Rej_Uniform_clear        <= 1'b1;
        P2_CBD_clear                <= 1'b1;
        P0_permutation_elements_num <= 2'b10;
        P0_permutation_nonce        <= 4'd2;
        P0_permutation_only_noise   <= 1'b0;
        P0_Permutation_enable       <= 1'b1;  
      end                                                                              	                            	  
			{Permutation_2,Permutation_2}: begin			
        P0_Permutation_enable       <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b0;
        P2_CBD_clear                <= 1'b0;
      end
			{Permutation_2,Rej_CBD_2}: begin
        P1_Rej_Uniform_enable       <= 1'b1;
        P2_CBD_enable               <= 1'b1;
      end
			{Rej_CBD_2,Rej_CBD_2}: begin
        P1_Rej_Uniform_enable       <= 1'b0;
        P2_CBD_enable               <= 1'b0;
      end
			{Rej_CBD_2,Push_2}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= 32*2;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[oAtG_BRAM_Length-1 : 0];
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= 0;
        eG_WData                    <= P2_CBD_oPoly[onoise_BRAM_Length-1 : 0];
        // DEBUG:
        // eG_debug  <= P2_CBD_oPoly[255:0];
      end                                       
			{Push_2,Push_2}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= AtG_WAd + 1;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[(AtG_WAd-32-32+2)*oAtG_BRAM_Length -1 -: oAtG_BRAM_Length];
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= eG_WAd + 1;
        eG_WData                    <= P2_CBD_oPoly[(eG_WAd+2)*onoise_BRAM_Length -1 -: onoise_BRAM_Length];
      end 
			{Push_2,Permutation_3}: begin
        AtG_outready                <= 1'b0;
        eG_outready                 <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b1;
        P2_CBD_clear                <= 1'b1;
        P0_permutation_elements_num <= 2'b11;
        P0_permutation_nonce        <= 4'd3;
        P0_permutation_only_noise   <= 1'b0;
        P0_Permutation_enable       <= 1'b1;  
      end
			{Permutation_3,Permutation_3}: begin			
        P0_Permutation_enable       <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b0;
        P2_CBD_clear                <= 1'b0;
      end
			{Permutation_3,Rej_CBD_3}: begin
        P1_Rej_Uniform_enable       <= 1'b1;
        P2_CBD_enable               <= 1'b1;
      end
			{Rej_CBD_3,Rej_CBD_3}: begin
        P1_Rej_Uniform_enable       <= 1'b0;
        P2_CBD_enable               <= 1'b0;
      end
			{Rej_CBD_3,Push_3}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= 32*3;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[oAtG_BRAM_Length-1 : 0];
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= 32;
        eG_WData                    <= P2_CBD_oPoly[onoise_BRAM_Length-1 : 0];
      end                                       
			{Push_3,Push_3}: begin
        AtG_outready                <= 1'b1;
        AtG_WAd                     <= AtG_WAd + 1;
        AtG_WData                   <= P1_Rej_Uniform_oPoly[(AtG_WAd-32-32-32+2)*oAtG_BRAM_Length -1 -: oAtG_BRAM_Length];
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= eG_WAd + 1;
        eG_WData                    <= P2_CBD_oPoly[(eG_WAd-32+2)*onoise_BRAM_Length -1 -: onoise_BRAM_Length];
      end 
			{Push_3,Permutation_4}: begin
        AtG_outready                <= 1'b0;
        eG_outready                 <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b1;
        P2_CBD_clear                <= 1'b1;
        P0_permutation_elements_num <= 2'b00;
        P0_permutation_nonce        <= 4'd4;
        P0_permutation_only_noise   <= 1'b1;
        P0_Permutation_enable       <= 1'b1;  
      end
			{Permutation_4,Permutation_4}: begin
        P0_Permutation_enable       <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b0;
        P2_CBD_clear                <= 1'b0;				        
      end					                   				 					           					
			{Permutation_4,CBD_4}: begin
        P2_CBD_enable               <= 1'b1;
      end	  
			{CBD_4,CBD_4}: begin
        P2_CBD_enable               <= 1'b0;				        
      end	
			{CBD_4,Push_4}: begin
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= 32*2;
        eG_WData                    <= P2_CBD_oPoly[onoise_BRAM_Length-1 : 0];
      end
			{Push_4,Push_4}: begin
        eG_outready                 <= 1'b1; 
        eG_WAd                      <= eG_WAd + 1;
        eG_WData                    <= P2_CBD_oPoly[(eG_WAd-32-32+2)*onoise_BRAM_Length -1 -: onoise_BRAM_Length];
      end 
			{Push_4,IDLE}: begin
        eG_outready                 <= 1'b0; 
        P1_Rej_Uniform_clear        <= 1'b1;
        P2_CBD_clear                <= 1'b1;
        P0_permutation_nonce        <= 4'd0; 
        AtG_WAd                     <= 0;
        AtG_WData                   <= 0;
        Sp_r_WAd                    <= 0;
        Sp_r_WData                  <= 0;
        eG_WAd                      <= 0;
        eG_WData                    <= 0;                
        Function_done               <= 1'b1;                
      end	  
			default: ;
    endcase
  end


State_Hash__Permutation P0 (
  .clk(clk),
  .reset_n(rst_n),
  .enable(P0_Permutation_enable),
  .permutation_only_noise(P0_permutation_only_noise),
  .iSeed(iSeed),
  .elements_num(P0_permutation_elements_num), //i,j
  .iCoins(iCoins),
  .nonce(P0_permutation_nonce),
  .Permutation_done(P0_permutation_done),
  .oAt_Char(P0_permutation_At_Char),
  .oNoise_Char(P0_permutation_Noise_Char));

State_Hash__Rej_Uniform P1 (
  .clk(clk),
  .reset_n(rst_n),
  .enable(P1_Rej_Uniform_enable),
  .clear(P1_Rej_Uniform_clear),	
  .i_CharArray(P0_permutation_At_Char),
  .Rej_Uniform_done(P1_Rej_Uniform_done),
  .oPoly(P1_Rej_Uniform_oPoly));

State_Hash__CBD P2 (
  .clk(clk),
  .reset_n(rst_n),
  .enable(P2_CBD_enable),
  .clear(P2_CBD_clear),		
  .i_CharArray(P0_permutation_Noise_Char),
  .CBD_done(P2_CBD_done),
  .oPoly(P2_CBD_oPoly));

endmodule