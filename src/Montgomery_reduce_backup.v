

module Montgomery_reduce #(
  parameter MontgomeryR_QINV = 62209,
  parameter KYBER_Q = 3329)
(
  input [15:0] iCoeffs_a,
  input [15:0] iCoeffs_b,
  output [15:0] oCoeffs
);

wire signed [31:0] a;
wire signed [31:0] t;
wire signed [15:0] u;

assign a = $signed(iCoeffs_a) * $signed(iCoeffs_b);
assign u = a * $signed(MontgomeryR_QINV);
assign t = u * $signed(KYBER_Q);
assign oCoeffs = $signed(a - t) >>> 16;

endmodule