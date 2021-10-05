//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Decompressed_Ciphertext
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG, Tendayi Kamucheka (ftendayi@gmail.com)
//////////////////////////////////////////////////////////////////////////////////

module State_Decompressed_Ciphertext#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter KYBER_POLYCOMPRESSEDBYTES = 96,
  parameter data_Width = 12,
  parameter BYTE_BITS = 8,
  parameter KYBER_512_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter i_Compressed_Seed_Size = BYTE_BITS * KYBER_POLYCOMPRESSEDBYTES,
  parameter i_Compressed_Polyvec_Size = BYTE_BITS * KYBER_512_POLYVECCOMPRESSEDBYTES,
  parameter o_Poly_Size = data_Width * KYBER_N,
  parameter o_BP_BRAM_Length = 96,
  parameter o_v_BRAM_Length = 12,
  parameter KYBER_512_POLYCOMPRESSEDBYTES = 96,
  parameter KYBER_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter KYBER_INDCPA_BYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_512_POLYCOMPRESSEDBYTES,
  parameter CIPHERTEXT_SZ = BYTE_BITS * KYBER_INDCPA_BYTES
)(
    input  clk,		
    input  rst_n,
    input  enable,	
    // input  [i_Compressed_Seed_Size-1 : 0] iSeed_Char,
    input  [CIPHERTEXT_SZ-1 : 0] i_CT,
    output reg Function_done,
    output reg                            Dec_Bp_outready,
    output reg [5 : 0]                    Dec_Bp_WAd,
    output reg [o_BP_BRAM_Length -1 : 0]  Dec_Bp_WData,
    output reg Dec_V_outready,
    output reg [7 : 0] Dec_V_WAd,
    output reg [o_v_BRAM_Length-1 : 0] Dec_V_WData
);
																
reg  [(BYTE_BITS*320)-1 : 0]	temp_BPchar_in; 
wire [o_Poly_Size-1 : 0]      temp_BP_out;
wire [o_Poly_Size-1 : 0]      temp_V_out;
	
reg decomp_V_enable;
reg decomp_Bp_enable;																														
wire decomp_V_done;
wire decomp_Bp_done;

reg [2:0] cstate,nstate;
localparam IDLE		      = 3'd0;
localparam Unpack_BP0    = 3'd1;
localparam Push_BP0      = 3'd2;
localparam Unpack_V	    = 3'd3;
localparam Push_V     = 3'd4;
localparam Unpack_BP1 		= 3'd5;
localparam Push_BP1      = 3'd6;

always @(posedge clk or negedge rst_n)
	if(!rst_n)  cstate <= IDLE;
	else        cstate <= nstate;
	
always @(cstate or enable or decomp_V_done or decomp_Bp_done or Dec_Bp_WAd 
          or Dec_V_WAd)
begin	
	case(cstate)
		IDLE: 	    if (enable)           nstate <= Unpack_BP0;
				        else                  nstate <= IDLE;
		Unpack_BP0: if (decomp_Bp_done)   nstate <= Push_BP0;		       
				        else                  nstate <= Unpack_BP0;
    Push_BP0:   if (Dec_Bp_WAd == 31)  nstate <= Unpack_V;
                else                  nstate <= Push_BP0; 
		Unpack_V:   if (decomp_V_done)    nstate <= Push_V;
				        else                  nstate <= Unpack_V;
    Push_V:     if (Dec_V_WAd == 255) nstate <= Unpack_BP1;
                else                  nstate <= Push_V;
		Unpack_BP1: if(decomp_Bp_done)    nstate <= Push_BP1;
				        else                  nstate <= Unpack_BP1;
		Push_BP1:   if(Dec_Bp_WAd == 63)   nstate <= IDLE;
				        else                  nstate <= Push_BP1; 					
		default:                          nstate <= IDLE;
  endcase
end

