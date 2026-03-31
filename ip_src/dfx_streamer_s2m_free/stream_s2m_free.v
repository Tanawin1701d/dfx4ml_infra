
module Stream_S2M_Free #
(
    parameter integer DATA_WIDTH        = 32
)
(
    // AXIS Master Interface load interface
    output  wire [DATA_WIDTH-1:0]     M_AXI_TDATA,
    output  wire [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  wire                      M_AXI_TVALID,
    input   wire                     M_AXI_TREADY,
    output  wire                      M_AXI_TLAST,

    input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    input   wire clk,
    input   wire nreset
);


// [USER_REQUEST]: freely connect from master to slave
assign M_AXI_TDATA = S_AXI_TDATA;
assign M_AXI_TKEEP = S_AXI_TKEEP;
assign M_AXI_TVALID = S_AXI_TVALID;
assign S_AXI_TREADY = M_AXI_TREADY;
assign M_AXI_TLAST = S_AXI_TLAST;
  
endmodule