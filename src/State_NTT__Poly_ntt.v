//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2020 09:40:11 PM
// Design Name: 
// Module Name: Poly_ntt
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


module Poly_ntt#(
  parameter KYBER_K = 2/3/4,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329
)(
	input clk,		
	input reset_n,
	input enable,
  input [15 : 0] Coef_RData,
  output reg  [7 : 0] Coef_RAd,
  output reg  [0 : 0] Coef_WEN,
  output reg  [7 : 0] Coef_WAd,
  output reg  [15 : 0] Coef_WData,
  output reg Poly_NTT_done
);

reg  [7 : 0] j;
reg  [6 :0] Zeta_RAd;
wire [15 : 0]Zeta_RData;
reg  [0 : 0] ppstate;
reg  [1 : 0] lastpush;
wire [15 : 0] Montgomery_oData;

reg  [15 : 0] temp_Coef0;
reg  [7 : 0] temp_j0;
reg  [15 : 0] temp_Coef1;
reg  [7 : 0] temp_j1;
reg  [15 : 0] temp_Montgomery0;
reg  [15 : 0] temp_Montgomery1;

reg [4 : 0] state_keeper;

reg [4:0] cstate,nstate;
localparam IDLE		         = 5'd1;
localparam LEN128             = 5'd2;
localparam LEN128_W           = 5'd0;             
localparam LEN64              = 5'd3;
localparam LEN64_W            = 5'd4;
localparam LEN64_L            = 5'd5;
localparam LEN32              = 5'd6;
localparam LEN32_W            = 5'd7;
localparam LEN32_L            = 5'd8;
localparam LEN16              = 5'd9;
localparam LEN16_W            = 5'd10;
localparam LEN16_L            = 5'd11;
localparam LEN8               = 5'd12;
localparam LEN8_W             = 5'd13;
localparam LEN8_L             = 5'd14;
localparam LEN4               = 5'd15;
localparam LEN4_W             = 5'd16;
localparam LEN4_L             = 5'd17;
localparam LEN2               = 5'd18;
localparam LEN2_W             = 5'd19;
localparam LEN2_L             = 5'd20;
localparam Wait               = 5'd31;

function [7:0] mod(input [7:0] a, input [7:0] b);
  mod = a & b;
endfunction

function [15:0] j_mod_len(input [7:0] j, input [7:0] len); 
  j_mod_len = { mod(j, len-1), mod(j-1, len-1) };
endfunction

function [15:0] j_case(input [7:0] a, input [7:0] b);
  j_case = { a, b };
endfunction


always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else         cstate <= nstate;

always @(cstate or enable or j or lastpush)
begin				
	case(cstate)
		IDLE: 	  if(enable)        nstate <= Wait;
				      else              nstate <= IDLE;		
		Wait:                       nstate <= state_keeper + 1;            
		LEN128:   if(j >= 131)      nstate <= Wait;
		          else              nstate <= LEN128_W;
		LEN128_W:                   nstate <= LEN128;
		LEN64:    if(j >= 193)      nstate <= LEN64_L;
		          else              nstate <= LEN64_W;
		LEN64_W:                    nstate <= LEN64;		
		LEN64_L:  if(lastpush == 3) nstate <= Wait;
		          else              nstate <=	LEN64_L;
		LEN32:    if(j >= 225)      nstate <= LEN32_L;
		          else              nstate <= LEN32_W;
		LEN32_W:                    nstate <= LEN32;		
		LEN32_L:  if(lastpush == 3) nstate <= Wait;
		          else              nstate <=	LEN32_L;           	
		LEN16:    if(j >= 241)      nstate <= LEN16_L;
		          else              nstate <= LEN16_W;
		LEN16_W:                    nstate <= LEN16;		
		LEN16_L:  if(lastpush == 3) nstate <= Wait;
		          else              nstate <=	LEN16_L;  
		LEN8:     if(j >= 249)      nstate <= LEN8_L;
		          else              nstate <= LEN8_W;
		LEN8_W:                     nstate <= LEN8;
		LEN8_L:   if(lastpush == 3) nstate <= Wait;
		          else              nstate <=	LEN8_L;
		LEN4:     if(j >= 253)      nstate <= LEN4_L;
		          else              nstate <= LEN4_W;
		LEN4_W:                     nstate <= LEN4;		
		LEN4_L:   if(lastpush == 3) nstate <= Wait;
		          else              nstate <=	LEN4_L; 
		LEN2:     if(j == 255)      nstate <= LEN2_L;
		          else              nstate <= LEN2_W;
		LEN2_W:                     nstate <= LEN2;		
		LEN2_L:   if(lastpush == 3) nstate <= IDLE;
		          else              nstate <=	LEN2_L;    
		Wait:                       nstate <= state_keeper + 1;           		            
		default:                    nstate <= IDLE;
  endcase
