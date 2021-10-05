`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 03/07/2021 09:42:30 PM
// Design Name: 
// Module Name: Montgomery_reduce
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

module Montgomery_reduce #(
  parameter MontgomeryR_QINV = 62209,
  parameter KYBER_Q = 3329)
(
  input                 clk,
  input                 ce,
  input   signed [31:0] iCoeffs_a,
  output  reg    [15:0] oCoeffs,
  output  wire          reduce_done
);

wire last;

reg signed [31:0] a;
reg signed [31:0] t;
reg signed [15:0] u;

reg [4:0] state;

assign reduce_done = state[4];
assign last        = state[3];

always @(posedge clk)
  if (ce) begin
    state <= {state[4:1], 1'b1};
    a     <= iCoeffs_a;
  end else begin
    state <= state << 1;
  end

always @(posedge clk)
  u <= a * $signed(MontgomeryR_QINV);

always @(posedge clk)
  t <= u * $signed(KYBER_Q);

always @(posedge clk)
  if (last)
    oCoeffs <= $signed(iCoeffs_a - t) >>> 16;

endmodule