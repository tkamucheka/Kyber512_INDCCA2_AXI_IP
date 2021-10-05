`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2021 02:40:41 AM
// Design Name: 
// Module Name: Kyber512_pre_post_hash_ENC
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

`define low_pos(w,b)    ((w)*64 + (b)*8)
`define low_pos2(w,b)   `low_pos(w,7-b)
`define high_pos(w,b)   (`low_pos(w,b) + 7)
`define high_pos2(w,b)  (`low_pos2(w,b) + 7)
`define fill_byte(a)		(8'b0 | a)

module Kyber512_pre_post_hash_ENC #(
  parameter KYBER_N = 256,
  parameter KYBER_K = 2,
  parameter KYBER_Q = 3329,
  parameter State_Width = 64,
  parameter State_Array = 25,
  parameter State_Size = State_Width * State_Array,
  parameter Byte_bits = 8,
  parameter Random_Bytes = 32,
  parameter Pk_Bytes = 800,
  parameter Ct_Bytes = 736,  
  parameter Buf_Bytes_Half = 32,
  parameter Kr_Bytes = 64,
  parameter SS_Bytes = 32,
  parameter iRandom_Size = Byte_bits * Random_Bytes,
  parameter iCt_Size = Byte_bits * Ct_Bytes,
  parameter iPk_Size = Byte_bits * Pk_Bytes,  
  parameter o_Buf_Half_Size = Byte_bits * Buf_Bytes_Half,
  parameter o_Kr_Size = Byte_bits * Kr_Bytes,
  parameter o_SS_Size = Byte_bits * SS_Bytes
)(
  input              clk,
  input              reset_n,
  input              enable,
  input              mode, // 0 for pre, 1 for post
  input [255:0]      i_buf,
  input [6399:0]     i_Pk,
  input [5887:0]     i_Ct,
  input [255:0]      i_post_Kr_Hi,
  output reg         pre_post_hash_done,
  output reg [255:0] o_message,
  output reg [255:0] o_coins,
  output reg [255:0] o_SS,
  output reg [255:0] o_post_Kr_Hi
);

reg [4:0] cstate,nstate;
localparam IDLE		                    = 5'd0;
localparam Permutation_Buf_Squeeze    = 5'd1;
localparam Permutation_Buf_Clear      = 5'd2;
localparam Permutation_PK_Round0_Cal  = 5'd3;
localparam Permutation_PK_Round1_Cal  = 5'd4;
localparam Permutation_PK_Round2_Cal  = 5'd5;
localparam Permutation_PK_Round3_Cal  = 5'd6;
localparam Permutation_PK_Round4_Cal  = 5'd7;
localparam Permutation_PK_Squeeze     = 5'd8;
localparam Permutation_Kr_Squeeze     = 5'd9;
localparam Permutation_Ct_Round0_Cal  = 5'd10;
localparam Permutation_Ct_Round1_Cal  = 5'd11;
localparam Permutation_Ct_Round2_Cal  = 5'd12;
localparam Permutation_Ct_Round3_Cal  = 5'd13;
localparam Permutation_Ct_Round4_Cal  = 5'd14;
localparam Permutation_Ct_Squeeze     = 5'd15;
localparam Permutation_Ct_Clear       = 5'd16;
localparam Permutation_SS_Squeeze     = 5'd17;
localparam Store                      = 5'd18;

localparam PRE  = 1'b0;
localparam POST = 1'b1;

reg                     P0_clear, P1_clear;
reg                     P0_Permutation_Cal_enable, P1_Permutation_Cal_enable;
reg  [1088-1 : 0]       P0_Permutation_Cal_iState;
reg  [576-1  : 0]       P1_Permutation_Cal_iState;
wire                    P0_Permutation_Cal_done, P1_Permutation_Cal_done;
wire [State_Size-1 : 0] P0_Permutation_Cal_oState, P1_Permutation_Cal_oState;

wire [255:0] buf_out, buf_reordered;
wire [319:0] buf_padded_reordered;
wire [1087:0] pk_padded_reordered, ct_padded_reordered;
wire [255:0] coins_reordered;
reg  [319:0] buf_padded;
reg  [1087:0] pk_padded, ct_padded;
reg  [255:0] coins;

reg [511:0] buf1;

assign buf_out = P0_Permutation_Cal_oState[1599 -: 256];

function [319:0] pad_buf(input [255:0] in);
  pad_buf = {in, 8'h06, 56'h0};
endfunction

function [1087:0] pad_ct(input [447:0] in);
  pad_ct = {in, 8'h06, 632'h0};
endfunction

function [1087:0] pad_pk(input [959:0] in);
  pad_pk = {in, 8'h06, 120'h0};
endfunction

function [575:0] pad576_buf1(input [511:0] in);
  pad576_buf1 = {in, 56'h80000000000000, 8'h06};
endfunction

function [1023:0] pad1024_buf1(input [511:0] in);
  pad1024_buf1 = {in, 56'h0, 8'h1f, 448'h0};
endfunction

genvar w, b;
generate
	for(w=0; w<5; w=w+1) begin : L0
		for(b=0; b<8; b=b+1) begin : L1
			assign buf_padded_reordered[`high_pos(w,b):`low_pos(w,b)] = 
          buf_padded[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

generate
	for(w=0; w<4; w=w+1) begin : L4
		for(b=0; b<8; b=b+1) begin : L5
			assign coins_reordered[`high_pos(w,b):`low_pos(w,b)] = 
          coins[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

// reorder buf hi bytes 
generate
	for(w=0; w<4; w=w+1) begin : L6
		for(b=0; b<8; b=b+1) begin : L7
			assign buf_reordered[`high_pos(w,b):`low_pos(w,b)] = 
          buf_out[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

// reorder pk bytes 
generate
	for(w=0; w<17; w=w+1) begin : L8
		for(b=0; b<8; b=b+1) begin : L9
			assign pk_padded_reordered[`high_pos(w,b):`low_pos(w,b)] = 
          pk_padded[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

// reorder ct bytes 
generate
	for(w=0; w<17; w=w+1) begin : L10
		for(b=0; b<8; b=b+1) begin : L11
			assign ct_padded_reordered[`high_pos(w,b):`low_pos(w,b)] = 
          ct_padded[`high_pos2(w,b):`low_pos2(w,b)];
		end
	end
endgenerate

reg [3:0] i;

always @(*) begin
  buf_padded <= pad_buf(i_buf);
  pk_padded  <= (i < 5) ? i_Pk[6399-(i*1088) -: 1088] : pad_pk(i_Pk[959 : 0]);
  ct_padded  <= (i < 5) ? i_Ct[5887-(i*1088) -: 1088] : pad_ct(i_Ct[447 : 0]);
end

always @(posedge clk) begin
  if (mode == POST) begin
    o_SS <= buf_reordered;
  end
end

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else         cstate <= nstate;

always @(cstate or enable or P0_Permutation_Cal_done or P1_Permutation_Cal_done) begin
// always @(posedge clk) begin
  if (mode == 1'b0) begin
    case (cstate)
      IDLE: if (enable)                  nstate <= Permutation_Buf_Squeeze;
            else                         nstate <= IDLE;
      Permutation_Buf_Squeeze: 
            if (P0_Permutation_Cal_done) nstate <= Permutation_Buf_Clear;
            else                         nstate <= Permutation_Buf_Squeeze;
      Permutation_Buf_Clear:             nstate <= Permutation_PK_Round0_Cal;
      Permutation_PK_Round0_Cal:  
            if (P0_Permutation_Cal_done) nstate <= Permutation_PK_Round1_Cal;
            else                         nstate <= Permutation_PK_Round0_Cal;
		  Permutation_PK_Round1_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_PK_Round2_Cal;
            else                         nstate <= Permutation_PK_Round1_Cal;
		  Permutation_PK_Round2_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_PK_Round3_Cal;
            else                         nstate <= Permutation_PK_Round2_Cal;
		  Permutation_PK_Round3_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_PK_Round4_Cal;
            else                         nstate <= Permutation_PK_Round3_Cal;
		  Permutation_PK_Round4_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_PK_Squeeze;
            else                         nstate <= Permutation_PK_Round4_Cal;
		  Permutation_PK_Squeeze:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Kr_Squeeze;
            else                         nstate <= Permutation_PK_Squeeze;	  	
		  Permutation_Kr_Squeeze:
            if (P1_Permutation_Cal_done) nstate <= Store;
            else                         nstate <= Permutation_Kr_Squeeze;
      Store:                             nstate <= IDLE;
      default:                           nstate <= IDLE;
    endcase
  end else begin
    case (cstate)
      IDLE: if (enable)                  nstate <= Permutation_Ct_Round0_Cal;
				    else                         nstate <= IDLE;
		  Permutation_Ct_Round0_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round1_Cal;
	          else                         nstate <= Permutation_Ct_Round0_Cal;
		  Permutation_Ct_Round1_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round2_Cal;
            else                         nstate <= Permutation_Ct_Round1_Cal;
		  Permutation_Ct_Round2_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round3_Cal;
            else                         nstate <= Permutation_Ct_Round2_Cal;
		  Permutation_Ct_Round3_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Round4_Cal;
            else                         nstate <= Permutation_Ct_Round3_Cal;
		  Permutation_Ct_Round4_Cal:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Squeeze;
            else                         nstate <= Permutation_Ct_Round4_Cal;
		  Permutation_Ct_Squeeze:
            if (P0_Permutation_Cal_done) nstate <= Permutation_Ct_Clear;
            else                         nstate <= Permutation_Ct_Squeeze;	  	
		  Permutation_Ct_Clear:              nstate <= Permutation_SS_Squeeze;	
      Permutation_SS_Squeeze:
            if (P0_Permutation_Cal_done) nstate <= IDLE;
            else                         nstate <= Permutation_SS_Squeeze;
      default:                           nstate <= IDLE;
    endcase
  end
end

// always @(negedge reset_n)
//   if (!reset_n) begin
//     P0_Permutation_Cal_enable <= 1'b0;
//     P1_Permutation_Cal_enable <= 1'b0;
//     pre_post_hash_done        <= 1'b0;
//     P0_clear                     <= 1'b0;
//     P1_clear                  <= 1'b0;
//     i                         <= 4'b0;
//     coins                     <= 0;
//     o_SS                      <= 0;
//     o_post_Kr_Hi              <= 0;
//   end

always @(posedge clk)
  if (reset_n == 1'b0) begin
    P0_Permutation_Cal_enable <= 1'b0;
    P1_Permutation_Cal_enable <= 1'b0;
    pre_post_hash_done        <= 1'b0;
    P0_clear                  <= 1'b0;
    P1_clear                  <= 1'b0;
    i                         <= 4'b0;
    coins                     <= 0;
    // o_SS                      <= 0;
    o_post_Kr_Hi              <= 0;
  // end
  // end else if (mode == 1'b0) begin
  end else begin
    case ({mode,cstate,nstate})
      // Pre INDCPA phase
      {PRE, IDLE, IDLE}: pre_post_hash_done <= 1'b0;
      {PRE, IDLE, Permutation_Buf_Squeeze}: begin
        P0_Permutation_Cal_iState <= {buf_padded_reordered, 704'h0, 64'h8000000000000000};
        P0_Permutation_Cal_enable <= 1'b1;
      end
      {PRE, Permutation_Buf_Squeeze, Permutation_Buf_Squeeze}: begin
        P0_Permutation_Cal_enable <= 1'b0;
      end
      {PRE, Permutation_Buf_Squeeze, Permutation_Buf_Clear}: begin
        P0_clear         <= 1'b1;
        buf1[511 -: 256] <= buf_out;
        o_message        <= buf_reordered;
      end
      {PRE, Permutation_Buf_Clear, Permutation_PK_Round0_Cal}: begin
        P0_clear                  <= 1'b0;
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= pk_padded_reordered;
        i <= i + 1;
      end
      {PRE, Permutation_PK_Round0_Cal, Permutation_PK_Round0_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Round0_Cal, Permutation_PK_Round1_Cal}: begin
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= pk_padded_reordered;
        i <= i + 1;
      end
      {PRE, Permutation_PK_Round1_Cal, Permutation_PK_Round1_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Round1_Cal, Permutation_PK_Round2_Cal}: begin
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= pk_padded_reordered;
        i <= i + 1;
      end
      {PRE, Permutation_PK_Round2_Cal, Permutation_PK_Round2_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Round2_Cal, Permutation_PK_Round3_Cal}: begin
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= pk_padded_reordered;
        i <= i + 1;
      end
      {PRE, Permutation_PK_Round3_Cal, Permutation_PK_Round3_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Round3_Cal, Permutation_PK_Round4_Cal}: begin
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= pk_padded_reordered;
        i <= i + 1;
      end
      {PRE, Permutation_PK_Round4_Cal, Permutation_PK_Round4_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Round4_Cal, Permutation_PK_Squeeze}: begin
        P0_Permutation_Cal_enable <= 1'b1;
        P0_Permutation_Cal_iState <= 
            {pk_padded_reordered[1087:64], 64'h8000000000000000};
      end
      {PRE, Permutation_PK_Squeeze, Permutation_PK_Squeeze}:
        P0_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_PK_Squeeze, Permutation_Kr_Squeeze}: begin
        // buf1[255 : 0]             = buf_out;
        P1_Permutation_Cal_iState <= pad576_buf1({buf1[511 -: 256], buf_out});
        P1_Permutation_Cal_enable <= 1'b1;
      end
      {PRE, Permutation_Kr_Squeeze, Permutation_Kr_Squeeze}:
        P1_Permutation_Cal_enable <= 1'b0;
      {PRE, Permutation_Kr_Squeeze, Store}: begin
        P0_clear  <= 1'b1;
        P1_clear  <= 1'b1;
        coins     <= P1_Permutation_Cal_oState[1599-256 -: 256];
        o_post_Kr_Hi     <= P1_Permutation_Cal_oState[1599 -: 256];
      end
      {PRE, Store, IDLE}: begin
        i                  <= 0;
        P0_clear           <= 1'b0;
        P1_clear           <= 1'b0;
        pre_post_hash_done <= 1'b1;
        o_coins            <= coins_reordered;
      end

      // Post INDCPA phase
      {POST, IDLE, IDLE}: pre_post_hash_done <= 1'b0;
      {POST, IDLE, Permutation_Ct_Round0_Cal}: begin
        P0_Permutation_Cal_iState <= ct_padded_reordered;
        P0_Permutation_Cal_enable <= 1'b1;
        i <= i + 1;
      end
      {POST, Permutation_Ct_Round0_Cal, Permutation_Ct_Round0_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Round0_Cal, Permutation_Ct_Round1_Cal}: begin
        P0_Permutation_Cal_iState <= ct_padded_reordered;
        P0_Permutation_Cal_enable <= 1'b1;
        i <= i + 1;
      end
      {POST, Permutation_Ct_Round1_Cal, Permutation_Ct_Round1_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Round1_Cal, Permutation_Ct_Round2_Cal}: begin
        P0_Permutation_Cal_iState <= ct_padded_reordered;
        P0_Permutation_Cal_enable <= 1'b1;
        i <= i + 1;
      end
      {POST, Permutation_Ct_Round2_Cal, Permutation_Ct_Round2_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Round2_Cal, Permutation_Ct_Round3_Cal}: begin
        P0_Permutation_Cal_iState <= ct_padded_reordered;
        P0_Permutation_Cal_enable <= 1'b1;
        i <= i + 1;
      end
      {POST, Permutation_Ct_Round3_Cal, Permutation_Ct_Round3_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Round3_Cal, Permutation_Ct_Round4_Cal}: begin
        P0_Permutation_Cal_iState <= ct_padded_reordered;
        P0_Permutation_Cal_enable <= 1'b1;
        i <= i + 1;
      end
      {POST, Permutation_Ct_Round4_Cal, Permutation_Ct_Round4_Cal}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Round4_Cal, Permutation_Ct_Squeeze}: begin
        P0_Permutation_Cal_iState <= 
            {ct_padded_reordered[1087:64], 64'h8000000000000000};
        P0_Permutation_Cal_enable <= 1'b1;
      end
      {POST, Permutation_Ct_Squeeze, Permutation_Ct_Squeeze}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_Ct_Squeeze, Permutation_Ct_Clear}: begin
        P0_clear      <= 1'b1;
        buf1          <= {i_post_Kr_Hi, buf_out};
      end
      {POST, Permutation_Ct_Clear, Permutation_SS_Squeeze}: begin
        P0_clear                  = 1'b0;
        P0_Permutation_Cal_iState = {pad1024_buf1(buf1), 64'h8000000000000000};
        P0_Permutation_Cal_enable = 1'b1;
      end
      {POST, Permutation_SS_Squeeze, Permutation_SS_Squeeze}:
        P0_Permutation_Cal_enable <= 1'b0;
      {POST, Permutation_SS_Squeeze, IDLE}: begin
        pre_post_hash_done <= 1'b1;
        // o_SS <= buf_reordered;
      end

      default: ;
    endcase
  end
// end else begin
// end

// always @(posedge clk)
//   case ({mode,cstate,nstate})
//     {POST, IDLE, IDLE}: pre_post_hash_done <= 1'b0;
//     {POST, IDLE, Permutation_Ct_Round0_Cal}: begin
//       P0_Permutation_Cal_iState <= ct_padded_reordered;
//       P0_Permutation_Cal_enable <= 1'b1;
//       i <= i + 1;
//     end
//     {POST, Permutation_Ct_Round0_Cal, Permutation_Ct_Round0_Cal}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Round0_Cal, Permutation_Ct_Round1_Cal}: begin
//       P0_Permutation_Cal_iState <= ct_padded_reordered;
//       P0_Permutation_Cal_enable <= 1'b1;
//       i <= i + 1;
//     end
//     {POST, Permutation_Ct_Round1_Cal, Permutation_Ct_Round1_Cal}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Round1_Cal, Permutation_Ct_Round2_Cal}: begin
//       P0_Permutation_Cal_iState <= ct_padded_reordered;
//       P0_Permutation_Cal_enable <= 1'b1;
//       i <= i + 1;
//     end
//     {POST, Permutation_Ct_Round2_Cal, Permutation_Ct_Round2_Cal}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Round2_Cal, Permutation_Ct_Round3_Cal}: begin
//       P0_Permutation_Cal_iState <= ct_padded_reordered;
//       P0_Permutation_Cal_enable <= 1'b1;
//       i <= i + 1;
//     end
//     {POST, Permutation_Ct_Round3_Cal, Permutation_Ct_Round3_Cal}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Round3_Cal, Permutation_Ct_Round4_Cal}: begin
//       P0_Permutation_Cal_iState <= ct_padded_reordered;
//       P0_Permutation_Cal_enable <= 1'b1;
//       i <= i + 1;
//     end
//     {POST, Permutation_Ct_Round4_Cal, Permutation_Ct_Round4_Cal}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Round4_Cal, Permutation_Ct_Squeeze}: begin
//       P0_Permutation_Cal_iState <= 
//           {ct_padded_reordered[1087:64], 64'h8000000000000000};
//       P0_Permutation_Cal_enable <= 1'b1;
//     end
//     {POST, Permutation_Ct_Squeeze, Permutation_Ct_Squeeze}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_Ct_Squeeze, Permutation_Ct_Clear}: begin
//       P0_clear      <= 1'b1;
//       buf1          <= {i_post_Kr_Hi, buf_out};
//     end
//     {POST, Permutation_Ct_Clear, Permutation_SS_Squeeze}: begin
//       P0_clear                  = 1'b0;
//       P0_Permutation_Cal_iState = {pad1024_buf1(buf1), 64'h8000000000000000};
//       P0_Permutation_Cal_enable = 1'b1;
//     end
//     {POST, Permutation_SS_Squeeze, Permutation_SS_Squeeze}:
//       P0_Permutation_Cal_enable <= 1'b0;
//     {POST, Permutation_SS_Squeeze, IDLE}: begin
//       pre_post_hash_done <= 1'b1;
//       o_SS <= buf_reordered;
//     end
//     default:  ;
//   endcase


// SHA3-256, SHAKE-256
f_permutation #(.r(1088), .c(512))
  P0 (
    .clk(clk), 
		.resetn(~reset_n | P0_clear),
		.in(P0_Permutation_Cal_iState),
		.in_ready(P0_Permutation_Cal_enable),
		.ack(),
		.out(P0_Permutation_Cal_oState), 
		.out_ready(P0_Permutation_Cal_done)
  );

// SHA3-512
f_permutation #(.r(576), .c(1024))
  P1 (
    .clk(clk), 
		.resetn(~reset_n | P1_clear),
		.in(P1_Permutation_Cal_iState),
		.in_ready(P1_Permutation_Cal_enable),
		.ack(),
		.out(P1_Permutation_Cal_oState),
		.out_ready(P1_Permutation_Cal_done)
  );

endmodule

`undef low_pos
`undef low_pos2
`undef high_pos
`undef high_pos2
`undef fill_byte