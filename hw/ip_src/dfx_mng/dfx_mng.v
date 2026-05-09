module DFX_Mng #(
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
    parameter BANK1_DATA_POOL_MASK_WIDTH =  8, // <---- MASK OF MGS and DMA
    // DMA CONTROL PARAMETER
    parameter DMA_INIT_TASK_CNT   = 8, //// (reset interrupt + startReadChannel + baseAddr0 + size0) + (startWriteChannel + baseAddr1 + size1)
    parameter DMA_EXEC_TASK_CNT   = 1,
    // PR  CONTROL PARAMETER
    parameter PR_CTRL_TASK_CNT    = 2  //// (set batch_size + ap_start)
) (

input wire clk,
input  wire nreset,

// ==========================================
// AXI-LITE (connect with processor) ========
// ==========================================

// Read Address Channel
input  wire [GLOB_ADDR_WIDTH-1:0]      S_AXI_ARADDR,
input  wire                            S_AXI_ARVALID,
output wire                            S_AXI_ARREADY,
// Read Data Channel
output wire [GLOB_DATA_WIDTH-1:0]      S_AXI_RDATA, ////// read data output acctually it is a reg
output wire [1:0]                      S_AXI_RRESP,
output wire                            S_AXI_RVALID,
input  wire                            S_AXI_RREADY,
// Write Address Channel
input  wire [GLOB_ADDR_WIDTH-1:0]      S_AXI_AWADDR,
input  wire                            S_AXI_AWVALID,
output wire                            S_AXI_AWREADY,
// Write Data Channel
input  wire [GLOB_DATA_WIDTH    -1:0]  S_AXI_WDATA,
input  wire [(GLOB_DATA_WIDTH/8)-1:0]  S_AXI_WSTRB,
input  wire                            S_AXI_WVALID,
output wire                            S_AXI_WREADY,
// Write Resp Channel
output wire [1:0]                      S_AXI_BRESP,
output wire                            S_AXI_BVALID,
input  wire                            S_AXI_BREADY,

// ==========================================
// AXI-LITE (connect with DMA IP) ===========
// ==========================================

// Read Address Channel
output  wire [GLOB_ADDR_WIDTH-1:0]    M_AXI_ARADDR,
output  wire                          M_AXI_ARVALID,
input   wire                          M_AXI_ARREADY,
// Read Data Channel
input   wire  [GLOB_ADDR_WIDTH-1:0]   M_AXI_RDATA, ////// read data output acctually it is a reg
input   wire  [1:0]                   M_AXI_RRESP,
input   wire                          M_AXI_RVALID,
output  wire                          M_AXI_RREADY,
// Write Address Channel
output  wire [GLOB_ADDR_WIDTH-1:0]    M_AXI_AWADDR, ///// actually it is wire
output  wire                          M_AXI_AWVALID,
input   wire                          M_AXI_AWREADY,
// Write Data Channel
output  wire[GLOB_DATA_WIDTH-1:0]     M_AXI_WDATA, ///// actually it is wire
output  wire[(GLOB_DATA_WIDTH/8)-1:0] M_AXI_WSTRB,
output  wire                          M_AXI_WVALID,
input   wire                          M_AXI_WREADY,
// Write Resp Channel
input  wire [1:0]                     M_AXI_BRESP,
input  wire                           M_AXI_BVALID,
output wire                           M_AXI_BREADY,

// ==========================================
// DFX CTRL                       ===========
// ==========================================

output wire[BANK1_RM_SELECT_WIDTH     -1: 0] dfx_rm_program, /// former slaveReprog
input  wire[BANK1_RM_SELECT_WIDTH     -1: 0] dfx_rm_nreset,   /// former nslaveReset

// ==========================================
// DFX STREAMER Control
// ==========================================

output wire[BANK1_DATA_POOL_MASK_WIDTH-1: 0] dfx_stream_store_reset,
output wire[BANK1_DATA_POOL_MASK_WIDTH-1: 0] dfx_stream_load_reset,
output wire[BANK1_DATA_POOL_MASK_WIDTH-1: 0] dfx_stream_store_init,
output wire[BANK1_DATA_POOL_MASK_WIDTH-1: 0] dfx_stream_load_init,

input  wire[BANK1_DATA_POOL_MASK_WIDTH-1: 0] dfx_stream_fin,

// ========================================================
// DFX STREAMER Control (Declare here for debuggin purpose)
// ========================================================

output wire[DMA_INIT_TASK_CNT  -1:0]    dma_init_task,
output wire[DMA_INIT_TASK_CNT  -1:0]    dma_fin_task,

output wire[PR_CTRL_TASK_CNT   -1:0]    pr_ctrl_task,
output wire[PR_CTRL_TASK_CNT   -1:0]    pr_ctrl_fin_task

);

