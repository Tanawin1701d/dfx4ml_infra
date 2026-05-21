module M_AXI_WRITE #(
     // ADDRESS & DATA
    parameter GLOB_ADDR_WIDTH     = 32, // Address width for AXI interface
    parameter GLOB_DATA_WIDTH     = 32, // Data width for AXI interface
    // BANK 0
    parameter BANK0_QUERY_BIT_LEN = 32,
    // BANK 1
    parameter BANK1_INDEX_WIDTH          =  3, // 2 ^ 2 = 4 slots
    parameter BANK1_DATA_ADDR_WIDTH      = 32, // <---- DATA FROM DMA START ADDR
    parameter BANK1_DATA_SIZE_WIDTH      = 26,
    parameter BANK1_RM_SELECT_WIDTH      = 2, // it should be n(vs) x n(rm perslot)
    parameter BANK1_PROFILE_RECON_WIDTH  = 32, // <---- PROFILER RECON
    parameter BANK1_PROFILE_EXEC_WIDTH   = 32, // <---- PROFILER EXEC
    parameter BANK1_DATA_POOL_MASK_WIDTH =  8, // <---- MASK OF MGS and DMA
    // REGION PARAMETER
    parameter NUM_REGION          = 1, // number of reconfigurable regions
    // DMA CONTROL PARAMETER
    parameter DMA_INIT_TASK_CNT   = 8, //// (reset interrupt + startReadChannel + baseAddr0 + size0) + (startWriteChannel + baseAddr1 + size1)
    parameter DMA_EXEC_TASK_CNT   = 1,
    // PR  CONTROL PARAMETER
    parameter PR_CTRL_TASK_CNT    = 2  //// (set batch_size + ap_start)
)(
    input  wire                   clk,
    input  wire                   nreset,

    // AXI Lite Write Address Channel
    output  reg [GLOB_ADDR_WIDTH-1:0]  M_AXI_AWADDR, ///// actually it is wire
    output  wire                       M_AXI_AWVALID,
    input   wire                       M_AXI_AWREADY,

    // AXI Lite Write Data Channel
    output  reg [GLOB_DATA_WIDTH-1:0]  M_AXI_WDATA, ///// actually it is wire
    output  wire[(GLOB_DATA_WIDTH/8)-1:0] M_AXI_WSTRB,
    output  wire                   M_AXI_WVALID,
    input   wire                   M_AXI_WREADY,

    // AXI Lite Write Response Channel
    input  wire [1:0]             M_AXI_BRESP,
    input  wire                   M_AXI_BVALID,
    output wire                   M_AXI_BREADY,

    // dma base addr
    input  wire [GLOB_ADDR_WIDTH-1: 0]   b0_dma_ip_addr,
    input wire [GLOB_ADDR_WIDTH -1: 0]   b0_pr_ip_addr,

    // pr ctrl addr and batch size
    input  wire [BANK0_QUERY_BIT_LEN-1: 0] b0_amt_query_per_iter_read_val,

    // slave input
    input   wire[DMA_INIT_TASK_CNT -1: 0] dma_init_task, ///// trigger slave dma to do somthing
    output  reg [DMA_INIT_TASK_CNT -1: 0] dma_fin_task,

    input   wire[PR_CTRL_TASK_CNT  -1: 0] pr_ctrl_task,
    output  reg [PR_CTRL_TASK_CNT  -1: 0] pr_ctrl_fin_task,


    input wire [BANK1_DATA_ADDR_WIDTH -1:0] b1_dma_src_addr_send_val,      // actually it is a reg
    input wire [BANK1_DATA_SIZE_WIDTH -1:0] b1_dma_src_size_send_val,      // actually it is a reg
    input wire [BANK1_DATA_ADDR_WIDTH -1:0] b1_dma_des_addr_send_val,
    input wire [BANK1_DATA_SIZE_WIDTH -1:0] b1_dma_des_size_send_val,
    input wire [BANK1_RM_SELECT_WIDTH-1: 0] b1_vs_rm_exec_select_send_val

);


/**
* This module supposed to connet to dma
*
*
**/

//////// READ CHANNEL

wire[GLOB_ADDR_WIDTH-1: 0] dmSrcStatusADDR    = b0_dma_ip_addr + 32'h04;

wire[GLOB_ADDR_WIDTH-1: 0] dmaSrcCtrlADDR     = b0_dma_ip_addr + 32'h00;
wire[GLOB_ADDR_WIDTH-1: 0] dmaSrcDataAddrADDR = b0_dma_ip_addr + 32'h18;
wire[GLOB_ADDR_WIDTH-1: 0] dmaSrcDataSizeADDR = b0_dma_ip_addr + 32'h28;

//////// WRITE CHANNEL

wire[GLOB_ADDR_WIDTH-1: 0] dmDesStatusADDR    = b0_dma_ip_addr + 32'h34;

// number of RM variants per region; each region's PR Ctrl IP sits at a
// separate 0x0001_0000-spaced AXI slot, so the offset uses the region
// index (i / num_rm_per_region), not the flat RM index (i).
localparam num_rm_per_region = BANK1_RM_SELECT_WIDTH / NUM_REGION;

//////// PR CTRL CHANNEL
reg[GLOB_ADDR_WIDTH-1: 0] prCtrlApCtrlADDR    ;
reg[GLOB_ADDR_WIDTH-1: 0] prCtrlBatchSizeADDR ;

