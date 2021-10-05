/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* if "ack" is 1, then current input has been used. */

module f_permutation_bramd #(
  parameter r = 576,  // bitrate
  parameter c = 1024, // capacity
  parameter d = 512   // output length
) (clk, reset_n, in, in_ready, ack, out, out_ready);
  input                     clk, reset_n;
  input      [r-1:0]        in;
  // input      [5:0]          S_WAd,
  // input      [63:0]         S_WData,
  input                     in_ready;
  output                    ack;
  output reg [1599:0]       out;
  output reg                out_ready;

  reg [3:0] cstate, nstate;
  localparam READY  = 4'd0;
  localparam ACCEPT = 4'd1;
  localparam MAX = (r/64)-1; 

  reg        [10:0]         i; /* select round constant */
  wire       [1599:0]       round_in, round_out;
  wire       [63:0]         rc1, rc2;
  wire                      update;
  wire                      accept;
  reg                       calc; /* == 1: calculating rounds */
  reg                       ready_tick;

  reg in_WEn;
  reg [5:0]  in_WAd, in_RAd;
  reg [63:0] in_WData;
  reg input_ready;

  wire S_WEn;
  wire [5:0] S_RAd, S_WAd, round_RAd, out_RAd;
  wire [63:0] S_WData, S_RData;

  always @(posedge clk)
    if (reset_n)  cstate <= READY;
    else          cstate <= nstate;

  always @(cstate, in_ready, in_WAd)
    case (cstate)
      READY:  if (in_ready)      nstate <= ACCEPT;
              else               nstate <= READY;
      ACCEPT: if (in_WAd == MAX) nstate <= READY;
              else               nstate <= ACCEPT; 
      default:                   nstate <= READY;
    endcase


  always @(posedge clk) begin
    if (reset_n) begin
      in_WAd   <= 0;
      in_WData <= 0;
      in_RAd   <= 0;
      in_WEn   <= 0;
      input_ready <= 0;
    end else begin
      case ({cstate,nstate})
        {READY,READY}: begin
          in_WEn   <= 1;
          in_WAd   <= 0;
          in_RAd   <= 0;
          input_ready <= 0;
        end
        {READY,ACCEPT}: begin
          in_WEn   <= 1;
          in_RAd   <= 0;
          in_WAd   <= 0;
          in_WData <= in[r-(in_WAd*64)-1 -: 64] ^ S_RData;
        end
        {ACCEPT,ACCEPT}: begin
          in_WEn   <= 1;
          in_RAd   <= in_RAd + 1;
          in_WAd   <= in_WAd + 1;
          in_WData <= in[r-((in_WAd+1)*64)-1 -: 64] ^ S_RData;
        end
        {ACCEPT,READY}: begin
          in_WEn      <= 0;
          input_ready <= 1;
        end
        default: ;
      endcase
    end
  end

  // assign accept = in_ready & (~ calc); // in_ready & (i == 0)
  assign accept = input_ready & (~ calc); // in_ready & (i == 0)
  
  always @ (posedge clk)
    if (reset_n) i <= 0;
    else         i <= {i[9:0], accept};
  
  always @ (posedge clk)
    if (reset_n) calc <= 0;
    else         calc <= (calc & (~ i[10])) | accept;
  
  assign update = calc | accept;

  assign ack = input_ready;

  always @ (posedge clk)
    if (reset_n) begin
      out_ready <= 0;
      ready_tick <= 0;
    end else if (accept)
      out_ready <= 0;
    else if (i[10] & ~ready_tick) begin // only change at the last round
      out_ready <= 1;
      ready_tick <= 1;
    end else begin
      out_ready <= 0;
      ready_tick <= 0;
    end

  assign round_in = accept ? {in ^ out[1599 -: r], out[0 +: c]} : out;

  S_BRAM_MUX mux0 (
    .cstate(cstate),
    .in_WEn(in_WEn),
    .in_WAd(in_WAd),
    .in_WData(in_WData),
    .out_RAd(out_RAd),
    .round_RAd(round_RAd),
    .S_WEn(S_WEn),
    .S_WAd(S_WAd),
    .S_WData(S_WData),
    .S_RAd(S_RAd)
  );

  // BRAM (SDP): KeccakF1600 permutaton state
  KeccakF1600_S S(
    // Port A:
    .clka(clk),
    .wea(S_WEn),
    .addra(S_WAd),
    .dina(S_WData),
    // Port B:
    .clkb(clk),
    .rstb(reset_n),
    .addrb(S_RAd),
    .doutb(S_RData)
  );

  // Round constants
  rconst2in1
    rconst_ ({i, accept}, rc1, rc2);

  // Permutation round
  round2in1
    round_ (
      .in(round_in), 
      .chomp(input_ready), 
      .S_RAd(round_RAd), 
      .S_RData(S_RData), 
      .round_const_1(rc1), 
      .round_const_2(rc2), 
      .out(round_out)
    );

  always @ (posedge clk)
    if (reset_n)
      out <= 0;
    else if (update)
      out <= round_out;
endmodule
