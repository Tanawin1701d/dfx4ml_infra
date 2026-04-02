module m_axi_read #(
    parameter GLOB_ADDR_WIDTH = 32,
    parameter GLOB_DATA_WIDTH = 32
)(

input wire clk,
input  wire reset,

// Read Address Channel
output  wire [GLOB_ADDR_WIDTH-1:0]  M_AXI_ARADDR,
output  wire                        M_AXI_ARVALID,
input   wire                        M_AXI_ARREADY,

// Read Data Channel
input   wire  [GLOB_ADDR_WIDTH-1:0]   M_AXI_RDATA, ////// read data output acctually it is a reg
input   wire  [1:0]                   M_AXI_RRESP,
input   wire                          M_AXI_RVALID,
output  wire                          M_AXI_RREADY
);


assign M_AXI_ARADDR    = 0;
assign M_AXI_ARVALID   = 0;
assign M_AXI_RREADY    = 0;

endmodule