integer i;
always @(*) begin
    prCtrlApCtrlADDR    = 0;
    prCtrlBatchSizeADDR = 0;
    for (i = 0; i < BANK1_RM_SELECT_WIDTH; i = i + 1) begin
        if (b1_vs_rm_exec_select_send_val[i]) begin
            prCtrlApCtrlADDR    = b0_pr_ip_addr + 32'h00 + (i/num_rm_per_region) * 32'h0001_0000;
            prCtrlBatchSizeADDR = b0_pr_ip_addr + 32'h10 + (i/num_rm_per_region) * 32'h0001_0000;
        end
    end
end



wire[GLOB_ADDR_WIDTH-1: 0] dmaDesCtrlADDR     = b0_dma_ip_addr + 32'h30;
wire[GLOB_ADDR_WIDTH-1: 0] dmaDesDataAddrADDR = b0_dma_ip_addr + 32'h48;
wire[GLOB_ADDR_WIDTH-1: 0] dmaDesDataSizeADDR = b0_dma_ip_addr + 32'h58;


localparam STATUS_IDLE   = 4'b0000;
localparam STATUS_WADDR  = 4'b0001;
localparam STATUS_WDATA  = 4'b0010;
localparam STATUS_RESP   = 4'b0100;
localparam STATUS_UNLOCK = 4'b1000;

/**
control main state machine
*/

reg[3:0] state;

always @(posedge clk or negedge nreset) begin

    if (~nreset)begin
        state <= STATUS_IDLE;
    end else begin
        case(state)
            STATUS_IDLE: begin
                if ( (dma_init_task != 0) | (pr_ctrl_task != 0)) begin state <= STATUS_WADDR; end
            end
            STATUS_WADDR: begin
                if (M_AXI_AWREADY) begin state <= STATUS_WDATA; end
            end
            STATUS_WDATA: begin
                if (M_AXI_WREADY) begin state <= STATUS_RESP; end
            end
            STATUS_RESP: begin
                if (M_AXI_BVALID) begin state <= STATUS_UNLOCK; end
            end
            STATUS_UNLOCK: begin
                state <= STATUS_IDLE;
            end

            default: begin
                state <= STATUS_IDLE;
            end
        endcase
    end
end

//// address channel
assign M_AXI_AWVALID = (state == STATUS_WADDR);
//// data channel
assign M_AXI_WSTRB   = 4'b1111;
assign M_AXI_WVALID  = (state == STATUS_WDATA);
//// resChannel
assign M_AXI_BREADY  = (state == STATUS_RESP);

///// manage address

always @ (*) begin

    M_AXI_AWADDR = 0;
    M_AXI_WDATA  = 0;

    dma_fin_task     = 0;
    pr_ctrl_fin_task = 0;

    if (dma_init_task != 0)begin

        if (state == STATUS_UNLOCK)begin //// STATUS_UNLOCK is one cycle
            dma_fin_task = dma_init_task;
        end

        case(dma_init_task)

        //////////////////// set STATUS of SRC side

            8'b00000001: begin
                        M_AXI_AWADDR = dmSrcStatusADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - 13){1'b0}}, 13'b1_0000_0000_0000}; //// start command
            end
        //////////////////// set STATUS of DES side
            8'b00000010: begin
                        M_AXI_AWADDR = dmDesStatusADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - 13){1'b0}}, 13'b1_0000_0000_0000}; //// start command
            end
        //////////////////// set READ (RUN/SRCADDR/SRCSIZE)
            8'b00000100: begin
                        M_AXI_AWADDR = dmaSrcCtrlADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - 13){1'b0}}, 13'b1_0000_0000_0001}; //// start command
                    end
            8'b00001000: begin
                        M_AXI_AWADDR = dmaSrcDataAddrADDR;
                        M_AXI_WDATA  = b1_dma_src_addr_send_val;

                    end
            8'b00010000: begin
                        M_AXI_AWADDR = dmaSrcDataSizeADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - BANK1_DATA_SIZE_WIDTH){1'b0}}, b1_dma_src_size_send_val};
                    end
            //////////////////// set WRITE (RUN/DESADDR/DESSIZE)
            8'b00100000: begin
                        M_AXI_AWADDR = dmaDesCtrlADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - 13){1'b0}}, 13'b1_0000_0000_0001}; //// start command
                    end
            8'b01000000: begin
                        M_AXI_AWADDR = dmaDesDataAddrADDR;
                        M_AXI_WDATA  = b1_dma_des_addr_send_val;
                    end
            8'b10000000: begin
                        M_AXI_AWADDR = dmaDesDataSizeADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH - BANK1_DATA_SIZE_WIDTH){1'b0}}, b1_dma_des_size_send_val};
                    end
            default: begin
                        M_AXI_AWADDR          = 0;
                        M_AXI_WDATA           = 0;
                        dma_fin_task          = 0;
                    end
        endcase
    end else if (pr_ctrl_task != 0) begin

        if (state == STATUS_UNLOCK) begin
            pr_ctrl_fin_task = pr_ctrl_task;
        end

        case (pr_ctrl_task)
            2'b01: begin // PR_CTRL_TASK_BATCH_SIZE: write batchSize to offset 0x10
                        M_AXI_AWADDR = prCtrlBatchSizeADDR;
                        M_AXI_WDATA  = b0_amt_query_per_iter_read_val;
                   end
            2'b10: begin // PR_CTRL_TASK_AP_START: write ap_start (bit 0) to offset 0x00
                        M_AXI_AWADDR = prCtrlApCtrlADDR;
                        M_AXI_WDATA  = {{(GLOB_DATA_WIDTH-1){1'b0}}, 1'b1};
                   end
            default: begin
                        M_AXI_AWADDR     = 0;
                        M_AXI_WDATA      = 0;
                        pr_ctrl_fin_task = 0;
                    end
        endcase

    end

end

endmodule