/////////////////////////////////////////////////
/////// INTERNAL WIRING IN CORE PERSPECTIVE  ////
/////////////////////////////////////////////////

//////// BANK 0 READ
wire [BANK0_STATE_BIT_LEN -1: 0] b0_main_state_read_val;
wire [BANK0_STATE_BIT_LEN -1: 0] b0_recon_state_read_val;
wire [BANK0_STATE_BIT_LEN -1: 0] b0_exec_state_read_val;
wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_read_val;
wire [BANK0_QUERY_BIT_LEN -1: 0] b0_cur_query_read_val;
wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_read_val;
wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_read_val;
wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_read_val;
wire [GLOB_ADDR_WIDTH     -1: 0] b0_pr_ip_addr_read_val;
wire                             b0_intr_ena_read_val;
wire                             b0_intr_status_read_val;
    //////// BANK 0 WRITE
wire [BANK0_CONTROL_WIDTH -1: 0] b0_control_cmd_write_val        ; input wire b0_control_cmd_write_req       ;
wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_write_val       ; input wire b0_last_session_write_req      ;
wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_write_val          ; input wire b0_amt_query_write_req         ;
wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_write_val ; input wire b0_amt_query_per_iter_write_req;
wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_write_val        ; input wire b0_dma_ip_addr_write_req       ;
wire [GLOB_ADDR_WIDTH     -1: 0] b0_pr_ip_addr_write_val         ; input wire b0_pr_ip_addr_write_req        ;
wire                             b0_intr_ena_write_val           ; input wire b0_intr_ena_write_req          ;
    //////// BANK 1 READ
wire                         b1_read_indexer_req;
wire [GLOB_ADDR_WIDTH -1: 0] b1_read_address_val;

wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_src_addr_read_val       ;
wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_src_size_read_val       ;
wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_des_addr_read_val       ;
wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_des_size_read_val       ;
wire [BANK1_PROFILE_RECON_WIDTH   -1: 0] b1_prof_recon_read_val         ;
wire [BANK1_PROFILE_EXEC_WIDTH    -1: 0] b1_prof_exec_read_val          ;
wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_recon_select_read_val ;
wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_exec_select_read_val  ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_load_mask_read_val          ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_store_mask_read_val         ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_complete_mask_read_val      ;
wire [BANK1_INDEX_WIDTH           -1: 0] b1_next_session_read_val       ;

    //////////// BANK 1 WRITE
wire [GLOB_ADDR_WIDTH-1             : 0] b1_write_address_val;

wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_src_addr_write_val      ; wire  b1_dma_src_addr_write_req      ;
wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_src_size_write_val      ; wire  b1_dma_src_size_write_req      ;
wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_des_addr_write_val      ; wire  b1_dma_des_addr_write_req      ;
wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_des_size_write_val      ; wire  b1_dma_des_size_write_req      ;
wire [BANK1_PROFILE_RECON_WIDTH   -1: 0] b1_prof_recon_write_val        ; wire  b1_prof_recon_write_req        ;
wire [BANK1_PROFILE_EXEC_WIDTH    -1: 0] b1_prof_exec_write_val         ; wire  b1_prof_exec_write_req         ;
wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_recon_select_write_val; wire  b1_vs_rm_recon_select_write_req;
wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_exec_select_write_val ; wire  b1_vs_rm_exec_select_write_req ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_load_mask_write_val         ; wire  b1_load_mask_write_req         ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_store_mask_write_val        ; wire  b1_store_mask_write_req        ;
wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_complete_mask_write_val     ; wire  b1_complete_mask_write_req     ;
wire [BANK1_INDEX_WIDTH           -1: 0] b1_next_session_write_val      ; wire  b1_next_session_write_req      ;