end

wire [15:0] j_case64;
wire [7:0] part_a, part_b;
wire [15:0] comp64_a, comp64_b;

assign part_a   = (j&63);
assign part_b   = ((j-1)&63);
assign j_case64 = j_mod_len(j, 64);

assign comp64_a = j_case(0,63);
assign comp64_b = j_case(1,0);

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
	  Poly_NTT_done     <= 1'b0;
	  Coef_WEN          <= 1'b0;
    Zeta_RAd          <= 0;
    ppstate           <= 0;
    lastpush          <= 0;
    temp_Coef0        <= 0;
    temp_j0           <= 0;
    temp_Coef1        <= 0;
    temp_j1           <= 0;
    temp_Montgomery0  <= 0;
    temp_Montgomery1  <= 0;
    j <= 0;
  end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Poly_NTT_done <= 1'b0;
					Zeta_RAd      <= 1;
					ppstate       <= 0;
					Coef_WEN      <= 1'b0;		 
        end  
			{IDLE,Wait}: begin 
			    state_keeper  <= IDLE;                          
          Coef_RAd      <= 128;              
          j             <= 1;
        end		
      {Wait, LEN128}: begin
          Coef_RAd  <= 0;
          ppstate   <= 0;       
        end
      {LEN128,LEN128_W}: begin
          if(j >= 3) begin //r[j] out
            case(ppstate) 
              0: begin
                Coef_WEN          <= 1'b1;
                Coef_WAd          <= temp_j0;
                Coef_WData        <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0  <= Montgomery_oData;               
              end
              1: begin              
                Coef_WAd          <= temp_j1;
                Coef_WData        <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1  <= Montgomery_oData;
              end
            endcase
          end   
          Coef_RAd  <= j + 128;
          j         <= j + 1;           
        end    
      {LEN128_W,LEN128}: begin
          if(j >= 2) begin
            case(ppstate)      
              0: begin
                Coef_WAd    <= temp_j0 + 128;
                Coef_WData  <= temp_Coef0 - temp_Montgomery0;
                temp_Coef0  <= Coef_RData;
                temp_j0     <= j-2;                
              end
              1: begin
                Coef_WAd    <= temp_j1 + 128;
                Coef_WData  <= temp_Coef1 - temp_Montgomery1;
                temp_Coef1  <= Coef_RData;
                temp_j1     <= j-2;  
              end
            endcase
          end
          ppstate   <= ppstate + 1;  
          Coef_RAd  <= j-1;     
        end
      {LEN128, Wait}: begin
          Coef_WEN <= 1'b0;            
          state_keeper <= LEN128;
          Zeta_RAd <= 2;                          
          Coef_RAd <= 64;              
          j <= 1;
        end
      {Wait, LEN64}: begin
          Coef_RAd <= 0;
          ppstate <= 0;       
        end
      {LEN64,LEN64_W}: begin
          if(j >= 3) begin //r[j] out
            case(ppstate) 
              0: begin
                Coef_WEN <= 1'b1;
                Coef_WAd <= temp_j0;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;               
              end
              1: begin              
                Coef_WAd <= temp_j1;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;
              end       
            endcase   
          end else begin
          end          
                      
          if(((j+1)%64 == 0) && (j != 191)) begin
            j <= j + 1 + 64;                 
          end else if((j%64 == 0) && (j != 192)) begin
            Zeta_RAd <= Zeta_RAd + 1;
            j <= j + 1;
          end else begin                
            j <= j + 1;
          end                      
          Coef_RAd <= j + 64;
        end 
      {LEN64_W,LEN64}: begin
          if(j >= 2) begin
            case(ppstate)      
              0: begin
                Coef_WAd <= temp_j0 + 64;
                Coef_WData <= temp_Coef0 - temp_Montgomery0; 
                temp_Coef0 <= Coef_RData;
                
                case(j_mod_len(j, 64)) // {(j%64),((j-1)%64)}
                  j_case(0,63): begin // {0,63}
                    temp_j0 <= j-64-2;
                  end
                  j_case(1,0): begin // {1,0}
                    temp_j0 <= j-64-2;
                  end
                  default: begin
                    temp_j0 <= j-2;
                  end
                endcase
              end
              1: begin
                Coef_WAd <= temp_j1 + 64;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;                 
                temp_Coef1 <= Coef_RData;
                
                case(j_mod_len(j, 64)) // {(j%64),((j-1)%64)}
                  j_case(0,63): begin // {0,63}
                    temp_j1 <= j-64-2;
                  end
                  j_case(1,0): begin // {1,0}
                    temp_j1 <= j-64-2;
                  end
                  default: begin
                    temp_j1 <= j-2;
                  end
                endcase
              end
            endcase
          end else begin
          end

          if((j%64 == 0) && (j != 192)) begin
              Coef_RAd <= j - 1 -64;
          end else begin                
            Coef_RAd <= j-1;
          end                                     
          ppstate <= ppstate + 1;  
        end
      {LEN64,LEN64_L}: begin
          lastpush <= 0;
          Coef_WAd <=  temp_j0 + 64;
          Coef_WData <= temp_Coef0 + Montgomery_oData;
          temp_Montgomery0 <= Montgomery_oData;             
        end
      {LEN64_L,LEN64_L}: begin
          case(lastpush)
            0: begin
              Coef_WAd <=  temp_j0 + 128;
              Coef_WData <= temp_Coef0 - temp_Montgomery0;                
            end
            1: begin
              Coef_WAd <=  temp_j1 + 64;
              Coef_WData <= temp_Coef1 + Montgomery_oData;
              temp_Montgomery1 <= Montgomery_oData;                          
            end
            2: begin
              Coef_WAd <=  temp_j1 + 128;
              Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
            end
            default:;  
          endcase  
          lastpush <= lastpush + 1;            
        end
      {LEN64_L, Wait}: begin  
          Coef_WEN <= 1'b0;            
          state_keeper <= LEN64_L;
          Zeta_RAd <= 4;                          
          Coef_RAd <= 32;              
          j <= 1;
        end
      {Wait, LEN32}: begin
          Coef_RAd <= 0;
          ppstate <= 0;       
        end
      {LEN32,LEN32_W}: begin
          if(j >= 3) begin //r[j] out
            case(ppstate) 
              0: begin
                Coef_WEN <= 1'b1;
                Coef_WAd <= temp_j0;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;               
              end
              1: begin              
                Coef_WAd <= temp_j1;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;
              end
            endcase   
          end else begin
          end          
                
          if(((j+1)%32 == 0) && (j != 223)) begin
            j <= j + 1 + 32;                 
          end else if((j%32 == 0) && (j != 224)) begin
            Zeta_RAd <= Zeta_RAd + 1;
            j <= j + 1;
          end else begin                
            j <= j + 1;
          end

          Coef_RAd <= j + 32;
        end 


        
      {LEN32_W,LEN32}: begin
          if(j >= 2) begin
            case(ppstate)      
              0: begin
                Coef_WAd <= temp_j0 + 32;
                Coef_WData <= temp_Coef0 - temp_Montgomery0; 
                temp_Coef0 <= Coef_RData;
                
                case(j_mod_len(j, 32)) // {(j%32),((j-1)%32)}
                  j_case(0,31): begin
                    temp_j0 <= j-32-2;
                  end
                  j_case(1,0): begin
                    temp_j0 <= j-32-2;
                  end                 
                  default: begin
                    temp_j0 <= j-2;
                  end
                endcase
              end
              1: begin
                Coef_WAd <= temp_j1 + 32;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;
                temp_Coef1 <= Coef_RData;
                
                case(j_mod_len(j, 32)) // {(j%32),((j-1)%32)}
                  j_case(0,31): begin
                    temp_j1 <= j-32-2;
                  end
                  j_case(1,0): begin
                    temp_j1 <= j-32-2;
                  end                 
                  default:begin
                    temp_j1 <= j-2;
                  end
                endcase                                                   
              end
            endcase
          end else begin
          end

          if((j%32 == 0) && (j != 224)) begin
            Coef_RAd <= j - 1 -32;
          end else begin                
            Coef_RAd <= j-1;
          end
          ppstate <= ppstate + 1;
        end



      {LEN32,LEN32_L}: begin
          lastpush <= 0;
          Coef_WAd <=  temp_j0 + 32;
          Coef_WData <= temp_Coef0 + Montgomery_oData;
          temp_Montgomery0 <= Montgomery_oData;             
        end
      {LEN32_L,LEN32_L}: begin
          case(lastpush)
            0: begin
              Coef_WAd <=  temp_j0 + 64;
              Coef_WData <= temp_Coef0 - temp_Montgomery0;                
            end
            1: begin
              Coef_WAd <=  temp_j1 + 32;
              Coef_WData <= temp_Coef1 + Montgomery_oData;
              temp_Montgomery1 <= Montgomery_oData;                          
            end
            2: begin
              Coef_WAd <=  temp_j1 + 64;
              Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
            end
            default:;  
          endcase  
          lastpush <= lastpush + 1;            
        end
      {LEN32_L, Wait}: begin  
          Coef_WEN <= 1'b0;            
          state_keeper <= LEN32_L;
          Zeta_RAd <= Zeta_RAd + 1;                          
          Coef_RAd <= 16;              
          j <= 1;
        end
      {Wait, LEN16}: begin
          Coef_RAd <= 0;
          ppstate <= 0;       
        end
      {LEN16,LEN16_W}: begin
          if(j >= 3) begin //r[j] out
            case(ppstate) 
              0: begin
                Coef_WEN <= 1'b1;
                Coef_WAd <= temp_j0;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;               
              end
              1: begin              
                Coef_WAd <= temp_j1;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;
              end       
            endcase   
          end else begin
          end
                
          if(((j+1)%16 == 0) && (j != 239)) begin
            j <= j + 1 + 16;
          end else if((j%16 == 0) && (j != 240)) begin
            Zeta_RAd <= Zeta_RAd + 1;
            j <= j + 1;
          end else begin
            j <= j + 1;
          end
          Coef_RAd <= j + 16;
        end
      {LEN16_W,LEN16}: begin
          if(j >= 2) begin
            case(ppstate)      
              0: begin
                Coef_WAd <= temp_j0 + 16;
                Coef_WData <= temp_Coef0 - temp_Montgomery0;
                temp_Coef0 <= Coef_RData;
                
                case(j_mod_len(j, 16))
                  j_case(0,15): begin
                    temp_j0 <= j-16-2;
                  end
                  j_case(1,0): begin
                    temp_j0 <= j-16-2;
                  end                 
                  default: begin
                    temp_j0 <= j-2;
                  end
                endcase
              end
              1: begin
                Coef_WAd <= temp_j1 + 16;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;
                temp_Coef1 <= Coef_RData;
            
                case(j_mod_len(j, 16))
                  j_case(0,15): begin
                    temp_j1 <= j-16-2;
                  end
                  j_case(1,0): begin
                    temp_j1 <= j-16-2;
                  end
                  default:begin
                    temp_j1 <= j-2;
                  end
                endcase                                                   
              end
            endcase
          end else begin
          end

          if((j%16 == 0) && (j != 240)) begin
            Coef_RAd <= j - 1 -16;
          end else begin                
            Coef_RAd <= j-1;
          end
          ppstate <= ppstate + 1;
        end
              {LEN16,LEN16_L}: begin
                lastpush <= 0;
                Coef_WAd <=  temp_j0 + 16;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;             
                                end
               {LEN16_L,LEN16_L}: begin
                case(lastpush)
                0:begin
                Coef_WAd <=  temp_j0 + 32;
                Coef_WData <= temp_Coef0 - temp_Montgomery0;                
                  end
                1:begin
                Coef_WAd <=  temp_j1 + 16;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;                          
                  end
                2:begin
                Coef_WAd <=  temp_j1 + 32;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
                  end
                default:;  
                endcase  
                lastpush <= lastpush + 1;            
                                end
            {LEN16_L, Wait}: begin  
               Coef_WEN <= 1'b0;            
               state_keeper <= LEN16_L;
               Zeta_RAd <= Zeta_RAd + 1;                          
               Coef_RAd <= 8;              
               j <= 1;
                                end
            {Wait, LEN8}: begin
               Coef_RAd <= 0;
               ppstate <= 0;       
                            end
            {LEN8,LEN8_W}: begin
                if(j >= 3) begin //r[j] out
                case(ppstate) 
                0: begin
                 Coef_WEN <= 1'b1;
                 Coef_WAd <= temp_j0;
                 Coef_WData <= temp_Coef0 + Montgomery_oData;
                 temp_Montgomery0 <= Montgomery_oData;               
                   end
                1: begin              
                 Coef_WAd <= temp_j1;
                 Coef_WData <= temp_Coef1 + Montgomery_oData;
                 temp_Montgomery1 <= Montgomery_oData;
                   end       
                endcase   
                          end
                else begin
                     end          
                      
                if(((j+1)%8 == 0) && (j != 247)) begin
                   j <= j + 1 + 8;                 
                                  end
                else if((j%8 == 0) && (j != 248)) begin
                   Zeta_RAd <= Zeta_RAd + 1;
                   j <= j + 1;
                                  end                     
                 else begin                
                   j <= j + 1;
                      end                      
                Coef_RAd <= j + 8;
         
                             end 
            {LEN8_W,LEN8}: begin
                if(j >= 2) begin
                case(ppstate)      
                 0: begin
                  Coef_WAd <= temp_j0 + 8;
                  Coef_WData <= temp_Coef0 - temp_Montgomery0; 
                                                                    
                 temp_Coef0 <= Coef_RData;
                 
                 case(j_mod_len(j, 8))
                   j_case(0,7): begin
                   temp_j0 <= j-8-2;
                      end
                   j_case(1,0): begin
                   temp_j0 <= j-8-2;
                          end                 
                    default:begin
                    temp_j0 <= j-2;
                            end
                 endcase
                                 
                          end
                1: begin
                  Coef_WAd <= temp_j1 + 8;
                  Coef_WData <= temp_Coef1 - temp_Montgomery1;                 
                
                  temp_Coef1 <= Coef_RData;
                  
                   case(j_mod_len(j, 8))
                   j_case(0,7): begin
                   temp_j1 <= j-8-2;
                           end
                   j_case(1,0): begin
                   temp_j1 <= j-8-2;
                           end
                    default:begin
                    temp_j1 <= j-2;
                            end
                 endcase                                                   
                   end
                endcase
                          end
                else begin
                     end                            
 
                if((j%8 == 0) && (j != 248)) begin
                   Coef_RAd <= j - 1 -8;
                                  end      
                 else begin                
                  Coef_RAd <= j-1;
                       end                                     
                ppstate <= ppstate + 1;  
                                    
                           end
              {LEN8,LEN8_L}: begin
                lastpush <= 0;
                Coef_WAd <=  temp_j0 + 8;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;             
                                end
               {LEN8_L,LEN8_L}: begin
                case(lastpush)
                0:begin
                Coef_WAd <=  temp_j0 + 16;
                Coef_WData <= temp_Coef0 - temp_Montgomery0;                
                  end
                1:begin
                Coef_WAd <=  temp_j1 + 8;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;                          
                  end
                2:begin
                Coef_WAd <=  temp_j1 + 16;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
                  end
                default:;  
                endcase  
                lastpush <= lastpush + 1;            
                                end
            {LEN8_L, Wait}: begin  
               Coef_WEN <= 1'b0;            
               state_keeper <= LEN8_L;
               Zeta_RAd <= Zeta_RAd + 1;                          
               Coef_RAd <= 4;              
               j <= 1;
                                end
            {Wait, LEN4}: begin
               Coef_RAd <= 0;
               ppstate <= 0;       
                            end
             {LEN4,LEN4_W}: begin
                if(j >= 3) begin //r[j] out
                case(ppstate) 
                0: begin
                 Coef_WEN <= 1'b1;
                 Coef_WAd <= temp_j0;
                 Coef_WData <= temp_Coef0 + Montgomery_oData;
                 temp_Montgomery0 <= Montgomery_oData;               
                   end
                1: begin              
                 Coef_WAd <= temp_j1;
                 Coef_WData <= temp_Coef1 + Montgomery_oData;
                 temp_Montgomery1 <= Montgomery_oData;
                   end       
                endcase   
                          end
                else begin
                     end          
                      
                if(((j+1)%4 == 0) && (j != 251)) begin
                   j <= j + 1 + 4;                 
                                  end
                else if((j%4 == 0) && (j != 252)) begin
                   Zeta_RAd <= Zeta_RAd + 1;
                   j <= j + 1;
                                  end                     
                 else begin                
                   j <= j + 1;
                      end                      
                Coef_RAd <= j + 4;
         
                             end 
            {LEN4_W,LEN4}: begin
                if(j >= 2) begin
                case(ppstate)      
                 0: begin
                  Coef_WAd <= temp_j0 + 4;
                  Coef_WData <= temp_Coef0 - temp_Montgomery0; 
                                                                    
                 temp_Coef0 <= Coef_RData;
                 
                 case(j_mod_len(j, 4))
                   j_case(0,3): begin
                    temp_j0 <= j-4-2;
                  end
                   j_case(1,0): begin
                   temp_j0 <= j-4-2;
                          end                 
                    default: begin
                    temp_j0 <= j-2;
                            end
                 endcase
                                 
                          end
                1: begin
                  Coef_WAd <= temp_j1 + 4;
                  Coef_WData <= temp_Coef1 - temp_Montgomery1;                 
                
                  temp_Coef1 <= Coef_RData;
                  
                   case(j_mod_len(j, 4))
                   j_case(0,3): begin
                   temp_j1 <= j-4-2;
                           end
                   j_case(1,0): begin
                   temp_j1 <= j-4-2;
                           end                 
                    default: begin
                    temp_j1 <= j-2;
                            end
                 endcase                                                   
                   end
                endcase
                          end
                else begin
                     end                            
 
                if((j%4 == 0) && (j != 252)) begin
                   Coef_RAd <= j - 1 -4;
                                  end      
                 else begin                
                  Coef_RAd <= j-1;
                       end                                     
                ppstate <= ppstate + 1;  
                                    
                             end
               {LEN4,LEN4_L}: begin
                lastpush <= 0;
                Coef_WAd <=  temp_j0 + 4;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;             
                                end
               {LEN4_L,LEN4_L}: begin
                case(lastpush)
                0:begin
                Coef_WAd <=  temp_j0 + 8;
                Coef_WData <= temp_Coef0 - temp_Montgomery0;                
                  end
                1:begin
                Coef_WAd <=  temp_j1 + 4;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;                          
                  end
                2:begin
                Coef_WAd <=  temp_j1 + 8;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
                  end
                default:;  
                endcase  
                lastpush <= lastpush + 1;            
                                end
             {LEN4_L, Wait}: begin  
               Coef_WEN <= 1'b0;            
               state_keeper <= LEN4_L;
               Zeta_RAd <= Zeta_RAd + 1;                          
               Coef_RAd <= 2;              
               j <= 1;
                                end
             {Wait, LEN2}: begin
               Coef_RAd <= 0;
               ppstate <= 0;       
                            end
             {LEN2,LEN2_W}: begin
                if(j >= 3) begin //r[j] out
                case(ppstate) 
                0: begin
                 Coef_WEN <= 1'b1;
                 Coef_WAd <= temp_j0;
                 Coef_WData <= temp_Coef0 + Montgomery_oData;
                 temp_Montgomery0 <= Montgomery_oData;               
                   end
                1: begin              
                 Coef_WAd <= temp_j1;
                 Coef_WData <= temp_Coef1 + Montgomery_oData;
                 temp_Montgomery1 <= Montgomery_oData;
                   end       
                endcase   
                          end
                else begin
                     end          
                      
                if(((j+1)%2 == 0) && (j != 253)) begin
                   j <= j + 1 + 2;                 
                                  end
                else if((j%2 == 0) && (j != 254)) begin
                   Zeta_RAd <= Zeta_RAd + 1;
                   j <= j + 1;
                                  end                     
                 else begin                
                   j <= j + 1;
                      end                      
                Coef_RAd <= j + 2;
         
                             end 
            {LEN2_W,LEN2}: begin
                if(j >= 2) begin
                case(ppstate)      
                 0: begin
                  Coef_WAd <= temp_j0 + 2;
                  Coef_WData <= temp_Coef0 - temp_Montgomery0; 
                                                                    
                 temp_Coef0 <= Coef_RData;
                 
                 case(j_mod_len(j, 2))
                   j_case(0,1): begin
                   temp_j0 <= j-2-2;
                      end
                   j_case(1,0): begin
                   temp_j0 <= j-2-2;
                          end                 
                    default:begin
                    temp_j0 <= j-2;
                            end
                 endcase
                                 
                          end
                1: begin
                  Coef_WAd <= temp_j1 + 2;
                  Coef_WData <= temp_Coef1 - temp_Montgomery1;                 
                
                  temp_Coef1 <= Coef_RData;
                  
                   case(j_mod_len(j, 2))
                   j_case(0,1): begin
                   temp_j1 <= j-2-2;
                           end
                   j_case(1,0): begin
                   temp_j1 <= j-2-2;
                           end                 
                    default:begin
                    temp_j1 <= j-2;
                            end
                 endcase                                                   
                   end
                endcase
                          end
                else begin
                     end                            
 
                if((j%2 == 0) && (j != 254)) begin
                   Coef_RAd <= j - 1 -2;
                                  end      
                 else begin                
                  Coef_RAd <= j-1;
                       end                                     
                ppstate <= ppstate + 1;  
                                    
                             end
               {LEN2,LEN2_L}: begin
                lastpush <= 0;
                Coef_WAd <=  temp_j0 + 2;
                Coef_WData <= temp_Coef0 + Montgomery_oData;
                temp_Montgomery0 <= Montgomery_oData;             
                                end
               {LEN2_L,LEN2_L}: begin
                case(lastpush)
                0:begin
                Coef_WAd <=  temp_j0 + 4;
                Coef_WData <= temp_Coef0 - temp_Montgomery0;                
                  end
                1:begin
                Coef_WAd <=  temp_j1 + 2;
                Coef_WData <= temp_Coef1 + Montgomery_oData;
                temp_Montgomery1 <= Montgomery_oData;                          
                  end
                2:begin
                Coef_WAd <=  temp_j1 + 4;
                Coef_WData <= temp_Coef1 - temp_Montgomery1;                                   
                  end
                default:;  
                endcase  
                lastpush <= lastpush + 1;            
                                end                           
              {LEN2_L, IDLE}: begin              
                  Poly_NTT_done <= 1;
                  lastpush <= 0;
                  temp_Coef0 <= 0;
                  temp_j0 <= 0;
                  temp_Coef1 <= 0;
                  temp_j1 <= 0;
                  temp_Montgomery0 <= 0;
                  temp_Montgomery1 <= 0;
                  j <= 0;
                  Coef_RAd <= 0;
                  Coef_WEN <= 1'b0;
                  Coef_WAd <= 0;
                  Coef_WData <= 0;
                               end                                   
			default: ;
			endcase
		end


 
Zeta M0(
.clka(clk),
.addra(Zeta_RAd),
.douta(Zeta_RData)
);    

   
State_polyvec_ntt__NTT__MontgomeryR P0(
.clk(clk),			
.reset_n(reset_n),
.iCoeffs_a(Zeta_RData),
.iCoeffs_b(Coef_RData),
.oCoeffs(Montgomery_oData)
);					
		
endmodule

