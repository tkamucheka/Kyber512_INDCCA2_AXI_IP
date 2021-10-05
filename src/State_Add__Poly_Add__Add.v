//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2019 02:51:44 PM
// Design Name: 
// Module Name: State_Add__Poly_Add__Add
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


module State_Add__Add_2 #(
  parameter i_Coeffs_Width_a = 128, 
  parameter i_Coeffs_Width_b = 32,
  parameter o_Coeffs_Width = 128
)(	
  input  [i_Coeffs_Width_a-1 : 0] iCoeffs_a,
  input  [i_Coeffs_Width_b-1 : 0] iCoeffs_b,
  output [o_Coeffs_Width-1 : 0]   oCoeffs
);

// BUG: b coefficients reversed
// assign oCoeffs[15 -: 16] = $signed(iCoeffs_a[15 -: 16]) + $signed(iCoeffs_b[3 -: 4]);
// assign oCoeffs[31 -: 16] = $signed(iCoeffs_a[31 -: 16]) + $signed(iCoeffs_b[7 -: 4]);
// assign oCoeffs[47 -: 16] = $signed(iCoeffs_a[47 -: 16]) + $signed(iCoeffs_b[11 -: 4]);
// assign oCoeffs[63 -: 16] = $signed(iCoeffs_a[63 -: 16]) + $signed(iCoeffs_b[15 -: 4]);
// assign oCoeffs[79 -: 16] = $signed(iCoeffs_a[79 -: 16]) + $signed(iCoeffs_b[19 -: 4]);
// assign oCoeffs[95 -: 16] = $signed(iCoeffs_a[95 -: 16]) + $signed(iCoeffs_b[23 -: 4]);
// assign oCoeffs[111 -: 16] = $signed(iCoeffs_a[111 -: 16]) + $signed(iCoeffs_b[27 -: 4]);
// assign oCoeffs[127 -: 16] = $signed(iCoeffs_a[127 -: 16]) + $signed(iCoeffs_b[31 -: 4]);

assign oCoeffs[15 -: 16] = $signed(iCoeffs_a[15 -: 16]) + $signed(iCoeffs_b[31 -: 4]);
assign oCoeffs[31 -: 16] = $signed(iCoeffs_a[31 -: 16]) + $signed(iCoeffs_b[27 -: 4]);
assign oCoeffs[47 -: 16] = $signed(iCoeffs_a[47 -: 16]) + $signed(iCoeffs_b[23 -: 4]);
assign oCoeffs[63 -: 16] = $signed(iCoeffs_a[63 -: 16]) + $signed(iCoeffs_b[19 -: 4]);
assign oCoeffs[79 -: 16] = $signed(iCoeffs_a[79 -: 16]) + $signed(iCoeffs_b[15 -: 4]);
assign oCoeffs[95 -: 16] = $signed(iCoeffs_a[95 -: 16]) + $signed(iCoeffs_b[11 -: 4]);
assign oCoeffs[111 -: 16] = $signed(iCoeffs_a[111 -: 16]) + $signed(iCoeffs_b[7 -: 4]);
assign oCoeffs[127 -: 16] = $signed(iCoeffs_a[127 -: 16]) + $signed(iCoeffs_b[3 -: 4]);

endmodule
