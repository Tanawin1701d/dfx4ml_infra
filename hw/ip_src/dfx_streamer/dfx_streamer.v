module Dfx_Streamer #
(
    parameter integer DATA_WIDTH         = 32,
    parameter integer ITF_DATA_WIDTH     = 32,   // the interface data width should larger than
    parameter integer AMT_ROW            = 1024,
    parameter integer STATE_BIT_WIDTH    =  5,
    parameter integer BANK1_ST_MSK_WIDTH =  8,
    parameter integer BANK1_LD_MSK_WIDTH =  8,
    parameter integer STREAMER_IDX       =  1 /// the index is start at one
)
(
    input wire                        clk,
    input wire                        nreset,
    input wire                        decup,

    // AXIS Slave Interface   store in terface
    input  wire [ITF_DATA_WIDTH-1:0] S_AXI_TDATA,
    //    input  wire [DATA_WIDTH/8-1:0] S_AXI_TKEEP_CLEAN,  // <= tkeep added        //// we disable tkeep
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    // AXIS Master Interface load interface
    output  wire [ITF_DATA_WIDTH-1:0]  M_AXI_TDATA,    // it is supposed to be reg
    output  wire [(DATA_WIDTH < 8 ? 1 : DATA_WIDTH/8)-1:0]  M_AXI_TKEEP,    // it is supposed to be reg
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
    output wire [$clog2(AMT_ROW)-1+1:0] dbg_amt_store_bytes,
    output wire [$clog2(AMT_ROW)-1+1:0] dbg_amt_load_bytes

);

    // AXIS Slave Interface   store in terface
    wire [ITF_DATA_WIDTH-1:0] S_AXI_TDATA_CLEAN  = decup ? 0: S_AXI_TDATA;
    wire                      S_AXI_TVALID_CLEAN = decup ? 0: S_AXI_TVALID;
    wire                      S_AXI_TREADY_CLEAN; assign S_AXI_TREADY = S_AXI_TREADY_CLEAN;
    wire                      S_AXI_TLAST_CLEAN  = decup ? 0: S_AXI_TLAST;

    // AXIS Master Interface load interface
    reg [ITF_DATA_WIDTH-1:0]     M_AXI_TDATA_CLEAN; assign M_AXI_TDATA = M_AXI_TDATA_CLEAN;
    reg                          M_AXI_TVALID_CLEAN; assign M_AXI_TVALID = M_AXI_TVALID_CLEAN;
    wire                         M_AXI_TREADY_CLEAN = decup ? 0: M_AXI_TREADY;
    reg                          M_AXI_TLAST_CLEAN; assign M_AXI_TLAST = M_AXI_TLAST_CLEAN;

    //// we accept all dfx controller command to make it easier to compute
    wire storeReset = storeReset_pool[STREAMER_IDX];
    wire loadReset  = loadReset_pool [STREAMER_IDX];
    wire storeInit  = storeInit_pool [STREAMER_IDX];
    wire loadInit   = loadInit_pool  [STREAMER_IDX];



///// declare state

localparam STATUS_IDLE       = 5'b00000;
localparam STATUS_STORE      = 5'b00001; // start store to the pipeline
localparam STATUS_FIN_STORE  = 5'b00010; // latency 1 state to make the pipeline finish
localparam STATUS_PRE_LOAD   = 5'b00100; // latency 1 state to make the load data
localparam STATUS_LOAD       = 5'b01000; // loading the data
localparam STATUS_AFT_LOAD   = 5'b10000; // cleanup the load interface

localparam STORAGE_IDX_WIDTH = $clog2(AMT_ROW);
localparam TRACKER_IDX_WIDTH = STORAGE_IDX_WIDTH + 1;

///// memory banking: align to URAM native depth (4096) to maximize utilization.
///// URAM288B is always 4096x72; wider data uses parallel URAMs (depth stays 4096).
///// Using shallower banks (e.g. 2048) wastes half the URAM depth.
localparam URAM_NATIVE_DEPTH = 4096;
localparam BANK_ROW_LOG2     = $clog2(URAM_NATIVE_DEPTH); // 12
localparam ROWS_PER_BANK     = URAM_NATIVE_DEPTH;         // 4096
localparam NUM_BANKS      = (AMT_ROW + ROWS_PER_BANK - 1) / ROWS_PER_BANK;
localparam BANK_SEL_WIDTH = (NUM_BANKS <= 1) ? 1 : $clog2(NUM_BANKS);

reg[STATE_BIT_WIDTH  -1: 0] state;
reg[TRACKER_IDX_WIDTH-1: 0] amt_store_bytes;
reg[TRACKER_IDX_WIDTH-1: 0] amt_load_bytes;
reg storeIntr;

/////////////////////////////////////
////// pipeline IO //////////////////
/////////////////////////////////////

reg                  s_pip_valid;
reg [DATA_WIDTH-1:0] s_pip_data;

// bank_rdata: plain reg array — dynamic indexing is legal here (unlike generate hierarchy)
reg [DATA_WIDTH-1:0]     bank_rdata [0:NUM_BANKS-1];
reg [BANK_SEL_WIDTH-1:0] bank_sel_q;

// m_pip_data is a 1-cycle-delayed read output, muxed from the correct bank
wire [DATA_WIDTH-1:0] m_pip_data = bank_rdata[bank_sel_q];

/////////////////////////////////////
////// axi signal assign ////////////
/////////////////////////////////////

