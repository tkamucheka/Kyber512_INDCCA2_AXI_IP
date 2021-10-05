//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2019 05:21:33 PM
// Design Name: 
// Module Name: polyvec_decompress
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


module polyvec_decompress#(
  parameter KYBER_K = 2,
  parameter KYBER_POLYVECCOMPRESSEDBYTES = 320,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter data_Width = 12,
  parameter Byte_bits = 8,
  parameter i_PolyVec_Compressed_Size = Byte_bits * KYBER_POLYVECCOMPRESSEDBYTES,
  parameter o_Poly_Size = data_Width * KYBER_N
 )(
  input      clk,
  input      reset_n,
  input      enable,
  input      [i_PolyVec_Compressed_Size-1 : 0] i_PolyVec_Compressed,
  output reg out_ready,
  output reg [o_Poly_Size-1 : 0] oPolyVec
 );
 
 reg   [Byte_bits-1:0]  tmp_Poly_Compressed [KYBER_POLYVECCOMPRESSEDBYTES-1:0];
 reg   [data_Width-1:0] tmp_poly [KYBER_N-1:0];
 reg   cal_state;
 integer a;
 integer i;

      
always@(posedge clk or negedge reset_n)
  if(~reset_n) begin
    cal_state   <= 0;
    i           <= 0;
    out_ready   <= 0;
    oPolyVec    <= 0;
  end else if(enable && (!cal_state) && (!out_ready)) begin
    for(a=0;a<320;a=a+1)
      tmp_Poly_Compressed[a] <= i_PolyVec_Compressed[(i_PolyVec_Compressed_Size-1)-((319-a)*8) -: 8];
      cal_state <= 1;
      out_ready <= 0;
    end                                       
  else if(i == 65) begin
    i <= 0;
    out_ready   <= 0;
  end else if(i==64) begin
    oPolyVec <= {tmp_poly[255],tmp_poly[254],tmp_poly[253],tmp_poly[252],tmp_poly[251],tmp_poly[250],tmp_poly[249],tmp_poly[248],tmp_poly[247],tmp_poly[246],tmp_poly[245],tmp_poly[244],tmp_poly[243],tmp_poly[242],tmp_poly[241],tmp_poly[240],tmp_poly[239],tmp_poly[238],tmp_poly[237],tmp_poly[236],tmp_poly[235],tmp_poly[234],tmp_poly[233],tmp_poly[232],tmp_poly[231],tmp_poly[230],tmp_poly[229],tmp_poly[228],tmp_poly[227],tmp_poly[226],tmp_poly[225],tmp_poly[224],tmp_poly[223],tmp_poly[222],tmp_poly[221],tmp_poly[220],tmp_poly[219],tmp_poly[218],tmp_poly[217],tmp_poly[216],tmp_poly[215],tmp_poly[214],tmp_poly[213],tmp_poly[212],tmp_poly[211],tmp_poly[210],tmp_poly[209],tmp_poly[208],tmp_poly[207],tmp_poly[206],tmp_poly[205],tmp_poly[204],tmp_poly[203],tmp_poly[202],tmp_poly[201],tmp_poly[200],tmp_poly[199],tmp_poly[198],tmp_poly[197],tmp_poly[196],tmp_poly[195],tmp_poly[194],tmp_poly[193],tmp_poly[192],tmp_poly[191],tmp_poly[190],tmp_poly[189],tmp_poly[188],tmp_poly[187],tmp_poly[186],tmp_poly[185],tmp_poly[184],tmp_poly[183],tmp_poly[182],tmp_poly[181],tmp_poly[180],tmp_poly[179],tmp_poly[178],tmp_poly[177],tmp_poly[176],tmp_poly[175],tmp_poly[174],tmp_poly[173],tmp_poly[172],tmp_poly[171],tmp_poly[170],tmp_poly[169],tmp_poly[168],tmp_poly[167],tmp_poly[166],tmp_poly[165],tmp_poly[164],tmp_poly[163],tmp_poly[162],tmp_poly[161],tmp_poly[160],tmp_poly[159],tmp_poly[158],tmp_poly[157],tmp_poly[156],tmp_poly[155],tmp_poly[154],tmp_poly[153],tmp_poly[152],tmp_poly[151],tmp_poly[150],tmp_poly[149],tmp_poly[148],tmp_poly[147],tmp_poly[146],tmp_poly[145],tmp_poly[144],tmp_poly[143],tmp_poly[142],tmp_poly[141],tmp_poly[140],tmp_poly[139],tmp_poly[138],tmp_poly[137],tmp_poly[136],tmp_poly[135],tmp_poly[134],tmp_poly[133],tmp_poly[132],tmp_poly[131],tmp_poly[130],tmp_poly[129],tmp_poly[128],tmp_poly[127],tmp_poly[126],tmp_poly[125],tmp_poly[124],tmp_poly[123],tmp_poly[122],tmp_poly[121],tmp_poly[120],tmp_poly[119],tmp_poly[118],tmp_poly[117],tmp_poly[116],tmp_poly[115],tmp_poly[114],tmp_poly[113],tmp_poly[112],tmp_poly[111],tmp_poly[110],tmp_poly[109],tmp_poly[108],tmp_poly[107],tmp_poly[106],tmp_poly[105],tmp_poly[104],tmp_poly[103],tmp_poly[102],tmp_poly[101],tmp_poly[100],tmp_poly[99],tmp_poly[98],tmp_poly[97],tmp_poly[96],tmp_poly[95],tmp_poly[94],tmp_poly[93],tmp_poly[92],tmp_poly[91],tmp_poly[90],tmp_poly[89],tmp_poly[88],tmp_poly[87],tmp_poly[86],tmp_poly[85],tmp_poly[84],tmp_poly[83],tmp_poly[82],tmp_poly[81],tmp_poly[80],tmp_poly[79],tmp_poly[78],tmp_poly[77],tmp_poly[76],tmp_poly[75],tmp_poly[74],tmp_poly[73],tmp_poly[72],tmp_poly[71],tmp_poly[70],tmp_poly[69],tmp_poly[68],tmp_poly[67],tmp_poly[66],tmp_poly[65],tmp_poly[64],tmp_poly[63],tmp_poly[62],tmp_poly[61],tmp_poly[60],tmp_poly[59],tmp_poly[58],tmp_poly[57],tmp_poly[56],tmp_poly[55],tmp_poly[54],tmp_poly[53],tmp_poly[52],tmp_poly[51],tmp_poly[50],tmp_poly[49],tmp_poly[48],tmp_poly[47],tmp_poly[46],tmp_poly[45],tmp_poly[44],tmp_poly[43],tmp_poly[42],tmp_poly[41],tmp_poly[40],tmp_poly[39],tmp_poly[38],tmp_poly[37],tmp_poly[36],tmp_poly[35],tmp_poly[34],tmp_poly[33],tmp_poly[32],tmp_poly[31],tmp_poly[30],tmp_poly[29],tmp_poly[28],tmp_poly[27],tmp_poly[26],tmp_poly[25],tmp_poly[24],tmp_poly[23],tmp_poly[22],tmp_poly[21],tmp_poly[20],tmp_poly[19],tmp_poly[18],tmp_poly[17],tmp_poly[16],tmp_poly[15],tmp_poly[14],tmp_poly[13],tmp_poly[12],tmp_poly[11],tmp_poly[10],tmp_poly[9],tmp_poly[8],tmp_poly[7],tmp_poly[6],tmp_poly[5],tmp_poly[4],tmp_poly[3],tmp_poly[2],tmp_poly[1],tmp_poly[0]};
    out_ready <= 1;          
    cal_state <= 0;
    i <= i + 1;
    out_ready <= 1;
  end else if(cal_state) begin
    for(i=0;i<64;i=i+1) begin
      tmp_poly[4*i]   <= (((tmp_Poly_Compressed[5*i]| ((tmp_Poly_Compressed[5*i+1] & 8'h03) <<< 8)) * KYBER_Q)+512) >>> 10;
      tmp_poly[4*i+1] <= ((((tmp_Poly_Compressed[5*i+1]>>>2) | ((tmp_Poly_Compressed[5*i+2] & 8'h0f) <<< 6)) * KYBER_Q)+512) >>> 10;
      tmp_poly[4*i+2] <= ((((tmp_Poly_Compressed[5*i+2]>>>4) | ((tmp_Poly_Compressed[5*i+3] & 8'h3f) <<< 4)) * KYBER_Q)+512) >>> 10;
      tmp_poly[4*i+3] <= ((((tmp_Poly_Compressed[5*i+3]>>>6) | ((tmp_Poly_Compressed[5*i+4] & 8'hff) <<< 2)) * KYBER_Q)+512) >>> 10;
    end
  end

endmodule
