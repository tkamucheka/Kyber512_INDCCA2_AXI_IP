//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Polytomsg
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING HUANG, Tendayi Kamucheka (ftendayi@gmail.com)
//////////////////////////////////////////////////////////////////////////////////

module State_Polytomsg#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Msg_Bytes = 32,
  parameter data_Width = 12,
  parameter Byte_bits = 8,
  parameter o_Msg_Size = Byte_bits * Msg_Bytes,
  parameter i_Poly_Size = data_Width * KYBER_N
)(
  input clk,    
  input rst_n,
  input enable, 
  input [data_Width-1 : 0] Reduce_DecMp_RData,
  output reg Function_done,
  output reg [7 : 0] Reduce_DecMp_RAd,
  output reg [o_Msg_Size -1 : 0]  oMsg  
);
    
reg  cal_enable;                            
wire Cal_oDone;
wire Cal_oMsg;                                
reg  [0:0] Msg_bits [KYBER_N-1:0];
integer i;
reg get;

reg [1:0] cstate,nstate;
parameter IDLE          = 2'd0;
parameter Pop_Mp        = 2'd1;
parameter Cal           = 2'd2;
parameter Push_Msg      = 2'd3;

always @(posedge clk or negedge rst_n)
  if (!rst_n) cstate <= IDLE;
  else        cstate <= nstate;
  
always @(cstate or enable or Cal_oDone or i or get) 
begin       
  case(cstate)
    IDLE:     if (enable)     nstate <= Pop_Mp;
              else            nstate <= IDLE;
    Pop_Mp:   if (get == 1)   nstate <= Cal;
              else            nstate <= Pop_Mp;      
    Cal:      if (Cal_oDone)  nstate <= Push_Msg;
              else            nstate <= Cal;
    Push_Msg: if (i == 255)   nstate <= IDLE;
              else            nstate <= Pop_Mp;                      
    default:                  nstate <= IDLE;
  endcase
end

