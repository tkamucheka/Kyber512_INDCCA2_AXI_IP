//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 04/30/2021 04:55:03 AM
// Design Name: 
// Module Name: Kyber512_INDCPA_DEC
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

module Kyber512_indcpa_DEC #(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter BYTE_BITS = 8,
  parameter KYBER_SYMBYTES     = 32,
  parameter KYBER_POLYBYTES    = 384,
  parameter KYBER_POLYVECBYTES = KYBER_K * KYBER_POLYBYTES,
  parameter KYBER_512_POLYCOMPRESSEDBYTES = 96,
  parameter KYBER_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter KYBER_INDCPA_BYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_512_POLYCOMPRESSEDBYTES,
  parameter KYBER_INDCPA_SECRETKEYBYTES = KYBER_POLYVECBYTES,
  parameter CIPHERTEXT_SZ = BYTE_BITS * KYBER_INDCPA_BYTES, 
  parameter SECRETKEY_SZ  = BYTE_BITS * KYBER_INDCPA_SECRETKEYBYTES,
  parameter MESSAGE_SZ    = BYTE_BITS * KYBER_SYMBYTES
)(
  input                           clk,		
  input                           rst_n,
  input                           enable,
  input                           mux_enc_dec,	
  input   [CIPHERTEXT_SZ-1 : 0]   i_CT,
  input   [SECRETKEY_SZ-1 : 0]    i_SK,
  // input   [Coins_Size-1 : 0]      i_Coins,
  output  reg                     Decryption_Done,
  output  [MESSAGE_SZ-1 : 0]      o_Msg,
  // output  reg                     Encryption_Done,
  // output  [Ciphertext_Size-1 : 0] o_ReENC_Ciphertext,
  // --------------------------------------
  // S0: UNPACK_PK_SK
  output reg     S0_Unpack_enable,
  input          S0_Function_Done,
  // input          S0_EncPk_DecSk_PolyVec_outready,
  // input [5:0]    S0_EncPk_DecSk_PolyVec_WAd,
  // input [127:0]  S0_EncPk_DecSk_PolyVec_WData,
  // --------------------------------------
  // S1: NTT
  output reg      S1_NTT_enable,
  output [3071:0] S1_Bp_ct_r_RData,
  input           S1_Bp_ct_r_RAd,
  input           S1_NTT_done,
  input           S1_NTT_Poly_0_outready,
  input [5:0]     S1_NTT_Poly_0_WAd,
  input [95:0]    S1_NTT_Poly_0_WData,
  // --------------------------------------
  // S2: PAcc
  output reg      S2_PAcc_enable,
  output [3071:0] S2_NTT_Poly_0_RData,
  output [4095:0] S2_EncPk_DecSk_PolyVec_RData,
  output [4095:0] S2_M2_AtG_RData,
  input           S2_NTT_Poly_0_RAd,
  input           S2_EncPk_DecSk_PolyVec_RAd,     
  input [2:0]     S2_M2_AtG_RAd,
  input           S2_PAcc_done,
  input           S2_Enc_BpV_DecMp_M2_outready,
  input [7:0]     S2_Enc_BpV_DecMp_M2_WAd,
  input [127:0]   S2_Enc_BpV_DecMp_M2_WData,
  // --------------------------------------
  // S3: INTT
  output reg      S3_INTT_enable,
  output [4095:0] S3_PACC_EncBp_DecMp_Poly_M2_RData,
  input [2:0]     S3_PACC_EncBp_DecMp_Poly_M2_RAd,
  input           S3_INTT_done,
  input           S3_INTT_Enc_BpV_DecMp_outready,
  input [6:0]     S3_INTT_Enc_BpV_DecMp_WAd,
  input [127:0]   S3_INTT_Enc_BpV_DecMp_WData,
  // --------------------------------------
  // S4: REDUCE
  output reg      S4_Reduce_enable,  
  output [4095:0] S4_Sub_DecMp_M2_RData,
  input [2:0]     S4_Sub_DecMp_M2_RAd,
  input           S4_Reduce_done,
  input           S4_Reduce_DecMp_outready,
  input [4:0]     S4_Reduce_DecMp_WAd,
  input [95:0]    S4_Reduce_DecMp_WData,
  // input           S4_Reduce_EncBp_outready,
  // input [5:0]     S4_Reduce_EncBp_WAd,
  // input [95:0]    S4_Reduce_EncBp_WData,
  // input           S4_Reduce_EncV_outready,
  // input [4:0]     S4_Reduce_EncV_WAd,
  // input [95:0]    S4_Reduce_EncV_WData,
  // --------------------------------------
  // SHARED
  output [3:0]    o_cstate,
  // output [0:0]    P5_Sub_DecMp_outready,
  // output [7:0]    P5_Sub_DecMp_WAd,
  // output [127:0]  P5_Sub_DecMp_WData
  // DEBUG:
  output reg trigger1,
  output reg trigger2
);