/////////////////////////////////////////////////////////////
/////////// DFX MANAGER CORE ////////////////////////////////
/////////////////////////////////////////////////////////////

DFX_Mng_Core #(
        .GLOB_ADDR_WIDTH            (GLOB_ADDR_WIDTH),
        .GLOB_DATA_WIDTH            (GLOB_DATA_WIDTH),
        .BANK0_CONTROL_WIDTH        (BANK0_CONTROL_WIDTH),
        .BANK0_STATE_BIT_LEN        (BANK0_STATE_BIT_LEN),
        .BANK0_QUERY_BIT_LEN        (BANK0_QUERY_BIT_LEN),
        .BANK1_INDEX_WIDTH          (BANK1_INDEX_WIDTH),
        .BANK1_DATA_ADDR_WIDTH      (BANK1_DATA_ADDR_WIDTH),
        .BANK1_DATA_SIZE_WIDTH      (BANK1_DATA_SIZE_WIDTH),
        .BANK1_RM_SELECT_WIDTH      (BANK1_RM_SELECT_WIDTH),
        .BANK1_PROFILE_RECON_WIDTH  (BANK1_PROFILE_RECON_WIDTH),
        .BANK1_PROFILE_EXEC_WIDTH   (BANK1_PROFILE_EXEC_WIDTH),
        .BANK1_DATA_POOL_MASK_WIDTH (BANK1_DATA_POOL_MASK_WIDTH),
        .DMA_INIT_TASK_CNT          (DMA_INIT_TASK_CNT),
        .DMA_EXEC_TASK_CNT          (DMA_EXEC_TASK_CNT),
        .PR_CTRL_TASK_CNT           (PR_CTRL_TASK_CNT),
    ) dfx_mng_core (
        .clk    (clk),
        .nreset(nreset),
            //////// BANK 0 READ
        .b0_main_state_read_val        (b0_main_state_read_val),
        .b0_recon_state_read_val       (b0_recon_state_read_val),
        .b0_exec_state_read_val        (b0_exec_state_read_val),
        .b0_last_session_read_val      (b0_last_session_read_val),
        .b0_cur_query_read_val         (b0_cur_query_read_val),
        .b0_amt_query_read_val         (b0_amt_query_read_val),
        .b0_amt_query_per_iter_read_val(b0_amt_query_per_iter_read_val),
        .b0_dma_ip_addr_read_val       (b0_dma_ip_addr_read_val),
        .b0_pr_ip_addr_read_val        (b0_pr_ip_addr_read_val),
        .b0_intr_ena_read_val          (b0_intr_ena_read_val),
        .b0_intr_status_read_val       (b0_intr_status_read_val),
            //////// BANK 0 WRITE
        .b0_control_cmd_write_val       (b0_control_cmd_write_val)        , .b0_control_cmd_write_req        (b0_control_cmd_write_req),
        .b0_last_session_write_val      (b0_last_session_write_val)       , .b0_last_session_write_req       (b0_last_session_write_req),
        .b0_amt_query_write_val         (b0_amt_query_write_val)          , .b0_amt_query_write_req          (b0_amt_query_write_req),
        .b0_amt_query_per_iter_write_val(b0_amt_query_per_iter_write_val) , .b0_amt_query_per_iter_write_req (b0_amt_query_per_iter_write_req),
        .b0_dma_ip_addr_write_val       (b0_dma_ip_addr_write_val)        , .b0_dma_ip_addr_write_req        (b0_dma_ip_addr_write_req),
        .b0_pr_ip_addr_write_val        (b0_pr_ip_addr_write_val)         , .b0_pr_ip_addr_write_req         (b0_pr_ip_addr_write_req),
        .b0_intr_ena_write_val          (b0_intr_ena_write_val)           , .b0_intr_ena_write_req           (b0_intr_ena_write_req),
            //////// BANK 1 READ
        .b1_read_indexer_req(b1_read_indexer_req),
        .b1_read_address_val(b1_read_address_val),

        .b1_dma_src_addr_read_val       (b1_dma_src_addr_read_val),
        .b1_dma_src_size_read_val       (b1_dma_src_size_read_val),
        .b1_dma_des_addr_read_val       (b1_dma_des_addr_read_val),
        .b1_dma_des_size_read_val       (b1_dma_des_size_read_val),
        .b1_prof_recon_read_val         (b1_prof_recon_read_val),
        .b1_prof_exec_read_val          (b1_prof_exec_read_val),
        .b1_vs_rm_recon_select_read_val (b1_vs_rm_recon_select_read_val),
        .b1_vs_rm_exec_select_read_val  (b1_vs_rm_exec_select_read_val),
        .b1_load_mask_read_val          (b1_load_mask_read_val),
        .b1_store_mask_read_val         (b1_store_mask_read_val),
        .b1_complete_mask_read_val      (b1_complete_mask_read_val),
        .b1_next_session_read_val       (b1_next_session_read_val),

            //////////// BANK 1 WRITE
        .b1_write_address_val(b1_write_address_val),

        .b1_dma_src_addr_write_val      (b1_dma_src_addr_write_val)       , .b1_dma_src_addr_write_req      (b1_dma_src_addr_write_req),
        .b1_dma_src_size_write_val      (b1_dma_src_size_write_val)       , .b1_dma_src_size_write_req      (b1_dma_src_size_write_req),
        .b1_dma_des_addr_write_val      (b1_dma_des_addr_write_val)       , .b1_dma_des_addr_write_req      (b1_dma_des_addr_write_req),
        .b1_dma_des_size_write_val      (b1_dma_des_size_write_val)       , .b1_dma_des_size_write_req      (b1_dma_des_size_write_req),
        .b1_prof_recon_write_val        (b1_prof_recon_write_val)         , .b1_prof_recon_write_req        (b1_prof_recon_write_req),
        .b1_prof_exec_write_val         (b1_prof_exec_write_val)          , .b1_prof_exec_write_req         (b1_prof_exec_write_req),
        .b1_vs_rm_recon_select_write_val(b1_vs_rm_recon_select_write_val) , .b1_vs_rm_recon_select_write_req(b1_vs_rm_recon_select_write_req),
        .b1_vs_rm_exec_select_write_val (b1_vs_rm_exec_select_write_val)  , .b1_vs_rm_exec_select_write_req (b1_vs_rm_exec_select_write_req),
        .b1_load_mask_write_val         (b1_load_mask_write_val)          , .b1_load_mask_write_req         (b1_load_mask_write_req),
        .b1_store_mask_write_val        (b1_store_mask_write_val)         , .b1_store_mask_write_req        (b1_store_mask_write_req),
        .b1_complete_mask_write_val     (b1_complete_mask_write_val)      , .b1_complete_mask_write_req     (b1_complete_mask_write_req),
        .b1_next_session_write_val      (b1_next_session_write_val)       , .b1_next_session_write_req      (b1_next_session_write_req),

            //////////// DMA and PR ctrl
        .dma_init_task(dma_init_task),
        .dma_fin_task (dma_fin_task),

        .pr_ctrl_task    (pr_ctrl_task),
        .pr_ctrl_fin_task(pr_ctrl_fin_task),

            //////////// MGS Communication
        .dfx_stream_store_reset(dfx_stream_store_reset),
        .dfx_stream_load_reset (dfx_stream_load_reset),
        .dfx_stream_store_init (dfx_stream_store_init),
        .dfx_stream_load_init  (dfx_stream_load_init),

        .dfx_stream_fin        (dfx_stream_fin),

            //////////// DFX Ctrl
        .dfx_rm_program (dfx_rm_program),
        .dfx_rm_nreset  (dfx_rm_nreset)

    );


