
module Stream_Single_S2M #
(
    parameter integer S_DATA_WIDTH      = 32,
    parameter integer M_DATA_WIDTH      = 32
)
(
    // AXIS Master Interface
    output  reg  [M_DATA_WIDTH-1:0]       M_AXI_TDATA,
    output  wire [M_DATA_WIDTH/8-1:0]     M_AXI_TKEEP,
    output  reg                           M_AXI_TVALID,
    input   wire                          M_AXI_TREADY,
    output  reg                           M_AXI_TLAST,

    // AXIS Slave Interface
    input  wire [S_DATA_WIDTH-1:0]        S_AXI_TDATA,
    input  wire [S_DATA_WIDTH/8-1:0]      S_AXI_TKEEP,
    input  wire                           S_AXI_TVALID,
    output wire                           S_AXI_TREADY,
    input  wire                           S_AXI_TLAST,

    input   wire clk,
    input   wire nreset
);

    assign S_AXI_TREADY = nreset && ((!sending) || M_AXI_TREADY);
    assign M_AXI_TKEEP  = {(M_DATA_WIDTH/8){1'b1}};
    reg    sending;
    wire   ready_for_next = nreset && S_AXI_TVALID && S_AXI_TREADY;

    wire [M_DATA_WIDTH-1:0] tdata_adapted;
    generate
        if (M_DATA_WIDTH > S_DATA_WIDTH) begin
            localparam REPS = M_DATA_WIDTH / S_DATA_WIDTH;
            assign tdata_adapted = {REPS{S_AXI_TDATA}};
        end else begin
            assign tdata_adapted = S_AXI_TDATA[M_DATA_WIDTH-1:0];
        end
    endgenerate

    always @(posedge clk) begin
        if (!nreset) begin
            M_AXI_TVALID <= 1'b0;
            M_AXI_TDATA  <= {M_DATA_WIDTH{1'b0}};
            M_AXI_TLAST  <= 1'b0;
            sending      <= 1'b0;
        end else begin
            if (ready_for_next) begin
                M_AXI_TVALID <= 1'b1;
                M_AXI_TDATA  <= tdata_adapted;
                M_AXI_TLAST  <= S_AXI_TLAST;
                sending      <= 1'b1;
            end else if (M_AXI_TREADY) begin
                M_AXI_TVALID <= 1'b0;
                M_AXI_TDATA  <= {M_DATA_WIDTH{1'b0}};
                M_AXI_TLAST  <= 1'b0;
                sending      <= 0;
            end
        end
    end

endmodule
