//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2019 01:45:35 PM
// Design Name: 
// Module Name: State_PolyVec_PAcc__Poly_Add__Data_Cal
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


module State_PAcc__Poly_PAcc__Poly_Add__Data_Cal#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter i_Coeffs_Width_a = 16, 
  parameter i_Coeffs_Width_b = 16,
  parameter o_Coeffs_Width = 16
)(	
    input  [i_Coeffs_Width_a-1 : 0] iCoeffs_a,
    input  [i_Coeffs_Width_b-1 : 0] iCoeffs_b,
    output signed [o_Coeffs_Width -1 : 0] oCoeffs
);

assign oCoeffs = $signed(iCoeffs_a) + $signed(iCoeffs_b);

endmodule
