//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2019 01:27:12 PM
// Design Name: 
// Module Name: State_Polytomsg__DataCal
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


module State_Polytomsg__DataCal#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter Coeffs_Ext_Width = 16,
  parameter Div_Out_Width = 40,
  parameter i_Coeffs_Width = 12,
  parameter o_Msg_Width = 1

)(
	input clk,		
	input reset_n,
	input enable,	
    input [i_Coeffs_Width-1 : 0] iCoeffs,
    output reg Data_Cal_done,
    output reg [o_Msg_Width -1 : 0]  oMsg 	
);
																																	
reg  [i_Coeffs_Width-1 :0] csubq_in;
wire [i_Coeffs_Width-1 :0] csubq_out;
reg  [i_Coeffs_Width-1 :0] polyadd_in;
wire [Coeffs_Ext_Width-1 :0] polyadd_out;										
reg dividend_tvalid;
reg [23:0] dividend_tdata;
reg  divisor_tvalid;
wire [15:0] divisor_tdata;
wire dout_tvalid;
wire [Div_Out_Width-1:0] dout_tdata;

assign divisor_tdata = KYBER_Q;

reg [1:0] cstate,nstate;
parameter IDLE		        = 2'd0;
parameter Csubq     		= 2'd1;
parameter Add               = 2'd2;
parameter Div               = 2'd3;

always @(posedge clk or negedge reset_n)
	if(!reset_n) cstate <= IDLE;
	else cstate <= nstate;
	
always @(cstate or enable or dout_tvalid) 
begin				
	case(cstate)
		IDLE: 	  if(enable) nstate <= Csubq;
				   else nstate <= IDLE;
		Csubq:     nstate <= Add;
		Add:       nstate <= Div;
		Div:      if(dout_tvalid) nstate <= IDLE;
				   else nstate <= Div;					
		default: nstate <= IDLE;
		endcase
end

always @(posedge clk or negedge reset_n)										
	if(!reset_n) begin
            Data_Cal_done <= 0;
			oMsg   <= 0;
			csubq_in <= 0;
			polyadd_in <= 0;
			dividend_tvalid <= 1'b0;
			divisor_tvalid <= 1'b0;
			dividend_tdata <= 0;
		         end
	else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
					Data_Cal_done <= 1'b0;	
				  end
			{IDLE,Csubq}: begin			        			    
					csubq_in <= iCoeffs;
				   end			
			{Csubq,Add}: begin
					polyadd_in <= csubq_out;					
				           end					
			{Add,Div}: begin
					dividend_tdata <= polyadd_out;
					dividend_tvalid <= 1'b1;
					divisor_tvalid <= 1'b1;						
				           end
			{Div,Div}: begin
					dividend_tvalid <= 1'b0;
					divisor_tvalid <= 1'b0;						
				           end				           			           
			{Div,IDLE}: begin 
					Data_Cal_done <= 1'b1;
					oMsg <= dout_tdata[16];
				end
			default: ;
			endcase
		end
	
State_Polytomsg__DataCal__Csubq State_Polytomsg__DataCal__Csubq_0(
.iPolyCoeffs(csubq_in),
.oPolyCoeffs(csubq_out)
);

State_Polytomsg__DataCal__Add State_Polytomsg__DataCal__Add_0(
.iPolyCoeffs(polyadd_in),
.oPolyCoeffs(polyadd_out)
   );
   
State_Pack_Cit_Div State_Pack_Cit_Div_0(
.aclk(clk),
.s_axis_divisor_tvalid(divisor_tvalid),
.s_axis_divisor_tdata(divisor_tdata),
.s_axis_dividend_tvalid(dividend_tvalid),
.s_axis_dividend_tdata(dividend_tdata),
.m_axis_dout_tvalid(dout_tvalid),
.m_axis_dout_tdata(dout_tdata)
  );
     
endmodule
