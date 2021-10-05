//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_polyvec_ntt
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
// Additional Comments: Reusable for Encryption and Decryption
//                      4 level pipeline in both MontgomeryReduction and BarrettReduction
//////////////////////////////////////////////////////////////////////////////////

module State_ntt#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Cal_Coeffs_Length = 16,
  parameter i_Coeffs_Bp_Length = 12,
  parameter i_Coeffs_Sp_Length = 4,
  parameter o_Coeffs_Length = 12,
  parameter o_BRAM_Length = 96,
  parameter Cal_Poly_Size = Cal_Coeffs_Length * KYBER_N,
  parameter i_Poly_Sp_Size = i_Coeffs_Sp_Length * KYBER_N,  
  parameter i_Poly_bp_Size = i_Coeffs_Bp_Length * KYBER_N,
  parameter o_Poly_Size = o_Coeffs_Length * KYBER_N
)(
	input clk,		
	input rst_n,
	input enable,
	input mux_enc_dec,//enc0,dec1
	input [i_Poly_Sp_Size-1 : 0] Sp_r_RData,
	input [i_Poly_bp_Size-1 : 0] Bp_ct_RData,
	output reg [0 : 0] Sp_r_RAd,
	output reg [0 : 0] Bp_ct_RAd,	
	output reg Function_done,
	output reg NTT_Poly_0_outready,
	output reg [5 : 0] NTT_Poly_0_WAd, 
	output reg [o_BRAM_Length-1 : 0] NTT_Poly_0_WData,
	// DEBUG:
	output reg trigger
); 

reg  P0_ntt_enable;
wire [7 : 0] P0_RAd;
wire [0 : 0] P0_WEN;
wire [7 : 0] P0_WAd;
wire [15 : 0] P0_Wdata;
wire P0_ntt_done;

reg  P1_reduce_enable;
wire [7 : 0] P1_RAd;
wire [0 : 0] P1_WEN;
wire [7 : 0] P1_WAd;
wire [15 : 0] P1_Wdata;
wire P1_reduce_done;

reg  [0 : 0] M0_WEN_Out; 
reg  [7 : 0] M0_WAd_Out;  
reg  [15 : 0] M0_WData_Out; 
reg  [7 : 0] M0_RAd_Out; 

wire  [0 : 0] M0_WEN; 
wire  [7 : 0] M0_WAd;  
wire  [15 : 0] M0_WData; 
wire  [7 : 0] M0_RAd; 
wire  [15 : 0] M0_RData;

reg  [11 : 0] temp_cofe0;
reg  [11 : 0] temp_cofe1;
reg  [11 : 0] temp_cofe2;
reg  [11 : 0] temp_cofe3;
reg  [11 : 0] temp_cofe4;
reg  [11 : 0] temp_cofe5;
reg  [11 : 0] temp_cofe6;

integer a;
reg [1 : 0] state_offset;
reg lock;

// DEBUG
reg debug_en;

reg [2:0] cstate,nstate;
localparam IDLE		        = 3'd0;
localparam Pop_0           = 3'd1;
localparam NTT      		    = 3'd2;
localparam Reduce          = 3'd3;
localparam Push_0          = 3'd4;
localparam Pop_1           = 3'd5;
localparam Push_1          = 3'd6;
localparam MEM_READ = 3'd7;

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) 	cstate <= IDLE;
	else 				cstate <= nstate;
	
always @(cstate or enable or P0_ntt_done or P1_reduce_done or M0_WAd_Out or NTT_Poly_0_WAd or lock or state_offset) 
begin				
	case(cstate)
		IDLE: 	if(enable) 												nstate <= MEM_READ;
				    else 															nstate <= IDLE;
		MEM_READ:  																nstate <= Pop_0;
		Pop_0:  if(M0_WAd_Out == 255 && (!lock)) 	nstate <= NTT;
		        else 															nstate <= Pop_0;
		NTT:    if(P0_ntt_done) 									nstate <= Reduce;
		        else 															nstate <= NTT;
		Reduce: if(P1_reduce_done) 								nstate <= Reduce + state_offset;
		        else 															nstate <= Reduce;	                  
		Push_0: if(NTT_Poly_0_WAd == 31) 					nstate <= Pop_1;
		        else 															nstate <= Push_0;  
		Pop_1:  if(M0_WAd_Out == 255 && (!lock)) 	nstate <= NTT;
		        else 															nstate <= Pop_1;		                  
		Push_1: if(NTT_Poly_0_WAd == 63) 					nstate <= IDLE;
		        else 															nstate <= Push_1;
		default: 																	nstate <= IDLE;
		endcase
end

