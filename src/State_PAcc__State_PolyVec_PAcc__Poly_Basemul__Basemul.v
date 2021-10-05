//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2019 02:51:16 PM
// Design Name: 
// Module Name: State_PolyVec_PAcc__Poly_Basemul__Basemul
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


module State_PAcc__Poly_PAcc__Poly_Basemul__Basemul#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Temp_Poly_Width = 16,
  parameter Setp_i_Width = 16,
  parameter Setp_o_Width = 16,
  parameter i_Coeffs_Width = 16,
  parameter i_Zeta_Width = 16,
  parameter o_Coeffs_Width = 16
)(
	input clk,		
	input reset_n,
	input enable,	
    input [i_Coeffs_Width-1 : 0] iCoeffs_a0,
    input [i_Coeffs_Width-1 : 0] iCoeffs_b0,
    input [i_Coeffs_Width-1 : 0] iCoeffs_a1,
    input [i_Coeffs_Width-1 : 0] iCoeffs_b1,
    input [i_Zeta_Width-1 : 0] i_Zeta,    
    output reg Basemul_done,
    output reg [o_Coeffs_Width -1 : 0]  oPoly_r0,
    output reg [o_Coeffs_Width -1 : 0]  oPoly_r1
);

reg  P1_MontgomeryR_enable;
reg  P2_MontgomeryR_enable;
reg  P3_MontgomeryR_enable;
reg  [Setp_i_Width-1 : 0] P1_iCoeffs_a;
reg  [Setp_i_Width-1 : 0] P1_iCoeffs_b;
reg  [Setp_i_Width-1 : 0] P2_iCoeffs_a;
reg  [Setp_i_Width-1 : 0] P2_iCoeffs_b;
reg  [Setp_i_Width-1 : 0] P3_iCoeffs_a;
reg  [Setp_i_Width-1 : 0] P3_iCoeffs_b;
wire P1_MontgomeryR_done;
wire P2_MontgomeryR_done;
wire P3_MontgomeryR_done;
wire [Setp_o_Width-1 : 0] P1_oCoeffs;
wire [Setp_o_Width-1 : 0] P2_oCoeffs;
wire [Setp_o_Width-1 : 0] P3_oCoeffs;

reg  [Temp_Poly_Width-1 : 0] temp_poly_r0_0;
reg  [Temp_Poly_Width-1 : 0] temp_poly_r0_1;
reg  [Temp_Poly_Width-1 : 0] temp_poly_r1;

reg [1:0] cstate,nstate;
localparam IDLE		         = 2'd0;
localparam Step_1    		 = 2'd1;
localparam Step_2   		     = 2'd2;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or P1_MontgomeryR_done or P2_MontgomeryR_done or P3_MontgomeryR_done) 
begin				
	case(cstate)
		IDLE: 	  if(enable) nstate <= Step_1;
				   else nstate <= IDLE;
		Step_1:   if(P1_MontgomeryR_done) nstate <= Step_2;
		           else nstate <= Step_1;
		Step_2:   if(P1_MontgomeryR_done) nstate <= IDLE;
		           else nstate <= Step_2;			   				
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
            Basemul_done <= 1'b0;
            oPoly_r0 <= 0;
            oPoly_r1 <= 0;
			P1_MontgomeryR_enable <= 1'b0;
			P2_MontgomeryR_enable <= 1'b0;
			P3_MontgomeryR_enable <= 1'b0;
		        end
	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
			      Basemul_done <= 1'b0;	
				         end
			{IDLE,Step_1}: begin
			      P1_iCoeffs_a <= iCoeffs_a1;
			      P1_iCoeffs_b <= iCoeffs_b1;
			      P2_iCoeffs_a <= iCoeffs_a0;
			      P2_iCoeffs_b <= iCoeffs_b0;
			      P3_iCoeffs_a <= iCoeffs_a0;
			      P3_iCoeffs_b <= iCoeffs_b1;
			      P1_MontgomeryR_enable <= 1'b1;
			      P2_MontgomeryR_enable <= 1'b1;
			      P3_MontgomeryR_enable <= 1'b1;	
				         end
			{Step_1,Step_1}: begin
			      P1_MontgomeryR_enable <= 1'b0;
			      P2_MontgomeryR_enable <= 1'b0;
			      P3_MontgomeryR_enable <= 1'b0;				       
			                 end	         				         
			{Step_1,Step_2}: begin
			      temp_poly_r0_0 <= P1_oCoeffs;
			      temp_poly_r0_1 <= P2_oCoeffs;
			      temp_poly_r1 <= P3_oCoeffs;
			      P1_iCoeffs_a <= P1_oCoeffs;
			      P1_iCoeffs_b <= i_Zeta;
			      P2_iCoeffs_a <= iCoeffs_a1;
			      P2_iCoeffs_b <= iCoeffs_b0;
			      P1_MontgomeryR_enable <= 1'b1;
			      P2_MontgomeryR_enable <= 1'b1;			      				       
			                 end
			{Step_2,Step_2}: begin
			      P1_MontgomeryR_enable <= 1'b0;
			      P2_MontgomeryR_enable <= 1'b0;				       
			                 end
			{Step_2,IDLE}: begin
                  oPoly_r0 <= $signed(temp_poly_r0_1) + $signed(P1_oCoeffs);
                  oPoly_r1 <= $signed(temp_poly_r1) + $signed(P2_oCoeffs);
                  Basemul_done <= 1'b1;	
			                end                			                 			                 	
			default: ;
			endcase
		end
	
					
State_PAcc__Poly_PAcc__Poly_Basemul__Basemul__MontgomeryR P1(
.clk(clk),		
.reset_n(reset_n),
.enable(P1_MontgomeryR_enable),	
.iCoeffs_a(P1_iCoeffs_a),
.iCoeffs_b(P1_iCoeffs_b),
.MontgomeryR_done(P1_MontgomeryR_done),
.oCoeffs(P1_oCoeffs)
);

State_PAcc__Poly_PAcc__Poly_Basemul__Basemul__MontgomeryR P2(
.clk(clk),		
.reset_n(reset_n),
.enable(P2_MontgomeryR_enable),	
.iCoeffs_a(P2_iCoeffs_a),
.iCoeffs_b(P2_iCoeffs_b),
.MontgomeryR_done(P2_MontgomeryR_done),
.oCoeffs(P2_oCoeffs)
);

State_PAcc__Poly_PAcc__Poly_Basemul__Basemul__MontgomeryR P3(
.clk(clk),		
.reset_n(reset_n),
.enable(P3_MontgomeryR_enable),	
.iCoeffs_a(P3_iCoeffs_a),
.iCoeffs_b(P3_iCoeffs_b),
.MontgomeryR_done(P3_MontgomeryR_done),
.oCoeffs(P3_oCoeffs)
);
		
endmodule
