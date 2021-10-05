//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 01:43:07 PM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_PolyVec__Shift
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


module State_Pack_Cit__Pack_PolyVec__Shift#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter i_Width = 16,
  parameter o_Ciphertext_Width = 8
)(
  input  [i_Width-1 : 0] iPolyCoeffs0,
  input  [i_Width-1 : 0] iPolyCoeffs1,
  input  [i_Width-1 : 0] iPolyCoeffs2,
  input  [i_Width-1 : 0] iPolyCoeffs3,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext0,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext1,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext2,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext3,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext4  
);

assign o_Ciphertext0 = iPolyCoeffs0 & 8'hff;
assign o_Ciphertext1 = (iPolyCoeffs0 >>> 8) | ((iPolyCoeffs1 & 8'h3f) <<< 2);
assign o_Ciphertext2 = (iPolyCoeffs1 >>> 6) | ((iPolyCoeffs2 & 8'h0f) <<< 4);
assign o_Ciphertext3 = (iPolyCoeffs2 >>> 4) | ((iPolyCoeffs3 & 8'h03) <<< 6);
assign o_Ciphertext4 = iPolyCoeffs3 >>> 2;

endmodule
