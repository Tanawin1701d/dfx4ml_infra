module Stream_Master_Dummy #
(
    parameter integer DATA_WIDTH        = 32,
    parameter integer AMT_ROW           = 1024
)
(
    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI_TDATA,
//    output  wire [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  wire                      M_AXI_TVALID,
    input   wire                      M_AXI_TREADY,
    output  wire                      M_AXI_TLAST,

    input   wire clk,
    input   wire nreset
);

assign M_AXI_TDATA   = 0; // Dummy implementation, always output zero
//assign M_AXI_TKEEP   = 0; // Dummy implementation, always output zero
assign M_AXI_TVALID  = 1'b0; // Dummy implementation, always not valid
assign M_AXI_TLAST   = 1'b0; // Dummy implementation, always not last

endmodule