reg  P0_Unpack_Ciphertext_enable;
// wire [Seed_Char_Size-1 : 0] ENC_Seed_Char = i_SK[BYTE_BITS*(768+800)-1 -: Seed_Char_Size];
// wire [BYTE_BITS*KYBER_POLYCOMPRESSEDBYTES-1 :0 ] P0_iSeed_Char = i_CT[Ciphertext_Size-1 -: 768];
// wire [BYTE_BITS*KYBER_512_POLYVECCOMPRESSEDBYTES-1 : 0] P0_i_Ciphertext = i_CT[Ciphertext_Size-1-768 -: 5120];
wire P0_Unpack_Ciphertext_done;
wire [0 : 0] P0_Bp_outready;
wire [5 : 0] P0_Bp_WAd;
wire [95 : 0] P0_Bp_WData;
wire [0 : 0] P0_Dec_V_outready;
wire [7 : 0] P0_Dec_V_WAd;
wire [11 : 0] P0_Dec_V_WData;

// reg  Unpack_enable;
// wire Unpack_done;
// wire [Packed_pk_Size-1 : 0] Packed_pk = i_SK[BYTE_BITS*(768+800)-1 -: Packed_pk_Size];
// wire [Packed_sk_Size-1 : 0] Packed_sk = i_SK[BYTE_BITS*768-1 -: Packed_sk_Size];
// wire [0 : 0] P1_EncPk_DecSk_PolyVec_outready; 
// wire [5 : 0] P1_EncPk_DecSk_PolyVec_WAd; 
// wire [127 : 0] P1_EncPk_DecSk_PolyVec_WData; 

// reg  NTT_enable;
// wire NTT_done;
// wire [0 : 0] P2_Bp_ct_RAd;
// wire [0 : 0] P2_NTT_Poly_0_outready;
// wire [5 : 0] P2_NTT_Poly_0_WAd;
// wire [95 : 0] P2_NTT_Poly_0_WData;
// wire [1024-1 : 0] P2_Sp_r_RData;
// wire [0 : 0] P2_Sp_r_RAd;

// reg  PAcc_enable;
// wire PAcc_done;
// wire [4095 : 0] P3_EncPk_DecSk_PolyVec_RData;
// wire [0 : 0] P3_NTT_Poly_0_RAd;
// wire [0 : 0] P3_EncPk_DecSk_PolyVec_RAd;
// wire [0 : 0] P3_Enc_BpV_DecMp_outready;
// wire [7 : 0] P3_Enc_BpV_DecMp_WAd;
// wire [127 : 0] P3_Enc_BpV_DecMp_WData;

// reg  INTT_enable;
// wire INTT_done;
// wire [2 : 0] PACC_EncBp_DecMp_Poly_RAd;
// wire [2 : 0] P3_M3_RAd;
// wire [0 : 0] INTT_Enc_BpV_DecMp_outready;
// wire [6 : 0] INTT_Enc_BpV_DecMp_WAd;
// wire [127 : 0]INTT_Enc_BpV_DecMp_WData;

reg  P5_Sub_enable;
wire P5_Sub_done;
// wire [0 : 0] Sub_EncBp_DecMp_outready;
// wire [7 : 0] Sub_EncBp_DecMp_WAd;
// wire [128 : 0] Sub_EncBp_DecMp_WData;
wire [0:0]    P5_Sub_DecMp_outready;
wire [7:0]    P5_Sub_DecMp_WAd;
wire [127:0]  P5_Sub_DecMp_WData;
wire [4 : 0]  P5_Dec_v_RAd;
wire [95 : 0] P5_Dec_v_RData;
// wire [6 : 0]  INTT_DecMp_RAd;
// wire [6 : 0]  INTT_Enc_BpV_RAd;
wire [6 : 0]  INTT_Enc_BpV_DecMp_RAd;
wire [127: 0] INTT_Enc_BpV_DecMp_RData;

