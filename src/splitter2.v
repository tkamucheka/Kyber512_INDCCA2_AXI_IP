`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2020 10:40:43 PM
// Design Name: 
// Module Name: splitter2
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


module splitter2
#(
    parameter ADDR_WIDTH   = 8, 
    parameter INPUT_WIDTH  = 32,
    parameter OUTPUT_WIDTH = 32,
    parameter N            = INPUT_WIDTH / OUTPUT_WIDTH 
)
(
    input  wire                     i_clk,
    input  wire                     i_reset_n,
    input  wire                     i_chomp,
    input  wire [ADDR_WIDTH-1:0]    i_addr,
    input  wire [INPUT_WIDTH-1:0]   i_data_in,
    output reg  [OUTPUT_WIDTH-1:0]  o_data_out,
    output reg                      o_full
);
integer i;

// Initialize block memory
reg [OUTPUT_WIDTH-1:0] memory [0:N-1];
reg r_full_next = 1'b0;

// Initial
initial
  for(i = 0; i < N; i = i + 1)
    memory[i] <= {OUTPUT_WIDTH{1'b0}};

// Process
// always @(posedge i_clk or negedge i_reset_n) begin
// always @(posedge i_clk) begin
//   if (i_reset_n == 1'b0) begin
//     o_full     <= 1'b0;
//     o_data_out <= 0;
//   end else if (i_chomp) begin
//     r_full_next <= 1'b1;
//     for(i = 0; i < N; i = i + 1)
//       memory[i] <= i_data_in[INPUT_WIDTH-(i*OUTPUT_WIDTH)-1 -: OUTPUT_WIDTH];
//   end else begin
//     o_full     <= r_full_next;
//     o_data_out <= memory[i_addr];
//   end
// end  

// always @(posedge i_clk, posedge i_chomp) begin
//   if (i_chomp) begin
//     r_full_next <= 1'b1;
//     for(i = 0; i < N; i = i + 1)
//       memory[i] <= i_data_in[INPUT_WIDTH-(i*OUTPUT_WIDTH)-1 -: OUTPUT_WIDTH];
//   end
// end


// Process
always @(posedge i_clk or negedge i_reset_n) begin
  if (i_reset_n == 1'b0) begin
    o_full      <= 1'b0;
    o_data_out  <= 0;
  end else begin
    o_full      <= r_full_next;
    o_data_out  <= memory[i_addr];
  end
end  

always @(posedge i_clk or posedge i_chomp) begin
  if (i_chomp) begin
    r_full_next = 1'b1;
    for(i = 0; i < N; i = i + 1)
      memory[i] <= i_data_in[INPUT_WIDTH-(i*OUTPUT_WIDTH)-1 -: OUTPUT_WIDTH];
  end
end

endmodule
