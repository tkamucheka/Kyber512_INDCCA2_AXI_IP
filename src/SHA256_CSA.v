`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 10:03:49 AM
// Design Name: 
// Module Name: SHA256_CSA
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

module SHA256_CSA(
   input [31:0] X,
   input [31:0] Y,
   input [31:0] Z,
   output [31:0] VS,
   output [31:0] VC
);

assign VS = X ^ Y ^ Z;
assign VC = {((X[30:0] & Y[30:0]) | ((X[30:0] ^ Y[30:0]) & Z[30:0])),1'b0};

endmodule