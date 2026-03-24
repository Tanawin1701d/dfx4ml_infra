
module DummyStreamS2m #
(
    parameter integer DATA_WIDTH        = 32
)
(
    // AXIS Master Interface load interface
    output  reg  [DATA_WIDTH-1:0]     M_AXI_TDATA,
    output  wire [DATA_WIDTH/8-1:0]   M_AXI_TKEEP,  // <= tkeep added
    output  reg                      M_AXI_TVALID,
    input   wire                     M_AXI_TREADY,
    output  reg                      M_AXI_TLAST,

    input  wire [DATA_WIDTH-1:0]     S_AXI_TDATA,
    input  wire [DATA_WIDTH/8-1:0]   S_AXI_TKEEP,  // <= tkeep added
    input  wire                      S_AXI_TVALID,
    output wire                      S_AXI_TREADY,
    input  wire                      S_AXI_TLAST,

    input   wire clk,
    input   wire nreset
);


    assign S_AXI_TREADY = nreset && ((!sending) || M_AXI_TREADY);
    assign M_AXI_TKEEP  = 4'b1111;
    reg    sending;
    wire   ready_for_next =  nreset && S_AXI_TVALID && S_AXI_TREADY;
    
    // Dummy transfer from slave to master
    always @(posedge clk) begin
        if (!nreset) begin
            M_AXI_TVALID <= 1'b0;
            M_AXI_TDATA  <= {DATA_WIDTH{1'b0}};
            M_AXI_TLAST  <= 1'b0;
            sending      <= 1'b0;
        end else begin
            if (ready_for_next) begin
                M_AXI_TVALID <= 1'b1;
                M_AXI_TDATA  <= S_AXI_TDATA;
                M_AXI_TLAST  <= S_AXI_TLAST;
                sending      <= 1'b1;
            end else if (M_AXI_TREADY) begin
                M_AXI_TVALID <= 1'b0;
                M_AXI_TDATA  <= 48;
                M_AXI_TLAST  <= 1'b0;
                sending      <= 0;
            end
        end
    end

endmodule