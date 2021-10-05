//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_PAcc
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
// Additional Comments: Reusable for Encryption and Decryption
//////////////////////////////////////////////////////////////////////////////////

module State_PAcc#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter i_a_Coeffs_Length = 16,
  parameter i_b_Coeffs_Length = 12,
  parameter o_Coeffs_Length = 16,
  parameter i_a_Poly_Size = i_a_Coeffs_Length * KYBER_N,
  parameter i_b_Poly_Size = i_b_Coeffs_Length * KYBER_N,
  parameter o_Poly_Size = o_Coeffs_Length * KYBER_N
)(
	input 														clk,		
	input 														rst_n,
	input 														enable,
	input 														mux_enc_dec,//enc0,dec1
	input 			[i_b_Poly_Size-1 : 0] NTT_Poly_0_RData,
	input 			[i_a_Poly_Size-1 : 0] EncPk_DecSk_PolyVec_RData,
	input 			[i_a_Poly_Size-1 : 0] AtG_RData,	
	output reg 	[0 : 0] 							NTT_Poly_0_RAd,
	output reg 	[0 : 0] 							EncPk_DecSk_PolyVec_RAd,	
	output reg 	[2 : 0] 							AtG_RAd,	
	output reg 												Function_done,
	output reg 												Enc_BpV_DecMp_outready,
	output reg 	[7 : 0] 							Enc_BpV_DecMp_WAd, // 128-159 EncV/DecMp, 31-63 EncBp0, 64-95 EncBP1
	output reg 	[128-1 : 0] 					Enc_BpV_DecMp_WData,
	// DEBUG
	output reg [1023:0] Bp_debug,
	output reg [ 511:0] V_debug
);