/////////////////////////////////////////////////////////////
/////////// AXI LITE MASTER  ////////////////////////////////
/////////////////////////////////////////////////////////////

M_AXI_READ #(
    .GLOB_ADDR_WIDTH(GLOB_ADDR_WIDTH),
    .GLOB_DATA_WIDTH(GLOB_DATA_WIDTH)
)m_axi_read (
.clk(clk),
.nreset(nreset),

// Read Address Channel
.M_AXI_ARADDR(M_AXI_ARADDR),
.M_AXI_ARVALID(M_AXI_ARVALID),
.M_AXI_ARREADY(M_AXI_ARREADY),

// Read Data Channel
.M_AXI_RDATA(M_AXI_RDATA), ////// read data output acctually it is a reg
.M_AXI_RRESP(M_AXI_RRESP),
.M_AXI_RVALID(M_AXI_RVALID),
.M_AXI_RREADY(M_AXI_RREADY)
);

M_AXI_WRITE #(
    .GLOB_ADDR_WIDTH            (GLOB_ADDR_WIDTH),
    .GLOB_DATA_WIDTH            (GLOB_DATA_WIDTH),
    .BANK0_QUERY_BIT_LEN        (BANK0_QUERY_BIT_LEN),
    .BANK1_INDEX_WIDTH          (BANK1_INDEX_WIDTH),
    .BANK1_DATA_ADDR_WIDTH      (BANK1_DATA_ADDR_WIDTH),
    .BANK1_DATA_SIZE_WIDTH      (BANK1_DATA_SIZE_WIDTH),
    .BANK1_RM_SELECT_WIDTH      (BANK1_RM_SELECT_WIDTH),
    .BANK1_PROFILE_RECON_WIDTH  (BANK1_PROFILE_RECON_WIDTH),
    .BANK1_PROFILE_EXEC_WIDTH   (BANK1_PROFILE_EXEC_WIDTH),
    .BANK1_DATA_POOL_MASK_WIDTH (BANK1_DATA_POOL_MASK_WIDTH),
    .DMA_INIT_TASK_CNT          (DMA_INIT_TASK_CNT),
    .DMA_EXEC_TASK_CNT          (DMA_EXEC_TASK_CNT),
    .PR_CTRL_TASK_CNT           (PR_CTRL_TASK_CNT)
) m_axi_write(
    .clk(clk),
    .nreset(nreset),

    // AXI Lite Write Address Channel
    .M_AXI_AWADDR (M_AXI_AWADDR), ///// actually it is wire
    .M_AXI_AWVALID(M_AXI_AWVALID),
    .M_AXI_AWREADY(M_AXI_AWREADY),

    // AXI Lite Write Data Channel
    .M_AXI_WDATA (M_AXI_WDATA), ///// actually it is wire
    .M_AXI_WSTRB (M_AXI_WSTRB),
    .M_AXI_WVALID(M_AXI_WVALID),
    .M_AXI_WREADY(M_AXI_WREADY),

    // AXI Lite Write Response Channel
    .M_AXI_BRESP (M_AXI_BRESP),
    .M_AXI_BVALID(M_AXI_BVALID),
    .M_AXI_BREADY(M_AXI_BREADY),

    // dma base addr
    .b0_dma_ip_addr(b0_dma_ip_addr),
    .b0_pr_ip_addr (b0_pr_ip_addr),

    // pr ctrl addr and batch size
    .b0_amt_query_per_iter_read_val(b0_amt_query_per_iter_read_val),

    // slave input
    .dma_init_task(dma_init_task), ///// trigger slave dma to do somthing
    .dma_fin_task(dma_fin_task),

    .pr_ctrl_task    (pr_ctrl_task),
    .pr_ctrl_fin_task(pr_ctrl_fin_task),


    .b1_dma_src_addr_send_val     (b1_dma_src_addr_read_val),      // actually it is a reg
    .b1_dma_src_size_send_val     (b1_dma_src_size_read_val),      // actually it is a reg
    .b1_dma_des_addr_send_val     (b1_dma_des_addr_read_val),
    .b1_dma_des_size_send_val     (b1_dma_des_size_read_val),
    .b1_vs_rm_exec_select_send_val(b1_vs_rm_exec_select_read_val)

);

