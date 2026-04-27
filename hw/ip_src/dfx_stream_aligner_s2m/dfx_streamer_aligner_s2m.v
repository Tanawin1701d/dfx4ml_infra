
// Add HLS byte-padding: HLS expects each sub-byte element in its own 8-bit slot.
// This module zero-pads each tightly-packed element to 8 bits for HLS slave input.
// Example: 256-bit packed in (ap_fixed<4,2> x 64) → 512-bit HLS-padded master out.
// Applicable for any DATA_WIDTH in [1, 7]; purely combinational (1:1 beat mapping).

module Dfx_Streamer_Aligner_S2M #(
    parameter integer DATA_WIDTH   = 4,   // actual element bit width (must be < 8)
    parameter integer NUM_ELEMENTS = 64   // number of elements per AXI-S beat
)(
    // Slave port: receives tightly-packed elements (DATA_WIDTH bits each)
    input  wire [NUM_ELEMENTS*DATA_WIDTH-1:0]  S_AXI_TDATA,
    input  wire                                S_AXI_TVALID,
    output wire                                S_AXI_TREADY,
    input  wire                                S_AXI_TLAST,

    // Master port: outputs to HLS slave (each element zero-padded to 8 bits)
    output wire [NUM_ELEMENTS*8-1:0]           M_AXI_TDATA,
    output wire [NUM_ELEMENTS-1:0]             M_AXI_TKEEP,
    output wire                                M_AXI_TVALID,
    input  wire                                M_AXI_TREADY,
    output wire                                M_AXI_TLAST,

    input   wire clk,
    input   wire nreset
);

    assign S_AXI_TREADY = M_AXI_TREADY;
    assign M_AXI_TVALID = S_AXI_TVALID;
    assign M_AXI_TLAST  = S_AXI_TLAST;
    assign M_AXI_TKEEP  = {NUM_ELEMENTS{1'b1}};

    // Place each element in the lower DATA_WIDTH bits of its 8-bit slot; zero the upper bits
    genvar i;
    generate
        for (i = 0; i < NUM_ELEMENTS; i = i + 1) begin : gen_unpack
            assign M_AXI_TDATA[i*8 +: DATA_WIDTH] = S_AXI_TDATA[i*DATA_WIDTH +: DATA_WIDTH];
            if (DATA_WIDTH < 8) begin
                assign M_AXI_TDATA[i*8 + DATA_WIDTH +: (8-DATA_WIDTH)] = {(8-DATA_WIDTH){1'b0}};
            end
        end
    endgenerate

endmodule
