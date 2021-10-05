`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2019 05:37:55 PM
// Design Name: 
// Module Name: State_Add__Add_3
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


module State_Add__Add_3#(
  parameter i_Coeffs_Width_a = 128, 
  parameter i_Coeffs_Width_b = 32,
  parameter i_Coeffs_Width_c = 96,
  parameter o_Coeffs_Width = 128
)(	
  input  [i_Coeffs_Width_a-1 : 0] iCoeffs_a,
  input  [i_Coeffs_Width_b-1 : 0] iCoeffs_b,
  input  [i_Coeffs_Width_c-1 : 0] iCoeffs_c,
  output [o_Coeffs_Width -1 : 0] oCoeffs
);

// BUG: incorrect ordering on b and c coefficients
// assign oCoeffs[15 -: 16] = $signed(iCoeffs_a[15 -: 16]) + $signed(iCoeffs_b[3 -: 4]) + $signed(iCoeffs_c[11 -: 12]);
// assign oCoeffs[31 -: 16] = $signed(iCoeffs_a[31 -: 16]) + $signed(iCoeffs_b[7 -: 4]) + $signed(iCoeffs_c[23 -: 12]);
// assign oCoeffs[47 -: 16] = $signed(iCoeffs_a[47 -: 16]) + $signed(iCoeffs_b[11 -: 4]) + $signed(iCoeffs_c[35 -: 12]);
// assign oCoeffs[63 -: 16] = $signed(iCoeffs_a[63 -: 16]) + $signed(iCoeffs_b[15 -: 4]) + $signed(iCoeffs_c[47 -: 12]);
// assign oCoeffs[79 -: 16] = $signed(iCoeffs_a[79 -: 16]) + $signed(iCoeffs_b[19 -: 4]) + $signed(iCoeffs_c[59 -: 12]);
// assign oCoeffs[95 -: 16] = $signed(iCoeffs_a[95 -: 16]) + $signed(iCoeffs_b[23 -: 4]) + $signed(iCoeffs_c[71 -: 12]);
// assign oCoeffs[111 -: 16] = $signed(iCoeffs_a[111 -: 16]) + $signed(iCoeffs_b[27 -: 4]) + $signed(iCoeffs_c[83 -: 12]);
// assign oCoeffs[127 -: 16] = $signed(iCoeffs_a[127 -: 16]) + $signed(iCoeffs_b[31 -: 4]) + $signed(iCoeffs_c[95 -: 12]);

assign oCoeffs[15 -: 16] = $signed(iCoeffs_a[15 -: 16]) + $signed(iCoeffs_b[31 -: 4]) + $signed(iCoeffs_c[95 -: 12]);
assign oCoeffs[31 -: 16] = $signed(iCoeffs_a[31 -: 16]) + $signed(iCoeffs_b[27 -: 4]) + $signed(iCoeffs_c[83 -: 12]);
assign oCoeffs[47 -: 16] = $signed(iCoeffs_a[47 -: 16]) + $signed(iCoeffs_b[23 -: 4]) + $signed(iCoeffs_c[71 -: 12]);
assign oCoeffs[63 -: 16] = $signed(iCoeffs_a[63 -: 16]) + $signed(iCoeffs_b[19 -: 4]) + $signed(iCoeffs_c[59 -: 12]);
assign oCoeffs[79 -: 16] = $signed(iCoeffs_a[79 -: 16]) + $signed(iCoeffs_b[15 -: 4]) + $signed(iCoeffs_c[47 -: 12]);
assign oCoeffs[95 -: 16] = $signed(iCoeffs_a[95 -: 16]) + $signed(iCoeffs_b[11 -: 4]) + $signed(iCoeffs_c[35 -: 12]);
assign oCoeffs[111 -: 16] = $signed(iCoeffs_a[111 -: 16]) + $signed(iCoeffs_b[7 -: 4]) + $signed(iCoeffs_c[23 -: 12]);
assign oCoeffs[127 -: 16] = $signed(iCoeffs_a[127 -: 16]) + $signed(iCoeffs_b[3 -: 4]) + $signed(iCoeffs_c[11 -: 12]);

endmodule

