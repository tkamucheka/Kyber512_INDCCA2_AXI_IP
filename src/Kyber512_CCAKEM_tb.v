`timescale 1ns / 1ps

`define P 10

module Kyber512_CCAKEM_tb;

localparam KYBER_K             = 2;
localparam KYBER_N             = 256;
localparam KYBER_Q             = 3329;
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

reg clk           = 0;
reg rst_n         = 1;
reg enable        = 0;
reg i_mux_enc_dec = 0;

reg                         mem_load = 0;

wire                        w_mem_ready;
wire [4:0]                  w_rand_CT_RAd;
wire [5:0]                  w_PK_SK_RAd;
wire [255:0]                w_rand_CT_RData;
wire [255:0]                w_PK_SK_RData;
wire                        w_function_done;
wire [   CIPHERTEXT_SZ-1:0] w_ociphertext;
wire [SHARED_SECRET_SZ-1:0] w_oshared_secret;

wire [1 : 0]  cstate_flag;
wire          Cal_flag;
wire          Function_Done;
wire          Verify;
wire          trigger1, trigger2;

// Inputs
// Random bytes
reg [RAND_SZ-1 : 0] i_Random = 256'h86a6ee272f1428dda0178f96f2962e8210e175967d0926406e9698ed673cbe4d;

// Public key
reg [PUBLIC_KEY_SZ-1 : 0] PK = 6400'h27f3382ceab540148f40662312162bd9f9b8b3768a842652fbb1211fe62614bbb9acd7276f38912773142d6718fc6b0ba471346e687e280276b90090bff043cef3ab2f4076b1c3071cb04be006b711fabcd51784f53c59605b58461275ddbbc8d82167a757bdce3c42c2852aaa4675eaa4cb2b33cce1c0707169cad6e70e1e719971d4c9bb52184cfbc9fcb6638cfb461b4b3903eb520832ab751c4f443ca0e258508ad16b72e22bd9c1842f4c37c340b1924c350a693821a18d8b38c0d1bc41906711071657b4fc92aa79930eec14b2bb1493e955386094e93c58998083b938c5acc16e22719103199dcf3c6d123c2276145946a8397cc6c090515dba20b46f99caec4bac00d013e2464607ba1d66c2b41ae6955b0599d7f83cd6083bc8b392a08c1e930171360a906afcc6e2f5c67fbb2b28404f12353307cc3c1fd23c321a4a8cebc63d720311c50a40e78fbb8827699620665c0debe82f75ea5c2f543fe1ba64f2279bf804b77fa903f6d526294461a2c05e4595af063014e873549c7596299b4b7e9bc6cfe71d982b2036e6092d53c0bd2709ae13472a3a8799b75afef5c564a874b7f39664a5c057e34176938433a1695313cc57717f54fb1e16868529d292780ca720b95401475208dcad820649a65a4f809123b7f8af7446511cc90d0814079706c593b4091913ae65c812460a435991b541d835b8d9b76e5c44bf53207df5b18db652c2c8c86c15724898b1754c4f9c7491b6c130f222bd1502af1095bd34cb43894b22e5935b6c9211d5cb8c998a546ed39e5893aca9f5a168ea245153a563662922040f68ec6e3250ae52ab71f8a1ace8cc303796a6f793bc2c078b13256fbde5b2bea7b8e242acba3c6aa4315429dabeacec2d241b37413b2567331220c4c681fabb2807ca69c496228240ddf990710426a1a0cd0c9b5275e4cfc06794b6985eb332bf82a89661c143b63cc634638a3edb5af045ca3da43e32818614b6579c783367a904f5197f622a4d5293cda564285b80c72fbc530c98421f64312440703ac8a128956fa359b2314837f888c60da777869a7dd7707add737cf1485befd898e03825c4f0215ba14afb2f04772faaeafc2f8e39052044193781;