// reg [4095:0] a0_debug = 4096'h09c404b7086904e506ec0c1a038508b30a3100400301064103e6029504f701c6020c0a710b30073002e5023e044b0c360b3a0ad8028b0460043a03810a6d0a3802a308150180061e02770bcd02e6074c0ccf05a30b0207660a980c8d0c520b610b29065c03c1017e07e4020002f7048b085701710c2c0c50001f04c6057f0324035d0c5607ec08650c08040007810afc0732070508bb036b0b0000570c0a021b026102ca0250001b09180920058707980ce1007c00710603040007db08bc098c03490a290c6a067a04e00366002e0901003d0892046200cc063001ab02960bff03f90a2f01cc0598006901ef0870020a0b790b0c0a8602740280091c02a200290b4e066504340bd9058d0348073a0106052b022e07a402a3093c06de09e00c0702740c480cff029303f30b2e0a0a0ab60051017a073b051c0abe07900684039006b003310c4401870c1b0c300b7300ad045707a608500ba5042e015f0852073008af0485079e02c305130bb804bc0c6e08e704c00a6a04c1053c00e00296099605db01f1032d0b7c07dd01000b610aff007e00c7078609560a0f080b093509da01f801bb03220b2702370c55017d02460547094a08a10bd908ac0286049800ae04830aed0af800380c8102b70c3d059608ac029b0cc90a6d015208ca048b05aa00b308c402e307da01ba007f037c0748053209b205d70610087103ab0bd40bc4;
// reg [4095:0] a1_debug = 4096'h0c4a0997041d07880ce000a407f80b9c0cd001990a8800cb056a037800f6024f07660cac08f40a7308950958041401be08f402ce0ced0620040400b40c2b0b1205c904340c9f0ac102d4090606ef059f0319093706820ad70cff0c2403e902ee0666034e0826058a09ac0551070107a002e50b7a02bb066004b40c3701d10c2001ab00480c8b0a5f087c09800394030608da04c00765030c013102a00a67028a0448020b096b07fa0c9e0804084905280105097409ef0c7d09a00ce2028f00a00b630c2002ee0a3706c1072109b20cc001ae04f403e70b19062409d702e005500297084f0b230b6d0c3602a206b70c1b0bf5035206eb054605ad0b8e0228062d031309130c640147057703ce0b2803d60654095f01b90745060707ee01db070b03f206650a00050d08ee0a6f065a0638094109c9044b015202b502e304c8009306d9011209360af60890057503c1094c05c500c000f4038d037a09e4089e098a025f060b0bdb0968017c0cbd082203470beb09cf074906a4038f009a04b30c6906b7024f097a09d9094901f401f609fd0c4a0c7500b309a005d5080003600bb90a2009e9058606cb092306130bfd06230152079c02780ad20ce3061703a304ba047a064704300b8d0910047006b607a3040502860456029e0052085b07a9035807980a68065701fc0b4104160bc60471011c0bdc0b34076601f500d8084b0588;
// reg [3071:0] ntt0_debug = 3072'hc3593ac3d858a5782f4782b4a50a27675b0f3670e3a383dacd0a5400e5a3c1786326c9191fabea9e677c6de14c4690ba34d78a7c4318bff6af67792ba75350a3d96f28964f7b72df60b6606fd4ee1b984b13b0deca89711ac3b58273c9c4d0281611502870262fca7b3d972a16fa982b1c622333a7882941afd3c08c03c247178c3642369c62b98c975448f35d529180c8e1302f244c3be6d47d0bc36ca682bfc7979cc0194b5b985b142169060a92623f8d3b1b9c21194c03360250c57f769c962b3a31dc1834964d9ff76d6704744876dfb862114aaa881aa96c171bdd53bc7e24b9441582da52a037227c0d19225c7bc36625e64b9c315fb74016c7b9540504449b7af85f427ea8d0f31659bc4871ba3f061247904f202ccd68f042280b2f15370e7f9536b8ec79766648802258658519ba52d959c20221da87a123712314cb7940afc847981cf7b84d973e7af958316807545a108e1071585176cdb8457128590a65269b6bf60bd17212494640f8c922d2fe06800f9b8cb5893c8493315f;
// reg [3071:0] ntt1_debug = 3072'hbaf47953b3d98a252075cac023f5b49a3c231fd2166c38804c32569be36f7678c245eb0d5e380920c9509800ef81a8902e022b85337f21d8421469ac9a6ceb2bf54332f1498994a3af3a4bc8a77f10dcca17db8f535666498622b9eb6c06246425ba273a9946c93ac74f1c473f72eba2dcf662344ec1f3151533572d76c1bd963bae423fc43ab265910b31110e2c1c4705e6309d29166387fc85399d33088007d5979f742675bc929f393108347e47d6387d8aaa713997aad756a56655113487a57aa36ab6283a557c5170fa3895d13555cd241c2d61955ec242ee91c81c911a048224176e297444714b3c680659e2a32ba3842b857a73802b1ea37f9c86ce20676eb0b69eb808cd7a6c3641fbf62db1f948b2c60ed4dfc80b773ce39fce5242ca719c5821a43f11d6195662636b543c930d3a0b1c500c3f6706b884a1b9cc186d752a0e4df2a444311909f069aa00c86cb8350c91965606ef718ba9a7e1195201964878fec0105445f90c2a897e1225d52ea03d3a4c422446df1a2b1c3e17ea;


reg  												P0_Poly_PAcc_enable;
reg  [i_a_Poly_Size-1 : 0] 	P0_Poly_PAcc_i_a_PolyVec_0;
reg  [i_a_Poly_Size-1 : 0] 	P0_Poly_PAcc_i_a_PolyVec_1;
reg  [i_b_Poly_Size-1 : 0] 	P0_Poly_PAcc_i_b_PolyVec_0;
reg  [1 : 0] 								get;

wire [o_Poly_Size -1 : 0] 	P0_Poly_PAcc_oPoly, debug1, debug2;
wire 												P0_Poly_PAcc_done;
// wire [i_a_Poly_Size-1 : 0] 	P0_EncPk_DecSk_poly;
// wire [i_a_Poly_Size-1 : 0] 	P0_AtG_poly;
// wire [i_b_Poly_Size-1 : 0] 	P0_NTT_poly;