///////// store
assign S_AXI_TREADY_CLEAN = (state == STATUS_STORE) && S_AXI_TVALID_CLEAN;
///////// load
assign M_AXI_TKEEP   = {(DATA_WIDTH < 8 ? 1 : DATA_WIDTH/8){1'b1}};
///////// interrupt signal
assign finStore = storeIntr;
/////////// debug signal
assign dbg_state           = state;
assign dbg_amt_store_bytes = amt_store_bytes;
assign dbg_amt_load_bytes  = amt_load_bytes;

/////////////////////////////////////
///// Memory: generate one bank per ROWS_PER_BANK rows
///// Write and read entirely inside generate so only static indices are used.
///// bank_rdata (plain reg array) is used for the output mux outside.
/////////////////////////////////////

// Read address and enable (combinatorial from registered control signals)
wire rd_preload = (state == STATUS_PRE_LOAD); // load on preload
wire rd_load_en = (state == STATUS_LOAD) &&   // load to contiue
                  ((M_AXI_TVALID_CLEAN && M_AXI_TREADY_CLEAN) | (amt_load_bytes == 0)) &&
                  ((amt_load_bytes + 1) < amt_store_bytes);
wire                       rd_en   = rd_preload | rd_load_en;
wire [TRACKER_IDX_WIDTH:0] rd_addr = rd_preload ? 0 : (amt_load_bytes + 1);

genvar b;
generate
    for (b = 0; b < NUM_BANKS; b = b + 1) begin : MEM_BANK
        (* ram_style = "ultra" *) reg [DATA_WIDTH-1:0] mem [0:ROWS_PER_BANK-1];

        always @(posedge clk) begin
            // write port — enabled only for the matching bank (static b used here)
            if (s_pip_valid && ((amt_store_bytes - 1) >> BANK_ROW_LOG2 == b))
                mem[(amt_store_bytes - 1) & (ROWS_PER_BANK - 1)] <= s_pip_data;

            // read port — output to flat reg array (static b used here)
            if (rd_en && (rd_addr >> BANK_ROW_LOG2 == b))
                bank_rdata[b] <= mem[rd_addr & (ROWS_PER_BANK - 1)];
        end
    end
endgenerate

// Register bank select so it aligns with bank_rdata latency
always @(posedge clk) begin
    if (rd_en)
        bank_sel_q <= rd_addr >> BANK_ROW_LOG2;
end

/////////////////////////////////////
////// control system    ////////////
/////////////////////////////////////
always @(posedge clk) begin

    if (~nreset) begin
        state              <= STATUS_IDLE;
        amt_store_bytes    <= 0;
        amt_load_bytes     <= -1;
        storeIntr          <= 0;
        M_AXI_TVALID_CLEAN <= 0;
        s_pip_valid        <= 0;
    end else begin
        case (state)
            STATUS_IDLE    : begin
                    if (storeReset) begin
                        amt_store_bytes <= 0;
                    end else if (loadReset) begin
                        amt_load_bytes <= -1;
                    end else if (storeInit) begin
                        state <= STATUS_STORE;
                    end else if (loadInit & (amt_store_bytes > 0)) begin
                        state <= STATUS_PRE_LOAD;
                    end
                    M_AXI_TVALID_CLEAN <= 0;
                    s_pip_valid        <= 0;
                    storeIntr          <= 0;
            end
            //////////// case store data to the internal memory
            STATUS_STORE    : begin
                s_pip_valid <= 0;
                if (S_AXI_TVALID_CLEAN)begin
                    amt_store_bytes <= amt_store_bytes + 1;
                    s_pip_valid     <= 1;
                    s_pip_data      <= S_AXI_TDATA_CLEAN[DATA_WIDTH-1:0];
                    if (S_AXI_TLAST_CLEAN)begin
                        state     <= STATUS_FIN_STORE;
                    end
                end
            end

            STATUS_FIN_STORE : begin
                s_pip_valid <= 0;
                storeIntr   <= 1;
                state       <= STATUS_IDLE;
            end

            STATUS_PRE_LOAD : begin
                state <= STATUS_LOAD;
                amt_load_bytes <= amt_load_bytes + 1;
            end

            STATUS_LOAD    : begin

                if ( (M_AXI_TVALID_CLEAN && M_AXI_TREADY_CLEAN) | (amt_load_bytes == 0)) begin

                    M_AXI_TVALID_CLEAN <= 1;
                    M_AXI_TDATA_CLEAN  <= (ITF_DATA_WIDTH > DATA_WIDTH) ?
                                              {{(ITF_DATA_WIDTH-DATA_WIDTH){1'b0}}, m_pip_data} :
                                              m_pip_data;
                    M_AXI_TLAST_CLEAN  <= (amt_load_bytes == (amt_store_bytes-1));
                    amt_load_bytes <= amt_load_bytes + 1;
                    if (amt_load_bytes == (amt_store_bytes-1))begin
                        state <= STATUS_AFT_LOAD;
                    end
                end
            end

            STATUS_AFT_LOAD    : begin
                if (M_AXI_TVALID_CLEAN && M_AXI_TREADY_CLEAN)begin
                    M_AXI_TVALID_CLEAN <= 0;
                    M_AXI_TLAST_CLEAN  <= 0;
                    state <= STATUS_IDLE;
                end
            end

            default: begin end

        endcase
    end

end


endmodule
