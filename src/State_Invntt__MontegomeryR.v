module INVNTT_MontgomeryR #(
  parameter QINV    = 62209, // q^(-1) mod 2^16
  parameter KYBER_Q = 3329,
  parameter V       = {1'b1,26'b0}/KYBER_Q+1
) (
  input                     clk,
  input                     ce,
  input             [15:0]  zeta_k,
  input             [15:0]  i_Coeffs,
  output reg signed [15:0]  o_Coeffs,
  output reg                ack,
  output                    done
);

localparam last = 5;

reg signed [15:0] t1;
reg signed [31:0] t32, a32;

reg [last:0] state = 0;

assign done = state[last];

always @(posedge clk) begin
  if (ce) begin
    state  <= {state[last:1], 1'b1};
    a32    <= $signed(zeta_k) * $signed(i_Coeffs);
  end else begin
    state     <= state << 1;

    t1        <= $signed(a32) * $signed(QINV);
    t32       <= $signed(t1) * $signed(KYBER_Q);
    o_Coeffs  <= $signed(a32 - t32) >>> 16;
  end
end

endmodule