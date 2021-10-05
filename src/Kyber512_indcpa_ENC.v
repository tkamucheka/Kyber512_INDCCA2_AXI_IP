//////////////////////////////////////////////////////////////////////////////////
// Module Name: Kyber512_indcpa_ENC
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

//Entity
module Kyber512_indcpa_ENC#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter KYBER_512_PKBytes = 800,
  parameter Msg_Bytes = 32,
  parameter Coins_Bytes = 32,
  parameter Ciphertext_Bytes = 736,
  parameter Seed_Bytes = 32,
  parameter data_Width_0 = 12,
  parameter data_Width_1 = 16,
  parameter data_Width_2 = 4,
  parameter Byte_bits = 8,
  parameter Poly_Size_12 = data_Width_0 * KYBER_N,
  parameter Poly_Size_16 = data_Width_1 * KYBER_N,
  parameter Poly_Size_4 = data_Width_2 * KYBER_N,  
  parameter Seed_Char_Size = Byte_bits * Seed_Bytes,  
  parameter KYBER_512_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter i_PK_Size = Byte_bits * KYBER_512_PKBytes,
  parameter i_Msg_Size = Byte_bits * Msg_Bytes,
  parameter i_Coins_Size = Byte_bits * Coins_Bytes,
  parameter o_Ciphertext_Size =  Byte_bits * Ciphertext_Bytes
)(
  input                             clk,    
  input                             rst_n,
  input                             enable,
  input                             mux_enc_dec,  
  // input  [i_PK_Size-1 : 0]          i_PK,
  input  [i_Msg_Size-1 : 0]         i_Msg,
  input  [i_Coins_Size-1 : 0]       i_Coins,
  input  [Seed_Char_Size-1:0]       i_Seed,
  output reg                        Encryption_Done,
  output reg [o_Ciphertext_Size -1 : 0] o_Ciphertext,
  // DEBUG:
  // State
  //  output [3:0] state,
  // State_Unpack
  // output [127:0] unpackedpk_debug,
  // output [255:0] seed_debug,
  // State_Poly_frommsg
  // output [191:0] msgpoly_debug,
  // State_Hash
  // output [1023:0] At_debug,
  // output [255:0] Sp_debug,
  // output [255:0] eG_debug
  // State ntt
  //  output [4095:0] ntt_debug,
  // PACC
  //  output [1023:0] Bp_debug,
  //  output [511:0] V_debug,
  //  output [255:0] reduceV_debug,
  //  output [255:0] reduceBp_debug
  output reg trigger,
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
  output [1023:0] S1_Sp_r_RData,
  input           S1_Sp_r_RAd,
  input           S1_NTT_done,
  // input           S1_NTT_Poly_0_outready,
  // input [5:0]     S1_NTT_Poly_0_WAd,
  // input [95:0]    S1_NTT_Poly_0_WData,
  // --------------------------------------
  // S2: PAcc
  output reg      S2_PAcc_enable,
  // output [3071:0] S2_NTT_Poly_0_RData,
  // output [4095:0] S2_EncPk_DecSk_PolyVec_RData,
  // output [4095:0] S2_M2_AtG_RData,
  // input           S2_NTT_Poly_0_RAd,
  // input           S2_EncPk_DecSk_PolyVec_RAd,     
  // input [2:0]     S2_M2_AtG_RAd,
  input           S2_PAcc_done,
  // input           S2_Enc_BpV_DecMp_M2_outready,
  // input [7:0]     S2_Enc_BpV_DecMp_M2_WAd,
  // input [127:0]   S2_Enc_BpV_DecMp_M2_WData,
  // --------------------------------------
  // S3: INTT
  output reg      S3_INTT_enable,
  // output [4095:0] S3_PACC_EncBp_DecMp_Poly_M2_RData,
  // input [2:0]     S3_PACC_EncBp_DecMp_Poly_M2_RAd,
  input           S3_INTT_done,
  input           S3_INTT_Enc_BpV_DecMp_outready,
  input [6:0]     S3_INTT_Enc_BpV_DecMp_WAd,
  input [127:0]   S3_INTT_Enc_BpV_DecMp_WData,
  // --------------------------------------
  // S4: REDUCE
  output reg      S4_Reduce_enable,  
  output [4095:0] S4_Add_EncBpV_M2_RData,
  input [2:0]     S4_Add_EncBpV_M2_RAd,
  input           S4_Reduce_done,
  // input           S4_Reduce_DecMp_outready,
  // input [4:0]     S4_Reduce_DecMp_WAd,
  // input [95:0]    S4_Reduce_DecMp_WData,
  input           S4_Reduce_EncBp_outready,
  input [5:0]     S4_Reduce_EncBp_WAd,
  input [95:0]    S4_Reduce_EncBp_WData,
  input           S4_Reduce_EncV_outready,
  input [4:0]     S4_Reduce_EncV_WAd,
  input [95:0]    S4_Reduce_EncV_WData,
  // --------------------------------------
  // SHARED M2 DATA
  output [3:0]    o_cstate,
  output [0:0]    P2_AtG_outready,
  output [7:0]    P2_AtG_M2_WAd,
  output [127:0]  P2_AtG_M2_WData
  // output [0:0]    P6_Add_EncBp_outready,
  // output [7:0]    P6_Add_EncBp_WAd,
  // output [127:0]  P6_Add_EncBp_WData
  // output [0:0]    SHARED_MEM_outready,
  // output [7:0]    SHARED_MEM_WAd,
  // output [127:0]  SHARED_MEM_WData,
  // output [4095:0] SHARED_M2_RData
);

