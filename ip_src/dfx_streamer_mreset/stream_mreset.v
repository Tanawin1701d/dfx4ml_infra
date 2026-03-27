/* This module is fake the pr reset signal into axi_stream to
enable V++ to able to link this system
*/
module Pr_Reset_Master #
(
    parameter integer DATA_WIDTH  = 32 /// >= 2
)
(
    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXIS_TDATA,
    output  wire                      M_AXIS_TVALID,
    input   wire                      M_AXIS_TREADY,
    output  wire                      M_AXIS_TLAST,

    input   wire pr_nreset,
    input   wire clk,
    input   wire nreset
);

assign M_AXIS_TDATA[DATA_WIDTH-1: 1] = 0; // Dummy implementation, always output zero
assign M_AXIS_TDATA[0]   = pr_nreset;
assign M_AXIS_TVALID  = 1'b0; // Dummy implementation, always not valid
assign M_AXIS_TLAST   = 1'b0; // Dummy implementation, always not last

endmodule
