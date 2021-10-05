//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2019 04:29:59 PM
// Design Name: 
// Module Name: State_PolyVec_PAcc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module State_PAcc__Poly_PAcc#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Temp_Poly_Width = 16,
  parameter i_a_Coeffs_Width = 16,
  parameter i_b_Coeffs_Width = 12,
  parameter o_MP_Coeffs_Width = 16,
  parameter Temp_Poly_Size = Temp_Poly_Width * KYBER_N,
  parameter i_a_Poly_Size = i_a_Coeffs_Width * KYBER_N,
  parameter i_b_Poly_Size = i_b_Coeffs_Width * KYBER_N,
  parameter o_MP_Poly_Size = o_MP_Coeffs_Width * KYBER_N
)(
	input clk,		
	input rst_n,
	input enable,	
//    input [i_a_Poly_Size*2-1 : 0] i_a_PolyVec,
    input [i_a_Poly_Size-1 : 0] i_a_PolyVec_0,
    input [i_a_Poly_Size-1 : 0] i_a_PolyVec_1, 
//    input [i_b_Poly_Size*2-1 : 0] i_b_PolyVec,
    input [i_b_Poly_Size-1 : 0] i_b_PolyVec_0,
    input [i_b_Poly_Size-1 : 0] i_b_PolyVec_1,
    output reg State_PolyVec_PAcc_done,
    output [o_MP_Poly_Size -1 : 0]  o_mp_Poly,
		// DEBUG
		output reg [4095:0] debug1,
		output reg [4095:0] debug2
);

reg  P0_Poly_Basemul_enable;	
wire P0_Poly_Basemul_done;
wire [Temp_Poly_Size-1 : 0] P0_Poly_Basemul_Poly_oPoly_r;
reg  P1_Poly_Basemul_enable;	
wire P1_Poly_Basemul_done;
wire [Temp_Poly_Size-1 : 0] P1_Poly_Basemul_Poly_oPoly_r;
reg P2_Poly_Add_enable;
wire P2_Poly_Add_done;
wire [Temp_Poly_Size-1 : 0] P2_Poly_Add_oPoly;
reg P3_Poly_Reduce_enable;
wire P3_Poly_Reduce_done;


reg [2:0] cstate,nstate;
localparam IDLE		         = 3'd0;
localparam Poly_Basemul       = 3'd3;
localparam Poly_Add           = 3'd4;
localparam Poly_Reduce        = 3'd5;

always @(posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or P0_Poly_Basemul_done or 
P1_Poly_Basemul_done or P2_Poly_Add_done or P3_Poly_Reduce_done) 
begin				
	case(cstate)
		IDLE: 	      if(enable) nstate <= Poly_Basemul;
				       else nstate <= IDLE;
		Poly_Basemul: if(P0_Poly_Basemul_done && P1_Poly_Basemul_done) nstate <= Poly_Add;
				       else nstate <= Poly_Basemul;
		Poly_Add:     if(P2_Poly_Add_done) nstate <= Poly_Reduce;
				       else nstate <= Poly_Add;
		Poly_Reduce:  if(P3_Poly_Reduce_done) nstate <= IDLE;
				       else nstate <= Poly_Reduce;						       				       				       		   				
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge rst_n)										
	if(!rst_n) begin
			State_PolyVec_PAcc_done <= 1'b0;
			P0_Poly_Basemul_enable <= 1'b0;
			P1_Poly_Basemul_enable <= 1'b0;
			P2_Poly_Add_enable <= 1'b0;
			P3_Poly_Reduce_enable <= 1'b0;			
	end	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					State_PolyVec_PAcc_done <= 1'b0;	
				end
			{IDLE,Poly_Basemul}: begin			        
					P0_Poly_Basemul_enable <= 1'b1;
					P1_Poly_Basemul_enable <= 1'b1;	
				end	         				         
			{Poly_Basemul,Poly_Basemul}: begin
					P0_Poly_Basemul_enable <= 1'b0;
					P1_Poly_Basemul_enable <= 1'b0;					       
				end                        
			{Poly_Basemul,Poly_Add}: begin
					P2_Poly_Add_enable <= 1'b1;		  
				end  
			{Poly_Add,Poly_Add}: begin
					P2_Poly_Add_enable <= 1'b0;				       
				end
			{Poly_Add,Poly_Reduce}: begin
					P3_Poly_Reduce_enable <= 1'b1;				       
				end  
			{Poly_Reduce,Poly_Reduce}: begin
					P3_Poly_Reduce_enable <= 1'b0;				       
				end			                          
			{Poly_Reduce,IDLE}: begin
					State_PolyVec_PAcc_done <= 1'b1;
					// DEBUG:
					// debug1 <= P0_Poly_Basemul_Poly_oPoly_r;
					// debug2 <= P1_Poly_Basemul_Poly_oPoly_r;  
				end                			                 			                 	
			default: ;
		endcase
	end

State_PAcc__Poly_PAcc__Poly_Basemul P0(
.clk(clk),		
.reset_n(rst_n),
.enable(P0_Poly_Basemul_enable),	
.iPoly_a(i_a_PolyVec_0),
.iPoly_b(i_b_PolyVec_0), 
// .func(0),
.Poly_Basemul_done(P0_Poly_Basemul_done),
.oPoly_r(P0_Poly_Basemul_Poly_oPoly_r)
);
    
State_PAcc__Poly_PAcc__Poly_Basemul P1(
.clk(clk),		
.reset_n(rst_n),
.enable(P1_Poly_Basemul_enable),	
.iPoly_a(i_a_PolyVec_1),
.iPoly_b(i_b_PolyVec_1), 
// .func(1),
.Poly_Basemul_done(P1_Poly_Basemul_done),
.oPoly_r(P1_Poly_Basemul_Poly_oPoly_r)
);

State_PAcc__Poly_PAcc__Poly_Add P2(
.clk(clk),		
.reset_n(rst_n),
.enable(P2_Poly_Add_enable),	
.iPoly_a(P0_Poly_Basemul_Poly_oPoly_r),
.iPoly_b(P1_Poly_Basemul_Poly_oPoly_r),
.Poly_Add_done(P2_Poly_Add_done),
.oPoly(P2_Poly_Add_oPoly)
);

State_PAcc__Poly_PAcc__Poly_Reduce P3(
.clk(clk),		
.reset_n(rst_n),
.enable(P3_Poly_Reduce_enable),	
.iPoly(P2_Poly_Add_oPoly),
.Poly_Reduce_done(P3_Poly_Reduce_done),
.oPoly(o_mp_Poly)
);
    
endmodule