// reg Encryption_Done_R;
// assign Encryption_Done = Encryption_Done_R;

// BRAM
// wire [0 : 0]    M2_WEN;
// wire [7 : 0]    M2_WAd;   //(7 DOWNTO 0);
// wire [127 : 0]  M2_WData; //(127 DOWNTO 0);
// wire [2 : 0]    M2_RAd;   //(2 DOWNTO 0);
// wire [4095 : 0] M2_RData; //(4095 DOWNTO 0)

// Entity
// reg  P0_Unpack_pk_enable;
// wire P0_EncPk_DecSk_PolyVec_outready; 
// wire P0_Unpack_pk_done;
// wire [5 : 0] P0_EncPk_DecSk_PolyVec_WAd;
// wire [128-1 : 0] P0_EncPk_DecSk_PolyVec_WData;

// Bug: Must be lower bits not higher bits
// wire [Seed_Char_Size-1 : 0] Seed_Char = i_PK[i_PK_Size-1 -: Seed_Char_Size];
// wire [Seed_Char_Size-1 : 0] Seed_Char = i_PK[Seed_Char_Size-1 : 0];

// DEBUG:
// assign seed_debug = Seed_Char; 

reg  P1_Poly_frommsg_enable;
wire P1_Poly_frommsg_done;
wire P1_out_ready;
wire [7 : 0] P0_Poly_Ad;
wire [11 : 0] P0_Poly_Data;
     
reg  P2_Hash_enable;  
wire P2_Hash_done;
// wire [0 : 0] P2_AtG_WEN;
// wire [7 : 0] P2_AtG_M2_WAd;
// wire [128-1 : 0] P2_AtG_M2_WData;
wire [0 : 0] Sp_r_outready;
wire [5 : 0] Sp_r_WAd;
wire [32-1 : 0] Sp_r_WData;
wire [0 : 0] eG_outready;
wire [6 : 0] eG_WAd;
wire [32-1 : 0] eG_WData;

// reg  P3_ntt_enable;
// wire [1024-1 : 0] P3_Sp_r_RData;
// wire [0 : 0] P3_Sp_r_RAd;
// wire P3_ntt_done;
// wire [0 : 0] P3_NTT_Poly_0_outready;
// wire [5 : 0] P3_NTT_Poly_0_WAd;
// wire [96-1 : 0] P3_NTT_Poly_0_WData;

