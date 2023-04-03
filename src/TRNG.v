module TRNG (
  input          i_clk,
  input          rd_enable,
  input          wr_enable,
  input   [15:0] i_addr,
  input   [15:0] i_data,
  output  [15:0] o_data
);

neo430_trng P0 (
  .clk_i(iclk),
  .rden_i(rd_enable),
  .wren_i(wr_enable),
  .addr_i(i_addr),
  .data_i(i_data),
  .data_o(o_data)
);

endmodule
