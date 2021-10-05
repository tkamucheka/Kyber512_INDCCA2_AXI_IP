//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 12:44:55 PM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_PolyVec
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


module State_Pack_Cit__Pack_PolyVec_Group#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Coeffs_Ext_Width = 16,
  parameter Coeffs_Ext_Width_1 = 24,
  parameter Byte_bits = 8,
  parameter Div_Out_Width = 32,
  parameter i_Coeffs_Width = 12,
  parameter o_Ciphertext_Width = 40
)(
	input clk,		
	input reset_n,
	input enable,
	input clear,
	input [i_Coeffs_Width*4-1 : 0] iCoeffs,	
//    input [i_Coeffs_Width-1 : 0] iCoeffs0,
//    input [i_Coeffs_Width-1 : 0] iCoeffs1,
//    input [i_Coeffs_Width-1 : 0] iCoeffs2,
//    input [i_Coeffs_Width-1 : 0] iCoeffs3,
    output reg Pack_Group_done,
    output reg [o_Ciphertext_Width -1 : 0]  oCiphertext_Group
);

wire [i_Coeffs_Width-1 : 0] iCoeffs0 = iCoeffs[i_Coeffs_Width*4-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs1 = iCoeffs[i_Coeffs_Width*3-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs2 = iCoeffs[i_Coeffs_Width*2-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs3 = iCoeffs[i_Coeffs_Width-1 : 0];

reg  [i_Coeffs_Width-1 :0] P0_csubq_in;
wire [i_Coeffs_Width-1 :0] P0_csubq_out;

reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs0;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs1;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs2;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs3;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t0;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t1;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t2;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t3;
										
reg dividend_tvalid;
reg [Coeffs_Ext_Width_1-1 : 0] dividend_tdata;
reg  divisor_tvalid;
wire [15:0] divisor_tdata;
wire dout_tvalid;
wire [40-1:0] dout_tdata;
assign divisor_tdata = KYBER_Q;

reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs0;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs1;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs2;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs3;
wire [Byte_bits-1 : 0] P3_oCiphertext0;
wire [Byte_bits-1 : 0] P3_oCiphertext1;
wire [Byte_bits-1 : 0] P3_oCiphertext2;
wire [Byte_bits-1 : 0] P3_oCiphertext3;
wire [Byte_bits-1 : 0] P3_oCiphertext4;

reg [3:0] cstate,nstate;
localparam IDLE		= 4'd0;
localparam Csubq0	= 4'd1;
localparam Csubq1	= 4'd2;
localparam Csubq2	= 4'd3;
localparam Csubq3	= 4'd4;
localparam Add    = 4'd5;
localparam Div0   = 4'd6;
localparam Div1   = 4'd7;
localparam Div2   = 4'd8;
localparam Div3   = 4'd9;
localparam Shift  = 4'd10;

always @(posedge clk or negedge reset_n or posedge clear)
	if((!reset_n) || clear) cstate <= IDLE;
	else 										cstate <= nstate;
	
always @(cstate or enable or dout_tvalid) 
begin				
	case(cstate)
		IDLE: 	if(enable) 			nstate <= Csubq0;
				   	else 						nstate <= IDLE;
		Csubq0:    							nstate <= Csubq1;
		Csubq1:    							nstate <= Csubq2;
		Csubq2:    							nstate <= Csubq3;
		Csubq3:    							nstate <= Add;
		Add:       							nstate <= Div0;
		Div0:   if(dout_tvalid) nstate <= Div1;
				    else 						nstate <= Div0;					
		Div1:   if(dout_tvalid) nstate <= Div2;
				    else 						nstate <= Div1;	
		Div2:   if(dout_tvalid) nstate <= Div3;
				    else 						nstate <= Div2;	
		Div3:   if(dout_tvalid) nstate <= Shift;
				    else 						nstate <= Div3;
		Shift:     							nstate <= IDLE;				    					    				    
		default: 								nstate <= IDLE;
	endcase
end

always @(posedge clk or negedge reset_n or posedge clear)										
	if((!reset_n) || clear) begin
		Pack_Group_done <= 1'b0;
		oCiphertext_Group   <= 0;
		dividend_tvalid <= 1'b0;
		divisor_tvalid <= 1'b0;
		dividend_tdata <= 0;
	end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Pack_Group_done <= 1'b0;	
				end
			{IDLE,Csubq0}: begin			        			    
					P0_csubq_in <= iCoeffs0;
				end			
			{Csubq0,Csubq1}: begin
					P1_iPolyCoeffs0 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs1;					
				end					
			{Csubq1,Csubq2}: begin
					P1_iPolyCoeffs1 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs2;					
				end	
			{Csubq2,Csubq3}: begin
					P1_iPolyCoeffs2 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs3;					
				end
			{Csubq3,Add}: begin
					P1_iPolyCoeffs3 <= P0_csubq_out;				
				end
			{Add,Div0}: begin
					dividend_tdata <= P1_oPolyCoeffs_t0;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;						
				end
			{Div0,Div0}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				end				           			           
			{Div0,Div1}: begin 
					P3_iPolyCoeffs0 <= dout_tdata[31:16] & 16'h3ff;
					dividend_tdata <= P1_oPolyCoeffs_t1;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				end
			{Div1,Div1}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				end				           			           
			{Div1,Div2}: begin 
					P3_iPolyCoeffs1 <= dout_tdata[31:16] & 16'h3ff;
					dividend_tdata <= P1_oPolyCoeffs_t2;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				end				         
			{Div2,Div2}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				end				           			           
			{Div2,Div3}: begin 
					P3_iPolyCoeffs2 <= dout_tdata[31:16] & 16'h3ff;
					dividend_tdata <= P1_oPolyCoeffs_t3;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				end
			{Div3,Div3}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				end				           			           
			{Div3,Shift}: begin 
					P3_iPolyCoeffs3 <= dout_tdata[31:16] & 16'h3ff;	
				end
			{Shift,IDLE}: begin
					// BUG: reversed construction
					// oCiphertext_Group <= {P3_oCiphertext4,P3_oCiphertext3,P3_oCiphertext2,P3_oCiphertext1,P3_oCiphertext0};
					oCiphertext_Group <= {P3_oCiphertext0,P3_oCiphertext1,P3_oCiphertext2,P3_oCiphertext3,P3_oCiphertext4};
					Pack_Group_done <= 1'b1;	
				end				         
			default: ;
		endcase
	end
	
State_Polytomsg__DataCal__Csubq P0(
.iPolyCoeffs(P0_csubq_in),
.oPolyCoeffs(P0_csubq_out)
);

State_Pack_Cit__Pack_PolyVec__Mask_Add P1(
.iPolyCoeffs0(P1_iPolyCoeffs0),
.iPolyCoeffs1(P1_iPolyCoeffs1),
.iPolyCoeffs2(P1_iPolyCoeffs2),
.iPolyCoeffs3(P1_iPolyCoeffs3),
.oPolyCoeffs_t0(P1_oPolyCoeffs_t0),
.oPolyCoeffs_t1(P1_oPolyCoeffs_t1),
.oPolyCoeffs_t2(P1_oPolyCoeffs_t2),
.oPolyCoeffs_t3(P1_oPolyCoeffs_t3) 
);
   
State_Pack_Cit_Div P2(
.aclk(clk),
.s_axis_divisor_tvalid(divisor_tvalid),
.s_axis_divisor_tdata(divisor_tdata),
.s_axis_dividend_tvalid(dividend_tvalid),
.s_axis_dividend_tdata(dividend_tdata),
.m_axis_dout_tvalid(dout_tvalid),
.m_axis_dout_tdata(dout_tdata)
); 

State_Pack_Cit__Pack_PolyVec__Shift P3(
.iPolyCoeffs0(P3_iPolyCoeffs0),
.iPolyCoeffs1(P3_iPolyCoeffs1),
.iPolyCoeffs2(P3_iPolyCoeffs2),
.iPolyCoeffs3(P3_iPolyCoeffs3),
.o_Ciphertext0(P3_oCiphertext0),
.o_Ciphertext1(P3_oCiphertext1),
.o_Ciphertext2(P3_oCiphertext2),
.o_Ciphertext3(P3_oCiphertext3),
.o_Ciphertext4(P3_oCiphertext4) 
);
  
endmodule
