//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2019 11:07:32 AM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_Poly__Mask_Add
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


module State_Pack_Cit__Pack_Poly__Mask_Add#(
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
  input  [i_Width-1 : 0] iPolyCoeffs4,
  input  [i_Width-1 : 0] iPolyCoeffs5,
  input  [i_Width-1 : 0] iPolyCoeffs6,
  input  [i_Width-1 : 0] iPolyCoeffs7,
  output [o_Width-1 : 0] oPolyCoeffs_t0,
  output [o_Width-1 : 0] oPolyCoeffs_t1,
  output [o_Width-1 : 0] oPolyCoeffs_t2,
  output [o_Width-1 : 0] oPolyCoeffs_t3,
  output [o_Width-1 : 0] oPolyCoeffs_t4,
  output [o_Width-1 : 0] oPolyCoeffs_t5,
  output [o_Width-1 : 0] oPolyCoeffs_t6,
  output [o_Width-1 : 0] oPolyCoeffs_t7
);

assign oPolyCoeffs_t0 = (({10'h0,iPolyCoeffs0} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t1 = (({10'h0,iPolyCoeffs1} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t2 = (({10'h0,iPolyCoeffs2} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t3 = (({10'h0,iPolyCoeffs3} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t4 = (({10'h0,iPolyCoeffs4} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t5 = (({10'h0,iPolyCoeffs5} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t6 = (({10'h0,iPolyCoeffs6} <<< 3) + KYBER_Q/2);
assign oPolyCoeffs_t7 = (({10'h0,iPolyCoeffs7} <<< 3) + KYBER_Q/2);

endmodule