// reg  P4_PAcc_enable;
// wire P4_PAcc_done;
// wire P4_M2_WEN;
// wire [7 : 0] P4_M2_WAd;
// wire [127 : 0] P4_M2_WData;
// wire [2 : 0] P4_M2_RAd;
// wire [3072-1 : 0] P4_NTT_Poly_0_RData;
// wire [4096-1 : 0] P4_EncPk_DecSk_PolyVec_RData;
// wire [0 : 0] P4_NTT_Poly_0_RAd;
// wire [0 : 0] P4_EncPk_DecSk_PolyVec_RAd;

// reg  P5_Invntt_enable;
// wire P5_Invntt_done;
// wire [2 : 0] P5_M2_RAd;
// wire [0 : 0] INTT_Enc_BpV_DecMp_outready;
// wire [6 : 0] INTT_Enc_BpV_DecMp_WAd;
// wire [128-1 : 0] INTT_Enc_BpV_DecMp_WData; 

reg  P6_Add_enable;
wire P6_Add_done;
wire [128-1 : 0] P6_INTT_Enc_BpV_DecMp_RData;
wire [32-1 : 0] P6_eG_RData;
wire [96-1 : 0] P6_k_RData;
wire [6 : 0] P6_INTT_Enc_BpV_DecMp_RAd;
wire [6 : 0] P6_eG_RAd;
wire [4 : 0] P6_k_RAd;
wire [0:0]    P6_Add_EncBp_outready;
wire [7:0]    P6_Add_EncBp_WAd;
wire [127:0]  P6_Add_EncBp_WData;
// wire P6_M2_WEN;
// wire [7 : 0] P6_M2_WAd;
// wire [127 : 0] P6_M2_WData;
 
// reg  P7_Reduce_enable;
// wire P7_Reduce_done;
// wire [2 : 0] P7_M2_RAd;
// wire [0 : 0] Reduce_EncBp_outready;
// wire [5 : 0] Reduce_EncBp_WAd;
// wire [96-1 : 0] Reduce_EncBp_WData;
// wire [0 : 0] Reduce_EncV_outready;
// wire [4 : 0] Reduce_EncV_WAd;
// wire [96-1 : 0] Reduce_EncV_WData;

reg  P8_Pack_Cit_enable;  
wire P8_Pack_Cit_done;
wire [48-1 : 0] P8_Reduce_EncBp_RData;
wire [96-1 : 0] P8_Reduce_EncV_RData;
wire [6 : 0] P8_Reduce_EncBp_RAd;
wire [4 : 0] P8_Reduce_EncV_RAd;
wire [2560-1 : 0] P8_o_Ciphertext0_0;
wire [2560-1 : 0] P8_o_Ciphertext0_1;
wire [768-1 : 0] P8_o_Ciphertext1;

reg dirty;

// BUG: reversed construction
// assign o_Ciphertext = {P8_o_Ciphertext1,P8_o_Ciphertext0_1,P8_o_Ciphertext0_0};
// assign o_Ciphertext = {P8_o_Ciphertext0_0,P8_o_Ciphertext0_1,P8_o_Ciphertext1};

reg [3:0] cstate,nstate;
localparam IDLE   = 4'd0;
localparam Unpack = 4'd1;
localparam Hash   = 4'd2;
localparam NTT    = 4'd3;
localparam PAcc   = 4'd4;
localparam INTT   = 4'd5;
localparam Add    = 4'd6;
localparam Reduce = 4'd7;
localparam Pack   = 4'd8;

assign o_cstate = cstate;

// systhesis translate_off
integer cycles = 0;
reg enable_enc_counter = 0;
always @(posedge clk) begin
  if (enable_enc_counter) 
    cycles <= cycles + 1;
