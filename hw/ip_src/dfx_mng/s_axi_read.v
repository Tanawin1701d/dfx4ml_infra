


module S_AXI_READ #(

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

    input  wire clk,
    input  wire nreset,

    // Read Address Channel
    input  wire [GLOB_ADDR_WIDTH-1:0]  S_AXI_ARADDR,
    input  wire                   S_AXI_ARVALID,
    output wire                   S_AXI_ARREADY,

    // Read Data Channel
    output reg  [GLOB_DATA_WIDTH-1:0]   S_AXI_RDATA, ////// read data output acctually it is a wire
    output wire [1:0]                   S_AXI_RRESP,
    output wire                         S_AXI_RVALID,
    input  wire                         S_AXI_RREADY,

    output  reg[GLOB_ADDR_WIDTH-1:0]         b1_read_address_val,   //// when connect to dfx_core req, you must indice the read_addr[13:6]
    output  reg                              b1_read_indexer_req,           // actually it is a wire
    ////// bank1 interconnect

    input wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_src_addr_send_val,
    input wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_src_size_send_val,
    input wire [BANK1_DATA_ADDR_WIDTH       -1: 0] b1_dma_des_addr_send_val,
    input wire [BANK1_DATA_SIZE_WIDTH       -1: 0] b1_dma_des_size_send_val,
    input wire [BANK1_PROFILE_RECON_WIDTH   -1: 0] b1_prof_recon_send_val,
    input wire [BANK1_PROFILE_EXEC_WIDTH    -1: 0] b1_prof_exec_send_val,
    input wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_recon_select_send_val,
    input wire [BANK1_RM_SELECT_WIDTH       -1: 0] b1_vs_rm_exec_select_send_val,
    input wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_load_mask_send_val,
    input wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_store_mask_send_val,
    input wire [BANK1_DATA_POOL_MASK_WIDTH  -1: 0] b1_complete_mask_send_val,
    input wire [BANK1_INDEX_WIDTH           -1: 0] b1_next_session_send_val,

    ////// bank0 interconnect
    input wire [BANK0_STATE_BIT_LEN -1: 0] b0_main_state_send_val,
    input wire [BANK0_STATE_BIT_LEN -1: 0] b0_recon_state_send_val,
    input wire [BANK0_STATE_BIT_LEN -1: 0] b0_exec_state_send_val,
    input wire [BANK1_INDEX_WIDTH   -1: 0] b0_last_session_send_val,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_cur_query_send_val,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_send_val,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_amt_query_per_iter_send_val,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_dma_ip_addr_send_val,
    input wire [GLOB_ADDR_WIDTH     -1: 0] b0_pr_ip_addr_send_val,
    input wire                             b0_intr_ena_send_val,
    input wire                             b0_intr_status_send_val,
    input wire [BANK0_QUERY_BIT_LEN -1: 0] b0_mperf_send_val



);

localparam ST_IDLE      = 3'b000;
localparam ST_READFETCH = 3'b001;
localparam ST_READWAIT  = 3'b011;  // extra cycle: let b1_*_read_val latch the updated indexer
localparam ST_READDATA  = 3'b010;


reg[2:0]            state; // State variable for FSM


