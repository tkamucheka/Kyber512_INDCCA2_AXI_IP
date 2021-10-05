
`timescale 1 ns / 1 ps

  module Kyber512_CCAKEM_IP_v1_0_S01_AXI #
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

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH  = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH  = 5
  )
  (
    // Users to add ports here
    input  wire [CIPHERTEXT_SZ-1:0]       i_ciphertext,
    input  wire [SHARED_SECRET_SZ-1:0]    i_shared_secret,
    input  wire [C_S_AXI_DATA_WIDTH-1:0]  i_control,
    input  wire                           i_reset_n,
    input  wire                           i_function_done,
    input  wire                           i_verify_fail,
    input  wire [4:0]   i_rand_CT_RAd,
    input  wire [5:0]   i_PK_SK_RAd,
    output wire [255:0] o_rand_CT_RData,
    output wire [255:0] o_PK_SK_RData,
    output reg  [C_S_AXI_DATA_WIDTH-1:0]  o_status_reg,
    output reg                            o_function_done,
    // DEBUG:
    // input wire [3:0] state,
    // input wire [255:0] i_message,
    // input wire [255:0] i_coins,
    // input wire [511:0] i_Kr,
    // input wire [127:0] unpackedpk_debug,
    // input wire [255:0] seed_debug,
    // input wire [191:0] msgpoly_debug,
    // input wire [1023:0] At_debug,
    // input wire [255:0] Sp_debug,
    // input wire [255:0] eG_debug,
    // input wire [4095:0] ntt_debug,
    // input wire [1023:0] Bp_debug,
    // input wire [511:0] V_debug,
    // input wire [255:0] reduceV_debug,
    // input wire [255:0] reduceBp_debug,
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S_AXI_RREADY
  );
  // User wires
  // wire reset_n;
  // wire [C_S_AXI_DATA_WIDTH-1:0] w_shared_secreta;
  // wire [C_S_AXI_DATA_WIDTH-1:0] w_shared_secretb;
  // wire [C_S_AXI_DATA_WIDTH-1:0] w_ociphertext;
  // wire [C_S_AXI_DATA_WIDTH-1:0] w_ociphertext_addr;
//  wire [C_S_AXI_DATA_WIDTH-1:0] w_omessage;
//  wire [C_S_AXI_DATA_WIDTH-1:0] w_ocoins;
//  wire [C_S_AXI_DATA_WIDTH-1:0] w_oKr;
  
  // AXI4LITE signals
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
  reg   axi_awready;
  reg   axi_wready;
  reg [1 : 0]   axi_bresp;
  reg   axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
  reg   axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
  reg [1 : 0]   axi_rresp;
  reg   axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // ADDR_LSB is used for addressing 32/64 bit registers/memories
  // ADDR_LSB = 2 for 32 bits (n downto 2)
  // ADDR_LSB = 3 for 64 bits (n downto 3)
  localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
  localparam integer OPT_MEM_ADDR_BITS = 2;
  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  //-- Number of Slave Registers 8
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg0;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg1;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg2;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg3;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg4;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg5;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg6;
  reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg7;
  wire   slv_reg_rden;
  wire   slv_reg_wren;
  reg [C_S_AXI_DATA_WIDTH-1:0]   reg_data_out;
  integer  byte_index;
  reg  aw_en;

  // I/O Connections assignments

  assign S_AXI_AWREADY  = axi_awready;
  assign S_AXI_WREADY = axi_wready;
  assign S_AXI_BRESP  = axi_bresp;
  assign S_AXI_BVALID = axi_bvalid;
  assign S_AXI_ARREADY  = axi_arready;
  assign S_AXI_RDATA  = axi_rdata;
  assign S_AXI_RRESP  = axi_rresp;
  assign S_AXI_RVALID = axi_rvalid;
  // Implement axi_awready generation
  // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_awready <= 1'b0;
        aw_en <= 1'b1;
      end 
    else
      begin    
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
          begin
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
          end
          else if (S_AXI_BREADY && axi_bvalid)
              begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
              end
        else           
          begin
            axi_awready <= 1'b0;
          end
      end 
  end       

  // Implement axi_awaddr latching
  // This process is used to latch the address when both 
  // S_AXI_AWVALID and S_AXI_WVALID are valid. 

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_awaddr <= 0;
      end 
    else
      begin    
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
          begin
            // Write Address latching 
            axi_awaddr <= S_AXI_AWADDR;
          end
      end 
  end       

  // Implement axi_wready generation
  // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
  // de-asserted when reset is low. 

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_wready <= 1'b0;
      end 
    else
      begin    
        if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
          begin
            // slave is ready to accept write data when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_wready <= 1'b1;
          end
        else
          begin
            axi_wready <= 1'b0;
          end
      end 
  end       

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  // select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        slv_reg0 <= 0;
        slv_reg1 <= 0;
        slv_reg2 <= 0;
        slv_reg3 <= 0;
        slv_reg4 <= 0;
        slv_reg5 <= 0;
        slv_reg6 <= 0;
        slv_reg7 <= 0;
      end 
    else begin
      if (slv_reg_wren)
        begin
          case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            3'h0:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 0
                  slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h1:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 1
                  slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h2:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 2
                  slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h3:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 3
                  slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h4:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 4
                  slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h5:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 5
                  slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h6:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 6
                  slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            3'h7:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes 
                  // Slave register 7
                  slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end  
            default : begin
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                        slv_reg4 <= slv_reg4;
                        slv_reg5 <= slv_reg5;
                        slv_reg6 <= slv_reg6;
                        slv_reg7 <= slv_reg7;
                      end
          endcase
        end
    end
  end    

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave 
  // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
  // This marks the acceptance of address and indicates the status of 
  // write transaction.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
      end 
    else
      begin    
        if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
          begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
          end                   // work error responses in future
        else
          begin
            if (S_AXI_BREADY && axi_bvalid) 
              //check if bready is asserted while bvalid is high) 
              //(there is a possibility that bready is always asserted high)   
              begin
                axi_bvalid <= 1'b0; 
              end  
          end
      end
  end   

  // Implement axi_arready generation
  // axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S_AXI_ARVALID is asserted. axi_awready is 
  // de-asserted when reset (active low) is asserted. 
  // The read address is also latched when S_AXI_ARVALID is 
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_arready <= 1'b0;
        axi_araddr  <= 32'b0;
      end 
    else
      begin    
        if (~axi_arready && S_AXI_ARVALID)
          begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= S_AXI_ARADDR;
          end
        else
          begin
            axi_arready <= 1'b0;
          end
      end 
  end       

  // Implement axi_arvalid generation
  // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
  // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
  // data are available on the axi_rdata bus at this instance. The 
  // assertion of axi_rvalid marks the validity of read data on the 
  // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
  // is deasserted on reset (active low). axi_rresp and axi_rdata are 
  // cleared to zero on reset (active low).  
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
      end 
    else
      begin    
        if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
          begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end   
        else if (axi_rvalid && S_AXI_RREADY)
          begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
          end                
      end
  end    

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  // wire [ 7:0] BRAM_RAd;
  wire [31:0] CT_RData;
  wire [31:0] SS_RData;
  reg [255:0] ss = 256'h5955e27b0a4bb2c1279fe11780b8a9d78f42e360faa6a94fdff417666569b91b;
  
  assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
  always @(*)
  begin
        // Address decoding for reading registers
        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
          3'h0   : reg_data_out <= slv_reg0; // i_data_reg
          3'h1   : reg_data_out <= slv_reg1; // i_memaddr_reg
          3'h2   : reg_data_out <= CT_RData; // o_ciphertext_reg
          3'h3   : reg_data_out <= SS_RData; // o_shared_secret_reg
          3'h4   : reg_data_out <= slv_reg4; // o_memaddr_reg
          3'h5   : reg_data_out <= slv_reg5; // 
          3'h6   : reg_data_out <= slv_reg6; // 
          3'h7   : reg_data_out <= slv_reg7; // 
          default : reg_data_out <= 0;
        endcase
  end

  // Output register or memory read data
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_rdata  <= 0;
      end 
    else
      begin    
        // When there is a valid read address (S_AXI_ARVALID) with 
        // acceptance of read address by the slave (axi_arready), 
        // output the read dada 
        if (slv_reg_rden)
          begin
            axi_rdata <= reg_data_out;     // register read data
          end   
      end
  end    

  // Add user logic here
function [255:0] reordered_mempackets ;
  input [255:0] in;

  integer w;

  begin
    for (w=0; w<8; w=w+1) begin
      reordered_mempackets[255-(w*32) -: 32] = in[31+(w*32) -: 32];
    end
  end
endfunction

  reg         CT_outready;
  reg         SS_outready;
  reg [7:0]   CT_WAd;
  reg [255:0] CT_WData;

  wire [255:0] w_rand_CT_RData;
  wire [255:0] w_PK_SK_RData;

  assign o_rand_CT_RData = reordered_mempackets(w_rand_CT_RData);
  assign o_PK_SK_RData   = reordered_mempackets(w_PK_SK_RData);

  // DEBUG:
  // assign SS_RData = o_rand_CT_RData[255-(C_S_AXI_DATA_WIDTH*slv_reg4) -: C_S_AXI_DATA_WIDTH];
  // assign CT_RData = o_PK_SK_RData[255-(C_S_AXI_DATA_WIDTH*slv_reg4) -: C_S_AXI_DATA_WIDTH];
  
  // BRAM
  Rand_CT_MEM M0 (
    .clka(S_AXI_ACLK),
    .wea(i_control[2]),
    .addra(slv_reg1[7:0]),      // (  7 DOWNTO 0)
    .dina(slv_reg0),            // ( 31 DOWNTO 0)
    .clkb(S_AXI_ACLK),
    .addrb(i_rand_CT_RAd[4:0]), // (  4 DOWNTO 0)
    .doutb(w_rand_CT_RData)     // (255 DOWNTO 0)
  );

  PK_SK_MEM M1 (
    .clka(S_AXI_ACLK),
    .wea(i_control[3]),
    .addra(slv_reg1[8:0]),    // (  8 DOWNTO 0)
    .dina(slv_reg0),          // ( 31 DOWNTO 0)
    .clkb(S_AXI_ACLK),
    .addrb(i_PK_SK_RAd[5:0]), // (  5 DOWNTO 0)
    .doutb(w_PK_SK_RData)     // (255 DOWNTO 0)
  );

  CT_OUT_MEM M2 (
    .clka(S_AXI_ACLK),
    .wea(CT_outready),
    .addra(CT_WAd),         // (  4 DOWNTO 0)
    .dina(CT_WData),        // (255 DOWNTO 0)
    .clkb(S_AXI_ACLK),
    .addrb(slv_reg4[7:0]),  // ( 7 DOWNTO 0)
    .doutb(CT_RData)        // (31 DOWNTO 0)
  );

  SS_OUT_MEM M3 (
    .clka(S_AXI_ACLK),
    .wea(SS_outready),
    .addra(i_control[0]),   // (  1 DOWNTO 0)
    .dina(reordered_mempackets(i_shared_secret)), // (255 DOWNTO 0)
    .clkb(S_AXI_ACLK),
    .addrb(slv_reg4[3:0]),  // (  3 DOWNTO 0)
    .doutb(SS_RData)        // ( 31 DOWNTO 0)
  );

  reg [2:0] cstate,nstate;
  localparam IDLE      = 3'd0;
  localparam WRITE_ENC = 3'd1;
  localparam WRITE_DEC = 3'd2;

  always @(posedge S_AXI_ACLK or negedge i_reset_n) begin
    if (i_reset_n == 1'b0)  cstate <= IDLE;
    else                    cstate <= nstate;
  end

  always @(i_control[0] or i_function_done or CT_WAd) begin
    case (cstate)
      IDLE: if (i_control[0] && i_function_done)  nstate <= WRITE_DEC;
            else if (i_function_done)             nstate <= WRITE_ENC;
            else                    nstate <= IDLE;
      WRITE_ENC: if (CT_WAd == 22)  nstate <= IDLE;
                 else               nstate <= WRITE_ENC;
      WRITE_DEC:                    nstate <= IDLE;
      default:                      nstate <= IDLE;
    endcase
  end

  always @(posedge S_AXI_ACLK or negedge i_reset_n) begin
    if (i_reset_n == 1'b0) begin
      o_status_reg    <= 32'b0;
      SS_outready     <= 1'b0;
      CT_outready     <= 1'b0;
      CT_WAd          <= 1'b0;
      o_function_done  <= 1'b0;
    end else begin
      case ({cstate,nstate})
        {IDLE,IDLE}: begin
          SS_outready <= 1'b0;
          o_function_done  <= 1'b0;
        end
        {IDLE,WRITE_ENC}: begin
          o_status_reg[0] <= 1'b0;
          SS_outready     <= 1'b1;
          CT_outready     <= 1'b1;
          CT_WData        <= reordered_mempackets(i_ciphertext[CIPHERTEXT_SZ-1 -: 256]);
          CT_WAd          <= 0;
        end
        {WRITE_ENC,WRITE_ENC}: begin
          SS_outready <= 1'b0;
          CT_WData    <= reordered_mempackets(i_ciphertext[CIPHERTEXT_SZ-((CT_WAd+1)*256)-1 -: 256]);
          CT_WAd      <= CT_WAd + 1;
        end
        {WRITE_ENC,IDLE}: begin
          o_function_done <= 1'b1;
          CT_outready     <= 1'b0;
          CT_WAd          <= 1'b0;
          o_status_reg[0] <= 1'b1; 
        end
        {IDLE,WRITE_DEC}: begin
          SS_outready      <= 1'b1;
          o_status_reg[1]  <= 1'b0;
          o_status_reg[31] <= 1'b0;
        end
        {WRITE_DEC,IDLE}: begin
          o_function_done  <= 1'b1;
          SS_outready      <= 1'b0;
          o_status_reg[1]  <= 1'b1;
          o_status_reg[31] <= i_verify_fail;
        end
        default: ;
      endcase
    end
  end

  // concat #(
  //   .INPUT_WIDTH(C_S_AXI_DATA_WIDTH), 
  //   .OUTPUT_WIDTH(RAND_SZ)) i_Rand_Concat_0
  // (
  //    .i_clk(S_AXI_ACLK),
  //    .i_reset_n(i_reset_n),
  //    .i_enable(i_control[3]),
  //    .i_data_in(slv_reg0),
  //    .o_data_out(o_random),
  //    .o_full_tick(o_status_tick[3])
  // );
  
  // concat #(
  //   .INPUT_WIDTH(C_S_AXI_DATA_WIDTH), 
  //   .OUTPUT_WIDTH(PUBLIC_KEY_SZ)) i_PK_Concat_0
  // (
  //    .i_clk(S_AXI_ACLK),
  //    .i_reset_n(i_reset_n),
  //    .i_enable(i_control[4]),
  //    .i_data_in(slv_reg1),
  //    .o_data_out(o_public_key),
  //    .o_full_tick(o_status_tick[4])
  // );

  // splitter2 #(
  //  .ADDR_WIDTH(8),
  //  .INPUT_WIDTH(CIPHERTEXT_SZ), 
  //  .OUTPUT_WIDTH(C_S_AXI_DATA_WIDTH)) o_CT_Split_0
  // (
  //  .i_clk(S_AXI_ACLK),
  //  .i_reset_n(i_reset_n),
  //  .i_chomp(i_encryption_done),
  //  .i_addr(slv_reg7[7:0]),
  //  .i_data_in(i_ciphertext),
  //  // .i_data_in({Bp_debug, V_debug, 896'h0, reduceBp_debug, reduceV_debug, i_ciphertext[5887 -: 2944]}),
  //  // .i_data_in({ntt_debug, 1792'h0}),
  //  // .i_data_in({reduceV_debug, reduceBp_debug, 5376'h0}),
  //  .o_data_out(w_ociphertext),
  //  .o_full(o_status_tick[9])
  // );
  
  //  splitter2 #(
  //    .ADDR_WIDTH(8),
  //    .INPUT_WIDTH(SHARED_SECRET_SZ), 
  //    .OUTPUT_WIDTH(C_S_AXI_DATA_WIDTH)) o_SS_Split_0
  //  (
  //  .i_clk(S_AXI_ACLK),
  //  .i_reset_n(i_reset_n),
  //  .i_chomp(i_encryption_done),
  //  .i_addr(slv_reg7[7:0]),
  //  .i_data_in(i_shared_secreta),
  //  .o_data_out(w_shared_secreta),
  //  .o_full(o_status_tick[7])
  //  );
  
  // DEC
  //  concat #(
  //   .INPUT_WIDTH(C_S_AXI_DATA_WIDTH), 
  //   .OUTPUT_WIDTH(RAND_SZ)) i_CT_Concat_0
  // (
  //    .i_clk(S_AXI_ACLK),
  //    .i_reset_n(i_reset_n),
  //    .i_enable(i_control[5]),
  //    .i_data_in(slv_reg2),
  //    .o_data_out(o_cipher_text),
  //    .o_full_tick(o_status_tick[5])
  // );
  
  // concat #(
  //   .INPUT_WIDTH(C_S_AXI_DATA_WIDTH), 
  //   .OUTPUT_WIDTH(PUBLIC_KEY_SZ)) i_SK_Concat_0
  // (
  //    .i_clk(S_AXI_ACLK),
  //    .i_reset_n(i_reset_n),
  //    .i_enable(i_control[6]),
  //    .i_data_in(slv_reg3),
  //    .o_data_out(o_secret_key),
  //    .o_full_tick(o_status_tick[6])
  // );
  
  // splitter2 #(
  //  .ADDR_WIDTH(8),
  //   .INPUT_WIDTH(SHARED_SECRET_SZ), 
  //   .OUTPUT_WIDTH(C_S_AXI_DATA_WIDTH)) o_SS_Split_1
  // (
  //   .i_clk(S_AXI_ACLK),
  //    .i_reset_n(i_reset_n),
  //    .i_chomp(i_encryption_done),
  //    .i_addr(slv_reg7),
  //    .i_data_in(i_shared_secretb),
  //    .o_data_out(w_shared_secretb),
  //    .o_full(o_status_tick[8])
  // );
  // User logic ends

  endmodule