end
// sythesis translate_on

always @(posedge clk or negedge rst_n)
  if(!rst_n) cstate <= IDLE;
  else       cstate <= nstate;
  
always @(cstate or enable or P1_Poly_frommsg_done or P2_Hash_done or S1_NTT_done
or S2_PAcc_done or S3_INTT_done or P6_Add_done or S4_Reduce_done or P8_Pack_Cit_done)
begin       
  case(cstate)
    IDLE:   if (enable && !dirty)     nstate = Unpack;
            else                      nstate = IDLE;
    Unpack: if (P1_Poly_frommsg_done) nstate = Hash;           
            else                      nstate = Unpack;
    Hash:   if (P2_Hash_done)         nstate = NTT;
            else                      nstate = Hash;
    NTT:    if (S1_NTT_done)          nstate = PAcc;
            else                      nstate = NTT;
    PAcc:   if (S2_PAcc_done)         nstate = INTT;           
            else                      nstate = PAcc;    
    INTT:   if (S3_INTT_done)         nstate = Add;
            else                      nstate = INTT;
    Add:    if (P6_Add_done)          nstate = Reduce;
            else                      nstate = Add;
    Reduce: if (S4_Reduce_done)       nstate = Pack;
            else                      nstate = Reduce;
    Pack:   if (P8_Pack_Cit_done)     nstate = IDLE;           
            else                      nstate = Pack;          
    default:                          nstate = IDLE;
  endcase
end

// BUG: 
always @(posedge clk)
  if(!rst_n) begin
    Encryption_Done         <= 1'b0;
    // P0_Unpack_pk_enable     <= 1'b0;
    S0_Unpack_enable        <= 1'b0;
    P1_Poly_frommsg_enable  <= 1'b0;
    P2_Hash_enable          <= 1'b0;
    // P3_ntt_enable           <= 1'b0;
    S1_NTT_enable           <= 1'b0;
    // P4_PAcc_enable          <= 1'b0;
    S2_PAcc_enable          <= 1'b0;
    // P5_Invntt_enable        <= 1'b0;
    S3_INTT_enable          <= 1'b0;
    P6_Add_enable           <= 1'b0;
    // P7_Reduce_enable        <= 1'b0;
    S4_Reduce_enable        <= 1'b0;
    P8_Pack_Cit_enable      <= 1'b0;
    dirty                   <= 1'b0;
    trigger <= 1'b0;
  end else begin
    case({cstate,nstate})
      {IDLE,IDLE}: begin
          // Encryption_Done_R    <= Encryption_Done_R;
          Encryption_Done         <= 1'b0;
        end
      {IDLE,Unpack}:  begin
          dirty                   <= 1'b1;
          Encryption_Done         <= 1'b0;
          // P0_Unpack_pk_enable     <= 1'b1;
          S0_Unpack_enable        <= 1'b1;
          P1_Poly_frommsg_enable  <= 1'b1;
          trigger <= 1'b1;

          // systhesis translate_off
          enable_enc_counter      <= 1'b1;
          // synthesis translate_on 
        end       
      {Unpack,Unpack}: begin
          // P0_Unpack_pk_enable     <= 1'b0;
          S0_Unpack_enable        <= 1'b0;
          P1_Poly_frommsg_enable  <= 1'b0;
        end         
      {Unpack,Hash}: begin
          P2_Hash_enable      <= 1'b1;
        end
      {Hash,Hash}: begin
          P2_Hash_enable      <= 1'b0;
        end
      {Hash,NTT}: begin
          // P3_ntt_enable       <= 1'b1;
          S1_NTT_enable       <= 1'b1;
        end                              
      {NTT,NTT}: begin
          // P3_ntt_enable       <= 1'b0;
          S1_NTT_enable       <= 1'b0;
        end 
      {NTT,PAcc}: begin
          // P4_PAcc_enable      <= 1'b1;
          S2_PAcc_enable      <= 1'b1;
        end 
      {PAcc,PAcc}: begin
          // P4_PAcc_enable      <= 1'b0;
          S2_PAcc_enable      <= 1'b0;
        end
      {PAcc,INTT}: begin
          // P5_Invntt_enable    <= 1'b1;
          S3_INTT_enable      <= 1'b1;
        end 
      {INTT,INTT}: begin
          // P5_Invntt_enable    <= 1'b0;
          S3_INTT_enable      <= 1'b0;
        end
      {INTT,Add}: begin
          P6_Add_enable       <= 1'b1;
        end
      {Add,Add}: begin
          P6_Add_enable       <= 1'b0;
        end 
      {Add,Reduce}: begin
          // P7_Reduce_enable    <= 1'b1;
          S4_Reduce_enable    <= 1'b1;
        end 
      {Reduce,Reduce}: begin
          // P7_Reduce_enable    <= 1'b0;
          S4_Reduce_enable    <= 1'b0;
        end
      {Reduce,Pack}: begin
          P8_Pack_Cit_enable  <= 1'b1;
        end
      {Pack,Pack}: begin
          P8_Pack_Cit_enable  <= 1'b0;
        end
      {Pack,IDLE}: begin
          Encryption_Done    <= 1'b1;
          o_Ciphertext       <= { P8_o_Ciphertext0_0, P8_o_Ciphertext0_1, P8_o_Ciphertext1 };
          trigger            <= 1'b0;

          // systhesis translate_off
          enable_enc_counter <= 1'b0;
          // synthesis translate_on 
        end
      default: ;
    endcase
  end


