`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 09:47:06 AM
// Design Name: 
// Module Name: sha256_tb
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


module sha256_tb;

reg clk = 0;
reg rst_n = 1;
reg init = 0;
reg load = 0;
reg fetch = 0;
reg [15:0] msg = 4'h0000;

wire [15:0] hash;
wire [15:0] debug;
wire ack;

integer i = 0;

//SHA256 SHA256_inst (
//   .clk(clk),
//   .rst_n(rst_n),
//   .init(init),
//   .load(load),
//   .fetch(fetch),
//   .idata(msg), //#31,15
//   .ack(ack),
//   //output valid,
//   .odata(hash),
//   .led(),
//   .debug(debug)
//);

crypto_fpga keccak_inst (
   .clk(clk),
   .rst_n(rst_n),
   .init(init),
   .load(load),
   .fetch(fetch),
   .ack(ack),
    .idata(msg),
   .odata(hash)
);

always #5 clk= ~clk;

initial begin
#10 rst_n = 0;
#100 rst_n = 1;
    init = 1;
#100 init = 0; 

//#20 msg = 16'hd3d4;
//    load = 1;
//#20 load = 0; 
//#20 msg = 16 'hb6b2;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h92b3;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'hacd4;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h8f52;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h979d;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'hc144;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h2096;
//    load = 1;
//#20 load = 0;

//#20 msg = 16'he2fd; 
//    load = 1;
//#20 load = 0; 
//#20 msg = 16'h44f5;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h2f38;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h4e7d;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h8769;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h0f67;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'h924f;
//    load = 1;
//#20 load = 0;
//#20 msg = 16'hdd25;
//    load = 0;

//#20 msg = 16'h0000;
//    load = 0;
//    fetch = 0;

for(i=0; i<50;i=i+1) begin
#40 msg = 16'h0000;
    load = 1;
end

#20 msg = 16'h0000;

#20 load = 0;
    fetch = 1;
    

end

endmodule