///////// main control state machine
always @(posedge clk or negedge nreset ) begin
    if (~nreset) begin
        state <= ST_IDLE;
        b1_read_indexer_req <= 0;
    end else begin
        case (state)
            ST_IDLE: begin
                if (S_AXI_ARVALID) begin
                    state <= ST_READFETCH;
                    b1_read_address_val <= S_AXI_ARADDR;
                    b1_read_indexer_req  <= 1;
                end
            end
            ST_READFETCH: begin // cycle 1: b1_read_indexer latches the new slot index
                b1_read_indexer_req <= 0;
                if (b1_read_address_val[15:14] == 2'b01)
                    state <= ST_READWAIT;  // Bank 1: need one more cycle for _read_val to settle
                else
                    state <= ST_READDATA;
            end
            ST_READWAIT: begin // cycle 2: b1_*_read_val latches data from the updated indexer
                state <= ST_READDATA;
            end
            ST_READDATA: begin
                if (S_AXI_RREADY) begin ///// send data response immediately
                    state <= ST_IDLE;
                end
            end
            default: begin
                state <= ST_IDLE; // Default case to handle unexpected states
            end

        endcase
    end
end

////////// main control output wires

/////////////// read address channel
assign S_AXI_ARREADY = (state == ST_IDLE) && S_AXI_ARVALID; // Ready to accept read address when
/////////////// read data channel
assign S_AXI_RRESP   = 2'b00;
assign S_AXI_RVALID  = (state == ST_READDATA);

// ext_bank1_out_index removed — was undeclared and unused

always @(*) begin

    S_AXI_RDATA       = 0; // Default case for unsupported addresses

    if (state == ST_READDATA)begin
        if (b1_read_address_val[15:14] == 2'b00) begin

            case (b1_read_address_val[13:6]) // Address bits 13 to 6 determine the slot
                8'h00:   begin S_AXI_RDATA = 0                                                                           ; end
                8'h01:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK0_STATE_BIT_LEN){1'b0}}, b0_main_state_send_val        }; end
                8'h02:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK0_STATE_BIT_LEN){1'b0}}, b0_recon_state_send_val       }; end
                8'h03:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK0_STATE_BIT_LEN){1'b0}}, b0_exec_state_send_val        }; end
                8'h04:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_INDEX_WIDTH  ){1'b0}}, b0_last_session_send_val      }; end
                8'h05:   begin S_AXI_RDATA =                                                 b0_cur_query_send_val          ; end
                8'h06:   begin S_AXI_RDATA =                                                 b0_amt_query_send_val          ; end
                8'h07:   begin S_AXI_RDATA =                                                 b0_amt_query_per_iter_send_val ; end
                8'h08:   begin S_AXI_RDATA =                                                 b0_dma_ip_addr_send_val        ; end
                8'h09:   begin S_AXI_RDATA =                                                 b0_pr_ip_addr_send_val         ; end
                8'h0A:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-1){1'b0}}                  , b0_intr_ena_send_val          }; end
                8'h0B:   begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-1){1'b0}}                  , b0_intr_status_send_val       }; end
                8'h0C:   begin S_AXI_RDATA =                                                 b0_mperf_send_val              ; end
                default: begin S_AXI_RDATA = 0                                                                              ; end
            endcase

        end else if (b1_read_address_val[15:14] == 2'b01) begin

            case (b1_read_address_val[5: 2])
                4'b0000:  begin S_AXI_RDATA = b1_dma_src_addr_send_val                                                               ; end
                4'b0001:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_DATA_SIZE_WIDTH    ){1'b0}},  b1_dma_src_size_send_val       }; end
                4'b0010:  begin S_AXI_RDATA =                                                        b1_dma_des_addr_send_val        ; end
                4'b0011:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_DATA_SIZE_WIDTH    ){1'b0}},  b1_dma_des_size_send_val       }; end
                4'b0100:  begin S_AXI_RDATA =                                                        b1_prof_recon_send_val          ; end
                4'b0101:  begin S_AXI_RDATA =                                                        b1_prof_exec_send_val           ; end
                4'b0110:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_RM_SELECT_WIDTH    ){1'b0}},  b1_vs_rm_recon_select_send_val }; end
                4'b0111:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_RM_SELECT_WIDTH    ){1'b0}},  b1_vs_rm_exec_select_send_val  }; end
                4'b1000:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_DATA_POOL_MASK_WIDTH){1'b0}}, b1_load_mask_send_val          }; end
                4'b1001:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_DATA_POOL_MASK_WIDTH){1'b0}}, b1_store_mask_send_val         }; end
                4'b1010:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_DATA_POOL_MASK_WIDTH){1'b0}}, b1_complete_mask_send_val      }; end
                4'b1011:  begin S_AXI_RDATA = {{(GLOB_DATA_WIDTH-BANK1_INDEX_WIDTH         ){1'b0}}, b1_next_session_send_val       }; end

            endcase

        end
    end
end

endmodule
