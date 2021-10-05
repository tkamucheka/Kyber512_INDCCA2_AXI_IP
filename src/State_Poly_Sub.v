//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Poly_Sub
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING HUANG, Tendayi Kamucheka (ftendayi@gmail.com)
//////////////////////////////////////////////////////////////////////////////////

module State_Poly_Sub #(
  parameter KYBER_K           = 2,
  parameter KYBER_N           = 256,
  parameter KYBER_Q           = 3329,
  parameter i_Coeffs_Width_v  = 12,
  parameter i_Coeffs_Width_mp = 16,
  parameter i_INTT_Mp_Length  = 128,
  parameter i_Dec_v_Length    = 96,
  parameter o_Sub_BRAM_Length = 128
)(
  input                           clk,    
  input                           rst_n,
  input                           enable,
  input [i_INTT_Mp_Length-1 : 0]  INTT_Enc_BpV_DecMp_RData,
  input [i_Dec_v_Length-1 : 0]    Dec_v_RData,
  output reg [6 : 0]              INTT_Enc_BpV_DecMp_RAd, 
                                  //// 0-31 EncV/DecMp, 32-63 EncBp0, 64-95 EncBp1
  output reg [4 : 0]              Dec_v_RAd, 
  output reg                      Function_done,
  output reg                      Sub_EncBp_DecMp_outready,
  output reg [7 : 0]              Sub_EncBp_DecMp_WAd, 
                                  /// 0-31 EncBp0 DecMp, 32-63 EncBp1, 64-95 EncV
  output reg [128-1 : 0]          Sub_EncBp_DecMp_WData
); 

wire [o_Sub_BRAM_Length-1 : 0] P0_oCoeffs;
reg get;

reg [1:0] cstate,nstate;
localparam IDLE          = 2'd0;
localparam Pop_v_mp      = 2'd1;
localparam Push_v_mp     = 2'd2;


always @(posedge clk or negedge rst_n)
  if(!rst_n) cstate <= IDLE;
  else cstate <= nstate;
  
always @(cstate or enable  or Sub_EncBp_DecMp_WAd or get) 
begin       
  case(cstate)
    IDLE:       if (enable)                     nstate <= Pop_v_mp;
                else                            nstate <= IDLE;
    Pop_v_mp:   if (get == 1)                   nstate <= Push_v_mp;
                else                            nstate <= Pop_v_mp;          
    Push_v_mp:  if (Sub_EncBp_DecMp_WAd == 95)  nstate <= IDLE;
                else                            nstate <= Pop_v_mp;
    default:                                    nstate <= IDLE;
  endcase
end

always @(posedge clk or negedge rst_n)                    
  if(!rst_n) begin
    INTT_Enc_BpV_DecMp_RAd    <= 7'hx;
    Dec_v_RAd                 <= 5'hx;
    Function_done             <= 0;
    Sub_EncBp_DecMp_outready  <= 0;
    Sub_EncBp_DecMp_WAd       <= 0;
    Sub_EncBp_DecMp_WData     <= 0;
    get                       <= 0;
  end else begin
    case({cstate,nstate})
      {IDLE,IDLE}: begin
          Function_done <= 1'b0;
        end
      {IDLE,Pop_v_mp}:begin             
          Dec_v_RAd               <= 0;
          INTT_Enc_BpV_DecMp_RAd  <= 0;
          Sub_EncBp_DecMp_WAd     <= 63;
          get                     <= 0;                                   
        end
      {Pop_v_mp,Pop_v_mp}: begin             
          get <= 1;                                   
        end
      {Pop_v_mp,Push_v_mp}:begin              
          Sub_EncBp_DecMp_outready  <= 1'b1;
          Sub_EncBp_DecMp_WAd       <= Sub_EncBp_DecMp_WAd + 1;
          Sub_EncBp_DecMp_WData     <= P0_oCoeffs;
          $display("Sub (OUT) [Mp]: %h", P0_oCoeffs);
        end
      {Push_v_mp,Pop_v_mp}:begin              
          Dec_v_RAd               <= Dec_v_RAd + 1;
          INTT_Enc_BpV_DecMp_RAd  <= INTT_Enc_BpV_DecMp_RAd + 1;
          get <= 0;                                  
        end
      {Push_v_mp,IDLE}:begin              
          Sub_EncBp_DecMp_outready  <= 1'b0;
          Sub_EncBp_DecMp_WData     <= P0_oCoeffs;
          INTT_Enc_BpV_DecMp_RAd    <= 7'hx;
          Dec_v_RAd                 <= 0;
          Function_done             <= 1'b1;
          Sub_EncBp_DecMp_WAd       <= 0;
          get <= 0; 
          // $display("Sub (OUT) [Mp]: %h", P0_oCoeffs);
        end   
      default: ;
    endcase
  end
    
State_Poly_Sub___Data_Cal P0(
.iCoeffs_a(Dec_v_RData),
.iCoeffs_b(INTT_Enc_BpV_DecMp_RData),
.oCoeffs(P0_oCoeffs)
);    
                  
endmodule
