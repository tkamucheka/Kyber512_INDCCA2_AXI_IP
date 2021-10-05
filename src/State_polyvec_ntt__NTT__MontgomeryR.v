//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2019 08:24:03 PM
// Design Name: 
// Module Name: State_polyvec_ntt__NTT__MontgomeryR
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


module State_polyvec_ntt__NTT__MontgomeryR#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter MontgomeryR_QINV = 62209,
  parameter i_Coeffs_Width = 16,
  parameter o_Coeffs_Width = 16
)(
	input clk,		
	input reset_n,
  input  [i_Coeffs_Width-1 : 0] iCoeffs_a,
  input  [i_Coeffs_Width-1 : 0] iCoeffs_b,
  output reg [o_Coeffs_Width -1 : 0]  oCoeffs
);

reg signed [31:0] temp_Coeff0;
reg signed [15:0] temp_Coeff1;
reg signed [31:0] temp_Coeff00;
reg signed [31:0] temp_Coeff01;
reg signed [31:0] temp_Coeff02;
reg signed [31:0] temp_Coeff03;
reg signed [31:0] temp_Coeff2;

reg [1 : 0] pp_i;

always@(posedge clk or negedge reset_n)
  if(!reset_n) begin
    temp_Coeff0 <= 0;
  end else begin
    temp_Coeff0 <= $signed(iCoeffs_a) *  $signed(iCoeffs_b); 
  end

always@(posedge clk or negedge reset_n)
  if(!reset_n) begin
    temp_Coeff1 <= 0;
    pp_i <= 0;
  end else begin
    temp_Coeff1 <= $signed(temp_Coeff0) * MontgomeryR_QINV;
    pp_i <= pp_i + 1;
    case(pp_i)
      0: begin
        temp_Coeff00 <= temp_Coeff0;
      end
      1: begin
        temp_Coeff01 <= temp_Coeff0;
      end   
      2: begin
        temp_Coeff02 <= temp_Coeff0;
      end
      3: begin
        temp_Coeff03 <= temp_Coeff0;
      end      
      default:;
    endcase
  end

always@(posedge clk or negedge reset_n)
  if(!reset_n) begin
    temp_Coeff2 <= 0;
  end else begin
    temp_Coeff2 <= $signed(temp_Coeff1) * KYBER_Q;
  end

always@(posedge clk or negedge reset_n)
  if(!reset_n) begin
    oCoeffs <= 0;
  end else begin
    case(pp_i)
      0: begin
        oCoeffs <= ($signed(temp_Coeff02 - temp_Coeff2)>>>16);
      end
      1: begin
        oCoeffs <= ($signed(temp_Coeff03 - temp_Coeff2)>>>16);
      end   
      2: begin
        oCoeffs <= ($signed(temp_Coeff00 - temp_Coeff2)>>>16);
      end
      3: begin
        oCoeffs <= ($signed(temp_Coeff01 - temp_Coeff2)>>>16);
      end
      default:;
    endcase   
  end

endmodule