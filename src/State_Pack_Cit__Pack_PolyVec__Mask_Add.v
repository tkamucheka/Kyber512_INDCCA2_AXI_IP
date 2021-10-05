//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 12:23:28 PM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_PolyVec__Mask
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


module State_Pack_Cit__Pack_PolyVec__Mask_Add#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter i_Width = 12,
  parameter o_Width = 24
)(
  input  [i_Width-1 : 0] iPolyCoeffs0,
  input  [i_Width-1 : 0] iPolyCoeffs1,
  input  [i_Width-1 : 0] iPolyCoeffs2,
  input  [i_Width-1 : 0] iPolyCoeffs3,
  output [o_Width-1 : 0] oPolyCoeffs_t0,
  output [o_Width-1 : 0] oPolyCoeffs_t1,
  output [o_Width-1 : 0] oPolyCoeffs_t2,
  output [o_Width-1 : 0] oPolyCoeffs_t3
);

assign oPolyCoeffs_t0 = (({10'h0,iPolyCoeffs0} <<< 10) + KYBER_Q/2);
assign oPolyCoeffs_t1 = (({10'h0,iPolyCoeffs1} <<< 10) + KYBER_Q/2);
assign oPolyCoeffs_t2 = (({10'h0,iPolyCoeffs2} <<< 10) + KYBER_Q/2);
assign oPolyCoeffs_t3 = (({10'h0,iPolyCoeffs3} <<< 10) + KYBER_Q/2);

endmodule