// Ciphertext
reg [5887:0] CT = 5888'ha5a2adc5382c25f445ec7ef5e81087f85cece8eddb2e313957472c9588f4eb6b04b2b02c7fed37c6cc68034b8e7dda5143698c3eec65575ef5642b73cb8e2fbd292d54eb67e8225ca3e233628a11c6e03bf1fc6b6e4a7f4f0f765de407f41150d23e06164a35be0c5105a594328949aebbd7acc26c2f300126540018df01d44f95b454899eaa31be015701fed1a79ce82d410036f66ec8dcaae3d75c394f814a613f9b3f68b41fad06b655fe8eec2382ce9dc0ddb7826f4ff3cefdfdad4c2262a33b461217035cc6cbbe4191205df051b9f394aeafe02a1f2dce5792be48c91dff76b02476840d25592c5e8e3b0766b8ff1c77467fac88cdd4a564cfbb2fd24b9730eb17d19a49fb403f334e572d2541fb3c47f1be4d86b76565907cc62377629472b980830d6a310cdd8bb0042399bf1e3539d3d29118e94e9d08ad55e6d53093eed6b64fc2b49691a1f9e43cf93e05e77fc0be5e152b4206d41bd6ed488866a455c663910751329a0f10d8a7378f2055f1c8a95e58462b71cd555806a50d09ba1d493e81fd9f3e29ad1a070375bcde48ef5a11614d86b4a5439c6ea09f4bbfe16895e4113fe72ce4233504d5b0719d851c2b149421e2e547744399aeb44c683e1904b8e6518932ad2e10e9f59961b8592a26da6b0a32b323537f9ebd5e98ae5a2157cae573251eed791648a9baf250dd3b14e5fbb2793cbc5f15ac92c8862b8e8bd989cfe87ddef3c19b17cea61119dd9eb759ec4869b16bd19f42899d50c9564c7821d77bec27fda6703c95f9029bd2963986ee4ba33b2a5ea5fcdb91e465d5751e2922c3540b09a2fa18d1396b0d7d61dc362692ca8d8580aeed6ac2a9d290d9f99c2fd52ca298a9d8d8f72b10b118abb5f4284d7b81639298825d27587a3baa9f9f93e83172e6905dfaa9725dfa012165a812c07a659e9389892063c76cfdf6cad1cf469c919299d86f62d6bf0f4692ee0cb08b3c0cf2a118651f0db3edb1d1f72d38ff09d2884b00c2a380e727760239f1532c345638f8d1ed7ebb41e7;

// Secret key
reg [SECRET_KEY_SZ-1 : 0] SK = 13056'h6107ab70727cf5684b162c3fd5e52fb154a9f868c9a990c0aa8436a1e871ea0463588b861e62913bb4a7965b9751d0785397ab2815a5156c1a25e86f4df870855b8699862c35e79dd302066fb8908c5ab1dbb4a368a674a2870fe02b679c0812baa33c8422c3b6f8a9d3870a66a40e8c605782234e77947806d85df0617d5ba369850950507863a4aa3125e415e26c4c9027cca85a3d2c513523d40868ab46373bb43f15823505455f4808d812065cd87862843c55002e31a80b29ea1b2dc658d2885cba792626b73fc9429f1c69a772f34561914b8c01469fda8d92447028f6955e021a1792cf743b364f51896a8a4ac9c7a574c0b23b9214bc948978259011611bb97aca5de3b4d0b946683976d2d8b54b30bb6ae79673970490baab1e625031152781c95c53795a3d7a05791bc2b5175c40cba3818b164b0bb0f7e8cd096097c1635231958c63d3cdbff3cdc3e0785d0371323c43095b492bf17d61f22ce099c9a1f573fc946563273d1869b62cfc06fbfa5cdfd7c604a74f87cb21db347f8443710e5cc63825bdc255c28df5236ba976086445c184380008ae72b0ab9e1806e02cc273194f95a6350a98b9435722236a64a09896dc5750fd29c2fc4730a59158c30c4a1917740924bf3d885ad7851c16ab02c41210c208aea5fa50a22cb1b6b14a934a59a2237581458822e7c578361f702b05b7f9c52fb53ada443d2d9c897cc14ceea3ada5b33c471cc377627bfdd29a628582367210f4422b92219b97dc0a4315aa40ca20c349ba0ebab3429a8a80a885c5fbab97958121a45703b8693bc8c40a963b652c1c3dfaca811625dc0087c1151d114981c67b929f1786ed843c91b5bdeef013df683798d5706603bb6a4c93de125a1c8b75f504a3820682038323819caafc181c45a60306843b6a1548c35741f06c06538ca00b671ac5d2ca90f14e4578a746ca7de6260684d77e497769aee956354c489515711c208737a34ee8d34b24982a4541b40fd860956c2b8dd00d0bda57b7a5a3d9b469ffd590d6e3468ca6769ff575309287b362c1a0fa6f20a333fcc116aa3a5c8a7b8eee978727f3382ceab540148f40662312162bd9f9b8b3768a842652fbb1211fe62614bbb9acd7276f38912773142d6718fc6b0ba471346e687e280276b90090bff043cef3ab2f4076b1c3071cb04be006b711fabcd51784f53c59605b58461275ddbbc8d82167a757bdce3c42c2852aaa4675eaa4cb2b33cce1c0707169cad6e70e1e719971d4c9bb52184cfbc9fcb6638cfb461b4b3903eb520832ab751c4f443ca0e258508ad16b72e22bd9c1842f4c37c340b1924c350a693821a18d8b38c0d1bc41906711071657b4fc92aa79930eec14b2bb1493e955386094e93c58998083b938c5acc16e22719103199dcf3c6d123c2276145946a8397cc6c090515dba20b46f99caec4bac00d013e2464607ba1d66c2b41ae6955b0599d7f83cd6083bc8b392a08c1e930171360a906afcc6e2f5c67fbb2b28404f12353307cc3c1fd23c321a4a8cebc63d720311c50a40e78fbb8827699620665c0debe82f75ea5c2f543fe1ba64f2279bf804b77fa903f6d526294461a2c05e4595af063014e873549c7596299b4b7e9bc6cfe71d982b2036e6092d53c0bd2709ae13472a3a8799b75afef5c564a874b7f39664a5c057e34176938433a1695313cc57717f54fb1e16868529d292780ca720b95401475208dcad820649a65a4f809123b7f8af7446511cc90d0814079706c593b4091913ae65c812460a435991b541d835b8d9b76e5c44bf53207df5b18db652c2c8c86c15724898b1754c4f9c7491b6c130f222bd1502af1095bd34cb43894b22e5935b6c9211d5cb8c998a546ed39e5893aca9f5a168ea245153a563662922040f68ec6e3250ae52ab71f8a1ace8cc303796a6f793bc2c078b13256fbde5b2bea7b8e242acba3c6aa4315429dabeacec2d241b37413b2567331220c4c681fabb2807ca69c496228240ddf990710426a1a0cd0c9b5275e4cfc06794b6985eb332bf82a89661c143b63cc634638a3edb5af045ca3da43e32818614b6579c783367a904f5197f622a4d5293cda564285b80c72fbc530c98421f64312440703ac8a128956fa359b2314837f888c60da777869a7dd7707add737cf1485befd898e03825c4f0215ba14afb2f04772faaeafc2f8e390520441937812deead50ab189a72080c25aeed7c3d17e8b4b3b934137bf81ee74803696cd7aaf1b88ecdf1359a452ed822314e06e7456a2224dc2da93f93f81f817bf690169c;

