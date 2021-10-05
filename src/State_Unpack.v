//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Unpack
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
// Additional Comments: Reusable for Encryption and Decryption
//////////////////////////////////////////////////////////////////////////////////

 module State_Unpack#(
 parameter KYBER_K = 2,
 parameter KYBER_N = 256,
 parameter Byte_bits = 8,
 parameter Seed_Bytes = 32,
 parameter KYBER_POLYBYTES = 384,
 parameter Length = 128,
 parameter o_BRAM_Length = 128,
 parameter PK_Size = Byte_bits * (KYBER_POLYBYTES * KYBER_K + Seed_Bytes),
 parameter SK_Size = Byte_bits * KYBER_POLYBYTES * KYBER_K,
 parameter PolyBytes_Size = Byte_bits * KYBER_POLYBYTES, 
 parameter Seed_Size = Byte_bits * Seed_Bytes
 )(
	input clk,
	input rst_n,
	input enable,
	input mux_enc_dec,//enc0,dec1
	input  [PK_Size-1 : 0] ipackedpk,
	input  [SK_Size-1 : 0] ipackedsk,
	output reg Function_Done,	
	output reg EncPk_DecSk_PolyVec_outready,
	output reg [5 : 0] EncPk_DecSk_PolyVec_WAd, 
	output reg [Length-1 : 0] EncPk_DecSk_PolyVec_WData
 	// DEBUG:
	// output reg [Length-1 : 0] unpackedpk_debug
);
//assign oSeed_Char = ipackedpk[PK_Size-1 -: Seed_Size];

reg 					P0_enable;
wire 					P0_done;
wire 					P0_out_ready;
wire [127:0] 	P0_o_poly;

reg [1:0] cstate, nstate; // current_state, next_state

localparam IDLE		       	= 2'd0;
localparam LOAD 					= 2'd1;
localparam SendEnc        = 2'd2;
localparam SendDec        = 2'd3;

localparam 	o = (Seed_Size)+84-1, p = (Seed_Size)+96-1,
						m = (Seed_Size)+80-1, n = (Seed_Size)+88-1,
						k = (Seed_Size)+60-1, l = (Seed_Size)+72-1,
						i = (Seed_Size)+56-1, j = (Seed_Size)+64-1,
						g = (Seed_Size)+36-1, h = (Seed_Size)+48-1, 
						e = (Seed_Size)+32-1, f = (Seed_Size)+40-1,
						c = (Seed_Size)+12-1, d = (Seed_Size)+24-1,
						a = (Seed_Size)+8-1,  b = (Seed_Size)+16-1;

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) 	cstate <= IDLE;
	else 				cstate <= nstate;

	
always @(cstate or enable  or mux_enc_dec or EncPk_DecSk_PolyVec_WAd 
					or P0_out_ready)
begin				
	case(cstate)
		IDLE:			if(enable && mux_enc_dec) 				nstate <= LOAD;
							else if(enable) 									nstate <= SendEnc;
							else 															nstate <= IDLE;
		LOAD: 		if (P0_out_ready && mux_enc_dec)  nstate <= SendDec;
							else 															nstate <= LOAD; 
		SendDec:  if(EncPk_DecSk_PolyVec_WAd == 63) nstate <= IDLE;
	            else 															nstate <= SendDec;
		SendEnc:  if(EncPk_DecSk_PolyVec_WAd == 63) nstate <= IDLE;
	            else 															nstate <= SendEnc;
		default: 																		nstate <= IDLE;
		endcase
end


