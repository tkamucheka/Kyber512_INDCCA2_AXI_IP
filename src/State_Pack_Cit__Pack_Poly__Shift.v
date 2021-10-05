`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2019 11:56:18 AM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_Poly__Shift
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


module State_Pack_Cit__Pack_Poly__Shift#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter i_Width = 8,
  parameter o_Ciphertext_Width = 8
)(
  input  [i_Width-1 : 0] iPolyCoeffs0,
  input  [i_Width-1 : 0] iPolyCoeffs1,
  input  [i_Width-1 : 0] iPolyCoeffs2,
  input  [i_Width-1 : 0] iPolyCoeffs3,
  input  [i_Width-1 : 0] iPolyCoeffs4,
  input  [i_Width-1 : 0] iPolyCoeffs5,
  input  [i_Width-1 : 0] iPolyCoeffs6,  
  input  [i_Width-1 : 0] iPolyCoeffs7,    
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext0,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext1,
  output [o_Ciphertext_Width-1 : 0] o_Ciphertext2
);

assign o_Ciphertext0 = iPolyCoeffs0 | (iPolyCoeffs1 << 3) | (iPolyCoeffs2 << 6);
assign o_Ciphertext1 = (iPolyCoeffs2 >> 2) | (iPolyCoeffs3 << 1) | (iPolyCoeffs4 << 4) | (iPolyCoeffs5 << 7);
assign o_Ciphertext2 = (iPolyCoeffs5 >> 1) | (iPolyCoeffs6 << 2) | (iPolyCoeffs7 << 5);


endmodule
