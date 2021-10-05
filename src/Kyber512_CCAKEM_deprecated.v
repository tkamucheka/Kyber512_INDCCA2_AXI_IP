`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2020 09:48:42 AM
// Design Name: 
// Module Name: Kyber512_CCAKEM
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


module Kyber512_CCAKEM #(
  parameter KYBER_K             = 2,
  parameter KYBER_N             = 256,
  parameter KYBER_Q             = 3329,
  parameter Byte_bits           = 8,
  parameter KYBER_512_SKBytes   = 1632,
  parameter KYBER_512_PKBytes   = 800,
  parameter KYBER_512_CtBytes   = 736,
  parameter KYBER_512_SSBytes   = 32,
  parameter KYBER_512_RandBytes = 32,
  parameter RAND_SZ             = Byte_bits * KYBER_512_RandBytes,
  parameter CIPHER_TEXT_SZ      = Byte_bits * KYBER_512_CtBytes,
  parameter SECRET_KEY_SZ       = Byte_bits * KYBER_512_SKBytes,
  parameter SHARED_SECRET_SZ    = Byte_bits * KYBER_512_SSBytes,
  parameter PUBLIC_KEY_SZ       = Byte_bits * KYBER_512_PKBytes
)(
  input   wire                          i_clk,
  input   wire                          i_reset_n,
  input   wire [2:0]                    i_enable,
  input   wire [RAND_SZ-1:0]            i_random,
  input   wire [PUBLIC_KEY_SZ-1:0]      i_public_key,
  input   wire [CIPHER_TEXT_SZ-1:0]     i_cipher_text,
  input   wire [SECRET_KEY_SZ-1:0]      i_secret_key,
  output  wire [SHARED_SECRET_SZ-1:0]   o_shared_secreta,
  output  wire [SHARED_SECRET_SZ-1:0]   o_shared_secretb,
  output  wire [CIPHER_TEXT_SZ-1:0]     o_cipher_text,
  output  wire                          o_encryption_done,
  output  wire                          o_decryption_done,
  output  wire                          o_cal_flag,
  output  wire [1:0]                    o_cstate_flag,
  output  wire                          o_verify_fail,
  // DEBUG:
//  output [3:0] state,
  // output [255:0] o_message,
  // output [255:0] o_coins,
  // output [511:0] o_Kr
  // output [127:0] unpackedpk_debug,
  // output [255:0] seed_debug,
  // output [191:0] msgpoly_debug
  // output [1023:0] At_debug,
	// output [255:0] Sp_debug,
	// output [255:0] eG_debug,
//  output [4095:0] ntt_debug,
//output [1023:0] Bp_debug,
//  output [511:0] V_debug,
//  output [255:0] reduceV_debug,
//  output [255:0] reduceBp_debug
output trigger1,
output trigger2
);

// Wires
wire w_cal_flag_enc;
wire w_cal_flag_dec;
wire [1:0] w_enc_cstate_flag;
wire [1:0] w_dec_cstate_flag;

// Drivers
assign  o_cal_flag    = ~i_enable[0] ? w_cal_flag_enc : w_cal_flag_dec;
assign  o_cstate_flag = ~i_enable[0] ? w_enc_cstate_flag : w_dec_cstate_flag;

Kyber512_ENC_KEM KEM_512_ENC_0(
  .clk(i_clk),
  .rst_n(i_reset_n),
  .enable(i_enable[1]),
  .i_Random(i_random),
  .i_PK(i_public_key),
  .Cal_flag(w_cal_flag_enc),
  .Encryption_Done(o_encryption_done),
  .o_Ciphertext(o_cipher_text),
  .o_SharedSecret(o_shared_secreta),
  .cstate_flag(w_enc_cstate_flag),
  // DEBUG:
  // .state(state),
  // .o_message(o_message),
  // .o_coins(o_coins),
  // .o_Kr(o_kr)
  // .unpackedpk_debug(unpackedpk_debug),
  // .seed_debug(seed_debug),
  // .msgpoly_debug(msgpoly_debug)
  // .At_debug(At_debug),
	// .Sp_debug(Sp_debug),
	// .eG_debug(eG_debug),
  // .ntt_debug(ntt_debug),
  // .Bp_debug(Bp_debug),
	// .V_debug(V_debug),
  // .reduceV_debug(reduceV_debug),
  // .reduceBp_debug(reduceBp_debug)
  .trigger1(trigger1),
  .trigger2(trigger2)
);

//Kyber512_DEC_KEM KEM_512_DEC_0(
//  .clk(i_clk),
//  .rst_n(i_reset_n),
//  .enable(i_enable[2]),
//  .i_Ct(i_cipher_text),
//  .i_SK(i_secret_key),
//  .Cal_flag(w_cal_flag_dec),
//  .Verify_fail(o_verify_fail),
//  .Decryption_Done(o_decryption_done),
//  .o_SharedSecret(o_shared_secretb),
//  .cstate_flag(w_dec_cstate_flag)
//);

TRNG KEM_TRNG_0 (

);

endmodule