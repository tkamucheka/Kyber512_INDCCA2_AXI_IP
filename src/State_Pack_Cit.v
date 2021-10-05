//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Pack_Cit
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module State_Pack_Cit#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Ciphertext0_Bytes = 320,
  parameter Ciphertext1_Bytes = 96,
  parameter data_Width = 12,
  parameter Byte_bits = 8,
  parameter o_Ciphertext0_Size = Byte_bits * Ciphertext0_Bytes,
  parameter o_Ciphertext1_Size = Byte_bits * Ciphertext1_Bytes,
  parameter i_Poly_Size = data_Width * KYBER_N
)(
	input 																	clk,		
	input 																	rst_n,
	input 																	enable,	
	input 		 [data_Width*4-1 : 0]					Reduce_EncBp_RData,
	input 		 [data_Width*8-1 : 0]				Reduce_EncV_RData,
	output reg [6 : 0] 											Reduce_EncBp_RAd,   
	output reg [4 : 0] 											Reduce_EncV_RAd,  
	output reg 															Function_done,
	output reg [o_Ciphertext0_Size -1 : 0]  o_Ciphertext0_0,
	output reg [o_Ciphertext0_Size -1 : 0]  o_Ciphertext0_1,
	output reg [o_Ciphertext1_Size -1 : 0]  o_Ciphertext1,
	// DEBUG:
	output reg interrupt
);

reg  P0_enable;
reg  P0_clear;	
wire P0_done;
wire [40-1 : 0] P0_oCiphertext_Group;

reg  P1_enable;	
wire P1_done;
wire [24-1 : 0] P1_oCiphertext_Group;
reg  [6:0] i;
reg get;

reg [3:0] cstate,nstate;
localparam IDLE		          	 = 4'd0;
localparam Pop_0               = 4'd1;
localparam Pack_PolyVecBp0     = 4'd2;
localparam Store_Ciphertext0_0 = 4'd3;
localparam Pop_1               = 4'd4;
localparam Pack_PolyVecBp1     = 4'd5;
localparam Store_Ciphertext0_1 = 4'd6;
localparam Pop_V               = 4'd7;
localparam Pack_PolyV	      	 = 4'd8;
localparam Store_Ciphertext1   = 4'd9;

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) cstate <= IDLE;
	else 			 cstate <= nstate;
	
always @(cstate or enable or P0_done or P1_done or i or get) 
begin				
	case(cstate)
		IDLE: 	          		if(enable) 				nstate <= Pop_0;
				              		else 			 				nstate <= IDLE;
		Pop_0:            		if(get == 1) 			nstate <= Pack_PolyVecBp0;
		                			else 							nstate <= Pop_0;		   
		Pack_PolyVecBp0:     	if(i == 64) 			nstate <= Pop_1;
		                      else if(P0_done) 	nstate <= Store_Ciphertext0_0;
				               		else 							nstate <= Pack_PolyVecBp0;
		Store_Ciphertext0_0: 	if(get == 1) 			nstate <= Pack_PolyVecBp0;
		                      else 							nstate <= Store_Ciphertext0_0;
		Pop_1:               	if(get == 1) 			nstate <= Pack_PolyVecBp1;
		                      else 							nstate <= Pop_1;
		Pack_PolyVecBp1:     	if(i == 64) 			nstate <= Pop_V;
		                      else if(P0_done) 	nstate <= Store_Ciphertext0_1;
				               		else 							nstate <= Pack_PolyVecBp1;
		Store_Ciphertext0_1: 	if(get == 1) 			nstate <= Pack_PolyVecBp1;
													else 							nstate <= Store_Ciphertext0_1;
		Pop_V:               	if(get == 1) 			nstate <= Pack_PolyV;
													else 							nstate <= Pop_V;
		Pack_PolyV:          	if(i == 32) 			nstate <= IDLE;
		                      else if(P1_done) 	nstate <= Store_Ciphertext1;
				               		else 							nstate <= Pack_PolyV;
		Store_Ciphertext1: 	 	if(get == 1) 			nstate <= Pack_PolyV;
													else 							nstate <= Store_Ciphertext1;
		default: 																nstate <= IDLE;
	endcase
end