always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
    decomp_V_enable   <= 1'b0;
    decomp_Bp_enable  <= 1'b0;
    temp_BPchar_in    <= 0;
    Function_done     <= 1'b0;
    Dec_Bp_outready    <= 1'b0;
    Dec_Bp_WAd         <= 0;
    Dec_Bp_WData       <= 0;
    Dec_V_outready    <= 1'b0;
    Dec_V_WAd         <= 0;
    Dec_V_WData       <= 0;
  end else begin
		case({cstate, nstate})
			{IDLE,IDLE}: begin
					Function_done <= 1'b0;	
        end
			{IDLE,Unpack_BP0}: begin		        			    
					decomp_Bp_enable <= 1'b1;
					temp_BPchar_in   <= i_CT[5888-1 -: 2560];
        end		
      {Unpack_BP0,Push_BP0}: begin
          decomp_Bp_enable  <= 1'b0;
          Dec_Bp_outready    <= 1'b1;
          Dec_Bp_WAd         <= 0;                 
          Dec_Bp_WData       <= temp_BP_out[o_BP_BRAM_Length-1 : 0];
          $display("Decompress Bp0: %h", temp_BP_out);
        end
      {Push_BP0,Push_BP0}: begin
          Dec_Bp_outready  <= 1'b1;
          Dec_Bp_WAd       <= Dec_Bp_WAd + 1;                
          Dec_Bp_WData     <= temp_BP_out[(Dec_Bp_WAd+2)*o_BP_BRAM_Length -1 -: o_BP_BRAM_Length];
        end
			{Push_BP0,Unpack_V}: begin
          Dec_Bp_outready    <= 1'b0;	
					decomp_V_enable <= 1'b1;					
        end					
			{Unpack_V,Push_V}: begin	
					decomp_V_enable <= 1'b0;
          Dec_V_outready    <= 1'b1;
          Dec_V_WAd         <= 0;
          Dec_V_WData       <= temp_V_out[o_v_BRAM_Length-1 : 0];
          $display("Decompress V: %h", temp_V_out);
        end
      {Push_V,Push_V}: begin
          Dec_V_outready  <= 1'b1;
          Dec_V_WAd       <= Dec_V_WAd + 1;                 
          Dec_V_WData     <= temp_V_out[(Dec_V_WAd+2)*o_v_BRAM_Length -1 -: o_v_BRAM_Length];
        end
			{Push_V,Unpack_BP1}: begin
          Dec_V_outready    <= 1'b0;
          decomp_Bp_enable  <= 1'b1;  
          temp_BPchar_in    <= i_CT[3328-1 -: 2560];
        end
			{Unpack_BP1,Push_BP1}: begin	
          decomp_Bp_enable  <= 1'b0;
          Dec_Bp_outready    <= 1'b1;
          Dec_Bp_WAd         <= 32;
          Dec_Bp_WData       <= temp_BP_out[o_BP_BRAM_Length-1 : 0];
          $display("Decompress Bp1: %h", temp_BP_out);
        end
      {Push_BP1,Push_BP1}: begin
          Dec_Bp_outready  <= 1'b1;
          Dec_Bp_WAd       <= Dec_Bp_WAd + 1;                 
          Dec_Bp_WData     <= temp_BP_out[(Dec_Bp_WAd-32+2)*o_BP_BRAM_Length -1 -: o_BP_BRAM_Length];
        end
      {Push_BP1,IDLE}: begin
          Function_done       <= 1'b1;
          Dec_Bp_outready      <= 1'b0;
          decomp_V_enable   <= 1'b0;
          decomp_Bp_enable    <= 1'b0;
          temp_BPchar_in      <= 0;
          Dec_Bp_WAd           <= 0;
          Dec_Bp_WData         <= 0;
          Dec_V_outready      <= 1'b0;
          Dec_V_WAd           <= 0;
          Dec_V_WData         <= 0;
        end
    default: ;
  endcase
end

Polyvec_Decompress P0 (
.clk(clk),
.reset_n(rst_n),
.enable(decomp_Bp_enable),
.i_Polyvec_Compressed(temp_BPchar_in),
.Function_Done(decomp_Bp_done),
.oPolyVec(temp_BP_out)
);

Poly_Decompress	P1 (
.clk(clk),
.reset_n(rst_n),
.enable(decomp_V_enable),
.i_Poly_Compressed(i_CT[768-1 : 0]),
.out_ready(decomp_V_done),
.oPoly(temp_V_out)
);

endmodule