/////////////////////////////////////////////////////////////
/////////// AXI LITE SlAVE  ////////////////////////////////
/////////////////////////////////////////////////////////////

S_AXI_READ #(
    .GLOB_ADDR_WIDTH            (GLOB_ADDR_WIDTH),
    .GLOB_DATA_WIDTH            (GLOB_DATA_WIDTH),
    .BANK0_CONTROL_WIDTH        (BANK0_CONTROL_WIDTH),
    .BANK0_STATE_BIT_LEN        (BANK0_STATE_BIT_LEN),
    .BANK0_QUERY_BIT_LEN        (BANK0_QUERY_BIT_LEN),
    .BANK1_INDEX_WIDTH          (BANK1_INDEX_WIDTH),
    .BANK1_DATA_ADDR_WIDTH      (BANK1_DATA_ADDR_WIDTH),
    .BANK1_DATA_SIZE_WIDTH      (BANK1_DATA_SIZE_WIDTH),
    .BANK1_RM_SELECT_WIDTH      (BANK1_RM_SELECT_WIDTH),
    .BANK1_PROFILE_RECON_WIDTH  (BANK1_PROFILE_RECON_WIDTH),
    .BANK1_PROFILE_EXEC_WIDTH   (BANK1_PROFILE_EXEC_WIDTH),
    .BANK1_DATA_POOL_MASK_WIDTH (BANK1_DATA_POOL_MASK_WIDTH),
    .DMA_INIT_TASK_CNT          (DMA_INIT_TASK_CNT),
    .DMA_EXEC_TASK_CNT          (DMA_EXEC_TASK_CNT),
    .PR_CTRL_TASK_CNT           (PR_CTRL_TASK_CNT)
) s_axi_read (

    .clk(clk),
    .nreset(nreset),

    // Read Address Channel
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),

    // Read Data Channel
    .S_AXI_RDATA(S_AXI_RDATA), ////// read data output acctually it is a wire
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),

    .b1_read_address_val(b1_read_address_val),   //// when connect to dfx_core req, you must indice the read_addr[13:6]
    .b1_read_indexer_req(b1_read_indexer_req),           // actually it is a wire
    ////// bank1 interconnect

    .b1_dma_src_addr_send_val       (b1_dma_src_addr_read_val),
    .b1_dma_src_size_send_val       (b1_dma_src_size_read_val),
    .b1_dma_des_addr_send_val       (b1_dma_des_addr_read_val),
    .b1_dma_des_size_send_val       (b1_dma_des_size_read_val),
    .b1_prof_recon_send_val         (b1_prof_recon_read_val),
    .b1_prof_exec_send_val          (b1_prof_exec_read_val),
    .b1_vs_rm_recon_select_send_val (b1_vs_rm_recon_select_read_val),
    .b1_vs_rm_exec_select_send_val  (b1_vs_rm_exec_select_read_val),
    .b1_load_mask_send_val          (b1_load_mask_read_val),
    .b1_store_mask_send_val         (b1_store_mask_read_val),
    .b1_complete_mask_send_val      (b1_complete_mask_read_val),
    .b1_next_session_send_val       (b1_next_session_read_val),

    ////// bank0 interconnect
    .b0_main_state_send_val         (b0_main_state_read_val),
    .b0_recon_state_send_val        (b0_recon_state_read_val),
    .b0_exec_state_send_val         (b0_exec_state_read_val),
    .b0_last_session_send_val       (b0_last_session_read_val),
    .b0_cur_query_send_val          (b0_cur_query_read_val),
    .b0_amt_query_send_val          (b0_amt_query_read_val),
    .b0_amt_query_per_iter_send_val (b0_amt_query_per_iter_read_val),
    .b0_dma_ip_addr_send_val        (b0_dma_ip_addr_read_val),
    .b0_pr_ip_addr_send_val         (b0_pr_ip_addr_read_val),
    .b0_intr_ena_send_val           (b0_intr_ena_read_val),
    .b0_intr_status_send_val        (b0_intr_status_read_val)

);

