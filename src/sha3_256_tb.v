`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2020 05:11:48 AM
// Design Name: 
// Module Name: sha3_256_tb
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

`define P 10

module sha3_256_tb;

reg clk       = 0, 
    reset     = 0, 
    in_ready  = 0,
    is_last   = 0;
reg [2:0] byte_num;
reg [63:0] in;

wire buffer_full, out_ready;
wire [255:0] out;

integer i;

// Instantiate the Unit Under Test (UUT)
// SHA3-256
keccak #(.r(1088), .c(512), .d(256))
uut (
    .clk(clk),
    .reset(reset),
    .in(in),
    .in_ready(in_ready),
    .is_last(is_last),
    .byte_num(byte_num),
    .buffer_full(buffer_full),
    .out(out),
    .out_ready(out_ready)
);

initial begin

// Initialize Inputs
clk = 0;
reset = 0;
in = 0;
in_ready = 0;
is_last = 0;
byte_num = 0;

// Wait 100 ns for global reset to finish
#100;

// Add stimulus here
@ (negedge clk);

// SHA3-256("The quick brown fox jumps over the lazy dog")
reset = 1; #(`P); reset = 0;
in_ready = 1; is_last = 0;
in = "The quic"; #(`P);
in = "k brown "; #(`P);
in = "fox jump"; #(`P);
in = "s over t"; #(`P);
in = "he lazy "; #(`P);
in = "dog     "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
in_ready = 0; is_last = 0;
while (out_ready !== 1)
    #(`P);
check(256'h69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04);

// hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
reset = 1; #(`P); reset = 0;
#(7*`P); // wait some cycles
in = 64'hA1A2A3A4A5000000;
byte_num = 5;
in_ready = 1;
is_last = 1;
#(`P);
in = 32'h12345678; // next input
in_ready = 1;
is_last = 1;
#(`P/2);
if (buffer_full === 1) error; // should be 0
#(`P/2);
in_ready = 0;
is_last = 0;

while (out_ready !== 1)
  #(`P);
check(256'h815bfaacecd76f2793cbacb330190cc2d7770a028e12293b4cd139841f2aedfc);
for(i=0; i<5; i=i+1)
begin
  #(`P);
  if (buffer_full !== 0) error; // should keep 0
end

// hash a string "\xC2\x06\x34\xF3\x57\xF4\x21\x00", len == 7
reset = 1; #(`P); reset = 0;
#(7*`P); // wait some cycles
in = 64'hc20634f357f42100;
byte_num = 7;
in_ready = 1;
is_last = 1;
#(`P);
in = 64'h12345678; // next input
in_ready = 1;
is_last = 1;
#(`P/2);
if (buffer_full === 1) error; // should be 0
#(`P/2);
in_ready = 0;
is_last = 0;

while (out_ready !== 1)
  #(`P);
check(256'hc57c45f7b31b9ece00cbbe8043d5e80d993fec44a323362c37a7db2761d3780b);
for(i=0; i<5; i=i+1)
begin
  #(`P);
  if (buffer_full !== 0) error; // should keep 0
end

// hash a string "\xC2\x06\x34\xF3\x57\xF4\x21\xFB", len == 7
reset = 1; #(`P); reset = 0;
in_ready = 1; is_last = 0;
in = 64'hc20634f357f421fb; #(`P)
in = 64'h0; byte_num = 0; is_last = 1; #(`P); /* !!! not in = "dog" */
in_ready = 0; is_last = 0;
while (out_ready !== 1)
    #(`P);
check(256'he44f5c3922ae49c92be921b4c3fd73a0b940f9fa6f825d6e660d5938cc0d691f);
          
// SHA3-256(  c20634f357f421fb8b596413cdc3158f05dcba9cf384c3e0a17168e8cc4a0ff7
//            66bf8533ede64a73da8c8fa1e106af778ad4acaa3263ff100e402fa0f37e4f42)
// Expected:  b8c67f9868755899be0881e8f4d9dc75a367e6c81fabb2e810a3f3e401d838d1
reset = 1; 
#(`P);  reset = 0;
        in_ready = 1;
        is_last  = 0;
        in = 64'hc20634f357f421fb;
#(`P);  in = 64'h8b596413cdc3158f;
#(`P);  in = 64'h05dcba9cf384c3e0;
#(`P);  in = 64'ha17168e8cc4a0ff7;
#(`P);  in = 64'h66bf8533ede64a73;
#(`P);  in = 64'hda8c8fa1e106af77;
#(`P);  in = 64'h8ad4acaa3263ff10;
#(`P);  in = 64'h0e402fa0f37e4f42;
#(`P);  in = 64'h0;
        is_last  = 1;
        byte_num = 0;
#(`P);  in_ready = 0;
        is_last  = 0;

while (out_ready !== 1)
  #(`P);
  
check(256'hb8c67f9868755899be0881e8f4d9dc75a367e6c81fabb2e810a3f3e401d838d1);

$display("Good!");
$finish;

end

always #(`P/2) clk = ~ clk;

task error;
    begin
          $display("E");
          $finish;
    end
endtask
    
task check;
    input [255:0] wish;
    begin
      if (out !== wish)
        begin
          $display("%h %h", out, wish); error;
        end
    end
endtask

endmodule

`undef P

