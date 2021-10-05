`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2019 02:50:13 PM
// Design Name: 
// Module Name: State_PolyVec_PAcc__Poly_Basemul__Basemul__MontgomeryR
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


module State_PAcc__Poly_PAcc__Poly_Basemul__Basemul__MontgomeryR#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter MontgomeryR_QINV = 62209,
  parameter Temp_Coeff_Width0 = 32,
  parameter Temp_Coeff_Width1 = 32,
  parameter Temp_Coeff_Width2 = 24,  
  parameter i_Coeffs_Width = 16,
  parameter o_Coeffs_Width = 16
)(
	input clk,		
	input reset_n,
	input enable,	
	input  [i_Coeffs_Width-1 : 0] iCoeffs_a,
	input  [i_Coeffs_Width-1 : 0] iCoeffs_b,
	output reg MontgomeryR_done,
	output reg [o_Coeffs_Width -1 : 0]  oCoeffs
);

reg signed [31:0] temp_Coeff0;
reg signed [15:0] temp_Coeff1;
reg signed [31:0] temp_Coeff2;

reg [2:0] cstate,nstate;
localparam IDLE		        = 3'd0;
localparam Coeff_Mul     	= 3'd1;
localparam Mul_1st     		= 3'd2;
localparam Mul_2nd        = 3'd3;
localparam Sub_Stop    		= 3'd4;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable) 
begin				
	case(cstate)
		IDLE: 	 if(enable) nstate <= Coeff_Mul;
				  else nstate <= IDLE;
		Coeff_Mul:nstate <= Mul_1st;		  
		Mul_1st:  nstate <= Mul_2nd;
		Mul_2nd:  nstate <= Sub_Stop;
		Sub_Stop: nstate <= IDLE;					
		default:  nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
		MontgomeryR_done 	<= 0;
		oCoeffs 					<= 0;
	end else begin
		case(cstate)
			IDLE: 
					MontgomeryR_done <= 1'b0;	
			Coeff_Mul:
					temp_Coeff0 <= $signed(iCoeffs_a) * $signed(iCoeffs_b);
			Mul_1st:
			  	temp_Coeff1 <= temp_Coeff0 * $signed(MontgomeryR_QINV);
			Mul_2nd:
					temp_Coeff2 <= temp_Coeff1 * $signed(KYBER_Q);
			Sub_Stop: begin
					MontgomeryR_done <= 1'b1; 
					oCoeffs <= (temp_Coeff0 - temp_Coeff2) >>> 16;
				end
			default: ;
		endcase
	end

endmodule	 
