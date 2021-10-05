module INVNTT_BarrettR_MontgomeryR #(
  parameter QINV    = 62209, // q^(-1) mod 2^16
  parameter KYBER_Q = 3329,
  parameter V       = {1'b1,26'b0}/KYBER_Q+1
) (
  input                     clk,
  input                     ce,
  input             [15:0]  zeta_k,
  input             [15:0]  i_Coeffs_a,
  input             [15:0]  i_Coeffs_b,
  output reg signed [15:0]  o_Coeffs_a,
  output reg signed [15:0]  o_Coeffs_b,
  output reg                ack,
  output                    done
);

localparam last = 6;

reg signed [15:0] t3, a, rjlen, zeta;
reg signed [31:0] t32, a32, t1_32, t2_32;

reg [last:0] state = 0;

assign done = state[last];

always @(posedge clk) begin
  if (ce) begin
    state  <= {state[last:1], 1'b1};
    rjlen  <= $signed(i_Coeffs_a) - $signed(i_Coeffs_b);
    a      <= $signed(i_Coeffs_a) + $signed(i_Coeffs_b);
    zeta   <= zeta_k;
  end else begin
    state       <= state << 1;

    t1_32       <= $signed({{16{a[15]}},a}) * $signed(V);
    t2_32       <= ($signed(t1_32) >>> 26) * $signed(KYBER_Q);
    o_Coeffs_a  <= $signed(a) - $signed(t2_32);

    a32         <= $signed(zeta) * $signed(rjlen);
    t3          <= $signed(a32) * $signed(QINV);
    t32         <= $signed(t3) * $signed(KYBER_Q);
    o_Coeffs_b  <= $signed(a32 - t32) >>> 16;  
  end
end
  
endmodule