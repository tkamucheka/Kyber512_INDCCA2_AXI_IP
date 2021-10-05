//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 11:46:04 AM
// Design Name: 
// Module Name: State_NTT_PolyReduce
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


module State_NTT_PolyReduce#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329
)(
	input 								clk,		
	input 								reset_n,
	input 								enable,
  input 			[15 : 0] 	Coef_RData,
  output reg  [7 : 0] 	Coef_RAd,
  output reg  [0 : 0]	 	Coef_WEN,
  output reg  [7 : 0] 	Coef_WAd,
  output reg  [15 : 0] 	Coef_WData,
  output reg 						Poly_Reduce_done
);
     
wire [11 : 0] BarrettReduceData;    

reg [8:0] a, a_l;    

reg [1 : 0] cstate,nstate;
localparam IDLE = 2'd0;
localparam Wait = 2'd1;
localparam Do   = 2'd2;
   
always@(posedge clk or negedge reset_n)
	if(!reset_n) 	cstate <= IDLE;
 	else 					cstate <= nstate;

// BUG: (PDRC-153) nstate, gated clock pin sourced by a combinational
//		pin. For SLICE registers, for example, use the CE pin to
// 		control the loading of data.
always@(cstate or enable or a) begin
	case(cstate)
		IDLE: if(enable) 		nstate <= Wait;
					else 					nstate <= IDLE;
		Wait: 							nstate <= Do;
		Do:   if(a == 260) 	nstate <= IDLE;
					else 					nstate <= Do;  
		default:;
	endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
		Poly_Reduce_done 	<= 1'b0;
		a 								<= 0;
		a_l 							<= 0;
		Coef_WEN 					<= 1'b0;
		Coef_WAd 					<= 0;
		Coef_WData 				<= 0;                    
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Poly_Reduce_done <= 1'b0;
					Coef_RAd <= 8'hxx; 
				end			
			{IDLE,Wait}: begin
					a 				<= 0;
					Coef_RAd 	<= 0;
				end         
			{Wait,Do}: begin
					Coef_RAd 	<= 1;
				end
			{Do,Do}: begin
					a 				<= a + 1;
					Coef_RAd 	<= Coef_RAd + 1;
					
					if(a >= 4) begin
						Coef_WEN 		<= 1'b1;
						Coef_WAd 		<= a - 4;
						Coef_WData 	<= BarrettReduceData;
					end        
				end 				       
			{Do,IDLE}: begin                  
					Poly_Reduce_done 	<= 1'b1;
					a 								<= 0;
					Coef_RAd 					<= 0;
					Coef_WEN 					<= 1'b0;
					Coef_WAd 					<= 0;
					Coef_WData 				<= 0;
				end 					       
 			default: ;
		endcase
	end
    
State_NTT_PolyReduce_BarrettR P0 (
	.clk(clk),
	.reset_n(reset_n),
	.iCoeffs(Coef_RData),
	.oCoeffs(BarrettReduceData)
);

endmodule
