module Dfx_Streamer #
(
    parameter integer DATA_WIDTH         = 32,
    parameter integer ITF_DATA_WIDTH     = 32,   // the interface data width should larger than
    parameter integer STORAGE_IDX_WIDTH  = 10,     //// 4 Kb
    parameter integer STATE_BIT_WIDTH    =  4,
    parameter integer BANK1_ST_MSK_WIDTH =  8,
    parameter integer BANK1_LD_MSK_WIDTH =  8,
    parameter integer STREAMER_IDX       =  1 /// the index is start at one
)
(
    input wire                        clk,
    input wire                        reset,
    input wire                        decup,

    // AXIS Slave Interface   store in terface
    input  wire [ITF_DATA_WIDTH-1:0] S_AXI_TDATA,
//    input  wire [DATA_WIDTH/8-1:0] S_AXI_TKEEP_CLEAN,  // <= tkeep added        //// we disable tkeep
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    // AXIS Master Interface load interface
    output  wire [ITF_DATA_WIDTH-1:0]  M_AXI_TDATA,    // it is supposed to be reg
//    output  wire [DATA_WIDTH/8-1:0]  M_AXI_TKEEP,    // it is supposed to be reg
    output  wire                       M_AXI_TVALID,    // it is supposed to be reg
    input   wire                       M_AXI_TREADY,    // it is supposed to be reg
    output  wire                       M_AXI_TLAST,    // it is supposed to be reg



    // control signal

    input wire[BANK1_ST_MSK_WIDTH-1: 0] storeReset_pool,
    input wire[BANK1_LD_MSK_WIDTH-1: 0] loadReset_pool,
    input wire[BANK1_ST_MSK_WIDTH-1: 0] storeInit_pool,
    input wire[BANK1_LD_MSK_WIDTH-1: 0] loadInit_pool,

    // store complete connect it to mgsFinExec
    output wire finStore,

    // out put wire for debugging
    output wire [STATE_BIT_WIDTH-1:0]   dbg_state,
    output wire [(STORAGE_IDX_WIDTH+1)-1:0] dbg_amt_store_bytes,
    output wire [(STORAGE_IDX_WIDTH+1)-1:0] dbg_amt_load_bytes

);

    // AXIS Slave Interface   store in terface
    wire [ITF_DATA_WIDTH-1:0] S_AXI_TDATA_CLEAN  = decup ? 0: S_AXI_TDATA;
    wire                      S_AXI_TVALID_CLEAN = decup ? 0: S_AXI_TVALID;
    wire                      S_AXI_TREADY_CLEAN; assign S_AXI_TREADY = S_AXI_TREADY_CLEAN;
    wire                      S_AXI_TLAST_CLEAN  = S_AXI_TLAST;

    // AXIS Master Interface load interface
    reg [ITF_DATA_WIDTH-1:0]     M_AXI_TDATA_CLEAN; assign M_AXI_TDATA = M_AXI_TDATA_CLEAN;   // it is supposed to be reg
    reg                          M_AXI_TVALID_CLEAN; assign M_AXI_TVALID = M_AXI_TVALID_CLEAN;   // it is supposed to be reg
    wire                         M_AXI_TREADY_CLEAN = decup ? 0: M_AXI_TREADY;    // it is supposed to be reg
    reg                          M_AXI_TLAST_CLEAN; assign M_AXI_TLAST = M_AXI_TLAST_CLEAN;     // it is supposed to be reg

    //// we accept all dfx controller command to make it easier to compute
    wire storeReset = storeReset_pool[STREAMER_IDX];
    wire loadReset  = loadReset_pool [STREAMER_IDX];
    wire storeInit  = storeInit_pool [STREAMER_IDX];
    wire loadInit   = loadInit_pool  [STREAMER_IDX];



///// declare state

localparam STATUS_IDLE       = 4'b0000;
localparam STATUS_STORE      = 4'b0001;
localparam STATUS_LOAD       = 4'b0010;

localparam TRACKER_IDX_WIDTH = STORAGE_IDX_WIDTH + 1; ///// this is for tracker index width