S_AXI_WRITE #(
    .GLOB_ADDR_WIDTH           (GLOB_ADDR_WIDTH),
    .GLOB_DATA_WIDTH           (GLOB_DATA_WIDTH),
    .BANK0_CONTROL_WIDTH       (BANK0_CONTROL_WIDTH),
    .BANK0_STATE_BIT_LEN       (BANK0_STATE_BIT_LEN),
    .BANK0_QUERY_BIT_LEN       (BANK0_QUERY_BIT_LEN),
    .BANK1_INDEX_WIDTH         (BANK1_INDEX_WIDTH),
    .BANK1_DATA_ADDR_WIDTH     (BANK1_DATA_ADDR_WIDTH),
    .BANK1_DATA_SIZE_WIDTH     (BANK1_DATA_SIZE_WIDTH),
    .BANK1_RM_SELECT_WIDTH     (BANK1_RM_SELECT_WIDTH),
    .BANK1_PROFILE_RECON_WIDTH (BANK1_PROFILE_RECON_WIDTH),
    .BANK1_PROFILE_EXEC_WIDTH  (BANK1_PROFILE_EXEC_WIDTH),
    .BANK1_DATA_POOL_MASK_WIDTH(BANK1_DATA_POOL_MASK_WIDTH)
)s_axi_write(
    .clk   (clk),
    .nreset(nreset),

    // AXI Lite Write Address Channel
    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),

    // AXI Lite Write Data Channel
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),

    // AXI Lite Write Response Channel
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),

    .b1_write_address_val(b1_write_address_val),

    //// bank0 interconnect
    .b0_control_cmd_send_val       (b0_control_cmd_write_val)       , .b0_control_cmd_send_req       (b0_control_cmd_write_req),
    .b0_last_session_send_val      (b0_last_session_write_val)      , .b0_last_session_send_req      (b0_last_session_write_req),
    .b0_amt_query_send_val         (b0_amt_query_write_val)         , .b0_amt_query_send_req         (b0_amt_query_write_req),
    .b0_amt_query_per_iter_send_val(b0_amt_query_per_iter_write_val), .b0_amt_query_per_iter_send_req(b0_amt_query_per_iter_write_req),
    .b0_load_offset_send_val       (b0_load_offset_write_val)       , .b0_load_offset_send_req       (b0_load_offset_write_req),
    .b0_store_offset_send_val      (b0_store_offset_write_val)      , .b0_store_offset_send_req      (b0_store_offset_write_req),
    .b0_dma_ip_addr_send_val       (b0_dma_ip_addr_write_val)       , .b0_dma_ip_addr_send_req       (b0_dma_ip_addr_write_req),
    .b0_pr_ip_addr_send_val        (b0_pr_ip_addr_write_val)        , .b0_pr_ip_addr_send_req        (b0_pr_ip_addr_write_req),
    .b0_intr_ena_send_val          (b0_intr_ena_write_val)          , .b0_intr_ena_send_req          (b0_intr_ena_write_req),

    //// bank1 interconnect

    .b1_dma_src_addr_send_val      (b1_dma_src_addr_write_val)       , .b1_dma_src_addr_send_req      (b1_dma_src_addr_write_req),
    .b1_dma_src_size_send_val      (b1_dma_src_size_write_val)       , .b1_dma_src_size_send_req      (b1_dma_src_size_write_req),
    .b1_dma_des_addr_send_val      (b1_dma_des_addr_write_val)       , .b1_dma_des_addr_send_req      (b1_dma_des_addr_write_req),
    .b1_dma_des_size_send_val      (b1_dma_des_size_write_val)       , .b1_dma_des_size_send_req      (b1_dma_des_size_write_req),
    .b1_prof_recon_send_val        (b1_prof_recon_write_val)         , .b1_prof_recon_send_req        (b1_prof_recon_write_req),
    .b1_prof_exec_send_val         (b1_prof_exec_write_val)          , .b1_prof_exec_send_req         (b1_prof_exec_write_req),
    .b1_vs_rm_recon_select_send_val(b1_vs_rm_recon_select_write_val) , .b1_vs_rm_recon_select_send_req(b1_vs_rm_recon_select_write_req),
    .b1_vs_rm_exec_select_send_val (b1_vs_rm_exec_select_write_val)  , .b1_vs_rm_exec_select_send_req (b1_vs_rm_exec_select_write_req),
    .b1_load_mask_send_val         (b1_load_mask_write_val)          , .b1_load_mask_send_req         (b1_load_mask_write_req),
    .b1_store_mask_send_val        (b1_store_mask_write_val)         , .b1_store_mask_send_req        (b1_store_mask_write_req),
    .b1_complete_mask_send_val     (b1_complete_mask_write_val)      , .b1_complete_mask_send_req     (b1_complete_mask_write_req),
    .b1_next_session_send_val      (b1_next_session_write_val)       , .b1_next_session_send_req      (b1_next_session_write_req)
);


endmodule
