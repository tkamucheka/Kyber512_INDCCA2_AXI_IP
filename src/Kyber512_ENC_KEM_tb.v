`timescale 1ns / 1ps

`define P 10

module Kyber512_ENC_KEM_tb;

reg  clk = 0;           
reg  rst_n=1;
reg  enable=0;
reg [256-1 : 0] i_Random = 0;
reg [6400-1 : 0] i_PK=0;
wire Cal_flag;
wire Encryption_Done;
wire [5888 -1 : 0]  o_Ciphertext;
wire [256 -1 : 0]  o_SharedSecret;
wire [1 : 0] cstate_flag;
wire trigger1;
wire trigger2;

reg [256-1:0] expected_T0_oBuf_Low = 256'hc20634f357f421fb8b596413cdc3158f05dcba9cf384c3e0a17168e8cc4a0ff7;
reg [512-1:0] expected_T0_o_Kr = 512'h82d7b80535bb1c9cc37ac1677ca6d4ff3ef92b84488cab1124dd4cf590e2998b40f247bee2d0c4f73329b33df04131f46befb2fcaee5a382afc2e8e299cd20a4;
reg [255:0] expected_shared_secret = 256'hf66417cdedc6c4b1775bf84c72ec9ad6ea6d6a05b5df16359d4c6b4488e32c5f;
reg [5887:0] expected_ciphertext = 5888'haadc275d5570dcb62b34ef470b6838e8b5f3a45838249d958ec54eba3e2ce269de082641b5524a178ec467a3a1d729fda998f7a20e8c7026f4269194f40ef2a6435d42709628c8c11d90fc718dce8ca14fcef02742e829d5dfcd415bcd1deff545adc1660a415c667e34bbe2ece7c160d6a167243e61f2a2ebe711be129476dee977b63f2d40e04f9d6dc49d219bd8dfcc0a7c988a212926a4186fa33a065fd068964fe48d215e0bc12d2fbf640e077df78aa59bb30063b590c7852eadffb13a5d37a261830192735d8cedc6936d8122e47a8f704a7b286ead0442e618328fa6382aeb28fcc22ce67687c39f8d30703af21f6c38f1370bf55c6868c2db51a2643e503d40c0424eb531d2dbf198dc522ea358fee2146f4449d0885ec8714e7f06f6a586a4860f66c2c549a7274b75934b129d3bed86c709815f3781cff0b884f4208c6520797f1ab770c9ccfd9d1b12f4a2c107a6b6adc65c33296aaa5d5536d68fab80e93408b717ecf96fb04a6115b0728380f4ec92ff8a3c1cc1d483eb04b764b28143e7d47eda77693da6cc72da15a116676d8fe2ee74add23decb8d0a70e03be3a3ebd6202cc5afbbf7055193377994cfebcf0579c5fd60794f4fa03f79b517ffce4b7ef85da17144c19195429e63c710c58610d2dbe09ebbb71a914a38e46c28ac8a70f3ead2a5b2696e644df1915e6dd87e63ad48a84504f2a6b89dbc2485f5dc7b24958244434e7523389d6e3b3def3be9dd7d24e26fbf4f5adfa81cb0da3210a98004da4de269edbd8398a04f51862ed7ab94ea1744b1a3b8cabed5689739a122086a5c67272f650ddcd9e3574c9903b482e90994088ce8742d555122e1834a4132c7b6b23c6704822267decf5312efb95982280c02b793db3dd4e6fc4d9cc3714660cef51548909748698d871489391e7eb74a34f45e9b65cd13b993381f37b1e340ba3c5271572a09e4117c2bebc186a34cfc07908091b5c64e0af46f20bda1f3a581e71276f8601ef9e6916cb0542947057f06ce53308504c7238;

Kyber512_ENC_KEM T0(
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.i_Random(i_Random),
.i_PK(i_PK),
.Cal_flag(Cal_flag),
.Encryption_Done(Encryption_Done),
.o_Ciphertext(o_Ciphertext),
.o_SharedSecret(o_SharedSecret),
.cstate_flag(cstate_flag),
.trigger1(trigger1),
.trigger2(trigger2)
);

