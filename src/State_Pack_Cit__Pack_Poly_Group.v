//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2019 11:52:01 AM
// Design Name: 
// Module Name: State_Pack_Cit__Pack_Poly_Group
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


module State_Pack_Cit__Pack_Poly_Group#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Coeffs_Ext_Width = 8,
  parameter Coeffs_Ext_Width_1 = 24,
  parameter Byte_bits = 8,
  parameter Div_Out_Width = 32,
  parameter i_Coeffs_Width = 12,
  parameter o_Ciphertext_Width = 24
)(
	input clk,		
	input reset_n,
	input enable,	
    input [i_Coeffs_Width*8-1 : 0] iCoeffs,
//    input [i_Coeffs_Width-1 : 0] iCoeffs1,
//    input [i_Coeffs_Width-1 : 0] iCoeffs2,
//    input [i_Coeffs_Width-1 : 0] iCoeffs3,
//    input [i_Coeffs_Width-1 : 0] iCoeffs4,
//    input [i_Coeffs_Width-1 : 0] iCoeffs5,
//    input [i_Coeffs_Width-1 : 0] iCoeffs6,
//    input [i_Coeffs_Width-1 : 0] iCoeffs7,
    output reg Pack_Group_done,
    output reg [o_Ciphertext_Width -1 : 0]  oCiphertext_Group
);

