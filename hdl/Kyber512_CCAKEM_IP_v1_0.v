
`timescale 1 ns / 1 ps

  module Kyber512_CCAKEM_IP_v1_0 #
  (
    // Users to add parameters here
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
    parameter PUBLIC_KEY_SZ       = Byte_bits * KYBER_512_PKBytes,
    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH  = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH  = 5,

    // Parameters of Axi Slave Bus Interface S01_AXI
    parameter integer C_S01_AXI_DATA_WIDTH  = 32,
    parameter integer C_S01_AXI_ADDR_WIDTH  = 5
  )
  (
    // Users to add ports here
    input kyber_aclk,
    input kyber_aresetn,
    output trigger1,
    output trigger2,
    output debug_function_done,
    output [   CIPHERTEXT_SZ-1 : 0] o_ciphertext,
    output [SHARED_SECRET_SZ-1 : 0] o_shared_secret,
    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,

    // Ports of Axi Slave Bus Interface S01_AXI
    input wire  s01_axi_aclk,
    input wire  s01_axi_aresetn,
    input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_awaddr,
    input wire [2 : 0] s01_axi_awprot,
    input wire  s01_axi_awvalid,
    output wire  s01_axi_awready,
    input wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_wdata,
    input wire [(C_S01_AXI_DATA_WIDTH/8)-1 : 0] s01_axi_wstrb,
    input wire  s01_axi_wvalid,
    output wire  s01_axi_wready,
    output wire [1 : 0] s01_axi_bresp,
    output wire  s01_axi_bvalid,
    input wire  s01_axi_bready,
    input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_araddr,
    input wire [2 : 0] s01_axi_arprot,
    input wire  s01_axi_arvalid,
    output wire  s01_axi_arready,
    output wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_rdata,
    output wire [1 : 0] s01_axi_rresp,
    output wire  s01_axi_rvalid,
    input wire  s01_axi_rready
  );
    // User defined wires
  wire w_cal_flag;
  wire w_verify_fail;
  wire w_function_done;
  wire w_decryption_done;
  wire [1:0] w_cstate_flag;
  // wire [RAND_SZ-1:0] w_random;
  // wire [PUBLIC_KEY_SZ-1:0] w_public_key;
  // wire [CIPHERTEXT_SZ-1:0] w_icipher_text;
  wire [CIPHERTEXT_SZ-1:0] w_ociphertext;
  wire [4:0]                w_rand_CT_RAd;
  wire [5:0]                w_PK_SK_RAd;
  wire [255:0]              w_rand_CT_RData;
  wire [255:0]              w_PK_SK_RData;
  wire [SHARED_SECRET_SZ-1:0] w_oshared_secret;
  // wire [SHARED_SECRET_SZ-1:0] w_oshared_secretb;
  // wire [SECRET_KEY_SZ-1:0] w_secret_key;
  wire [C_S00_AXI_DATA_WIDTH-1:0] w_control;
  wire [C_S00_AXI_DATA_WIDTH-1:0] w_status_reg;

  // Drivers
  assign o_ciphertext = w_ociphertext;
  assign o_shared_secret = w_oshared_secret;
  
// Instantiation of Axi Bus Interface S00_AXI
  Kyber512_CCAKEM_IP_v1_0_S00_AXI # ( 
    .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
  ) Kyber512_CCAKEM_IP_v1_0_S00_AXI_inst (
    .S_AXI_ACLK(s00_axi_aclk),
    .S_AXI_ARESETN(s00_axi_aresetn),
    .S_AXI_AWADDR(s00_axi_awaddr),
    .S_AXI_AWPROT(s00_axi_awprot),
    .S_AXI_AWVALID(s00_axi_awvalid),
    .S_AXI_AWREADY(s00_axi_awready),
    .S_AXI_WDATA(s00_axi_wdata),
    .S_AXI_WSTRB(s00_axi_wstrb),
    .S_AXI_WVALID(s00_axi_wvalid),
    .S_AXI_WREADY(s00_axi_wready),
    .S_AXI_BRESP(s00_axi_bresp),
    .S_AXI_BVALID(s00_axi_bvalid),
    .S_AXI_BREADY(s00_axi_bready),
    .S_AXI_ARADDR(s00_axi_araddr),
    .S_AXI_ARPROT(s00_axi_arprot),
    .S_AXI_ARVALID(s00_axi_arvalid),
    .S_AXI_ARREADY(s00_axi_arready),
    .S_AXI_RDATA(s00_axi_rdata),
    .S_AXI_RRESP(s00_axi_rresp),
    .S_AXI_RVALID(s00_axi_rvalid),
    .S_AXI_RREADY(s00_axi_rready),
    // User ports
    .i_encryption_done(w_function_done),
    .i_decryption_done(w_decryption_done),
    .i_cal_flag(w_cal_flag),
    .i_cstate_flag(w_cstate_flag),
    .i_status_reg(w_status_reg),
    .o_control(w_control)
  );

  // DEBUG
  // wire [3:0] state;
  // wire [255:0] w_message, w_coins;
  // wire [511:0] w_Kr;
  // wire [127:0] w_unpackedpk_debug;
  // wire [255:0] w_seed_debug;
  // wire [191:0] w_msgpoly_debug;
  // wire [1023:0] At_debug;
  // wire [255:0] Sp_debug;
  // wire [255:0] eG_debug;
// wire [1023:0] Bp_debug;
//  wire [511:0] V_debug;
//  wire [255:0] reduceV_debug;
//  wire [255:0] reduceBp_debug;
//  wire [4095:0] ntt_debug;

// Instantiation of Axi Bus Interface S01_AXI
  Kyber512_CCAKEM_IP_v1_0_S01_AXI # ( 
    .C_S_AXI_DATA_WIDTH(C_S01_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S01_AXI_ADDR_WIDTH)
  ) Kyber512_CCAKEM_IP_v1_0_S01_AXI_inst (
    .S_AXI_ACLK(s01_axi_aclk),
    .S_AXI_ARESETN(s01_axi_aresetn),
    .S_AXI_AWADDR(s01_axi_awaddr),
    .S_AXI_AWPROT(s01_axi_awprot),
    .S_AXI_AWVALID(s01_axi_awvalid),
    .S_AXI_AWREADY(s01_axi_awready),
    .S_AXI_WDATA(s01_axi_wdata),
    .S_AXI_WSTRB(s01_axi_wstrb),
    .S_AXI_WVALID(s01_axi_wvalid),
    .S_AXI_WREADY(s01_axi_wready),
    .S_AXI_BRESP(s01_axi_bresp),
    .S_AXI_BVALID(s01_axi_bvalid),
    .S_AXI_BREADY(s01_axi_bready),
    .S_AXI_ARADDR(s01_axi_araddr),
    .S_AXI_ARPROT(s01_axi_arprot),
    .S_AXI_ARVALID(s01_axi_arvalid),
    .S_AXI_ARREADY(s01_axi_arready),
    .S_AXI_RDATA(s01_axi_rdata),
    .S_AXI_RRESP(s01_axi_rresp),
    .S_AXI_RVALID(s01_axi_rvalid),
    .S_AXI_RREADY(s01_axi_rready),
    // User ports
    .i_control(w_control),
    .i_reset_n(w_control[31]),
    .i_ciphertext(w_ociphertext),
    .i_shared_secret(w_oshared_secret),
    // .i_shared_secretb(w_oshared_secretb),
    .i_function_done(w_function_done),
    // .i_decryption_done(w_decryption_done),
    .i_verify_fail(w_verify_fail),
    .i_rand_CT_RAd(w_rand_CT_RAd),
    .i_PK_SK_RAd(w_PK_SK_RAd),
    .o_rand_CT_RData(w_rand_CT_RData),
    .o_PK_SK_RData(w_PK_SK_RData),
    .o_status_reg(w_status_reg),
    .o_function_done(debug_function_done)
    // DEBUG
    // .state(state),
    // .i_message(w_message),
    // .i_coins(w_coins),
    // .i_Kr(w_Kr)
    // .unpackedpk_debug(w_unpackedpk_debug),
    // .seed_debug(w_seed_debug),
    // .msgpoly_debug(w_msgpoly_debug)
    // .At_debug(At_debug),
    // .Sp_debug(Sp_debug),
    // .eG_debug(eG_debug),
  //  .ntt_debug(ntt_debug),
  //    .Bp_debug(Bp_debug),
  // .V_debug(V_debug),
  //  .reduceV_debug(reduceV_debug),
  //  .reduceBp_debug(reduceBp_debug)
  );

  // wire resetn;
  // always @(posedge clk) begin
  //  if (!w_control[31])
  //    resetn <= kyber_resetn;
  // end

  // Add user logic here
  Kyber512_INDCCA #(
    .RAND_SZ(RAND_SZ),
    .PUBLIC_KEY_SZ(PUBLIC_KEY_SZ),
    .CIPHERTEXT_SZ(CIPHERTEXT_SZ),
    .SECRET_KEY_SZ(SECRET_KEY_SZ),
    .SHARED_SECRET_SZ(SHARED_SECRET_SZ)
  ) Kyber512_CCAKEM_inst (
    .i_clk(kyber_aclk),
    .i_reset_n(w_control[31]),
    .i_enable(w_control[1]),
    .i_mux_enc_dec(w_control[0]),
    // .i_random(w_random),
    // .i_public_key(w_public_key),
    // .i_ciphertext(w_icipher_text),
    // .i_secret_key(w_secret_key),
    .o_rand_CT_RAd(w_rand_CT_RAd),
    .o_PK_SK_RAd(w_PK_SK_RAd),
    .i_rand_CT_RData(w_rand_CT_RData),
    .i_PK_SK_RData(w_PK_SK_RData),
    .o_shared_secret(w_oshared_secret),
    // .o_shared_secretb(w_oshared_secretb),
    .o_ciphertext(w_ociphertext),
    // .o_encryption_done(w_function_done),
    // .o_decryption_done(w_decryption_done),
    .o_function_done(w_function_done),
    .o_cal_flag(w_cal_flag),
    .o_cstate_flag(w_cstate_flag),
    .o_verify_fail(w_verify_fail),
    // DEBUG:
    // .state(state),
    //.o_message(w_message),
    //.o_coins(w_coins),
    //.o_Kr(w_kr)
    // .unpackedpk_debug(w_unpackedpk_debug),
    // .seed_debug(w_seed_debug),
    // .msgpoly_debug(w_msgpoly_debug),
    // .At_debug(At_debug),
    // .Sp_debug(Sp_debug),
    // .eG_debug(eG_debug)
  //  .ntt_debug(ntt_debug),
  //    .Bp_debug(Bp_debug),
  // .V_debug(V_debug),
  //  .reduceV_debug(reduceV_debug),
  //  .reduceBp_debug(reduceBp_debug)
  .trigger1(trigger1),
  .trigger2(trigger2)
  );
  // User logic ends

  endmodule
