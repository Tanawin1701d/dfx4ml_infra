
// Strip HLS byte-padding: HLS zero-pads each sub-byte element to 8 bits.
// This module removes that padding, producing a tightly-packed output stream.
// Example: ap_fixed<4,2> x 64 elements → 512-bit HLS slave in, 256-bit packed master out.
// Applicable for any DATA_WIDTH in [1, 7]; purely combinational (1:1 beat mapping).

module Dfx_Streamer_Aligner_M2S #(
    parameter integer DATA_WIDTH    = 4,    // actual element bit width (must be < 8)
    parameter integer NUM_ELEMENTS  = 64,   // number of elements per AXI-S beat
    // derived — do not override
    parameter integer HLS_WIDTH     = NUM_ELEMENTS * 8,
    parameter integer PACKED_WIDTH  = NUM_ELEMENTS * DATA_WIDTH,
    parameter integer M_TKEEP_WIDTH = (PACKED_WIDTH < 8) ? 1 : PACKED_WIDTH / 8
)(
    // Slave port: receives from HLS master (each element zero-padded to 8 bits)
    input  wire [HLS_WIDTH-1:0]     S_AXI_TDATA,
    input  wire                     S_AXI_TVALID,
    output wire                     S_AXI_TREADY,
    input  wire                     S_AXI_TLAST,

    // Master port: outputs tightly-packed elements (DATA_WIDTH bits each)
    output wire [PACKED_WIDTH-1:0]  M_AXI_TDATA,
    output wire [M_TKEEP_WIDTH-1:0] M_AXI_TKEEP,
    output wire                     M_AXI_TVALID,
    input  wire                     M_AXI_TREADY,
    output wire                     M_AXI_TLAST
);

    assign S_AXI_TREADY = M_AXI_TREADY;
    assign M_AXI_TVALID = S_AXI_TVALID;
    assign M_AXI_TLAST  = S_AXI_TLAST;
    assign M_AXI_TKEEP  = {M_TKEEP_WIDTH{1'b1}};

    // Keep only the lower DATA_WIDTH bits from each 8-bit slot
    genvar i;
    generate
        for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin : gen_pack
            assign M_AXI_TDATA[i*DATA_WIDTH +: DATA_WIDTH] = S_AXI_TDATA[i*8 +: DATA_WIDTH];
        end
    endgenerate

endmodule
