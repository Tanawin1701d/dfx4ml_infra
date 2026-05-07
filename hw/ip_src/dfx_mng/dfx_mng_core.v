module DFX_Mng_Core #(

    // ADDRESS & DATA
    parameter GLOB_ADDR_WIDTH = 32, // Address width for AXI interface
    parameter GLOB_DATA_WIDTH = 32, // Data width for AXI interface

    parameter BANK0_CONTROL_WIDTH = 4,
    parameter BANK0_STATE_BIT_LEN = 4,
    parameter BANK0_QUERY_BIT_LEN = 32,



    parameter BANK1_INDEX_WIDTH            =  3, // 2 ^ 2 = 4 slots
    parameter BANK1_DATA_ADDR_WIDTH         = 32, // <---- DATA FROM DMA START ADDR
    parameter BANK1_DATA_SIZE_WIDTH         = 26,
    parameter BANK1_RM_SELECT_WIDTH         = 2, // it should be n(vs) x n(rm perslot)
    parameter BANK1_PROFILE_RECON_WIDTH    = 32, // <---- PROFILER RECON
    parameter BANK1_PROFILE_EXEC_WIDTH     = 32, // <---- PROFILER EXEC
    parameter BANK1_DATA_POOL_MASK_WIDTH =  8, // <---- MASK OF MGS and DMA

    parameter DMA_INIT_TASK_CNT   = 8, //// (reset interrupt + startReadChannel + baseAddr0 + size0) + (startWriteChannel + baseAddr1 + size1)
    parameter DMA_EXEC_TASK_CNT   = 1,

    parameter PR_CTRL_TASK_CNT    = 2  //// (set batch_size + ap_start)
) (
    input wire clk,
    input wire nreset,

    //////// BANK 0

    output wire [BANK0_STATE_BIT_LEN -1: 0] b0_main_state_read_val,
    output wire [BANK0_STATE_BIT_LEN -1: 0] b0_recon_state_read_val,
    output wire [BANK0_STATE_BIT_LEN -1: 0] b0_exec_state_read_val,
    output wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_read_val,
    output wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_read_val,
    output wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_accum_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_accum_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_read_val,
    output wire [GLOB_ADDR_WIDTH     -1: 0] b0_rm_ip_addr_read_val,
    output wire                             b0_intr_ena_read_val,
    output wire                             b0_intr_status_read_val,

    input wire [BANK0_CONTROL_WIDTH -1: 0] b0_control_cmd_write_val        , input wire b0_control_cmd_write_req,
    input wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_write_val       , input wire b0_last_session_write_req,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_write_val          , input wire b0_amt_query_write_req,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_write_val , input wire b0_amt_query_per_iter_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_write_val        , input wire b0_load_offset_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_accum_write_val  , input wire b0_load_offset_accum_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_write_val       , input wire b0_store_offset_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_accum_write_val , input wire b0_store_offset_accum_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_write_val        , input wire b0_dma_ip_addr_write_req,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_rm_ip_addr_write_val         , input wire b0_rm_ip_addr_write_req,
    input wire                             b0_intr_ena_write_val           , input wire b0_intr_ena_write_req,
    //////// BANK 1

    //////////// BANK 1 read data
    input  wire                                   b1_read_indexer_req,
    input  wire [BANK1_INDEX_WIDTH-1         : 0] b1_read_indexer_val,

    output reg [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_src_addr_read_val,
    output reg [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_src_size_read_val,
    output reg [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_des_addr_read_val,
    output reg [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_des_size_read_val,
    output reg [BANK1_PROFILE_RECON_WIDTH-1 : 0] b1_prof_recon_read_val,
    output reg [BANK1_PROFILE_EXEC_WIDTH-1  : 0] b1_prof_exec_read_val,
    output reg [BANK1_RM_SELECT_WIDTH-1     : 0] b1_vs_rm_select_read_val,
    output reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_load_mask_read_val,
    output reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_store_mask_read_val,
    output reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_complete_mask_read_val,

    //////////// BANK 1 write data
    input  wire [BANK1_INDEX_WIDTH-1         : 0] b1_write_indexer_val,

    input  wire [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_src_addr_write_val , input  wire  b1_dma_src_addr_write_req,
    input  wire [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_src_size_write_val , input  wire  b1_dma_src_size_write_req,
    input  wire [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_des_addr_write_val , input  wire  b1_dma_des_addr_write_req,
    input  wire [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_des_size_write_val , input  wire  b1_dma_des_size_write_req,
    input  wire [BANK1_PROFILE_RECON_WIDTH-1 : 0] b1_prof_recon_write_val   , input  wire  b1_prof_recon_write_req,
    input  wire [BANK1_PROFILE_EXEC_WIDTH-1  : 0] b1_prof_exec_write_val    , input  wire  b1_prof_exec_write_req,
    input  wire [BANK1_RM_SELECT_WIDTH-1     : 0] b1_vs_rm_select_write_val , input  wire  b1_vs_rm_select_write_req,
    input  wire [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_load_mask_write_val    , input  wire  b1_load_mask_write_req,
    input  wire [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_store_mask_write_val   , input  wire  b1_store_mask_write_req,
    input  wire [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_complete_mask_write_val, input  wire  b1_complete_mask_write_req,

    input  wire [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_par_complete_mask_write_val, input  wire  b1_par_complete_mask_write_req,


    ////////////
    output reg [DMA_INIT_TASK_CNT  -1:0]    dmaInitTask,
    output reg [PR_CTRL_TASK_CNT   -1:0]    prCtrlTask









);

localparam BANK1_ROWS = 1 << BANK1_INDEX_WIDTH;

localparam CTRL_CLEAR            = 4'b0000;
localparam CTRL_SHUTDOWN         = 4'b0001;
localparam CTRL_START            = 4'b0010;

localparam STATE_MAIN_SHUTDOWN     = 4'b0000;
localparam STATE_MAIN_PROCESS      = 4'b0001;
localparam STATE_MAIN_PRE_SHUTDOWN = 4'b0010;

localparam STATE_RECON_SHUTDOWN     = 4'b0000;
localparam STATE_RECON_REPROG       = 4'b0001;
localparam STATE_RECON_W4SLAVERESET = 4'b0010;
localparam STATE_RECON_W4SLAVEOP    = 4'b0011;
localparam STATE_RECON_FIN_SYNC     = 4'b0100;

localparam STATE_EXEC_SHUTDOWN           = 4'b0000;
localparam STATE_EXEC_INITIALIZE_PR_CTRL = 4'b0001; // initialize PR-controlled IP (set batch_size + ap_start)
localparam STATE_EXEC_CLEAR_MGS          = 4'b0010;
localparam STATE_EXEC_INITIALIZE_MGS     = 4'b0011; // initialize magic streamer, to reset magic streamer and start the streaming
localparam STATE_EXEC_INITIALIZE_DMA     = 4'b0100; // the state will reset the interrupt signal
localparam STATE_EXEC_SET_DMA_LOAD       = 4'b0101; // the system is setting the dma load, we can trigger the slave to do something
localparam STATE_EXEC_SET_DMA_STORE      = 4'b0110; // the system is setting the dma store, we can trigger the slave to do something
localparam STATE_EXEC_TRIGGERING         = 4'b0111;
localparam STATE_EXEC_WAIT4FIN           = 4'b1000;
localparam STATE_EXEC_FIN_SYNC           = 4'b1001;

/////////////////////////////////////////////
////// STATE MACHINE  ///////////////////////
/////////////////////////////////////////////




/////////////////////////////////////////////
////// system wire    ///////////////////////
/////////////////////////////////////////////
wire all_sync = (b0_recon_state == STATE_RECON_FIN_SYNC) &&  (b0_exec_state == STATE_EXEC_FIN_SYNC);


/////////////////////////////////////////////
////// BANK 0 MEM  //////////////////////////
/////////////////////////////////////////////
reg [BANK0_STATE_BIT_LEN -1: 0] b0_main_state;
reg [BANK0_STATE_BIT_LEN -1: 0] b0_recon_state;
reg [BANK0_STATE_BIT_LEN -1: 0] b0_exec_state;
reg [BANK1_INDEX_WIDTH   -1: 0] b0_last_session;
reg [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query;
reg [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter;
reg [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset; // it stores the size in memory that will be offset in each group of session run for data input load
reg [GLOB_ADDR_WIDTH     -1: 0] b0_load_offset_accum; // it stores the size in memory that will be offset in each group of session run for data input load
reg [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset; // it stores the size in memory that will be offset in each group of session run for data input store
reg [GLOB_ADDR_WIDTH     -1: 0] b0_store_offset_accum; // it stores the size in memory that will be offset in each group of session run for data input store
reg [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr;
reg [GLOB_ADDR_WIDTH     -1: 0] b0_rm_ip_addr;
reg                             b0_intr_ena;
reg                             b0_intr_status;

assign b0_main_state_read_val         = b0_main_state;
assign b0_recon_state_read_val        = b0_recon_state;
assign b0_exec_state_read_val         = b0_exec_state;
assign b0_last_session_read_val       = b0_last_session;
assign b0_amt_query_read_val          = b0_amt_query;
assign b0_amt_query_per_iter_read_val = b0_amt_query_per_iter;
assign b0_load_offset_read_val        = b0_load_offset;
assign b0_load_offset_accum_read_val  = b0_load_offset_accum;
assign b0_store_offset_read_val       = b0_store_offset;
assign b0_store_offset_accum_read_val = b0_store_offset_accum;
assign b0_dma_ip_addr_read_val        = b0_dma_ip_addr;
assign b0_rm_ip_addr_read_val         = b0_rm_ip_addr;
assign b0_intr_ena_read_val           = b0_intr_ena;
assign b0_intr_status_read_val        = b0_intr_status;



/////////////////////////////////////////////
////// BANK 1 MEM  //////////////////////////
/////////////////////////////////////////////


reg  [BANK1_INDEX_WIDTH-1 : 0] b1_read_indexer;

reg [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_src_addr   [BANK1_ROWS-1: 0];
reg [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_src_size   [BANK1_ROWS-1: 0];
reg [BANK1_DATA_ADDR_WIDTH-1     : 0] b1_dma_des_addr   [BANK1_ROWS-1: 0];
reg [BANK1_DATA_SIZE_WIDTH-1     : 0] b1_dma_des_size   [BANK1_ROWS-1: 0];
reg [BANK1_PROFILE_RECON_WIDTH-1 : 0] b1_prof_recon     [BANK1_ROWS-1: 0];
reg [BANK1_PROFILE_EXEC_WIDTH-1  : 0] b1_prof_exec      [BANK1_ROWS-1: 0];
reg [BANK1_RM_SELECT_WIDTH-1     : 0] b1_vs_rm_select   [BANK1_ROWS-1: 0];
reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_load_mask      [BANK1_ROWS-1: 0];
reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_store_mask     [BANK1_ROWS-1: 0];
reg [BANK1_DATA_POOL_MASK_WIDTH-1: 0] b1_complete_mask  [BANK1_ROWS-1: 0];
reg [BANK1_INDEX_WIDTH-1         : 0] b1_next_session   [BANK1_ROWS-1: 0];



/////////////////////////////////////////////
////// PROCEDURE   //////////////////////////
/////////////////////////////////////////////


/////////////////////////////////////////////
////// BANK 1 MEM  //////////////////////////
/////////////////////////////////////////////




always@( posedge clk) begin

    b1_dma_src_addr_read_val  <= b1_dma_src_addr[ b1_read_indexer];
    b1_dma_src_size_read_val  <= b1_dma_src_size[ b1_read_indexer];
    b1_dma_des_addr_read_val  <= b1_dma_des_addr[ b1_read_indexer];
    b1_dma_des_size_read_val  <= b1_dma_des_size[ b1_read_indexer];
    b1_prof_recon_read_val    <= b1_prof_recon[ b1_read_indexer];
    b1_prof_exec_read_val     <= b1_prof_exec[ b1_read_indexer];
    b1_vs_rm_select_read_val  <= b1_vs_rm_select[ b1_read_indexer];
    b1_load_mask_read_val     <= b1_load_mask[ b1_read_indexer];
    b1_store_mask_read_val    <= b1_store_mask[ b1_read_indexer];
    b1_complete_mask_read_val <= b1_complete_mask[ b1_read_indexer];

    if (b0_main_state == STATE_MAIN_SHUTDOWN) begin

        if (b1_dma_src_addr_write_req)  begin b1_dma_src_addr[b1_write_indexer_val]  <=     b1_dma_src_addr_write_val; end
        if (b1_dma_src_size_write_req)  begin b1_dma_src_size[b1_write_indexer_val]  <=     b1_dma_src_size_write_val; end
        if (b1_dma_des_addr_write_req)  begin b1_dma_des_addr[b1_write_indexer_val]  <=     b1_dma_des_addr_write_val; end
        if (b1_dma_des_size_write_req)  begin b1_dma_des_size[b1_write_indexer_val]  <=     b1_dma_des_size_write_val; end
        if (b1_prof_recon_write_req)    begin b1_prof_recon[b1_write_indexer_val]    <=     b1_prof_recon_write_val;   end
        if (b1_prof_exec_write_req)     begin b1_prof_exec[b1_write_indexer_val]     <=     b1_prof_exec_write_val;    end
        if (b1_vs_rm_select_write_req)  begin b1_vs_rm_select[b1_write_indexer_val]  <=     b1_vs_rm_select_write_val; end
        if (b1_load_mask_write_req)     begin b1_load_mask[b1_write_indexer_val]     <=     b1_load_mask_write_val;    end
        if (b1_store_mask_write_req)    begin b1_store_mask[b1_write_indexer_val]    <=     b1_store_mask_write_val;   end
        if (b1_complete_mask_write_req) begin b1_complete_mask[b1_write_indexer_val] <=    b1_complete_mask_write_val; end

    end else if (b0_main_state == STATE_MAIN_PROCESS) begin

        if (b1_par_complete_mask_write_req) begin
            b1_complete_mask[b1_write_indexer_val] <= (b1_complete_mask_read_val |
                                                       b1_par_complete_mask_write_val);
        end

    end

end



always@( posedge clk) begin

    // main state
    if (~nreset)begin
        b0_main_state   <= STATE_MAIN_SHUTDOWN;
        b0_exec_state   <= STATE_EXEC_SHUTDOWN;
        b0_intr_status  <= 0;
        b1_read_indexer <= 0;
    end else if (b0_control_cmd_write_req) begin
        //  master command from PS
        case(b0_control_cmd_write_val)
            CTRL_CLEAR: begin
                b0_main_state   <= STATE_MAIN_SHUTDOWN;
                b0_exec_state   <= STATE_MAIN_PRE_SHUTDOWN;
                b0_intr_status  <= 0;
                b1_read_indexer <= 0;
            end
            CTRL_SHUTDOWN: begin
                b0_main_state  <= STATE_MAIN_SHUTDOWN; // we don't reset recon and exec state due to debuggability
            end
            CTRL_START: begin
                b0_main_state   <= STATE_MAIN_PROCESS;
                b0_recon_state  <= STATE_RECON_SHUTDOWN;
                b0_exec_state   <= STATE_EXEC_SHUTDOWN;
                b0_intr_status  <= 0;
                b1_read_indexer <= 0;
            end
        endcase
    end else begin
        /// handle case (STATE_MAIN_PROCESS/ STATE_MAIN_PRE_SHUTDOWN)


    end

    // recon state
    if (~nreset)begin
        b0_recon_state  <= STATE_RECON_SHUTDOWN;
    end else if (b0_control_cmd_write_req && (b0_control_cmd_write_val == CTRL_CLEAR)) begin
        b0_recon_state  <= STATE_RECON_SHUTDOWN;
    end else begin
        case (b0_recon_state)
            STATE_RECON_SHUTDOWN: begin
                if (b0_main_state == STATE_MAIN_PROCESS)begin // main start we then start
                    b0_recon_state <= STATE_RECON_REPROG;
                end
            end
            STATE_RECON_REPROG      : begin b0_recon_state <= STATE_RECON_W4SLAVERESET; end
            STATE_RECON_W4SLAVERESET: begin b0_recon_state <= STATE_RECON_W4SLAVEOP   ; end
            STATE_RECON_W4SLAVEOP   : begin b0_recon_state <= STATE_RECON_FIN_SYNC    ; end
            STATE_RECON_FIN_SYNC    : begin
                if (all_sync)begin b0_recon_state <= STATE_RECON_SHUTDOWN; end
            end
        endcase
    end

    // exec state
    if (~nreset)begin
        b0_exec_state <= STATE_EXEC_SHUTDOWN;
    end else if (b0_control_cmd_write_req && (b0_control_cmd_write_val == CTRL_CLEAR)) begin
        b0_exec_state <= STATE_EXEC_SHUTDOWN;
        dmaInitTask   <= 0;
        prCtrlTask    <= 0;
    end else begin
        case (b0_exec_state)
            STATE_EXEC_SHUTDOWN: begin
                if (b0_main_state == STATE_MAIN_PROCESS)begin // main start we then start
                    b0_exec_state <= STATE_EXEC_INITIALIZE_PR_CTRL;
                    prCtrlTask    <= 1;
                end
            end


        endcase


    end





end



endmodule