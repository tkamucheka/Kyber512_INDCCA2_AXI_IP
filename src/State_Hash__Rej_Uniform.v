//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2019 01:43:08 PM
// Design Name: 
// Module Name: State_Hash__Rej_Uniform
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


module State_Hash__Rej_Uniform#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Compare_Constant = 19 * KYBER_Q,
  parameter i_CharArray_Width = 8,
  parameter Char_Array_Num = 672,
  parameter o_Coeffs_Width = 16,
  parameter i_CharArray_Size = i_CharArray_Width * Char_Array_Num,
  parameter o_Poly_Size = o_Coeffs_Width * KYBER_N
)(
	input clk,		
	input reset_n,
	input enable,
	input clear,	
  input [i_CharArray_Size-1 : 0] i_CharArray,
  output reg Rej_Uniform_done,
  output reg [o_Poly_Size -1 : 0]  oPoly
);

// No need to save coefficients
// reg [i_CharArray_Width-1 : 0] i_CharArray_Coeffs_P0_M [336-1:0];
// reg [i_CharArray_Width-1 : 0] i_CharArray_Coeffs_P0_L [336-1:0];

reg  [i_CharArray_Width-1 : 0] P0_iCoeffs_M;
reg  [i_CharArray_Width-1 : 0] P0_iCoeffs_L;

wire [o_Coeffs_Width-1 : 0] P0_oCoeffs;
wire 												P0_Comparer_result;

// reg  [o_Coeffs_Width-1 : 0] o_Poly_Coeffs [KYBER_N-1:0];
reg  [16-1 : 0] 						temp_val_0;

// integer x;

reg [8:0] i;
// Bug: Insufficient range. Causes earlier coefficients to be overwritten.
// reg [7:0] poly_counter;
reg [9:0] poly_counter;

reg [2:0] cstate,nstate;

localparam IDLE		  = 3'd0;
localparam Data_Pre	= 3'd1;
localparam Compare  = 3'd2;
localparam Cal      = 3'd3;
localparam Store    = 3'd4;

always @(posedge clk or negedge reset_n or posedge clear)
	if((!reset_n) || clear) cstate <= IDLE;
	else 										cstate <= nstate;
	
always @(cstate or enable or poly_counter or P0_Comparer_result)
begin				
	case(cstate)
		IDLE: 	  if(enable) 							nstate <= Data_Pre;
				   		else 										nstate <= IDLE;
		Data_Pre: 												nstate <= Compare;
		Compare:  												nstate <= Cal;
		Cal:      if(P0_Comparer_result) 	nstate <= Store;
		          else  									nstate <= Compare;
		// Bug: Misses last coefficient
		// Store:    if(poly_counter == 255) nstate <= IDLE;         				   
		Store:    if(poly_counter == 256) nstate <= IDLE;
				    	else 										nstate <= Compare;					
		default: 													nstate <= IDLE;
		endcase
end

