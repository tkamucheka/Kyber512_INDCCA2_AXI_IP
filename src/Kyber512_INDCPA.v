`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 03/26/2021 12:25:30 PM
// Design Name: 
// Module Name: Kyber512_INDCPA
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

module Kyber512_INDCPA #(
  parameter KYBER_K             = 2,
  parameter KYBER_N             = 256,
  parameter KYBER_Q             = 3329,
  parameter BYTE_BITS           = 8,
  parameter KYBER512_SYM_BYTES  = 32,
  parameter KYBER512_PK_BYTES   = 800,
  parameter KYBER512_CT_BYTES   = 736,
  parameter KYBER512_SK_BYTES   = 768,
  parameter PUBLICKEY_SZ        = BYTE_BITS * KYBER512_PK_BYTES,
  parameter MSG_SZ              = BYTE_BITS * KYBER512_SYM_BYTES,
  parameter COINS_SZ            = BYTE_BITS * KYBER512_SYM_BYTES,
  parameter CIPHERTEXT_SZ       = BYTE_BITS * KYBER512_CT_BYTES,
  parameter SECRETKEY_SZ        = BYTE_BITS * KYBER512_SK_BYTES,
  parameter SEED_SZ             = BYTE_BITS * KYBER512_SYM_BYTES
) (
  input clk,
  input rst_n,
  input mux_enc_dec,
  // INDCPA ENC
  input                       i_indcpa_enc_enable,
  input  [PUBLICKEY_SZ-1:0]   i_PK,
  input  [MSG_SZ-1:0]         i_Msg,
  input  [COINS_SZ-1:0]       i_Coins,
  output                      o_indcpa_enc_done,
  output [CIPHERTEXT_SZ-1:0]  o_CT,
  // ------------------------
  // INDCPA DEC
  input                       i_indcpa_dec_enable,
  input  [CIPHERTEXT_SZ-1:0]  i_CT,
  input  [SECRETKEY_SZ-1:0]   i_SK,
  output                      o_indcpa_dec_done,
  output [MSG_SZ-1:0]         o_Msg,
  // ------------------------
  // DEBUG:
  output wire trigger1,
  output wire trigger2
);

// S0: UNPACK_PK_SK
wire          w_P2_S0_Unpack_pk_enable;
wire          w_P2_S0_Unpack_sk_enable;
wire          w_P2_S0_Unpack_pk_sk_enable = mux_enc_dec ? 
                  w_P2_S0_Unpack_sk_enable : w_P2_S0_Unpack_pk_enable;
wire          w_P2_S0_Unpack_done;
wire          w_P2_S0_EncPk_DecSk_PolyVec_outready;
wire [5:0]    w_P2_S0_EncPk_DecSk_PolyVec_WAd;
wire [127:0]  w_P2_S0_EncPk_DecSk_PolyVec_WData;

// S1: NTT
wire          w_P2_S1_ENC_ntt_enable, w_P2_S1_DEC_ntt_enable;
wire          w_P2_S1_ntt_enable = mux_enc_dec ? 
                  w_P2_S1_DEC_ntt_enable : w_P2_S1_ENC_ntt_enable;
wire [1023:0] w_P2_S1_P3_Sp_r_RData;
wire [3071:0] w_P2_S1_Bp_ct_RData;
wire          w_P2_S1_P3_Sp_r_RAd;
wire          w_P2_S1_Bp_ct_RAd;
wire          w_P2_S1_P3_ntt_done;
wire          w_P2_S1_P3_NTT_Poly_0_outready;
wire [5:0]    w_P2_S1_P3_NTT_Poly_0_WAd;
wire [95:0]   w_P2_S1_P3_NTT_Poly_0_WData;

// S2: PAcc
wire          w_P2_S2_ENC_PAcc_enable, w_P2_S2_DEC_PAcc_enable;
wire          w_P2_S2_PAcc_enable = mux_enc_dec ? 
                  w_P2_S2_DEC_PAcc_enable : w_P2_S2_ENC_PAcc_enable;
wire [3071:0] w_P2_S2_NTT_Poly_0_RData;
wire [4095:0] w_P2_S2_EncPk_DecSk_PolyVec_RData;
wire [4095:0] w_P2_S2_M2_RData;
wire          w_P2_S2_NTT_Poly_0_RAd;
wire          w_P2_S2_EncPk_DecSk_PolyVec_RAd;     
wire [2:0]    w_P2_S2_M2_RAd;
wire          w_P2_S2_PAcc_done;
wire          w_P2_S2_M2_WEN;
wire [7:0]    w_P2_S2_M2_WAd;
wire [127:0]  w_P2_S2_M2_WData;

// S3: INTT
wire          w_P2_S3_ENC_Invntt_enable, w_P2_S3_DEC_Invntt_enable;
wire          w_P2_S3_Invntt_enable = mux_enc_dec ?
                w_P2_S3_DEC_Invntt_enable : w_P2_S3_ENC_Invntt_enable;
// wire [4095:0] w_P2_S3_M2_RData;
// wire [2:0]    w_P2_S3_P5_M2_RAd;
wire          w_P2_S3_P5_Invntt_done;
wire          w_P2_S3_INTT_Enc_BpV_DecMp_outready;
wire [6:0]    w_P2_S3_INTT_Enc_BpV_DecMp_WAd;
wire [127:0]  w_P2_S3_INTT_Enc_BpV_DecMp_WData;

// S4: REDUCE
wire          w_P2_S4_ENC_Reduce_enable, w_P2_S4_DEC_Reduce_enable;
wire          w_P2_S4_Reduce_enable = mux_enc_dec ? 
                  w_P2_S4_DEC_Reduce_enable : w_P2_S4_ENC_Reduce_enable;
wire [4095:0] w_P2_S4_Add_EncBpV_M2_RData, w_P2_S4_Sub_DecMp_M2_RData;
wire [4095:0] w_P2_S4_EncBpV_DecMp_M2_RData = mux_enc_dec ?
                  w_P2_S4_Sub_DecMp_M2_RData : w_P2_S4_Add_EncBpV_M2_RData;
wire [2:0]    w_P2_S4_EncBpV_DecMp_M2_RAd;
wire          w_P2_S4_Reduce_done;
wire          w_P2_S4_Reduce_DecMp_outready;
wire [4:0]    w_P2_S4_Reduce_DecMp_WAd;
wire [95:0]   w_P2_S4_Reduce_DecMp_WData;
wire          w_P2_S4_Reduce_EncBp_outready;
wire [5:0]    w_P2_S4_Reduce_EncBp_WAd;
wire [95:0]   w_P2_S4_Reduce_EncBp_WData;
wire          w_P2_S4_Reduce_EncV_outready;
wire [4:0]    w_P2_S4_Reduce_EncV_WAd;
wire [95:0]   w_P2_S4_Reduce_EncV_WData;

// SHARED
wire [3:0]    w_enc_cstate, w_dec_cstate;
wire [3:0]    w_cstate = mux_enc_dec ? w_dec_cstate : w_enc_cstate;
wire [0:0]    w_ENC_P2_AtG_M2_WEN;
wire [7:0]    w_ENC_P2_AtG_M2_WAd;
wire [127:0]  w_ENC_P2_AtG_M2_WData;
wire [0:0]    w_ENC_P6_Add_EncBp_DecMp_outready;
wire [7:0]    w_ENC_P6_Add_EncBp_DecMp_WAd;
wire [127:0]  w_ENC_P6_Add_EncBp_DecMp_WData;
wire [0:0]    w_DEC_P5_Sub_EncBp_DecMp_outready;
wire [7:0]    w_DEC_P5_Sub_EncBp_DecMp_WAd;
wire [127:0]  w_DEC_P5_Sub_EncBp_DecMp_WData;
wire [5 : 0]  w_SHARED_Bp_ct_WAd;
wire [95 : 0] w_SHARED_Bp_ct_WData;
// wire [4095:0] w_SHARED_M2_RData;

Kyber512_indcpa_ENC P0 
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(i_indcpa_enc_enable),
	.mux_enc_dec(mux_enc_dec),
	// .i_PK(i_PK),
	.i_Msg(i_Msg),
	.i_Coins(i_Coins),
  .i_Seed(i_PK[SEED_SZ-1 : 0]),
	.Encryption_Done(o_indcpa_enc_done),
	.o_Ciphertext(o_CT),
	// DEBUG:
	// .state(state),
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
  // ---------------------------------------
  // S0: UNPACK_PK_SK
  .S0_Unpack_enable(w_P2_S0_Unpack_pk_enable),
  .S0_Function_Done(w_P2_S0_Unpack_done),
  // .S0_EncPk_DecSk_PolyVec_outready(w_P2_S0_EncPk_DecSk_PolyVec_outready),
  // .S0_EncPk_DecSk_PolyVec_WAd(w_P2_S0_EncPk_DecSk_PolyVec_WAd),
  // .S0_EncPk_DecSk_PolyVec_WData(w_P2_S0_EncPk_DecSk_PolyVec_WData),
  // Unpack DEBUG:
  // output .unpackedpk_debug(unpackedpk_debug)
  // --------------------------------------
  // S1: NTT
  .S1_NTT_enable(w_P2_S1_ENC_ntt_enable),
  .S1_Sp_r_RData(w_P2_S1_P3_Sp_r_RData),
  .S1_Sp_r_RAd(w_P2_S1_P3_Sp_r_RAd),
  .S1_NTT_done(w_P2_S1_P3_ntt_done),
  // .S1_NTT_Poly_0_outready(w_P2_S1_P3_NTT_Poly_0_outready),
  // .S1_NTT_Poly_0_WAd(w_P2_S1_P3_NTT_Poly_0_WAd),
  // .S1_NTT_Poly_0_WData(w_P2_S1_P3_NTT_Poly_0_WData),
  // --------------------------------------
  // S2: PAcc
  .S2_PAcc_enable(w_P2_S2_ENC_PAcc_enable),
  // .S2_NTT_Poly_0_RData(w_P2_S2_NTT_Poly_0_RData),
  // .S2_EncPk_DecSk_PolyVec_RData(w_P2_S2_EncPk_DecSk_PolyVec_RData),
  // .S2_M2_AtG_RData(w_SHARED_M2_RData),
  // .S2_NTT_Poly_0_RAd(w_P2_S2_NTT_Poly_0_RAd),
  // .S2_EncPk_DecSk_PolyVec_RAd(w_P2_S2_EncPk_DecSk_PolyVec_RAd),     
  // .S2_M2_AtG_RAd(w_P2_S2_M2_RAd),
  .S2_PAcc_done(w_P2_S2_PAcc_done),
  // .S2_Enc_BpV_DecMp_M2_outready(w_P2_S2_M2_WEN),
  // .S2_Enc_BpV_DecMp_M2_WAd(w_P2_S2_M2_WAd),
  // .S2_Enc_BpV_DecMp_M2_WData(w_P2_S2_M2_WData),
  // PAcc DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S3: INTT
  .S3_INTT_enable(w_P2_S3_ENC_Invntt_enable),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RData(w_SHARED_M2_RData),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RAd(w_P2_S3_P5_M2_RAd),
  .S3_INTT_done(w_P2_S3_P5_Invntt_done),
  .S3_INTT_Enc_BpV_DecMp_outready(w_P2_S3_INTT_Enc_BpV_DecMp_outready),
  .S3_INTT_Enc_BpV_DecMp_WAd(w_P2_S3_INTT_Enc_BpV_DecMp_WAd),
  .S3_INTT_Enc_BpV_DecMp_WData(w_P2_S3_INTT_Enc_BpV_DecMp_WData),
  // INTT DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S4: REDUCE
  .S4_Reduce_enable(w_P2_S4_ENC_Reduce_enable),	
  .S4_Add_EncBpV_M2_RData(w_P2_S4_Add_EncBpV_M2_RData),
  .S4_Add_EncBpV_M2_RAd(w_P2_S4_EncBpV_DecMp_M2_RAd),
  .S4_Reduce_done(w_P2_S4_Reduce_done),
  // .S4_Reduce_DecMp_outready(w_P2_S4_Reduce_DecMp_outready),
  // .S4_Reduce_DecMp_WAd(w_P2_S4_Reduce_DecMp_WAd),
  // .S4_Reduce_DecMp_WData(w_P2_S4_Reduce_DecMp_WData),
  .S4_Reduce_EncBp_outready(w_P2_S4_Reduce_EncBp_outready),
  .S4_Reduce_EncBp_WAd(w_P2_S4_Reduce_EncBp_WAd),
  .S4_Reduce_EncBp_WData(w_P2_S4_Reduce_EncBp_WData),
  .S4_Reduce_EncV_outready(w_P2_S4_Reduce_EncV_outready),
  .S4_Reduce_EncV_WAd(w_P2_S4_Reduce_EncV_WAd),
  .S4_Reduce_EncV_WData(w_P2_S4_Reduce_EncV_WData),
  // DEBUG: out
  // .reduceV_debug(reduceV_debug),
  // .reduceBp_debug(reduceBp_debug)
  // --------------------------------------
  // SHARED
  .o_cstate(w_enc_cstate),
  .P2_AtG_outready(w_ENC_P2_AtG_M2_WEN),
  .P2_AtG_M2_WAd(w_ENC_P2_AtG_M2_WAd),
  .P2_AtG_M2_WData(w_ENC_P2_AtG_M2_WData)
  // .P6_Add_EncBp_DecMp_outready(w_ENC_P6_Add_EncBp_DecMp_outready),
  // .P6_Add_EncBp_DecMp_WAd(w_ENC_P6_Add_EncBp_DecMp_WAd),
  // .P6_Add_EncBp_DecMp_WData(w_ENC_P6_Add_EncBp_DecMp_WData),
  // .SHARED_M2_RData(w_SHARED_M2_RData),
  // DEBUG:
  // .trigger(trigger1)
);

Kyber512_indcpa_DEC P1
(
  .clk(clk),
	.rst_n(rst_n),
	.enable(i_indcpa_dec_enable),
	.mux_enc_dec(mux_enc_dec),
  .i_CT(i_CT),
  // .i_SK(i_SK),
  .Decryption_Done(o_indcpa_dec_done),
  .o_Msg(o_Msg),
  // --------------------------------------
  // S0: UNPACK_PK_SK
  .S0_Unpack_enable(w_P2_S0_Unpack_sk_enable),
  // .S0_i_PK(i_PK),
  // .S0_i_SK(i_SK),
  .S0_Function_Done(w_P2_S0_Unpack_done),
  // .S0_EncPk_DecSk_PolyVec_outready(w_P2_S0_EncPk_DecSk_PolyVec_outready),
  // .S0_EncPk_DecSk_PolyVec_WAd(w_P2_S0_EncPk_DecSk_PolyVec_WAd),
  // .S0_EncPk_DecSk_PolyVec_WData(w_P2_S0_EncPk_DecSk_PolyVec_WData),
  // Unpack DEBUG:
  // output .unpackedpk_debug(unpackedpk_debug)
  // --------------------------------------
  // S1: NTT
  .S1_NTT_enable(w_P2_S1_DEC_ntt_enable),
  .S1_Bp_ct_r_RData(w_P2_S1_Bp_ct_RData),
  .S1_Bp_ct_r_RAd(w_P2_S1_Bp_ct_RAd),
  .S1_NTT_done(w_P2_S1_P3_ntt_done),
  // .S1_NTT_Poly_0_outready(w_P2_S1_P3_NTT_Poly_0_outready),
  // .S1_NTT_Poly_0_WAd(w_P2_S1_P3_NTT_Poly_0_WAd),
  // .S1_NTT_Poly_0_WData(w_P2_S1_P3_NTT_Poly_0_WData),
  // --------------------------------------
  // S2: PAcc
  .S2_PAcc_enable(w_P2_S2_DEC_PAcc_enable),
  // .S2_NTT_Poly_0_RData(w_P2_S2_NTT_Poly_0_RData),
  // .S2_EncPk_DecSk_PolyVec_RData(w_P2_S2_EncPk_DecSk_PolyVec_RData),
  // .S2_M2_AtG_RData(w_SHARED_M2_RData),
  // .S2_NTT_Poly_0_RAd(w_P2_S2_NTT_Poly_0_RAd),
  // .S2_EncPk_DecSk_PolyVec_RAd(w_P2_S2_EncPk_DecSk_PolyVec_RAd),  
  // .S2_M2_AtG_RAd(w_P2_S2_M2_RAd),
  .S2_PAcc_done(w_P2_S2_PAcc_done),
  // .S2_Enc_BpV_DecMp_M2_outready(w_P2_S2_M2_WEN),
  // .S2_Enc_BpV_DecMp_M2_WAd(w_P2_S2_M2_WAd),
  // .S2_Enc_BpV_DecMp_M2_WData(w_P2_S2_M2_WData),
  // PAcc DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S3: INTT
  .S3_INTT_enable(w_P2_S3_DEC_Invntt_enable),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RData(w_SHARED_M2_RData),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RAd(w_P2_S3_P5_M2_RAd),
  .S3_INTT_done(w_P2_S3_P5_Invntt_done),
  .S3_INTT_Enc_BpV_DecMp_outready(w_P2_S3_INTT_Enc_BpV_DecMp_outready),
  .S3_INTT_Enc_BpV_DecMp_WAd(w_P2_S3_INTT_Enc_BpV_DecMp_WAd),
  .S3_INTT_Enc_BpV_DecMp_WData(w_P2_S3_INTT_Enc_BpV_DecMp_WData),
  // INTT DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S4: REDUCE
  .S4_Reduce_enable(w_P2_S4_DEC_Reduce_enable),	
  .S4_Sub_DecMp_M2_RData(w_P2_S4_Sub_DecMp_M2_RData),
  .S4_Sub_DecMp_M2_RAd(w_P2_S4_EncBpV_DecMp_M2_RAd),
  .S4_Reduce_done(w_P2_S4_Reduce_done),
  .S4_Reduce_DecMp_outready(w_P2_S4_Reduce_DecMp_outready),
  .S4_Reduce_DecMp_WAd(w_P2_S4_Reduce_DecMp_WAd),
  .S4_Reduce_DecMp_WData(w_P2_S4_Reduce_DecMp_WData),
  // .S4_Reduce_EncBp_outready(w_P2_S4_Reduce_EncBp_outready),
  // .S4_Reduce_EncBp_WAd(w_P2_S4_Reduce_EncBp_WAd),
  // .S4_Reduce_EncBp_WData(w_P2_S4_Reduce_EncBp_WData),
  // .S4_Reduce_EncV_outready(w_P2_S4_Reduce_EncV_outready),
  // .S4_Reduce_EncV_WAd(w_P2_S4_Reduce_EncV_WAd),
  // .S4_Reduce_EncV_WData(w_P2_S4_Reduce_EncV_WData),
  // DEBUG: out
  // .reduceV_debug(reduceV_debug),
  // .reduceBp_debug(reduceBp_debug)
  // --------------------------------------
  // SHARED
  .o_cstate(w_dec_cstate),
  // .SHARED_Bp_ct_outready(w_SHARED_Bp_ct_outready),
  // .SHARED_Bp_ct_WAd(w_SHARED_Bp_ct_WAd),
  // .SHARED_Bp_ct_WData(w_SHARED_Bp_ct_WData),  
  // .P5_Sub_EncBp_DecMp_outready(w_DEC_P5_Sub_EncBp_DecMp_outready),
  // .P5_Sub_EncBp_DecMp_WAd(w_DEC_P5_Sub_EncBp_DecMp_WAd),
  // .P5_Sub_EncBp_DecMp_WData(w_DEC_P5_Sub_EncBp_DecMp_WData)
  // .SHARED_M2_RData(w_SHARED_M2_RData),
  // DEBUG:
  .trigger1(trigger1),
  .trigger2(trigger2)
);

Kyber512_INDCPA_Shared P2
(
  .clk(clk),
  .rst_n(rst_n),
  .mux_enc_dec(mux_enc_dec), // enc0, dec1
  // --------------------------------------
  // S0: UNPACK_PK_SK
  .S0_Unpack_enable(w_P2_S0_Unpack_pk_sk_enable),
  .S0_i_PK(i_PK),
  .S0_i_SK(i_SK),
  .S0_Unpack_pk_sk_done(w_P2_S0_Unpack_done),
  // .S0_EncPk_DecSk_PolyVec_outready(w_P2_S0_EncPk_DecSk_PolyVec_outready),
  // .S0_EncPk_DecSk_PolyVec_WAd(w_P2_S0_EncPk_DecSk_PolyVec_WAd),
  // .S0_EncPk_DecSk_PolyVec_WData(w_P2_S0_EncPk_DecSk_PolyVec_WData),
  // Unpack DEBUG:
  // output .unpackedpk_debug(unpackedpk_debug)
  // --------------------------------------
  // S1: NTT
  .S1_NTT_enable(w_P2_S1_ntt_enable),
  .S1_Sp_r_RData(w_P2_S1_P3_Sp_r_RData),
  .S1_Bp_ct_RData(w_P2_S1_Bp_ct_RData),
  .S1_Sp_r_RAd(w_P2_S1_P3_Sp_r_RAd),
  .S1_Bp_ct_RAd(w_P2_S1_Bp_ct_RAd),
  .S1_NTT_done(w_P2_S1_P3_ntt_done),
  // .S1_NTT_Poly_0_outready(w_P2_S1_P3_NTT_Poly_0_outready),
  // .S1_NTT_Poly_0_WAd(w_P2_S1_P3_NTT_Poly_0_WAd),
  // .S1_NTT_Poly_0_WData(w_P2_S1_P3_NTT_Poly_0_WData),
  // --------------------------------------
  // S2: PAcc
  .S2_PAcc_enable(w_P2_S2_PAcc_enable),
  // .S2_NTT_Poly_0_RData(w_P2_S2_NTT_Poly_0_RData),
  // .S2_EncPk_DecSk_PolyVec_RData(w_P2_S2_EncPk_DecSk_PolyVec_RData),
  // .S2_M2_AtG_RData(w_SHARED_M2_RData),
  // .S2_NTT_Poly_0_RAd(w_P2_S2_NTT_Poly_0_RAd),
  // .S2_EncPk_DecSk_PolyVec_RAd(w_P2_S2_EncPk_DecSk_PolyVec_RAd),  
  // .S2_M2_AtG_RAd(w_P2_S2_M2_RAd),
  .S2_PAcc_done(w_P2_S2_PAcc_done),
  // .S2_Enc_BpV_DecMp_M2_outready(w_P2_S2_M2_WEN),
  // .S2_Enc_BpV_DecMp_M2_WAd(w_P2_S2_M2_WAd),
  // .S2_Enc_BpV_DecMp_M2_WData(w_P2_S2_M2_WData),
  // PAcc DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S3: INTT
  .S3_INTT_enable(w_P2_S3_Invntt_enable),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RData(w_SHARED_M2_RData),
  // .S3_PACC_EncBp_DecMp_Poly_M2_RAd(w_P2_S3_P5_M2_RAd),
  .S3_INTT_done(w_P2_S3_P5_Invntt_done),
  .S3_INTT_Enc_BpV_DecMp_outready(w_P2_S3_INTT_Enc_BpV_DecMp_outready),
  .S3_INTT_Enc_BpV_DecMp_WAd(w_P2_S3_INTT_Enc_BpV_DecMp_WAd),
  .S3_INTT_Enc_BpV_DecMp_WData(w_P2_S3_INTT_Enc_BpV_DecMp_WData),
  // INTT DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
  // --------------------------------------
  // S4: REDUCE
  .S4_Reduce_enable(w_P2_S4_Reduce_enable),
  .S4_EncBpV_DecMp_M2_RData(w_P2_S4_EncBpV_DecMp_M2_RData),
  .S4_EncBpV_DecMp_M2_RAd(w_P2_S4_EncBpV_DecMp_M2_RAd),
  .S4_Reduce_done(w_P2_S4_Reduce_done),
  .S4_Reduce_DecMp_outready(w_P2_S4_Reduce_DecMp_outready),
  .S4_Reduce_DecMp_WAd(w_P2_S4_Reduce_DecMp_WAd),
  .S4_Reduce_DecMp_WData(w_P2_S4_Reduce_DecMp_WData),
  .S4_Reduce_EncBp_outready(w_P2_S4_Reduce_EncBp_outready),
  .S4_Reduce_EncBp_WAd(w_P2_S4_Reduce_EncBp_WAd),
  .S4_Reduce_EncBp_WData(w_P2_S4_Reduce_EncBp_WData),
  .S4_Reduce_EncV_outready(w_P2_S4_Reduce_EncV_outready),
  .S4_Reduce_EncV_WAd(w_P2_S4_Reduce_EncV_WAd),
  .S4_Reduce_EncV_WData(w_P2_S4_Reduce_EncV_WData),
  // DEBUG: out
  // .reduceV_debug(reduceV_debug),
  // .reduceBp_debug(reduceBp_debug)
  // --------------------------------------
  // SHARED
  .i_cstate(w_cstate),
  .ENC_AtG_M2_WEN(w_ENC_P2_AtG_M2_WEN),
  .ENC_AtG_M2_WAd(w_ENC_P2_AtG_M2_WAd),
  .ENC_AtG_M2_WData(w_ENC_P2_AtG_M2_WData)
  // .SHARED_Bp_ct_outready(w_SHARED_Bp_ct_outready),
  // .SHARED_Bp_ct_WAd(w_SHARED_Bp_ct_WAd),
  // .SHARED_Bp_ct_WData(w_SHARED_Bp_ct_WData),
  // .ENC_Add_EncBp_DecMp_outready(w_ENC_P6_Add_EncBp_DecMp_outready),
  // .ENC_Add_EncBp_DecMp_WAd(w_ENC_P6_Add_EncBp_DecMp_WAd),
  // .ENC_Add_EncBp_DecMp_WData(w_ENC_P6_Add_EncBp_DecMp_WData),
  // .DEC_Sub_EncBp_DecMp_outready(w_DEC_P5_Sub_EncBp_DecMp_outready),
  // .DEC_Sub_EncBp_DecMp_WAd(w_DEC_P5_Sub_EncBp_DecMp_WAd),
  // .DEC_Sub_EncBp_DecMp_WData(w_DEC_P5_Sub_EncBp_DecMp_WData),
  // .SHARED_M2_RData(w_SHARED_M2_RData),
  // DEBUG:
  // .trigger(trigger2)
);

endmodule