// reg  Reduce_enable;
// wire Reduce_done;
// wire [2 : 0] Sub_EncBpV_DecMp_RAd;
// wire [0 : 0] Reduce_DecMp_outready;
// wire [4 : 0] Reduce_DecMp_WAd;
// wire [95 : 0] Reduce_DecMp_WData;

// wire From_Msg_done;
// wire [0 : 0] P8_out_ready;
// wire [7 : 0] P8_Poly_WAd;
// wire [11 : 0] P8_WData;
// reg  From_Msg_enable;

reg  P7_Poly_ToMsg_enable;
wire P7_Poly_ToMsg_done;
wire [7 : 0] Reduce_DecMp_RAd;
wire [11 : 0] Reduce_DecMp_RData;	
wire [0 : 0] Reduce_EncBp_outready;
wire [5 : 0] Reduce_EncBp_WAd;
wire [96-1 : 0] Reduce_EncBp_WData;
wire [0 : 0] Reduce_EncV_outready;
wire [4 : 0] Reduce_EncV_WAd;
wire [96-1 : 0] Reduce_EncV_WData;

// wire Hash_Done;
// reg Hash_enable;
// wire [2 : 0] P9_AtG_WEN;
// wire [7 : 0] P9_AtG_WAd;
// wire [128-1 : 0] P9_AtG_WData;
// wire [0 : 0] Sp_r_outready;
// wire [5 : 0] Sp_r_WAd;
// wire [32-1 : 0] Sp_r_WData;
// wire [0 : 0] eG_outready;
// wire [6 : 0] eG_WAd;
// wire [32-1 : 0] eG_WData;

// wire Add_done;
// reg Add_enable;
// wire [4 : 0] P10_Add_k_RAd;
// wire [32-1 : 0] P10_eG_RData;
// wire [6 : 0] P10_eG_RAd; 
// wire P10_M3_WEN;
// wire [7 : 0] P10_M3_WAd;
// wire [127 : 0] P10_M3_WData;

// wire Pack_done;
// reg Pack_enable;
// wire [48-1 : 0] P11_Reduce_EncBp_RData;
// wire [96-1 : 0] P11_Reduce_EncV_RData;
// wire [6 : 0] P11_Reduce_EncBp_RAd;
// wire [4 : 0] P11_Reduce_EncV_RAd;
// wire [2560-1 : 0] P11_o_Ciphertext0_0;
// wire [2560-1 : 0] P11_o_Ciphertext0_1;
// wire [768-1 : 0] P11_o_Ciphertext1;
// assign o_ReENC_Ciphertext = {P11_o_Ciphertext1,P11_o_Ciphertext0_1,P11_o_Ciphertext0_0};

//BRAM
// wire [0 : 0] M0_WEN;
// wire [5 : 0] M0_WAd;
// wire [95 : 0] M0_WData;
// wire [0 : 0] M0_RAd;
// wire [3071 : 0] M0_RData;

// wire [0 : 0] M1_WEN;
// wire [7 : 0] M1_WAd;
// wire [11 : 0] M1_WData;
// wire [4 : 0] M1_RAd;
// wire [95 : 0] M1_RData;

// wire [0 : 0] M3_WEN;
// wire [7 : 0] M3_WAd;
// wire [127 : 0] M3_WData;
// wire [2 : 0] M3_RAd;
// wire [4095 : 0] M3_RData;

// Dirty bit
reg dirty;

reg [3:0] cstate,nstate;											
localparam IDLE       = 4'd0;
localparam Unpack     = 4'd1; // Unpack CT & SK
localparam NTT        = 4'd3;
localparam PAcc       = 4'd4;
localparam INTT       = 4'd5;
localparam Sub        = 4'd6;
localparam Reduce     = 4'd7;
localparam Poly_ToMsg = 4'd8;

assign o_cstate = cstate;

