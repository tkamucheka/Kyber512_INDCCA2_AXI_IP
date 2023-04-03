//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arkansas
// Engineer: Tendayi Kamucheka (ftendayi@gmail.com)
// 
// Create Date: 03/15/2021 01:29:00 PM
// Design Name: 
// Module Name: State_InvNTT__INTT
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

module State_INVNTT__INTT #(
  parameter KYBER_N   = 256,
  parameter KYBER_Q   = 3329,
  parameter QINV      = 62209, // q^(-1) mod 2^16
  parameter COEFF_SZ  = 16,
  parameter POLY_SZ   = COEFF_SZ * KYBER_N
)(
  input                     clk,
	input                     reset_n,
	input                     enable,
  input      [3:0]          select,
  input      [POLY_SZ-1:0]  i_Poly,
  output reg [POLY_SZ-1:0]  o_Poly,
  output reg [POLY_SZ-1:0]  result_fixed,
  output reg                Poly_INTT_done
);

localparam LOG2_N = $clog2(KYBER_N);

// reg [COEFF_SZ-1:0] r [KYBER_N-1:0];

reg [3:0] stage;
reg [6:0] k;
reg [7:0] j;
reg [8:0] i, start;
reg       update, P0_reduce_enable, P1_reduce_enable;

wire [COEFF_SZ-1:0] zetas[127:0];

wire [7:0]  len, j_plus_len;
wire        P0_reduce_done, P1_reduce_done;
wire        P0_reduce_ack, P1_reduce_ack;

wire signed [COEFF_SZ-1:0] zetas_k, r_j, r_j_plus_len;
wire signed [COEFF_SZ-1:0] P0_BarrettR_out, P0_MontgomeryR_out, P1_MontgomeryR_out;

reg [2:0] cstate, nstate;
localparam [2:0] IDLE      = 3'd0;
localparam [2:0] COMPUTE0  = 3'd1;
localparam [2:0] REDUCE0   = 3'd2;
localparam [2:0] COMPUTE1  = 3'd3;
localparam [2:0] REDUCE1   = 3'd4;
localparam [2:0] WAIT      = 3'd5;

// Index Computation:
// calculate the corresponding point's index j_plus_len to the j_th point
assign len        = 2 << stage;
assign j_plus_len = j + len;

assign zetas_k      = zetas[k];
assign r_j          = o_Poly[POLY_SZ-(j*COEFF_SZ)-1          -: COEFF_SZ];
assign r_j_plus_len = o_Poly[POLY_SZ-(j_plus_len*COEFF_SZ)-1 -: COEFF_SZ];

always @(posedge clk)
  if (!reset_n) cstate <= IDLE;
  else          cstate <= nstate;

always @(cstate, enable, stage, update, P0_reduce_done, P1_reduce_done, i) begin
  case (cstate)
    IDLE:       if (enable)             nstate = COMPUTE0;
                else                    nstate = IDLE;
    COMPUTE0:   if (stage == LOG2_N-1)  nstate = COMPUTE1;
                else if (update)        nstate = REDUCE0;
                else                    nstate = COMPUTE0;
    REDUCE0:    if (P0_reduce_done)     nstate = COMPUTE0;
                else                    nstate = REDUCE0;
    COMPUTE1:   if (i == 256)           nstate = IDLE;
                else                    nstate = REDUCE1;
    REDUCE1:    if (P1_reduce_done)     nstate = COMPUTE1;
                else                    nstate = REDUCE1;
    default:                            nstate = IDLE;
  endcase
end