//BRAM

// L128_EncPk_DecSk_PolyVec M0(
// .clka(clk),
// .wea(S0_EncPk_DecSk_PolyVec_outready),
// .addra(S0_EncPk_DecSk_PolyVec_WAd),   //(5 DOWNTO 0);
// .dina(S0_EncPk_DecSk_PolyVec_WData), //(127 DOWNTO 0);
// .clkb(clk),
// .addrb(S2_EncPk_DecSk_PolyVec_RAd),
// .doutb(S2_EncPk_DecSk_PolyVec_RData)//(4095 DOWNTO 0)
// );

L12_k M1(
.clka(clk),
.wea(P1_out_ready),
.addra(P0_Poly_Ad),   //(7 DOWNTO 0);
.dina(P0_Poly_Data), //(11 DOWNTO 0);
.clkb(clk),
.addrb(P6_k_RAd),//(4 DOWNTO 0);
.doutb(P6_k_RData)//(95 DOWNTO 0)
);

L128_AtG M2(
.clka(clk),
.wea(P6_Add_EncBp_outready),
.addra(P6_Add_EncBp_WAd),       // (   7 DOWNTO 0)
.dina(P6_Add_EncBp_WData),      // ( 127 DOWNTO 0)
.clkb(clk),
.addrb(S4_Add_EncBpV_M2_RAd),   // (   2 DOWNTO 0)
.doutb(S4_Add_EncBpV_M2_RData)  // (4095 DOWNTO 0)
);

L32_noise_r_PolyVec M3(
.clka(clk),
.wea(Sp_r_outready),
.addra(Sp_r_WAd),   //(5 DOWNTO 0);
.dina(Sp_r_WData), //(31 DOWNTO 0);
.clkb(clk),
.addrb(S1_Sp_r_RAd),//(0 DOWNTO 0);
.doutb(S1_Sp_r_RData)//(1023 DOWNTO 0)
);

L32_noise_eG M4(
.clka(clk),
.wea(eG_outready),
.addra(eG_WAd),   //(6 DOWNTO 0);
.dina(eG_WData), //(31 DOWNTO 0);
.clkb(clk),
.addrb(P6_eG_RAd),//(6 DOWNTO 0);
.doutb(P6_eG_RData)//(31 DOWNTO 0)
);

