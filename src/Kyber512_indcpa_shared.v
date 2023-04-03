`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 04/08/2021 05:47:30 AM
// Design Name: 
// Module Name: Kyber512_INDCPA_shared
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Kyber512_INDCPA shared modules
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////

module Kyber512_INDCPA_Shared #(
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
  parameter COEF_SZ             = 16
) (
  input clk,
  input rst_n,
  input mux_enc_dec, // enc0, dec1
  // S0: UNPACK_PK_SK
  input                     S0_Unpack_enable,
  input [PUBLICKEY_SZ-1:0]  S0_i_PK,
  input [SECRETKEY_SZ-1:0]  S0_i_SK,
  output                    S0_Unpack_pk_sk_done,
  // output                    S0_EncPk_DecSk_PolyVec_outready,
  // output [5:0]              S0_EncPk_DecSk_PolyVec_WAd,
  // output [127:0]            S0_EncPk_DecSk_PolyVec_WData,
  // Unpack DEBUG:
  // output .unpackedpk_debug(unpackedpk_debug)
  // --------------------------------------
  // S1: NTT
  input          S1_NTT_enable,
  input [1023:0] S1_Sp_r_RData,
  input [3071:0] S1_Bp_ct_RData,
  output         S1_Sp_r_RAd,
  output         S1_Bp_ct_RAd,
  output         S1_NTT_done,
  // output         S1_NTT_Poly_0_outready,
  // output [5:0]   S1_NTT_Poly_0_WAd,
  // output [95:0]  S1_NTT_Poly_0_WData,
  // --------------------------------------
  // S2: PAcc
  input          S2_PAcc_enable,
  // input [3071:0] S2_NTT_Poly_0_RData,
  // input [4095:0] S2_EncPk_DecSk_PolyVec_RData,
  // input [4095:0] S2_M2_AtG_RData,
  // output         S2_NTT_Poly_0_RAd,
  // output         S2_EncPk_DecSk_PolyVec_RAd,   
  // output [2:0]   S2_M2_AtG_RAd,
  output         S2_PAcc_done,
  // output         S2_Enc_BpV_DecMp_M2_outready,
  // output [7:0]   S2_Enc_BpV_DecMp_M2_WAd,
  // output [127:0] S2_Enc_BpV_DecMp_M2_WData,
  // --------------------------------------
  // S3: INTT
  input          S3_INTT_enable,
  // input [4095:0] S3_PACC_EncBp_DecMp_Poly_M2_RData,
  // output [2:0]   S3_PACC_EncBp_DecMp_Poly_M2_RAd,
  output         S3_INTT_done,
  output         S3_INTT_Enc_BpV_DecMp_outready,
  output [6:0]   S3_INTT_Enc_BpV_DecMp_WAd,
  output [127:0] S3_INTT_Enc_BpV_DecMp_WData,
  // --------------------------------------
  // S4: REDUCE
  input          S4_Reduce_enable,  
  input [4095:0] S4_EncBpV_DecMp_M2_RData,
  output [2:0]   S4_EncBpV_DecMp_M2_RAd,
  output         S4_Reduce_done,
  output         S4_Reduce_DecMp_outready,
  output [4:0]   S4_Reduce_DecMp_WAd,
  output [95:0]  S4_Reduce_DecMp_WData,
  output         S4_Reduce_EncBp_outready,
  output [5:0]   S4_Reduce_EncBp_WAd,
  output [95:0]  S4_Reduce_EncBp_WData,
  output         S4_Reduce_EncV_outready,
  output [4:0]   S4_Reduce_EncV_WAd,
  output [95:0]  S4_Reduce_EncV_WData,
  // SHARED M2_RDATA
  input [3:0]    i_cstate,
  input [0:0]    ENC_AtG_M2_WEN,
  input [7:0]    ENC_AtG_M2_WAd,
  input [127:0]  ENC_AtG_M2_WData,
  // input [0:0]    ENC_Add_EncBp_DecMp_outready,
  // input [7:0]    ENC_Add_EncBp_DecMp_WAd,
  // input [127:0]  ENC_Add_EncBp_DecMp_WData,
  // input [0:0]    DEC_Sub_EncBp_DecMp_outready,
  // input [7:0]    DEC_Sub_EncBp_DecMp_WAd,
  // input [127:0]  DEC_Sub_EncBp_DecMp_WData,
  // input [4095:0] SHARED_M2_RData,
  // DEBUG:
  output         trigger
);

// S0: Unpack_PK_SK
wire          S0_EncPk_DecSk_PolyVec_outready;
wire [5:0]    S0_EncPk_DecSk_PolyVec_WAd;
wire [127:0]  S0_EncPk_DecSk_PolyVec_WData;

// S1: NTT
wire          S1_NTT_Poly_0_outready;
wire [5:0]    S1_NTT_Poly_0_WAd;
wire [95:0]   S1_NTT_Poly_0_WData;

// S2: PAcc
wire [3071:0] S2_NTT_Poly_0_RData;
wire [4095:0] S2_EncPk_DecSk_PolyVec_RData;
wire          S2_NTT_Poly_0_RAd;
wire          S2_EncPk_DecSk_PolyVec_RAd;
wire [2:0]    S2_M2_AtG_RAd; 
wire          S2_Enc_BpV_DecMp_M2_outready;
wire [7:0]    S2_Enc_BpV_DecMp_M2_WAd;
wire [127:0]  S2_Enc_BpV_DecMp_M2_WData;

// S3: INTT
wire [2:0]    S3_PACC_EncBp_DecMp_Poly_M2_RAd;

// S4: Reduce
wire [2:0]    S4_Add_EncBpV_DecMp_M2_RAd;

// SHARED
wire [4095:0] SHARED_M2_RData;
wire [0 : 0]    M2_WEN;
wire [7 : 0]    M2_WAd;   // (   7 DOWNTO 0)
wire [127 : 0]  M2_WData; // ( 127 DOWNTO 0)
wire [2 : 0]    M2_RAd;   // (   2 DOWNTO 0)
wire [4095 : 0] M2_RData; // (4095 DOWNTO 0)

// BRAM
L128_EncPk_DecSk_PolyVec M0 (
.clka(clk),
.wea(S0_EncPk_DecSk_PolyVec_outready),
.addra(S0_EncPk_DecSk_PolyVec_WAd),   // (   5 DOWNTO 0)
.dina(S0_EncPk_DecSk_PolyVec_WData),  // ( 127 DOWNTO 0)
.clkb(clk),
.addrb(S2_EncPk_DecSk_PolyVec_RAd),   // ( DOWNTO 0)
.doutb(S2_EncPk_DecSk_PolyVec_RData)  // (4095 DOWNTO 0)
);

L128_AtG M2 (
.clka(clk),
.wea(M2_WEN),
.addra(M2_WAd),   //(7 DOWNTO 0);
.dina(M2_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(M2_RAd),//(2 DOWNTO 0);
.doutb(SHARED_M2_RData)//(4095 DOWNTO 0)
);

L96_NTT_Poly_0 M5 (
.clka(clk),
.wea(S1_NTT_Poly_0_outready),
.addra(S1_NTT_Poly_0_WAd),  //(5 DOWNTO 0);
.dina(S1_NTT_Poly_0_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(S2_NTT_Poly_0_RAd),  //(0 DOWNTO 0);
.doutb(S2_NTT_Poly_0_RData) //(3071 DOWNTO 0)
);

// BRAM Mux : Missing DEC P5 Sub out
BRAM_MUX mux0(
.cstate(i_cstate),
.P2_AtG_WEN(ENC_AtG_M2_WEN),
.P2_AtG_WAd(ENC_AtG_M2_WAd),
.P2_AtG_WData(ENC_AtG_M2_WData),      
.P4_M2_WEN(S2_Enc_BpV_DecMp_M2_outready),
.P4_M2_WAd(S2_Enc_BpV_DecMp_M2_WAd),
.P4_M2_WData(S2_Enc_BpV_DecMp_M2_WData),
.P4_M2_RAd(S2_M2_AtG_RAd),
.P5_M2_RAd(S3_PACC_EncBp_DecMp_Poly_M2_RAd),
// .P6_M2_WEN(ENC_Add_EncBp_DecMp_outready),
// .P6_M2_WAd(ENC_Add_EncBp_DecMp_WAd),
// .P6_M2_WData(ENC_Add_EncBp_DecMp_WData),
// .P7_M2_RAd(S4_Add_EncBpV_DecMp_M2_RAd),   
.M2_WEN(M2_WEN),
.M2_WAd(M2_WAd),
.M2_WData(M2_WData),
.M2_RAd(M2_RAd)
);

// Entity
State_Unpack S0 (
.clk(clk),
.rst_n(rst_n),
.enable(S0_Unpack_enable),
.mux_enc_dec(mux_enc_dec), // enc0, dec1
.ipackedpk(S0_i_PK),
.ipackedsk(S0_i_SK),
.Function_Done(S0_Unpack_pk_sk_done),
.EncPk_DecSk_PolyVec_outready(S0_EncPk_DecSk_PolyVec_outready),
.EncPk_DecSk_PolyVec_WAd(S0_EncPk_DecSk_PolyVec_WAd),
.EncPk_DecSk_PolyVec_WData(S0_EncPk_DecSk_PolyVec_WData)
// DEBUG: PASS
// .unpackedpk_debug(unpackedpk_debug)
);

State_ntt S1 (
  .clk(clk),		
  .rst_n(rst_n),
  .enable(S1_NTT_enable),
  .mux_enc_dec(mux_enc_dec), // enc0, dec1
  .Sp_r_RData(S1_Sp_r_RData),
  .Bp_ct_RData(S1_Bp_ct_RData),	
  .Sp_r_RAd(S1_Sp_r_RAd),
  .Bp_ct_RAd(S1_Bp_ct_RAd),
  .Function_done(S1_NTT_done),
  .NTT_Poly_0_outready(S1_NTT_Poly_0_outready),
  .NTT_Poly_0_WAd(S1_NTT_Poly_0_WAd),
  .NTT_Poly_0_WData(S1_NTT_Poly_0_WData),
  .trigger(trigger)
);

State_PAcc S2 (
  .clk(clk),		
  .rst_n(rst_n),
  .enable(S2_PAcc_enable),
  .mux_enc_dec(mux_enc_dec), // enc0, dec1	
  .NTT_Poly_0_RData(S2_NTT_Poly_0_RData),
  .EncPk_DecSk_PolyVec_RData(S2_EncPk_DecSk_PolyVec_RData),
  .AtG_RData(SHARED_M2_RData),
  .NTT_Poly_0_RAd(S2_NTT_Poly_0_RAd),
  .EncPk_DecSk_PolyVec_RAd(S2_EncPk_DecSk_PolyVec_RAd),     
  .AtG_RAd(S2_M2_AtG_RAd),
  .Function_done(S2_PAcc_done),
  .Enc_BpV_DecMp_outready(S2_Enc_BpV_DecMp_M2_outready),
  .Enc_BpV_DecMp_WAd(S2_Enc_BpV_DecMp_M2_WAd),
  .Enc_BpV_DecMp_WData(S2_Enc_BpV_DecMp_M2_WData)
  // DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
);

State_Invntt S3 (
  .clk(clk),		
  .rst_n(rst_n),
  .enable(S3_INTT_enable),
  .mux_enc_dec(mux_enc_dec), // enc0, dec1	
  .PACC_EncBp_DecMp_Poly_RData(SHARED_M2_RData),
  .PACC_EncBp_DecMp_Poly_RAd(S3_PACC_EncBp_DecMp_Poly_M2_RAd),
  .Function_done(S3_INTT_done),
  .INTT_Enc_BpV_DecMp_outready(S3_INTT_Enc_BpV_DecMp_outready),
  .INTT_Enc_BpV_DecMp_WAd(S3_INTT_Enc_BpV_DecMp_WAd),
  .INTT_Enc_BpV_DecMp_WData(S3_INTT_Enc_BpV_DecMp_WData)
  // DEBUG
  // .Bp_debug(Bp_debug),
  // .V_debug(V_debug)
);

State_Reduce S4 (
  .clk(clk),		
  .rst_n(rst_n),
  .enable(S4_Reduce_enable),
  .mux_enc_dec(mux_enc_dec), // enc0, dec1	 	
  .Add_EncBpV_DecMp_RData(S4_EncBpV_DecMp_M2_RData),
  .Add_EncBpV_DecMp_RAd(S4_EncBpV_DecMp_M2_RAd),
  .Function_done(S4_Reduce_done),
  .Reduce_DecMp_outready(S4_Reduce_DecMp_outready),
  .Reduce_DecMp_WAd(S4_Reduce_DecMp_WAd),
  .Reduce_DecMp_WData(S4_Reduce_DecMp_WData),
  .Reduce_EncBp_outready(S4_Reduce_EncBp_outready),
  .Reduce_EncBp_WAd(S4_Reduce_EncBp_WAd),
  .Reduce_EncBp_WData(S4_Reduce_EncBp_WData),
  .Reduce_EncV_outready(S4_Reduce_EncV_outready),
  .Reduce_EncV_WAd(S4_Reduce_EncV_WAd),
  .Reduce_EncV_WData(S4_Reduce_EncV_WData)
  // DEBUG: out
  // .reduceV_debug(reduceV_debug),
  // .reduceBp_debug(reduceBp_debug)
);

endmodule