always @(posedge clk, negedge reset_n) begin
  if (!reset_n) begin
    stage     <= 0;
    start     <= 0;
    j         <= 0;
    k         <= 0;
    i         <= 0;
    update    <= 0;
    P0_reduce_enable <= 0;
    P1_reduce_enable <= 0;
  end else begin
    case ({cstate,nstate})
      {IDLE,IDLE}: Poly_INTT_done <= 0;
      {IDLE,COMPUTE0}: begin
        // for (i=0; i < 256; i=i+1) begin
        //   r[i] <= i_Poly[4095-(i*16) -: 16];
        // end
        o_Poly <= i_Poly;
        stage  <= 0;
        start  <= 0;
        j      <= 0;
        k      <= 0;
      end
      {COMPUTE0,COMPUTE0}: begin
        // NTT Function:
        // if (stage < LOG2_N-1)
        if (start < KYBER_N) begin
          if (j < start + len) begin
            update           <= 1;
            P0_reduce_enable <= 1;
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
      {COMPUTE0,REDUCE0}: begin
        update           <= 0;
        P0_reduce_enable <= 0;
      end
      {REDUCE0,REDUCE0}: ;
      {REDUCE0,COMPUTE0}: begin
        // r[j]          <= P0_BarrettR_out;
        // r[j_plus_len] <= P0_MontgomeryR_out;
        o_Poly[POLY_SZ-(j*COEFF_SZ)-1          -: COEFF_SZ] <= P0_BarrettR_out;
        o_Poly[POLY_SZ-(j_plus_len*COEFF_SZ)-1 -: COEFF_SZ] <= P0_MontgomeryR_out;
        j                                                   <= j + 1;
      end
      {COMPUTE0,COMPUTE1}: begin
        update  <= 0;
        j       <= 0;
        i       <= 0;
      end
      {COMPUTE1,REDUCE1}: begin
        P1_reduce_enable  <= 1;
      end
      {REDUCE1,REDUCE1}: begin
        // if (P1_reduce_ack) 
        P1_reduce_enable <= 0;
      end
      {REDUCE1,COMPUTE1}: begin
        o_Poly[POLY_SZ-(j*COEFF_SZ)-1 -: COEFF_SZ] <= P1_MontgomeryR_out;
        i                                          <= i + 1;
        j                                          <= j + 1; 
        // r[j]  <= P1_MontgomeryR_out;
      end
      {COMPUTE1,IDLE}: begin
        // for (index=0; index < 256; index = index + 1) begin
        //   o_Poly[4095-(index*16) -: 16] <= r[index];
        // end
        Poly_INTT_done <= 1;
      end
      default: ;
    endcase
  end
end

INVNTT_BarrettR_MontgomeryR P0 (
.clk(clk),
.ce(P0_reduce_enable),
.zeta_k(zetas_k),
.i_Coeffs_a(r_j),
.i_Coeffs_b(r_j_plus_len),
.o_Coeffs_a(P0_BarrettR_out),
.o_Coeffs_b(P0_MontgomeryR_out),
.ack(P0_reduce_ack),
.done(P0_reduce_done)
);

INVNTT_MontgomeryR P1 (
.clk(clk),
.ce(P1_reduce_enable),
.zeta_k(zetas_k),
.i_Coeffs(r_j),
.o_Coeffs(P1_MontgomeryR_out),
.ack(P1_reduce_ack),
.done(P1_reduce_done)
);

