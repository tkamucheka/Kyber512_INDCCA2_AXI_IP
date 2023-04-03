`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2020 02:14:03 PM
// Design Name: Tendayi Kamucheka (ftendayi@gmail.com)
// Module Name: Kyber512_INDCPA_tb
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

`define P 10

module Kyber512_INDCPA_tb;

localparam KYBER_K             = 2;
localparam KYBER_N             = 256;
localparam KYBER_Q             = 3329;
localparam Byte_bits           = 8;
localparam KYBER_512_SKBytes   = 1632;
localparam KYBER_512_PKBytes   = 800;
localparam KYBER_512_CtBytes   = 736;
localparam KYBER_512_SSBytes   = 32;
localparam KYBER_512_RandBytes = 32;
localparam RAND_SZ             = Byte_bits * KYBER_512_RandBytes;
localparam CIPHER_TEXT_SZ      = Byte_bits * KYBER_512_CtBytes;
localparam SECRET_KEY_SZ       = Byte_bits * KYBER_512_SKBytes;
localparam SHARED_SECRET_SZ    = Byte_bits * KYBER_512_SSBytes;
localparam PUBLIC_KEY_SZ       = Byte_bits * KYBER_512_PKBytes;

reg               clk       = 0;           
reg               rst_n     = 1;
reg               enable    = 0;
reg [6400-1 : 0]  i_PK      = 0;
reg [5888-1:0]    i_CT      = 0;
reg [6144-1:0]    i_SK      = 0;

reg [256-1:0] i_Buf_Hi, i_Buf_Low;
reg [512-1:0] i_Kr;

reg mux_enc_dec           = 0;
reg T1_indcpa_ENC_enable  = 0;
reg T1_indcpa_DEC_enable  = 0;

wire [5888-1 : 0] o_Ciphertext;
wire [ 256-1 : 0] DEC_omsg;
wire Encryption_Done, Decryption_Done;
wire trigger1, trigger2;

reg [5888-1:0] expected_CT = 5888'hcd3891127e3507b8e31942f0384905ccd258530f1888161e62b8657d6583027256890603b5c698de4f95932a9539d30a940aaeda60757ff3764b3629e49be4f4981890a3e4a11edb6895fc82c80d670c500331db9db0ce95d3efdb9469e4762e38033548249d8110ebaf19146433a55bb5dbb4ca69b30cf310b7d5c555fc4d400c884fb70966b430cb3b34bdad9f311afa69c51e9e972c9c7849a9391f08ea8e044d7d70795d7220334981a292e11a580f7ccdfdb9807599158fa5f1853a5f1830ffc43ebedc91fdb000bb0fbb375362098d2ec743cba316cdf091ed741bc1d77008271bb11a15ec55cc4e1de7ea5897469259cbb727346d88604dfa7be9c54f2bda0e0b3ab9c362c1aeb5f30cde2098b4008ed589e6895e3cf891cd4db57a53f767f296ca998ae1546d3d830ef9a147bb910e7e97896c60518f9481ae0d6a3f1cf9a638eb1419b08126d1ec60b0bf40cef6511b7b572bd869530f663bf72b8442b61f3fef4cc33c0298caf6d477c83ebaef2cbb80415d208289af17edf42587ef8938347609bc0915c7f55eefc1ebbc0ac113807fe9cf06210a91e7bdff42bfa5ba6298f1c375a6ad01f90f218df250652d1519699bd04a31552dd5ba2971b79ee24fdf0190761cdc91e1cd7ebe3071699ea7e264ea64939cfb1dee6436772eba439de6c5a0789777db2bf34b71cb76141beeeeed7fd5cad582330df6e8999a47bdc506c42d359dc7c0cc1a26498fa528265a087536d24ae07d040def96c0111d3c45bbadd99c2e716ce13ca9934fef2b0882e0250a5d45e81b762a5f074975dc8bcbc8ef38db4ab8f8c7a2aaec2c85472d70c3d8e8b67c0506ec1b6acb0b325067182ae987d69eb38d83ee38d0e87b5d65cc6b3cfacd0b4c36ac1695b5e98a2dbb7f95d54f3345aa71151909c7f64bad1dd0e9418aa32e3dc85b00150d4f547ca100c68429f464ee5c72bcf01fec1c05508e7b927bbb62892b900223b26fc159390c69d2a303794a9a297a585ee29abc562133408249477dd94a69b2dd0df7;