reg [3:0] cstate,nstate;
localparam IDLE		             	= 4'd0;
localparam Pop_NTT_EncPk_DecSk  = 4'd1;
localparam PAcc_0   		        = 4'd2;
localparam Push_0             	= 4'd3;
localparam Pop_Enc_At0        	= 4'd4;
localparam PAcc_1             	= 4'd5;
localparam Push_1             	= 4'd6;
localparam Pop_Enc_At1        	= 4'd7;
localparam PAcc_2             	= 4'd8;
localparam Push_2             	= 4'd9;

// genvar a, w;
// generate for (w=0; w<256; w=w+1) begin : U0
// 	for(a=0; a<256; a=a+1) begin : U1
// 		assign P0_EncPk_DecSk_poly[(w*256)+(255-a)]			= EncPk_DecSk_PolyVec_RData[(i_a_Poly_Size-1)-((255-a)*16) -: 16];
// 		assign P0_AtG_poly[(w*256)+(255-a)] 						= AtG_RData[(i_a_Poly_Size-1)-((255-a)*16) 								 -: 16];
// 		assign P0_NTT_poly[((w*256)+(8*(a/8)+7)-(a%8))] = NTT_Poly_0_RData[(i_b_Poly_Size-1)-((255-a)*12) 				 -: 12];
// 	end
// end
// endgenerate

always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) 	cstate <= IDLE;
	else 				cstate <= nstate;
	
always @(cstate or enable or P0_Poly_PAcc_done or 
				EncPk_DecSk_PolyVec_RAd or AtG_RAd or Enc_BpV_DecMp_WAd or get or mux_enc_dec)
begin				
	case(cstate)
		IDLE:									if(enable) 									nstate <= Pop_NTT_EncPk_DecSk;
				  								else 												nstate <= IDLE;
		Pop_NTT_EncPk_DecSk: 	if(get == 3)								nstate <= PAcc_0;
		                    	else 												nstate <= Pop_NTT_EncPk_DecSk;
 		PAcc_0:  							if(P0_Poly_PAcc_done) 			nstate <= Push_0;
		           						else 												nstate <= PAcc_0;
		Push_0:  							if((Enc_BpV_DecMp_WAd == 159) && mux_enc_dec) nstate <= IDLE;
		           						else if(Enc_BpV_DecMp_WAd == 159) 						nstate <= Pop_Enc_At0;
		            					else 																					nstate <= Push_0;           
		Pop_Enc_At0: 					if(get == 2) 								nstate <= PAcc_1;
				      						else 												nstate <= Pop_Enc_At0;
		PAcc_1:  							if(P0_Poly_PAcc_done) 			nstate <= Push_1;
				  								else 												nstate <= PAcc_1;
		Push_1:  							if(Enc_BpV_DecMp_WAd == 63) nstate <= Pop_Enc_At1;
		            					else 												nstate <= Push_1;
		Pop_Enc_At1: 					if(get == 2) 								nstate <= PAcc_2;
				      						else 												nstate <= Pop_Enc_At1;
		PAcc_2:  							if(P0_Poly_PAcc_done) 			nstate <= Push_2;
				  								else 												nstate <= PAcc_2;
		Push_2:  							if(Enc_BpV_DecMp_WAd == 95) nstate <= IDLE;
		            					else 												nstate <= Push_2;				  	
		default: 																					nstate <= IDLE;
	endcase
end

