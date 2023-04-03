//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/08/2021 06:03:03 AM
// Design Name: 
// Module Name: poly_decompress
// Project Name: Kyber512_INDCPA
// Target Devices: VC707
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

module Poly_Decompress #(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter BYTE_BITS = 8,
  parameter COEFF_SZ = 12,
  parameter KYBER_POLYCOMPRESSEDBYTES = 96,
  parameter POLYCOMPRESSED_SZ = BYTE_BITS * KYBER_POLYCOMPRESSEDBYTES,
  parameter POLYVEC_SZ = COEFF_SZ * KYBER_N
)(
  input                                   clk,
  input                                   reset_n,
  input                                   enable,
  input      [POLYCOMPRESSED_SZ-1 : 0] i_Poly_Compressed,
  output reg                              out_ready,
  output reg [POLYVEC_SZ-1 : 0]           oPoly
);

localparam K = 3;

integer i, j;

reg dirty = 0;
reg   [ 7:0] stage = 0;
reg   [23:0] a;
wire  [95:0] r;
wire  [63:0] w_t;

reg [3:0] cstate,nstate;
localparam IDLE   = 4'd0;
localparam LOAD   = 4'd1;
localparam OUTPUT = 4'd2;

always @(posedge clk or negedge reset_n) begin
  if (!reset_n)  cstate <= IDLE;
  else          cstate <= nstate;
end

always @(cstate, enable, stage, j) begin
  case (cstate)
    IDLE:     if (enable & !dirty)  nstate <= LOAD;
              else              nstate <= IDLE;
    LOAD:     if (stage == K)   nstate <= OUTPUT;
              else              nstate <= LOAD;
    OUTPUT:   if (j == 32)      nstate <= IDLE;
              else              nstate <= OUTPUT;
    default:                    nstate <= IDLE;
  endcase
end

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    a <= 0;
    i <= 0;
    j <= 0;
    stage <= 0;
    out_ready <= 0;
    dirty <= 1'b0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: begin
        out_ready <= 1'b0;
        dirty <= 1'b0;
        stage <= 0;
        i <= 0;
        j <= 0;
      end
      {IDLE,LOAD}: begin
        a     <= i_Poly_Compressed[768-(24*i)-1 -: 24];
        i     <= i + 1;
        stage <= stage <= 1;
        dirty <= 1'b1;
      end
      {LOAD,LOAD}: begin
        a     <= i_Poly_Compressed[768-(24*i)-1 -: 24];
        i     <= i + 1;
        stage <= stage + 1;
      end
      {LOAD,OUTPUT}: begin
        a         <= i_Poly_Compressed[768-(24*i)-1 -: 24];
        i         <= i + 1;
        oPoly[3071-(96*j) -: 96]  <= r;
        j <= j + 1;
      end
      {OUTPUT,OUTPUT}: begin
        a         <= i_Poly_Compressed[768-(24*i)-1 -: 24];
        i         <= i + 1;
        oPoly[3071-(96*j) -: 96]  <= r;
        j <= j + 1;
      end
      {OUTPUT,IDLE}: begin
        out_ready     <= 1'b1;
      end
      default: ;
    endcase
  end
end

Poly_Decompress__t P0 (
  .clk(clk),
  .a(a),
  .t(w_t)
);

Poly_Decompress__r P1 (
  .clk(clk),
  .t(w_t),
  .r(r)
);
  
endmodule