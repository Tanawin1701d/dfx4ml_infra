// DFX Decoupler Control Mux
// Selects between DFX controller signal and PS-side signal.
// ctrl=1: DFX controller drives decoupler (used during partial reconfiguration)
// ctrl=0: PS directly drives decoupler (used during normal operation)
module dfx_decup_ctrl (
    input  wire       decup_dfx_ctrl,      // decoupler signal from DFX controller
    input  wire [1:0] decup_and_ctrl_ps,   // [1]: PS decoupler signal, [0]: source-select (1=DFX, 0=PS)
    output wire       decup_res            // decoupler output to hardware
);

wire decup_ps = decup_and_ctrl_ps[1];  // PS-driven decoupler value
wire ctrl     = decup_and_ctrl_ps[0];  // mux select: 1 = use DFX ctrl path
assign decup_res = ctrl ? decup_dfx_ctrl : decup_ps;

endmodule

