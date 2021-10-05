//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 02:40:24 PM
// Design Name: 
// Module Name: State_ntt_BRAM_MUX
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


module State_ntt_BRAM_MUX(
      input [2 : 0] cstate,
      input [0 : 0] P0_WEN,
      input [7 : 0] P0_WAd,
      input [15 : 0] P0_Wdata,      
      input [7 : 0]  P0_RAd,
      input [0 : 0] P1_WEN,
      input [7 : 0] P1_WAd,
      input [15 : 0] P1_Wdata,      
      input [7 : 0]  P1_RAd,
      input [0 : 0] M0_WEN_Out, 
      input [7 : 0] M0_WAd_Out,  
      input [15 : 0] M0_WData_Out, 
      input [7 : 0] M0_RAd_Out, 
      output reg [0 : 0] M0_WEN,
      output reg [7 : 0] M0_WAd,
      output reg [15 : 0] M0_WData,
      output reg [7 : 0] M0_RAd
);


parameter IDLE		        = 3'd0;
parameter Pop_0             = 3'd1;
parameter NTT      		    = 3'd2;
parameter Reduce            = 3'd3;
parameter Push_0            = 3'd4;
parameter Pop_1             = 3'd5;
parameter Push_1            = 3'd6; 
    
always@(*)    
begin
     case(cstate)
      NTT: begin
        M0_WEN <= P0_WEN;
        M0_WAd <= P0_WAd;
        M0_WData <= P0_Wdata;
        M0_RAd <= P0_RAd;
           end
      Reduce: begin
        M0_WEN <= P1_WEN;
        M0_WAd <= P1_WAd;
        M0_WData <= P1_Wdata;
        M0_RAd <= P1_RAd;
              end        
     default: begin
        M0_WEN <= M0_WEN_Out;
        M0_WAd <= M0_WAd_Out;
        M0_WData <= M0_WData_Out;
        M0_RAd <= M0_RAd_Out;        
              end
     endcase
end         
    
    
endmodule
