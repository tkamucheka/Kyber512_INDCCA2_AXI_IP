//////////////////////////////////////////////////////////////////////////////////
// Module Name: State_Add
// Project Name: Kyber512_AC701
// Target Devices: AC701
// Author: YIMING,HUANG
//////////////////////////////////////////////////////////////////////////////////

module State_Add#(
  parameter KYBER_K = 2,
  parameter KYBER_N = 256,
  parameter KYBER_Q = 3329,
  parameter i_INTT_bpv_Length = 128,
  parameter i_e_Length = 32,
  parameter i_k_Length = 96,
  parameter o_Add_BRAM_Length = 128
)(
	input clk,		
	input rst_n,
	input enable,
	input [i_INTT_bpv_Length-1 : 0] INTT_Enc_BpV_DecMp_RData,
	input [i_e_Length-1 : 0] eG_RData,
	input [i_k_Length-1 : 0] k_RData,	
	output reg [6 : 0] INTT_Enc_BpV_DecMp_RAd, //// 0-31 EncV/DecMp, 32-63 EncBp0, 64-95 EncBp1
	output reg [6 : 0] eG_RAd,
	output reg [4 : 0] k_RAd,  
    output reg Function_done,
    output reg Add_EncBp_DecMp_outready,
    output reg [7 : 0] Add_EncBp_DecMp_WAd, // 0-31 EncBp0 DecMp, 32-63 EncBp1
    output reg [128-1 : 0] Add_EncBp_DecMp_WData
); 

wire [o_Add_BRAM_Length-1 : 0] P0_oCoeffs;
wire [o_Add_BRAM_Length-1 : 0] P1_oCoeffs;

reg get;

reg [2:0] cstate,nstate;
localparam IDLE		      = 3'd0;
localparam Pop_bp_ep_0  = 3'd1;
localparam Push_bp_ep_0 = 3'd2;
localparam Pop_bp_ep_1  = 3'd3;
localparam Push_bp_ep_1 = 3'd4;
localparam Pop_v_epp_k  = 3'd5;
localparam Push_v_epp_k = 3'd6;


always @(posedge clk/* or negedge rst_n*/)
	if(!rst_n) cstate <= IDLE;
	else       cstate <= nstate;

always @(cstate or enable  or Add_EncBp_DecMp_WAd or get) begin
// always @(posedge clk) begin
	case(cstate)
		IDLE: 	      if(enable)    nstate <= Pop_bp_ep_0;
				          else          nstate <= IDLE;
		Pop_bp_ep_0:  if(get == 1)  nstate <= Push_bp_ep_0;
		              else          nstate <= Pop_bp_ep_0;		       
		Push_bp_ep_0: if(Add_EncBp_DecMp_WAd == 31) 
                                nstate <= Pop_bp_ep_1;
		              else          nstate <= Pop_bp_ep_0;
		Pop_bp_ep_1:  if (get == 1) nstate <= Push_bp_ep_1;
		              else          nstate <= Pop_bp_ep_1;
		Push_bp_ep_1: if(Add_EncBp_DecMp_WAd == 63) 
                                nstate <= Pop_v_epp_k;
		              else          nstate <= Pop_bp_ep_1;		                
		Pop_v_epp_k:  if (get == 1) nstate <= Push_v_epp_k;
		              else          nstate <= Pop_v_epp_k;
		Push_v_epp_k: if(Add_EncBp_DecMp_WAd == 95) 
                                nstate <= IDLE;
		              else          nstate <= Pop_v_epp_k;
		default:                    nstate <= IDLE;
  endcase
end

