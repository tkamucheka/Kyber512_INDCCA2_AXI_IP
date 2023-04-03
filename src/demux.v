module Demux (
  input        clk,
  input   wire select,
  input   wire din,
  output  reg  dout0,
  output  reg  dout1
);

always @(posedge clk) begin
  case (select)
    1'b0: dout0 <= din;
    1'b1: dout1 <= din;
    default: ;
  endcase
end

endmodule