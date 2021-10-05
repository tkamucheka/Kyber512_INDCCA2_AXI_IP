`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 12:39:38 AM
// Design Name: 
// Module Name: hash_h
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


module hash_h #(
		// Users to add parameters here
    parameter DATA_SZ = 256
)
(
  input clk,
  input reset_n,
  input enable,
  input [DATA_SZ-1:0] in,
  output [DATA_SZ-1:0] out
);


SHA256 SHA256_inst (
   .clk(),
   .rst_n(),
   .init(),
   .load(),
   .fetch(),
   .idata(), //#31,15
   .ack(),
   //output valid,
   .odata(),
   .led(),
   .debug()
);

endmodule