always @(posedge clk/* or negedge rst_n*/)										
	if(!rst_n) begin
    // INTT_Enc_BpV_DecMp_RAd   <= 0;
    // eG_RAd                   <= 0;
    // k_RAd                    <= 0;   
    Function_done            <= 0;
    Add_EncBp_DecMp_outready <= 0;
    Add_EncBp_DecMp_WAd      <= 0;
    Add_EncBp_DecMp_WData    <= 0;
    get                      <= 0;
  end else begin
		case({cstate,nstate})
			{IDLE,IDLE}: begin
          Add_EncBp_DecMp_outready <= 1'b0;
					Function_done <=  1'b0;
					Add_EncBp_DecMp_WData <= 0;
          INTT_Enc_BpV_DecMp_RAd   <= 7'hx;
          eG_RAd                   <= 7'hx;
          k_RAd                    <= 5'hx;
        end
			{IDLE,Pop_bp_ep_0}:begin
          // BUG: incorrect ordering
          // INTT_Enc_BpV_DecMp_RAd <= 64;			        
          INTT_Enc_BpV_DecMp_RAd <= 63;
          eG_RAd                 <= 0;
          Add_EncBp_DecMp_WAd    <= -1;
          get                    <= 0;              
        end				       			
			{Pop_bp_ep_0,Pop_bp_ep_0}: begin			        
          get <= 1;                                   
        end	
			{Pop_bp_ep_0,Push_bp_ep_0}: begin			        
          Add_EncBp_DecMp_outready <= 1'b1;
          Add_EncBp_DecMp_WAd      <= Add_EncBp_DecMp_WAd + 1;
          Add_EncBp_DecMp_WData    <= P0_oCoeffs;
        end
			{Push_bp_ep_0,Pop_bp_ep_0}: begin
          // BUG: incorrect ordering
          // INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd + 1;
          INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd - 1;
          eG_RAd                 <= eG_RAd + 1;
          get                    <= 0;           
        end            
			{Push_bp_ep_0,Pop_bp_ep_1}: begin			        
          Add_EncBp_DecMp_outready <= 1'b1;
          Add_EncBp_DecMp_WData    <= P0_oCoeffs;
          // BUG: incorrect ordering
          // INTT_Enc_BpV_DecMp_RAd <= 32;
          INTT_Enc_BpV_DecMp_RAd   <= 95;
          eG_RAd                   <= 32;
          get                      <= 0;
        end			       			
			{Pop_bp_ep_1,Pop_bp_ep_1}:begin			        
          get <= 1;                                   
        end	
			{Pop_bp_ep_1,Push_bp_ep_1}:begin			        
          Add_EncBp_DecMp_outready <= 1'b1;
          Add_EncBp_DecMp_WAd      <= Add_EncBp_DecMp_WAd + 1;
          Add_EncBp_DecMp_WData    <= P0_oCoeffs;
        end
			{Push_bp_ep_1,Pop_bp_ep_1}:begin
          // BUG: incorrect ordering        
          // INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd + 1;
          INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd - 1;
          eG_RAd                 <= eG_RAd + 1;
          get                    <= 0;                       
        end				                
			{Push_bp_ep_1,Pop_v_epp_k}:begin			        
          Add_EncBp_DecMp_outready <= 1'b1;
          Add_EncBp_DecMp_WData    <= P0_oCoeffs;
          // BUG: incorrect ordering 
          // INTT_Enc_BpV_DecMp_RAd   <= 0;
          INTT_Enc_BpV_DecMp_RAd   <= 31;
          eG_RAd                   <= 64;
          // k_RAd                    <= 0;
          k_RAd                    <= 31;
          get                      <= 0;  
        end			       			
			{Pop_v_epp_k,Pop_v_epp_k}:begin			        
          get <= 1;                            
        end
			{Pop_v_epp_k,Push_v_epp_k}:begin			        
          Add_EncBp_DecMp_outready <= 1'b1;
          Add_EncBp_DecMp_WAd <= Add_EncBp_DecMp_WAd + 1;
          Add_EncBp_DecMp_WData <= P1_oCoeffs;
        end
			{Push_v_epp_k,Pop_v_epp_k}:begin
          // BUG: incorrect ordering 		        
          // INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd + 1;
          INTT_Enc_BpV_DecMp_RAd <= INTT_Enc_BpV_DecMp_RAd - 1;
          eG_RAd                 <= eG_RAd + 1;
          // k_RAd                  <= k_RAd + 1;
          k_RAd                  <= k_RAd - 1;          
          get                    <= 0;                          
        end				                
			{Push_v_epp_k,IDLE}:begin			        
          Add_EncBp_DecMp_outready <= 1'b0;
          Add_EncBp_DecMp_WData    <= P1_oCoeffs;
          INTT_Enc_BpV_DecMp_RAd   <= 0;
          eG_RAd                   <= 0;
          k_RAd                    <= 0; 
          Function_done            <= 1'b1;
          Add_EncBp_DecMp_WAd      <= 0;
          get                      <= 0; 
        end		
			default: ;
    endcase
  end
		
State_Add__Add_2 P0(
.iCoeffs_a(INTT_Enc_BpV_DecMp_RData),
.iCoeffs_b(eG_RData),
.oCoeffs(P0_oCoeffs)
);		

State_Add__Add_3 P1(
.iCoeffs_a(INTT_Enc_BpV_DecMp_RData),
.iCoeffs_b(eG_RData),
.iCoeffs_c(k_RData),
.oCoeffs(P1_oCoeffs)
);	
		
endmodule		