Kyber512_INDCPA DUT (
.clk(clk),
.rst_n(rst_n),
.mux_enc_dec(mux_enc_dec),
// INDCPA_ENC
.i_indcpa_enc_enable(T1_indcpa_ENC_enable),
.i_PK(i_PK),
.i_Msg(i_Buf_Hi),
.i_Coins(i_Kr[255:0]),
.o_indcpa_enc_done(Encryption_Done),
.o_CT(o_Ciphertext),
// INDCPA_DEC
.i_indcpa_dec_enable(T1_indcpa_DEC_enable),
.i_CT(i_CT),
.i_SK(i_SK),
.o_Msg(DEC_omsg),
.o_indcpa_dec_done(Decryption_Done),
// DEBUG:
.trigger1(trigger1),
.trigger2(trigger2)
);

initial begin
#(`P) rst_n = 0; #(`P); 
rst_n = 1;
#(`P*10) // wait a while after reset

#(`P); mux_enc_dec = 0;
       T1_indcpa_ENC_enable = 1;
       i_PK = 6400'h2a025124e6c528944c96651c8347c82b7172dba83f2df55bb9e79d64063735510324dc2e40a6c4a205ae1ba7446ff5283c910724f71fb93a56f1063b2bd96a5a6b5128883493173fea8c6877c0085220b99889bea5561702810a1b905b0c008f8486c122131dec66ad3941a1f9341301b523e73364619528b0123c0f3c7da0262a01d879fec85485956b96d567ab3760da12b7196a32797260e2d864b78a68a4cb69a23ab32d4c5b9784930cf4589e966c67da9dac070b3dd51a6d96640a091e8be8580d0377cbf9cd41a619bf0abdd4381c6961161a8b5e14582bc4c25836bc65b5c39ce3fca110c11cc6498e33d29a9b4aa4f66c9b574c4038d64bf2f85ab40ab4e084482e09728861a9a7ca564e31cc10c31ea5b55fdfb373a3519ae1681ab4db86a3265618e2badde02a04199ddf097f5b1c7463158672fc7e27812d711644b748bdcf8ac6716487331aab4598c410153cb56082b80a7b1cf3ad12d860f9b5ade101bf861a5eb3768dfefc46e46b4c4c12b1ac080fc69bc01f8a917b386646600c701487d44bb5500c228543561bd39977118a2f45491e663ae603acd17827fb612336c16d468668d8963a06501f8079a8587a9c4eb6128ae1aed7a9275686bd4bd46df3e50c1232cb19e40d72b02759e3a60c2c60485ab77f753ccf39bd7ed3166e561fddc91369b21d3d0a3a1929c67b7782682acadf078001577a82ca3b8cd63b56a44abefacc6d357ef8047ef352a8f593539540900cb3c65e368b08f375f262c198d3873a1c9fcfc4bdd372a52899aea4c280127b18430c7c68b003e9642c17375ad3b018b793462d74a797b97a612c81143464178504f406a1da133df94223d7d55bee0384b0a65052a62e3ebb947538c713eb4ec958621b613ceee59bbe745558b393edeb71af7bc468a425a8c249ad62ba27396ca4f3c6a6183d323c4d4461896869830bfa4ab54a5b78a5c4e2c80ce585b6e392858e46a4b1414e81873a82161b60e36fcf9176cae5619a3639c937cb4a877e58e31d6ec0332ee3996958b208a059a8a6a3d5e6732ff59e77760c03f54f573a3c43a86c8f5042bc259d7c61efccbcafb1b839356adfb44e5adf29950a758c1227495982bd5207;
       i_Buf_Hi = 256'hc20634f357f421fb8b596413cdc3158f05dcba9cf384c3e0a17168e8cc4a0ff7;
       i_Kr =     512'h82d7b80535bb1c9cc37ac1677ca6d4ff3ef92b84488cab1124dd4cf590e2998b40f247bee2d0c4f73329b33df04131f46befb2fcaee5a382afc2e8e299cd20a4;