always @(posedge clk or negedge rst_n)                    
  if(!rst_n) begin
    Function_done <= 1'b0;
    oMsg          <= 0;
    cal_enable    <= 1'b0;
    i             <= 0;
  end else begin
    case({cstate,nstate})
      {IDLE,IDLE}: begin
          Function_done <=  1'b0; 
        end
      {IDLE,Pop_Mp}: begin              
          Reduce_DecMp_RAd <= 0;
          get <= 0;
          i <= 0;       
        end      
      {Pop_Mp,Pop_Mp}: begin              
          get <= 1;       
        end
      {Pop_Mp,Cal}: begin
          get <= 0;
          cal_enable <= 1'b1;
          // $display("Poly_tomsg (IN) [Mp %h]: %h", Reduce_DecMp_RAd, Reduce_DecMp_RData);           
        end
      {Cal,Cal}: begin
          cal_enable <= 1'b0;           
        end
      {Cal,Push_Msg}: begin
          Msg_bits[i-1] <= Cal_oMsg;        
        end
      {Push_Msg,Pop_Mp}: begin
          Reduce_DecMp_RAd <= Reduce_DecMp_RAd + 1;
          i <= i + 1;                     
        end
      {Push_Msg,IDLE}: begin
          Function_done <= 1'b1;
          oMsg <= {Msg_bits[255],Msg_bits[254],Msg_bits[253],Msg_bits[252],Msg_bits[251],Msg_bits[250],Msg_bits[249],Msg_bits[248],Msg_bits[247],Msg_bits[246],Msg_bits[245],Msg_bits[244],Msg_bits[243],Msg_bits[242],Msg_bits[241],Msg_bits[240],Msg_bits[239],Msg_bits[238],Msg_bits[237],Msg_bits[236],Msg_bits[235],Msg_bits[234],Msg_bits[233],Msg_bits[232],Msg_bits[231],Msg_bits[230],Msg_bits[229],Msg_bits[228],Msg_bits[227],Msg_bits[226],Msg_bits[225],Msg_bits[224],Msg_bits[223],Msg_bits[222],Msg_bits[221],Msg_bits[220],Msg_bits[219],Msg_bits[218],Msg_bits[217],Msg_bits[216],Msg_bits[215],Msg_bits[214],Msg_bits[213],Msg_bits[212],Msg_bits[211],Msg_bits[210],Msg_bits[209],Msg_bits[208],Msg_bits[207],Msg_bits[206],Msg_bits[205],Msg_bits[204],Msg_bits[203],Msg_bits[202],Msg_bits[201],Msg_bits[200],Msg_bits[199],Msg_bits[198],Msg_bits[197],Msg_bits[196],Msg_bits[195],Msg_bits[194],Msg_bits[193],Msg_bits[192],Msg_bits[191],Msg_bits[190],Msg_bits[189],Msg_bits[188],Msg_bits[187],Msg_bits[186],Msg_bits[185],Msg_bits[184],Msg_bits[183],Msg_bits[182],Msg_bits[181],Msg_bits[180],Msg_bits[179],Msg_bits[178],Msg_bits[177],Msg_bits[176],Msg_bits[175],Msg_bits[174],Msg_bits[173],Msg_bits[172],Msg_bits[171],Msg_bits[170],Msg_bits[169],Msg_bits[168],Msg_bits[167],Msg_bits[166],Msg_bits[165],Msg_bits[164],Msg_bits[163],Msg_bits[162],Msg_bits[161],Msg_bits[160],Msg_bits[159],Msg_bits[158],Msg_bits[157],Msg_bits[156],Msg_bits[155],Msg_bits[154],Msg_bits[153],Msg_bits[152],Msg_bits[151],Msg_bits[150],Msg_bits[149],Msg_bits[148],Msg_bits[147],Msg_bits[146],Msg_bits[145],Msg_bits[144],Msg_bits[143],Msg_bits[142],Msg_bits[141],Msg_bits[140],Msg_bits[139],Msg_bits[138],Msg_bits[137],Msg_bits[136],Msg_bits[135],Msg_bits[134],Msg_bits[133],Msg_bits[132],Msg_bits[131],Msg_bits[130],Msg_bits[129],Msg_bits[128],Msg_bits[127],Msg_bits[126],Msg_bits[125],Msg_bits[124],Msg_bits[123],Msg_bits[122],Msg_bits[121],Msg_bits[120],Msg_bits[119],Msg_bits[118],Msg_bits[117],Msg_bits[116],Msg_bits[115],Msg_bits[114],Msg_bits[113],Msg_bits[112],Msg_bits[111],Msg_bits[110],Msg_bits[109],Msg_bits[108],Msg_bits[107],Msg_bits[106],Msg_bits[105],Msg_bits[104],Msg_bits[103],Msg_bits[102],Msg_bits[101],Msg_bits[100],Msg_bits[99],Msg_bits[98],Msg_bits[97],Msg_bits[96],Msg_bits[95],Msg_bits[94],Msg_bits[93],Msg_bits[92],Msg_bits[91],Msg_bits[90],Msg_bits[89],Msg_bits[88],Msg_bits[87],Msg_bits[86],Msg_bits[85],Msg_bits[84],Msg_bits[83],Msg_bits[82],Msg_bits[81],Msg_bits[80],Msg_bits[79],Msg_bits[78],Msg_bits[77],Msg_bits[76],Msg_bits[75],Msg_bits[74],Msg_bits[73],Msg_bits[72],Msg_bits[71],Msg_bits[70],Msg_bits[69],Msg_bits[68],Msg_bits[67],Msg_bits[66],Msg_bits[65],Msg_bits[64],Msg_bits[63],Msg_bits[62],Msg_bits[61],Msg_bits[60],Msg_bits[59],Msg_bits[58],Msg_bits[57],Msg_bits[56],Msg_bits[55],Msg_bits[54],Msg_bits[53],Msg_bits[52],Msg_bits[51],Msg_bits[50],Msg_bits[49],Msg_bits[48],Msg_bits[47],Msg_bits[46],Msg_bits[45],Msg_bits[44],Msg_bits[43],Msg_bits[42],Msg_bits[41],Msg_bits[40],Msg_bits[39],Msg_bits[38],Msg_bits[37],Msg_bits[36],Msg_bits[35],Msg_bits[34],Msg_bits[33],Msg_bits[32],Msg_bits[31],Msg_bits[30],Msg_bits[29],Msg_bits[28],Msg_bits[27],Msg_bits[26],Msg_bits[25],Msg_bits[24],Msg_bits[23],Msg_bits[22],Msg_bits[21],Msg_bits[20],Msg_bits[19],Msg_bits[18],Msg_bits[17],Msg_bits[16],Msg_bits[15],Msg_bits[14],Msg_bits[13],Msg_bits[12],Msg_bits[11],Msg_bits[10],Msg_bits[9],Msg_bits[8],Msg_bits[7],Msg_bits[6],Msg_bits[5],Msg_bits[4],Msg_bits[3],Msg_bits[2],Msg_bits[1],Msg_bits[0]};
          i <= 0;
        end
      default: ;
    endcase
  end
  
State_Polytomsg__DataCal State_Polytomsg__DataCal_0(
.clk(clk),    
.reset_n(rst_n),
.enable(cal_enable),  
.iCoeffs(Reduce_DecMp_RData), 
.Data_Cal_done(Cal_oDone),
.oMsg(Cal_oMsg) 
);              
    
endmodule
