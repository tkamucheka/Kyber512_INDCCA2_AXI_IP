//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2019 04:35:45 PM
// Design Name: 
// Module Name: State_PolyVec_PAcc__Poly_Basemul
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


module State_PAcc__Poly_PAcc__Poly_Basemul#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Temp_Poly_Width = 16,
  parameter Setp_i_Width = 16,
  parameter Setp_o_Width = 16,
  parameter i_Coeffs_Width_a = 16,
  parameter i_Coeffs_Width_b = 12,
  parameter i_Zeta_Width = 16,
  parameter o_Coeffs_Width = 16,
  parameter i_Poly_Size_a = i_Coeffs_Width_a * KYBER_N,
  parameter i_Poly_Size_b = i_Coeffs_Width_b * KYBER_N,
  parameter o_Poly_Size = o_Coeffs_Width * KYBER_N
)(
	input 														clk,
	input 														reset_n,
	input 														enable,
	// input func,
	input 			[i_Poly_Size_a-1 : 0] iPoly_a,
	input 			[i_Poly_Size_b-1 : 0] iPoly_b,
	output reg 												Poly_Basemul_done,
	output reg 	[o_Poly_Size -1 : 0] 	oPoly_r
);

wire signed [15:0] zeta [63:0];
assign zeta[0]=16'd2226; 
assign zeta[1]=16'd430; 
assign zeta[2]=16'd555; 
assign zeta[3]=16'd843; 
assign zeta[4]=16'd2078; 
assign zeta[5]=16'd871; 
assign zeta[6]=16'd1550; 
assign zeta[7]=16'd105; 
assign zeta[8]=16'd422; 
assign zeta[9]=16'd587; 
assign zeta[10]=16'd177; 
assign zeta[11]=16'd3094; 
assign zeta[12]=16'd3038; 
assign zeta[13]=16'd2869; 
assign zeta[14]=16'd1574; 
assign zeta[15]=16'd1653; 
assign zeta[16]=16'd3083; 
assign zeta[17]=16'd778; 
assign zeta[18]=16'd1159; 
assign zeta[19]=16'd3182; 
assign zeta[20]=16'd2552; 
assign zeta[21]=16'd1483; 
assign zeta[22]=16'd2727; 
assign zeta[23]=16'd1119; 
assign zeta[24]=16'd1739; 
assign zeta[25]=16'd644; 
assign zeta[26]=16'd2457; 
assign zeta[27]=16'd349; 
assign zeta[28]=16'd418; 
assign zeta[29]=16'd329; 
assign zeta[30]=16'd3173; 
assign zeta[31]=16'd3254; 
assign zeta[32]=16'd817; 
assign zeta[33]=16'd1097; 
assign zeta[34]=16'd603; 
assign zeta[35]=16'd610; 
assign zeta[36]=16'd1322; 
assign zeta[37]=16'd2044; 
assign zeta[38]=16'd1864; 
assign zeta[39]=16'd384; 
assign zeta[40]=16'd2114; 
assign zeta[41]=16'd3193; 
assign zeta[42]=16'd1218; 
assign zeta[43]=16'd1994; 
assign zeta[44]=16'd2455; 
assign zeta[45]=16'd220; 
assign zeta[46]=16'd2142; 
assign zeta[47]=16'd1670; 
assign zeta[48]=16'd2144; 
assign zeta[49]=16'd1799; 
assign zeta[50]=16'd2051; 
assign zeta[51]=16'd794; 
assign zeta[52]=16'd1819; 
assign zeta[53]=16'd2475; 
assign zeta[54]=16'd2459; 
assign zeta[55]=16'd478; 
assign zeta[56]=16'd3221; 
assign zeta[57]=16'd3021; 
assign zeta[58]=16'd996; 
assign zeta[59]=16'd991; 
assign zeta[60]=16'd958; 
assign zeta[61]=16'd1869; 
assign zeta[62]=16'd1522; 
assign zeta[63]=16'd1628;