always @(posedge clk/* or negedge rst_n*/)										
	if(!rst_n) begin
		Function_done <= 1'b0;
		o_Ciphertext0_0 <= 0;
		o_Ciphertext0_1 <= 0;
		o_Ciphertext1 <= 0;
		P0_enable <= 1'b0;
		P0_clear <= 1'b0;
		P1_enable <= 1'b0;					
		i <= 0;
		get <= 0;
		// Reduce_EncBp_RAd <= 0;
		// Reduce_EncV_RAd <= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Function_done <=  1'b0;
					Reduce_EncBp_RAd <= 6'hxx;
					Reduce_EncV_RAd <= 4'hx;
				end
			{IDLE,Pop_0}: begin			        
					// Reduce_EncBp_RAd <= 0;
					Reduce_EncBp_RAd <= 63;
					get <= 0;                 		    
				end			
			{Pop_0,Pop_0}: begin			        
					get <= 1;                 		    
				end	
			{Pop_0,Pack_PolyVecBp0}: begin			        
					P0_enable <= 1'b1;
					P0_clear  <= 1'b0;
					get 			<= 0;                  		    
				end
			{Pack_PolyVecBp0,Pack_PolyVecBp0}: begin
					P0_enable <= 1'b0;					
				end
			{Pack_PolyVecBp0,Store_Ciphertext0_0}: begin
					// BUG: reversed construction
					// o_Ciphertext0_0[i*40 + 39 -: 40] <= P0_oCiphertext_Group;
					o_Ciphertext0_0[2559-(i*40) -: 40] <= P0_oCiphertext_Group;
					i <= i + 1;		
					// Reduce_EncBp_RAd <= Reduce_EncBp_RAd + 1;
					Reduce_EncBp_RAd <= Reduce_EncBp_RAd - 1;
					get <= 0;		
				end
			{Store_Ciphertext0_0,Store_Ciphertext0_0}: begin			
					get <= 1;			
				end	
			{Store_Ciphertext0_0,Pack_PolyVecBp0}: begin			
					P0_enable <= 1'b1;			
					get <= 0;
				end     					
			{Pack_PolyVecBp0,Pop_1}: begin
					P0_clear <= 1'b1;
					P0_enable <= 1'b0;
					// Reduce_EncBp_RAd <= 64;
					Reduce_EncBp_RAd <= 127;
					i <= 0;
					get <= 0;           			
				end
			{Pop_1,Pop_1}: begin
					get <= 1;		
				end
			{Pop_1,Pack_PolyVecBp1}: begin
					P0_clear <= 1'b0;
					P0_enable <= 1'b1;
					get <= 0;			
				end
			{Pack_PolyVecBp1,Pack_PolyVecBp1}: begin
					P0_enable <= 1'b0;						
				end
			{Pack_PolyVecBp1,Store_Ciphertext0_1}: begin
					// BUG: reversed construction
					// o_Ciphertext0_1[i*40 + 39 -: 40] <= P0_oCiphertext_Group;
					o_Ciphertext0_1[2559-(i*40) -: 40] <= P0_oCiphertext_Group;
					// Reduce_EncBp_RAd <= Reduce_EncBp_RAd + 1;
					Reduce_EncBp_RAd <= Reduce_EncBp_RAd - 1;
					i <= i + 1;	
					get <= 0;			
				end
			{Store_Ciphertext0_1,Store_Ciphertext0_1}: begin
					get <= 1;			
				end
			{Store_Ciphertext0_1,Pack_PolyVecBp1}: begin
					P0_enable <= 1'b1;
					get <= 0;			
				end	         				 					           					
			{Pack_PolyVecBp1,Pop_V}: begin
					P0_clear <= 1'b1;
					P0_enable <= 1'b0;
					// Reduce_EncV_RAd <= 0;
					Reduce_EncV_RAd <= 63;    
					i <= 0;  
					get <= 0;                    			
				end
			{Pop_V,Pop_V}: begin
					get <= 1; 			
				end
			{Pop_V,Pack_PolyV}: begin
					P1_enable <= 1'b1;
					get <= 0;			
				end
			{Pack_PolyV,Pack_PolyV}: begin
					P1_enable <= 1'b0;		
				end
			{Pack_PolyV,Store_Ciphertext1}: begin
					// BUG: reversed construction
					// o_Ciphertext1[i*24 + 23 -: 24] <= P1_oCiphertext_Group;
					o_Ciphertext1[767-(i*24) -: 24] <= P1_oCiphertext_Group;
					i <= i + 1;		
					// Reduce_EncV_RAd <= Reduce_EncV_RAd + 1;
					Reduce_EncV_RAd <= Reduce_EncV_RAd - 1;
					get <= 0;                            
				end
			{Store_Ciphertext1,Store_Ciphertext1}: begin
					get <= 1;				
				end
			{Store_Ciphertext1,Pack_PolyV}: begin
					P1_enable <= 1'b1;
					get <= 0;				
				end			           					
			{Pack_PolyV,IDLE}: begin
					Function_done 	 <= 1'b1;
					i 							 <= 0;
					P0_enable 			 <= 1'b0;
					P0_clear  			 <= 1'b0;
					P1_enable 			 <= 1'b0;
					get 						 <= 0;
					Reduce_EncBp_RAd <= 0; 
					Reduce_EncV_RAd  <= 0;
					get 						 <= 0;		        	    			
				end				                            
			default: ;
			endcase
		end

State_Pack_Cit__Pack_PolyVec_Group P0(
.clk(clk),		
.reset_n(rst_n),
.enable(P0_enable),
.clear(P0_clear),	
.iCoeffs(Reduce_EncBp_RData),
.Pack_Group_done(P0_done),
.oCiphertext_Group(P0_oCiphertext_Group)
);
	
State_Pack_Cit__Pack_Poly_Group P1(
.clk(clk),		
.reset_n(rst_n),
.enable(P1_enable),	
.iCoeffs(Reduce_EncV_RData),
.Pack_Group_done(P1_done),
.oCiphertext_Group(P1_oCiphertext_Group)
);							
		
endmodule
