`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka
// 
// Create Date: 09/23/2021 10:07:36 AM
// Design Name: Kyber512_CCAKEM
// Module Name: Kyber512_CCAKEM_IP_tb
// Project Name: Kyber512_CCAKEM
// Target Devices: Virtex-7
// Tool Versions: 2019.1
// Description: Kyber512_CCAKEM AXi IP testbench. 
// Reference: https://www.realdigital.org/doc/32101c99686fe25ec47bedd94e76dc96
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define P 10

module Kyber512_CCAKEM_IP_tb;

localparam C_S_AXI_DATA_WIDTH  = 32;

localparam BYTE_BITS           = 8;
localparam KYBER_512_SKBytes   = 1632;
localparam KYBER_512_PKBytes   = 800;
localparam KYBER_512_CtBytes   = 736;
localparam KYBER_512_SSBytes   = 32;
localparam KYBER_512_RandBytes = 32;
localparam RAND_SZ             = BYTE_BITS * KYBER_512_RandBytes;
localparam CIPHERTEXT_SZ       = BYTE_BITS * KYBER_512_CtBytes;
localparam SECRET_KEY_SZ       = BYTE_BITS * KYBER_512_SKBytes;
localparam SHARED_SECRET_SZ    = BYTE_BITS * KYBER_512_SSBytes;
localparam PUBLIC_KEY_SZ       = BYTE_BITS * KYBER_512_PKBytes;

// Random bytes
reg [RAND_SZ-1 : 0] RAND = 256'h86a6ee272f1428dda0178f96f2962e8210e175967d0926406e9698ed673cbe4d;

// Public key
reg [PUBLIC_KEY_SZ-1 : 0] PK = 6400'h27f3382ceab540148f40662312162bd9f9b8b3768a842652fbb1211fe62614bbb9acd7276f38912773142d6718fc6b0ba471346e687e280276b90090bff043cef3ab2f4076b1c3071cb04be006b711fabcd51784f53c59605b58461275ddbbc8d82167a757bdce3c42c2852aaa4675eaa4cb2b33cce1c0707169cad6e70e1e719971d4c9bb52184cfbc9fcb6638cfb461b4b3903eb520832ab751c4f443ca0e258508ad16b72e22bd9c1842f4c37c340b1924c350a693821a18d8b38c0d1bc41906711071657b4fc92aa79930eec14b2bb1493e955386094e93c58998083b938c5acc16e22719103199dcf3c6d123c2276145946a8397cc6c090515dba20b46f99caec4bac00d013e2464607ba1d66c2b41ae6955b0599d7f83cd6083bc8b392a08c1e930171360a906afcc6e2f5c67fbb2b28404f12353307cc3c1fd23c321a4a8cebc63d720311c50a40e78fbb8827699620665c0debe82f75ea5c2f543fe1ba64f2279bf804b77fa903f6d526294461a2c05e4595af063014e873549c7596299b4b7e9bc6cfe71d982b2036e6092d53c0bd2709ae13472a3a8799b75afef5c564a874b7f39664a5c057e34176938433a1695313cc57717f54fb1e16868529d292780ca720b95401475208dcad820649a65a4f809123b7f8af7446511cc90d0814079706c593b4091913ae65c812460a435991b541d835b8d9b76e5c44bf53207df5b18db652c2c8c86c15724898b1754c4f9c7491b6c130f222bd1502af1095bd34cb43894b22e5935b6c9211d5cb8c998a546ed39e5893aca9f5a168ea245153a563662922040f68ec6e3250ae52ab71f8a1ace8cc303796a6f793bc2c078b13256fbde5b2bea7b8e242acba3c6aa4315429dabeacec2d241b37413b2567331220c4c681fabb2807ca69c496228240ddf990710426a1a0cd0c9b5275e4cfc06794b6985eb332bf82a89661c143b63cc634638a3edb5af045ca3da43e32818614b6579c783367a904f5197f622a4d5293cda564285b80c72fbc530c98421f64312440703ac8a128956fa359b2314837f888c60da777869a7dd7707add737cf1485befd898e03825c4f0215ba14afb2f04772faaeafc2f8e39052044193781;

// Secret key
reg [SECRET_KEY_SZ-1 : 0] SK = 13056'h6107ab70727cf5684b162c3fd5e52fb154a9f868c9a990c0aa8436a1e871ea0463588b861e62913bb4a7965b9751d0785397ab2815a5156c1a25e86f4df870855b8699862c35e79dd302066fb8908c5ab1dbb4a368a674a2870fe02b679c0812baa33c8422c3b6f8a9d3870a66a40e8c605782234e77947806d85df0617d5ba369850950507863a4aa3125e415e26c4c9027cca85a3d2c513523d40868ab46373bb43f15823505455f4808d812065cd87862843c55002e31a80b29ea1b2dc658d2885cba792626b73fc9429f1c69a772f34561914b8c01469fda8d92447028f6955e021a1792cf743b364f51896a8a4ac9c7a574c0b23b9214bc948978259011611bb97aca5de3b4d0b946683976d2d8b54b30bb6ae79673970490baab1e625031152781c95c53795a3d7a05791bc2b5175c40cba3818b164b0bb0f7e8cd096097c1635231958c63d3cdbff3cdc3e0785d0371323c43095b492bf17d61f22ce099c9a1f573fc946563273d1869b62cfc06fbfa5cdfd7c604a74f87cb21db347f8443710e5cc63825bdc255c28df5236ba976086445c184380008ae72b0ab9e1806e02cc273194f95a6350a98b9435722236a64a09896dc5750fd29c2fc4730a59158c30c4a1917740924bf3d885ad7851c16ab02c41210c208aea5fa50a22cb1b6b14a934a59a2237581458822e7c578361f702b05b7f9c52fb53ada443d2d9c897cc14ceea3ada5b33c471cc377627bfdd29a628582367210f4422b92219b97dc0a4315aa40ca20c349ba0ebab3429a8a80a885c5fbab97958121a45703b8693bc8c40a963b652c1c3dfaca811625dc0087c1151d114981c67b929f1786ed843c91b5bdeef013df683798d5706603bb6a4c93de125a1c8b75f504a3820682038323819caafc181c45a60306843b6a1548c35741f06c06538ca00b671ac5d2ca90f14e4578a746ca7de6260684d77e497769aee956354c489515711c208737a34ee8d34b24982a4541b40fd860956c2b8dd00d0bda57b7a5a3d9b469ffd590d6e3468ca6769ff575309287b362c1a0fa6f20a333fcc116aa3a5c8a7b8eee978727f3382ceab540148f40662312162bd9f9b8b3768a842652fbb1211fe62614bbb9acd7276f38912773142d6718fc6b0ba471346e687e280276b90090bff043cef3ab2f4076b1c3071cb04be006b711fabcd51784f53c59605b58461275ddbbc8d82167a757bdce3c42c2852aaa4675eaa4cb2b33cce1c0707169cad6e70e1e719971d4c9bb52184cfbc9fcb6638cfb461b4b3903eb520832ab751c4f443ca0e258508ad16b72e22bd9c1842f4c37c340b1924c350a693821a18d8b38c0d1bc41906711071657b4fc92aa79930eec14b2bb1493e955386094e93c58998083b938c5acc16e22719103199dcf3c6d123c2276145946a8397cc6c090515dba20b46f99caec4bac00d013e2464607ba1d66c2b41ae6955b0599d7f83cd6083bc8b392a08c1e930171360a906afcc6e2f5c67fbb2b28404f12353307cc3c1fd23c321a4a8cebc63d720311c50a40e78fbb8827699620665c0debe82f75ea5c2f543fe1ba64f2279bf804b77fa903f6d526294461a2c05e4595af063014e873549c7596299b4b7e9bc6cfe71d982b2036e6092d53c0bd2709ae13472a3a8799b75afef5c564a874b7f39664a5c057e34176938433a1695313cc57717f54fb1e16868529d292780ca720b95401475208dcad820649a65a4f809123b7f8af7446511cc90d0814079706c593b4091913ae65c812460a435991b541d835b8d9b76e5c44bf53207df5b18db652c2c8c86c15724898b1754c4f9c7491b6c130f222bd1502af1095bd34cb43894b22e5935b6c9211d5cb8c998a546ed39e5893aca9f5a168ea245153a563662922040f68ec6e3250ae52ab71f8a1ace8cc303796a6f793bc2c078b13256fbde5b2bea7b8e242acba3c6aa4315429dabeacec2d241b37413b2567331220c4c681fabb2807ca69c496228240ddf990710426a1a0cd0c9b5275e4cfc06794b6985eb332bf82a89661c143b63cc634638a3edb5af045ca3da43e32818614b6579c783367a904f5197f622a4d5293cda564285b80c72fbc530c98421f64312440703ac8a128956fa359b2314837f888c60da777869a7dd7707add737cf1485befd898e03825c4f0215ba14afb2f04772faaeafc2f8e390520441937812deead50ab189a72080c25aeed7c3d17e8b4b3b934137bf81ee74803696cd7aaf1b88ecdf1359a452ed822314e06e7456a2224dc2da93f93f81f817bf690169c;

// Ciphertext
reg [5887:0] CT = 5888'ha5a2adc5382c25f445ec7ef5e81087f85cece8eddb2e313957472c9588f4eb6b04b2b02c7fed37c6cc68034b8e7dda5143698c3eec65575ef5642b73cb8e2fbd292d54eb67e8225ca3e233628a11c6e03bf1fc6b6e4a7f4f0f765de407f41150d23e06164a35be0c5105a594328949aebbd7acc26c2f300126540018df01d44f95b454899eaa31be015701fed1a79ce82d410036f66ec8dcaae3d75c394f814a613f9b3f68b41fad06b655fe8eec2382ce9dc0ddb7826f4ff3cefdfdad4c2262a33b461217035cc6cbbe4191205df051b9f394aeafe02a1f2dce5792be48c91dff76b02476840d25592c5e8e3b0766b8ff1c77467fac88cdd4a564cfbb2fd24b9730eb17d19a49fb403f334e572d2541fb3c47f1be4d86b76565907cc62377629472b980830d6a310cdd8bb0042399bf1e3539d3d29118e94e9d08ad55e6d53093eed6b64fc2b49691a1f9e43cf93e05e77fc0be5e152b4206d41bd6ed488866a455c663910751329a0f10d8a7378f2055f1c8a95e58462b71cd555806a50d09ba1d493e81fd9f3e29ad1a070375bcde48ef5a11614d86b4a5439c6ea09f4bbfe16895e4113fe72ce4233504d5b0719d851c2b149421e2e547744399aeb44c683e1904b8e6518932ad2e10e9f59961b8592a26da6b0a32b323537f9ebd5e98ae5a2157cae573251eed791648a9baf250dd3b14e5fbb2793cbc5f15ac92c8862b8e8bd989cfe87ddef3c19b17cea61119dd9eb759ec4869b16bd19f42899d50c9564c7821d77bec27fda6703c95f9029bd2963986ee4ba33b2a5ea5fcdb91e465d5751e2922c3540b09a2fa18d1396b0d7d61dc362692ca8d8580aeed6ac2a9d290d9f99c2fd52ca298a9d8d8f72b10b118abb5f4284d7b81639298825d27587a3baa9f9f93e83172e6905dfaa9725dfa012165a812c07a659e9389892063c76cfdf6cad1cf469c919299d86f62d6bf0f4692ee0cb08b3c0cf2a118651f0db3edb1d1f72d38ff09d2884b00c2a380e727760239f1532c345638f8d1ed7ebb41e7;

// Shared secret
reg [255:0] expected_shared_secret = 256'h5955e27b0a4bb2c1279fe11780b8a9d78f42e360faa6a94fdff417666569b91b;

//clock and reset_n signals
reg aclk  = 1'b0;
reg arstn = 1'b0;

// AXI Interface signals
// S00_AXI Channel
//Write Address channel (AW)
reg [31:0] s00_write_addr       = 32'd0;	//Master write address
reg [2:0]  s00_write_prot       = 3'd0;	  //type of write(leave at 0)
reg        s00_write_addr_valid = 1'b0;	  //master indicating address is valid
wire       s00_write_addr_ready;		      //slave ready to receive address

//Write Data Channel (W)
reg [31:0] s00_write_data = 32'd0;	//Master write data
reg [ 3:0] s00_write_strb = 4'd0;	  //Master byte-wise write strobe
reg        s00_write_data_valid = 1'b0;	  //Master indicating write data is valid
wire       s00_write_data_ready;		      //slave ready to receive data

//Write Response Channel (WR)
reg        s00_write_resp_ready = 1'b0;	//Master ready to receive write response
wire [1:0] s00_write_resp;		    //slave write response
wire       s00_write_resp_valid;		    //slave response valid

//Read Address channel (AR)
reg [31:0] s00_read_addr = 32'd0;	//Master read address
reg [ 2:0] s00_read_prot = 3'd0;	  //type of read(leave at 0)
reg        s00_read_addr_valid = 1'b0;	  //Master indicating address is valid
wire       s00_read_addr_ready;		      //slave ready to receive address

//Read Data Channel (R)
reg         s00_read_data_ready = 1'b0;	  //Master indicating ready to receive data
wire [31:0] s00_read_data;		    //slave read data
wire [1:0]  s00_read_resp;		      //slave read response
wire        s00_read_data_valid;		      //slave indicating data in channel is valid

// S01_AXI Channel
//Write Address channel (AW)
reg [31:0] s01_write_addr       = 32'd0;	//Master write address
reg [2:0]  s01_write_prot       = 3'd0;	  //type of write(leave at 0)
reg        s01_write_addr_valid = 1'b0;	  //master indicating address is valid
wire       s01_write_addr_ready;		      //slave ready to receive address

//Write Data Channel (W)
reg [31:0] s01_write_data = 32'd0;	//Master write data
reg [ 3:0] s01_write_strb = 4'd0;	  //Master byte-wise write strobe
reg        s01_write_data_valid = 1'b0;	  //Master indicating write data is valid
wire       s01_write_data_ready;		      //slave ready to receive data

//Write Response Channel (WR)
reg        s01_write_resp_ready = 1'b0;	//Master ready to receive write response
wire [1:0] s01_write_resp;		    //slave write response
wire       s01_write_resp_valid;		    //slave response valid

//Read Address channel (AR)
reg [31:0] s01_read_addr = 32'd0;	//Master read address
reg [ 2:0] s01_read_prot = 3'd0;	  //type of read(leave at 0)
reg        s01_read_addr_valid = 1'b0;	  //Master indicating address is valid
wire       s01_read_addr_ready;		      //slave ready to receive address

//Read Data Channel (R)
reg         s01_read_data_ready = 1'b0;	  //Master indicating ready to receive data
wire [31:0] s01_read_data;		    //slave read data
wire [1:0]  s01_read_resp;		      //slave read response
wire        s01_read_data_valid;		      //slave indicating data in channel is valid


//LED output of the IPcore
wire [SHARED_SECRET_SZ-1:0] w_oshared_secret;
wire [   CIPHERTEXT_SZ-1:0] w_ociphertext;
wire                        w_function_done;
wire                        w_trigger1;
wire                        w_trigger2;

//Instantiation of LED IP
Kyber512_CCAKEM_IP_v1_0 # (
  .C_S_AXI_DATA_WIDTH(32),
  .C_S_AXI_ADDR_WIDTH(32)
) DUT (

  // Ports of Kyber512 Interface
  .kyber_aclk(aclk),
  .kyber_aresetn(arstn),
  .trigger1(w_trigger1),
  .trigger2(w_trigger2),
  .debug_function_done(w_function_done),
  .o_ciphertext(w_ociphertext),
  .o_shared_secret(w_oshared_secret),

  // Ports of Axi Slave Bus Interface S00_AXI
  .s00_axi_aclk(aclk),
  .s00_axi_aresetn(arstn),

  .s00_axi_awaddr(s00_write_addr),
  .s00_axi_awprot(s00_write_prot),
  .s00_axi_awvalid(s00_write_addr_valid),
  .s00_axi_awready(s00_write_addr_ready),

  .s00_axi_wdata(s00_write_data),
  .s00_axi_wstrb(s00_write_strb),
  .s00_axi_wvalid(s00_write_data_valid),
  .s00_axi_wready(s00_write_data_ready),

  .s00_axi_bresp(s00_write_resp),
  .s00_axi_bvalid(s00_write_resp_valid),
  .s00_axi_bready(s00_write_resp_ready),

  .s00_axi_araddr(s00_read_addr),
  .s00_axi_arprot(s00_read_prot),
  .s00_axi_arvalid(s00_read_addr_valid),
  .s00_axi_arready(s00_read_addr_ready),

  .s00_axi_rdata(s00_read_data),
  .s00_axi_rresp(s00_read_resp),
  .s00_axi_rvalid(s00_read_data_valid),
  .s00_axi_rready(s00_read_data_ready),

  // Ports of Axi Slave Bus Interface S01_AXI
  .s01_axi_aclk(aclk),
  .s01_axi_aresetn(arstn),

  .s01_axi_awaddr(s01_write_addr),
  .s01_axi_awprot(s01_write_prot),
  .s01_axi_awvalid(s01_write_addr_valid),
  .s01_axi_awready(s01_write_addr_ready),

  .s01_axi_wdata(s01_write_data),
  .s01_axi_wstrb(s01_write_strb),
  .s01_axi_wvalid(s01_write_data_valid),
  .s01_axi_wready(s01_write_data_ready),

  .s01_axi_bresp(s01_write_resp),
  .s01_axi_bvalid(s01_write_resp_valid),
  .s01_axi_bready(s01_write_resp_ready),

  .s01_axi_araddr(s01_read_addr),
  .s01_axi_arprot(s01_read_prot),
  .s01_axi_arvalid(s01_read_addr_valid),
  .s01_axi_arready(s01_read_addr_ready),

  .s01_axi_rdata(s01_read_data),
  .s01_axi_rresp(s01_read_resp),
  .s01_axi_rvalid(s01_read_data_valid),
  .s01_axi_rready(s01_read_data_ready)
);

//clock signal
always
  #5 aclk <= ~aclk;


// Testbench
integer i;	
initial
begin
  // Reset IP Core
  #(`P);  arstn = 0;
  #(`P);  arstn = 1;
  #(`P*10); // Idle

  // Encapsulation
  // Reset Kyber512 CCAKEM module
  #(`P); s00_axi_write(32'd0, 32'h00000000);
  // #(`P); s00_axi_write(32'd0, 32'h80000000);
  #(`P*10); // Idle

  // Set device mode to decapsulation
  #(`P); s00_axi_write(32'd0, 32'h80000000);
  #(`P*10); // Idle

  // Write random bytes
  #(`P); s00_axi_write(32'd0, 32'h80000004);
  for (i=0; i < (RAND_SZ/C_S_AXI_DATA_WIDTH); i=i+1) begin
    #(`P);
    // slv_reg1: addr
    s01_axi_write(32'd4, i); 
    // slv_reg0: data
    s01_axi_write(32'd0, RAND[RAND_SZ-(i*C_S_AXI_DATA_WIDTH)-1 -: C_S_AXI_DATA_WIDTH]); 
  end

  // Write public key
  #(`P); s00_axi_write(32'd0, 32'h80000008);
  for (i=0; i < (PUBLIC_KEY_SZ/C_S_AXI_DATA_WIDTH); i=i+1) begin
    #(`P); 
    // slv_reg1: addr
    s01_axi_write(32'd4, i);
    // slv_reg0: data
    s01_axi_write(32'd0, PK[PUBLIC_KEY_SZ-(i*C_S_AXI_DATA_WIDTH)-1 -: C_S_AXI_DATA_WIDTH]);
  end

  // Enable device
  #(`P); s00_axi_write(32'd0, 32'h80000002);
  #(`P*10); // Idle

  while(w_function_done == 1'b0) #(`P);
  #(`P);  check5888(w_ociphertext, CT);
          check256(w_oshared_secret, expected_shared_secret);

  // End Encapsulation test

  // Decapsulation
  // Reset Kyber512 CCAKEM module
  #(`P); s00_axi_write(32'd0, 32'h00000000);
  // #(`P); s00_axi_write(32'd0, 32'h80000000);
  #(`P*10); // Idle

  // Set device mode to decapsulation
  #(`P); s00_axi_write(32'd0, 32'h80000001);
  #(`P*10); // Idle

  // Write secret key
  #(`P); s00_axi_write(32'd0, 32'h80000009);
  for (i=0; i < (SECRET_KEY_SZ/C_S_AXI_DATA_WIDTH); i=i+1) begin
    #(`P);
    // slv_reg1: addr
    s01_axi_write(32'd4, i); 
    // slv_reg0: data
    s01_axi_write(32'd0, SK[SECRET_KEY_SZ-(i*C_S_AXI_DATA_WIDTH)-1 -: C_S_AXI_DATA_WIDTH]); 
  end

  // Write ciphertext
  #(`P); s00_axi_write(32'd0, 32'h80000005);
  for (i=0; i < (CIPHERTEXT_SZ/C_S_AXI_DATA_WIDTH); i=i+1) begin
    #(`P); 
    // slv_reg1: addr
    s01_axi_write(32'd4, i);
    // slv_reg0: data
    s01_axi_write(32'd0, CT[CIPHERTEXT_SZ-(i*C_S_AXI_DATA_WIDTH)-1 -: C_S_AXI_DATA_WIDTH]);
  end


  // Enable device
  #(`P); s00_axi_write(32'd0, 32'h80000003);
  #(`P*10); // Idle

  while(w_function_done == 1'b0) #(`P);
  #(`P);  check256(w_oshared_secret, expected_shared_secret);

  $finish;
end


// AXI Write tasks
task s00_axi_write;
  input [31:0] addr;
  input [31:0] data;
  begin
    #3 s00_write_addr <= addr;	//Put write address on bus
    s00_write_data <= data;	//put write data on bus
    s00_write_addr_valid <= 1'b1;	//indicate address is valid
    s00_write_data_valid <= 1'b1;	//indicate data is valid
    s00_write_resp_ready <= 1'b1;	//indicate ready for a response
    s00_write_strb <= 4'hF;		//writing all 4 bytes

    //wait for one slave ready signal or the other
    wait(s00_write_data_ready || s00_write_addr_ready);
      
    @(posedge aclk); //one or both signals and a positive edge
    if(s00_write_data_ready && s00_write_addr_ready)//received both ready signals
    begin
      s00_write_addr_valid<=0;
      s00_write_data_valid<=0;
    end
    else    //wait for the other signal and a positive edge
    begin
      if(s00_write_data_ready)    //case data handshake completed
      begin
        s00_write_data_valid<=0;
        wait(s00_write_addr_ready); //wait for address address ready
      end
      else if(s00_write_addr_ready)   //case address handshake completed
      begin
        s00_write_addr_valid<=0;
        wait(s00_write_data_ready); //wait for data ready
      end 
      @(posedge aclk);// complete the second handshake
      s00_write_addr_valid<=0; //make sure both valid signals are deasserted
      s00_write_data_valid<=0;
    end
            
    //both handshakes have occured
    //deassert strobe
    s00_write_strb<=0;

    //wait for valid response
    wait(s00_write_resp_valid);
    
    //both handshake signals and rising edge
    @(posedge aclk);

    //deassert ready for response
    s00_write_resp_ready<=0;

    //end of write transaction
  end
endtask

task s01_axi_write;
  input [31:0] addr;
  input [31:0] data;
  begin
    #3 s01_write_addr <= addr;	//Put write address on bus
    s01_write_data <= data;	//put write data on bus
    s01_write_addr_valid <= 1'b1;	//indicate address is valid
    s01_write_data_valid <= 1'b1;	//indicate data is valid
    s01_write_resp_ready <= 1'b1;	//indicate ready for a response
    s01_write_strb <= 4'hF;		//writing all 4 bytes

    //wait for one slave ready signal or the other
    wait(s01_write_data_ready || s01_write_addr_ready);
      
    @(posedge aclk); //one or both signals and a positive edge
    if(s01_write_data_ready && s01_write_addr_ready)//received both ready signals
    begin
      s01_write_addr_valid<=0;
      s01_write_data_valid<=0;
    end
    else    //wait for the other signal and a positive edge
    begin
      if(s01_write_data_ready)    //case data handshake completed
      begin
        s01_write_data_valid<=0;
        wait(s01_write_addr_ready); //wait for address address ready
      end
      else if(s01_write_addr_ready)   //case address handshake completed
      begin
        s01_write_addr_valid<=0;
        wait(s01_write_data_ready); //wait for data ready
      end 
      @(posedge aclk);// complete the second handshake
      s01_write_addr_valid<=0; //make sure both valid signals are deasserted
      s01_write_data_valid<=0;
    end
            
    //both handshakes have occured
    //deassert strobe
    s01_write_strb<=0;

    //wait for valid response
    wait(s01_write_resp_valid);
    
    //both handshake signals and rising edge
    @(posedge aclk);

    //deassert ready for response
    s01_write_resp_ready<=0;

    //end of write transaction
  end
endtask


task error;
  begin
    $display("Error!");
    $finish;
  end
endtask
    
task check256;
  input [256-1:0] out;
  input [256-1:0] wish;
  begin
    $display("Checking shared secret...");
    if (out !== wish)
      begin
        $display("Wish: %h\nOutput: %h", wish, out); error;
      end
      
    $display("Shared secret... OK");
  end
endtask

task check5888;
  input [5888-1:0] out;
  input [5888-1:0] wish;
  begin
    $display("Checking ciphertext...");
    if (out !== wish)
      begin
        $display("Wish: %h\nOutput: %h", wish, out); error;
      end
      
    $display("Ciphertext... OK");
  end
endtask

endmodule

`undef P
