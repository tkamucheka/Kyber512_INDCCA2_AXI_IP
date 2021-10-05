`timescale 1ns / 1ps

`define P 10

module NTT_tb;

reg  clk = 0;           
reg  rst_n=1;
reg  enable=0;

wire NTT_Done;

NTT DUT (
  .clk(clk),
  .reset_n(rst_n),
  .enable(enable),
  .Poly_NTT_done(NTT_Done)
);

initial begin
#(`P); rst_n = 0;
#(`P); rst_n = 1;

#(`P*10) // idle

#(`P); enable = 1;
#(`P); enable = 0;

while (NTT_Done !== 1'b1) #(`P);

$finish;
end

always #(`P/2) clk = ~clk;

endmodule