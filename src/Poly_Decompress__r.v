//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/08/2021 06:06:33 AM
// Design Name: Poly_Decompress__r
// Module Name: Poly_Decompress__r
// Project Name: Kyber512 INDCPA
// Target Devices: VC707
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

`define w16(b)  (16'b0 | b)
`define i(b)    (8*b-1)

module Poly_Decompress__r #(
  parameter KYBER_Q = 3329
)(
  input             clk,
  input      [63:0] t,
  output reg [95:0] r
);
  
always @(posedge clk) begin
  r[12*8-1 -: 12] <= (`w16(t[`i(8) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*7-1 -: 12] <= (`w16(t[`i(7) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*6-1 -: 12] <= (`w16(t[`i(6) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*5-1 -: 12] <= (`w16(t[`i(5) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*4-1 -: 12] <= (`w16(t[`i(4) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*3-1 -: 12] <= (`w16(t[`i(3) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*2-1 -: 12] <= (`w16(t[`i(2) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
  r[12*1-1 -: 12] <= (`w16(t[`i(1) -: 8] & 8'h7) * KYBER_Q + 4) >> 3;
end

endmodule

`undef w16
`undef i