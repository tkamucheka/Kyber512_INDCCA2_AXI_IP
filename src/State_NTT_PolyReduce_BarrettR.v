//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 11:05:19 AM
// Design Name: 
// Module Name: State_NTT_PolyReduce_BarrettR
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

module State_NTT_PolyReduce_BarrettR#(
  parameter KYBER_K           = 2,
  parameter KYBER_N           = 256,
  parameter KYBER_Q           = 3329,
  parameter BarrettR_const_v  = 20159,
  parameter Temp_Coeff_Width0 = 32,
  parameter Temp_Coeff_Width1 = 6,
  parameter Temp_Coeff_Width2 = 32,  
  parameter i_Coeffs_Width    = 16,
  parameter o_Coeffs_Width    = 12
)(
	input                               clk,		
	input                               reset_n,
  input       [i_Coeffs_Width -1 : 0] iCoeffs,
  output reg  [o_Coeffs_Width -1 : 0] oCoeffs
);

reg signed [Temp_Coeff_Width0-1 : 0] 	temp_Coeff0;
reg signed [Temp_Coeff_Width1-1 : 0] 	temp_Coeff1;	
reg signed [Temp_Coeff_Width2-1 : 0] 	temp_Coeff2;	

reg [1 : 0] pp_i;
reg signed [15:0] temp_i_Coeff0;
reg signed [15:0] temp_i_Coeff1;
reg signed [15:0] temp_i_Coeff2;
reg signed [15:0] temp_i_Coeff3;

//Mul_1st
always@(posedge clk or negedge reset_n)
  if (!reset_n) begin
    temp_Coeff0 <= 0;
    pp_i        <= 0;
  end else begin
    temp_Coeff0 <= $signed(iCoeffs) * $signed(BarrettR_const_v);
    pp_i        <= pp_i + 1;
    case(pp_i)
      0: temp_i_Coeff0 <= iCoeffs;
      1: temp_i_Coeff1 <= iCoeffs;  
      2: temp_i_Coeff2 <= iCoeffs;
      3: temp_i_Coeff3 <= iCoeffs;     
      default: ;
    endcase
  end

//Shift
always@(posedge clk or negedge reset_n)
  if (!reset_n) temp_Coeff1 <= 0;
  else          temp_Coeff1 <= $signed(temp_Coeff0) >>> 26;

//Mul_2nd
always@(posedge clk or negedge reset_n)
  if (!reset_n) temp_Coeff2 <= 0;
  else          temp_Coeff2 <= $signed(temp_Coeff1) * $signed(KYBER_Q);

//Sub
always@(posedge clk or negedge reset_n)
  if (!reset_n) oCoeffs <= 0;
  else begin
    case(pp_i)
      0: oCoeffs <= $signed(temp_i_Coeff1) - $signed(temp_Coeff2);
      1: oCoeffs <= $signed(temp_i_Coeff2) - $signed(temp_Coeff2);
      2: oCoeffs <= $signed(temp_i_Coeff3) - $signed(temp_Coeff2);
      3: oCoeffs <= $signed(temp_i_Coeff0) - $signed(temp_Coeff2);
      default: ;
    endcase 
  end

endmodule
