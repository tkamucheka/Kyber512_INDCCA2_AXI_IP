//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2019 04:01:47 PM
// Design Name: 
// Module Name: State_Hash__Rej_Uniform_Comparer
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


module State_Hash__Rej_Uniform_Comparer#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter Compare_Constant = 63251, // 19 * KYBER_Q
  parameter i_Width = 8,
  parameter o_Width = 16
)(
  input      [i_Width-1 : 0] iCoeffs_M,
  input      [i_Width-1 : 0] iCoeffs_L,
  output reg  Comparer_result,
  output reg [o_Width-1 : 0] oCoeffs
);
   
always@(iCoeffs_M or iCoeffs_L) begin
  // Bug: Incorrect byte ordering, bytes should be reversed
  // if({iCoeffs_M,iCoeffs_L} < Compare_Constant)
  if({iCoeffs_L,iCoeffs_M} < Compare_Constant)
    Comparer_result <= 1;                         
  else 
    Comparer_result <= 0; 

  // Bug: Incorrect byte ordering, bytes should be reversed
  // oCoeffs <= {iCoeffs_M,iCoeffs_L};
  oCoeffs <= {iCoeffs_L,iCoeffs_M};
end
                                  
endmodule
