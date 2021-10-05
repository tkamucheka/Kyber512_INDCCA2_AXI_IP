//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2019 07:06:58 PM
// Design Name: 
// Module Name: State_Poly_Sub___Data_Cal
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


module State_Poly_Sub___Data_Cal#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter i_Coeffs_Width_a = 96, 
  parameter i_Coeffs_Width_b = 128,
  parameter o_Coeffs_Width = 128
)(	
    input  [i_Coeffs_Width_a-1 : 0] iCoeffs_a,
    input  [i_Coeffs_Width_b-1 : 0] iCoeffs_b,
    output signed [o_Coeffs_Width -1 : 0] oCoeffs
);

assign oCoeffs[15 -: 16] = $signed({4'h0,iCoeffs_a[11 -: 12]} - iCoeffs_b[15 -: 16]);
assign oCoeffs[31 -: 16] = $signed({4'h0,iCoeffs_a[23 -: 12]} - iCoeffs_b[31 -: 16]);
assign oCoeffs[47 -: 16] = $signed({4'h0,iCoeffs_a[35 -: 12]} - iCoeffs_b[47 -: 16]);
assign oCoeffs[63 -: 16] = $signed({4'h0,iCoeffs_a[47 -: 12]} - iCoeffs_b[63 -: 16]);
assign oCoeffs[79 -: 16] = $signed({4'h0,iCoeffs_a[59 -: 12]} - iCoeffs_b[79 -: 16]);
assign oCoeffs[95 -: 16] = $signed({4'h0,iCoeffs_a[71 -: 12]} - iCoeffs_b[95 -: 16]);
assign oCoeffs[111 -: 16] = $signed({4'h0,iCoeffs_a[83 -: 12]} - iCoeffs_b[111 -: 16]);
assign oCoeffs[127 -: 16] = $signed({4'h0,iCoeffs_a[95 -: 12]} - iCoeffs_b[127 -: 16]);

endmodule