always @(posedge clk/* or negedge rst_n*/)										
	if(!rst_n) begin
		P0_Poly_PAcc_enable 				<= 1'b0;	        
		P0_Poly_PAcc_i_a_PolyVec_0 	<= 0;
		P0_Poly_PAcc_i_a_PolyVec_1 	<= 0;
		// NTT_Poly_0_RAd 							<= 0;
		// EncPk_DecSk_PolyVec_RAd 		<= 1;
		// AtG_RAd 										<= 0;
		Function_done 							<= 1'b0;
		Enc_BpV_DecMp_outready 			<= 1'b0;
		Enc_BpV_DecMp_WAd 					<= 0; 
		Enc_BpV_DecMp_WData 				<= 0;
		get 												<= 0;   
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Function_done <=  1'b0;
					NTT_Poly_0_RAd 							<= 1'hx;
					EncPk_DecSk_PolyVec_RAd 		<= 1'hx;
					AtG_RAd 										<= 3'hx;
				end
			{IDLE,Pop_NTT_EncPk_DecSk}: begin			         
					NTT_Poly_0_RAd 					<= 0;
					EncPk_DecSk_PolyVec_RAd <= 1;
				end
			{Pop_NTT_EncPk_DecSk,Pop_NTT_EncPk_DecSk}: begin			         
					P0_Poly_PAcc_i_a_PolyVec_0 	<= EncPk_DecSk_PolyVec_RData;
					P0_Poly_PAcc_i_b_PolyVec_0 	<= NTT_Poly_0_RData;  
					// P0_Poly_PAcc_i_a_PolyVec_0 	<= a0_debug;
					// P0_Poly_PAcc_i_b_PolyVec_0 	<= ntt0_debug;                  
					EncPk_DecSk_PolyVec_RAd 		<= 0;
					NTT_Poly_0_RAd 							<= (get > 1) ? 1 : 0;
					get 												<= get + 1;
					// DEBUG:
					$display("PACC (IN)[V, 0, PK/SK]: %h", EncPk_DecSk_PolyVec_RData);
					$display("PACC (IN)[V, 0, SP/BP]: %h", NTT_Poly_0_RData);
				end
			{Pop_NTT_EncPk_DecSk,PAcc_0}: begin			        		         
					P0_Poly_PAcc_i_a_PolyVec_1 	<= EncPk_DecSk_PolyVec_RData;  
					// P0_Poly_PAcc_i_a_PolyVec_1 	<= a1_debug;
					P0_Poly_PAcc_enable 				<= 1'b1;                    
					get 												<= 0;
					// DEBUG:
					$display("PACC (IN)[V, 1, PK/SK]: %h", EncPk_DecSk_PolyVec_RData);
					$display("PACC (IN)[V, 1, SP/BP]: %h", NTT_Poly_0_RData);
				end
			{PAcc_0,PAcc_0}: begin
					P0_Poly_PAcc_enable 				<= 1'b0;
				end
			{PAcc_0,Push_0}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= 128;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[128-1 : 0];                 	
					// DEBUG:
					$display("PACC (OUT)[V]: %h", {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]});
					// V_debug <= {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]};
					// V_debug <= {P0_Poly_PAcc_i_a_PolyVec_0[4095 -: 256], P0_Poly_PAcc_i_b_PolyVec_0[3071 -: 256]};
					// Bp_debug[1023 -: 512] <= {debug1[4095 -: 256], debug1[255 : 0]};
					// Bp_debug[511 : 0] 		<= {debug2[4095 -: 256], debug2[255 : 0]};
					// Function_done 				<= 1'b1;
				end
			{Push_0,Push_0}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= Enc_BpV_DecMp_WAd + 1;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[(Enc_BpV_DecMp_WAd-128+2)*128 -1 -: 128];          
				end	
			{Push_0,IDLE}: begin
					Function_done 							<= 1'b1;
					Enc_BpV_DecMp_outready 			<= 1'b0;
					EncPk_DecSk_PolyVec_RAd 		<= 0;
					AtG_RAd 										<= 0;
					Enc_BpV_DecMp_WAd 					<= 0; 
					Enc_BpV_DecMp_WData 				<= 0; 				            	
				end
			{Push_0,Pop_Enc_At0}: begin
					Enc_BpV_DecMp_outready 			<= 1'b0;
					AtG_RAd 										<= 0;
					get 												<= 0;
				end				
			{Pop_Enc_At0,Pop_Enc_At0}: begin
					P0_Poly_PAcc_i_a_PolyVec_0 	<= AtG_RData;
					AtG_RAd 										<= 1;
					get 												<= get + 1;                   
				end			
			{Pop_Enc_At0,PAcc_1}: begin
					P0_Poly_PAcc_i_a_PolyVec_1 	<= AtG_RData;
					AtG_RAd 										<= 3'bxxx; 
					P0_Poly_PAcc_enable 				<= 1'b1;
					get 												<= 0;
				end
			{PAcc_1,PAcc_1}: begin
					P0_Poly_PAcc_enable 				<= 1'b0;	
				end					                       				 					           					
			{PAcc_1,Push_1}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= 32;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[128-1 : 0];
					// DEBUG:                 	
					$display("PACC (OUT)[Bp0]: %h", {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]});
					Bp_debug[1023 -: 512] <= {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]};
				end
			{Push_1,Push_1}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= Enc_BpV_DecMp_WAd + 1;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[(Enc_BpV_DecMp_WAd-32+2)*128 -1 -: 128];
				end
			{Push_1,Pop_Enc_At1}: begin
					Enc_BpV_DecMp_outready 			<= 1'b0;
					AtG_RAd 										<= 2;
					get 												<= 0;
				end	             
			{Pop_Enc_At1,Pop_Enc_At1}: begin
					P0_Poly_PAcc_i_a_PolyVec_0 	<= AtG_RData;
					AtG_RAd 										<= 3;
					get 												<= get + 1;
				end
			{Pop_Enc_At1,PAcc_2}: begin
					P0_Poly_PAcc_i_a_PolyVec_1 	<= AtG_RData;  
					P0_Poly_PAcc_enable 				<= 1'b1;
					get 												<= 0;
				end	                                       
			{PAcc_2,PAcc_2}: begin
					P0_Poly_PAcc_enable 				<= 1'b0;	
				end
			{PAcc_2,Push_2}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= 64;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[128-1 : 0];                 	
					// DEBUG
					$display("PACC (OUT)[Bp1]: %h", {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]});
					Bp_debug[511 : 0] <= {P0_Poly_PAcc_oPoly[4095 -: 256], P0_Poly_PAcc_oPoly[255 : 0]};
				end
			{Push_2,Push_2}: begin
					Enc_BpV_DecMp_outready 			<= 1'b1;
					Enc_BpV_DecMp_WAd 					<= Enc_BpV_DecMp_WAd + 1;                 
					Enc_BpV_DecMp_WData 				<= P0_Poly_PAcc_oPoly[(Enc_BpV_DecMp_WAd-64+2)*128 -1 -: 128];          
				end				              				              
			{Push_2,IDLE}: begin
					Function_done 							<= 1'b1;
					P0_Poly_PAcc_enable 				<= 1'b0;	        
					P0_Poly_PAcc_i_a_PolyVec_0 	<= 0;
					P0_Poly_PAcc_i_a_PolyVec_1 	<= 0;
					NTT_Poly_0_RAd 							<= 0;
					EncPk_DecSk_PolyVec_RAd 		<= 0;
					AtG_RAd 										<= 0;
					Enc_BpV_DecMp_outready 			<= 1'b0;
					Enc_BpV_DecMp_WAd 					<= 0; 
					Enc_BpV_DecMp_WData 				<= 0; 
					get 												<= 0;
				end
			default: ;
		endcase
	end

       
State_PAcc__Poly_PAcc P0(
.clk(clk),		
.rst_n(rst_n),
.enable(P0_Poly_PAcc_enable),
.i_a_PolyVec_0(P0_Poly_PAcc_i_a_PolyVec_0),
.i_a_PolyVec_1(P0_Poly_PAcc_i_a_PolyVec_1),
.i_b_PolyVec_0(P0_Poly_PAcc_i_b_PolyVec_0),
.i_b_PolyVec_1(NTT_Poly_0_RData),
// .i_b_PolyVec_1(ntt1_debug),
.State_PolyVec_PAcc_done(P0_Poly_PAcc_done),
.o_mp_Poly(P0_Poly_PAcc_oPoly)
// DEBUG
// .debug1(debug1),
// .debug2(debug2)
);    
    
endmodule