///// meta data
(* ram_style = "block" *) reg[DATA_WIDTH-1: 0] mainMem [0: ((1 << STORAGE_IDX_WIDTH) - 1)];

reg[STATE_BIT_WIDTH  -1: 0] state;
reg[TRACKER_IDX_WIDTH-1: 0] amt_store_bytes; ///// store to this block
reg[TRACKER_IDX_WIDTH-1: 0] amt_load_bytes;  ///// load to this block
reg storeIntr;

/////////////////////////////////////
////// axi signal assign ////////////
/////////////////////////////////////

///////// store
assign S_AXI_TREADY_CLEAN = (state == STATUS_STORE) && S_AXI_TVALID_CLEAN;
///////// load
////assign M_AXI_TKEEP   = 4'b1111;
///////// interrupt signal
assign finStore = storeIntr;
/////////// debug signal
assign dbg_state           = state;
assign dbg_amt_store_bytes = amt_store_bytes;
assign dbg_amt_load_bytes  = amt_load_bytes;

/////////////////////////////////////
////// control system    ////////////
/////////////////////////////////////
always @(posedge clk, negedge reset) begin

    if (~reset) begin
        state           <= STATUS_IDLE;
        amt_store_bytes <= 0;
        amt_load_bytes  <= 0;
        storeIntr       <= 0;
    end else begin
        case (state)
            STATUS_IDLE    : begin
                    if (storeReset) begin
                        amt_store_bytes <= 0;
                        storeIntr       <= 0;
                    end else if (loadReset) begin
                        amt_load_bytes <= 0;
                        storeIntr      <= 0;
                    end else if (storeInit) begin
                        state <= STATUS_STORE;
                    end else if (loadInit & (amt_store_bytes > 0)) begin
                        state <= STATUS_LOAD;
                    end
            end
            //////////// case store data to the internal memory
            STATUS_STORE    : begin
                if (S_AXI_TVALID_CLEAN)begin //// we are sure that ready will send this time
                    amt_store_bytes <= amt_store_bytes + 1;
                    if (S_AXI_TLAST_CLEAN)begin
                        storeIntr <= 1;
                        state     <= STATUS_IDLE;
                    end
                end
            end
            STATUS_LOAD    : begin
                if (M_AXI_TREADY_CLEAN | (amt_load_bytes == 0)) begin //// last sending is success in this cycle/ send next
                    if ( amt_load_bytes == amt_store_bytes )begin
                        /////// no data to send anymore
                        M_AXI_TVALID_CLEAN <= 0;
                        M_AXI_TLAST_CLEAN  <= 0;
                        state <= STATUS_IDLE;
                    end else begin
                        M_AXI_TVALID_CLEAN <= 1;
                        M_AXI_TLAST_CLEAN  <= (amt_load_bytes == (amt_store_bytes-1));
                        amt_load_bytes <= amt_load_bytes + 1;
                    end
                end
                ///// at here do nothing just wait for hls4ml to ready to get data
            end
            default: begin end

        endcase
    end

end


/////////////////////////////////////
///// M_DATA and MEM management
/////////////////////////////////////

always @(posedge clk) begin
    if (state == STATUS_STORE)begin
        if (S_AXI_TVALID_CLEAN)begin
            mainMem[amt_store_bytes[STORAGE_IDX_WIDTH-1: 0]] <=  S_AXI_TDATA_CLEAN[DATA_WIDTH-1:0];
        end

    end else if (state == STATUS_LOAD) begin

        if (M_AXI_TREADY_CLEAN | (amt_load_bytes == 0))begin
            if (amt_load_bytes == amt_store_bytes)begin
                M_AXI_TDATA_CLEAN <= 48;
            end else begin
                M_AXI_TDATA_CLEAN <= (ITF_DATA_WIDTH > DATA_WIDTH) ?
                       {{(ITF_DATA_WIDTH-DATA_WIDTH){1'b0}},
                         mainMem[amt_load_bytes[STORAGE_IDX_WIDTH-1:0]]
                       } :
                        mainMem[amt_load_bytes[STORAGE_IDX_WIDTH-1:0]];
            end
        end

    end
end


endmodule
