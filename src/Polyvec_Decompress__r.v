//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/06/2021 14:44:33 PM
// Design Name: Polyvec_Decompress__r
// Module Name: Polyvec_Decompress__r
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

`define w32(b)  (32'b0 | b)

module Polyvec_Decompress__r #(
  parameter KYBER_Q = 3329
)(
  input             clk,
  input      [63:0] t,
  output reg [47:0] r
);
  
always @(posedge clk) begin
  r[12*4-1 -: 12] <= (`w32(t[16*4-1 -: 16] & 16'h3ff) * KYBER_Q + 512) >> 10;
  r[12*3-1 -: 12] <= (`w32(t[16*3-1 -: 16] & 16'h3ff) * KYBER_Q + 512) >> 10;
  r[12*2-1 -: 12] <= (`w32(t[16*2-1 -: 16] & 16'h3ff) * KYBER_Q + 512) >> 10;
  r[12*1-1 -: 12] <= (`w32(t[16*1-1 -: 16] & 16'h3ff) * KYBER_Q + 512) >> 10;
end

endmodule

`undef w32