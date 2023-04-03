module NTT#(
  parameter KYBER_K = 2/3/4,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329
)(
	input clk,		
	input reset_n,
	input enable,
  input [15 : 0] Coef_RData,
  output reg  [7 : 0] Coef_RAd,
  output reg  [0 : 0] Coef_WEN,
  output reg  [7 : 0] Coef_WAd,
  output reg  [15 : 0] Coef_WData,
  output reg Poly_NTT_done
);

localparam LOG2_N = $clog2(KYBER_N);
localparam LOG2_Q = $clog2(KYBER_Q);

wire [7:0] i_corr;
wire [7:0] k, k_0;
reg  [7:0] i;
reg  [7:0] stage;

reg [9:0] index;

wire [15:0] zeta_k;

wire [15:0] Montgomery_oCoeffs;

reg [8:0] start;
reg [7:0] j, k_addr;
wire [7:0] len, j_len;

reg [15:0] A [255:0];

reg [15:0] A_j;

reg compute_done;

reg update;

reg [2:0] cstate, nstate;
reg [2:0] IDLE      = 3'd0;
reg [2:0] FETCH     = 3'd1;
reg [2:0] COMPUTE_R = 3'd2;
reg [2:0] COMPUTE_W = 3'd3;
reg [2:0] WRITE     = 3'd4;

assign len = 128 >> stage;

assign j_len = len + j;

// Index Computation:
// calculate the corresponding point's index i_corr to the i_th point
assign i_corr = i ^ (1 << stage);

// calculate the twiddle factor k for both i_corr and i
assign k_0 = (stage == 0) ? 0 : (i << (LOG2_N - stage));
assign k   = k_0[8-1 : 1];

// Shared Variable Computation
assign v = Montgomery_oCoeffs;

always @(posedge clk)
  if (!reset_n) cstate <= IDLE;
  else          cstate <= nstate;

always @(cstate, enable, compute_done, Coef_RAd, Coef_WAd) begin
  case (cstate)
    IDLE:       if (enable)       nstate = FETCH;
                else              nstate = IDLE;
    FETCH:      if (index == 255) nstate = COMPUTE_R;
                else              nstate = FETCH;
    COMPUTE_R:  if (compute_done) nstate = WRITE;
                // else if (update)  nstate = COMPUTE_W;
                else              nstate = COMPUTE_R;
    COMPUTE_W:                    nstate = COMPUTE_R;
    WRITE:      if (index == 255) nstate = IDLE;
                else              nstate = WRITE;
    default:                      nstate = IDLE;
  endcase
end

always @(posedge clk, negedge reset_n) begin
  if (!reset_n) begin
    compute_done  <= 0;
    Coef_RAd      <= 0;
    stage         <= 0;
    i             <= 0;
    start         <= 0;
    j             <= 0;
    k_addr        <= 1;
    Coef_WEN      <= 0;
    index         <= 0;
    update        <= 0;
  end else begin
    case ({cstate,nstate})  
      {IDLE,IDLE}: Poly_NTT_done <= 0;
      {IDLE,FETCH}: begin 
        Coef_RAd <= 1;
        A[index] <= Coef_RData;
      end
      {FETCH,FETCH}: begin
        Coef_RAd    <= Coef_RAd + 1;
        index       <= index + 1;
        A[index]    <= Coef_RData;
      end
      {FETCH,COMPUTE_R}: begin
        Coef_RAd <= 0;
        A[index] <= Coef_RData;
      end
      {COMPUTE_R,COMPUTE_R}: begin
        // NTT Function:
        case (update)
          0: begin
            if (stage < LOG2_N-1) begin
              if (start < KYBER_N) begin
                if (j < start + len) begin
                  update <= 1;
                end else begin
                  k_addr <= k_addr + 1;
                  start  <= j + len;
                  j      <= j + len;
                end
              end else begin
                stage <= stage + 1;
                start <= 0;
                j     <= 0;
              end
            end else begin
              compute_done <= 1;
            end
          end
          1: begin
            j           <= j + 1;
            A[j + len]  <= A[j] - Montgomery_oCoeffs;
            A[j]        <= A[j] + Montgomery_oCoeffs;
            update      <= 0;
          end
          default: ; 
        endcase
      end
      // {COMPUTE_R,COMPUTE_W}: begin
      //   update <= 0;
      //   A_j <= A[j];
      // end
      // {COMPUTE_W,COMPUTE_R}: begin
      //   j           <= j + 1;
      //   A[j + len]  <= A_j - Montgomery_oCoeffs;
      //   A[j]        <= A_j + Montgomery_oCoeffs;
      // end
      {COMPUTE_R,WRITE}: begin
        compute_done  <= 0;
        Coef_WEN      <= 1;
        Coef_WAd      <= 0;
        index         <= 0;
        Coef_WData    <= A[0];
      end
      {WRITE,WRITE}: begin
        Coef_WEN    <= 1;
        Coef_WAd    <= Coef_WAd + 1;
        index       <= index + 1;
        Coef_WData  <= A[index+1];
      end
      {WRITE,IDLE}: begin
        k_addr <= 1;
        Coef_WEN      <= 0;
        Coef_WAd      <= 0;
        stage         <= 0;
        index         <= 0;
        Poly_NTT_done <= 1;
      end
      default: ;
    endcase
  end
end

Zeta M0(
.clka(clk),
.addra(k_addr),
.douta(zeta_k)
);    

Montgomery_reduce P0 (
.clk(clk),
.iCoeffs_a(zeta_k),
.iCoeffs_b(A[j+len]),
.oCoeffs(Montgomery_oCoeffs)
);

endmodule