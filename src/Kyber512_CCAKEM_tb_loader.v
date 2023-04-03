`timescale 1ps/1ps

module MEM_LOADER #(
  parameter BYTE_BITS           = 8,
  parameter KYBER_512_SKBytes   = 1632,
  parameter KYBER_512_PKBytes   = 800,
  parameter KYBER_512_CtBytes   = 736,
  parameter KYBER_512_SSBytes   = 32,
  parameter KYBER_512_RandBytes = 32,
  parameter RAND_SZ             = BYTE_BITS * KYBER_512_RandBytes,
  parameter CIPHERTEXT_SZ       = BYTE_BITS * KYBER_512_CtBytes,
  parameter SECRET_KEY_SZ       = BYTE_BITS * KYBER_512_SKBytes,
  parameter SHARED_SECRET_SZ    = BYTE_BITS * KYBER_512_SSBytes,
  parameter PUBLIC_KEY_SZ       = BYTE_BITS * KYBER_512_PKBytes
) (
  input                                i_clk,
  input                                i_rst_n,
  input                                i_enable,
  input                                i_mode,
  input       [         RAND_SZ-1 : 0] i_random,
  input       [   PUBLIC_KEY_SZ-1 : 0] i_public_key,
  input       [   CIPHERTEXT_SZ-1 : 0] i_ciphertext,
  input       [   SECRET_KEY_SZ-1 : 0] i_secret_key,
  output reg                           o_done,
  // CCAKEM Input
  input       [                 4 : 0] i_rand_CT_RAd,
  input       [                 5 : 0] i_PK_SK_RAd,
  output      [               255 : 0] o_rand_CT_RData,
  output      [               255 : 0] o_PK_SK_RData,
  // CCAKEM Output
  input                                i_function_done,
  input       [   CIPHERTEXT_SZ-1 : 0] i_ociphertext,
  input       [SHARED_SECRET_SZ-1 : 0] i_oshared_secret
);

function [255:0] reordered_mempackets ;
  input [255:0] in;

  integer w;

  begin
    for (w=0; w<8; w=w+1) begin
      reordered_mempackets[255-(w*32) -: 32] = in[31+(w*32) -: 32];
    end
  end
endfunction

reg [31:0] i_control = 0;
reg [31:0] slv_reg0  = 0;
reg [31:0] slv_reg1  = 0;

reg         CT_outready;
reg         SS_outready;
reg [  7:0] CT_WAd;
reg [255:0] CT_WData;

wire [ 7:0] BRAM_RAd;
wire [31:0] CT_RData;
wire [31:0] SS_RData;

wire [255:0] w_rand_CT_RData;
wire [255:0] w_PK_SK_RData;

assign o_rand_CT_RData = reordered_mempackets(w_rand_CT_RData);
assign o_PK_SK_RData   = reordered_mempackets(w_PK_SK_RData);

// BRAM
Rand_CT_MEM M0 (
  .clka(i_clk),
  .wea(i_control[2]),
  .addra(slv_reg1[7:0]),  // ( 7 DOWNTO 0)
  .dina(slv_reg0),        // (31 DOWNTO 0)
  .clkb(i_clk),
  .addrb(i_rand_CT_RAd),  // (  4 DOWNTO 0)
  .doutb(w_rand_CT_RData) // (255 DOWNTO 0)
);

PK_SK_MEM M1 (
  .clka(i_clk),
  .wea(i_control[3]),
  .addra(slv_reg1[8:0]),  // ( 8 DOWNTO 0)
  .dina(slv_reg0),        // (31 DOWNTO 0)
  .clkb(i_clk),
  .addrb(i_PK_SK_RAd),    // (  5 DOWNTO 0)
  .doutb(w_PK_SK_RData)   // (255 DOWNTO 0)
);

CT_OUT_MEM M2 (
  .clka(i_clk),
  .wea(CT_outready),
  .addra(CT_WAd),         // (  4 DOWNTO 0)
  .dina(CT_WData),        // (255 DOWNTO 0)
  .clkb(i_clk),
  .addrb(BRAM_RAd[7:0]),  // ( 7 DOWNTO 0)
  .doutb(CT_RData)        // (31 DOWNTO 0)
);

SS_OUT_MEM M3 (
  .clka(i_clk),
  .wea(SS_outready),
  .addra(i_mode),         // (  1 DOWNTO 0)
  .dina(i_oshared_secret),// (255 DOWNTO 0)
  .clkb(i_clk),
  .addrb(BRAM_RAd[3:0]),  // (  3 DOWNTO 0)
  .doutb(SS_RData)        // ( 31 DOWNTO 0)
);

// Fill memories with data
reg [3:0] cstate,nstate;
localparam IDLE      = 4'd0;
localparam LOAD_RAND = 4'd1;
localparam LOAD_PK   = 4'd2;
localparam LOAD_SK   = 4'd3;
localparam LOAD_CT   = 4'd4;
localparam BREAK     = 4'd5;

always @(posedge i_clk or negedge i_rst_n) begin
  if (i_rst_n == 1'b0)  cstate <= IDLE;
  else                  cstate <= nstate;
end

always @(cstate, i_enable, i_mode, slv_reg1) begin
  case (cstate)
    IDLE:       if (i_enable && i_mode) nstate <= LOAD_CT;
                else if (i_enable)      nstate <= LOAD_RAND;
                else                    nstate <= IDLE;
    LOAD_RAND:  if (slv_reg1 == 7)      nstate <= BREAK;
                else                    nstate <= LOAD_RAND;
    LOAD_PK:    if (slv_reg1 == 199)    nstate <= IDLE;
                else                    nstate <= LOAD_PK;
    LOAD_CT:    if (slv_reg1 == 183)    nstate <= BREAK;
                else                    nstate <= LOAD_CT;
    LOAD_SK:    if (slv_reg1 == 407)    nstate <= IDLE;
                else                    nstate <= LOAD_SK;
    BREAK:      if (i_mode)             nstate <= LOAD_SK;
                else                    nstate <= LOAD_PK; 
    default:                            nstate <= IDLE;
  endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
  if (i_rst_n == 1'b0) begin
    slv_reg0 <= 32'b0;
    slv_reg1 <= 32'b0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: begin
        o_done         <= 1'b0;
        i_control[3:2] <= 2'b0;
      end
      // Enc
      {IDLE,LOAD_RAND}: begin
        i_control[2]  <= 1'b1; // we
        slv_reg0      <= i_random[RAND_SZ-1 -: 32];
        slv_reg1      <= 0;
      end
      {LOAD_RAND,LOAD_RAND}: begin
        slv_reg0      <= i_random[RAND_SZ-((slv_reg1+1)*32)-1 -: 32];
        slv_reg1      <= slv_reg1 + 1;
      end
      {LOAD_RAND,BREAK}: begin
        i_control[2]  <= 1'b0;
        slv_reg1      <= 0;
      end
      {BREAK,LOAD_PK}: begin
        i_control[3]  <= 1'b1; // we
        slv_reg0      <= i_public_key[PUBLIC_KEY_SZ-1 -: 32];
        slv_reg1      <= 0;
      end
      {LOAD_PK,LOAD_PK}: begin
        slv_reg0      <= i_public_key[PUBLIC_KEY_SZ-((slv_reg1+1)*32)-1 -: 32];
        slv_reg1      <= slv_reg1 + 1;
      end
      {LOAD_PK,IDLE}: begin
        i_control[3]  <= 1'b0;
        slv_reg1      <= 0; 
        o_done        <= 1'b1;
      end
      // Dec
      {IDLE,LOAD_CT}: begin
        i_control[2]  <= 1'b1; // wea
        slv_reg0      <= i_ciphertext[CIPHERTEXT_SZ-1 -: 32];
        slv_reg1      <= 0;
      end
      {LOAD_CT,LOAD_CT}: begin
        slv_reg0      <= i_ciphertext[CIPHERTEXT_SZ-((slv_reg1+1)*32)-1 -: 32];
        slv_reg1      <= slv_reg1 + 1;
      end
      {LOAD_CT,BREAK}: begin
        i_control[2]  <= 1'b0;
        slv_reg1      <= 0; 
      end
      {BREAK,LOAD_SK}: begin
        i_control[3]  <= 1'b1; // wea
        slv_reg0      <= i_secret_key[SECRET_KEY_SZ-1 -: 32];
        slv_reg1      <= 0;
      end
      {LOAD_SK,LOAD_SK}: begin
        slv_reg0      <= i_secret_key[SECRET_KEY_SZ-((slv_reg1+1)*32)-1 -: 32];
        slv_reg1      <= slv_reg1 + 1;
      end
      {LOAD_SK,IDLE}: begin
        i_control[3]  <= 1'b0;
        slv_reg1      <= 0;
        o_done        <= 1'b1;
      end
      default: ;
    endcase
  end
end
  
endmodule