// synthesis translate_off
integer cycles = 0;
reg enable_dec_counter = 0;
always @(posedge clk) begin
  if (enable_dec_counter) 
    cycles <= cycles + 1;
end
// synthesis translate_on

always @(posedge clk or negedge rst_n)
	if (!rst_n) cstate <= IDLE;
	else        cstate <= nstate;

// INDCPA state machine
always @(cstate or enable or P0_Unpack_Ciphertext_done or S1_NTT_done or
          S2_PAcc_done or S3_INTT_done or P5_Sub_done or
          S4_Reduce_done or P7_Poly_ToMsg_done) begin
  case (cstate)
    IDLE:       if(enable && !dirty)            nstate <= Unpack;
                else                            nstate <= IDLE;
    Unpack:     if (P0_Unpack_Ciphertext_done)  nstate <= NTT;
                else                            nstate <= Unpack;
    NTT:        if (S1_NTT_done)                nstate <= PAcc;
                else                            nstate <= NTT;
    PAcc:       if (S2_PAcc_done)               nstate <= INTT;
                else                            nstate <= PAcc; 
    INTT:       if (S3_INTT_done)               nstate <= Sub;
                else                            nstate <= INTT;
    Sub:        if (P5_Sub_done)                nstate <= Reduce;
                else                            nstate <= Sub;
    Reduce:     if (S4_Reduce_done)             nstate <= Poly_ToMsg;
                else                            nstate <= Reduce; 
    Poly_ToMsg: if (P7_Poly_ToMsg_done)         nstate <= IDLE;
                else                            nstate <= Poly_ToMsg; 
    default:                                    nstate <= IDLE;
  endcase          
end

always @(posedge clk or negedge rst_n)
  if (!rst_n) begin
    Decryption_Done             <= 1'b0;
		P0_Unpack_Ciphertext_enable <= 1'b0;
		S0_Unpack_enable            <= 1'b0;
		S1_NTT_enable               <= 1'b0;
		S2_PAcc_enable              <= 1'b0;
		S3_INTT_enable              <= 1'b0;
		P5_Sub_enable               <= 1'b0;
		S4_Reduce_enable            <= 1'b0;
		P7_Poly_ToMsg_enable        <= 1'b0;
    dirty                       <= 1'b0;
    trigger1                    <= 1'b0;
    trigger2                    <= 1'b0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: Decryption_Done  <= 1'b0;
      {IDLE,Unpack}: begin
        dirty                       <= 1'b1;
        P0_Unpack_Ciphertext_enable <= 1'b1;
        S0_Unpack_enable            <= 1'b1;
        trigger1                    <= 1'b1;

        // synthesis translate_off
        enable_dec_counter          <= 1'b1;
        // synthesis translate_on 
      end
      {Unpack,Unpack}: begin
        P0_Unpack_Ciphertext_enable <= 1'b0;
        S0_Unpack_enable            <= 1'b0; 
      end
      {Unpack,NTT}:            S1_NTT_enable    <= 1'b1;
      {NTT,NTT}:               S1_NTT_enable    <= 1'b0;
      {NTT,PAcc}:              S2_PAcc_enable   <= 1'b1;
      {PAcc,PAcc}:             S2_PAcc_enable   <= 1'b0;
      {PAcc,INTT}:             S3_INTT_enable   <= 1'b1;
      {INTT,INTT}:             S3_INTT_enable   <= 1'b0;
      {INTT,Sub}:              P5_Sub_enable    <= 1'b1;
      {Sub,Sub}:               P5_Sub_enable    <= 1'b0;
      {Sub,Reduce}:            S4_Reduce_enable <= 1'b1;
      {Reduce,Reduce}:         S4_Reduce_enable <= 1'b0;
      {Reduce,Poly_ToMsg}: begin
        P7_Poly_ToMsg_enable  <= 1'b1;
        trigger2              <= 1'b1;
      end      
      {Poly_ToMsg,Poly_ToMsg}: P7_Poly_ToMsg_enable  <= 1'b0;
      {Poly_ToMsg,IDLE}: begin
        Decryption_Done     <= 1'b1;
        trigger1            <= 1'b0;
        trigger2            <= 1'b0;

        // synthesis translate_off
        enable_dec_counter  <= 1'b0;
        // synthesis translate_on
      end       
      default: ;
    endcase
  end

