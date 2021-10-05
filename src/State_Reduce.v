//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Reduce
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
// Additional Comments: Reusable for Encryption and Decryption
//////////////////////////////////////////////////////////////////////////////////

module State_Reduce#(
  parameter KYBER_K 				= 2,
  parameter KYBER_N 				= 256,
  parameter KYBER_Q 				= 3329,
  parameter i_Coeffs_Width 	= 16,
  parameter o_Coeffs_Width 	= 12,
  parameter o_BRAM_Length 	= 96,
  parameter i_Poly_Size 		= i_Coeffs_Width * KYBER_N,
  parameter o_Poly_Size 		= o_Coeffs_Width * KYBER_N
)(
  input                     				clk,    
  input                     				rst_n,
  input                     				enable,
  input                     				mux_enc_dec, // enc0, dec1    
  input [i_Poly_Size-1 : 0] 				Add_EncBpV_DecMp_RData,
  output reg [2 : 0] 								Add_EncBpV_DecMp_RAd,
  output reg 												Function_done,
  output reg 												Reduce_DecMp_outready,    
  output reg [4 : 0] 								Reduce_DecMp_WAd, // 0-31 DecMp,
  output reg [o_BRAM_Length-1 : 0] 	Reduce_DecMp_WData,
  output reg 												Reduce_EncBp_outready,    
  output reg [5 : 0] 								Reduce_EncBp_WAd, // 0-31 EncBp0,32-63 EncBp1
  output reg [o_BRAM_Length-1 : 0] 	Reduce_EncBp_WData,
  output reg 												Reduce_EncV_outready,    
  output reg [4 : 0] 								Reduce_EncV_WAd, // 0-31 EncV
  output reg [o_BRAM_Length-1 : 0] 	Reduce_EncV_WData,
  // DEBUG:
  output reg [255:0] reduceV_debug,
  output reg [255:0] reduceBp_debug
);

reg  get;
reg  P0_PolyReduce_enable;
wire P0_PolyReduce_done;
wire [o_Poly_Size-1 : 0] P0_PolyReduce_oPoly;

reg [3:0] cstate,nstate;
localparam IDLE         = 4'd0;
localparam Pop_0        = 4'd1;
localparam Reduce_0     = 4'd2;
localparam Push_Dec_0   = 4'd8;
localparam Push_0_Pop_1 = 4'd3;
localparam Reduce_1     = 4'd4;
localparam Push_1_Pop_2 = 4'd5;
localparam Reduce_2     = 4'd6;
localparam Push_2       = 4'd7;

always @(posedge clk or negedge rst_n)
  if(!rst_n)  cstate <= IDLE;
  else        cstate <= nstate;
  
always @(cstate or enable or P0_PolyReduce_done or Reduce_DecMp_WAd or Reduce_EncBp_WAd or Reduce_EncV_WAd or get or mux_enc_dec) 
begin       
  case(cstate)
    IDLE:         if(enable)                  nstate <= Pop_0;
                  else                        nstate <= IDLE;
    Pop_0:        if(get == 1)                nstate <= Reduce_0; 
                  else                        nstate <= Pop_0;         
    Reduce_0:     if (P0_PolyReduce_done && mux_enc_dec) 
                                              nstate <= Push_Dec_0;
                  else if(P0_PolyReduce_done) nstate <= Push_0_Pop_1;
                  else                        nstate <= Reduce_0; 
    Push_Dec_0:   if(Reduce_DecMp_WAd == 31)  nstate <= IDLE; 
                  else                        nstate <= Push_Dec_0;                  
    Push_0_Pop_1: if(Reduce_EncV_WAd == 31)   nstate <= Reduce_1;
                  else                        nstate <= Push_0_Pop_1;
    Reduce_1:     if(P0_PolyReduce_done)      nstate <= Push_1_Pop_2;
                  else                        nstate <= Reduce_1; 
    Push_1_Pop_2: if(Reduce_EncBp_WAd == 31)  nstate <= Reduce_2;          
                  else                        nstate <= Push_1_Pop_2;       
    Reduce_2:     if(P0_PolyReduce_done)      nstate <= Push_2;
                  else                        nstate <= Reduce_2;
    Push_2:       if(Reduce_EncBp_WAd == 63)  nstate <= IDLE;
                  else                        nstate <= Push_2;         
    default:                                  nstate <= IDLE;
  endcase
end

