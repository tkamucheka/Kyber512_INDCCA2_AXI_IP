`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 10/21/2020 09:48:42 AM
// Design Name: Kyber512 INDCCA
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


module Kyber512_INDCCA #(
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
  parameter CIPHERTEXT_SZ       = Byte_bits * KYBER_512_CtBytes,
  parameter SECRET_KEY_SZ       = Byte_bits * KYBER_512_SKBytes,
  parameter SHARED_SECRET_SZ    = Byte_bits * KYBER_512_SSBytes,
  parameter PUBLIC_KEY_SZ       = Byte_bits * KYBER_512_PKBytes
)(
  input   wire                          i_clk,
  input   wire                          i_reset_n,
  input   wire                          i_enable,
  input   wire                          i_mux_enc_dec,
  // input   wire [RAND_SZ-1:0]            i_random,
  // input   wire [PUBLIC_KEY_SZ-1:0]      i_public_key,
  // input   wire [CIPHERTEXT_SZ-1:0]     i_ciphertext,
  // input   wire [SECRET_KEY_SZ-1:0]      i_secret_key,
  input   wire [255:0]                  i_rand_CT_RData,
  input   wire [255:0]                  i_PK_SK_RData,
  output  reg  [4:0]                    o_rand_CT_RAd,
  output  reg  [5:0]                    o_PK_SK_RAd,
  output  wire [SHARED_SECRET_SZ-1:0]   o_shared_secret,
  output  wire [CIPHERTEXT_SZ-1:0]      o_ciphertext,
  output  reg                           o_function_done,
  output  reg                           o_cal_flag,
  output  wire [3:0]                    o_cstate_flag,
  output  reg                           o_verify_fail,
  // DEBUG:
  // output [3:0] state,
  // output [255:0] o_message,
  // output [255:0] o_coins,
  // output [511:0] o_Kr
  // output [127:0] unpackedpk_debug,
  // output [255:0] seed_debug,
  // output [191:0] msgpoly_debug
  // output [1023:0] At_debug,
  // output [255:0] Sp_debug,
  // output [255:0] eG_debug,
  // output [4095:0] ntt_debug,
  // output [1023:0] Bp_debug,
  // output [511:0] V_debug,
  // output [255:0] reduceV_debug,
  // output [255:0] reduceBp_debug
  output wire trigger1,
  output wire trigger2
);

integer w;
integer fetch;

// Status flags

// Control signals
// Control signals: Run dirty bit
reg start;
reg pass;
// Control Signals: Mode select - Enc/Dec
reg mux_enc_dec_R;
// wire enable_ENC; 
// wire enable_DEC;
// Control signals: Pre & Post INDCPA Encryption
reg  T0_pre_post_indcpa_ENC_enable;
reg  T0_pre_post_indcpa_ENC_mode;
wire T0_pre_post_indcpa_ENC_done;
// Control signals: INDCPA 
reg  T1_indcpa_ENC_enable, T1_indcpa_DEC_enable;
wire T1_indcpa_ENC_done;
wire T1_indcpa_DEC_done;

// Data signals
reg            FO_verify_fail;
// Data signals: Pre & Post INDCPA Encryption
reg  [255 : 0] T0_iBuf_Hi;
reg  [255 : 0] T0_i_post_Kr_Hi;
reg  [511 : 0] T0_FO_buf;
wire [255 : 0] T0_oBuf_Hi;
wire [511 : 0] T0_o_Kr;
// Data signals: INDCPA
// reg  [PUBLIC_KEY_SZ-1:0]  i_PK;
reg  [PUBLIC_KEY_SZ-1:0]  i_public_key;
reg  [CIPHERTEXT_SZ-1:0] i_ciphertext;
reg  [SECRET_KEY_SZ-1:0]  i_secret_key;
wire [CIPHERTEXT_SZ-1:0] T1_oCiphertext;
wire [255 : 0] T1_DEC_omsg;

// Module states (INDCCA)
reg [3:0] cstate, nstate;                      
localparam IDLE             = 4'd0;
localparam FetchMEM_ENC     = 4'd1;
localparam ReadMEM_ENC      = 4'd2; 
localparam Pre_indcpa_ENC   = 4'd3;
localparam indcpa_ENC       = 4'd4;
localparam Post_indcpa_ENC  = 4'd5;
localparam FetchMEM_DEC     = 4'd6;
localparam ReadMEM_DEC      = 4'd7;
localparam indcpa_DEC       = 4'd8;

// // Enable demux
// Demux A0 (
//   .clk(i_clk),
//   .select(i_mux_enc_dec),
//   .din(i_enable),
//   .dout0(enable_ENC),
//   .dout1(enable_DEC)
// );

// synthesis translate_off
integer enc_cycles, dec_cycles;
reg enable_enc_counter = 0;
reg enable_dec_counter = 0;

always @(posedge i_clk) begin
  if (!i_reset_n) begin
    enc_cycles <= 0;
    dec_cycles <= 0;
  end else begin
    if (enable_enc_counter) 
      enc_cycles <= enc_cycles + 1;

    if (enable_dec_counter)
      dec_cycles <= dec_cycles + 1;
  end
end
// synthesis translate_on

// Drivers
assign o_cstate_flag     = cstate;
assign o_ciphertext      = T1_oCiphertext;

always @(posedge i_clk or negedge i_reset_n)
  if (!i_reset_n) cstate <= IDLE;
  else            cstate <= nstate;

// INDCCA state machine
always @(cstate or i_enable or T0_pre_post_indcpa_ENC_done or
        T1_indcpa_ENC_done or T1_indcpa_DEC_done or o_PK_SK_RAd or w) begin
  case(cstate)
    IDLE:             if (i_enable && i_mux_enc_dec)    nstate <= FetchMEM_DEC;
                      else if (i_enable)                nstate <= FetchMEM_ENC;
                      else                              nstate <= IDLE;
    FetchMEM_ENC:     if (fetch == 2)                   nstate <= ReadMEM_ENC;
                      else                              nstate <= FetchMEM_ENC;
    ReadMEM_ENC:      if (o_PK_SK_RAd == 27)            nstate <= Pre_indcpa_ENC;
                      else                              nstate <= ReadMEM_ENC;
    Pre_indcpa_ENC:   if (T0_pre_post_indcpa_ENC_done)  nstate <= indcpa_ENC;          
                      else                              nstate <= Pre_indcpa_ENC;
    indcpa_ENC:       if (T1_indcpa_ENC_done)           nstate <= Post_indcpa_ENC;
                      else                              nstate <= indcpa_ENC;
    Post_indcpa_ENC:  if (T0_pre_post_indcpa_ENC_done)  nstate <= IDLE;
                      else                              nstate <= Post_indcpa_ENC;
    FetchMEM_DEC:     if (fetch == 2)                   nstate <= ReadMEM_DEC;
                      else                              nstate <= FetchMEM_DEC;
    ReadMEM_DEC:      if (w == 51)                      nstate <= indcpa_DEC;
                      else                              nstate <= ReadMEM_DEC;
    indcpa_DEC:       if (T1_indcpa_DEC_done)           nstate <= Pre_indcpa_ENC;
                      else                              nstate <= indcpa_DEC;   
    default:                                            nstate <= IDLE;
  endcase
end

always @(posedge i_clk or negedge i_reset_n)                    
  if(!i_reset_n) begin
    o_function_done               <= 1'b0;
    o_cal_flag                    <= 1'b0;
    T0_pre_post_indcpa_ENC_mode   <= 1'b0;
    T0_pre_post_indcpa_ENC_enable <= 1'b0;
    T0_i_post_Kr_Hi               <= 0;
    T1_indcpa_ENC_enable          <= 1'b0;
    T1_indcpa_DEC_enable          <= 1'b0;
    mux_enc_dec_R                 <= 1'b0;
    start                         <= 1'b0;
    pass                          <= 1'b0;
    o_verify_fail                 <= 1'b0;
  end else begin
    case({cstate,nstate})
      {IDLE,IDLE}: begin
        o_function_done <= 1'b0;
      end
      {IDLE,FetchMEM_DEC}: begin // Decapsulation
        o_rand_CT_RAd <= 0;
        o_PK_SK_RAd   <= 0;
        fetch         <= 0;
        w             <= 0;
      end
      {FetchMEM_DEC,FetchMEM_DEC}: begin
        o_rand_CT_RAd <= o_rand_CT_RAd + 1;
        o_PK_SK_RAd   <= o_PK_SK_RAd + 1;
        fetch         <= fetch + 1;
      end
      {FetchMEM_DEC,ReadMEM_DEC}: begin
        i_ciphertext[ 5887 -: 256] <= i_rand_CT_RData;
        i_secret_key[13055 -: 256] <= i_PK_SK_RData;
        o_rand_CT_RAd              <= o_rand_CT_RAd + 1;
        o_PK_SK_RAd                <= o_PK_SK_RAd + 1;
        w                          <= w + 1;
      end
      {ReadMEM_DEC,ReadMEM_DEC}: begin
        if (o_rand_CT_RAd < 22) o_rand_CT_RAd <= o_rand_CT_RAd + 1;
        if (o_PK_SK_RAd < 50)   o_PK_SK_RAd   <= o_PK_SK_RAd + 1;

        if (w < 23) i_ciphertext[ 5887-(w*256) -: 256] <= i_rand_CT_RData;
        if (w < 51) i_secret_key[13055-(w*256) -: 256] <= i_PK_SK_RData;
        
        w                                  <= w + 1;
      end
      {ReadMEM_DEC,indcpa_DEC}: begin
        o_rand_CT_RAd         <= 4'hx;
        o_PK_SK_RAd           <= 5'hx;
        o_cal_flag            <= 1'b1;
        o_function_done       <= 1'b0;
        T1_indcpa_DEC_enable  <= 1'b1;
        mux_enc_dec_R         <= 1'b1;

        // synthesis translate_off
        enable_dec_counter    <= 1'b1;
        // synthesis translate_on 
      end
      {indcpa_DEC,indcpa_DEC}: begin
        T1_indcpa_DEC_enable <= 1'b0;
      end
      {indcpa_DEC,Pre_indcpa_ENC}: begin
        T0_pre_post_indcpa_ENC_enable <= 1'b1;
        T0_pre_post_indcpa_ENC_mode   <= 1'b0; // mode = pre
        mux_enc_dec_R                 <= 1'b1;
        T0_FO_buf                     <= {T1_DEC_omsg, i_secret_key[511 -: 256]};
        i_public_key                  <= i_secret_key[6912-1 -: 6400];
        T0_iBuf_Hi                    <= i_secret_key[255 : 0];

        // synthesis translate_off
        enable_dec_counter            <= 1'b0;
        // synthesis translate_on
      end
      {IDLE,FetchMEM_ENC}:  begin // Encapsulation
        o_rand_CT_RAd                <= 0;
        o_PK_SK_RAd                  <= 0;
        fetch                        <= 0;
        w                            <= 0;
      end
      {FetchMEM_ENC,FetchMEM_ENC}: begin
        o_PK_SK_RAd <= o_PK_SK_RAd + 1;
        fetch       <= fetch + 1;
      end
      {FetchMEM_ENC,ReadMEM_ENC}: begin
          i_public_key[6399 -: 256]  <= i_PK_SK_RData;
          o_PK_SK_RAd                <= o_PK_SK_RAd + 1;
          w                          <= w + 1;
      end
      {ReadMEM_ENC,ReadMEM_ENC}: begin
        i_public_key[6399-(w*256) -: 256] <= i_PK_SK_RData;
        o_PK_SK_RAd                       <= o_PK_SK_RAd + 1;
        w                                 <= w + 1;
      end
      {ReadMEM_ENC,Pre_indcpa_ENC}: begin
        o_rand_CT_RAd                 <= 4'hx;
        o_PK_SK_RAd                   <= 5'hx;
        start                         <= 1'b0;
        o_cal_flag                    <= 1'b1;
        T0_pre_post_indcpa_ENC_enable <= 1'b1;
        T0_pre_post_indcpa_ENC_mode   <= 1'b0;
        T0_iBuf_Hi                    <= i_rand_CT_RData;
        // T0_iBuf_Hi                    <= i_random;
        // i_PK                          <= i_public_key;
        mux_enc_dec_R                 <= 1'b0;
        o_function_done               <= 1'b0;

        // synthesis translate_off
        enable_enc_counter            <= 1'b1;
        // synthesis translate_on 
      end
      {Pre_indcpa_ENC,Pre_indcpa_ENC}: begin
        T0_pre_post_indcpa_ENC_enable <= 1'b0;
        T0_pre_post_indcpa_ENC_mode   <= 1'b0;   
      end
      {Pre_indcpa_ENC,indcpa_ENC}: begin
        T0_i_post_Kr_Hi      <= T0_o_Kr[511 -: 256];
        T1_indcpa_ENC_enable <= 1'b1;      
        mux_enc_dec_R        <= 1'b0;         
      end
      {indcpa_ENC,indcpa_ENC}: begin
        T1_indcpa_ENC_enable <= 1'b0;  
      end
      {indcpa_ENC,Post_indcpa_ENC}: begin
        T0_pre_post_indcpa_ENC_enable <= 1'b1;
        T0_pre_post_indcpa_ENC_mode   <= 1'b1;
        mux_enc_dec_R                 <= i_mux_enc_dec; 
      end                              
      {Post_indcpa_ENC,Post_indcpa_ENC}: begin
        T0_pre_post_indcpa_ENC_enable <= 1'b0;
        T0_pre_post_indcpa_ENC_mode   <= 1'b1;  
      end 
      {Post_indcpa_ENC,IDLE}: begin
        if (i_mux_enc_dec)
          o_verify_fail    <= FO_verify_fail;
        
        o_function_done    <= 1'b1;
        o_cal_flag         <= 1'b0;

        // synthesis translate_off
        enable_enc_counter <= 1'b0;
        // synthesis translate_on 
      end
      default: ;
    endcase
  end


// Verify in FO transform
always @(*) begin
  FO_verify_fail <= (i_ciphertext == T1_oCiphertext) ? 1'b0 : 1'b1;
end


Kyber512_pre_post_INDCPA T0 (
  .clk(i_clk),
  .reset_n(i_reset_n),
  .enable(T0_pre_post_indcpa_ENC_enable),
  .mux_enc_dec(mux_enc_dec_R),
  .mode(T0_pre_post_indcpa_ENC_mode), // 0 pre, 1 post
  .pre_post_hash_done(T0_pre_post_indcpa_ENC_done),
  .i_buf(T0_iBuf_Hi), // (i_Random),
  .i_Pk(i_public_key), // (i_PK)
  .i_Ct(T1_oCiphertext), // (o_Ciphertext),
  .i_post_Kr_Hi(T0_i_post_Kr_Hi),
  .i_FO_buf(T0_FO_buf),
  .i_FO_verify_fail(FO_verify_fail),
  .o_post_Kr_Hi(T0_o_Kr[511 -: 256]),
  .o_message(T0_oBuf_Hi),
  .o_coins(T0_o_Kr[255 -: 256]),
  .o_SS(o_shared_secret)
);


Kyber512_INDCPA T1 (
  .clk(i_clk),
  .rst_n(i_reset_n),
  .mux_enc_dec(mux_enc_dec_R),
  // INDCPA_ENC
  .i_indcpa_enc_enable(T1_indcpa_ENC_enable),
  .i_PK(i_public_key),
  .i_Msg(T0_oBuf_Hi),
  .i_Coins(T0_o_Kr[255 -: 256]),
  .o_indcpa_enc_done(T1_indcpa_ENC_done),
  .o_CT(T1_oCiphertext),
  // INDCPA_DEC
  .i_indcpa_dec_enable(T1_indcpa_DEC_enable),
  .i_CT(i_ciphertext),
  .i_SK(i_secret_key[13055 -: 6144]),
  .o_Msg(T1_DEC_omsg),
  .o_indcpa_dec_done(T1_indcpa_DEC_done),
  // DEBUG:
  .trigger1(trigger1),
  .trigger2(trigger2)
);

// TRNG KEM_TRNG_0 (

// );

endmodule