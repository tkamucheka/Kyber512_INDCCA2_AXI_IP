//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Invntt
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING HUANG, Tendayi Kamucheka
// Additional Comments: Reusable for Encryption and Decryption
//////////////////////////////////////////////////////////////////////////////////

module State_Invntt#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter i_Coeffs_Width = 16,
  parameter o_Coeffs_Width = 16,
  parameter i_Poly_Size = i_Coeffs_Width * KYBER_N,
  parameter o_Poly_Size = o_Coeffs_Width * KYBER_N
)(
	input clk,		
	input rst_n,
	input enable,
	input mux_enc_dec,//enc0,dec1
	input [i_Poly_Size-1 : 0] PACC_EncBp_DecMp_Poly_RData,
	output reg [2 : 0] PACC_EncBp_DecMp_Poly_RAd,  //// 4 EncV/DecMp, 2 EncBp0, 3 EncBP1
	output reg Function_done,
	output reg INTT_Enc_BpV_DecMp_outready,
	output reg [6 : 0] INTT_Enc_BpV_DecMp_WAd, // 0-31 EncV/DecMp, 32-63 EncBp0, 64-95 EncBp1
	output reg [128-1 : 0] INTT_Enc_BpV_DecMp_WData
	// DEBUG
	// output reg [1023:0] Bp_debug,
	// output reg [ 511:0] V_debug
);

// reg [4095:0] V_debug_in = 4096'h059204830be701d60955040107cb08bd098000000156052105f008370611063607bf07ec0697050601800baf04c40ad20caa020307a303aa083d02c80a4804e108cd0b250c6607440a9e09320a8f024d08f209490ca5071302b206dd0a5900b40ce2069f09d604550ac509460ce001d50373040c045d02af020c00750ae106ea02140be306840c4106df0af009de03cf01f80b0e046e0c8708ee0033037402a1031b03e6072e0ab6036503800c1b0c9807ef075509b1001c06080c51051e002002d40967014205ac084904ff091d062e08350569075a07db09bb09430acc06a600a808600ce20948014b053b0a80064d0358063809dd09a90a280789041c0407009e0823040e07380568062b03ea0bdb0382098804dc00c708dc053608940831039d041f0311028a0a70094500cb09fd022e044808ff0cbe016c05ae001500c4059d01830ba20728039705e605070112035a0017009f0142087c096703fb0bd50b230aa50cad05a307800bcc00d105f8018d0b7005d602a9007007850be80b6300ca05730a0b0cf608c902e407d50cc90b2604ca01280b7a009802420003070c09fe0790013b0bf20a430a4f04ca00350c0c03f0078e098b044f0c210565079100ee05550b7909d106b708430a5503260299041d06ea06010102008704b4025f090a09610697004700830a950af00762017509b40c9d03e201bc0c5d0413061e;
// reg [4095:0] Bp0_debug_in = 4096'h00f707ea0a0d02f6018a050c0af00a270c260ab104cb0b6f08760194060a02d80114063c05800ae007cb07f50158099807050c6c072b07a1032c033702b408d205a70cd5034301ce02e104c4069d0683099f063402b7018004fd079a055d029201d609590bd6063b020409c70919087e076200cf074f0ac802cb0adb074704cb05f10b3906980b9c06680297085e02cb0ae10529053d0269055e01640c500bb10b6305b003a308ff07b6035f04ea039f035903690c80096002f5097005e10758085a0201082e01c40b06069a00e304ee038206b20911033c0aed020c01370895060a07f105c00bf703540b2b097d06af007d0bd4074700a2013d02d90ce60569045a0b060c840b9e067b034a0acf09d30a10047e0c690c5803f203aa05810cbd01c3090f06da0bbc0b3b001d05f00c4702ee049f082b063201d702b50364068d0c3b0679080405730145024d03b207a3041a021103ea061e094b023604f50cb8057d043e0caf05170417040009e206f4008f0b50027c01fe0104059806160383025604a10869016301b00488009f0652006003ab054800a2033302c40b0901470108013a00030bc50c6b02df01ea0080092d0c62061106c8082b008a04be0a95067e04b701b00280044b040200b60b7c02a40b4d0a7809c0068e02de00a801c300e5019900b107d4065b069300ae06d80bb407380af600e806670a82069e06f5; 
// reg [4095:0] Bp1_debug_in = 4096'h08d4048000d201e00a2b057f0921005b051200c109be01df00e1069c02b806520384043c059f027209d4076305430a99068807e603f3064700f807a60c6e0a850785088f070303a0052701be04a90a15068d07d9068700b404390122052802070a88075d052c013f0808033c0b4904a5076f08390b9002a6010e0b75078105fd09120c1608790a34002a048500330cb508cb066e040401530862040902d70b28082b060f093104120ad407c80aa10a8f097a011a082306380b4904790a350c4c0bab052b052300f40c29074b02f6022c037508ec067205dc0a500369075e05670502078d05760b4407170498072509b201a602240af80ca106a1037f0872073100bb06d700580098067707c5062b05f50abf071903790364065303aa005508de02790600063f06eb052508eb044d04c00b1809cc057e013107dd0cf300b40691055408be00b706e90b2d0bcb07e405e9038802fd047800a006250cf9042206f4033605ac062200170084015e059706820b5209c80ce101ca07210af0098f0a6e0a1d02e106af0883019901c3090c04b4002a015a05f10482016e031d0a6d06b50001066e0c7d09760b0a0bce00e007870b8209f404cc019d05a400060bd30126081a08a8057e06b809d0070307870771074002e406a901be06e900ff09c701fc07e5094a090304de077507be046a011b01b00b860a210173085d06cd01530668;

