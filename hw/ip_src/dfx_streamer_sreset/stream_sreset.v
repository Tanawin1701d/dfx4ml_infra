module Pr_Reset_Slave #
(
    parameter integer DATA_WIDTH        = 32,
    parameter integer AMT_ROW           = 1024,
    parameter [0:0]   SINK_MODE         = 0
)
(
    input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    output  wire pr_nreset,
    input   wire clk,
    input   wire nreset
);

assign pr_nreset     = S_AXI_TDATA[0];
assign S_AXI_TREADY  = SINK_MODE; // Dummy implementation, always not ready

endmodule