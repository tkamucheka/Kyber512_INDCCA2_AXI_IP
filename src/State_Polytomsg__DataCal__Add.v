//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2019 02:06:42 PM
// Design Name: 
// Module Name: State_Polytomsg__DataCal__Add
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


module State_Polytomsg__DataCal__Add#(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter i_Width = 12,
  parameter o_Width = 16
)(
  input   [i_Width-1 : 0] iPolyCoeffs,
  output  [o_Width-1 : 0]  oPolyCoeffs
   );

assign oPolyCoeffs = (({4'h0,iPolyCoeffs} <<< 1) + KYBER_Q/2);

endmodule