reg  P0_INTT_enable;
reg  [i_Poly_Size-1 : 0] P0_INTT_iPoly;
wire P0_INTT_done;
wire [o_Poly_Size -1 : 0] P0_INTT_oPoly, P0_INTT_oPoly_debug;
reg  get;

reg [3:0] cstate,nstate;
localparam IDLE	 = 4'd0;
localparam Pop0	 = 4'd1;
localparam INTT0 = 4'd2;
localparam Push0 = 4'd3;
localparam Pop1	 = 4'd4;
localparam INTT1 = 4'd5;
localparam Push1 = 4'd6;
localparam Pop2	 = 4'd7;
localparam INTT2 = 4'd8;
localparam Push2 = 4'd9;

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) cstate <= IDLE;
	else 			 cstate <= nstate;
	
always @(cstate or enable or P0_INTT_done 
					or INTT_Enc_BpV_DecMp_WAd or get or mux_enc_dec) 
begin				
	case(cstate)
		IDLE: 	if(enable) 				nstate <= Pop0;
				  	else 							nstate <= IDLE;
		Pop0: 	if(get == 1) 			nstate <= INTT0;
		        else 							nstate <= Pop0;  
		INTT0:  if(P0_INTT_done) 	nstate <= Push0;
		        else 							nstate <= INTT0;
		Push0:  if((INTT_Enc_BpV_DecMp_WAd == 31) && mux_enc_dec) 
															nstate <= IDLE;
		        else if(INTT_Enc_BpV_DecMp_WAd == 31) 
															nstate <= Pop1;
		        else 							nstate <= Push0;
		Pop1:		if(get == 1) 			nstate <= INTT1;
		        else 							nstate <= Pop1; 
		INTT1:  if(P0_INTT_done) 	nstate <= Push1;
		        else 							nstate <= INTT1;
		Push1:  if(INTT_Enc_BpV_DecMp_WAd == 63) 
															nstate <= Pop2;
		        else 							nstate <= Push1;
		Pop2:		if(get == 1) 			nstate <= INTT2;
		        else 							nstate <= Pop2;
		INTT2:  if(P0_INTT_done) 	nstate <= Push2;
		        else 							nstate <= INTT2;
		Push2:  if(INTT_Enc_BpV_DecMp_WAd == 95) 
															nstate <= IDLE;
		        else 							nstate <= Push2;
		default: 									nstate <= IDLE;
	endcase
end

reg [3:0] select;

