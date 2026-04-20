module AXI_Lite_Shut #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire clk,
    input  wire nreset,

    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input  wire                        S_AXI_AWVALID,
    output wire                        S_AXI_AWREADY,

    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]       S_AXI_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0]   S_AXI_WSTRB,
    input  wire                        S_AXI_WVALID,
    output wire                        S_AXI_WREADY,

    // Write Response Channel
    output wire [1:0]  S_AXI_BRESP,
    output wire        S_AXI_BVALID,
    input  wire        S_AXI_BREADY,

    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire                  S_AXI_ARVALID,
    output wire                  S_AXI_ARREADY,

    // Read Data Channel
    output wire [DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [1:0]            S_AXI_RRESP,
    output wire                  S_AXI_RVALID,
    input  wire                  S_AXI_RREADY
);

assign S_AXI_AWREADY = 1;
assign S_AXI_WREADY  = 1;
assign S_AXI_BRESP   = 0;
assign S_AXI_BVALID  = 1;
assign S_AXI_ARREADY = 1;
assign S_AXI_RDATA   = 1;
assign S_AXI_RRESP   = 0;
assign S_AXI_RVALID  = 1;

//
////------------------------------------------------------
//// Write path
//// Accepts AW and W independently; fires BVALID once both
//// are received; stalls only while BVALID is pending.
////------------------------------------------------------
//
//reg aw_recv;   // write address received, waiting for data
//reg w_recv;    // write data received, waiting for address
//reg bvalid_r;
//
//wire aw_fire = S_AXI_AWVALID & S_AXI_AWREADY;
//wire w_fire  = S_AXI_WVALID  & S_AXI_WREADY;
//
//assign S_AXI_AWREADY = ~bvalid_r & ~aw_recv;
//assign S_AXI_WREADY  = ~bvalid_r & ~w_recv;
//assign S_AXI_BVALID  = bvalid_r;
//assign S_AXI_BRESP   = 2'b00; // OKAY
//
//always @(posedge clk or negedge nreset) begin
//    if (~nreset) begin
//        aw_recv  <= 0;
//        w_recv   <= 0;
//        bvalid_r <= 0;
//    end else begin
//        if (bvalid_r & S_AXI_BREADY) begin
//            // response accepted — return to idle
//            bvalid_r <= 0;
//            aw_recv  <= 0;
//            w_recv   <= 0;
//        end else begin
//            if (aw_fire) aw_recv <= 1;
//            if (w_fire)  w_recv  <= 1;
//            // assert BVALID once both halves are in hand
//            if ((aw_recv | aw_fire) & (w_recv | w_fire))
//                bvalid_r <= 1;
//        end
//    end
//end
//
////------------------------------------------------------
//// Read path
//// Always accepts AR; returns RDATA=0 (OKAY) one cycle later.
////------------------------------------------------------
//
//reg rvalid_r;
//
//assign S_AXI_ARREADY = ~rvalid_r;
//assign S_AXI_RVALID  = rvalid_r;
//assign S_AXI_RDATA   = {DATA_WIDTH{1'b0}};
//assign S_AXI_RRESP   = 2'b00; // OKAY
//
//always @(posedge clk or negedge nreset) begin
//    if (~nreset) begin
//        rvalid_r <= 0;
//    end else begin
//        if (rvalid_r & S_AXI_RREADY)
//            rvalid_r <= 0;
//        else if (S_AXI_ARVALID & S_AXI_ARREADY)
//            rvalid_r <= 1;
//    end
//end

endmodule
