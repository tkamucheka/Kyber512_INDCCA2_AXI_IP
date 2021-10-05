//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Poly_frommsg
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module State_Poly_frommsg#(
   parameter KYBER_Q = 3329,
   parameter KYBER_SYMBYTES = 32,
   parameter KYBER_N = 256,
   parameter Byte_bits = 8,
   parameter Length = 12,
   parameter Msg_size = KYBER_SYMBYTES * Byte_bits,
   parameter And_Sum = (KYBER_Q+1)/2
)(
   input clk,
   input rst_n,
   input enable,
   input  [Msg_size-1 : 0]   iMsg_byte_array,
   output reg out_ready,              
   output reg Function_Done,          
   output reg [7 : 0] Poly_Ad,         
   output reg [Length-1 : 0] Poly_Data
   // DEBUG:
  //  output reg [191:0] msgpoly_debug
);

localparam IDLE = 2'd0;
localparam SEND = 2'd2;

reg [1:0] cstate, nstate;
reg [3:0] shift;

// DEBUG: reg [255:0] index;

always @(posedge clk)
	if(!rst_n)  cstate <= IDLE;
	else        cstate <= nstate;

	
always @(cstate or enable or Poly_Ad)
begin				
	case(cstate)
		IDLE: if(enable)          nstate = SEND;
				  else                nstate = IDLE;
		SEND: if(Poly_Ad == 255)  nstate = IDLE;
	        else                nstate = SEND;
		default:                  nstate = IDLE;
		endcase
end

// always @(posedge clk or negedge rst_n)										
// 	if(!rst_n) begin
//       Function_Done <= 1'b0;	      
//       out_ready     <= 1'b0;
//       Poly_Ad       <= 0;
//       Poly_Data     <= 0;
//       shift         <= 7;
//       // DEBUG: index      <= 0;
//     end
// 	else begin
  always @(posedge clk) begin
		case({cstate,nstate})
      {IDLE,IDLE}: begin
        Function_Done <= 1'b0;	      
        out_ready     <= 1'b0;
      end
      {IDLE,SEND}: begin
          out_ready     <= 1'b1;
          Poly_Ad       <= 0;
          shift         <= 7;
          Poly_Data  <= (iMsg_byte_array [7:0] & 8'h01) ? And_Sum : 0;
        end
      {SEND,SEND}: begin
          out_ready     <= 1'b1;
          Poly_Ad       <= Poly_Ad + 1;
          // BUG: Modulo will not synthesize
          // Poly_Data  <= ((iMsg_byte_array[(((Poly_Ad+1)/8)*8+7) -: 8] >>> ((Poly_Ad+1) % 8)) & 8'h01) ? And_Sum : 0;
          Poly_Data  <= ((iMsg_byte_array[(((Poly_Ad+1)/8)*8+7) -: 8] >>> ((Poly_Ad+1) & 7)) & 8'h01) ? And_Sum : 0;
          // DEBUG:
          // if (Poly_Ad < 16)
          //   msgpoly_debug[191-(Poly_Ad*12) -: 12] <= Poly_Data;
        end
      {SEND,IDLE}: begin
          Function_Done <= 1'b1;	      
          out_ready     <= 1'b0;
          Poly_Ad       <= 0;
          Poly_Data     <= 0;
        end			  	  				  
			default: ;
    endcase
  end

// always @(posedge clk) begin
//   if (!Function_Done && Poly_Ad < 16)
//     msgpoly_debug[191-(Poly_Ad*12) -: 12] <= Poly_Data;
// end

endmodule