always @(posedge clk)										
	if(!rst_n) begin
		// Sp_r_RAd      			<= 0;
		// Bp_ct_RAd     			<= 0;
		Function_done 			<= 1'b0;
		NTT_Poly_0_outready <= 1'b0;
		NTT_Poly_0_WAd 			<= 0;
		NTT_Poly_0_WData 		<= 0;        	        
		P0_ntt_enable 			<= 1'b0;	        
		P1_reduce_enable 		<= 1'b0;
		state_offset 				<= 1'b0;
		lock 								<= 1'b0;
		a 									<= 0;
		// DEBUG
		debug_en <= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
				Function_done 			<= 1'b0;	
				NTT_Poly_0_outready <= 1'b0;
				NTT_Poly_0_WAd 			<= 0;
				NTT_Poly_0_WData 		<= 0;
				Sp_r_RAd      			<= 1'hx;
				Bp_ct_RAd     			<= 1'hx;
				trigger <= 0;            
			end
			{IDLE,MEM_READ}:begin
				Sp_r_RAd  	<= 1'd0;
				Bp_ct_RAd 	<= 1'd0;
				trigger <= 1;     
			end
			{MEM_READ,Pop_0}: begin
				M0_WAd_Out 	<= -1;
				lock 				<= 1'b1;
			end
			{Pop_0,Pop_0}: begin
				M0_RAd_Out <= 8'hxx;

				case(mux_enc_dec)
					0: begin //enc
						if(lock) M0_WData_Out <= $signed(Sp_r_RData[3 -: 4]);
						else		 M0_WData_Out <= $signed(Sp_r_RData[(M0_WAd_Out+2)*4-1 -: 4]);
					end
					1: begin //dec
						if(lock) M0_WData_Out <= Bp_ct_RData[3071 -: 12];
						else     M0_WData_Out <= Bp_ct_RData[3071-(M0_WAd_Out+2)*12-1 -: 12];
					end
				endcase	
				M0_WEN_Out 	<= 1'b1;
				M0_WAd_Out 	<= M0_WAd_Out + 1;
				lock 				<= 1'b0;
				$display("%h", M0_WData_Out);
			end
			{Pop_0,NTT}:begin
				state_offset 	<= 1;	        		         
				P0_ntt_enable <= 1'b1;
				M0_WEN_Out 		<= 1'b1;
				$display("NTT (IN)[Sp0]: %h", Sp_r_RData);
				$display("NTT (IN)[Bp0]: %h", Bp_ct_RData);
			end			          				       			
			{NTT,NTT}: begin
				M0_WEN_Out 		<= 1'b0;
				P0_ntt_enable <= 1'b0;
			end
			{NTT,Reduce}:begin
				P1_reduce_enable <= 1'b1;                   
			end
			{Reduce,Reduce}:begin
				P1_reduce_enable <= 1'b0;
			end		             
			{Reduce,Push_0}:begin
				Sp_r_RAd 		<= 1'd1;
				Bp_ct_RAd 	<= 1'd1;
				M0_RAd_Out 	<= 0;
				a 					<= 0;
			end
			{Push_0,Push_0}:begin
				if(a == 0) begin
				end else begin
					case((a-1) & 7) // mod 8 
						0: temp_cofe0 <= M0_RData[11 : 0];
						1: temp_cofe1 <= M0_RData[11 : 0];
						2: temp_cofe2 <= M0_RData[11 : 0];
						3: temp_cofe3 <= M0_RData[11 : 0];
						4: temp_cofe4 <= M0_RData[11 : 0];
						5: temp_cofe5 <= M0_RData[11 : 0];                        
						6: temp_cofe6 <= M0_RData[11 : 0];
						7: begin
							NTT_Poly_0_outready <= 1'b1;   
							NTT_Poly_0_WAd <= (a/8) - 1;
							// BUG: incorrect byte ordering
							// NTT_Poly_0_WData <= {M0_RData[11 : 0], temp_cofe6, temp_cofe5, temp_cofe4, temp_cofe3, temp_cofe2, temp_cofe1, temp_cofe0};
							NTT_Poly_0_WData <= {temp_cofe0, temp_cofe1, temp_cofe2, temp_cofe3, temp_cofe4, temp_cofe5, temp_cofe6, M0_RData[11 : 0]};
							// ntt_debug[3071-(((a/8)-1)*96) -: 96] <= {temp_cofe0, temp_cofe1, temp_cofe2, temp_cofe3, temp_cofe4, temp_cofe5, temp_cofe6, M0_RData[11 : 0]};
							$display("NTT (OUT)[Bp0]: %h", {temp_cofe0, temp_cofe1, temp_cofe2, temp_cofe3, temp_cofe4, temp_cofe5, temp_cofe6, M0_RData[11 : 0]});
						end                            
					endcase        
				end
				a 				 <= a + 1;      
				M0_RAd_Out <= M0_RAd_Out + 1; 
			end				              	
			{Push_0,Pop_1}:begin			        
				M0_WAd_Out <= -1;
				lock 			 <= 1'b1;
				// DEBUG:
				// Function_done <=  1'b1;
			end
			{Pop_1,Pop_1}:begin
				NTT_Poly_0_outready <= 1'b0;
				M0_RAd_Out <= 8'hxx;

				case(mux_enc_dec)
					0: begin //enc
						if(lock) M0_WData_Out <= $signed(Sp_r_RData[3 -: 4]);
						else 		 M0_WData_Out <= $signed(Sp_r_RData[(M0_WAd_Out+2)*4-1 -: 4]);
					end
					1: begin //dec
						if(lock) M0_WData_Out <= Bp_ct_RData[11 -: 12];
						else  	 M0_WData_Out <= Bp_ct_RData[(M0_WAd_Out+2)*12-1 -: 12];
					end
				endcase	
				M0_WEN_Out <= 1'b1; 	                          
				M0_WAd_Out <= M0_WAd_Out + 1;
				lock 			 <= 1'b0;
				$display("%h", M0_WData_Out);
			end
			{Pop_1,NTT}:begin
				M0_WEN_Out <= 1'b1;
				state_offset <= 3;
				P0_ntt_enable <= 1'b1;
				$display("NTT (IN)[Sp1]: %h", Sp_r_RData);
				$display("NTT (IN)[Bp1]: %h", Bp_ct_RData);
			end
			{Reduce,Push_1}:begin
				M0_RAd_Out <= 0;
				a <= 0;
			end
			{Push_1,Push_1}:begin
				if(a == 0) begin
										end
				else begin
					case((a-1) & 7) // mod 8 
						0: temp_cofe0 <= M0_RData[11 : 0];
						1: temp_cofe1 <= M0_RData[11 : 0];
						2: temp_cofe2 <= M0_RData[11 : 0];
						3: temp_cofe3 <= M0_RData[11 : 0];
						4: temp_cofe4 <= M0_RData[11 : 0];
						5: temp_cofe5 <= M0_RData[11 : 0];
						6: temp_cofe6 <= M0_RData[11 : 0];
						7: begin
							NTT_Poly_0_outready <= 1'b1;   
							NTT_Poly_0_WAd <= a/8 - 1 + 32;     
							// BUG: incorrect byte ordering
							// NTT_Poly_0_WData <= {M0_RData[11 : 0], temp_cofe6, temp_cofe5, temp_cofe4, temp_cofe3, temp_cofe2, temp_cofe1, temp_cofe0};
							NTT_Poly_0_WData <= {temp_cofe0, temp_cofe1, temp_cofe2, temp_cofe3, temp_cofe4, temp_cofe5, temp_cofe6, M0_RData[11 : 0]};        
						end                             
					endcase        
				end
				a <= a + 1;      
				M0_RAd_Out <= M0_RAd_Out + 1; 
			end					       				                        	       	
			{Push_1,IDLE}: begin    			       			        
				Function_done <=  1'b1;
				Sp_r_RAd      <= 0;
				Bp_ct_RAd     <= 0;            	                    
				a <= 0;
				state_offset <= 0;
				trigger <= 0;
			end	 				        
			default: ;
		endcase
	end
	
