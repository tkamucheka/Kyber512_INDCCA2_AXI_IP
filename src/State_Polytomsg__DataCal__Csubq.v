//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2019 02:03:56 PM
// Design Name: 
// Module Name: State_Polytomsg__DataCal__Csubq
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


module State_Polytomsg__DataCal__Csubq#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter i_Width = 12,
  parameter o_Width = 12
)(
  input      [i_Width-1 : 0] iPolyCoeffs,
  output reg [o_Width-1 : 0] oPolyCoeffs
);
   
always@(iPolyCoeffs)
  if (iPolyCoeffs >= KYBER_Q) oPolyCoeffs <= iPolyCoeffs - KYBER_Q;   
  else                        oPolyCoeffs <= iPolyCoeffs;
                                  
endmodule
