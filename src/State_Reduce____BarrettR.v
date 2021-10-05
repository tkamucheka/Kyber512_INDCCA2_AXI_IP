//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2019 12:48:36 PM
// Design Name: 
// Module Name: State_Reduce____BarrettR
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


module State_Reduce__PolyReduce__BarrettR#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter BarrettR_cons_v = 20159,
  parameter Temp_Coeff_Width0 = 32,
  parameter Temp_Coeff_Width1 = 6,
  parameter Temp_Coeff_Width2 = 32,  
  parameter i_Coeffs_Width = 16,
  parameter o_Coeffs_Width = 12
)(
	input clk,		
	input reset_n,
	input enable,	
  input [i_Coeffs_Width-1 : 0] iCoeffs,
  output reg BarrettR_done,
  output reg [o_Coeffs_Width -1 : 0]  oCoeffs
);

reg signed [Temp_Coeff_Width0-1 : 0] 	temp_Coeff0;
reg signed [Temp_Coeff_Width1-1 : 0] 	temp_Coeff1;
reg signed [Temp_Coeff_Width2-1 : 0] 	temp_Coeff2;

reg [2:0] cstate,nstate;
localparam IDLE		= 3'd0;
localparam Mul_1st = 3'd1;
localparam Shift   = 3'd2;
localparam Mul_2nd = 3'd3;
localparam Sub    	= 3'd4;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else 				 cstate <= nstate;

always @(cstate or enable)
	case(cstate)
		IDLE: 	 	if (enable)	nstate <= Mul_1st;
				  		else 				nstate <= IDLE;
		Mul_1st:  						nstate <= Shift;
		Shift:    						nstate <= Mul_2nd;
		Mul_2nd:  						nstate <= Sub;
		Sub:      						nstate <= IDLE;
		default: 							nstate <= IDLE;
	endcase

always @(posedge clk or negedge reset_n)
	if(!reset_n) begin
		BarrettR_done <= 0;
		oCoeffs 			<= 0;
	end else begin
		case(cstate)
			IDLE: 		BarrettR_done <= 1'b0;
			Mul_1st: 	temp_Coeff0 	<= $signed(iCoeffs) * $signed(BarrettR_cons_v);
			Shift: 		temp_Coeff1 	<= $signed(temp_Coeff0) >>> 26;
			Mul_2nd: 	temp_Coeff2 	<= $signed(temp_Coeff1) * $signed(KYBER_Q);
			Sub: begin
				oCoeffs 			<= $signed(iCoeffs) - $signed(temp_Coeff2);
				BarrettR_done <= 1'b1;
			end
			default: ;
		endcase
	end

endmodule