reg  P1_Poly_Basemul_enable;
reg  P2_Poly_Basemul_enable;
reg  [Setp_i_Width-1 : 0] P1_Poly_Basemul_iCoeffs_a0;
reg  [Setp_i_Width-1 : 0] P1_Poly_Basemul_iCoeffs_b0;
reg  [Setp_i_Width-1 : 0] P1_Poly_Basemul_iCoeffs_a1;
reg  [Setp_i_Width-1 : 0] P1_Poly_Basemul_iCoeffs_b1;
reg  [Setp_i_Width-1 : 0] P1_Poly_Basemul_i_Zeta;
reg  [Setp_i_Width-1 : 0] P2_Poly_Basemul_iCoeffs_a0;
reg  [Setp_i_Width-1 : 0] P2_Poly_Basemul_iCoeffs_b0;
reg  [Setp_i_Width-1 : 0] P2_Poly_Basemul_iCoeffs_a1;
reg  [Setp_i_Width-1 : 0] P2_Poly_Basemul_iCoeffs_b1;
reg  [Setp_i_Width-1 : 0] P2_Poly_Basemul_i_Zeta;
wire P1_Poly_Basemul_done;
wire P2_Poly_Basemul_done;
wire [Setp_o_Width-1 : 0] P1_oPoly_r0;
wire [Setp_o_Width-1 : 0] P1_oPoly_r1;
wire [Setp_o_Width-1 : 0] P2_oPoly_r0;
wire [Setp_o_Width-1 : 0] P2_oPoly_r1;


reg  [o_Coeffs_Width-1 : 0] temp_Poly_Coeffs_a [KYBER_N-1:0];
reg  [o_Coeffs_Width-1 : 0] temp_Poly_Coeffs_b [KYBER_N-1:0];
// reg  [o_Coeffs_Width-1 : 0] temp_Poly_Coeffs_r [KYBER_N-1:0];

integer a;
integer i;

reg [7:0] x;

