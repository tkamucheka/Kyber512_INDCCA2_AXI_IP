`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2020 06:57:32 PM
// Design Name: 
// Module Name: keccak_tb
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

module keccak_tb;

reg clk       = 0, 
    reset     = 0, 
    in_ready  = 0,
    is_last   = 0;
reg [2:0] byte_num;
reg [63:0] in;

wire buffer_full, out_ready;
wire [511:0] out;

integer i;

// Instantiate the Unit Under Test (UUT)
keccak uut (
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

// SHA3-512("The quick brown fox jumps over the lazy dog")
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
check(512'h01dedd5de4ef14642445ba5f5b97c15e47b9ad931326e4b0727cd94cefc44fff23f07bf543139939b49128caf436dc1bdee54fcb24023a08d9403f9b4bf0d450);

// hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
reset = 1; #(`P); reset = 0;
#(7*`P); // wait some cycles
in = 64'hA1A2A3A4A5000000;
byte_num = 5;
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
check(512'hedc8d5dd93da576838a856c71c5ba87d359445b0589e75e6f67bb8e41a05e78876835d5254d27e0b1445ab49599ff30952a83765858f1e47332835eee6af43f9);
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
check(512'hc9730adfa32afae2b1ce92a32516116093bc86f994ca619f810c93fea177c6315913fe289365eff0a8f97525f26b7b749918c7e8d5e7a51ef74d475782d854fd);
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
check(512'hcad2093f1186dd188eb5b34220eba714213717635b15f2e54ca17949df920ad4ab598a9dbebfe49c2db728dccbbacae3bcdf6b69c59a7773d4b033440ab147c3);
          
// SHA3-512(  c20634f357f421fb8b596413cdc3158f05dcba9cf384c3e0a17168e8cc4a0ff7
//            66bf8533ede64a73da8c8fa1e106af778ad4acaa3263ff100e402fa0f37e4f42)
// Expected:  82d7b80535bb1c9cc37ac1677ca6d4ff3ef92b84488cab1124dd4cf590e2998b
//            40f247bee2d0c4f73329b33df04131f46befb2fcaee5a382afc2e8e299cd20a4
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
  
check(512'h82d7b80535bb1c9cc37ac1677ca6d4ff3ef92b84488cab1124dd4cf590e2998b40f247bee2d0c4f73329b33df04131f46befb2fcaee5a382afc2e8e299cd20a4);

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
    input [511:0] wish;
    begin
      if (out !== wish)
        begin
          $display("%h %h", out, wish); error;
        end
    end
endtask

endmodule

`undef P

