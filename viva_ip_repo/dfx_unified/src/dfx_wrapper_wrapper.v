//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Tue Mar 24 13:24:55 2026
//Host        : kathryn2 running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target dfx_wrapper_wrapper.bd
//Design      : dfx_wrapper_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module dfx_wrapper_wrapper
   (M_AXIS_DS0_tdata,
    M_AXIS_DS0_tkeep,
    M_AXIS_DS0_tlast,
    M_AXIS_DS0_tready,
    M_AXIS_DS0_tvalid,
    M_AXIS_DS1_tdata,
    M_AXIS_DS1_tkeep,
    M_AXIS_DS1_tlast,
    M_AXIS_DS1_tready,
    M_AXIS_DS1_tvalid,
    M_AXI_BS_araddr,
    M_AXI_BS_arburst,
    M_AXI_BS_arcache,
    M_AXI_BS_arlen,
    M_AXI_BS_arprot,
    M_AXI_BS_arready,
    M_AXI_BS_arsize,
    M_AXI_BS_aruser,
    M_AXI_BS_arvalid,
    M_AXI_BS_rdata,
    M_AXI_BS_rlast,
    M_AXI_BS_rready,
    M_AXI_BS_rresp,
    M_AXI_BS_rvalid,
    M_AXI_DMA_IN_araddr,
    M_AXI_DMA_IN_arburst,
    M_AXI_DMA_IN_arcache,
    M_AXI_DMA_IN_arlen,
    M_AXI_DMA_IN_arprot,
    M_AXI_DMA_IN_arready,
    M_AXI_DMA_IN_arsize,
    M_AXI_DMA_IN_arvalid,
    M_AXI_DMA_IN_rdata,
    M_AXI_DMA_IN_rlast,
    M_AXI_DMA_IN_rready,
    M_AXI_DMA_IN_rresp,
    M_AXI_DMA_IN_rvalid,
    M_AXI_DMA_OUT_awaddr,
    M_AXI_DMA_OUT_awburst,
    M_AXI_DMA_OUT_awcache,
    M_AXI_DMA_OUT_awlen,
    M_AXI_DMA_OUT_awprot,
    M_AXI_DMA_OUT_awready,
    M_AXI_DMA_OUT_awsize,
    M_AXI_DMA_OUT_awvalid,
    M_AXI_DMA_OUT_bready,
    M_AXI_DMA_OUT_bresp,
    M_AXI_DMA_OUT_bvalid,
    M_AXI_DMA_OUT_wdata,
    M_AXI_DMA_OUT_wlast,
    M_AXI_DMA_OUT_wready,
    M_AXI_DMA_OUT_wstrb,
    M_AXI_DMA_OUT_wvalid,
    S_AXIS_DS0_tdata,
    S_AXIS_DS0_tkeep,
    S_AXIS_DS0_tlast,
    S_AXIS_DS0_tready,
    S_AXIS_DS0_tvalid,
    S_AXIS_DS1_tdata,
    S_AXIS_DS1_tlast,
    S_AXIS_DS1_tready,
    S_AXIS_DS1_tvalid,
    S_AXI_CTRL_araddr,
    S_AXI_CTRL_arburst,
    S_AXI_CTRL_arcache,
    S_AXI_CTRL_arid,
    S_AXI_CTRL_arlen,
    S_AXI_CTRL_arlock,
    S_AXI_CTRL_arprot,
    S_AXI_CTRL_arqos,
    S_AXI_CTRL_arready,
    S_AXI_CTRL_arregion,
    S_AXI_CTRL_arsize,
    S_AXI_CTRL_arvalid,
    S_AXI_CTRL_awaddr,
    S_AXI_CTRL_awburst,
    S_AXI_CTRL_awcache,
    S_AXI_CTRL_awid,
    S_AXI_CTRL_awlen,
    S_AXI_CTRL_awlock,
    S_AXI_CTRL_awprot,
    S_AXI_CTRL_awqos,
    S_AXI_CTRL_awready,
    S_AXI_CTRL_awregion,
    S_AXI_CTRL_awsize,
    S_AXI_CTRL_awvalid,
    S_AXI_CTRL_bid,
    S_AXI_CTRL_bready,
    S_AXI_CTRL_bresp,
    S_AXI_CTRL_bvalid,
    S_AXI_CTRL_rdata,
    S_AXI_CTRL_rid,
    S_AXI_CTRL_rlast,
    S_AXI_CTRL_rready,
    S_AXI_CTRL_rresp,
    S_AXI_CTRL_rvalid,
    S_AXI_CTRL_wdata,
    S_AXI_CTRL_wlast,
    S_AXI_CTRL_wready,
    S_AXI_CTRL_wstrb,
    S_AXI_CTRL_wvalid,
    clk,
    dbg_amt_load_bytes_0,
    dbg_amt_store_bytes_0,
    dbg_state_0,
    dfx_intr,
    nreset,
    pr_reset);
  output [31:0]M_AXIS_DS0_tdata;
  output [3:0]M_AXIS_DS0_tkeep;
  output M_AXIS_DS0_tlast;
  input M_AXIS_DS0_tready;
  output M_AXIS_DS0_tvalid;
  output [31:0]M_AXIS_DS1_tdata;
  output [3:0]M_AXIS_DS1_tkeep;
  output M_AXIS_DS1_tlast;
  input M_AXIS_DS1_tready;
  output M_AXIS_DS1_tvalid;
  output [31:0]M_AXI_BS_araddr;
  output [1:0]M_AXI_BS_arburst;
  output [3:0]M_AXI_BS_arcache;
  output [7:0]M_AXI_BS_arlen;
  output [2:0]M_AXI_BS_arprot;
  input M_AXI_BS_arready;
  output [2:0]M_AXI_BS_arsize;
  output [3:0]M_AXI_BS_aruser;
  output M_AXI_BS_arvalid;
  input [31:0]M_AXI_BS_rdata;
  input M_AXI_BS_rlast;
  output M_AXI_BS_rready;
  input [1:0]M_AXI_BS_rresp;
  input M_AXI_BS_rvalid;
  output [31:0]M_AXI_DMA_IN_araddr;
  output [1:0]M_AXI_DMA_IN_arburst;
  output [3:0]M_AXI_DMA_IN_arcache;
  output [7:0]M_AXI_DMA_IN_arlen;
  output [2:0]M_AXI_DMA_IN_arprot;
  input M_AXI_DMA_IN_arready;
  output [2:0]M_AXI_DMA_IN_arsize;
  output M_AXI_DMA_IN_arvalid;
  input [31:0]M_AXI_DMA_IN_rdata;
  input M_AXI_DMA_IN_rlast;
  output M_AXI_DMA_IN_rready;
  input [1:0]M_AXI_DMA_IN_rresp;
  input M_AXI_DMA_IN_rvalid;
  output [31:0]M_AXI_DMA_OUT_awaddr;
  output [1:0]M_AXI_DMA_OUT_awburst;
  output [3:0]M_AXI_DMA_OUT_awcache;
  output [7:0]M_AXI_DMA_OUT_awlen;
  output [2:0]M_AXI_DMA_OUT_awprot;
  input M_AXI_DMA_OUT_awready;
  output [2:0]M_AXI_DMA_OUT_awsize;
  output M_AXI_DMA_OUT_awvalid;
  output M_AXI_DMA_OUT_bready;
  input [1:0]M_AXI_DMA_OUT_bresp;
  input M_AXI_DMA_OUT_bvalid;
  output [31:0]M_AXI_DMA_OUT_wdata;
  output M_AXI_DMA_OUT_wlast;
  input M_AXI_DMA_OUT_wready;
  output [3:0]M_AXI_DMA_OUT_wstrb;
  output M_AXI_DMA_OUT_wvalid;
  input [31:0]S_AXIS_DS0_tdata;
  input [3:0]S_AXIS_DS0_tkeep;
  input S_AXIS_DS0_tlast;
  output S_AXIS_DS0_tready;
  input S_AXIS_DS0_tvalid;
  input [31:0]S_AXIS_DS1_tdata;
  input S_AXIS_DS1_tlast;
  output S_AXIS_DS1_tready;
  input S_AXIS_DS1_tvalid;
  input [31:0]S_AXI_CTRL_araddr;
  input [1:0]S_AXI_CTRL_arburst;
  input [3:0]S_AXI_CTRL_arcache;
  input [0:0]S_AXI_CTRL_arid;
  input [7:0]S_AXI_CTRL_arlen;
  input [0:0]S_AXI_CTRL_arlock;
  input [2:0]S_AXI_CTRL_arprot;
  input [3:0]S_AXI_CTRL_arqos;
  output S_AXI_CTRL_arready;
  input [3:0]S_AXI_CTRL_arregion;
  input [2:0]S_AXI_CTRL_arsize;
  input S_AXI_CTRL_arvalid;
  input [31:0]S_AXI_CTRL_awaddr;
  input [1:0]S_AXI_CTRL_awburst;
  input [3:0]S_AXI_CTRL_awcache;
  input [0:0]S_AXI_CTRL_awid;
  input [7:0]S_AXI_CTRL_awlen;
  input [0:0]S_AXI_CTRL_awlock;
  input [2:0]S_AXI_CTRL_awprot;
  input [3:0]S_AXI_CTRL_awqos;
  output S_AXI_CTRL_awready;
  input [3:0]S_AXI_CTRL_awregion;
  input [2:0]S_AXI_CTRL_awsize;
  input S_AXI_CTRL_awvalid;
  output [0:0]S_AXI_CTRL_bid;
  input S_AXI_CTRL_bready;
  output [1:0]S_AXI_CTRL_bresp;
  output S_AXI_CTRL_bvalid;
  output [31:0]S_AXI_CTRL_rdata;
  output [0:0]S_AXI_CTRL_rid;
  output S_AXI_CTRL_rlast;
  input S_AXI_CTRL_rready;
  output [1:0]S_AXI_CTRL_rresp;
  output S_AXI_CTRL_rvalid;
  input [31:0]S_AXI_CTRL_wdata;
  input S_AXI_CTRL_wlast;
  output S_AXI_CTRL_wready;
  input [3:0]S_AXI_CTRL_wstrb;
  input S_AXI_CTRL_wvalid;
  input clk;
  output [10:0]dbg_amt_load_bytes_0;
  output [10:0]dbg_amt_store_bytes_0;
  output [3:0]dbg_state_0;
  output dfx_intr;
  input nreset;
  output [0:0]pr_reset;

  wire [31:0]M_AXIS_DS0_tdata;
  wire [3:0]M_AXIS_DS0_tkeep;
  wire M_AXIS_DS0_tlast;
  wire M_AXIS_DS0_tready;
  wire M_AXIS_DS0_tvalid;
  wire [31:0]M_AXIS_DS1_tdata;
  wire [3:0]M_AXIS_DS1_tkeep;
  wire M_AXIS_DS1_tlast;
  wire M_AXIS_DS1_tready;
  wire M_AXIS_DS1_tvalid;
  wire [31:0]M_AXI_BS_araddr;
  wire [1:0]M_AXI_BS_arburst;
  wire [3:0]M_AXI_BS_arcache;
  wire [7:0]M_AXI_BS_arlen;
  wire [2:0]M_AXI_BS_arprot;
  wire M_AXI_BS_arready;
  wire [2:0]M_AXI_BS_arsize;
  wire [3:0]M_AXI_BS_aruser;
  wire M_AXI_BS_arvalid;
  wire [31:0]M_AXI_BS_rdata;
  wire M_AXI_BS_rlast;
  wire M_AXI_BS_rready;
  wire [1:0]M_AXI_BS_rresp;
  wire M_AXI_BS_rvalid;
  wire [31:0]M_AXI_DMA_IN_araddr;
  wire [1:0]M_AXI_DMA_IN_arburst;
  wire [3:0]M_AXI_DMA_IN_arcache;
  wire [7:0]M_AXI_DMA_IN_arlen;
  wire [2:0]M_AXI_DMA_IN_arprot;
  wire M_AXI_DMA_IN_arready;
  wire [2:0]M_AXI_DMA_IN_arsize;
  wire M_AXI_DMA_IN_arvalid;
  wire [31:0]M_AXI_DMA_IN_rdata;
  wire M_AXI_DMA_IN_rlast;
  wire M_AXI_DMA_IN_rready;
  wire [1:0]M_AXI_DMA_IN_rresp;
  wire M_AXI_DMA_IN_rvalid;
  wire [31:0]M_AXI_DMA_OUT_awaddr;
  wire [1:0]M_AXI_DMA_OUT_awburst;
  wire [3:0]M_AXI_DMA_OUT_awcache;
  wire [7:0]M_AXI_DMA_OUT_awlen;
  wire [2:0]M_AXI_DMA_OUT_awprot;
  wire M_AXI_DMA_OUT_awready;
  wire [2:0]M_AXI_DMA_OUT_awsize;
  wire M_AXI_DMA_OUT_awvalid;
  wire M_AXI_DMA_OUT_bready;
  wire [1:0]M_AXI_DMA_OUT_bresp;
  wire M_AXI_DMA_OUT_bvalid;
  wire [31:0]M_AXI_DMA_OUT_wdata;
  wire M_AXI_DMA_OUT_wlast;
  wire M_AXI_DMA_OUT_wready;
  wire [3:0]M_AXI_DMA_OUT_wstrb;
  wire M_AXI_DMA_OUT_wvalid;
  wire [31:0]S_AXIS_DS0_tdata;
  wire [3:0]S_AXIS_DS0_tkeep;
  wire S_AXIS_DS0_tlast;
  wire S_AXIS_DS0_tready;
  wire S_AXIS_DS0_tvalid;
  wire [31:0]S_AXIS_DS1_tdata;
  wire S_AXIS_DS1_tlast;
  wire S_AXIS_DS1_tready;
  wire S_AXIS_DS1_tvalid;
  wire [31:0]S_AXI_CTRL_araddr;
  wire [1:0]S_AXI_CTRL_arburst;
  wire [3:0]S_AXI_CTRL_arcache;
  wire [0:0]S_AXI_CTRL_arid;
  wire [7:0]S_AXI_CTRL_arlen;
  wire [0:0]S_AXI_CTRL_arlock;
  wire [2:0]S_AXI_CTRL_arprot;
  wire [3:0]S_AXI_CTRL_arqos;
  wire S_AXI_CTRL_arready;
  wire [3:0]S_AXI_CTRL_arregion;
  wire [2:0]S_AXI_CTRL_arsize;
  wire S_AXI_CTRL_arvalid;
  wire [31:0]S_AXI_CTRL_awaddr;
  wire [1:0]S_AXI_CTRL_awburst;
  wire [3:0]S_AXI_CTRL_awcache;
  wire [0:0]S_AXI_CTRL_awid;
  wire [7:0]S_AXI_CTRL_awlen;
  wire [0:0]S_AXI_CTRL_awlock;
  wire [2:0]S_AXI_CTRL_awprot;
  wire [3:0]S_AXI_CTRL_awqos;
  wire S_AXI_CTRL_awready;
  wire [3:0]S_AXI_CTRL_awregion;
  wire [2:0]S_AXI_CTRL_awsize;
  wire S_AXI_CTRL_awvalid;
  wire [0:0]S_AXI_CTRL_bid;
  wire S_AXI_CTRL_bready;
  wire [1:0]S_AXI_CTRL_bresp;
  wire S_AXI_CTRL_bvalid;
  wire [31:0]S_AXI_CTRL_rdata;
  wire [0:0]S_AXI_CTRL_rid;
  wire S_AXI_CTRL_rlast;
  wire S_AXI_CTRL_rready;
  wire [1:0]S_AXI_CTRL_rresp;
  wire S_AXI_CTRL_rvalid;
  wire [31:0]S_AXI_CTRL_wdata;
  wire S_AXI_CTRL_wlast;
  wire S_AXI_CTRL_wready;
  wire [3:0]S_AXI_CTRL_wstrb;
  wire S_AXI_CTRL_wvalid;
  wire clk;
  wire [10:0]dbg_amt_load_bytes_0;
  wire [10:0]dbg_amt_store_bytes_0;
  wire [3:0]dbg_state_0;
  wire dfx_intr;
  wire nreset;
  wire [0:0]pr_reset;

  dfx_wrapper dfx_wrapper_i
       (.M_AXIS_DS0_tdata(M_AXIS_DS0_tdata),
        .M_AXIS_DS0_tkeep(M_AXIS_DS0_tkeep),
        .M_AXIS_DS0_tlast(M_AXIS_DS0_tlast),
        .M_AXIS_DS0_tready(M_AXIS_DS0_tready),
        .M_AXIS_DS0_tvalid(M_AXIS_DS0_tvalid),
        .M_AXIS_DS1_tdata(M_AXIS_DS1_tdata),
        .M_AXIS_DS1_tkeep(M_AXIS_DS1_tkeep),
        .M_AXIS_DS1_tlast(M_AXIS_DS1_tlast),
        .M_AXIS_DS1_tready(M_AXIS_DS1_tready),
        .M_AXIS_DS1_tvalid(M_AXIS_DS1_tvalid),
        .M_AXI_BS_araddr(M_AXI_BS_araddr),
        .M_AXI_BS_arburst(M_AXI_BS_arburst),
        .M_AXI_BS_arcache(M_AXI_BS_arcache),
        .M_AXI_BS_arlen(M_AXI_BS_arlen),
        .M_AXI_BS_arprot(M_AXI_BS_arprot),
        .M_AXI_BS_arready(M_AXI_BS_arready),
        .M_AXI_BS_arsize(M_AXI_BS_arsize),
        .M_AXI_BS_aruser(M_AXI_BS_aruser),
        .M_AXI_BS_arvalid(M_AXI_BS_arvalid),
        .M_AXI_BS_rdata(M_AXI_BS_rdata),
        .M_AXI_BS_rlast(M_AXI_BS_rlast),
        .M_AXI_BS_rready(M_AXI_BS_rready),
        .M_AXI_BS_rresp(M_AXI_BS_rresp),
        .M_AXI_BS_rvalid(M_AXI_BS_rvalid),
        .M_AXI_DMA_IN_araddr(M_AXI_DMA_IN_araddr),
        .M_AXI_DMA_IN_arburst(M_AXI_DMA_IN_arburst),
        .M_AXI_DMA_IN_arcache(M_AXI_DMA_IN_arcache),
        .M_AXI_DMA_IN_arlen(M_AXI_DMA_IN_arlen),
        .M_AXI_DMA_IN_arprot(M_AXI_DMA_IN_arprot),
        .M_AXI_DMA_IN_arready(M_AXI_DMA_IN_arready),
        .M_AXI_DMA_IN_arsize(M_AXI_DMA_IN_arsize),
        .M_AXI_DMA_IN_arvalid(M_AXI_DMA_IN_arvalid),
        .M_AXI_DMA_IN_rdata(M_AXI_DMA_IN_rdata),
        .M_AXI_DMA_IN_rlast(M_AXI_DMA_IN_rlast),
        .M_AXI_DMA_IN_rready(M_AXI_DMA_IN_rready),
        .M_AXI_DMA_IN_rresp(M_AXI_DMA_IN_rresp),
        .M_AXI_DMA_IN_rvalid(M_AXI_DMA_IN_rvalid),
        .M_AXI_DMA_OUT_awaddr(M_AXI_DMA_OUT_awaddr),
        .M_AXI_DMA_OUT_awburst(M_AXI_DMA_OUT_awburst),
        .M_AXI_DMA_OUT_awcache(M_AXI_DMA_OUT_awcache),
        .M_AXI_DMA_OUT_awlen(M_AXI_DMA_OUT_awlen),
        .M_AXI_DMA_OUT_awprot(M_AXI_DMA_OUT_awprot),
        .M_AXI_DMA_OUT_awready(M_AXI_DMA_OUT_awready),
        .M_AXI_DMA_OUT_awsize(M_AXI_DMA_OUT_awsize),
        .M_AXI_DMA_OUT_awvalid(M_AXI_DMA_OUT_awvalid),
        .M_AXI_DMA_OUT_bready(M_AXI_DMA_OUT_bready),
        .M_AXI_DMA_OUT_bresp(M_AXI_DMA_OUT_bresp),
        .M_AXI_DMA_OUT_bvalid(M_AXI_DMA_OUT_bvalid),
        .M_AXI_DMA_OUT_wdata(M_AXI_DMA_OUT_wdata),
        .M_AXI_DMA_OUT_wlast(M_AXI_DMA_OUT_wlast),
        .M_AXI_DMA_OUT_wready(M_AXI_DMA_OUT_wready),
        .M_AXI_DMA_OUT_wstrb(M_AXI_DMA_OUT_wstrb),
        .M_AXI_DMA_OUT_wvalid(M_AXI_DMA_OUT_wvalid),
        .S_AXIS_DS0_tdata(S_AXIS_DS0_tdata),
        .S_AXIS_DS0_tkeep(S_AXIS_DS0_tkeep),
        .S_AXIS_DS0_tlast(S_AXIS_DS0_tlast),
        .S_AXIS_DS0_tready(S_AXIS_DS0_tready),
        .S_AXIS_DS0_tvalid(S_AXIS_DS0_tvalid),
        .S_AXIS_DS1_tdata(S_AXIS_DS1_tdata),
        .S_AXIS_DS1_tlast(S_AXIS_DS1_tlast),
        .S_AXIS_DS1_tready(S_AXIS_DS1_tready),
        .S_AXIS_DS1_tvalid(S_AXIS_DS1_tvalid),
        .S_AXI_CTRL_araddr(S_AXI_CTRL_araddr),
        .S_AXI_CTRL_arburst(S_AXI_CTRL_arburst),
        .S_AXI_CTRL_arcache(S_AXI_CTRL_arcache),
        .S_AXI_CTRL_arid(S_AXI_CTRL_arid),
        .S_AXI_CTRL_arlen(S_AXI_CTRL_arlen),
        .S_AXI_CTRL_arlock(S_AXI_CTRL_arlock),
        .S_AXI_CTRL_arprot(S_AXI_CTRL_arprot),
        .S_AXI_CTRL_arqos(S_AXI_CTRL_arqos),
        .S_AXI_CTRL_arready(S_AXI_CTRL_arready),
        .S_AXI_CTRL_arregion(S_AXI_CTRL_arregion),
        .S_AXI_CTRL_arsize(S_AXI_CTRL_arsize),
        .S_AXI_CTRL_arvalid(S_AXI_CTRL_arvalid),
        .S_AXI_CTRL_awaddr(S_AXI_CTRL_awaddr),
        .S_AXI_CTRL_awburst(S_AXI_CTRL_awburst),
        .S_AXI_CTRL_awcache(S_AXI_CTRL_awcache),
        .S_AXI_CTRL_awid(S_AXI_CTRL_awid),
        .S_AXI_CTRL_awlen(S_AXI_CTRL_awlen),
        .S_AXI_CTRL_awlock(S_AXI_CTRL_awlock),
        .S_AXI_CTRL_awprot(S_AXI_CTRL_awprot),
        .S_AXI_CTRL_awqos(S_AXI_CTRL_awqos),
        .S_AXI_CTRL_awready(S_AXI_CTRL_awready),
        .S_AXI_CTRL_awregion(S_AXI_CTRL_awregion),
        .S_AXI_CTRL_awsize(S_AXI_CTRL_awsize),
        .S_AXI_CTRL_awvalid(S_AXI_CTRL_awvalid),
        .S_AXI_CTRL_bid(S_AXI_CTRL_bid),
        .S_AXI_CTRL_bready(S_AXI_CTRL_bready),
        .S_AXI_CTRL_bresp(S_AXI_CTRL_bresp),
        .S_AXI_CTRL_bvalid(S_AXI_CTRL_bvalid),
        .S_AXI_CTRL_rdata(S_AXI_CTRL_rdata),
        .S_AXI_CTRL_rid(S_AXI_CTRL_rid),
        .S_AXI_CTRL_rlast(S_AXI_CTRL_rlast),
        .S_AXI_CTRL_rready(S_AXI_CTRL_rready),
        .S_AXI_CTRL_rresp(S_AXI_CTRL_rresp),
        .S_AXI_CTRL_rvalid(S_AXI_CTRL_rvalid),
        .S_AXI_CTRL_wdata(S_AXI_CTRL_wdata),
        .S_AXI_CTRL_wlast(S_AXI_CTRL_wlast),
        .S_AXI_CTRL_wready(S_AXI_CTRL_wready),
        .S_AXI_CTRL_wstrb(S_AXI_CTRL_wstrb),
        .S_AXI_CTRL_wvalid(S_AXI_CTRL_wvalid),
        .clk(clk),
        .dbg_amt_load_bytes_0(dbg_amt_load_bytes_0),
        .dbg_amt_store_bytes_0(dbg_amt_store_bytes_0),
        .dbg_state_0(dbg_state_0),
        .dfx_intr(dfx_intr),
        .nreset(nreset),
        .pr_reset(pr_reset));
endmodule