reg [1:0] cstate,nstate;
localparam IDLE		        = 2'd0;
localparam Data_Pre       = 2'd1;
localparam Data_Send      = 2'd2;
localparam Data_Store   	= 2'd3;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or P1_Poly_Basemul_done or P2_Poly_Basemul_done or i or a) 
begin				
	case(cstate)
		IDLE: 			if (enable) 	nstate = Data_Pre;
				   			else 					nstate = IDLE;
		Data_Pre:   if (a == 256) nstate = Data_Send;
								else					nstate = Data_Pre;
		Data_Send:  if (P1_Poly_Basemul_done && P2_Poly_Basemul_done) 
															nstate = Data_Store;
		           	else 					nstate = Data_Send;
		Data_Store: if (i >= 64) 	nstate = IDLE;
				   			else 					nstate = Data_Send;		   				
		default: 									nstate = IDLE;
	endcase	
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
			Poly_Basemul_done <= 1'b0;
			oPoly_r <= 0;
			P1_Poly_Basemul_enable <= 1'b0;
			P2_Poly_Basemul_enable <= 1'b0;
			a <= 0;
		end
	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Poly_Basemul_done <= 1'b0;	
				end
			{IDLE,Data_Pre}: begin
					// BUG: Very slow
				  // for(a=0;a<256;a=a+1) begin
						// BUG: reversed bytes
						// temp_Poly_Coeffs_a[a] <=iPoly_a[(i_Poly_Size_a-1)-((255-a)*16) -: 16];
						// temp_Poly_Coeffs_b[a] <=iPoly_b[(i_Poly_Size_b-1)-((255-a)*12) -: 12];

						// temp_Poly_Coeffs_a[255-a] <= iPoly_a[(i_Poly_Size_a-1)-((255-a)*16) -: 16];
						// temp_Poly_Coeffs_b[(8*(a/8)+7)-(a&7)] <= {4'h0, iPoly_b[(i_Poly_Size_b-1)-((255-a)*12) -: 12]};
					// end

					temp_Poly_Coeffs_a[255-a] 						<= 				iPoly_a[(i_Poly_Size_a-1)-((255-a)*16) -: 16];
					temp_Poly_Coeffs_b[(8*(a/8)+7)-(a&7)] <= {4'h0, iPoly_b[(i_Poly_Size_b-1)-((255-a)*12) -: 12]};
					a <= a + 1;
				end
			{Data_Pre,Data_Pre}: begin
					temp_Poly_Coeffs_a[255-a] 						<= 				iPoly_a[(i_Poly_Size_a-1)-((255-a)*16) -: 16];
					temp_Poly_Coeffs_b[(8*(a/8)+7)-(a&7)] <= {4'h0, iPoly_b[(i_Poly_Size_b-1)-((255-a)*12) -: 12]};
					a <= a + 1;
				end
			{Data_Pre,Data_Send}: begin
					P1_Poly_Basemul_iCoeffs_a0 <= temp_Poly_Coeffs_a[0];
					P1_Poly_Basemul_iCoeffs_b0 <= temp_Poly_Coeffs_b[0];
					P1_Poly_Basemul_iCoeffs_a1 <= temp_Poly_Coeffs_a[1];
					P1_Poly_Basemul_iCoeffs_b1 <= temp_Poly_Coeffs_b[1];
					P1_Poly_Basemul_enable <= 1'b1;
					P2_Poly_Basemul_iCoeffs_a0 <= temp_Poly_Coeffs_a[2];
					P2_Poly_Basemul_iCoeffs_b0 <= temp_Poly_Coeffs_b[2];
					P2_Poly_Basemul_iCoeffs_a1 <= temp_Poly_Coeffs_a[3];
					P2_Poly_Basemul_iCoeffs_b1 <= temp_Poly_Coeffs_b[3];
					P2_Poly_Basemul_enable <= 1'b1;
					P1_Poly_Basemul_i_Zeta <= zeta[0];
					P2_Poly_Basemul_i_Zeta <= -zeta[0];
					i <= 1;		      				       
				end
			{Data_Send,Data_Send}: begin
					P1_Poly_Basemul_enable <= 1'b0;
					P2_Poly_Basemul_enable <= 1'b0;
					// $display("1");		       
				end
			{Data_Send,Data_Store}: begin
					// temp_Poly_Coeffs_r[255-(4*i-4)] <= P1_oPoly_r0;
					// temp_Poly_Coeffs_r[255-(4*i-3)] <= P1_oPoly_r1;
					// temp_Poly_Coeffs_r[255-(4*i-2)] <= P2_oPoly_r0;
					// temp_Poly_Coeffs_r[255-(4*i-1)] <= P2_oPoly_r1;
					oPoly_r[(255-(4*i-4))*16 +: 16] <= P1_oPoly_r0;
					oPoly_r[(255-(4*i-3))*16 +: 16] <= P1_oPoly_r1;
					oPoly_r[(255-(4*i-2))*16 +: 16] <= P2_oPoly_r0;
					oPoly_r[(255-(4*i-1))*16 +: 16] <= P2_oPoly_r1;
					// DEBUG:
					// $display("%d | r0: %h, a: %h, b: %h, zetas: %h", (i-1), P1_oPoly_r0, P1_Poly_Basemul_iCoeffs_a0, P1_Poly_Basemul_iCoeffs_b0, zeta[i-1]);
					// $display("%d | r0: %h, a: %h, b: %h, zetas: %h", (i-1), P1_oPoly_r1, P1_Poly_Basemul_iCoeffs_a1, P1_Poly_Basemul_iCoeffs_b1, zeta[i-1]);
					// $display("%d | r1: %h, a: %h, b: %h, zetas: %h", (i-1), P2_oPoly_r0, P2_Poly_Basemul_iCoeffs_a0, P2_Poly_Basemul_iCoeffs_b0, -zeta[i-1]);
					// $display("%d | r1: %h, a: %h, b: %h, zetas: %h", (i-1), P2_oPoly_r1, P2_Poly_Basemul_iCoeffs_a1, P2_Poly_Basemul_iCoeffs_b1, -zeta[i-1]);
				end                        
			{Data_Store,Data_Send}: begin
					P1_Poly_Basemul_iCoeffs_a0 <= temp_Poly_Coeffs_a[4*i];
					P1_Poly_Basemul_iCoeffs_b0 <= temp_Poly_Coeffs_b[4*i];
					P1_Poly_Basemul_iCoeffs_a1 <= temp_Poly_Coeffs_a[4*i+1];
					P1_Poly_Basemul_iCoeffs_b1 <= temp_Poly_Coeffs_b[4*i+1];
					P1_Poly_Basemul_enable <= 1'b1;
					P2_Poly_Basemul_iCoeffs_a0 <= temp_Poly_Coeffs_a[4*i+2];
					P2_Poly_Basemul_iCoeffs_b0 <= temp_Poly_Coeffs_b[4*i+2];
					P2_Poly_Basemul_iCoeffs_a1 <= temp_Poly_Coeffs_a[4*i+3];
					P2_Poly_Basemul_iCoeffs_b1 <= temp_Poly_Coeffs_b[4*i+3];
					P2_Poly_Basemul_enable <= 1'b1;
					P1_Poly_Basemul_i_Zeta <= zeta[i];
					P2_Poly_Basemul_i_Zeta <= -zeta[i];
					i <= i+1;
					// $display("3");    
				end
			{Data_Store,IDLE}: begin
					Poly_Basemul_done <= 1'b1;
					i <= 0;
					a <= 0;
					// BUG: reversed coefficients, Very slow
					// oPoly_r <= {temp_Poly_Coeffs_r[255],temp_Poly_Coeffs_r[254],temp_Poly_Coeffs_r[253],temp_Poly_Coeffs_r[252],temp_Poly_Coeffs_r[251],temp_Poly_Coeffs_r[250],temp_Poly_Coeffs_r[249],temp_Poly_Coeffs_r[248],temp_Poly_Coeffs_r[247],temp_Poly_Coeffs_r[246],temp_Poly_Coeffs_r[245],temp_Poly_Coeffs_r[244],temp_Poly_Coeffs_r[243],temp_Poly_Coeffs_r[242],temp_Poly_Coeffs_r[241],temp_Poly_Coeffs_r[240],temp_Poly_Coeffs_r[239],temp_Poly_Coeffs_r[238],temp_Poly_Coeffs_r[237],temp_Poly_Coeffs_r[236],temp_Poly_Coeffs_r[235],temp_Poly_Coeffs_r[234],temp_Poly_Coeffs_r[233],temp_Poly_Coeffs_r[232],temp_Poly_Coeffs_r[231],temp_Poly_Coeffs_r[230],temp_Poly_Coeffs_r[229],temp_Poly_Coeffs_r[228],temp_Poly_Coeffs_r[227],temp_Poly_Coeffs_r[226],temp_Poly_Coeffs_r[225],temp_Poly_Coeffs_r[224],temp_Poly_Coeffs_r[223],temp_Poly_Coeffs_r[222],temp_Poly_Coeffs_r[221],temp_Poly_Coeffs_r[220],temp_Poly_Coeffs_r[219],temp_Poly_Coeffs_r[218],temp_Poly_Coeffs_r[217],temp_Poly_Coeffs_r[216],temp_Poly_Coeffs_r[215],temp_Poly_Coeffs_r[214],temp_Poly_Coeffs_r[213],temp_Poly_Coeffs_r[212],temp_Poly_Coeffs_r[211],temp_Poly_Coeffs_r[210],temp_Poly_Coeffs_r[209],temp_Poly_Coeffs_r[208],temp_Poly_Coeffs_r[207],temp_Poly_Coeffs_r[206],temp_Poly_Coeffs_r[205],temp_Poly_Coeffs_r[204],temp_Poly_Coeffs_r[203],temp_Poly_Coeffs_r[202],temp_Poly_Coeffs_r[201],temp_Poly_Coeffs_r[200],temp_Poly_Coeffs_r[199],temp_Poly_Coeffs_r[198],temp_Poly_Coeffs_r[197],temp_Poly_Coeffs_r[196],temp_Poly_Coeffs_r[195],temp_Poly_Coeffs_r[194],temp_Poly_Coeffs_r[193],temp_Poly_Coeffs_r[192],temp_Poly_Coeffs_r[191],temp_Poly_Coeffs_r[190],temp_Poly_Coeffs_r[189],temp_Poly_Coeffs_r[188],temp_Poly_Coeffs_r[187],temp_Poly_Coeffs_r[186],temp_Poly_Coeffs_r[185],temp_Poly_Coeffs_r[184],temp_Poly_Coeffs_r[183],temp_Poly_Coeffs_r[182],temp_Poly_Coeffs_r[181],temp_Poly_Coeffs_r[180],temp_Poly_Coeffs_r[179],temp_Poly_Coeffs_r[178],temp_Poly_Coeffs_r[177],temp_Poly_Coeffs_r[176],temp_Poly_Coeffs_r[175],temp_Poly_Coeffs_r[174],temp_Poly_Coeffs_r[173],temp_Poly_Coeffs_r[172],temp_Poly_Coeffs_r[171],temp_Poly_Coeffs_r[170],temp_Poly_Coeffs_r[169],temp_Poly_Coeffs_r[168],temp_Poly_Coeffs_r[167],temp_Poly_Coeffs_r[166],temp_Poly_Coeffs_r[165],temp_Poly_Coeffs_r[164],temp_Poly_Coeffs_r[163],temp_Poly_Coeffs_r[162],temp_Poly_Coeffs_r[161],temp_Poly_Coeffs_r[160],temp_Poly_Coeffs_r[159],temp_Poly_Coeffs_r[158],temp_Poly_Coeffs_r[157],temp_Poly_Coeffs_r[156],temp_Poly_Coeffs_r[155],temp_Poly_Coeffs_r[154],temp_Poly_Coeffs_r[153],temp_Poly_Coeffs_r[152],temp_Poly_Coeffs_r[151],temp_Poly_Coeffs_r[150],temp_Poly_Coeffs_r[149],temp_Poly_Coeffs_r[148],temp_Poly_Coeffs_r[147],temp_Poly_Coeffs_r[146],temp_Poly_Coeffs_r[145],temp_Poly_Coeffs_r[144],temp_Poly_Coeffs_r[143],temp_Poly_Coeffs_r[142],temp_Poly_Coeffs_r[141],temp_Poly_Coeffs_r[140],temp_Poly_Coeffs_r[139],temp_Poly_Coeffs_r[138],temp_Poly_Coeffs_r[137],temp_Poly_Coeffs_r[136],temp_Poly_Coeffs_r[135],temp_Poly_Coeffs_r[134],temp_Poly_Coeffs_r[133],temp_Poly_Coeffs_r[132],temp_Poly_Coeffs_r[131],temp_Poly_Coeffs_r[130],temp_Poly_Coeffs_r[129],temp_Poly_Coeffs_r[128],temp_Poly_Coeffs_r[127],temp_Poly_Coeffs_r[126],temp_Poly_Coeffs_r[125],temp_Poly_Coeffs_r[124],temp_Poly_Coeffs_r[123],temp_Poly_Coeffs_r[122],temp_Poly_Coeffs_r[121],temp_Poly_Coeffs_r[120],temp_Poly_Coeffs_r[119],temp_Poly_Coeffs_r[118],temp_Poly_Coeffs_r[117],temp_Poly_Coeffs_r[116],temp_Poly_Coeffs_r[115],temp_Poly_Coeffs_r[114],temp_Poly_Coeffs_r[113],temp_Poly_Coeffs_r[112],temp_Poly_Coeffs_r[111],temp_Poly_Coeffs_r[110],temp_Poly_Coeffs_r[109],temp_Poly_Coeffs_r[108],temp_Poly_Coeffs_r[107],temp_Poly_Coeffs_r[106],temp_Poly_Coeffs_r[105],temp_Poly_Coeffs_r[104],temp_Poly_Coeffs_r[103],temp_Poly_Coeffs_r[102],temp_Poly_Coeffs_r[101],temp_Poly_Coeffs_r[100],temp_Poly_Coeffs_r[99],temp_Poly_Coeffs_r[98],temp_Poly_Coeffs_r[97],temp_Poly_Coeffs_r[96],temp_Poly_Coeffs_r[95],temp_Poly_Coeffs_r[94],temp_Poly_Coeffs_r[93],temp_Poly_Coeffs_r[92],temp_Poly_Coeffs_r[91],temp_Poly_Coeffs_r[90],temp_Poly_Coeffs_r[89],temp_Poly_Coeffs_r[88],temp_Poly_Coeffs_r[87],temp_Poly_Coeffs_r[86],temp_Poly_Coeffs_r[85],temp_Poly_Coeffs_r[84],temp_Poly_Coeffs_r[83],temp_Poly_Coeffs_r[82],temp_Poly_Coeffs_r[81],temp_Poly_Coeffs_r[80],temp_Poly_Coeffs_r[79],temp_Poly_Coeffs_r[78],temp_Poly_Coeffs_r[77],temp_Poly_Coeffs_r[76],temp_Poly_Coeffs_r[75],temp_Poly_Coeffs_r[74],temp_Poly_Coeffs_r[73],temp_Poly_Coeffs_r[72],temp_Poly_Coeffs_r[71],temp_Poly_Coeffs_r[70],temp_Poly_Coeffs_r[69],temp_Poly_Coeffs_r[68],temp_Poly_Coeffs_r[67],temp_Poly_Coeffs_r[66],temp_Poly_Coeffs_r[65],temp_Poly_Coeffs_r[64],temp_Poly_Coeffs_r[63],temp_Poly_Coeffs_r[62],temp_Poly_Coeffs_r[61],temp_Poly_Coeffs_r[60],temp_Poly_Coeffs_r[59],temp_Poly_Coeffs_r[58],temp_Poly_Coeffs_r[57],temp_Poly_Coeffs_r[56],temp_Poly_Coeffs_r[55],temp_Poly_Coeffs_r[54],temp_Poly_Coeffs_r[53],temp_Poly_Coeffs_r[52],temp_Poly_Coeffs_r[51],temp_Poly_Coeffs_r[50],temp_Poly_Coeffs_r[49],temp_Poly_Coeffs_r[48],temp_Poly_Coeffs_r[47],temp_Poly_Coeffs_r[46],temp_Poly_Coeffs_r[45],temp_Poly_Coeffs_r[44],temp_Poly_Coeffs_r[43],temp_Poly_Coeffs_r[42],temp_Poly_Coeffs_r[41],temp_Poly_Coeffs_r[40],temp_Poly_Coeffs_r[39],temp_Poly_Coeffs_r[38],temp_Poly_Coeffs_r[37],temp_Poly_Coeffs_r[36],temp_Poly_Coeffs_r[35],temp_Poly_Coeffs_r[34],temp_Poly_Coeffs_r[33],temp_Poly_Coeffs_r[32],temp_Poly_Coeffs_r[31],temp_Poly_Coeffs_r[30],temp_Poly_Coeffs_r[29],temp_Poly_Coeffs_r[28],temp_Poly_Coeffs_r[27],temp_Poly_Coeffs_r[26],temp_Poly_Coeffs_r[25],temp_Poly_Coeffs_r[24],temp_Poly_Coeffs_r[23],temp_Poly_Coeffs_r[22],temp_Poly_Coeffs_r[21],temp_Poly_Coeffs_r[20],temp_Poly_Coeffs_r[19],temp_Poly_Coeffs_r[18],temp_Poly_Coeffs_r[17],temp_Poly_Coeffs_r[16],temp_Poly_Coeffs_r[15],temp_Poly_Coeffs_r[14],temp_Poly_Coeffs_r[13],temp_Poly_Coeffs_r[12],temp_Poly_Coeffs_r[11],temp_Poly_Coeffs_r[10],temp_Poly_Coeffs_r[9],temp_Poly_Coeffs_r[8],temp_Poly_Coeffs_r[7],temp_Poly_Coeffs_r[6],temp_Poly_Coeffs_r[5],temp_Poly_Coeffs_r[4],temp_Poly_Coeffs_r[3],temp_Poly_Coeffs_r[2],temp_Poly_Coeffs_r[1],temp_Poly_Coeffs_r[0]};
					// for (x=0; x<256; x=x+1) begin
					// 	oPoly_r[4079-(16*x) -: 16] <= {temp_Poly_Coeffs_r[x], temp_Poly_Coeffs_r[x+1], temp_Poly_Coeffs_r[x+2], temp_Poly_Coeffs_r[x+3], temp_Poly_Coeffs_r[x], temp_Poly_Coeffs_r[x], temp_Poly_Coeffs_r[x], temp_Poly_Coeffs_r[x]};
					// end
					// oPoly_r <= temp_Poly_Coeffs_r;
					// $display("PACC Basemul (OUT): %h", oPoly_r);
				end                			                 			                 	
			default: ;
			endcase
		end
	
					
State_PAcc__Poly_PAcc__Poly_Basemul__Basemul P1(
.clk(clk),		
.reset_n(reset_n),
.enable(P1_Poly_Basemul_enable),	
.iCoeffs_a0(P1_Poly_Basemul_iCoeffs_a0),
.iCoeffs_b0(P1_Poly_Basemul_iCoeffs_b0),
.iCoeffs_a1(P1_Poly_Basemul_iCoeffs_a1),
.iCoeffs_b1(P1_Poly_Basemul_iCoeffs_b1),
.i_Zeta(P1_Poly_Basemul_i_Zeta),    
.Basemul_done(P1_Poly_Basemul_done),
.oPoly_r0(P1_oPoly_r0),
.oPoly_r1(P1_oPoly_r1)
);

State_PAcc__Poly_PAcc__Poly_Basemul__Basemul P2(
.clk(clk),		
.reset_n(reset_n),
.enable(P2_Poly_Basemul_enable),	
.iCoeffs_a0(P2_Poly_Basemul_iCoeffs_a0),
.iCoeffs_b0(P2_Poly_Basemul_iCoeffs_b0),
.iCoeffs_a1(P2_Poly_Basemul_iCoeffs_a1),
.iCoeffs_b1(P2_Poly_Basemul_iCoeffs_b1),
.i_Zeta(P2_Poly_Basemul_i_Zeta),    
.Basemul_done(P2_Poly_Basemul_done),
.oPoly_r0(P2_oPoly_r0),
.oPoly_r1(P2_oPoly_r1)
);
		
endmodule
