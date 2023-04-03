module S_BRAM_MUX (
  input      [3:0] cstate,
  input        in_WEn,
  input      [5:0] in_WAd,
  input      [63:0] in_WData,
  input      [5:0] out_RAd,
  input      [5:0] round_RAd,
  output reg        S_WEn,
  output reg [5:0]  S_WAd,
  output reg [63:0] S_WData,
  output reg [5:0] S_RAd
);

localparam ACCEPT = 4'd1;
localparam ROUND  = 4'd2;
localparam OUTPUT = 4'd3;

always @(*) begin
  case (cstate)
    ACCEPT: begin
      S_WEn   <= in_WEn;
      S_WAd   <= in_WAd;
      S_WData <= in_WData;
      S_RAd   <= in_WAd;
    end
    ROUND: begin
      S_WEn   <= 0;
      S_WAd   <= 0;
      S_WData <= 0;
      S_RAd   <= round_RAd;
    end
    OUTPUT: begin
      S_WEn   <= 0;
      S_WAd   <= 0;
      S_WData <= 0;
      S_RAd   <= out_RAd;
    end
    default: begin
      S_WEn   <= 0;
      S_WAd   <= 0;
      S_WData <= 0;
      S_RAd   <= 0;
    end 
  endcase
end
  
endmodule