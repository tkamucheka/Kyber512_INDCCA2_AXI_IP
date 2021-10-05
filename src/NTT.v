`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 03/08/2021 01:10:30 AM
// Design Name: 
// Module Name: Montgomery_reduce
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

module NTT #(
  parameter KYBER_K = 2,
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

reg [9:0] index;

reg   [7:0] stage;
reg   [8:0] start;
reg   [7:0] j, k;
reg         update, pass, P0_reduce_enable;

wire        P0_reduce_done;
wire  [7:0] len, j_plus_len;
wire [15:0] zeta_k;
wire [15:0] Montgomery_oCoeffs;

reg        [15:0] A_j; //, A_j_plus_len;
reg signed [31:0] a;

reg [2:0] cstate, nstate;
localparam [2:0] IDLE      = 3'd0;
localparam [2:0] COMPUTE_R = 3'd1;
localparam [2:0] REDUCE    = 3'd2;
localparam [2:0] COMPUTE_W = 3'd3;
localparam [2:0] WAIT      = 3'd4;

// Index Computation:
// calculate the corresponding point's index j_plus_len to the j_th point
assign len = 128 >> stage;
assign j_plus_len = len + j;

always @(posedge clk)
  if (!reset_n) cstate <= IDLE;
  else          cstate <= nstate;

always @(cstate, enable, stage, update, P0_reduce_done, pass) begin
  case (cstate)
    IDLE:       if (enable)             nstate = COMPUTE_R;
                else                    nstate = IDLE;
    COMPUTE_R:  if (stage == LOG2_N-1)  nstate = IDLE;
                else if (update)        nstate = WAIT;
                else                    nstate = COMPUTE_R;
    WAIT:                               nstate = REDUCE;
    REDUCE:     if (P0_reduce_done)     nstate = COMPUTE_W;
                else                    nstate = REDUCE;
    COMPUTE_W:                          nstate = COMPUTE_R;
    // COMPUTE_W:  if (pass)               nstate = COMPUTE_R;
    //             else                    nstate = COMPUTE_W;
    default:                            nstate = IDLE;
  endcase
end

always @(posedge clk, negedge reset_n) begin
  if (!reset_n) begin
    Coef_WEN  <= 0;
    stage     <= 0;
    start     <= 0;
    j         <= 0;
    k         <= 1;
    index     <= 0;
    update    <= 0;
    pass      <= 0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: Poly_NTT_done <= 0;
      {IDLE,COMPUTE_R}: begin
        stage <= 0;
        start <= 0;
        j     <= 0;
        k     <= 1;
        index <= 0;
      end
      {COMPUTE_R,COMPUTE_R}: begin
        Coef_WEN    <= 0;
        // NTT Function:
        // if (stage < LOG2_N-1)
        if (start < KYBER_N) begin
          if (j < start + len) begin
            update   <= 1;
            Coef_RAd <= j_plus_len;
          end else begin
            k     <= k + 1;
            start <= j + len;
            j     <= j + len;
          end
        end else begin
          stage <= stage + 1;
          start <= 0;
          j     <= 0;
        end
      end
      {COMPUTE_R,WAIT}: begin
        update  <= 0; 
      end
      {WAIT,REDUCE}: begin
        update            <= 0;
        P0_reduce_enable  <= 1;
        a                 <= $signed(Coef_RData) * $signed(zeta_k);
      end
      {REDUCE,REDUCE}: begin
        P0_reduce_enable  <= 0;
        Coef_RAd          <= j;
        A_j               <= Coef_RData;
      end
      {REDUCE,COMPUTE_W}: begin
        Coef_RAd    <= 8'hxx; // prevent memory collision
        Coef_WEN    <= 1;
        Coef_WAd    <= j_plus_len;
        Coef_WData  <= A_j - Montgomery_oCoeffs;
      end
      {COMPUTE_W,COMPUTE_R}: begin
        Coef_WAd    <= j;
        Coef_WData  <= A_j + Montgomery_oCoeffs;
        index       <= index + 1;
        j           <= j + 1;        
      end
      // {COMPUTE_W,COMPUTE_W}: begin
      //   pass        <= 1;
      //   Coef_WAd    <= j;
      //   Coef_WData  <= A_j + Montgomery_oCoeffs;
      //   index       <= index + 1;
      //   j           <= j + 1;
      // end
      // {COMPUTE_W,COMPUTE_R}: begin
      //   pass        <= 0;
      //   Coef_WEN    <= 0;
      // end
      {COMPUTE_R,IDLE}: begin
        Coef_WEN      <= 0;        
        Poly_NTT_done <= 1;
      end
      default: ;
    endcase
  end
end

Zeta M0(
.clka(clk),
.addra(k[6:0]),
.douta(zeta_k)
);    

Montgomery_reduce P0 (
.clk(clk),
.ce(P0_reduce_enable),
.iCoeffs_a(a),
.oCoeffs(Montgomery_oCoeffs),
.reduce_done(P0_reduce_done)
);

endmodule