// Per-region DFX Decoupler Control Mux (instance for region REGION_IDX).
// Selects the decoupler source for one RM region.
// ctrl=1: DFX controller drives decoupler (used during partial reconfiguration)
// ctrl=0: PS directly drives decoupler (used during normal operation)
// decup_res can be routed to decup_store, decup_load, or both on the target Dfx_Streamer.
module dfx_decup_ctrl #(
    parameter integer REGION_IDX = 0,
    parameter integer NUM_REGION = 2


) (
    input  wire                    decup_dfx_ctrl,      // decoupler signal from DFX controller (1 = decouple)
    input  wire [NUM_REGION+1-1:0] decup_and_ctrl_ps,   // [NUM_REGION:1]: per-region PS decoupler values; [0]: source-select (1=DFX, 0=PS)
    output wire                    decup_res            // decoupler result for region REGION_IDX
);

wire decup_ps = decup_and_ctrl_ps[REGION_IDX+1];  // PS-driven value for this region
wire ctrl     = decup_and_ctrl_ps[0];              // mux select: 1 = DFX ctrl path, 0 = PS path
assign decup_res = ctrl ? decup_dfx_ctrl : decup_ps;

endmodule