wire [i_Coeffs_Width-1 : 0] iCoeffs0 = iCoeffs[i_Coeffs_Width*8-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs1 = iCoeffs[i_Coeffs_Width*7-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs2 = iCoeffs[i_Coeffs_Width*6-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs3 = iCoeffs[i_Coeffs_Width*5-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs4 = iCoeffs[i_Coeffs_Width*4-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs5 = iCoeffs[i_Coeffs_Width*3-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs6 = iCoeffs[i_Coeffs_Width*2-1 -: i_Coeffs_Width];
wire [i_Coeffs_Width-1 : 0] iCoeffs7 = iCoeffs[i_Coeffs_Width-1 : 0];

reg  [i_Coeffs_Width-1 :0] P0_csubq_in;
wire [i_Coeffs_Width-1 :0] P0_csubq_out;

reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs0;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs1;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs2;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs3;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs4;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs5;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs6;
reg  [i_Coeffs_Width-1 :0] P1_iPolyCoeffs7;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t0;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t1;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t2;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t3;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t4;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t5;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t6;
wire [Coeffs_Ext_Width_1-1 :0] P1_oPolyCoeffs_t7;
										
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
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs4;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs5;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs6;
reg  [Coeffs_Ext_Width-1 : 0] P3_iPolyCoeffs7;
wire [Byte_bits-1 : 0] P3_oCiphertext0;
wire [Byte_bits-1 : 0] P3_oCiphertext1;
wire [Byte_bits-1 : 0] P3_oCiphertext2;

reg [4:0] cstate,nstate;
localparam IDLE		        = 5'd0;
localparam Csubq0     		= 5'd1;
localparam Csubq1     		= 5'd2;
localparam Csubq2     		= 5'd3;
localparam Csubq3     		= 5'd4;
localparam Csubq4     		= 5'd5;
localparam Csubq5     		= 5'd6;
localparam Csubq6     		= 5'd7;
localparam Csubq7     		= 5'd8;
localparam Add               = 5'd9;
localparam Div0              = 5'd10;
localparam Div1              = 5'd11;
localparam Div2              = 5'd12;
localparam Div3              = 5'd13;
localparam Div4              = 5'd14;
localparam Div5              = 5'd15;
localparam Div6              = 5'd16;
localparam Div7              = 5'd17;
localparam Shift             = 5'd18;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or dout_tvalid) 
begin				
	case(cstate)
		IDLE: 	  if(enable) nstate <= Csubq0;
				   else nstate <= IDLE;
		Csubq0:    nstate <= Csubq1;
		Csubq1:    nstate <= Csubq2;
		Csubq2:    nstate <= Csubq3;
		Csubq3:    nstate <= Csubq4;
		Csubq4:    nstate <= Csubq5;
		Csubq5:    nstate <= Csubq6;
		Csubq6:    nstate <= Csubq7;
		Csubq7:    nstate <= Add;
		Add:       nstate <= Div0;
		Div0:      if(dout_tvalid) nstate <= Div1;
				    else nstate <= Div0;					
		Div1:      if(dout_tvalid) nstate <= Div2;
				    else nstate <= Div1;	
		Div2:      if(dout_tvalid) nstate <= Div3;
				    else nstate <= Div2;	
		Div3:      if(dout_tvalid) nstate <= Div4;
				    else nstate <= Div3;
		Div4:      if(dout_tvalid) nstate <= Div5;
				    else nstate <= Div4;					
		Div5:      if(dout_tvalid) nstate <= Div6;
				    else nstate <= Div5;	
		Div6:      if(dout_tvalid) nstate <= Div7;
				    else nstate <= Div6;	
		Div7:      if(dout_tvalid) nstate <= Shift;
				    else nstate <= Div7;				    
		Shift:     nstate <= IDLE;				    					    				    
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
            Pack_Group_done <= 1'b0;
			oCiphertext_Group   <= 0;
			dividend_tvalid <= 1'b0;
			divisor_tvalid <= 1'b0;
			dividend_tdata <= 0;
		         end
	else begin
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
			{Csubq3,Csubq4}: begin
			        P1_iPolyCoeffs3 <= P0_csubq_out;
			        P0_csubq_in <= iCoeffs4;				
				           end
			{Csubq4,Csubq5}: begin
			        P1_iPolyCoeffs4 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs5;					
				           end					
			{Csubq5,Csubq6}: begin
			        P1_iPolyCoeffs5 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs6;					
				           end	
			{Csubq6,Csubq7}: begin
			        P1_iPolyCoeffs6 <= P0_csubq_out;
					P0_csubq_in <= iCoeffs7;					
				           end
			{Csubq7,Add}: begin
			        P1_iPolyCoeffs7 <= P0_csubq_out;				
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
			        P3_iPolyCoeffs0 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t1;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end
			{Div1,Div1}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end				           			           
			{Div1,Div2}: begin 
			        P3_iPolyCoeffs1 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t2;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end				         
			{Div2,Div2}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end				           			           
			{Div2,Div3}: begin 
			        P3_iPolyCoeffs2 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t3;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end
			{Div3,Div3}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end
			{Div3,Div4}: begin 
			        P3_iPolyCoeffs3 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t4;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end				         
			{Div4,Div4}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end				           			           
			{Div4,Div5}: begin 
			        P3_iPolyCoeffs4 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t5;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end
			{Div5,Div5}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end
			{Div5,Div6}: begin 
			        P3_iPolyCoeffs5 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t6;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end				         
			{Div6,Div6}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end					           				           			           
			{Div6,Div7}: begin 
			        P3_iPolyCoeffs6 <= dout_tdata[23:16] & 8'd7;
					dividend_tdata <= P1_oPolyCoeffs_t7;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;	
				         end				         
			{Div7,Div7}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end	
			{Div7,Shift}: begin 
			        P3_iPolyCoeffs7 <= dout_tdata[23:16] & 8'd7;	
				         end
			{Shift,IDLE}: begin 
					// BUG: reversed construction
					// oCiphertext_Group <= {P3_oCiphertext2,P3_oCiphertext1,P3_oCiphertext0};
					oCiphertext_Group <= {P3_oCiphertext0,P3_oCiphertext1,P3_oCiphertext2};
					Pack_Group_done <= 1'b1;	
				end				         
			default: ;
			endcase
		end
	
State_Polytomsg__DataCal__Csubq P0(
.iPolyCoeffs(P0_csubq_in),
.oPolyCoeffs(P0_csubq_out)
);

State_Pack_Cit__Pack_Poly__Mask_Add P1(
.iPolyCoeffs0(P1_iPolyCoeffs0),
.iPolyCoeffs1(P1_iPolyCoeffs1),
.iPolyCoeffs2(P1_iPolyCoeffs2),
.iPolyCoeffs3(P1_iPolyCoeffs3),
.iPolyCoeffs4(P1_iPolyCoeffs4),
.iPolyCoeffs5(P1_iPolyCoeffs5),
.iPolyCoeffs6(P1_iPolyCoeffs6),
.iPolyCoeffs7(P1_iPolyCoeffs7),
.oPolyCoeffs_t0(P1_oPolyCoeffs_t0),
.oPolyCoeffs_t1(P1_oPolyCoeffs_t1),
.oPolyCoeffs_t2(P1_oPolyCoeffs_t2),
.oPolyCoeffs_t3(P1_oPolyCoeffs_t3),
.oPolyCoeffs_t4(P1_oPolyCoeffs_t4),
.oPolyCoeffs_t5(P1_oPolyCoeffs_t5),
.oPolyCoeffs_t6(P1_oPolyCoeffs_t6),
.oPolyCoeffs_t7(P1_oPolyCoeffs_t7) 
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

State_Pack_Cit__Pack_Poly__Shift P3(
.iPolyCoeffs0(P3_iPolyCoeffs0),
.iPolyCoeffs1(P3_iPolyCoeffs1),
.iPolyCoeffs2(P3_iPolyCoeffs2),
.iPolyCoeffs3(P3_iPolyCoeffs3),
.iPolyCoeffs4(P3_iPolyCoeffs4),
.iPolyCoeffs5(P3_iPolyCoeffs5),
.iPolyCoeffs6(P3_iPolyCoeffs6),
.iPolyCoeffs7(P3_iPolyCoeffs7),
.o_Ciphertext0(P3_oCiphertext0),
.o_Ciphertext1(P3_oCiphertext1),
.o_Ciphertext2(P3_oCiphertext2) 
);
  
endmodule
