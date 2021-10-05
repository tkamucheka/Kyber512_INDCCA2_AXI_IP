//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/06/2021 14:45:33 PM
// Design Name: Polyvec_Decompress__t
// Module Name: Polyvec_Decompress__t
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
`define i(b)    (40-(8*b)-1)

module Polyvec_Decompress__t (
  input               clk,
  input      [40-1:0] a,
  output reg [64-1:0] t
);

always @(posedge clk) begin
  t[16*4-1 -: 16] <= (`w16(a[`i(0) -: 8]) >> 0) | (`w16(a[`i(1) -: 8]) << 8);
  t[16*3-1 -: 16] <= (`w16(a[`i(1) -: 8]) >> 2) | (`w16(a[`i(2) -: 8]) << 6);
  t[16*2-1 -: 16] <= (`w16(a[`i(2) -: 8]) >> 4) | (`w16(a[`i(3) -: 8]) << 4);
  t[16*1-1 -: 16] <= (`w16(a[`i(3) -: 8]) >> 6) | (`w16(a[`i(4) -: 8]) << 2);
end

endmodule

`undef w16
`undef i