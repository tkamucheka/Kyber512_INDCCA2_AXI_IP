//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 07/06/2021 12:33:03 PM
// Design Name: 
// Module Name: polyvec_decompress
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

module Polyvec_Decompress #(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter BYTE_BITS = 8,
  parameter COEFF_SZ = 12,
  parameter KYBER_POLYVECCOMPRESSEDBYTES = KYBER_K * 320,
  parameter POLYVECCOMPRESSED_SZ = BYTE_BITS * KYBER_POLYVECCOMPRESSEDBYTES,
  parameter POLYVEC_SZ = COEFF_SZ * KYBER_N
)(
  input                                   clk,
  input                                   reset_n,
  input                                   enable,
  input      [(POLYVECCOMPRESSED_SZ/2)-1 : 0] i_Polyvec_Compressed,
  output reg                              out_ready,
  output reg                              Function_Done,
  output reg [POLYVEC_SZ-1 : 0]           oPolyVec
);

localparam K = 3;

integer i, j;

reg dirty = 0;
reg   [ 7:0] stage = 0;
reg   [39:0] a;
wire  [47:0] r;
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
    OUTPUT:   if (j == 64)      nstate <= IDLE;
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
    Function_Done <= 1'b0;
    dirty <= 1'b0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: begin
        out_ready <= 1'b0;
        Function_Done <= 1'b0;
        dirty <= 1'b0;
        stage <= 0;
        i <= 0;
        j <= 0;
      end
      {IDLE,LOAD}: begin
        a     <= i_Polyvec_Compressed[2560-(40*i)-1 -: 40];
        i     <= i + 1;
        stage <= stage <= 1;
        dirty <= 1'b1;
      end
      {LOAD,LOAD}: begin
        a     <= i_Polyvec_Compressed[2560-(40*i)-1 -: 40];
        i     <= i + 1;
        stage <= stage + 1;
      end
      {LOAD,OUTPUT}: begin
        a         <= i_Polyvec_Compressed[2560-(40*i)-1 -: 40];
        i         <= i + 1;
        out_ready <= 1'b1;
        oPolyVec[3071-(48*j) -: 48]  <= r;
        j <= j + 1;
      end
      {OUTPUT,OUTPUT}: begin
        a         <= i_Polyvec_Compressed[2560-(40*i)-1 -: 40];
        i         <= i + 1;
        oPolyVec[3071-(48*j) -: 48]  <= r;
        j <= j + 1;
      end
      {OUTPUT,IDLE}: begin
        out_ready     <= 1'b1;
        Function_Done <= 1'b1;
      end
      default: ;
    endcase
  end
end

Polyvec_Decompress__t P0 (
  .clk(clk),
  .a(a),
  .t(w_t)
);

Polyvec_Decompress__r P1 (
  .clk(clk),
  .t(w_t),
  .r(r)
);
  
endmodule