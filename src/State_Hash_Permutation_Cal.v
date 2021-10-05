//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Hash_Permutation_Cal
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module State_Hash_Permutation_Cal #(
  parameter Round0_Constants1 = 64'h0000000000000001,
  parameter Round0_Constants2 = 64'h0000000000008082,
  parameter Round1_Constants1 = 64'h800000000000808a,
  parameter Round1_Constants2 = 64'h8000000080008000,
  parameter Round2_Constants1 = 64'h000000000000808b,
  parameter Round2_Constants2 = 64'h0000000080000001,
  parameter Round3_Constants1 = 64'h8000000080008081,
  parameter Round3_Constants2 = 64'h8000000000008009,
  parameter Round4_Constants1 = 64'h000000000000008a,
  parameter Round4_Constants2 = 64'h0000000000000088,
  parameter Round5_Constants1 = 64'h0000000080008009,
  parameter Round5_Constants2 = 64'h000000008000000a,
  parameter Round6_Constants1 = 64'h000000008000808b,
  parameter Round6_Constants2 = 64'h800000000000008b,
  parameter Round7_Constants1 = 64'h8000000000008089,
  parameter Round7_Constants2 = 64'h8000000000008003,
  parameter Round8_Constants1 = 64'h8000000000008002,
  parameter Round8_Constants2 = 64'h8000000000000080,
  parameter Round9_Constants1 = 64'h000000000000800a,
  parameter Round9_Constants2 = 64'h800000008000000a,
  parameter Round10_Constants1 = 64'h8000000080008081,
  parameter Round10_Constants2 = 64'h8000000000008080,
  parameter Round11_Constants1 = 64'h0000000080000001,
  parameter Round11_Constants2 = 64'h8000000080008008
  
)(
input  clk,
input  reset_n,
input  enable,
input  [1599:0]  iState,
output reg    out_ready,
output reg [1599:0] oState
);
      
reg        [1599:0] P0_round_in;
reg        [63:0]   P0_rc1, P0_rc2;
wire       [1599:0] P0_round_out;

reg  cal_state;
reg  [3:0] round_counter;

    always@(posedge clk or negedge reset_n)
     if(~reset_n) begin
          cal_state     <= 0;
          round_counter <= 0;
          out_ready   <= 0;
          P0_round_in   <= 0;
          oState <= 0;
                   end 
     else if(enable && (!cal_state)) begin         
                cal_state <= 1;
                out_ready <= 0;
                round_counter <= 0;
                                     end    
     else  if(round_counter == 13) begin
               out_ready <= 0;
               round_counter <= 0;
                                   end
     else  if(round_counter == 12) begin
            oState <= P0_round_out;
            out_ready <= 1;
            cal_state <= 0;
            round_counter <= round_counter+1;
                                    end
                                   
      else if(round_counter == 11) begin
                    P0_rc1 <= Round11_Constants1;
                    P0_rc2 <= Round11_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                    end                                
      else if(round_counter == 10) begin
                    P0_rc1 <= Round10_Constants1;
                    P0_rc2 <= Round10_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end                               
      else if(round_counter == 9) begin
                    P0_rc1 <= Round9_Constants1;
                    P0_rc2 <= Round9_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end                                
      else if(round_counter == 8) begin
                    P0_rc1 <= Round8_Constants1;
                    P0_rc2 <= Round8_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                  end                                
      else if(round_counter == 7) begin
                    P0_rc1 <= Round7_Constants1;
                    P0_rc2 <= Round7_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                  end                              
      else if(round_counter == 6) begin
                    P0_rc1 <= Round6_Constants1;
                    P0_rc2 <= Round6_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end                               
      else if(round_counter == 5) begin
                    P0_rc1 <= Round5_Constants1;
                    P0_rc2 <= Round5_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end                                  
      else if(round_counter == 4) begin
                    P0_rc1 <= Round4_Constants1;
                    P0_rc2 <= Round4_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end 
      else if(round_counter == 3) begin
                    P0_rc1 <= Round3_Constants1;
                    P0_rc2 <= Round3_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end 
      else if(round_counter == 2) begin
                    P0_rc1 <= Round2_Constants1;
                    P0_rc2 <= Round2_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end     
      else if(round_counter == 1) begin
                    P0_rc1 <= Round1_Constants1;
                    P0_rc2 <= Round1_Constants2;
                    P0_round_in <= P0_round_out;
                    round_counter <= round_counter+1;
                                          end                                                
      else if(cal_state) begin
                    P0_rc1 <= Round0_Constants1;
                    P0_rc2 <= Round0_Constants2;
                    P0_round_in <= iState;
                    round_counter <= round_counter+1;
                         end                                 
                                        
                                      
State_Hash__Permutation__Round P0(
.in(P0_round_in),
.round_const_1(P0_rc1),
.round_const_2(P0_rc2),
.out(P0_round_out)
);

endmodule