//Kyber512_indcpa_ENC T1(
//.clk(clk),		
//.rst_n(rst_n),
//.enable(enable),
//.mux_enc_dec(0),	
//.i_PK(i_PK),
//.i_Msg(T0_oBuf_Low),
//.i_Coins(T0_o_Kr[511 : 256]),
//.Encryption_Done(Encryption_Done),
//.o_Ciphertext(o_Ciphertext)       
//);
 
initial begin
#(`P); rst_n = 0;
#(`P); rst_n = 1;

#(`P*10) // idle

#(`P); i_Random = 256'hd3d4b6b292b3acd48f52979dc1442096e2fd44f52f384e7d87690f67924fdd25;
       i_PK =
       6400'hc4794b69584eeca6c185338b310a04011364e65329f7641c0c12a7300b73e5e2234b64c33a8bad8b02463a14386d8aa3a3528180e16177d2bce6c274cf3c5a026b7698dac8521cb629cb65c1e317e40720f7b2485718172c0cc51f604c7f45325d63c5ec5786080c4081c7af325770bbb836007b050abc2161a22c50b201180992878579e1cc0771306000b47dbcc8984993a26aac67e064362e10903d208962c40c30b61a96f2bff9f3a2cc815969f01e70a82079cbb0864a2780c291a292024e5b663494bd8d85343a67102be522a4372a3ce96de079c07482c4ff3c29f3e3b20a6aab51a0173bc751be0a79840639b01633447c181b0cc373db0a57647a5058ba2ef415520873af58489e372c1385bbbce4c6e7084c6a1a4c3c050e966299db151f2dc3b7dd071061fbaf7e700c8667950fba8035a99df8b11b2273b23752c57d612447a594a198bdac682898e40a83d4aef88a03817c2b3d6c59acb829c9dca652a18c8ba45ab3408ce3a27dbaf1077c837432259bd7056171b83ad44bbc4a7c991d8478e04c0af8c7b9d09c1988ba0c6a8537f6f02466c7caf438a795889514e41bf4e82ced0c6204440b2b2cb1c945439f1cacd46290eff6591973938276adff4cc2e9e32e66e63426a858ac195501077ae5a2b7bb0266b474c3d101c2ab81048bfca57c0898946330da084c65c73031012a67aa2848b4206ba97f9e4c80498852054197efd9c7a029ce8f020a630bc2ee72a3c11672b209ccae414fe793b124769de0025597f28423dbb6362c2ab7b6c1f52b35eb6654ade5b828d262133391647c1477e53c286b3d54f695b9517407e67edbb170f2536600da50eef8a65a866341999c4b2415b5322ec83409d926113669af905857c1c394c5050cf4d0387a439e9ea8985fb260db8b967cd1cb227834ebfb9c49476a8fa309b394c6b7f6247a999d49491ff6d19f4a5cc7b3009ad505806093bb209a9e86b56c233961fd3b6252c1797822ade37c61a3a34b7a746430d4b8100947b6367a05642856e42952b085a987359887a657c61f416b41c61b471cc1bd346b76f5810d4b8858fe0604399e59ebd6db0ed4878ca56bafcebb4c0912c32d74d7e2ed6fc71c2672;
       enable = 1;
#(`P); enable = 0;

while (Encryption_Done !== 1'b1) #(`P);
#(`P); check5888(o_Ciphertext, expected_ciphertext);
       check256(o_SharedSecret, expected_shared_secret);

$finish;
end

always #(`P/2) clk = ~clk;

task error;
  begin
    $display("E");
    $finish;
  end
endtask
    
task check256;
  input [256-1:0] out;
  input [256-1:0] wish;
  begin
    if (out !== wish)
      begin
        $display("%h\n%h", out, wish); error;
      end
      
    $display("check256: Success");
  end
endtask

task check5888;
  input [5888-1:0] out;
  input [5888-1:0] wish;
  begin
    if (out !== wish)
      begin
        $display("%h\n%h", out, wish); error;
      end
      
    $display("check5888: Success");
  end
endtask

endmodule

`undef P