assign zetas[0]=16'd1701;
assign zetas[1]=16'd1807;
assign zetas[2]=16'd1460;
assign zetas[3]=16'd2371;
assign zetas[4]=16'd2338;
assign zetas[5]=16'd2333;
assign zetas[6]=16'd308;
assign zetas[7]=16'd108;
assign zetas[8]=16'd2851;
assign zetas[9]=16'd870;
assign zetas[10]=16'd854;
assign zetas[11]=16'd1510;
assign zetas[12]=16'd2535;
assign zetas[13]=16'd1278;
assign zetas[14]=16'd1530;
assign zetas[15]=16'd1185;
assign zetas[16]=16'd1659;
assign zetas[17]=16'd1187;
assign zetas[18]=16'd3109;
assign zetas[19]=16'd874;
assign zetas[20]=16'd1335;
assign zetas[21]=16'd2111;
assign zetas[22]=16'd136;
assign zetas[23]=16'd1215;
assign zetas[24]=16'd2945;
assign zetas[25]=16'd1465;
assign zetas[26]=16'd1285;
assign zetas[27]=16'd2007;
assign zetas[28]=16'd2719;
assign zetas[29]=16'd2726;
assign zetas[30]=16'd2232;
assign zetas[31]=16'd2512;
assign zetas[32]=16'd75;
assign zetas[33]=16'd156;
assign zetas[34]=16'd3000;
assign zetas[35]=16'd2911;
assign zetas[36]=16'd2980;
assign zetas[37]=16'd872;
assign zetas[38]=16'd2685;
assign zetas[39]=16'd1590;
assign zetas[40]=16'd2210;
assign zetas[41]=16'd602;
assign zetas[42]=16'd1846;
assign zetas[43]=16'd777;
assign zetas[44]=16'd147;
assign zetas[45]=16'd2170;
assign zetas[46]=16'd2551;
assign zetas[47]=16'd246;
assign zetas[48]=16'd1676;
assign zetas[49]=16'd1755;
assign zetas[50]=16'd460;
assign zetas[51]=16'd291;
assign zetas[52]=16'd235;
assign zetas[53]=16'd3152;
assign zetas[54]=16'd2742;
assign zetas[55]=16'd2907;
assign zetas[56]=16'd3224;
assign zetas[57]=16'd1779;
assign zetas[58]=16'd2458;
assign zetas[59]=16'd1251;
assign zetas[60]=16'd2486;
assign zetas[61]=16'd2774;
assign zetas[62]=16'd2899;
assign zetas[63]=16'd1103;
assign zetas[64]=16'd1275;
assign zetas[65]=16'd2652;
assign zetas[66]=16'd1065;
assign zetas[67]=16'd2881;
assign zetas[68]=16'd725;
assign zetas[69]=16'd1508;
assign zetas[70]=16'd2368;
assign zetas[71]=16'd398;
assign zetas[72]=16'd951;
assign zetas[73]=16'd247;
assign zetas[74]=16'd1421;
assign zetas[75]=16'd3222;
assign zetas[76]=16'd2499;
assign zetas[77]=16'd271;
assign zetas[78]=16'd90;
assign zetas[79]=16'd853;
assign zetas[80]=16'd1860;
assign zetas[81]=16'd3203;
assign zetas[82]=16'd1162;
assign zetas[83]=16'd1618;
assign zetas[84]=16'd666;
assign zetas[85]=16'd320;
assign zetas[86]=16'd8;
assign zetas[87]=16'd2813;
assign zetas[88]=16'd1544;
assign zetas[89]=16'd282;
assign zetas[90]=16'd1838;
assign zetas[91]=16'd1293;
assign zetas[92]=16'd2314;
assign zetas[93]=16'd552;
assign zetas[94]=16'd2677;
assign zetas[95]=16'd2106;
assign zetas[96]=16'd1571;
assign zetas[97]=16'd205;
assign zetas[98]=16'd2918;
assign zetas[99]=16'd1542;
assign zetas[100]=16'd2721;
assign zetas[101]=16'd2597;
assign zetas[102]=16'd2312;
assign zetas[103]=16'd681;
assign zetas[104]=16'd130;
assign zetas[105]=16'd1602;
assign zetas[106]=16'd1871;
assign zetas[107]=16'd829;
assign zetas[108]=16'd2946;
assign zetas[109]=16'd3065;
assign zetas[110]=16'd1325;
assign zetas[111]=16'd2756;
assign zetas[112]=16'd1861;
assign zetas[113]=16'd1474;
assign zetas[114]=16'd1202;
assign zetas[115]=16'd2367;
assign zetas[116]=16'd3147;
assign zetas[117]=16'd1752;
assign zetas[118]=16'd2707;
assign zetas[119]=16'd171;
assign zetas[120]=16'd3127;
assign zetas[121]=16'd3042;
assign zetas[122]=16'd1907;
assign zetas[123]=16'd1836;
assign zetas[124]=16'd1517;
assign zetas[125]=16'd359;
assign zetas[126]=16'd758;
assign zetas[127]=16'd1441;