// L96_NTT_Poly_0 M5(
// .clka(clk),
// .wea(S1_NTT_Poly_0_outready),
// .addra(S1_NTT_Poly_0_WAd),  //(5 DOWNTO 0);
// .dina(S1_NTT_Poly_0_WData), //(95 DOWNTO 0);
// .clkb(clk),
// .addrb(S2_NTT_Poly_0_RAd),  //(0 DOWNTO 0);
// .doutb(S2_NTT_Poly_0_RData) //(3071 DOWNTO 0)
// );

L128_INTT_Enc_BpV_DecMp M6(
.clka(clk),
.wea(S3_INTT_Enc_BpV_DecMp_outready),
.addra(S3_INTT_Enc_BpV_DecMp_WAd),   //(6 DOWNTO 0);
.dina(S3_INTT_Enc_BpV_DecMp_WData), //(127 DOWNTO 0);
.clkb(clk),
.addrb(P6_INTT_Enc_BpV_DecMp_RAd),//(6 DOWNTO 0);
.doutb(P6_INTT_Enc_BpV_DecMp_RData)//(127 DOWNTO 0)
);

L96_Reduce_EncBp M7(
.clka(clk),
.wea(S4_Reduce_EncBp_outready),
.addra(S4_Reduce_EncBp_WAd),   //(5 DOWNTO 0);
.dina(S4_Reduce_EncBp_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(P8_Reduce_EncBp_RAd),//(6 DOWNTO 0);
.doutb(P8_Reduce_EncBp_RData)//(47 DOWNTO 0)
);

L96_Reduce_EncV M8(
.clka(clk),
.wea(S4_Reduce_EncV_outready),
.addra(S4_Reduce_EncV_WAd),   //(4 DOWNTO 0);
.dina(S4_Reduce_EncV_WData), //(95 DOWNTO 0);
.clkb(clk),
.addrb(P8_Reduce_EncV_RAd),//(4 DOWNTO 0);
.doutb(P8_Reduce_EncV_RData)//(95 DOWNTO 0)
);

// BRAM_MUX mux0(
// .cstate(cstate),
// .P2_AtG_WEN(P2_AtG_WEN),
// .P2_AtG_M2_WAd(P2_AtG_M2_WAd),
// .P2_AtG_M2_WData(P2_AtG_M2_WData),      
// .P4_M2_WEN(S2_Enc_BpV_DecMp_M2_outready),
// .P4_M2_WAd(S2_Enc_BpV_DecMp_M2_WAd),
// .P4_M2_WData(S2_Enc_BpV_DecMp_M2_WData),
// .P4_M2_RAd(S2_M2_AtG_RAd),
// .P5_M2_RAd(S3_PACC_EncBp_DecMp_Poly_M2_RAd),
// .P6_M2_WEN(P6_M2_WEN),
// .P6_M2_WAd(P6_M2_WAd),
// .P6_M2_WData(P6_M2_WData),
// .P7_M2_RAd(S4_Add_EncBpV_DecMp_M2_RAd),       
// .M2_WEN(M2_WEN),
// .M2_WAd(M2_WAd),
// .M2_WData(M2_WData),
// .M2_RAd(M2_RAd)
// );

// ENC_M2_BRAM_MUX mux0 (
//   .cstate(cstate),
//   .P2_AtG_outready(P2_AtG_outready),
//   .P2_AtG_M2_WAd(P2_AtG_M2_WAd),
//   .P2_AtG_M2_WData(P2_AtG_M2_WData),
//   .S4_Add_EncBpV_M2_RAd(S4_Add_EncBpV_M2_RAd),
//   .S4_Add_EncBpV_M2_RData(S4_Add_EncBpV_M2_RData),
//   .M2_WEN(),
//   .M2_WAd(),
//   .M2_WData(),
//   .M2_RAd(M2_RAd)
// );

//Entity
// State_Unpack P0(
// .clk(clk),
// .rst_n(rst_n),
// .enable(P0_Unpack_pk_enable),
// .mux_enc_dec(mux_enc_dec),  
// .ipackedpk(i_PK),
// .ipackedsk(),
// .Function_Done(P0_Unpack_pk_done),
// .EncPk_DecSk_PolyVec_outready(P0_EncPk_DecSk_PolyVec_outready),
// .EncPk_DecSk_PolyVec_WAd(P0_EncPk_DecSk_PolyVec_WAd),
// .EncPk_DecSk_PolyVec_WData(P0_EncPk_DecSk_PolyVec_WData)
// // DEBUG: PASS
// // .unpackedpk_debug(unpackedpk_debug)
// );
   
State_Poly_frommsg P1(
.clk(clk),
.rst_n(rst_n),
.enable(P1_Poly_frommsg_enable),
.iMsg_byte_array(i_Msg),
.out_ready(P1_out_ready),
.Function_Done(P1_Poly_frommsg_done),
.Poly_Ad(P0_Poly_Ad),
.Poly_Data(P0_Poly_Data)
// DEBUG:
// .msgpoly_debug(msgpoly_debug)
);

State_Hash P2(
.clk(clk),  
.rst_n(rst_n),
.enable(P2_Hash_enable),  
.iSeed(i_Seed),
.iCoins(i_Coins),
.Function_done(P2_Hash_done),
.AtG_outready(P2_AtG_outready),     // (P2_AtG_WEN),
.AtG_WAd(P2_AtG_M2_WAd),       // (P2_AtG_M2_WAd),
.AtG_WData(P2_AtG_M2_WData),   // (P2_AtG_M2_WData),
.Sp_r_outready(Sp_r_outready),
.Sp_r_WAd(Sp_r_WAd),
.Sp_r_WData(Sp_r_WData),
.eG_outready(eG_outready),
.eG_WAd(eG_WAd),
.eG_WData(eG_WData)
// DEBUG
// .At_debug(At_debug),
// .Sp_debug(Sp_debug),
// .eG_debug(eG_debug)
);

// State_ntt P3(
// .clk(clk),    
// .rst_n(rst_n),
// .enable(P3_ntt_enable),
// .mux_enc_dec(mux_enc_dec),
// .Sp_r_RData(P3_Sp_r_RData),
// .Bp_ct_RData(), 
// .Sp_r_RAd(P3_Sp_r_RAd),
// .Bp_ct_RAd(),
// .Function_done(P3_ntt_done),
// .NTT_Poly_0_outready(P3_NTT_Poly_0_outready),
// .NTT_Poly_0_WAd(P3_NTT_Poly_0_WAd),
// .NTT_Poly_0_WData(P3_NTT_Poly_0_WData),
// // debug:
// .trigger(trigger)
// );

// // NTT_dump DUT(
// //   .clk(clk),
// //   .reset_n(rst_n),
// //   .enable(P4_PAcc_enable),
// //   .Coef_RAd(P4_NTT_Poly_0_RAd),
// //   .Coef_RData(P4_NTT_Poly_0_RData),
// //   .ntt_debug(ntt_debug),
// //   .done(P4_PAcc_done)
// // );

// State_PAcc P4(
// .clk(clk),    
// .rst_n(rst_n),
// .enable(P4_PAcc_enable),
// // .enable(enable),
// .mux_enc_dec(mux_enc_dec),//enc0,dec1 
// .NTT_Poly_0_RData(P4_NTT_Poly_0_RData),
// .EncPk_DecSk_PolyVec_RData(P4_EncPk_DecSk_PolyVec_RData),
// .AtG_RData(M2_RData),
// .NTT_Poly_0_RAd(P4_NTT_Poly_0_RAd),
// .EncPk_DecSk_PolyVec_RAd(P4_EncPk_DecSk_PolyVec_RAd),     
// .AtG_RAd(P4_M2_RAd),
// .Function_done(P4_PAcc_done),
// // .Function_done(Encryption_Done),
// .Enc_BpV_DecMp_outready(P4_M2_WEN),
// .Enc_BpV_DecMp_WAd(P4_M2_WAd),
// .Enc_BpV_DecMp_WData(P4_M2_WData)
// // DEBUG
// // .Bp_debug(Bp_debug),
// // .V_debug(V_debug)
// );

// State_Invntt P5(
// .clk(clk),    
// .rst_n(rst_n),
// .enable(P5_Invntt_enable),
// .mux_enc_dec(mux_enc_dec), // enc0, dec1  
// .PACC_EncBp_DecMp_Poly_RData(M2_RData),
// .PACC_EncBp_DecMp_Poly_RAd(P5_M2_RAd),
// .Function_done(P5_Invntt_done),
// .INTT_Enc_BpV_DecMp_outready(INTT_Enc_BpV_DecMp_outready),
// .INTT_Enc_BpV_DecMp_WAd(INTT_Enc_BpV_DecMp_WAd),
// .INTT_Enc_BpV_DecMp_WData(INTT_Enc_BpV_DecMp_WData)
// // DEBUG
// // .Bp_debug(Bp_debug),
// // .V_debug(V_debug)
// );

State_Add P6(
.clk(clk),    
.rst_n(rst_n),
.enable(P6_Add_enable), 
.INTT_Enc_BpV_DecMp_RData(P6_INTT_Enc_BpV_DecMp_RData),
.eG_RData(P6_eG_RData),
.k_RData(P6_k_RData),
.INTT_Enc_BpV_DecMp_RAd(P6_INTT_Enc_BpV_DecMp_RAd),
.eG_RAd(P6_eG_RAd),
.k_RAd(P6_k_RAd),
.Function_done(P6_Add_done),
.Add_EncBp_DecMp_outready(P6_Add_EncBp_outready),
.Add_EncBp_DecMp_WAd(P6_Add_EncBp_WAd),
.Add_EncBp_DecMp_WData(P6_Add_EncBp_WData)
);

// State_Reduce P7(
// .clk(clk),    
// .rst_n(rst_n),
// .enable(P7_Reduce_enable),
// .mux_enc_dec(mux_enc_dec),//enc0,dec1   
// .Add_EncBpV_DecMp_RData(M2_RData),
// .Add_EncBpV_DecMp_RAd(P7_M2_RAd),
// .Function_done(P7_Reduce_done),
// .Reduce_DecMp_outready(),
// .Reduce_DecMp_WAd(),
// .Reduce_DecMp_WData(),
// .Reduce_EncBp_outready(Reduce_EncBp_outready),
// .Reduce_EncBp_WAd(Reduce_EncBp_WAd),
// .Reduce_EncBp_WData(Reduce_EncBp_WData),
// .Reduce_EncV_outready(Reduce_EncV_outready),
// .Reduce_EncV_WAd(Reduce_EncV_WAd),
// .Reduce_EncV_WData(Reduce_EncV_WData)
// // DEBUG: out
// // .reduceV_debug(reduceV_debug),
// // .reduceBp_debug(reduceBp_debug)
// );

State_Pack_Cit P8(
.clk(clk),
.rst_n(rst_n),
.enable(P8_Pack_Cit_enable),
.Reduce_EncBp_RData(P8_Reduce_EncBp_RData),
.Reduce_EncV_RData(P8_Reduce_EncV_RData),
.Reduce_EncBp_RAd(P8_Reduce_EncBp_RAd),
.Reduce_EncV_RAd(P8_Reduce_EncV_RAd),
.Function_done(P8_Pack_Cit_done),
.o_Ciphertext0_0(P8_o_Ciphertext0_0),
.o_Ciphertext0_1(P8_o_Ciphertext0_1),
.o_Ciphertext1(P8_o_Ciphertext1)
);

endmodule
