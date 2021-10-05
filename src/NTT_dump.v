module NTT_dump(
  input clk, 
  input reset_n, 
  input enable,
  input      [3071:0] Coef_RData,
  output reg    [7:0] Coef_RAd,
  output reg [4095:0] ntt_debug,
  output reg done
);

reg [8:0] index;

reg [3:0] cstate,nstate;
localparam IDLE = 4'd0;
localparam DUMP = 4'd1;

always @(posedge clk) begin
  if (!reset_n) cstate <= IDLE;
  else          cstate <= nstate;
end

always @(cstate, enable, index) begin
  case(cstate)
    IDLE: if (enable)       nstate = DUMP;
          else              nstate = IDLE;
    DUMP: if (index == 2) nstate = IDLE;
          else              nstate = DUMP;
  endcase
end

always @(posedge clk) begin
  if (!reset_n) begin
    ntt_debug <= 0;
    Coef_RAd  <= 0;
    done      <= 1;
    index     <= 0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: done <= 0;
      {IDLE,DUMP}: begin
        Coef_RAd                <= Coef_RAd + 1;
        index                   <= index + 1;
        ntt_debug[4095 -: 3072] <= Coef_RData;
      end
      {DUMP,DUMP}: begin
        Coef_RAd          <= Coef_RAd + 1;
        index             <= index + 1;
        ntt_debug[3071:0] <= Coef_RData;
      end
      {DUMP,IDLE}: done <= 1;
      default: ;
    endcase
  end
end

endmodule