// DEBUG:
always @(*) begin
  case(select)
    4'h0: result_fixed <= 4096'h068ff9edfe98069efaa80201fe6903eefe5203e6062a0274010d0641018e044bf9cf0245ff38feee02b1fe6605b8028f0074fc4dfb39f9da064dfe6cfbfa0673ffc103b5fb240518060002060299fa2e004e043304f0ff8c0465068dfc7ffcdcfe6702fdfd1e009701f404d50109fdf2ff10016404adfca1053b040206aa01450557fa7bfb99fd23069e03300402048803d3fcbe03cf032e021102e20023fc48043dfdba007a0611015a04b7000001c9fbcf05bafc6501dd0485fe36fca404c803bd0472f9fbfcc20536fd56fc65f9e4fecd0072fc3b0292f9f9fe40fbd8fb3002370373fa4201ca0441ff4b0076fbc503a7fdb603d506750634fcb8fa6405affc9aff3dfeadfe6c04cb01f1feeffaa2001e0523f9d500ed031c008a0263fafefe69fb4e052905b4ffd1fdd6fc03fe3cff7000d4fffaffc305c9fd14fcd6f9beff7efdb90262034c036b05fc05ff053efedafb15fcbc0490fa36063506070535fec2fae5ff7dfb77fb86fe320484f99e0391ff1dffb105c8fa8cff3b044005c2fa6afd02fb6c054c032f027f04a3ff1303710052fd5dffbb061b02e7fe31ff21fcba0475fd2affc4fd47ff560140ff54048f0228feb3fca40085ff9bf975fce6fa1f02fefcf00670fe19fc99024afc8c00a502ac059b03dbfca20336facefeedfdcd0313066200b2005b0065063303fb001afbd4fb6f0262050d05ed0407facd;
    4'h1: result_fixed <= 4096'h0229066105eb0455016c0592fbe102a3ffccfc27fb1e02d906330304fa7f047f00b6fdae0463fa3bfbfefb5dffbd023c061ffeb601ca01f0041502360217012f01d00652fa2dfb3405fbfdb0fb83fabffca1fee2026f05b7007b05a9037cfa89fc9a01acfae6036efaac0031048f020f05cafe2b0343ffd404b0fed30296fb33fa7e00a6fb1f0359063304320676fd72fd94fdd7060bff23065dfdc6005605380361fcf4fac70669fd6a0237fc1ffec402740531f9dd0543f9f40101fd3bfb46ffba0189ff9b00f1fb62febefb7c0617ff11fdbf0006fe640442fe1000e5fb01fd2df9fd0676fd640022f9e3022501b4fa070360050005a2fb92050d064cfd92fad0ffa8fa5cfa32f9eafc3d00330251fd5803d802ec0059fe57fbe5fa9efae502470271fdd4fa5505c8feccfc2bfffbfbc0fdbdfe3dfb3afdfa013803a805de012cfe010164fa7e04a10208fa55063c01d3fb7aff08020904a603ca0067feb0f9ccff57fad202ddfd48fa3eff36fce3fa0f05980186fced05470071fcc902f4ffcffcd7fe76ff3ffd72041905e0054dfad3fc89039efb3efac50032ff76033ffbf0fe93fdd20283ff6b017f0510fe30fa8a02940503ffe802deff4100e403b702a3fece01ad05c8fdbd0547fdf7fb6a01b405670325052d05b9faeefaf80201043402cd025a00eefebdfdba0167fd20035fff9afe3df98d02a0fa4200f3ff69;
    4'h2: result_fixed <= 4096'h00680482f9920623fb1905c1fce2fd3805dafe5b059a00e9fc9801530193fb6f0593056d05d70298fa06fb7506080455fa2effdcfbd7068602f9f9aafe2d0133063efffafcd103c7047b000ffd4b06aa019efd8403d5fff901c1fcf00036fdcefe6b03fbfe2c051c058502d7fafafdcefb19065ffb6d031f021c0248055e011cfb8d05c0fc36fa47fc5e0401fc3cfdaf00c6fa400366fb85fceefe5ffeef0326fbe601f00270049dfff0009b045c0147fd64fab0028fffe70262067405c204dbff790346fdafffbffcc8fcb40391067803350668fcaef9caff84034f027501480050fa94fabf0316016e0689f9c300adfa13fae7fbbefc8804ad03cafa1efa3efa60fbbb01bdfb82f9aefdbffbaa049ef9f8055c0100fe56039104f20612f9e4fc6b036f0233f9b8fdc6fb5cfbc4f9f8fc4bfa1b065804bdfc05fae004ee01d800dc05da03d6029cfb3e031bfd8bfe4bfc94fe2804ccfdb2fa7efc0efdbfff7bfbb40198025700b30552fb3c04de000500fafee7fae2fb0402cafaff0212003a031b01b3fc370639fbd8010ffdb103d0fd15fcecfbd5ff0f045902dd056000f1f9e8047d015905d4faf200c605f4fd730543036c01eafa5900bffe990346facc00cffecc0193036005f401e5fc5a013900aa02f9fbf4063ffe1b04fafce803abf9eefdacfc05ff7cfa20fc140473fabc006f0068fbe20622fd85fe1f030405a7;
    default: ;
  endcase;
end

endmodule