// Shared secret
reg [255:0] expected_shared_secret = 256'h5955e27b0a4bb2c1279fe11780b8a9d78f42e360faa6a94fdff417666569b91b;

MEM_LOADER P0 (
  .i_clk(clk),
  .i_rst_n(rst_n),
  .i_enable(mem_load),
  .i_mode(i_mux_enc_dec),
  .i_random(i_Random),
  .i_public_key(PK),
  .i_ciphertext(CT),
  .i_secret_key(SK),
  .o_done(w_mem_ready),
  // CCAKEM Input
  .i_rand_CT_RAd(w_rand_CT_RAd),
  .i_PK_SK_RAd(w_PK_SK_RAd),
  .o_rand_CT_RData(w_rand_CT_RData),
  .o_PK_SK_RData(w_PK_SK_RData),
  // CCAKEM Output
  .i_function_done(w_function_done),
  .i_ociphertext(w_ociphertext),
  .i_oshared_secret(w_oshared_secret)
);

Kyber512_INDCCA DUT (
.i_clk(clk),
.i_reset_n(rst_n),
.i_enable(enable),
.i_mux_enc_dec(i_mux_enc_dec),
// INDCCA_ENC:
// .i_random(i_Random),
// .i_public_key(PK),
.o_ciphertext(w_ociphertext),
// INDCCA_DEC:
// .i_ciphertext(w_ociphertext),
// .i_secret_key(SK),
.o_verify_fail(Verify),
// INDCCA_SHARED:
.i_rand_CT_RData(w_rand_CT_RData),
.i_PK_SK_RData(w_PK_SK_RData),
.o_rand_CT_RAd(w_rand_CT_RAd),
.o_PK_SK_RAd(w_PK_SK_RAd),
.o_function_done(Function_Done),
.o_shared_secret(w_oshared_secret),
// DEBUG:
.o_cal_flag(Cal_flag),
.o_cstate_flag(cstate_flag),
.trigger1(trigger1),
.trigger2(trigger2)
);
 
initial begin
#(`P); rst_n = 0;
#(`P); rst_n = 1;

#(`P*10) // idle

// Encapsulation
// Load BRAMs
#(`P);  i_mux_enc_dec = 1'b0;
        mem_load = 1;
#(`P);  mem_load = 0;
while (w_mem_ready !== 1'b1) #(`P);

// Enable
        enable = 1;
#(`P);  enable = 0;

while (Function_Done !== 1'b1) #(`P);
#(`P);  check5888(w_ociphertext, CT);
        check256(w_oshared_secret, expected_shared_secret);

$display("INDCCA Encapsulation... SUCCESS");

// System reset
#(`P) rst_n = 0;
#(`P) rst_n = 1;
#(`P*10) // wait a while after reset

// Decapsulation
// Load BRAMs
#(`P);  i_mux_enc_dec = 1;
        mem_load = 1;
#(`P);  mem_load = 0;
while (w_mem_ready !== 1'b1) #(`P);

// Enable
        enable = 1;
#(`P);  enable = 0;

while (Function_Done !== 1'b1) #(`P);
        check256(w_oshared_secret, expected_shared_secret);

$display("INDCCA Decapsulation... SUCCESS");
$finish;
end

// Clock generator
always #(`P/2) clk = ~clk;

// tasks
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