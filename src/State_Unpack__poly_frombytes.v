

module State_Unpack__poly_frombytes #(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter BYTE_BITS = 8,
  parameter KYBER_POLYBYTES = 384,
  parameter IPOLY_SZ = BYTE_BITS * KYBER_POLYBYTES * KYBER_K,
  parameter OPOLY_SZ = 128,
  parameter COEFF_SZ = 16
)(
  input                         clk,
  input                         resetn,
  input                         enable,
  input       [IPOLY_SZ-1 : 0]  i_poly,
  output reg                    Function_Done,
  output reg                    out_ready,
  output reg  [OPOLY_SZ-1 : 0]  o_poly
);

reg [7:0] n;

reg  [ 96-1 : 0] a;
wire [128-1 : 0] r;

reg cstate,nstate;
localparam IDLE   = 1'd0;
localparam UNPACK = 1'd1;

always @(posedge clk or negedge resetn) begin
  if (!resetn)  cstate <= IDLE;
  else          cstate <= nstate;
end

always @(cstate, enable, n) begin
  case (cstate)
    IDLE:     if (enable)         nstate <= UNPACK;
              else                nstate <= IDLE;
    UNPACK:   if (n > KYBER_N/4) nstate <= IDLE;
              else                nstate <= UNPACK;
    default:                      nstate <= IDLE;
  endcase
end

always @(posedge clk or negedge resetn) begin
  if (!resetn) begin
    Function_Done <= 0;
    out_ready     <= 0;
    n             <= 0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: begin
        Function_Done <= 0;
      end
      {IDLE,UNPACK}: begin
        a <= i_poly[96+(96*n)-1 -: 96];
        n <= n + 1;
      end
      {UNPACK,UNPACK}: begin
        out_ready <= 1'b1;
        a         <= i_poly[96+(96*n)-1 -: 96];
        o_poly    <= r;
        n         <= n + 1;
      end
      {UNPACK,IDLE}: begin
        Function_Done <= 1'b1;
        out_ready     <= 1'b0;
        n             <= 0;
      end
      default: ;
    endcase
  end
end

State_Unpack__poly_frombytes__r P0 (clk, a, r);
  
endmodule