// always @(posedge clk or negedge rst_n)										
// 	if(!rst_n) begin
// 			Function_Done 								<= 1'b0;	      
// 			EncPk_DecSk_PolyVec_outready	<= 1'b0;
// 			EncPk_DecSk_PolyVec_WAd      	<= 0;
// 			EncPk_DecSk_PolyVec_WData    	<= 0;
// 			// DEBUG:
// 			// unpackedpk_debug 							<= 0;
// 		end
// 	else begin
// always @(cstate, nstate, EncPk_DecSk_PolyVec_WAd, ipackedpk) begin
always @(posedge clk)
	if (!rst_n) begin
		Function_Done 								<= 1'b0;	      
		EncPk_DecSk_PolyVec_outready	<= 1'b0;
		EncPk_DecSk_PolyVec_WAd      	<= 0;
		EncPk_DecSk_PolyVec_WData    	<= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: Function_Done 				<= 1'b0;
			{IDLE,SendEnc}: begin
					EncPk_DecSk_PolyVec_outready	<= 1'b1;
					EncPk_DecSk_PolyVec_WAd      	<= 0;
					// BUG:
					//  EncPk_DecSk_PolyVec_WData 		<= {
					//  	4'h0,ipackedpk [12*8-1 -: 12],
					//  	4'h0,ipackedpk [12*7-1 -: 12],
					//  	4'h0,ipackedpk [12*6-1 -: 12],
					//  	4'h0,ipackedpk [12*5-1 -: 12],
					//  	4'h0,ipackedpk [12*4-1 -: 12],
					//  	4'h0,ipackedpk [12*3-1 -: 12], 
					//  	4'h0,ipackedpk [12*2-1 -: 12],
					//  	4'h0,ipackedpk [12-1 -: 12]};
					
					EncPk_DecSk_PolyVec_WData			<= {
						4'h0, ipackedpk [o -: 4], ipackedpk [p -: 8],
						4'h0, ipackedpk [m -: 8], ipackedpk [n -: 4],
						4'h0, ipackedpk [k -: 4], ipackedpk [l -: 8],
						4'h0, ipackedpk [i -: 8], ipackedpk [j -: 4],
						4'h0, ipackedpk [g -: 4], ipackedpk [h -: 8],
						4'h0, ipackedpk [e -: 8], ipackedpk [f -: 4],
						4'h0, ipackedpk [c -: 4], ipackedpk [d -: 8],
						4'h0, ipackedpk [a -: 8], ipackedpk [b -: 4]
					};
				end
			{SendEnc,SendEnc}: begin
					EncPk_DecSk_PolyVec_outready	<= 1'b1;
					EncPk_DecSk_PolyVec_WAd      	<= EncPk_DecSk_PolyVec_WAd + 1;
					// BUG:
					//  EncPk_DecSk_PolyVec_WData 		<= {
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+8)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+7)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+6)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+5)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+4)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+3)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+2)*12-1 -: 12],
					//  	4'h0,ipackedpk [((EncPk_DecSk_PolyVec_WAd+1)*8+1)*12-1 -: 12]};

					EncPk_DecSk_PolyVec_WData			<= {
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+o -: 4], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+p -: 8],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+m -: 8], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+n -: 4],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+k -: 4], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+l -: 8],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+i -: 8], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+j -: 4],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+g -: 4], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+h -: 8],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+e -: 8], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+f -: 4],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+c -: 4], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+d -: 8],
						4'h0, ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+a -: 8], ipackedpk[((EncPk_DecSk_PolyVec_WAd+1)*96)+b -: 4]
					};
					end
			  {SendEnc,IDLE}: begin
						Function_Done 								<= 1'b1;	      
						EncPk_DecSk_PolyVec_outready	<= 1'b0;
						EncPk_DecSk_PolyVec_WAd       <= 0;
						EncPk_DecSk_PolyVec_WData  	 	<= 0;
						// DEBUG:
						// unpackedpk_debug 							<= EncPk_DecSk_PolyVec_WData;
					end	
			 {IDLE,LOAD}: begin
						// EncPk_DecSk_PolyVec_WData 		<= {
						// 	4'h0,ipackedsk [12*8-1 -: 12],
						// 	4'h0,ipackedsk [12*7-1 -: 12],
						// 	4'h0,ipackedsk [12*6-1 -: 12],
						// 	4'h0,ipackedsk [12*5-1 -: 12],
						// 	4'h0,ipackedsk [12*4-1 -: 12],
						// 	4'h0,ipackedsk [12*3-1 -: 12],
						// 	4'h0,ipackedsk [12*2-1 -: 12],
						// 	4'h0,ipackedsk [12-1 -: 12]};
						P0_enable <= 1'b1;
					end
			 {LOAD,LOAD}: begin
				 P0_enable <= 1'b0;
			 end
			 {LOAD,SendDec}: begin
					EncPk_DecSk_PolyVec_outready  <= 1'b1;
					EncPk_DecSk_PolyVec_WAd      	<= 0;
					EncPk_DecSk_PolyVec_WData 		<= P0_o_poly;
			 end
			 {SendDec,SendDec}: begin
						EncPk_DecSk_PolyVec_outready  <= 1'b1;
						EncPk_DecSk_PolyVec_WAd      	<= EncPk_DecSk_PolyVec_WAd + 1;
						// EncPk_DecSk_PolyVec_WData 		<= {
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+8)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+7)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+6)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+5)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+4)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+3)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+2)*12-1 -: 12],
						// 	4'h0,ipackedsk [((EncPk_DecSk_PolyVec_WAd+1)*8+1)*12-1 -: 12]};
						EncPk_DecSk_PolyVec_WData <= P0_o_poly;
					end
			  {SendDec,IDLE}: begin
						Function_Done <= 1'b1;	      
						EncPk_DecSk_PolyVec_outready  <= 1'b0;
						EncPk_DecSk_PolyVec_WAd      	<= 0;
						EncPk_DecSk_PolyVec_WData    	<= 0;
					end			  	  				  
			default: ;
		endcase
	end
    

State_Unpack__poly_frombytes P0 (
	.clk(clk),
	.resetn(rst_n),
	.enable(P0_enable),
	.i_poly(ipackedsk),
	.Function_Done(P0_done),
	.out_ready(P0_out_ready),
	.o_poly(P0_o_poly)
);

endmodule

