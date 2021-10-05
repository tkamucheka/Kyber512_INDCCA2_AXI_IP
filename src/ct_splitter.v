`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka
// 
// Create Date: 02/05/2021 10:35:43 AM
// Design Name: Kyber512
// Module Name: ss_splitter
// Project Name: Kyber512
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

module ct_splitter
#(
    parameter ADDR_WIDTH   = 8, 
    parameter INPUT_WIDTH  = 32,
    parameter OUTPUT_WIDTH = 32,
    parameter N            = INPUT_WIDTH / OUTPUT_WIDTH 
)
(
  input                           i_clk,
  input                           i_resetn,
  input                           i_chomp,
  input       [ADDR_WIDTH-1:0]    i_addr,
  input       [INPUT_WIDTH-1:0]   i_data_in,
  output      [OUTPUT_WIDTH-1:0]  o_data_out,
  output reg                      o_outready
);

reg [2:0] cstate, nstate;
localparam IDLE = 3'd0;
localparam BUSY = 3'd1;
localparam LOAD = 3'd2;

reg CT_WEn;
reg [4:0]   CT_WAd;
reg [255:0] CT_WData;
// reg [7:0]   CT_RAd;
// reg [31:0]  CT_RData;

wire mem_busy, mema_busy, memb_busy;

assign mem_busy = mema_busy | memb_busy;

always @(posedge i_clk) begin
  if (i_resetn) cstate <= IDLE;
  else          cstate <= nstate;
end

always @(cstate, i_resetn, i_chomp, mem_busy, CT_WAd) begin
  case (cstate)
    IDLE: if (i_resetn)       nstate <= BUSY;
          else if (i_chomp)   nstate <= LOAD;
          else                nstate <= IDLE;
    BUSY: if (mem_busy == 0)  nstate <= IDLE;
          else                nstate <= BUSY;         
    LOAD: if (CT_WAd == 22)   nstate <= IDLE;
          else                nstate <= LOAD;
    default:                  nstate <= IDLE;
  endcase
end

always @(i_resetn, cstate, nstate, i_data_in, CT_WAd) begin
  if (i_resetn == 0) begin
    CT_WEn      <= 1;
    CT_WAd      <= 0;
    CT_WData    <= 0;
    o_outready  <= 0;
  end else
    case ({cstate,nstate})
      {IDLE,IDLE}: o_outready <= 1;
      {IDLE,BUSY}: o_outready <= 0;
      {BUSY,BUSY}: o_outready <= 0;
      {BUSY,IDLE}: o_outready <= 1;
      {IDLE,LOAD}: begin
        o_outready  <= 0;
        CT_WEn      <= 1;
        CT_WAd      <= 0;
        CT_WData    <= i_data_in[INPUT_WIDTH-1 -: 256];
      end
      {LOAD,LOAD}: begin
        o_outready  <= 0;
        CT_WEn      <= 1;
        CT_WAd      <= CT_WAd + 1;
        CT_WData    <= i_data_in[INPUT_WIDTH-(256*(CT_WAd+1))-1 -: 256];
      end
      {LOAD,IDLE}:  begin
        o_outready  <= 1;
        CT_WEn      <= 0;
      end
      default: ;
    endcase
end

CT_output_blk_mem M0 (
  // Port A:
  .clka(i_clk),
  .rsta_busy(mema_busy),
  .wea(CT_WEn),
  .addra(CT_WAd),
  .dina(CT_WData),
  // Port B:
  .clkb(i_clk),
  .rstb(i_resetn),
  .rstb_busy(memb_busy),
  .addrb(i_addr),
  .doutb(o_data_out)
);

endmodule