while (Encryption_Done !== 1'b1)
  #(`P);
 
#(`P); enable = 0;
       check_ciphertext(o_Ciphertext, expected_CT);

$display("Ciphertext: %h", o_Ciphertext);
$display("INDCPA encryption success...");

#(`P); mux_enc_dec = 1;
       T1_indcpa_DEC_enable = 1;
       i_CT = o_Ciphertext;
       i_SK = 6144'h019117b3ab44e93596c5bc6fb8e679c445c12b22769ce028b64aa294c2aeebd8856500928f485d38d725c2b410e775612be88d4d983e04b62daa695ff9a74d92aa4e3cd735e80c3256281315ca2d6f306462389c4d0c79c8b30b1d33c21d1661c2a1864e36a71f851dcffa14977525773c62bab746551733b7ec382da72071b9585197cd4003a7d13b5a72c8bc5e679c544b705cd0c3ae40b346029ab76b84901545864ab22696498db84b8557835ee75236c5c8e07c2ea092c4994b077bfab9d6208998b8b254e60f21c9c658381fa9c8cc6648560e3ab949b932c4e21bed5a2f0a3c2929a90eb7cc7ad78154dc41a199f7a7c381a8638193bd39104308475ec000df15b255a2bd7366320ce0126e92c918998bfa3a7589b9a03eb7cb83094c72bb0e00661c0ec63a248abc608a3bf4f85e34f9067d109843b631cc689f2206bf5b099362e41d706c0b47e9124bb5be376024d7e56f1e047e94e0757ca0c2aba3ab79fb02d5c8a7c373cab176c72b5311f3527b5173ce30558afbf534dcb86340c2a542bacfae10668f08472548717f19be4c280baec01f7478c7e6d95b6e7a86674c0c34802e943668c2c5bd34486d2af55e500767654c8c8a441fb950b342638874581922a2a207665edb32689cc9181657574c876a75476ccd98c572624609dc33e2cb31bba7c803c6819e155faf29122889c91a74328c2bb90681a2604850b2466bfceb5d35829a508545f4f32515aa035cf3b50f2b41d7831fb449c27e70aa62102c6422aa1be21e19cb8adb272e0b8783f4857392b05c5ecc490948895aeccb55c83d65e82041ca4164aab6827804a11662a4eb600800287736c159ab6f60ea9395f7cb10d8363e637019e87f5c3b9f60693b6f1ca675f27668739fc2d77d1ecc3b4a8b537047a5d69c6149028a0166428ce2ba5d99be67c3b05e2b8cf6b7b95deb3bcd769f05c4643f65277bf75b18a5182deb88fdb2333c42adb44c6d42eb519d7454a6047f0ea196c7802dcc83a41c0241cc79099a9a33ed8cce828625af7c161a17cd8514005908c78f574af29717fbd93c0d61cabf052a0b2b90;

while (Decryption_Done !== 1'b1)
  #(`P);

#(`P); enable = 0;
       check_message(DEC_omsg, i_Buf_Hi);

$display("INDCPA decryption success...");
$finish;
end

always #(`P/2) clk = ~ clk;

task error;
  begin
    $display("Error!");
    $finish;
  end 
endtask
    
task check_ciphertext;
  input [5888-1:0] out;
  input [5888-1:0] wish;
  begin
    if (out !== wish)
      begin
        $display("%h %h", out, wish); error;
      end
  end
endtask

task check_message;
  input [256-1:0] out;
  input [256-1:0] wish;
  begin
    if (out !== wish)
      begin
        $display("%h %h", out, wish); error;
      end
  end
endtask

endmodule

`undef P