// Poly_ntt P0(
// .clk(clk),		
// .reset_n(rst_n),
// .enable(P0_ntt_enable),
// .Coef_RData(M0_RData),
// .Coef_RAd(P0_RAd),
// .Coef_WEN(P0_WEN),
// .Coef_WAd(P0_WAd),
// .Coef_WData(P0_Wdata),
// .Poly_NTT_done(P0_ntt_done)
// );

NTT P0 (
	.clk(clk),
	.reset_n(rst_n),
	.enable(P0_ntt_enable),
	.Coef_RAd(P0_RAd),
	.Coef_RData(M0_RData),
	.Coef_WEN(P0_WEN),
	.Coef_WAd(P0_WAd),
	.Coef_WData(P0_Wdata),
	.Poly_NTT_done(P0_ntt_done)
);

State_NTT_PolyReduce P1(
.clk(clk),		
.reset_n(rst_n),
.enable(P1_reduce_enable),
.Coef_RData(M0_RData),
.Coef_RAd(P1_RAd),
.Coef_WEN(P1_WEN),
.Coef_WAd(P1_WAd),
.Coef_WData(P1_Wdata),
.Poly_Reduce_done(P1_reduce_done)
);
 
NTT_Poly_BRAM M0(
.clka(clk),
.wea(M0_WEN), 
.addra(M0_WAd),  // IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.dina(M0_WData),   //IN STD_LOGIC_VECTOR(15 DOWNTO 0);
.clkb(clk),   // IN STD_LOGIC;
.addrb(M0_RAd),  // IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.doutb(M0_RData)  // OUT STD_LOGIC_VECTOR(15 DOWNTO 0)    
); 
 
State_ntt_BRAM_MUX MUX0(
.cstate(cstate),
.P0_WEN(P0_WEN),
.P0_WAd(P0_WAd),
.P0_Wdata(P0_Wdata),
.P0_RAd(P0_RAd),
.P1_WEN(P1_WEN),
.P1_WAd(P1_WAd),
.P1_Wdata(P1_Wdata),
.P1_RAd(P1_RAd),
.M0_WEN_Out(M0_WEN_Out), 
.M0_WAd_Out(M0_WAd_Out),  
.M0_WData_Out(M0_WData_Out), 
.M0_RAd_Out(M0_RAd_Out),
.M0_WEN(M0_WEN),
.M0_WAd(M0_WAd),
.M0_WData(M0_WData),
.M0_RAd(M0_RAd)
);
  									
endmodule
