//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2020 04:42:48 PM
// Design Name: 
// Module Name: BRAM_MUX
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


module BRAM_MUX(
  input [3 : 0] cstate,
  input P2_AtG_WEN,
  input [7 : 0] P2_AtG_WAd,
  input [127 : 0] P2_AtG_WData,      
  input P4_M2_WEN,
  input [7 : 0] P4_M2_WAd,
  input [127 : 0] P4_M2_WData,
  input [2 : 0] P4_M2_RAd,
  input [2 : 0] P5_M2_RAd,
//   input P6_M2_WEN,
//   input [7 : 0] P6_M2_WAd,
//   input [127 : 0] P6_M2_WData,
  input [2 : 0] P7_M2_RAd,       
  output reg M2_WEN,
  output reg [7 : 0] M2_WAd,
  output reg [127 : 0] M2_WData,
  output reg [2 : 0] M2_RAd
);

parameter IDLE    = 4'd0;
parameter Unpack  = 4'd1;
parameter Hash    = 4'd2;
parameter NTT     = 4'd3;
parameter PAcc    = 4'd4;
parameter INTT    = 4'd5;
parameter Add     = 4'd6;
parameter Reduce  = 4'd7;
parameter Pack    = 4'd8;

    
always@(*)
begin
  case(cstate)
    Hash: begin //only write
        M2_WEN <= P2_AtG_WEN;
        M2_WAd <= P2_AtG_WAd;
        M2_WData <= P2_AtG_WData;
        M2_RAd <= 3'bxxx;
      end
    PAcc: begin // read first, write then
        M2_WEN <= P4_M2_WEN;
        M2_WAd <= P4_M2_WAd;
        M2_WData <= P4_M2_WData;
        M2_RAd <= P4_M2_RAd;
      end
    INTT: begin // only read
        M2_WEN <= 1'b0;
        M2_WAd <= 0; 
        M2_WData <= 0;
        M2_RAd <= P5_M2_RAd;    
      end
    Add: begin // do nothing
        M2_WEN    <= 1'b0;
        M2_WAd    <= 0;
        M2_WData  <= 0;
        M2_RAd    <= 3'bxxx;
      end
    Reduce: begin // do nothing
        M2_WEN <= 1'b0;
        M2_WAd <= 0; 
        M2_WData <= 0;
        M2_RAd <= 3'bxxx;  
      end   
    default: begin
        M2_WEN <= 1'b0;
        M2_WAd <= 0; 
        M2_WData <= 0;
        M2_RAd <= 3'bxxx;     
      end
  endcase
end 
    
endmodule