// BUG: clk faster than computation
always @(posedge clk or negedge reset_n or posedge clear)
// always @(reset_n, clear, cstate, nstate, P0_oCoeffs)							
	if((!reset_n) || clear) begin
		Rej_Uniform_done <= 1'b0;
		oPoly <= 0;
		// a <= 0;
		i <= 0;
		poly_counter <= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Rej_Uniform_done <=  Rej_Uniform_done;	
				end
			{IDLE,Data_Pre}: begin
					Rej_Uniform_done <= 1'b0;
					// Bug: results in delayed processing of coefficients
					// for(a=0; a<336; a=a+1) begin
						// Bug: processes coefficients in reverse order
						// i_CharArray_Coeffs_P0_M[a] = i_CharArray[(5376-1)-((335-a)*16) -: 8];
						// i_CharArray_Coeffs_P0_L[a] = i_CharArray[(5376-1)-((335-a)*16) -: 16];
					// end
				end			
			{Compare,Cal}: begin
					// Bug: same as above. Process coefficients on the fly without saving
					// P0_iCoeffs_M <= i_CharArray_Coeffs_P0_M[i];
					// P0_iCoeffs_L <= i_CharArray_Coeffs_P0_L[i];
					P0_iCoeffs_M <= i_CharArray[(5376-1)-(i*16) -: 8];
					P0_iCoeffs_L <= i_CharArray[(5376-1)-(i*16) -: 16];
				end
			{Cal,Compare}: begin
					i <= i + 1;					
				end
			{Cal,Store}: begin
					i 					<= i + 1;
					temp_val_0 	<= (P0_oCoeffs >>> 12) * KYBER_Q;	
				end	  
			{Store,Compare}: begin
					poly_counter 								<= poly_counter + 1;
					// o_Poly_Coeffs[poly_counter] <= P0_oCoeffs - temp_val_0;
					oPoly[4095-(poly_counter*16) -: 16] <= P0_oCoeffs - temp_val_0;	        
				end					                   				 					           					
			{Store,IDLE}: begin
					Rej_Uniform_done <= 1'b1;
					// o_Poly_Coeffs[poly_counter] <= P0_oCoeffs - temp_val_0;
					oPoly[4095-(poly_counter*16) -: 16] <= P0_oCoeffs - temp_val_0;
					//oPoly <= {{P0_oCoeffs - temp_val_0},o_Poly_Coeffs[254],o_Poly_Coeffs[253],o_Poly_Coeffs[252],o_Poly_Coeffs[251],o_Poly_Coeffs[250],o_Poly_Coeffs[249],o_Poly_Coeffs[248],o_Poly_Coeffs[247],o_Poly_Coeffs[246],o_Poly_Coeffs[245],o_Poly_Coeffs[244],o_Poly_Coeffs[243],o_Poly_Coeffs[242],o_Poly_Coeffs[241],o_Poly_Coeffs[240],o_Poly_Coeffs[239],o_Poly_Coeffs[238],o_Poly_Coeffs[237],o_Poly_Coeffs[236],o_Poly_Coeffs[235],o_Poly_Coeffs[234],o_Poly_Coeffs[233],o_Poly_Coeffs[232],o_Poly_Coeffs[231],o_Poly_Coeffs[230],o_Poly_Coeffs[229],o_Poly_Coeffs[228],o_Poly_Coeffs[227],o_Poly_Coeffs[226],o_Poly_Coeffs[225],o_Poly_Coeffs[224],o_Poly_Coeffs[223],o_Poly_Coeffs[222],o_Poly_Coeffs[221],o_Poly_Coeffs[220],o_Poly_Coeffs[219],o_Poly_Coeffs[218],o_Poly_Coeffs[217],o_Poly_Coeffs[216],o_Poly_Coeffs[215],o_Poly_Coeffs[214],o_Poly_Coeffs[213],o_Poly_Coeffs[212],o_Poly_Coeffs[211],o_Poly_Coeffs[210],o_Poly_Coeffs[209],o_Poly_Coeffs[208],o_Poly_Coeffs[207],o_Poly_Coeffs[206],o_Poly_Coeffs[205],o_Poly_Coeffs[204],o_Poly_Coeffs[203],o_Poly_Coeffs[202],o_Poly_Coeffs[201],o_Poly_Coeffs[200],o_Poly_Coeffs[199],o_Poly_Coeffs[198],o_Poly_Coeffs[197],o_Poly_Coeffs[196],o_Poly_Coeffs[195],o_Poly_Coeffs[194],o_Poly_Coeffs[193],o_Poly_Coeffs[192],o_Poly_Coeffs[191],o_Poly_Coeffs[190],o_Poly_Coeffs[189],o_Poly_Coeffs[188],o_Poly_Coeffs[187],o_Poly_Coeffs[186],o_Poly_Coeffs[185],o_Poly_Coeffs[184],o_Poly_Coeffs[183],o_Poly_Coeffs[182],o_Poly_Coeffs[181],o_Poly_Coeffs[180],o_Poly_Coeffs[179],o_Poly_Coeffs[178],o_Poly_Coeffs[177],o_Poly_Coeffs[176],o_Poly_Coeffs[175],o_Poly_Coeffs[174],o_Poly_Coeffs[173],o_Poly_Coeffs[172],o_Poly_Coeffs[171],o_Poly_Coeffs[170],o_Poly_Coeffs[169],o_Poly_Coeffs[168],o_Poly_Coeffs[167],o_Poly_Coeffs[166],o_Poly_Coeffs[165],o_Poly_Coeffs[164],o_Poly_Coeffs[163],o_Poly_Coeffs[162],o_Poly_Coeffs[161],o_Poly_Coeffs[160],o_Poly_Coeffs[159],o_Poly_Coeffs[158],o_Poly_Coeffs[157],o_Poly_Coeffs[156],o_Poly_Coeffs[155],o_Poly_Coeffs[154],o_Poly_Coeffs[153],o_Poly_Coeffs[152],o_Poly_Coeffs[151],o_Poly_Coeffs[150],o_Poly_Coeffs[149],o_Poly_Coeffs[148],o_Poly_Coeffs[147],o_Poly_Coeffs[146],o_Poly_Coeffs[145],o_Poly_Coeffs[144],o_Poly_Coeffs[143],o_Poly_Coeffs[142],o_Poly_Coeffs[141],o_Poly_Coeffs[140],o_Poly_Coeffs[139],o_Poly_Coeffs[138],o_Poly_Coeffs[137],o_Poly_Coeffs[136],o_Poly_Coeffs[135],o_Poly_Coeffs[134],o_Poly_Coeffs[133],o_Poly_Coeffs[132],o_Poly_Coeffs[131],o_Poly_Coeffs[130],o_Poly_Coeffs[129],o_Poly_Coeffs[128],o_Poly_Coeffs[127],o_Poly_Coeffs[126],o_Poly_Coeffs[125],o_Poly_Coeffs[124],o_Poly_Coeffs[123],o_Poly_Coeffs[122],o_Poly_Coeffs[121],o_Poly_Coeffs[120],o_Poly_Coeffs[119],o_Poly_Coeffs[118],o_Poly_Coeffs[117],o_Poly_Coeffs[116],o_Poly_Coeffs[115],o_Poly_Coeffs[114],o_Poly_Coeffs[113],o_Poly_Coeffs[112],o_Poly_Coeffs[111],o_Poly_Coeffs[110],o_Poly_Coeffs[109],o_Poly_Coeffs[108],o_Poly_Coeffs[107],o_Poly_Coeffs[106],o_Poly_Coeffs[105],o_Poly_Coeffs[104],o_Poly_Coeffs[103],o_Poly_Coeffs[102],o_Poly_Coeffs[101],o_Poly_Coeffs[100],o_Poly_Coeffs[99],o_Poly_Coeffs[98],o_Poly_Coeffs[97],o_Poly_Coeffs[96],o_Poly_Coeffs[95],o_Poly_Coeffs[94],o_Poly_Coeffs[93],o_Poly_Coeffs[92],o_Poly_Coeffs[91],o_Poly_Coeffs[90],o_Poly_Coeffs[89],o_Poly_Coeffs[88],o_Poly_Coeffs[87],o_Poly_Coeffs[86],o_Poly_Coeffs[85],o_Poly_Coeffs[84],o_Poly_Coeffs[83],o_Poly_Coeffs[82],o_Poly_Coeffs[81],o_Poly_Coeffs[80],o_Poly_Coeffs[79],o_Poly_Coeffs[78],o_Poly_Coeffs[77],o_Poly_Coeffs[76],o_Poly_Coeffs[75],o_Poly_Coeffs[74],o_Poly_Coeffs[73],o_Poly_Coeffs[72],o_Poly_Coeffs[71],o_Poly_Coeffs[70],o_Poly_Coeffs[69],o_Poly_Coeffs[68],o_Poly_Coeffs[67],o_Poly_Coeffs[66],o_Poly_Coeffs[65],o_Poly_Coeffs[64],o_Poly_Coeffs[63],o_Poly_Coeffs[62],o_Poly_Coeffs[61],o_Poly_Coeffs[60],o_Poly_Coeffs[59],o_Poly_Coeffs[58],o_Poly_Coeffs[57],o_Poly_Coeffs[56],o_Poly_Coeffs[55],o_Poly_Coeffs[54],o_Poly_Coeffs[53],o_Poly_Coeffs[52],o_Poly_Coeffs[51],o_Poly_Coeffs[50],o_Poly_Coeffs[49],o_Poly_Coeffs[48],o_Poly_Coeffs[47],o_Poly_Coeffs[46],o_Poly_Coeffs[45],o_Poly_Coeffs[44],o_Poly_Coeffs[43],o_Poly_Coeffs[42],o_Poly_Coeffs[41],o_Poly_Coeffs[40],o_Poly_Coeffs[39],o_Poly_Coeffs[38],o_Poly_Coeffs[37],o_Poly_Coeffs[36],o_Poly_Coeffs[35],o_Poly_Coeffs[34],o_Poly_Coeffs[33],o_Poly_Coeffs[32],o_Poly_Coeffs[31],o_Poly_Coeffs[30],o_Poly_Coeffs[29],o_Poly_Coeffs[28],o_Poly_Coeffs[27],o_Poly_Coeffs[26],o_Poly_Coeffs[25],o_Poly_Coeffs[24],o_Poly_Coeffs[23],o_Poly_Coeffs[22],o_Poly_Coeffs[21],o_Poly_Coeffs[20],o_Poly_Coeffs[19],o_Poly_Coeffs[18],o_Poly_Coeffs[17],o_Poly_Coeffs[16],o_Poly_Coeffs[15],o_Poly_Coeffs[14],o_Poly_Coeffs[13],o_Poly_Coeffs[12],o_Poly_Coeffs[11],o_Poly_Coeffs[10],o_Poly_Coeffs[9],o_Poly_Coeffs[8],o_Poly_Coeffs[7],o_Poly_Coeffs[6],o_Poly_Coeffs[5],o_Poly_Coeffs[4],o_Poly_Coeffs[3],o_Poly_Coeffs[2],o_Poly_Coeffs[1],o_Poly_Coeffs[0]};
					// for(x=0 ;x<256; x=x+1) begin : U
					// 	oPoly[4095-(x*16) -: 16] <= o_Poly_Coeffs[x];
					// end
				end
			default: ;
		endcase
	end

State_Hash__Rej_Uniform_Comparer P0( 
.iCoeffs_M(P0_iCoeffs_M),
.iCoeffs_L(P0_iCoeffs_L),
.Comparer_result(P0_Comparer_result),
.oCoeffs(P0_oCoeffs)
);
						
endmodule