always @(posedge clk/* or negedge rst_n*/)										
	if(!rst_n) begin
		P0_INTT_enable 							<= 1'b0;
		P0_INTT_iPoly 							<= 0;
		// PACC_EncBp_DecMp_Poly_RAd 	<= 0;
		Function_done 							<= 1'b0;
		INTT_Enc_BpV_DecMp_outready <= 1'b0;
		INTT_Enc_BpV_DecMp_WAd 			<= 0;
		INTT_Enc_BpV_DecMp_WData 		<= 0;
		get 												<= 0;
		select <= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Function_done <= 1'b0;
					PACC_EncBp_DecMp_Poly_RAd <= 3'hx;
				end
			{IDLE,Pop0}: begin
					PACC_EncBp_DecMp_Poly_RAd <= 4;
				end
			{Pop0,Pop0}: begin
					get <= 1;
				end
			{Pop0,INTT0}: begin
					P0_INTT_iPoly 	<= PACC_EncBp_DecMp_Poly_RData;
					P0_INTT_enable 	<= 1'b1;
					get 						<= 0;
					// DEBUG:
					// P0_INTT_iPoly 	<= V_debug_in;
					$display("INTT (IN)[V]: %h", PACC_EncBp_DecMp_Poly_RData);
				end
			{INTT0,INTT0}: begin
					P0_INTT_enable 							<= 1'b0;
					// DEBUG:
					select <= 4'd0;
			end
			{INTT0,Push0}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= 0;                 
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[128-1 : 0]; 
					// DEBUG:
					$display("INTT (OUT)[V]: %h", P0_INTT_oPoly);
					// V_debug <= {P0_INTT_oPoly[4095 -: 256], P0_INTT_oPoly[255 : 0]};
				end
			{Push0,Push0}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= INTT_Enc_BpV_DecMp_WAd + 1;              
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[(INTT_Enc_BpV_DecMp_WAd+2)*128 -1 -: 128];
				end
			{Push0,IDLE}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b0;
					Function_done 							<= 1'b1;
					P0_INTT_enable 							<= 1'b0;
					P0_INTT_iPoly 							<= 0;
					PACC_EncBp_DecMp_Poly_RAd 	<= 0;
					INTT_Enc_BpV_DecMp_WAd 			<= 0;
					INTT_Enc_BpV_DecMp_WData 		<= 0;
				end
			{Push0,Pop1}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b0;
					PACC_EncBp_DecMp_Poly_RAd 	<= 1; 
					get 												<= 0;          
				end		                               
			{Pop1,Pop1}: begin
					get <= 1;          
				end
			{Pop1,INTT1}: begin
					P0_INTT_iPoly 	<= PACC_EncBp_DecMp_Poly_RData;
					P0_INTT_enable 	<= 1'b1;
					get 						<= 0;
					// DEBUG:
					// P0_INTT_iPoly 	<= Bp0_debug_in;
					$display("INTT (IN)[Bp0]: %h", PACC_EncBp_DecMp_Poly_RData);
				end
			{INTT1,INTT1}: begin
					P0_INTT_enable 							<= 1'b0;
					// DEBUG:
					select <= 4'd1;
			end
			{INTT1,Push1}: begin
					P0_INTT_enable 							<= 1'b0;
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= 32;                 
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[128-1 : 0]; 
					// DEBUG:
					$display("INTT (OUT)[Bp0]: %h", P0_INTT_oPoly);
					// Bp_debug[1023 -: 512] <= {P0_INTT_oPoly[4095 -: 256], P0_INTT_oPoly[255 : 0]}; 
				end
			{Push1,Push1}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= INTT_Enc_BpV_DecMp_WAd + 1;                 
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[(INTT_Enc_BpV_DecMp_WAd-32+2)*128 -1 -: 128];
				end				          
			{Push1,Pop2}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b0;
					PACC_EncBp_DecMp_Poly_RAd 	<= 2;
					get 												<= 0;
				end				          
			{Pop2,Pop2}: begin
					get <= 1;           
				end					             
			{Pop2,INTT2}: begin
					P0_INTT_iPoly 	<= PACC_EncBp_DecMp_Poly_RData;
					P0_INTT_enable 	<= 1'b1;
					get 						<= 0;
					// DEBUG:
					// P0_INTT_iPoly 	<= Bp1_debug_in;
					$display("INTT (IN)[Bp1]: %h", PACC_EncBp_DecMp_Poly_RData);
				end
			{INTT2,INTT2}: begin
					P0_INTT_enable 							<= 1'b0;
					// DEBUG:
					select <= 4'd2;
			end
			{INTT2,Push2}: begin
					P0_INTT_enable 							<= 1'b0;
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= 64;                 
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[128-1 : 0];
					// DEBUG
					$display("INTT (OUT)[Bp1]: %h", P0_INTT_oPoly);
					// Bp_debug[511 : 0] <= {P0_INTT_oPoly[4095 -: 256], P0_INTT_oPoly[255 : 0]};
				end
			{Push2,Push2}: begin
					INTT_Enc_BpV_DecMp_outready <= 1'b1;
					INTT_Enc_BpV_DecMp_WAd 			<= INTT_Enc_BpV_DecMp_WAd + 1;                 
					INTT_Enc_BpV_DecMp_WData 		<= P0_INTT_oPoly[(INTT_Enc_BpV_DecMp_WAd-64+2)*128 -1 -: 128];
				end
			{Push2,IDLE}: begin
					Function_done 							<= 1'b1;
					INTT_Enc_BpV_DecMp_outready <= 1'b0;
					P0_INTT_enable 							<= 1'b0;
					P0_INTT_iPoly 							<= 0;
					PACC_EncBp_DecMp_Poly_RAd 	<= 0;
					INTT_Enc_BpV_DecMp_WAd 			<= 0;
					INTT_Enc_BpV_DecMp_WData 		<= 0;
					get 												<= 0;
				end
			default: ;
		endcase
	end

State_INVNTT__INTT P0 (
	.clk(clk),
	.enable(P0_INTT_enable),
	.reset_n(rst_n),
	.select(select),
	.i_Poly(P0_INTT_iPoly),
	.o_Poly(P0_INTT_oPoly),
	.result_fixed(P0_INTT_oPoly_debug),
	.Poly_INTT_done(P0_INTT_done)
);

// State_Invntt__INTT P0(
// 	.clk(clk),		
// 	.enable(P0_INTT_enable),
// 	.select(select),
// 	.r_i(P0_INTT_iPoly),
// 	.result0(P0_INTT_oPoly),
// 	.result1(P0_INTT_oPoly_debug),
// 	.finish(P0_INTT_done)
// );

endmodule
