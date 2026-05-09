module S_AXI_WRITE #(
    // ADDRESS & DATA
    parameter GLOB_ADDR_WIDTH     = 32, // Address width for AXI interface
    parameter GLOB_DATA_WIDTH     = 32, // Data width for AXI interface
    // BANK 0
    parameter BANK0_CONTROL_WIDTH = 4,
    parameter BANK0_STATE_BIT_LEN = 4,
    parameter BANK0_QUERY_BIT_LEN = 32,
    // BANK 1
    parameter BANK1_INDEX_WIDTH          =  3, // 2 ^ 2 = 4 slots
    parameter BANK1_DATA_ADDR_WIDTH      = 32, // <---- DATA FROM DMA START ADDR
    parameter BANK1_DATA_SIZE_WIDTH      = 26,
    parameter BANK1_RM_SELECT_WIDTH      = 2, // it should be n(vs) x n(rm perslot)
    parameter BANK1_PROFILE_RECON_WIDTH  = 32, // <---- PROFILER RECON
    parameter BANK1_PROFILE_EXEC_WIDTH   = 32, // <---- PROFILER EXEC
    parameter BANK1_DATA_POOL_MASK_WIDTH =  8 // <---- MASK OF MGS and DMA
)(
    input  wire                        clk,
    input  wire                        nreset,

    // AXI Lite Write Address Channel
    input  wire [GLOB_ADDR_WIDTH-1:0]  S_AXI_AWADDR,
    input  wire                        S_AXI_AWVALID,
    output wire                        S_AXI_AWREADY,

    // AXI Lite Write Data Channel
    input  wire [GLOB_DATA_WIDTH-1:0]     S_AXI_WDATA,
    input  wire [(GLOB_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                           S_AXI_WVALID,
    output wire                           S_AXI_WREADY,

    // AXI Lite Write Response Channel
    output wire [1:0]                S_AXI_BRESP,
    output wire                      S_AXI_BVALID,
    input  wire                      S_AXI_BREADY,

    output reg [GLOB_ADDR_WIDTH    -1: 0] b1_write_address_val,

    //// bank0 interconnect
    output wire [BANK0_CONTROL_WIDTH -1: 0] b0_control_cmd_send_val        , output reg b0_control_cmd_send_req,       // actually it is wire but we want to put it into always block
    output wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_send_val       , output reg b0_last_session_send_req,      // actually it is wire but we want to put it into always block
    output wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_send_val          , output reg b0_amt_query_send_req,         // actually it is wire but we want to put it into always block
    output wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_send_val , output reg b0_amt_query_per_iter_send_req,// actually it is wire but we want to put it into always block
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_send_val        , output reg b0_load_offset_send_req,       // actually it is wire but we want to put it into always block
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_send_val       , output reg b0_store_offset_send_req,      // actually it is wire but we want to put it into always block
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_send_val        , output reg b0_dma_ip_addr_send_req,       // actually it is wire but we want to put it into always block
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_pr_ip_addr_send_val         , output reg b0_pr_ip_addr_send_req,        // actually it is wire but we want to put it into always block
    output wire                             b0_intr_ena_send_val           , output reg b0_intr_ena_send_req,          // actually it is wire but we want to put it into always block

    //// bank1 interconnect

    output  wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_src_addr_send_val       , output  reg  b1_dma_src_addr_send_req,       // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_src_size_send_val       , output  reg  b1_dma_src_size_send_req,       // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_des_addr_send_val       , output  reg  b1_dma_des_addr_send_req,       // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_des_size_send_val       , output  reg  b1_dma_des_size_send_req,       // actually it is wire but we want to put it into always block
    output  wire [BANK1_PROFILE_RECON_WIDTH   -1: 0] b1_prof_recon_send_val         , output  reg  b1_prof_recon_send_req,         // actually it is wire but we want to put it into always block
    output  wire [BANK1_PROFILE_EXEC_WIDTH    -1: 0] b1_prof_exec_send_val          , output  reg  b1_prof_exec_send_req,          // actually it is wire but we want to put it into always block
    output  wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_recon_select_send_val , output  reg  b1_vs_rm_recon_select_send_req, // actually it is wire but we want to put it into always block
    output  wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_exec_select_send_val  , output  reg  b1_vs_rm_exec_select_send_req,  // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_load_mask_send_val          , output  reg  b1_load_mask_send_req,          // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_store_mask_send_val         , output  reg  b1_store_mask_send_req,         // actually it is wire but we want to put it into always block
    output  wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_complete_mask_send_val      , output  reg  b1_complete_mask_send_req,      // actually it is wire but we want to put it into always block
    output  wire [BANK1_INDEX_WIDTH           -1: 0] b1_next_session_send_val       , output  reg  b1_next_session_send_req        // actually it is wire but we want to put it into always block
);


always @(*)begin
    case(S_AXI_WSTRB)
        default: begin end
    endcase
end



localparam ST_IDLE = 3'b000;
localparam ST_DATA = 3'b001;
localparam ST_RESP = 3'b010;

reg [2:0] state;

////////// main control state machine

always @(posedge clk or negedge nreset ) begin

    if (~nreset) begin
        state <= ST_IDLE;
        b1_write_address_val <= 0;
    end else begin
        case (state)
            ST_IDLE: begin
                if (S_AXI_AWVALID) begin
                    b1_write_address_val <= S_AXI_AWADDR;
                    state <= ST_DATA;
                end
            end

            ST_DATA: begin
                if (S_AXI_WVALID) begin
                    // Here you would typically write the data to the appropriate register or memory location
                    // For this example, we just move to the response state
                    state <= ST_RESP;
                end
            end

            ST_RESP: begin
                if (S_AXI_BREADY) begin
                    state <= ST_IDLE; // Go back to idle after response is acknowledged
                end
            end

            default: state <= ST_IDLE; // Default case to avoid latches

        endcase
    end

end

assign S_AXI_AWREADY = (state == ST_IDLE);
assign S_AXI_WREADY  = (state == ST_DATA);
assign S_AXI_BRESP   = 2'b00; // OKAY response
assign S_AXI_BVALID  = (state == ST_RESP);

/////////// writing to bank1 wiring

/////////// bank1 data wiring

assign b1_dma_src_addr_send_val       =  S_AXI_WDATA[BANK1_DATA_ADDR_WIDTH       -1: 0];
assign b1_dma_src_size_send_val       =  S_AXI_WDATA[BANK1_DATA_SIZE_WIDTH       -1: 0];
assign b1_dma_des_addr_send_val       =  S_AXI_WDATA[BANK1_DATA_ADDR_WIDTH       -1: 0];
assign b1_dma_des_size_send_val       =  S_AXI_WDATA[BANK1_DATA_SIZE_WIDTH       -1: 0];
assign b1_prof_recon_send_val         =  S_AXI_WDATA[BANK1_PROFILE_RECON_WIDTH   -1: 0];
assign b1_prof_exec_send_val          =  S_AXI_WDATA[BANK1_PROFILE_EXEC_WIDTH    -1: 0];
assign b1_vs_rm_recon_select_send_val =  S_AXI_WDATA[BANK1_RM_SELECT_WIDTH       -1: 0];
assign b1_vs_rm_exec_select_send_val  =  S_AXI_WDATA[BANK1_RM_SELECT_WIDTH       -1: 0];
assign b1_load_mask_send_val          =  S_AXI_WDATA[BANK1_DATA_POOL_MASK_WIDTH  -1: 0];
assign b1_store_mask_send_val         =  S_AXI_WDATA[BANK1_DATA_POOL_MASK_WIDTH  -1: 0];
assign b1_complete_mask_send_val      =  S_AXI_WDATA[BANK1_DATA_POOL_MASK_WIDTH  -1: 0];
assign b1_next_session_send_val       =  S_AXI_WDATA[BANK1_INDEX_WIDTH           -1: 0];


//////////// bank0 data wiring

assign b0_control_cmd_send_val        = S_AXI_WDATA[BANK0_CONTROL_WIDTH -1: 0];
assign b0_last_session_send_val       = S_AXI_WDATA[BANK1_INDEX_WIDTH   -1: 0];
assign b0_amt_query_send_val          = S_AXI_WDATA[BANK0_QUERY_BIT_LEN -1: 0];
assign b0_amt_query_per_iter_send_val = S_AXI_WDATA[BANK0_QUERY_BIT_LEN -1: 0];
assign b0_load_offset_send_val        = S_AXI_WDATA[GLOB_ADDR_WIDTH     -1: 0];
assign b0_store_offset_send_val       = S_AXI_WDATA[GLOB_ADDR_WIDTH     -1: 0];
assign b0_dma_ip_addr_send_val        = S_AXI_WDATA[GLOB_ADDR_WIDTH     -1: 0];
assign b0_pr_ip_addr_send_val         = S_AXI_WDATA[GLOB_ADDR_WIDTH     -1: 0];
assign b0_intr_ena_send_val           = S_AXI_WDATA;




/////////// block control write signals

always @(*) begin

    b0_control_cmd_send_req        = 0;
    b0_last_session_send_req       = 0;
    b0_amt_query_send_req          = 0;
    b0_amt_query_per_iter_send_req = 0;
    b0_load_offset_send_req        = 0;
    b0_store_offset_send_req       = 0;
    b0_dma_ip_addr_send_req        = 0;
    b0_pr_ip_addr_send_req         = 0;
    b0_intr_ena_send_req           = 0;


    b1_dma_src_addr_send_req       = 0;
    b1_dma_src_size_send_req       = 0;
    b1_dma_des_addr_send_req       = 0;
    b1_dma_des_size_send_req       = 0;
    b1_prof_recon_send_req         = 0;
    b1_prof_exec_send_req          = 0;
    b1_vs_rm_recon_select_send_req = 0;
    b1_vs_rm_exec_select_send_req  = 0;
    b1_load_mask_send_req          = 0;
    b1_store_mask_send_req         = 0;
    b1_complete_mask_send_req      = 0;
    b1_next_session_send_req       = 0;


    if (state == ST_DATA) begin
        case (b1_write_address_val[15:14])
            2'b00: begin
                case (b1_write_address_val[13:6]) // Address bits 13 to 6 determine the slot

                    8'h00: begin b0_control_cmd_send_req        = 1; end
                    // 8'h01:       main state
                    // 8'h02:       recon state
                    // 8'h03:       exec state
                    8'h04: begin b0_last_session_send_req       = 1; end
                    // 8'h05:        cur query
                    8'h06: begin b0_amt_query_send_req          = 1; end
                    8'h07: begin b0_amt_query_per_iter_send_req = 1; end
                    8'h08: begin b0_dma_ip_addr_send_req        = 1; end
                    8'h09: begin b0_pr_ip_addr_send_req         = 1; end
                    8'h0A: begin b0_intr_ena_send_req           = 1; end
                    // 8'h0B:       intr status
                    default: begin end
                endcase
            end

            2'b01: begin
                case (b1_write_address_val[5:2]) // Address bits 5 to 2 determine the slot
                    4'b0000: begin b1_dma_src_addr_send_req       = 1; end
                    4'b0001: begin b1_dma_src_size_send_req       = 1; end
                    4'b0010: begin b1_dma_des_addr_send_req       = 1; end
                    4'b0011: begin b1_dma_des_size_send_req       = 1; end
                    4'b0100: begin b1_prof_recon_send_req         = 1; end
                    4'b0101: begin b1_prof_exec_send_req          = 1; end
                    4'b0110: begin b1_vs_rm_recon_select_send_req = 1; end
                    4'b0111: begin b1_vs_rm_exec_select_send_req  = 1; end
                    4'b1000: begin b1_load_mask_send_req          = 1; end
                    4'b1001: begin b1_store_mask_send_req         = 1; end
                    4'b1010: begin b1_complete_mask_send_req      = 1; end
                    4'b1011: begin b1_next_session_send_req       = 1; end
                    default: begin end
                endcase
            end

            default: begin end
        endcase
    end

end

endmodule
