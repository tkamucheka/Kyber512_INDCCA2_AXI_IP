//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/08/2021 06:07:33 AM
// Design Name: Poly_Decompress__t
// Module Name: Poly_Decompress__t
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

`define i(b)    (24-(8*b)-1)

module Poly_Decompress__t (
  input               clk,
  input      [24-1:0] a,
  output reg [64-1:0] t
);

always @(posedge clk) begin
  t[8*8-1 -: 8] <= (a[`i(0) -: 8] >> 0);
  t[8*7-1 -: 8] <= (a[`i(0) -: 8] >> 3);
  t[8*6-1 -: 8] <= (a[`i(0) -: 8] >> 6) | (a[`i(1) -: 8] << 2);
  t[8*5-1 -: 8] <= (a[`i(1) -: 8] >> 1);
  t[8*4-1 -: 8] <= (a[`i(1) -: 8] >> 4);
  t[8*3-1 -: 8] <= (a[`i(1) -: 8] >> 7) | (a[`i(2) -: 8] << 1);
  t[8*2-1 -: 8] <= (a[`i(2) -: 8] >> 2);
  t[8*1-1 -: 8] <= (a[`i(2) -: 8] >> 5);
end

endmodule

`undef i