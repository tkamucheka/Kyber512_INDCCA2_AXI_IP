`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2020 12:03:28 AM
// Design Name: 
// Module Name: concat
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

module concat #
(
  parameter    INPUT_WIDTH  = 32,
  parameter    OUTPUT_WIDTH = 32,
  parameter    N            = OUTPUT_WIDTH / INPUT_WIDTH
)
(
  input  wire                         i_clk,
  input  wire                         i_reset_n,
  input  wire                         i_enable,
  input  wire [INPUT_WIDTH - 1 : 0]   i_data_in,
  output wire [OUTPUT_WIDTH - 1 : 0]  o_data_out,
  output wire                         o_full_tick
);

// Registers
reg [INPUT_WIDTH-1:0]  r_count, r_count_next;
reg [OUTPUT_WIDTH-1:0] r_data_out, r_data_next;
reg                    r_full, r_full_next;

// Drivers
assign o_data_out  = r_data_out;
assign o_full_tick = r_full;

// Module logic
// save initial and next value in register
always @(posedge i_clk) begin
  if(i_reset_n == 1'b0) begin
    r_count     <= 32'b0;
    r_full      <= 1'b0;
    r_data_out  <= 0;
  end else begin
    r_count     <= r_count_next;
    r_full      <= r_full_next;
    r_data_out  <= r_data_next;
  end
end

// always @(posedge i_clk, negedge i_reset_n, posedge i_enable) begin
// always @(posedge i_clk) begin
//   if (i_reset_n == 1'b0) begin
//     r_count_next <= 0;
//     r_full_next  <= 0;
//   end else if (i_enable) begin
//     // concatenation
//     r_data_next = r_data_out << INPUT_WIDTH;
//     r_data_next = {r_data_next[OUTPUT_WIDTH-1:INPUT_WIDTH], i_data_in};

//     // coversion completed , send data to output
//     if (r_count == N-1) begin
//         r_count_next <= 32'b0;
//         r_full_next  <= 1'b1;
//     end else begin // else continue count
//         r_count_next <= r_count + 1;
//         r_full_next  <= 1'b0;
//     end
//   end else
//     r_data_next <= r_data_out;
//   end

always @(posedge i_enable) begin
  r_count_next <= r_count;
  r_full_next  <= r_full;
  
  if (i_enable) begin
    // concatenation
    r_data_next = r_data_out << INPUT_WIDTH;
    r_data_next = {r_data_next[OUTPUT_WIDTH-1:INPUT_WIDTH], i_data_in};

    // coversion completed , send data to output
    if (r_count == N-1) begin
        r_count_next <= 32'b0;
        r_full_next  <= 1'b1;
    end else begin // else continue count
        r_count_next <= r_count + 1;
        r_full_next  <= 1'b0;
    end
  end else
    r_data_next = r_data_out;
end

endmodule
