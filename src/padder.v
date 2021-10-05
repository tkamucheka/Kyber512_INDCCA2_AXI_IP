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

/* "is_last" == 0 means byte number is 8, no matter what value "byte_num" is. */
/* if "in_ready" == 0, then "is_last" should be 0. */
/* the user switch to next "in" only if "ack" == 1. */

module padder #(
  parameter r       = 576,  // bitrate
  parameter c       = 1024, // capacity
  parameter d       = 512,  // output length
  parameter BUF_SZ  = 9     // buffer size
) (clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack);
    input                         clk, reset;
    input      [63:0]             in;
    input                         in_ready, is_last;
    input      [2:0]              byte_num;
    output                        buffer_full; /* to "user" module */
    output reg [r-1:0]            out;         /* to "f_permutation" module */
    output                        out_ready;   /* to "f_permutation" module */
    input                         f_ack;       /* from "f_permutation" module */

    reg                           state;       /* state == 0: user will send more input data
                                                * state == 1: user will not send any data */
    reg                           done;        /* == 1: out_ready should be 0 */
    reg        [BUF_SZ-1:0]       i;           /* length of "out" buffer */
    wire       [63:0]             v0;          /* output of module "padder1" */
    reg        [63:0]             v1;          /* to be shifted into register "out" */
    wire                          accept,      /* accept user input? */
                                  update;
    
    assign buffer_full = i[BUF_SZ-1];
    assign out_ready = buffer_full;
    assign accept = (~ state) & in_ready & (~ buffer_full); // if state == 1, do not eat input
    assign update = (accept | (state & (~ buffer_full))) & (~ done); // don't fill buffer if done

    always @ (posedge clk)
      if (reset)
        out <= 0;
      else if (update)
        out <= {out[0 +: (r - 64)], v1};

    always @ (posedge clk)
      if (reset)
        i <= 0;
      else if (f_ack | update)
        i <= {i[BUF_SZ-2:0], 1'b1} & {BUF_SZ{~ f_ack}};
/*    if (f_ack)  i <= 0; */
/*    if (update) i <= {i[BUF_SZ-2:0], 1'b1}; // increase length */

    always @ (posedge clk)
      if (reset)
        state <= 0;
      else if (is_last)
        state <= 1;

    always @ (posedge clk)
      if (reset)
        done <= 0;
      else if (state & out_ready)
        done <= 1;

    padder1 p0 (in, byte_num, v0);
    
    always @ (*)
      begin
        if (state)
          begin
            v1 = 0;
            v1[7] = v1[7] | i[BUF_SZ-2]; /* "v1[7]" is the MSB of its last byte */
          end
        else if (is_last == 0)
          v1 = in;
        else
          begin
            v1 = v0;
            v1[7] = v1[7] | i[BUF_SZ-2];
          end
      end
endmodule