// BRAM
L96_NTT_Poly_0 M0( 
.clka(clk),
.wea(P0_Bp_outready),
.addra(P0_Bp_WAd),     // ( 5 DOWNTO 0);
.dina(P0_Bp_WData),    // (95 DOWNTO 0);
.clkb(clk),
.addrb(S1_Bp_ct_r_RAd),      // (   0 DOWNTO 0);
.doutb(S1_Bp_ct_r_RData)  // (3071 DOWNTO 0)
);

L12_k M1(
.clka(clk),
.wea(P0_Dec_V_outready),
.addra(P0_Dec_V_WAd),   // ( 7 DOWNTO 0);
.dina(P0_Dec_V_WData),  // (11 DOWNTO 0);
.clkb(clk),
.addrb(P5_Dec_v_RAd),   // ( 4 DOWNTO 0);
.doutb(P5_Dec_v_RData)  // (95 DOWNTO 0)
);

//  L128_EncPk_DecSk_PolyVec M2(
// .clka(clk),
// .wea(S0_EncPk_DecSk_PolyVec_outready),
// .addra(S0_EncPk_DecSk_PolyVec_WAd),   // (  5 DOWNTO 0);
// .dina(S0_EncPk_DecSk_PolyVec_WData),  // (127 DOWNTO 0);
// .clkb(clk),
// .addrb(S2_EncPk_DecSk_PolyVec_RAd),
// .doutb(S2_EncPk_DecSk_PolyVec_RData) // (4095 DOWNTO 0)
// );

L128_AtG M3(
.clka(clk),
.wea(P5_Sub_DecMp_outready),
.addra(P5_Sub_DecMp_WAd),   // (  7 DOWNTO 0);
.dina(P5_Sub_DecMp_WData),  // (127 DOWNTO 0);
.clkb(clk),
.addrb(S4_Sub_DecMp_M2_RAd),   // (   2 DOWNTO 0);
.doutb(S4_Sub_DecMp_M2_RData)  // (4095 DOWNTO 0)
);