always @(posedge clk/* or negedge rst_n*/)                    
  if(!rst_n) begin
    P0_PolyReduce_enable  <= 1'b0;
    // Add_EncBpV_DecMp_RAd   <= 0;
    Function_done         <= 1'b0;
    Reduce_DecMp_outready <= 1'b0;
    Reduce_DecMp_WAd      <= 0;
    Reduce_DecMp_WData    <= 0;           
    Reduce_EncBp_outready <= 1'b0;
    Reduce_EncBp_WAd      <= 0;
    Reduce_EncBp_WData    <= 0;
    Reduce_EncV_outready  <= 1'b0;
    Reduce_EncV_WAd       <= 0;
    Reduce_EncV_WData     <= 0;
    get                   <= 0;
  end else begin
    case({cstate,nstate})
      {IDLE,IDLE}: begin
          Function_done <= 1'b0;
          Add_EncBpV_DecMp_RAd  <= 3'hx;
        end
      {IDLE,Pop_0}: begin
          Add_EncBpV_DecMp_RAd  <= 2;
          get                   <= 0;
        end
      {Pop_0,Pop_0}: begin
          get <= 1;
        end 
      {Pop_0,Reduce_0}: begin
          Add_EncBpV_DecMp_RAd <= 3'bxxx;
          P0_PolyReduce_enable <= 1'b1;
          get                  <= 0;
        end
      {Reduce_0,Reduce_0}: begin               
          P0_PolyReduce_enable <= 1'b0;
        end
      {Reduce_0,Push_Dec_0}: begin               
          Reduce_DecMp_outready <= 1'b1;
          Reduce_DecMp_WAd      <= 0;                 
          Reduce_DecMp_WData    <= P0_PolyReduce_oPoly[o_BRAM_Length-1 : 0];  
        end
      {Push_Dec_0,Push_Dec_0}: begin               
          Reduce_DecMp_outready <= 1'b1;
          Reduce_DecMp_WAd      <= Reduce_DecMp_WAd + 1;                 
          Reduce_DecMp_WData    <= P0_PolyReduce_oPoly[(Reduce_DecMp_WAd+2)*o_BRAM_Length -1 -: o_BRAM_Length]; 
        end
      {Push_Dec_0,IDLE}: begin               
          Reduce_DecMp_outready <= 1'b0;
          Function_done         <= 1'b1;
          P0_PolyReduce_enable  <= 1'b0;
          // Add_EncBpV_DecMp_RAd   <= 0;
          Reduce_DecMp_WAd      <= 0;
          Reduce_DecMp_WData    <= 0;          
          Reduce_EncBp_outready <= 1'b0;
          Reduce_EncBp_WAd      <= 0;
          Reduce_EncBp_WData    <= 0;
          Reduce_EncV_outready  <= 1'b0;
          Reduce_EncV_WAd       <= 0;
          Reduce_EncV_WData     <= 0;
          $display("Reduce (OUT) [Mp]: %h", P0_PolyReduce_oPoly);
        end
      {Reduce_0,Push_0_Pop_1}: begin               
          Add_EncBpV_DecMp_RAd  <= 0;
          Reduce_EncV_outready  <= 1'b1;
          Reduce_EncV_WAd       <= 0;                 
          Reduce_EncV_WData     <= P0_PolyReduce_oPoly[o_BRAM_Length-1 : 0];
          // DEBUG:
          reduceV_debug <= P0_PolyReduce_oPoly[255:0];
        end
      {Push_0_Pop_1,Push_0_Pop_1}: begin
          Reduce_EncV_outready  <= 1'b1;
          Reduce_EncV_WAd       <= Reduce_EncV_WAd + 1;                 
          Reduce_EncV_WData     <= P0_PolyReduce_oPoly[(Reduce_EncV_WAd+2)*o_BRAM_Length -1 -: o_BRAM_Length];    
        end                    
      {Push_0_Pop_1,Reduce_1}: begin
          P0_PolyReduce_enable <= 1'b1;
        end
      {Reduce_1,Reduce_1}: begin
          P0_PolyReduce_enable <= 1'b0;         
        end
      {Reduce_1,Push_1_Pop_2}: begin                        
          Add_EncBpV_DecMp_RAd  <= 1;
          Reduce_EncBp_outready <= 1'b1;
          Reduce_EncBp_WAd      <= 0;                 
          Reduce_EncBp_WData    <= P0_PolyReduce_oPoly[o_BRAM_Length-1 : 0];
          // DEBUG: Bp
          reduceBp_debug <= P0_PolyReduce_oPoly[255:0];  
        end     
      {Push_1_Pop_2,Push_1_Pop_2}: begin
          Reduce_EncBp_outready <= 1'b1;
          Reduce_EncBp_WAd      <= Reduce_EncBp_WAd + 1;                 
          Reduce_EncBp_WData    <= P0_PolyReduce_oPoly[(Reduce_EncBp_WAd+2)*o_BRAM_Length -1 -: o_BRAM_Length];    
        end     
      {Push_1_Pop_2,Reduce_2}: begin
          P0_PolyReduce_enable  <= 1'b1;  
        end        
      {Reduce_2,Reduce_2}: begin
          P0_PolyReduce_enable  <= 1'b0;  
        end
      {Reduce_2,Push_2}: begin
          Reduce_EncBp_outready <= 1'b1;
          Reduce_EncBp_WAd      <= 32;                 
          Reduce_EncBp_WData    <= P0_PolyReduce_oPoly[o_BRAM_Length-1 : 0];  
        end 
      {Push_2,Push_2}: begin
          Reduce_EncBp_outready <= 1'b1;
          Reduce_EncBp_WAd      <= Reduce_EncBp_WAd + 1;                 
          Reduce_EncBp_WData    <= P0_PolyReduce_oPoly[(Reduce_EncBp_WAd-32+2)*o_BRAM_Length -1 -: o_BRAM_Length];    
        end
      {Push_2,IDLE}: begin
          Function_done         <= 1'b1;
          Reduce_EncV_outready  <= 1'b0;
          P0_PolyReduce_enable  <= 1'b0;
          Add_EncBpV_DecMp_RAd  <= 0;
          Reduce_DecMp_WAd      <= 0;
          Reduce_DecMp_WData    <= 0;           
          Reduce_EncBp_outready <= 1'b0;
          Reduce_EncBp_WAd      <= 0;
          Reduce_EncBp_WData    <= 0;
          Reduce_EncV_outready  <= 1'b0;
          Reduce_EncV_WAd       <= 0;
          Reduce_EncV_WData     <= 0;
        end
      default: ;
    endcase
  end

State_Reduce__PolyReduce P0(
.clk(clk),    
.reset_n(rst_n),
.enable(P0_PolyReduce_enable),  
.iPoly(Add_EncBpV_DecMp_RData),
.Poly_Reduce_done(P0_PolyReduce_done),
.oPoly(P0_PolyReduce_oPoly)
);            
    
endmodule
