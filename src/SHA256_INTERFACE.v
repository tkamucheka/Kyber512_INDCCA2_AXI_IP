`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 12:48:51 AM
// Design Name: 
// Module Name: SHA256_INTERFACE
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


module SHA256_INTERFACE(
	input clk,              //clock signal
	input rst_n,            //reset signal
	input load,             //load initial value & Message 
	input fetch,            //fetch Hash value
   output [15:0] odata,    //output data
   output EN,              //SHA256_CORE??????M??
   //output EN_busy,              //SHA256_CORE??????M??
   input busy,             //?X?e?[?g????p ?f?[?^???????????????v?Z?I?????????
   output ack,             //acknowledgement signal load??fetch?????
   input [31:0] Hash0,     //SHA_CORE???????n?b?V???l
   input [31:0] Hash1,
   input [31:0] Hash2,
   input [31:0] Hash3,
   input [31:0] Hash4,
   input [31:0] Hash5,
   input [31:0] Hash6,
   input [31:0] Hash7,
   input [15:0] idata, //#??X
   output [31:0] idata32 //#???
);  

/********************** reg wire ?? ************************************************************/
reg ack_r;

reg [15:0] odata_r;

//state machine
reg [2:0] state;
reg [2:0] next_state;

reg [4:0] Dnum; //#2,4


//SHA256_CORE??????M??
assign EN = ((state == 3'b010) && (~Dnum[0]))? 1'b1 : 1'b0; //#??????Dnum????
//assign EN = ((state == 3'b101) && (~Dnum[0]))? 1'b1 : 1'b0; //#??????Dnum????
//assign EN_busy = ((state == 3'b101) && (~Dnum[0]))? 1'b1 : 1'b0; //#??????Dnum????

reg [31:0] idata_r; //#idata?p???W?X?^
/********************** ack CTRL *****************************************************************/
//acknowledgement signal
assign ack = ack_r;
always @(posedge clk or negedge rst_n)begin
   if (~rst_n) ack_r <= 0;                           //reset
   else begin
      if (state == 3'b011) ack_r <= 1;               //fetch?pack 
      else if (state == 3'b001) ack_r <= 1;          //load?pack //#???
      else ack_r <= 0;
   end
end

/********************** FETCH ?X?e?[?g ***********************************************************/
assign odata = odata_r;                                     //output
always @(posedge clk or negedge rst_n)begin
   if (~rst_n) odata_r <= 16'h0000;                     //reset
   else begin
      if (state == 3'b011) begin                       //?J?E???^????????o????????
         if (Dnum == 'd0) odata_r <= Hash0[31:16]; 
         else if (Dnum == 'd1) odata_r <= Hash0[15:0];
         else if (Dnum == 'd2) odata_r <= Hash1[31:16];
         else if (Dnum == 'd3) odata_r <= Hash1[15:0];
         else if (Dnum == 'd4) odata_r <= Hash2[31:16];
         else if (Dnum == 'd5) odata_r <= Hash2[15:0];
         else if (Dnum == 'd6) odata_r <= Hash3[31:16];
         else if (Dnum == 'd7) odata_r <= Hash3[15:0];
	 else if (Dnum == 'd8) odata_r <= Hash4[31:16];
	 else if (Dnum == 'd9) odata_r <= Hash4[15:0];
	 else if (Dnum == 'd10) odata_r <= Hash5[31:16];
	 else if (Dnum == 'd11) odata_r <= Hash5[15:0];
	 else if (Dnum == 'd12) odata_r <= Hash6[31:16];
	 else if (Dnum == 'd13) odata_r <= Hash6[15:0];
	 else if (Dnum == 'd14) odata_r <= Hash7[31:16];
	 else if (Dnum == 'd15) odata_r <= Hash7[15:0];
      end
      else odata_r <= odata_r;
   end
end

//fetch?p?J?E???^ //#load?p?J?E???^
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) Dnum <= 5'd0;                                //reset
   else if ((state == 3'b001) || (state == 3'b100)) Dnum <= Dnum + 1;  //fetch data count //#load data count
   else if (Dnum == 'd32) Dnum <= 5'd0;
	else Dnum <= Dnum;
end

assign idata32 = idata_r;
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) idata_r <= 32'h00000000;
	else if (state == 3'b001) idata_r <= {idata_r[15:0],idata};
	else idata_r <= idata_r;
end
/********************** ?X?e?[?g?}?V?? ***********************************************************/
// Finite State Machine
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) state <= 3'b000;
   else state <= next_state;
end

//?g??????H
always @(load or fetch or state or busy) begin    //????????M???????????????????
   case (state)
      3'b000      : begin                         //?????X?e?[?g
         if (load) next_state <= 3'b001;                     
         else if (fetch) next_state <= 3'b011;              
         else next_state <= 3'b000;
      end

      3'b001  : next_state <= 3'b010;             //load_ack?X?e?[?g ack???
      //3'b101  : next_state <= 3'b010;             //load_ack?X?e?[?g ack???

      3'b010  : begin                             //SHA256_core???N????????X?e?[?g EN??High????
         if (~busy) next_state <= 3'b000;         //busy??High?????@
         else next_state <= 3'b010;
      end
      
      3'b011 : next_state <= 3'b100;              //fetch?X?e?[?g odata??Hash??????? 
      
      3'b100  : next_state <= 3'b000;             //cnt <= cnt + 1;

      default: next_state <= 3'b000;
   endcase
end



endmodule