L128_INTT_Enc_BpV_DecMp M4(
.clka(clk),
.wea(S3_INTT_Enc_BpV_DecMp_outready),
.addra(S3_INTT_Enc_BpV_DecMp_WAd),   //(6 DOWNTO 0);
.dina(S3_INTT_Enc_BpV_DecMp_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(INTT_Enc_BpV_DecMp_RAd),//(6 DOWNTO 0);
.doutb(INTT_Enc_BpV_DecMp_RData)//(127 DOWNTO 0)
);

L96_Reduce_DecMp M5(
.clka(clk),
.wea(S4_Reduce_DecMp_outready),
.addra(S4_Reduce_DecMp_WAd),   //(4 DOWNTO 0);
.dina(S4_Reduce_DecMp_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(Reduce_DecMp_RAd),//(7 DOWNTO 0);
.doutb(Reduce_DecMp_RData)//(11 DOWNTO 0)
);

// L32_noise_r_PolyVec M6(
// .clka(clk),
// .wea(Sp_r_outready),
// .addra(Sp_r_WAd),   //(5 DOWNTO 0);
// .dina(Sp_r_WData), //(31 DOWNTO 0);
// .clkb(clk),
// .addrb(S1_Sp_r_RAd),//(0 DOWNTO 0);
// .doutb(S1_Sp_r_RData)//(1023 DOWNTO 0)
// );

// L32_noise_eG M7(
// .clka(clk),
// .wea(eG_outready),
// .addra(eG_WAd),   //(6 DOWNTO 0);
// .dina(eG_WData), //(31 DOWNTO 0);
// .clkb(clk),
// .addrb(P10_eG_RAd),//(6 DOWNTO 0);
// .doutb(P10_eG_RData)//(31 DOWNTO 0)
// );

// L96_Reduce_EncBp M8(
// .clka(clk),
// .wea(S4_Reduce_EncBp_outready),
// .addra(S4_Reduce_EncBp_WAd),   //(5 DOWNTO 0);
// .dina(S4_Reduce_EncBp_WData), //(95 DOWNTO 0);
// .clkb(clk),
// .addrb(P11_Reduce_EncBp_RAd),//(6 DOWNTO 0);
// .doutb(P11_Reduce_EncBp_RData)//(47 DOWNTO 0)
// );

// L96_Reduce_EncV M9(
// .clka(clk),
// .wea(S4_Reduce_EncV_outready),
// .addra(S4_Reduce_EncV_WAd),   //(4 DOWNTO 0);
// .dina(S4_Reduce_EncV_WData), //(95 DOWNTO 0);
// .clkb(clk),
// .addrb(P11_Reduce_EncV_RAd),//(4 DOWNTO 0);
// .doutb(P11_Reduce_EncV_RData)//(95 DOWNTO 0)
// );

//BRAM MUX
// Dec_decomp_NTT_BRAM_MUX MUX0(
// .cstate(cstate),
// .mux_enc_dec(mux_enc_dec),
// .P0_ct_outready(P0_ct_outready),
// .P0_ct_WAd(P0_ct_WAd),
// .P0_Bp_WData(P0_Bp_WData), 
// .P2_Bp_ct_RAd(P2_Bp_ct_RAd),
// .P2_NTT_Poly_0_outready(P2_NTT_Poly_0_outready),
// .P2_NTT_Poly_0_WAd(P2_NTT_Poly_0_WAd),
// .P2_NTT_Poly_0_WData(P2_NTT_Poly_0_WData),
// .P3_NTT_RAd(P3_NTT_Poly_0_RAd),
// .M0_WEN(M0_WEN),
// .M0_WAd(M0_WAd),
// .M0_WData(M0_WData),
// .M0_RAd(M0_RAd)
// );

// L12_k_MUX MUX1(
// .cstate(cstate),
// .mux_enc_dec(mux_enc_dec),
// .P0_Dec_V_outready(P0_Dec_V_outready),
// .P0_Dec_V_WAd(P0_Dec_V_WAd),
// .P0_Dec_V_WData(P0_Dec_V_WData),
// .P5_Dec_v_RAd(P5_Dec_v_RAd),
// .P8_out_ready(P8_out_ready),
// .P8_Poly_WAd(P8_Poly_WAd),
// .P8_WData(P8_WData),
// .P10_k_RAd(P10_Add_k_RAd), 
// .M1_WEN(M1_WEN),
// .M1_WAd(M1_WAd),
// .M1_WData(M1_WData),
// .M1_RAd(M1_RAd)
// );

// Dec_L128_BRAM_MUX MUX2(
// .cstate(cstate),
// .mux_enc_dec(mux_enc_dec),
// .P3_Enc_BpV_DecMp_outready(P3_Enc_BpV_DecMp_outready),
// .P3_Enc_BpV_DecMp_WAd(P3_Enc_BpV_DecMp_WAd),
// .P3_Enc_BpV_DecMp_WData(P3_Enc_BpV_DecMp_WData),      
// .PACC_EncBp_DecMp_Poly_RAd(PACC_EncBp_DecMp_Poly_RAd),
// .P5_Sub_DecMp_outready(Sub_EncBp_DecMp_outready),
// .P5_Sub_DecMp_WAd(Sub_EncBp_DecMp_WAd),
// .P5_Sub_DecMp_WData(Sub_EncBp_DecMp_WData),      
// .P6_Add_EncBpV_DecMp_RAd(Sub_EncBpV_DecMp_RAd),
// .P9_AtG_WEN(P9_AtG_WEN),
// .P9_AtG_WAd(P9_AtG_WAd),
// .P9_AtG_WData(P9_AtG_WData),
// .P3_M3_RAd(P3_M3_RAd),
// .P10_M3_WEN(P10_M3_WEN),
// .P10_M3_WAd(P10_M3_WAd),
// .P10_M3_WData(P10_M3_WData),       
// .M3_WEN(M3_WEN),
// .M3_WAd(M3_WAd),
// .M3_WData(M3_WData),
// .M3_RAd(M3_RAd)
// );

// Entity 
State_Decompressed_Ciphertext P0 (
.clk(clk),
.rst_n(rst_n),
.enable(P0_Unpack_Ciphertext_enable),
// .iSeed_Char(P0_iSeed_Char), // BUG: Not required in INDCPA
.i_CT(i_CT),
.Function_done(P0_Unpack_Ciphertext_done),
.Dec_Bp_outready(P0_Bp_outready),
.Dec_Bp_WAd(P0_Bp_WAd),        // [ 5 : 0]
.Dec_Bp_WData(P0_Bp_WData),    // [95 : 0]
.Dec_V_outready(P0_Dec_V_outready),
.Dec_V_WAd(P0_Dec_V_WAd),            // [ 7 : 0]
.Dec_V_WData(P0_Dec_V_WData)         // [11 : 0]
);

// State_Unpack P1(
// .clk(clk),
// .rst_n(rst_n),
// .enable(Unpack_enable),
// .mux_enc_dec(mux_enc_dec),
// .ipackedpk(Packed_pk),
// .ipackedsk(Packed_sk),
// .Function_Done(Unpack_done),
// .EncPk_DecSk_PolyVec_outready(P1_EncPk_DecSk_PolyVec_outready),
// .EncPk_DecSk_PolyVec_WAd(P1_EncPk_DecSk_PolyVec_WAd), //[5:0]
// .EncPk_DecSk_PolyVec_WData(P1_EncPk_DecSk_PolyVec_WData) //[127 : 0]
// );	

// State_ntt P2(
// .clk(clk),
// .rst_n(rst_n),
// .enable(NTT_enable),
// .mux_enc_dec(mux_enc_dec),
// .Sp_r_RData(P2_Sp_r_RData),
// .Bp_ct_RData(M0_RData),
// .Sp_r_RAd(P2_Sp_r_RAd),
// .Bp_ct_RAd(P2_Bp_ct_RAd),
// .Function_done(NTT_done),
// .NTT_Poly_0_outready(P2_NTT_Poly_0_outready),
// .NTT_Poly_0_WAd(P2_NTT_Poly_0_WAd),
// .NTT_Poly_0_WData(P2_NTT_Poly_0_WData)
// );

// State_PAcc P3(
// .clk(clk),
// .rst_n(rst_n),
// .enable(PAcc_enable),
// .mux_enc_dec(mux_enc_dec),//enc0,dec1
// .NTT_Poly_0_RData(M0_RData),
// .EncPk_DecSk_PolyVec_RData(P3_EncPk_DecSk_PolyVec_RData),
// .AtG_RData(M3_RData),
// .NTT_Poly_0_RAd(P3_NTT_Poly_0_RAd),
// .EncPk_DecSk_PolyVec_RAd(P3_EncPk_DecSk_PolyVec_RAd),
// .AtG_RAd(P3_M3_RAd),
// .Function_done(PAcc_done),
// .Enc_BpV_DecMp_outready(P3_Enc_BpV_DecMp_outready),
// .Enc_BpV_DecMp_WAd(P3_Enc_BpV_DecMp_WAd),
// .Enc_BpV_DecMp_WData(P3_Enc_BpV_DecMp_WData)
// );

// State_Invntt P4(
// .clk(clk),		
// .rst_n(rst_n),
// .enable(INTT_enable),
// .mux_enc_dec(mux_enc_dec), // enc0, dec1	
// .PACC_EncBp_DecMp_Poly_RData(M3_RData),
// .PACC_EncBp_DecMp_Poly_RAd(PACC_EncBp_DecMp_Poly_RAd),
// .Function_done(INTT_done),
// .INTT_Enc_BpV_DecMp_outready(INTT_Enc_BpV_DecMp_outready),
// .INTT_Enc_BpV_DecMp_WAd(INTT_Enc_BpV_DecMp_WAd),
// .INTT_Enc_BpV_DecMp_WData(INTT_Enc_BpV_DecMp_WData)
// );

State_Poly_Sub P5(
.clk(clk),
.rst_n(rst_n),
.enable(P5_Sub_enable),
.INTT_Enc_BpV_DecMp_RData(INTT_Enc_BpV_DecMp_RData),
.Dec_v_RData(P5_Dec_v_RData),
.INTT_Enc_BpV_DecMp_RAd(INTT_Enc_BpV_DecMp_RAd),
.Dec_v_RAd(P5_Dec_v_RAd),
.Function_done(P5_Sub_done),
.Sub_EncBp_DecMp_outready(P5_Sub_DecMp_outready),
.Sub_EncBp_DecMp_WAd(P5_Sub_DecMp_WAd),     // [  7 : 0]
.Sub_EncBp_DecMp_WData(P5_Sub_DecMp_WData)  // [127 : 0]
);

// State_Reduce P6(
// .clk(clk),		
// .rst_n(rst_n),
// .enable(Reduce_enable),
// .mux_enc_dec(mux_enc_dec),//enc0,dec1	 	
// .Add_EncBpV_DecMp_RData(M3_RData),
// .Add_EncBpV_DecMp_RAd(Sub_EncBpV_DecMp_RAd),
// .Function_done(Reduce_done),
// .Reduce_DecMp_outready(Reduce_DecMp_outready),
// .Reduce_DecMp_WAd(Reduce_DecMp_WAd),
// .Reduce_DecMp_WData(Reduce_DecMp_WData),
// .Reduce_EncBp_outready(Reduce_EncBp_outready),
// .Reduce_EncBp_WAd(Reduce_EncBp_WAd),
// .Reduce_EncBp_WData(Reduce_EncBp_WData),
// .Reduce_EncV_outready(Reduce_EncV_outready),
// .Reduce_EncV_WAd(Reduce_EncV_WAd),
// .Reduce_EncV_WData(Reduce_EncV_WData)
// );

State_Polytomsg P7(
.clk(clk),		
.rst_n(rst_n),
.enable(P7_Poly_ToMsg_enable),
.Reduce_DecMp_RAd(Reduce_DecMp_RAd),
.Reduce_DecMp_RData(Reduce_DecMp_RData),
.Function_done(P7_Poly_ToMsg_done),
.oMsg(o_Msg)		
);

// State_Poly_frommsg P8(
// .clk(clk),
// .rst_n(rst_n),
// .enable(From_Msg_enable),
// .iMsg_byte_array(oMsg),
// .out_ready(P8_out_ready),
// .Function_Done(From_Msg_done),
// .Poly_Ad(P8_Poly_WAd),
// .Poly_Data(P8_WData)
// );	

// State_Hash P9(
// .clk(clk),
// .rst_n(rst_n),
// .enable(Hash_enable),
// .iSeed(ENC_Seed_Char),
// .iCoins(i_Coins),
// .Function_done(Hash_Done),
// .AtG_outready(P9_AtG_WEN),
// .AtG_WAd(P9_AtG_WAd),
// .AtG_WData(P9_AtG_WData),
// .Sp_r_outready(Sp_r_outready),
// .Sp_r_WAd(Sp_r_WAd),
// .Sp_r_WData(Sp_r_WData),
// .eG_outready(eG_outready),
// .eG_WAd(eG_WAd),
// .eG_WData(eG_WData)
// );

// State_Add P10(
// .clk(clk),		
// .rst_n(rst_n),
// .enable(Add_enable),	
// .INTT_Enc_BpV_DecMp_RData(INTT_Enc_BpV_DecMp_RData),
// .eG_RData(P10_eG_RData),
// .k_RData(M1_RData),
// .INTT_Enc_BpV_DecMp_RAd(INTT_Enc_BpV_RAd),
// .eG_RAd(P10_eG_RAd),
// .k_RAd(P10_Add_k_RAd),
// .Function_done(Add_done),
// .Add_EncBp_DecMp_outready(P10_M3_WEN),
// .Add_EncBp_DecMp_WAd(P10_M3_WAd),
// .Add_EncBp_DecMp_WData(P10_M3_WData)
// );
                     
// State_Pack_Cit P11(
// .clk(clk),		
// .rst_n(rst_n),
// .enable(Pack_enable),	
// .Reduce_EncBp_RData(P11_Reduce_EncBp_RData),
// .Reduce_EncV_RData(P11_Reduce_EncV_RData),
// .Reduce_EncBp_RAd(P11_Reduce_EncBp_RAd),
// .Reduce_EncV_RAd(P11_Reduce_EncV_RAd),
// .Function_done(Pack_done),
// .o_Ciphertext0_0(P11_o_Ciphertext0_0),
// .o_Ciphertext0_1(P11_o_Ciphertext0_1),
// .o_Ciphertext1(P11_o_Ciphertext1)
// );

endmodule
