//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Tue Mar 24 13:24:55 2026
//Host        : kathryn2 running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target dfx_wrapper.bd
//Design      : dfx_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "dfx_wrapper,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dfx_wrapper,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=26,numReposBlks=17,numNonXlnxBlks=3,numHierBlks=9,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=1,da_clkrst_cnt=6,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "dfx_wrapper.hwdef" *) 
module dfx_wrapper
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_DS0, CLK_DOMAIN dfx_wrapper_clk, FREQ_HZ 99999001, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [31:0]M_AXIS_DS0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS0 TKEEP" *) output [3:0]M_AXIS_DS0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS0 TLAST" *) output M_AXIS_DS0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS0 TREADY" *) input M_AXIS_DS0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS0 TVALID" *) output M_AXIS_DS0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS1 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_DS1, CLK_DOMAIN dfx_wrapper_clk, FREQ_HZ 99999001, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [31:0]M_AXIS_DS1_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS1 TKEEP" *) output [3:0]M_AXIS_DS1_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS1 TLAST" *) output M_AXIS_DS1_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS1 TREADY" *) input M_AXIS_DS1_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_DS1 TVALID" *) output M_AXIS_DS1_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_BS, ADDR_WIDTH 32, ARUSER_WIDTH 4, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN dfx_wrapper_clk, DATA_WIDTH 32, FREQ_HZ 99999001, HAS_BRESP 0, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 0, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_ONLY, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M_AXI_BS_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARBURST" *) output [1:0]M_AXI_BS_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARCACHE" *) output [3:0]M_AXI_BS_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARLEN" *) output [7:0]M_AXI_BS_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARPROT" *) output [2:0]M_AXI_BS_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARREADY" *) input M_AXI_BS_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARSIZE" *) output [2:0]M_AXI_BS_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARUSER" *) output [3:0]M_AXI_BS_aruser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS ARVALID" *) output M_AXI_BS_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS RDATA" *) input [31:0]M_AXI_BS_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS RLAST" *) input M_AXI_BS_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS RREADY" *) output M_AXI_BS_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS RRESP" *) input [1:0]M_AXI_BS_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_BS RVALID" *) input M_AXI_BS_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_DMA_IN, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN dfx_wrapper_clk, DATA_WIDTH 32, FREQ_HZ 99999001, HAS_BRESP 0, HAS_BURST 0, HAS_CACHE 1, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 0, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 16, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_ONLY, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M_AXI_DMA_IN_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARBURST" *) output [1:0]M_AXI_DMA_IN_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARCACHE" *) output [3:0]M_AXI_DMA_IN_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARLEN" *) output [7:0]M_AXI_DMA_IN_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARPROT" *) output [2:0]M_AXI_DMA_IN_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARREADY" *) input M_AXI_DMA_IN_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARSIZE" *) output [2:0]M_AXI_DMA_IN_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN ARVALID" *) output M_AXI_DMA_IN_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN RDATA" *) input [31:0]M_AXI_DMA_IN_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN RLAST" *) input M_AXI_DMA_IN_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN RREADY" *) output M_AXI_DMA_IN_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN RRESP" *) input [1:0]M_AXI_DMA_IN_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_IN RVALID" *) input M_AXI_DMA_IN_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_DMA_OUT, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN dfx_wrapper_clk, DATA_WIDTH 32, FREQ_HZ 99999001, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 1, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 0, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 16, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE WRITE_ONLY, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M_AXI_DMA_OUT_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWBURST" *) output [1:0]M_AXI_DMA_OUT_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWCACHE" *) output [3:0]M_AXI_DMA_OUT_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWLEN" *) output [7:0]M_AXI_DMA_OUT_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWPROT" *) output [2:0]M_AXI_DMA_OUT_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWREADY" *) input M_AXI_DMA_OUT_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWSIZE" *) output [2:0]M_AXI_DMA_OUT_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT AWVALID" *) output M_AXI_DMA_OUT_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT BREADY" *) output M_AXI_DMA_OUT_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT BRESP" *) input [1:0]M_AXI_DMA_OUT_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT BVALID" *) input M_AXI_DMA_OUT_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT WDATA" *) output [31:0]M_AXI_DMA_OUT_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT WLAST" *) output M_AXI_DMA_OUT_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT WREADY" *) input M_AXI_DMA_OUT_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT WSTRB" *) output [3:0]M_AXI_DMA_OUT_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_DMA_OUT WVALID" *) output M_AXI_DMA_OUT_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_DS0, CLK_DOMAIN dfx_wrapper_clk, FREQ_HZ 99999001, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [31:0]S_AXIS_DS0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS0 TKEEP" *) input [3:0]S_AXIS_DS0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS0 TLAST" *) input S_AXIS_DS0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS0 TREADY" *) output S_AXIS_DS0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS0 TVALID" *) input S_AXIS_DS0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS1 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_DS1, CLK_DOMAIN dfx_wrapper_clk, FREQ_HZ 99999001, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [31:0]S_AXIS_DS1_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS1 TLAST" *) input S_AXIS_DS1_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS1 TREADY" *) output S_AXIS_DS1_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_DS1 TVALID" *) input S_AXIS_DS1_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_CTRL, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN dfx_wrapper_clk, DATA_WIDTH 32, FREQ_HZ 99999001, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 1, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]S_AXI_CTRL_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARBURST" *) input [1:0]S_AXI_CTRL_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARCACHE" *) input [3:0]S_AXI_CTRL_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARID" *) input [0:0]S_AXI_CTRL_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARLEN" *) input [7:0]S_AXI_CTRL_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARLOCK" *) input [0:0]S_AXI_CTRL_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARPROT" *) input [2:0]S_AXI_CTRL_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARQOS" *) input [3:0]S_AXI_CTRL_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARREADY" *) output S_AXI_CTRL_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARREGION" *) input [3:0]S_AXI_CTRL_arregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARSIZE" *) input [2:0]S_AXI_CTRL_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL ARVALID" *) input S_AXI_CTRL_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWADDR" *) input [31:0]S_AXI_CTRL_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWBURST" *) input [1:0]S_AXI_CTRL_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWCACHE" *) input [3:0]S_AXI_CTRL_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWID" *) input [0:0]S_AXI_CTRL_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWLEN" *) input [7:0]S_AXI_CTRL_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWLOCK" *) input [0:0]S_AXI_CTRL_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWPROT" *) input [2:0]S_AXI_CTRL_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWQOS" *) input [3:0]S_AXI_CTRL_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWREADY" *) output S_AXI_CTRL_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWREGION" *) input [3:0]S_AXI_CTRL_awregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWSIZE" *) input [2:0]S_AXI_CTRL_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL AWVALID" *) input S_AXI_CTRL_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL BID" *) output [0:0]S_AXI_CTRL_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL BREADY" *) input S_AXI_CTRL_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL BRESP" *) output [1:0]S_AXI_CTRL_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL BVALID" *) output S_AXI_CTRL_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RDATA" *) output [31:0]S_AXI_CTRL_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RID" *) output [0:0]S_AXI_CTRL_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RLAST" *) output S_AXI_CTRL_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RREADY" *) input S_AXI_CTRL_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RRESP" *) output [1:0]S_AXI_CTRL_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL RVALID" *) output S_AXI_CTRL_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL WDATA" *) input [31:0]S_AXI_CTRL_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL WLAST" *) input S_AXI_CTRL_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL WREADY" *) output S_AXI_CTRL_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL WSTRB" *) input [3:0]S_AXI_CTRL_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_CTRL WVALID" *) input S_AXI_CTRL_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_BUSIF M_AXI_DMA_IN:M_AXI_DMA_OUT:M_AXIS_DS0:S_AXIS_DS0:S_AXIS_DS1:S_AXI_CTRL:M_AXI_BS:M_AXIS_DS1, ASSOCIATED_RESET nreset, CLK_DOMAIN dfx_wrapper_clk, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk;
  output [10:0]dbg_amt_load_bytes_0;
  output [10:0]dbg_amt_store_bytes_0;
  output [3:0]dbg_state_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.DFX_INTR INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.DFX_INTR, PortWidth 1, SENSITIVITY LEVEL_HIGH" *) output dfx_intr;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.NRESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.NRESET, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input nreset;
  output [0:0]pr_reset;

  wire [31:0]DFX_Ctrl_0_M_AXI_ARADDR;
  wire [0:0]DFX_Ctrl_0_M_AXI_ARREADY;
  wire DFX_Ctrl_0_M_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_M_AXI_AWADDR;
  wire [0:0]DFX_Ctrl_0_M_AXI_AWREADY;
  wire DFX_Ctrl_0_M_AXI_AWVALID;
  wire DFX_Ctrl_0_M_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_M_AXI_BRESP;
  wire [0:0]DFX_Ctrl_0_M_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_M_AXI_RDATA;
  wire DFX_Ctrl_0_M_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_M_AXI_RRESP;
  wire [0:0]DFX_Ctrl_0_M_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_M_AXI_WDATA;
  wire [0:0]DFX_Ctrl_0_M_AXI_WREADY;
  wire [3:0]DFX_Ctrl_0_M_AXI_WSTRB;
  wire DFX_Ctrl_0_M_AXI_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M00_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_RDATA;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M00_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_WREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M01_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M01_AXI_ARREADY;
  wire [0:0]DFX_Ctrl_0_axi_periph_M01_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M01_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M01_AXI_AWREADY;
  wire [0:0]DFX_Ctrl_0_axi_periph_M01_AXI_AWVALID;
  wire [0:0]DFX_Ctrl_0_axi_periph_M01_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M01_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M01_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M01_AXI_RDATA;
  wire [0:0]DFX_Ctrl_0_axi_periph_M01_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M01_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M01_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M01_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M01_AXI_WREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_M01_AXI_WSTRB;
  wire [0:0]DFX_Ctrl_0_axi_periph_M01_AXI_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M02_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_ARREADY;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M02_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_AWREADY;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_AWVALID;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M02_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M02_AXI_RDATA;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M02_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M02_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_WREADY;
  wire DFX_Ctrl_0_axi_periph_M02_AXI_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M03_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_ARREADY;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M03_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_AWREADY;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_AWVALID;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M03_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M03_AXI_RDATA;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M03_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M03_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_WREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_M03_AXI_WSTRB;
  wire DFX_Ctrl_0_axi_periph_M03_AXI_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M04_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_ARREADY;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M04_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_AWREADY;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_AWVALID;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M04_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M04_AXI_RDATA;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M04_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M04_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_WREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_M04_AXI_WSTRB;
  wire DFX_Ctrl_0_axi_periph_M04_AXI_WVALID;
  wire [7:0]DFX_Ctrl_0_slaveMgsLoadInit;
  wire [7:0]DFX_Ctrl_0_slaveMgsLoadReset;
  wire [7:0]DFX_Ctrl_0_slaveMgsStoreInit;
  wire [7:0]DFX_Ctrl_0_slaveMgsStoreReset;
  wire DFX_Ctrl_A_hw_intr;
  wire [7:0]DFX_Ctrl_A_slaveReprog;
  wire DFX_Ctrl_B_ICAP_avail;
  wire DFX_Ctrl_B_ICAP_csib;
  wire [31:0]DFX_Ctrl_B_ICAP_i;
  wire [31:0]DFX_Ctrl_B_ICAP_o;
  wire DFX_Ctrl_B_ICAP_prdone;
  wire DFX_Ctrl_B_ICAP_prerror;
  wire DFX_Ctrl_B_ICAP_rdwrb;
  wire [31:0]DFX_Ctrl_B_M_AXI_MEM_ARADDR;
  wire [1:0]DFX_Ctrl_B_M_AXI_MEM_ARBURST;
  wire [3:0]DFX_Ctrl_B_M_AXI_MEM_ARCACHE;
  wire [7:0]DFX_Ctrl_B_M_AXI_MEM_ARLEN;
  wire [2:0]DFX_Ctrl_B_M_AXI_MEM_ARPROT;
  wire DFX_Ctrl_B_M_AXI_MEM_ARREADY;
  wire [2:0]DFX_Ctrl_B_M_AXI_MEM_ARSIZE;
  wire [3:0]DFX_Ctrl_B_M_AXI_MEM_ARUSER;
  wire DFX_Ctrl_B_M_AXI_MEM_ARVALID;
  wire [31:0]DFX_Ctrl_B_M_AXI_MEM_RDATA;
  wire DFX_Ctrl_B_M_AXI_MEM_RLAST;
  wire DFX_Ctrl_B_M_AXI_MEM_RREADY;
  wire [1:0]DFX_Ctrl_B_M_AXI_MEM_RRESP;
  wire DFX_Ctrl_B_M_AXI_MEM_RVALID;
  wire DFX_Ctrl_B_vsm_vs4ml_rm_decouple;
  wire DFX_Ctrl_B_vsm_vs4ml_rm_reset;
  wire [31:0]Dfx_Streamer_1_M_AXI_TDATA;
  wire [3:0]Dfx_Streamer_1_M_AXI_TKEEP;
  wire Dfx_Streamer_1_M_AXI_TLAST;
  wire Dfx_Streamer_1_M_AXI_TREADY;
  wire Dfx_Streamer_1_M_AXI_TVALID;
  wire [10:0]Dfx_Streamer_1_dbg_amt_load_bytes;
  wire [10:0]Dfx_Streamer_1_dbg_amt_store_bytes;
  wire [3:0]Dfx_Streamer_1_dbg_state;
  wire Dfx_Streamer_1_finStore;
  wire [31:0]S01_AXI_0_1_ARADDR;
  wire [1:0]S01_AXI_0_1_ARBURST;
  wire [3:0]S01_AXI_0_1_ARCACHE;
  wire [0:0]S01_AXI_0_1_ARID;
  wire [7:0]S01_AXI_0_1_ARLEN;
  wire [0:0]S01_AXI_0_1_ARLOCK;
  wire [2:0]S01_AXI_0_1_ARPROT;
  wire [3:0]S01_AXI_0_1_ARQOS;
  wire S01_AXI_0_1_ARREADY;
  wire [3:0]S01_AXI_0_1_ARREGION;
  wire [2:0]S01_AXI_0_1_ARSIZE;
  wire S01_AXI_0_1_ARVALID;
  wire [31:0]S01_AXI_0_1_AWADDR;
  wire [1:0]S01_AXI_0_1_AWBURST;
  wire [3:0]S01_AXI_0_1_AWCACHE;
  wire [0:0]S01_AXI_0_1_AWID;
  wire [7:0]S01_AXI_0_1_AWLEN;
  wire [0:0]S01_AXI_0_1_AWLOCK;
  wire [2:0]S01_AXI_0_1_AWPROT;
  wire [3:0]S01_AXI_0_1_AWQOS;
  wire S01_AXI_0_1_AWREADY;
  wire [3:0]S01_AXI_0_1_AWREGION;
  wire [2:0]S01_AXI_0_1_AWSIZE;
  wire S01_AXI_0_1_AWVALID;
  wire [0:0]S01_AXI_0_1_BID;
  wire S01_AXI_0_1_BREADY;
  wire [1:0]S01_AXI_0_1_BRESP;
  wire S01_AXI_0_1_BVALID;
  wire [31:0]S01_AXI_0_1_RDATA;
  wire [0:0]S01_AXI_0_1_RID;
  wire S01_AXI_0_1_RLAST;
  wire S01_AXI_0_1_RREADY;
  wire [1:0]S01_AXI_0_1_RRESP;
  wire S01_AXI_0_1_RVALID;
  wire [31:0]S01_AXI_0_1_WDATA;
  wire S01_AXI_0_1_WLAST;
  wire S01_AXI_0_1_WREADY;
  wire [3:0]S01_AXI_0_1_WSTRB;
  wire S01_AXI_0_1_WVALID;
  wire [31:0]S_AXIS_DS0_1_TDATA;
  wire [3:0]S_AXIS_DS0_1_TKEEP;
  wire S_AXIS_DS0_1_TLAST;
  wire S_AXIS_DS0_1_TREADY;
  wire S_AXIS_DS0_1_TVALID;
  wire [31:0]S_AXI_0_1_TDATA;
  wire S_AXI_0_1_TLAST;
  wire S_AXI_0_1_TREADY;
  wire S_AXI_0_1_TVALID;
  wire [0:0]axi_dfx_decup_gpio_io_o;
  wire [0:0]axi_dfx_reset_gpio_io_o;
  wire [31:0]axi_dma_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_0_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_0_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_0_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARPROT;
  wire axi_dma_0_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARSIZE;
  wire axi_dma_0_M_AXI_MM2S_ARVALID;
  wire [31:0]axi_dma_0_M_AXI_MM2S_RDATA;
  wire axi_dma_0_M_AXI_MM2S_RLAST;
  wire axi_dma_0_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_0_M_AXI_MM2S_RRESP;
  wire axi_dma_0_M_AXI_MM2S_RVALID;
  wire [31:0]axi_dma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_dma_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_dma_0_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_dma_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWPROT;
  wire axi_dma_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWSIZE;
  wire axi_dma_0_M_AXI_S2MM_AWVALID;
  wire axi_dma_0_M_AXI_S2MM_BREADY;
  wire [1:0]axi_dma_0_M_AXI_S2MM_BRESP;
  wire axi_dma_0_M_AXI_S2MM_BVALID;
  wire [31:0]axi_dma_0_M_AXI_S2MM_WDATA;
  wire axi_dma_0_M_AXI_S2MM_WLAST;
  wire axi_dma_0_M_AXI_S2MM_WREADY;
  wire [3:0]axi_dma_0_M_AXI_S2MM_WSTRB;
  wire axi_dma_0_M_AXI_S2MM_WVALID;
  wire axi_dma_0_s2mm_introut;
  wire clk_0_1;
  wire [31:0]dfx_decoupler_1_rp_intf_0_TDATA;
  wire [3:0]dfx_decoupler_1_rp_intf_0_TKEEP;
  wire dfx_decoupler_1_rp_intf_0_TLAST;
  wire dfx_decoupler_1_rp_intf_0_TREADY;
  wire dfx_decoupler_1_rp_intf_0_TVALID;
  wire reset_0_1;
  wire [0:0]reset_join_Res;
  wire [0:0]util_vector_logic_0_Res;
  wire [7:0]xlconcat_0_dout;
  wire [0:0]xlconstant_0_dout;
  wire [5:0]xlconstant_1_dout;
  wire [0:0]xlconstant_2_dout;

  assign DFX_Ctrl_B_M_AXI_MEM_ARREADY = M_AXI_BS_arready;
  assign DFX_Ctrl_B_M_AXI_MEM_RDATA = M_AXI_BS_rdata[31:0];
  assign DFX_Ctrl_B_M_AXI_MEM_RLAST = M_AXI_BS_rlast;
  assign DFX_Ctrl_B_M_AXI_MEM_RRESP = M_AXI_BS_rresp[1:0];
  assign DFX_Ctrl_B_M_AXI_MEM_RVALID = M_AXI_BS_rvalid;
  assign Dfx_Streamer_1_M_AXI_TREADY = M_AXIS_DS1_tready;
  assign M_AXIS_DS0_tdata[31:0] = dfx_decoupler_1_rp_intf_0_TDATA;
  assign M_AXIS_DS0_tkeep[3:0] = dfx_decoupler_1_rp_intf_0_TKEEP;
  assign M_AXIS_DS0_tlast = dfx_decoupler_1_rp_intf_0_TLAST;
  assign M_AXIS_DS0_tvalid = dfx_decoupler_1_rp_intf_0_TVALID;
  assign M_AXIS_DS1_tdata[31:0] = Dfx_Streamer_1_M_AXI_TDATA;
  assign M_AXIS_DS1_tkeep[3:0] = Dfx_Streamer_1_M_AXI_TKEEP;
  assign M_AXIS_DS1_tlast = Dfx_Streamer_1_M_AXI_TLAST;
  assign M_AXIS_DS1_tvalid = Dfx_Streamer_1_M_AXI_TVALID;
  assign M_AXI_BS_araddr[31:0] = DFX_Ctrl_B_M_AXI_MEM_ARADDR;
  assign M_AXI_BS_arburst[1:0] = DFX_Ctrl_B_M_AXI_MEM_ARBURST;
  assign M_AXI_BS_arcache[3:0] = DFX_Ctrl_B_M_AXI_MEM_ARCACHE;
  assign M_AXI_BS_arlen[7:0] = DFX_Ctrl_B_M_AXI_MEM_ARLEN;
  assign M_AXI_BS_arprot[2:0] = DFX_Ctrl_B_M_AXI_MEM_ARPROT;
  assign M_AXI_BS_arsize[2:0] = DFX_Ctrl_B_M_AXI_MEM_ARSIZE;
  assign M_AXI_BS_aruser[3:0] = DFX_Ctrl_B_M_AXI_MEM_ARUSER;
  assign M_AXI_BS_arvalid = DFX_Ctrl_B_M_AXI_MEM_ARVALID;
  assign M_AXI_BS_rready = DFX_Ctrl_B_M_AXI_MEM_RREADY;
  assign M_AXI_DMA_IN_araddr[31:0] = axi_dma_0_M_AXI_MM2S_ARADDR;
  assign M_AXI_DMA_IN_arburst[1:0] = axi_dma_0_M_AXI_MM2S_ARBURST;
  assign M_AXI_DMA_IN_arcache[3:0] = axi_dma_0_M_AXI_MM2S_ARCACHE;
  assign M_AXI_DMA_IN_arlen[7:0] = axi_dma_0_M_AXI_MM2S_ARLEN;
  assign M_AXI_DMA_IN_arprot[2:0] = axi_dma_0_M_AXI_MM2S_ARPROT;
  assign M_AXI_DMA_IN_arsize[2:0] = axi_dma_0_M_AXI_MM2S_ARSIZE;
  assign M_AXI_DMA_IN_arvalid = axi_dma_0_M_AXI_MM2S_ARVALID;
  assign M_AXI_DMA_IN_rready = axi_dma_0_M_AXI_MM2S_RREADY;
  assign M_AXI_DMA_OUT_awaddr[31:0] = axi_dma_0_M_AXI_S2MM_AWADDR;
  assign M_AXI_DMA_OUT_awburst[1:0] = axi_dma_0_M_AXI_S2MM_AWBURST;
  assign M_AXI_DMA_OUT_awcache[3:0] = axi_dma_0_M_AXI_S2MM_AWCACHE;
  assign M_AXI_DMA_OUT_awlen[7:0] = axi_dma_0_M_AXI_S2MM_AWLEN;
  assign M_AXI_DMA_OUT_awprot[2:0] = axi_dma_0_M_AXI_S2MM_AWPROT;
  assign M_AXI_DMA_OUT_awsize[2:0] = axi_dma_0_M_AXI_S2MM_AWSIZE;
  assign M_AXI_DMA_OUT_awvalid = axi_dma_0_M_AXI_S2MM_AWVALID;
  assign M_AXI_DMA_OUT_bready = axi_dma_0_M_AXI_S2MM_BREADY;
  assign M_AXI_DMA_OUT_wdata[31:0] = axi_dma_0_M_AXI_S2MM_WDATA;
  assign M_AXI_DMA_OUT_wlast = axi_dma_0_M_AXI_S2MM_WLAST;
  assign M_AXI_DMA_OUT_wstrb[3:0] = axi_dma_0_M_AXI_S2MM_WSTRB;
  assign M_AXI_DMA_OUT_wvalid = axi_dma_0_M_AXI_S2MM_WVALID;
  assign S01_AXI_0_1_ARADDR = S_AXI_CTRL_araddr[31:0];
  assign S01_AXI_0_1_ARBURST = S_AXI_CTRL_arburst[1:0];
  assign S01_AXI_0_1_ARCACHE = S_AXI_CTRL_arcache[3:0];
  assign S01_AXI_0_1_ARID = S_AXI_CTRL_arid[0];
  assign S01_AXI_0_1_ARLEN = S_AXI_CTRL_arlen[7:0];
  assign S01_AXI_0_1_ARLOCK = S_AXI_CTRL_arlock[0];
  assign S01_AXI_0_1_ARPROT = S_AXI_CTRL_arprot[2:0];
  assign S01_AXI_0_1_ARQOS = S_AXI_CTRL_arqos[3:0];
  assign S01_AXI_0_1_ARREGION = S_AXI_CTRL_arregion[3:0];
  assign S01_AXI_0_1_ARSIZE = S_AXI_CTRL_arsize[2:0];
  assign S01_AXI_0_1_ARVALID = S_AXI_CTRL_arvalid;
  assign S01_AXI_0_1_AWADDR = S_AXI_CTRL_awaddr[31:0];
  assign S01_AXI_0_1_AWBURST = S_AXI_CTRL_awburst[1:0];
  assign S01_AXI_0_1_AWCACHE = S_AXI_CTRL_awcache[3:0];
  assign S01_AXI_0_1_AWID = S_AXI_CTRL_awid[0];
  assign S01_AXI_0_1_AWLEN = S_AXI_CTRL_awlen[7:0];
  assign S01_AXI_0_1_AWLOCK = S_AXI_CTRL_awlock[0];
  assign S01_AXI_0_1_AWPROT = S_AXI_CTRL_awprot[2:0];
  assign S01_AXI_0_1_AWQOS = S_AXI_CTRL_awqos[3:0];
  assign S01_AXI_0_1_AWREGION = S_AXI_CTRL_awregion[3:0];
  assign S01_AXI_0_1_AWSIZE = S_AXI_CTRL_awsize[2:0];
  assign S01_AXI_0_1_AWVALID = S_AXI_CTRL_awvalid;
  assign S01_AXI_0_1_BREADY = S_AXI_CTRL_bready;
  assign S01_AXI_0_1_RREADY = S_AXI_CTRL_rready;
  assign S01_AXI_0_1_WDATA = S_AXI_CTRL_wdata[31:0];
  assign S01_AXI_0_1_WLAST = S_AXI_CTRL_wlast;
  assign S01_AXI_0_1_WSTRB = S_AXI_CTRL_wstrb[3:0];
  assign S01_AXI_0_1_WVALID = S_AXI_CTRL_wvalid;
  assign S_AXIS_DS0_1_TDATA = S_AXIS_DS0_tdata[31:0];
  assign S_AXIS_DS0_1_TKEEP = S_AXIS_DS0_tkeep[3:0];
  assign S_AXIS_DS0_1_TLAST = S_AXIS_DS0_tlast;
  assign S_AXIS_DS0_1_TVALID = S_AXIS_DS0_tvalid;
  assign S_AXIS_DS0_tready = S_AXIS_DS0_1_TREADY;
  assign S_AXIS_DS1_tready = S_AXI_0_1_TREADY;
  assign S_AXI_0_1_TDATA = S_AXIS_DS1_tdata[31:0];
  assign S_AXI_0_1_TLAST = S_AXIS_DS1_tlast;
  assign S_AXI_0_1_TVALID = S_AXIS_DS1_tvalid;
  assign S_AXI_CTRL_arready = S01_AXI_0_1_ARREADY;
  assign S_AXI_CTRL_awready = S01_AXI_0_1_AWREADY;
  assign S_AXI_CTRL_bid[0] = S01_AXI_0_1_BID;
  assign S_AXI_CTRL_bresp[1:0] = S01_AXI_0_1_BRESP;
  assign S_AXI_CTRL_bvalid = S01_AXI_0_1_BVALID;
  assign S_AXI_CTRL_rdata[31:0] = S01_AXI_0_1_RDATA;
  assign S_AXI_CTRL_rid[0] = S01_AXI_0_1_RID;
  assign S_AXI_CTRL_rlast = S01_AXI_0_1_RLAST;
  assign S_AXI_CTRL_rresp[1:0] = S01_AXI_0_1_RRESP;
  assign S_AXI_CTRL_rvalid = S01_AXI_0_1_RVALID;
  assign S_AXI_CTRL_wready = S01_AXI_0_1_WREADY;
  assign axi_dma_0_M_AXI_MM2S_ARREADY = M_AXI_DMA_IN_arready;
  assign axi_dma_0_M_AXI_MM2S_RDATA = M_AXI_DMA_IN_rdata[31:0];
  assign axi_dma_0_M_AXI_MM2S_RLAST = M_AXI_DMA_IN_rlast;
  assign axi_dma_0_M_AXI_MM2S_RRESP = M_AXI_DMA_IN_rresp[1:0];
  assign axi_dma_0_M_AXI_MM2S_RVALID = M_AXI_DMA_IN_rvalid;
  assign axi_dma_0_M_AXI_S2MM_AWREADY = M_AXI_DMA_OUT_awready;
  assign axi_dma_0_M_AXI_S2MM_BRESP = M_AXI_DMA_OUT_bresp[1:0];
  assign axi_dma_0_M_AXI_S2MM_BVALID = M_AXI_DMA_OUT_bvalid;
  assign axi_dma_0_M_AXI_S2MM_WREADY = M_AXI_DMA_OUT_wready;
  assign clk_0_1 = clk;
  assign dbg_amt_load_bytes_0[10:0] = Dfx_Streamer_1_dbg_amt_load_bytes;
  assign dbg_amt_store_bytes_0[10:0] = Dfx_Streamer_1_dbg_amt_store_bytes;
  assign dbg_state_0[3:0] = Dfx_Streamer_1_dbg_state;
  assign dfx_decoupler_1_rp_intf_0_TREADY = M_AXIS_DS0_tready;
  assign dfx_intr = DFX_Ctrl_A_hw_intr;
  assign pr_reset[0] = reset_join_Res;
  assign reset_0_1 = nreset;
  dfx_wrapper_DFX_Ctrl_0_axi_periph_0 DFX_Ctrl_0_axi_periph
       (.ACLK(clk_0_1),
        .ARESETN(reset_0_1),
        .M00_ACLK(clk_0_1),
        .M00_ARESETN(reset_0_1),
        .M00_AXI_araddr(DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR),
        .M00_AXI_arready(DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY),
        .M00_AXI_arvalid(DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID),
        .M00_AXI_awaddr(DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR),
        .M00_AXI_awready(DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY),
        .M00_AXI_awvalid(DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID),
        .M00_AXI_bready(DFX_Ctrl_0_axi_periph_M00_AXI_BREADY),
        .M00_AXI_bresp(DFX_Ctrl_0_axi_periph_M00_AXI_BRESP),
        .M00_AXI_bvalid(DFX_Ctrl_0_axi_periph_M00_AXI_BVALID),
        .M00_AXI_rdata(DFX_Ctrl_0_axi_periph_M00_AXI_RDATA),
        .M00_AXI_rready(DFX_Ctrl_0_axi_periph_M00_AXI_RREADY),
        .M00_AXI_rresp(DFX_Ctrl_0_axi_periph_M00_AXI_RRESP),
        .M00_AXI_rvalid(DFX_Ctrl_0_axi_periph_M00_AXI_RVALID),
        .M00_AXI_wdata(DFX_Ctrl_0_axi_periph_M00_AXI_WDATA),
        .M00_AXI_wready(DFX_Ctrl_0_axi_periph_M00_AXI_WREADY),
        .M00_AXI_wvalid(DFX_Ctrl_0_axi_periph_M00_AXI_WVALID),
        .M01_ACLK(clk_0_1),
        .M01_ARESETN(reset_0_1),
        .M01_AXI_araddr(DFX_Ctrl_0_axi_periph_M01_AXI_ARADDR),
        .M01_AXI_arready(DFX_Ctrl_0_axi_periph_M01_AXI_ARREADY),
        .M01_AXI_arvalid(DFX_Ctrl_0_axi_periph_M01_AXI_ARVALID),
        .M01_AXI_awaddr(DFX_Ctrl_0_axi_periph_M01_AXI_AWADDR),
        .M01_AXI_awready(DFX_Ctrl_0_axi_periph_M01_AXI_AWREADY),
        .M01_AXI_awvalid(DFX_Ctrl_0_axi_periph_M01_AXI_AWVALID),
        .M01_AXI_bready(DFX_Ctrl_0_axi_periph_M01_AXI_BREADY),
        .M01_AXI_bresp(DFX_Ctrl_0_axi_periph_M01_AXI_BRESP),
        .M01_AXI_bvalid(DFX_Ctrl_0_axi_periph_M01_AXI_BVALID),
        .M01_AXI_rdata(DFX_Ctrl_0_axi_periph_M01_AXI_RDATA),
        .M01_AXI_rready(DFX_Ctrl_0_axi_periph_M01_AXI_RREADY),
        .M01_AXI_rresp(DFX_Ctrl_0_axi_periph_M01_AXI_RRESP),
        .M01_AXI_rvalid(DFX_Ctrl_0_axi_periph_M01_AXI_RVALID),
        .M01_AXI_wdata(DFX_Ctrl_0_axi_periph_M01_AXI_WDATA),
        .M01_AXI_wready(DFX_Ctrl_0_axi_periph_M01_AXI_WREADY),
        .M01_AXI_wstrb(DFX_Ctrl_0_axi_periph_M01_AXI_WSTRB),
        .M01_AXI_wvalid(DFX_Ctrl_0_axi_periph_M01_AXI_WVALID),
        .M02_ACLK(clk_0_1),
        .M02_ARESETN(reset_0_1),
        .M02_AXI_araddr(DFX_Ctrl_0_axi_periph_M02_AXI_ARADDR),
        .M02_AXI_arready(DFX_Ctrl_0_axi_periph_M02_AXI_ARREADY),
        .M02_AXI_arvalid(DFX_Ctrl_0_axi_periph_M02_AXI_ARVALID),
        .M02_AXI_awaddr(DFX_Ctrl_0_axi_periph_M02_AXI_AWADDR),
        .M02_AXI_awready(DFX_Ctrl_0_axi_periph_M02_AXI_AWREADY),
        .M02_AXI_awvalid(DFX_Ctrl_0_axi_periph_M02_AXI_AWVALID),
        .M02_AXI_bready(DFX_Ctrl_0_axi_periph_M02_AXI_BREADY),
        .M02_AXI_bresp(DFX_Ctrl_0_axi_periph_M02_AXI_BRESP),
        .M02_AXI_bvalid(DFX_Ctrl_0_axi_periph_M02_AXI_BVALID),
        .M02_AXI_rdata(DFX_Ctrl_0_axi_periph_M02_AXI_RDATA),
        .M02_AXI_rready(DFX_Ctrl_0_axi_periph_M02_AXI_RREADY),
        .M02_AXI_rresp(DFX_Ctrl_0_axi_periph_M02_AXI_RRESP),
        .M02_AXI_rvalid(DFX_Ctrl_0_axi_periph_M02_AXI_RVALID),
        .M02_AXI_wdata(DFX_Ctrl_0_axi_periph_M02_AXI_WDATA),
        .M02_AXI_wready(DFX_Ctrl_0_axi_periph_M02_AXI_WREADY),
        .M02_AXI_wvalid(DFX_Ctrl_0_axi_periph_M02_AXI_WVALID),
        .M03_ACLK(clk_0_1),
        .M03_ARESETN(reset_0_1),
        .M03_AXI_araddr(DFX_Ctrl_0_axi_periph_M03_AXI_ARADDR),
        .M03_AXI_arready(DFX_Ctrl_0_axi_periph_M03_AXI_ARREADY),
        .M03_AXI_arvalid(DFX_Ctrl_0_axi_periph_M03_AXI_ARVALID),
        .M03_AXI_awaddr(DFX_Ctrl_0_axi_periph_M03_AXI_AWADDR),
        .M03_AXI_awready(DFX_Ctrl_0_axi_periph_M03_AXI_AWREADY),
        .M03_AXI_awvalid(DFX_Ctrl_0_axi_periph_M03_AXI_AWVALID),
        .M03_AXI_bready(DFX_Ctrl_0_axi_periph_M03_AXI_BREADY),
        .M03_AXI_bresp(DFX_Ctrl_0_axi_periph_M03_AXI_BRESP),
        .M03_AXI_bvalid(DFX_Ctrl_0_axi_periph_M03_AXI_BVALID),
        .M03_AXI_rdata(DFX_Ctrl_0_axi_periph_M03_AXI_RDATA),
        .M03_AXI_rready(DFX_Ctrl_0_axi_periph_M03_AXI_RREADY),
        .M03_AXI_rresp(DFX_Ctrl_0_axi_periph_M03_AXI_RRESP),
        .M03_AXI_rvalid(DFX_Ctrl_0_axi_periph_M03_AXI_RVALID),
        .M03_AXI_wdata(DFX_Ctrl_0_axi_periph_M03_AXI_WDATA),
        .M03_AXI_wready(DFX_Ctrl_0_axi_periph_M03_AXI_WREADY),
        .M03_AXI_wstrb(DFX_Ctrl_0_axi_periph_M03_AXI_WSTRB),
        .M03_AXI_wvalid(DFX_Ctrl_0_axi_periph_M03_AXI_WVALID),
        .M04_ACLK(clk_0_1),
        .M04_ARESETN(reset_0_1),
        .M04_AXI_araddr(DFX_Ctrl_0_axi_periph_M04_AXI_ARADDR),
        .M04_AXI_arready(DFX_Ctrl_0_axi_periph_M04_AXI_ARREADY),
        .M04_AXI_arvalid(DFX_Ctrl_0_axi_periph_M04_AXI_ARVALID),
        .M04_AXI_awaddr(DFX_Ctrl_0_axi_periph_M04_AXI_AWADDR),
        .M04_AXI_awready(DFX_Ctrl_0_axi_periph_M04_AXI_AWREADY),
        .M04_AXI_awvalid(DFX_Ctrl_0_axi_periph_M04_AXI_AWVALID),
        .M04_AXI_bready(DFX_Ctrl_0_axi_periph_M04_AXI_BREADY),
        .M04_AXI_bresp(DFX_Ctrl_0_axi_periph_M04_AXI_BRESP),
        .M04_AXI_bvalid(DFX_Ctrl_0_axi_periph_M04_AXI_BVALID),
        .M04_AXI_rdata(DFX_Ctrl_0_axi_periph_M04_AXI_RDATA),
        .M04_AXI_rready(DFX_Ctrl_0_axi_periph_M04_AXI_RREADY),
        .M04_AXI_rresp(DFX_Ctrl_0_axi_periph_M04_AXI_RRESP),
        .M04_AXI_rvalid(DFX_Ctrl_0_axi_periph_M04_AXI_RVALID),
        .M04_AXI_wdata(DFX_Ctrl_0_axi_periph_M04_AXI_WDATA),
        .M04_AXI_wready(DFX_Ctrl_0_axi_periph_M04_AXI_WREADY),
        .M04_AXI_wstrb(DFX_Ctrl_0_axi_periph_M04_AXI_WSTRB),
        .M04_AXI_wvalid(DFX_Ctrl_0_axi_periph_M04_AXI_WVALID),
        .S00_ACLK(clk_0_1),
        .S00_ARESETN(reset_0_1),
        .S00_AXI_araddr(DFX_Ctrl_0_M_AXI_ARADDR),
        .S00_AXI_arready(DFX_Ctrl_0_M_AXI_ARREADY),
        .S00_AXI_arvalid(DFX_Ctrl_0_M_AXI_ARVALID),
        .S00_AXI_awaddr(DFX_Ctrl_0_M_AXI_AWADDR),
        .S00_AXI_awready(DFX_Ctrl_0_M_AXI_AWREADY),
        .S00_AXI_awvalid(DFX_Ctrl_0_M_AXI_AWVALID),
        .S00_AXI_bready(DFX_Ctrl_0_M_AXI_BREADY),
        .S00_AXI_bresp(DFX_Ctrl_0_M_AXI_BRESP),
        .S00_AXI_bvalid(DFX_Ctrl_0_M_AXI_BVALID),
        .S00_AXI_rdata(DFX_Ctrl_0_M_AXI_RDATA),
        .S00_AXI_rready(DFX_Ctrl_0_M_AXI_RREADY),
        .S00_AXI_rresp(DFX_Ctrl_0_M_AXI_RRESP),
        .S00_AXI_rvalid(DFX_Ctrl_0_M_AXI_RVALID),
        .S00_AXI_wdata(DFX_Ctrl_0_M_AXI_WDATA),
        .S00_AXI_wready(DFX_Ctrl_0_M_AXI_WREADY),
        .S00_AXI_wstrb(DFX_Ctrl_0_M_AXI_WSTRB),
        .S00_AXI_wvalid(DFX_Ctrl_0_M_AXI_WVALID),
        .S01_ACLK(clk_0_1),
        .S01_ARESETN(reset_0_1),
        .S01_AXI_araddr(S01_AXI_0_1_ARADDR),
        .S01_AXI_arburst(S01_AXI_0_1_ARBURST),
        .S01_AXI_arcache(S01_AXI_0_1_ARCACHE),
        .S01_AXI_arid(S01_AXI_0_1_ARID),
        .S01_AXI_arlen(S01_AXI_0_1_ARLEN),
        .S01_AXI_arlock(S01_AXI_0_1_ARLOCK),
        .S01_AXI_arprot(S01_AXI_0_1_ARPROT),
        .S01_AXI_arqos(S01_AXI_0_1_ARQOS),
        .S01_AXI_arready(S01_AXI_0_1_ARREADY),
        .S01_AXI_arregion(S01_AXI_0_1_ARREGION),
        .S01_AXI_arsize(S01_AXI_0_1_ARSIZE),
        .S01_AXI_arvalid(S01_AXI_0_1_ARVALID),
        .S01_AXI_awaddr(S01_AXI_0_1_AWADDR),
        .S01_AXI_awburst(S01_AXI_0_1_AWBURST),
        .S01_AXI_awcache(S01_AXI_0_1_AWCACHE),
        .S01_AXI_awid(S01_AXI_0_1_AWID),
        .S01_AXI_awlen(S01_AXI_0_1_AWLEN),
        .S01_AXI_awlock(S01_AXI_0_1_AWLOCK),
        .S01_AXI_awprot(S01_AXI_0_1_AWPROT),
        .S01_AXI_awqos(S01_AXI_0_1_AWQOS),
        .S01_AXI_awready(S01_AXI_0_1_AWREADY),
        .S01_AXI_awregion(S01_AXI_0_1_AWREGION),
        .S01_AXI_awsize(S01_AXI_0_1_AWSIZE),
        .S01_AXI_awvalid(S01_AXI_0_1_AWVALID),
        .S01_AXI_bid(S01_AXI_0_1_BID),
        .S01_AXI_bready(S01_AXI_0_1_BREADY),
        .S01_AXI_bresp(S01_AXI_0_1_BRESP),
        .S01_AXI_bvalid(S01_AXI_0_1_BVALID),
        .S01_AXI_rdata(S01_AXI_0_1_RDATA),
        .S01_AXI_rid(S01_AXI_0_1_RID),
        .S01_AXI_rlast(S01_AXI_0_1_RLAST),
        .S01_AXI_rready(S01_AXI_0_1_RREADY),
        .S01_AXI_rresp(S01_AXI_0_1_RRESP),
        .S01_AXI_rvalid(S01_AXI_0_1_RVALID),
        .S01_AXI_wdata(S01_AXI_0_1_WDATA),
        .S01_AXI_wlast(S01_AXI_0_1_WLAST),
        .S01_AXI_wready(S01_AXI_0_1_WREADY),
        .S01_AXI_wstrb(S01_AXI_0_1_WSTRB),
        .S01_AXI_wvalid(S01_AXI_0_1_WVALID));
  dfx_wrapper_DFX_Ctrl_0_0 DFX_Ctrl_A
       (.M_AXI_ARADDR(DFX_Ctrl_0_M_AXI_ARADDR),
        .M_AXI_ARREADY(DFX_Ctrl_0_M_AXI_ARREADY),
        .M_AXI_ARVALID(DFX_Ctrl_0_M_AXI_ARVALID),
        .M_AXI_AWADDR(DFX_Ctrl_0_M_AXI_AWADDR),
        .M_AXI_AWREADY(DFX_Ctrl_0_M_AXI_AWREADY),
        .M_AXI_AWVALID(DFX_Ctrl_0_M_AXI_AWVALID),
        .M_AXI_BREADY(DFX_Ctrl_0_M_AXI_BREADY),
        .M_AXI_BRESP(DFX_Ctrl_0_M_AXI_BRESP),
        .M_AXI_BVALID(DFX_Ctrl_0_M_AXI_BVALID),
        .M_AXI_RDATA(DFX_Ctrl_0_M_AXI_RDATA),
        .M_AXI_RREADY(DFX_Ctrl_0_M_AXI_RREADY),
        .M_AXI_RRESP(DFX_Ctrl_0_M_AXI_RRESP),
        .M_AXI_RVALID(DFX_Ctrl_0_M_AXI_RVALID),
        .M_AXI_WDATA(DFX_Ctrl_0_M_AXI_WDATA),
        .M_AXI_WREADY(DFX_Ctrl_0_M_AXI_WREADY),
        .M_AXI_WSTRB(DFX_Ctrl_0_M_AXI_WSTRB),
        .M_AXI_WVALID(DFX_Ctrl_0_M_AXI_WVALID),
        .S_AXI_ARADDR(DFX_Ctrl_0_axi_periph_M01_AXI_ARADDR[15:0]),
        .S_AXI_ARREADY(DFX_Ctrl_0_axi_periph_M01_AXI_ARREADY),
        .S_AXI_ARVALID(DFX_Ctrl_0_axi_periph_M01_AXI_ARVALID),
        .S_AXI_AWADDR(DFX_Ctrl_0_axi_periph_M01_AXI_AWADDR[15:0]),
        .S_AXI_AWREADY(DFX_Ctrl_0_axi_periph_M01_AXI_AWREADY),
        .S_AXI_AWVALID(DFX_Ctrl_0_axi_periph_M01_AXI_AWVALID),
        .S_AXI_BREADY(DFX_Ctrl_0_axi_periph_M01_AXI_BREADY),
        .S_AXI_BRESP(DFX_Ctrl_0_axi_periph_M01_AXI_BRESP),
        .S_AXI_BVALID(DFX_Ctrl_0_axi_periph_M01_AXI_BVALID),
        .S_AXI_RDATA(DFX_Ctrl_0_axi_periph_M01_AXI_RDATA),
        .S_AXI_RREADY(DFX_Ctrl_0_axi_periph_M01_AXI_RREADY),
        .S_AXI_RRESP(DFX_Ctrl_0_axi_periph_M01_AXI_RRESP),
        .S_AXI_RVALID(DFX_Ctrl_0_axi_periph_M01_AXI_RVALID),
        .S_AXI_WDATA(DFX_Ctrl_0_axi_periph_M01_AXI_WDATA),
        .S_AXI_WREADY(DFX_Ctrl_0_axi_periph_M01_AXI_WREADY),
        .S_AXI_WSTRB(DFX_Ctrl_0_axi_periph_M01_AXI_WSTRB),
        .S_AXI_WVALID(DFX_Ctrl_0_axi_periph_M01_AXI_WVALID),
        .clk(clk_0_1),
        .hw_ctrl_start(xlconstant_0_dout),
        .hw_intr(DFX_Ctrl_A_hw_intr),
        .hw_intr_clear(xlconstant_0_dout),
        .mgsFinExec(xlconcat_0_dout),
        .nslaveReset(reset_join_Res),
        .reset(reset_0_1),
        .slaveMgsLoadInit(DFX_Ctrl_0_slaveMgsLoadInit),
        .slaveMgsLoadReset(DFX_Ctrl_0_slaveMgsLoadReset),
        .slaveMgsStoreInit(DFX_Ctrl_0_slaveMgsStoreInit),
        .slaveMgsStoreReset(DFX_Ctrl_0_slaveMgsStoreReset),
        .slaveReprog(DFX_Ctrl_A_slaveReprog));
  dfx_wrapper_dfx_controller_0_0 DFX_Ctrl_B
       (.clk(clk_0_1),
        .icap_avail(DFX_Ctrl_B_ICAP_avail),
        .icap_clk(clk_0_1),
        .icap_csib(DFX_Ctrl_B_ICAP_csib),
        .icap_i(DFX_Ctrl_B_ICAP_o),
        .icap_o(DFX_Ctrl_B_ICAP_i),
        .icap_prdone(DFX_Ctrl_B_ICAP_prdone),
        .icap_prerror(DFX_Ctrl_B_ICAP_prerror),
        .icap_rdwrb(DFX_Ctrl_B_ICAP_rdwrb),
        .icap_reset(reset_0_1),
        .m_axi_mem_araddr(DFX_Ctrl_B_M_AXI_MEM_ARADDR),
        .m_axi_mem_arburst(DFX_Ctrl_B_M_AXI_MEM_ARBURST),
        .m_axi_mem_arcache(DFX_Ctrl_B_M_AXI_MEM_ARCACHE),
        .m_axi_mem_arlen(DFX_Ctrl_B_M_AXI_MEM_ARLEN),
        .m_axi_mem_arprot(DFX_Ctrl_B_M_AXI_MEM_ARPROT),
        .m_axi_mem_arready(DFX_Ctrl_B_M_AXI_MEM_ARREADY),
        .m_axi_mem_arsize(DFX_Ctrl_B_M_AXI_MEM_ARSIZE),
        .m_axi_mem_aruser(DFX_Ctrl_B_M_AXI_MEM_ARUSER),
        .m_axi_mem_arvalid(DFX_Ctrl_B_M_AXI_MEM_ARVALID),
        .m_axi_mem_rdata(DFX_Ctrl_B_M_AXI_MEM_RDATA),
        .m_axi_mem_rlast(DFX_Ctrl_B_M_AXI_MEM_RLAST),
        .m_axi_mem_rready(DFX_Ctrl_B_M_AXI_MEM_RREADY),
        .m_axi_mem_rresp(DFX_Ctrl_B_M_AXI_MEM_RRESP),
        .m_axi_mem_rvalid(DFX_Ctrl_B_M_AXI_MEM_RVALID),
        .reset(reset_0_1),
        .s_axi_reg_araddr(DFX_Ctrl_0_axi_periph_M02_AXI_ARADDR),
        .s_axi_reg_arready(DFX_Ctrl_0_axi_periph_M02_AXI_ARREADY),
        .s_axi_reg_arvalid(DFX_Ctrl_0_axi_periph_M02_AXI_ARVALID),
        .s_axi_reg_awaddr(DFX_Ctrl_0_axi_periph_M02_AXI_AWADDR),
        .s_axi_reg_awready(DFX_Ctrl_0_axi_periph_M02_AXI_AWREADY),
        .s_axi_reg_awvalid(DFX_Ctrl_0_axi_periph_M02_AXI_AWVALID),
        .s_axi_reg_bready(DFX_Ctrl_0_axi_periph_M02_AXI_BREADY),
        .s_axi_reg_bresp(DFX_Ctrl_0_axi_periph_M02_AXI_BRESP),
        .s_axi_reg_bvalid(DFX_Ctrl_0_axi_periph_M02_AXI_BVALID),
        .s_axi_reg_rdata(DFX_Ctrl_0_axi_periph_M02_AXI_RDATA),
        .s_axi_reg_rready(DFX_Ctrl_0_axi_periph_M02_AXI_RREADY),
        .s_axi_reg_rresp(DFX_Ctrl_0_axi_periph_M02_AXI_RRESP),
        .s_axi_reg_rvalid(DFX_Ctrl_0_axi_periph_M02_AXI_RVALID),
        .s_axi_reg_wdata(DFX_Ctrl_0_axi_periph_M02_AXI_WDATA),
        .s_axi_reg_wready(DFX_Ctrl_0_axi_periph_M02_AXI_WREADY),
        .s_axi_reg_wvalid(DFX_Ctrl_0_axi_periph_M02_AXI_WVALID),
        .vsm_vs4ml_hw_triggers(DFX_Ctrl_A_slaveReprog),
        .vsm_vs4ml_rm_decouple(DFX_Ctrl_B_vsm_vs4ml_rm_decouple),
        .vsm_vs4ml_rm_reset(DFX_Ctrl_B_vsm_vs4ml_rm_reset),
        .vsm_vs4ml_rm_shutdown_ack(xlconstant_2_dout));
  dfx_wrapper_Dfx_Streamer_0_0 Dfx_Streamer_1
       (.M_AXI_TDATA(Dfx_Streamer_1_M_AXI_TDATA),
        .M_AXI_TKEEP(Dfx_Streamer_1_M_AXI_TKEEP),
        .M_AXI_TLAST(Dfx_Streamer_1_M_AXI_TLAST),
        .M_AXI_TREADY(Dfx_Streamer_1_M_AXI_TREADY),
        .M_AXI_TVALID(Dfx_Streamer_1_M_AXI_TVALID),
        .S_AXI_TDATA(S_AXI_0_1_TDATA),
        .S_AXI_TLAST(S_AXI_0_1_TLAST),
        .S_AXI_TREADY(S_AXI_0_1_TREADY),
        .S_AXI_TVALID(S_AXI_0_1_TVALID),
        .clk(clk_0_1),
        .dbg_amt_load_bytes(Dfx_Streamer_1_dbg_amt_load_bytes),
        .dbg_amt_store_bytes(Dfx_Streamer_1_dbg_amt_store_bytes),
        .dbg_state(Dfx_Streamer_1_dbg_state),
        .decup(util_vector_logic_0_Res),
        .finStore(Dfx_Streamer_1_finStore),
        .loadInit_pool(DFX_Ctrl_0_slaveMgsLoadInit),
        .loadReset_pool(DFX_Ctrl_0_slaveMgsLoadReset),
        .reset(reset_0_1),
        .storeInit_pool(DFX_Ctrl_0_slaveMgsStoreInit),
        .storeReset_pool(DFX_Ctrl_0_slaveMgsStoreReset));
  dfx_wrapper_axi_gpio_0_1 axi_dfx_decup
       (.gpio_io_o(axi_dfx_decup_gpio_io_o),
        .s_axi_aclk(clk_0_1),
        .s_axi_araddr(DFX_Ctrl_0_axi_periph_M04_AXI_ARADDR[8:0]),
        .s_axi_aresetn(reset_0_1),
        .s_axi_arready(DFX_Ctrl_0_axi_periph_M04_AXI_ARREADY),
        .s_axi_arvalid(DFX_Ctrl_0_axi_periph_M04_AXI_ARVALID),
        .s_axi_awaddr(DFX_Ctrl_0_axi_periph_M04_AXI_AWADDR[8:0]),
        .s_axi_awready(DFX_Ctrl_0_axi_periph_M04_AXI_AWREADY),
        .s_axi_awvalid(DFX_Ctrl_0_axi_periph_M04_AXI_AWVALID),
        .s_axi_bready(DFX_Ctrl_0_axi_periph_M04_AXI_BREADY),
        .s_axi_bresp(DFX_Ctrl_0_axi_periph_M04_AXI_BRESP),
        .s_axi_bvalid(DFX_Ctrl_0_axi_periph_M04_AXI_BVALID),
        .s_axi_rdata(DFX_Ctrl_0_axi_periph_M04_AXI_RDATA),
        .s_axi_rready(DFX_Ctrl_0_axi_periph_M04_AXI_RREADY),
        .s_axi_rresp(DFX_Ctrl_0_axi_periph_M04_AXI_RRESP),
        .s_axi_rvalid(DFX_Ctrl_0_axi_periph_M04_AXI_RVALID),
        .s_axi_wdata(DFX_Ctrl_0_axi_periph_M04_AXI_WDATA),
        .s_axi_wready(DFX_Ctrl_0_axi_periph_M04_AXI_WREADY),
        .s_axi_wstrb(DFX_Ctrl_0_axi_periph_M04_AXI_WSTRB),
        .s_axi_wvalid(DFX_Ctrl_0_axi_periph_M04_AXI_WVALID));
  dfx_wrapper_axi_gpio_0_0 axi_dfx_reset
       (.gpio_io_o(axi_dfx_reset_gpio_io_o),
        .s_axi_aclk(clk_0_1),
        .s_axi_araddr(DFX_Ctrl_0_axi_periph_M03_AXI_ARADDR[8:0]),
        .s_axi_aresetn(reset_0_1),
        .s_axi_arready(DFX_Ctrl_0_axi_periph_M03_AXI_ARREADY),
        .s_axi_arvalid(DFX_Ctrl_0_axi_periph_M03_AXI_ARVALID),
        .s_axi_awaddr(DFX_Ctrl_0_axi_periph_M03_AXI_AWADDR[8:0]),
        .s_axi_awready(DFX_Ctrl_0_axi_periph_M03_AXI_AWREADY),
        .s_axi_awvalid(DFX_Ctrl_0_axi_periph_M03_AXI_AWVALID),
        .s_axi_bready(DFX_Ctrl_0_axi_periph_M03_AXI_BREADY),
        .s_axi_bresp(DFX_Ctrl_0_axi_periph_M03_AXI_BRESP),
        .s_axi_bvalid(DFX_Ctrl_0_axi_periph_M03_AXI_BVALID),
        .s_axi_rdata(DFX_Ctrl_0_axi_periph_M03_AXI_RDATA),
        .s_axi_rready(DFX_Ctrl_0_axi_periph_M03_AXI_RREADY),
        .s_axi_rresp(DFX_Ctrl_0_axi_periph_M03_AXI_RRESP),
        .s_axi_rvalid(DFX_Ctrl_0_axi_periph_M03_AXI_RVALID),
        .s_axi_wdata(DFX_Ctrl_0_axi_periph_M03_AXI_WDATA),
        .s_axi_wready(DFX_Ctrl_0_axi_periph_M03_AXI_WREADY),
        .s_axi_wstrb(DFX_Ctrl_0_axi_periph_M03_AXI_WSTRB),
        .s_axi_wvalid(DFX_Ctrl_0_axi_periph_M03_AXI_WVALID));
  dma_hier_imp_147877G dma_hier
       (.M_AXIS_DS0_tdata(dfx_decoupler_1_rp_intf_0_TDATA),
        .M_AXIS_DS0_tkeep(dfx_decoupler_1_rp_intf_0_TKEEP),
        .M_AXIS_DS0_tlast(dfx_decoupler_1_rp_intf_0_TLAST),
        .M_AXIS_DS0_tready(dfx_decoupler_1_rp_intf_0_TREADY),
        .M_AXIS_DS0_tvalid(dfx_decoupler_1_rp_intf_0_TVALID),
        .M_AXI_DMA_IN_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .M_AXI_DMA_IN_arburst(axi_dma_0_M_AXI_MM2S_ARBURST),
        .M_AXI_DMA_IN_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .M_AXI_DMA_IN_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .M_AXI_DMA_IN_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .M_AXI_DMA_IN_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .M_AXI_DMA_IN_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .M_AXI_DMA_IN_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .M_AXI_DMA_IN_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .M_AXI_DMA_IN_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .M_AXI_DMA_IN_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .M_AXI_DMA_IN_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .M_AXI_DMA_IN_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .M_AXI_DMA_OUT_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .M_AXI_DMA_OUT_awburst(axi_dma_0_M_AXI_S2MM_AWBURST),
        .M_AXI_DMA_OUT_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .M_AXI_DMA_OUT_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .M_AXI_DMA_OUT_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .M_AXI_DMA_OUT_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .M_AXI_DMA_OUT_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .M_AXI_DMA_OUT_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .M_AXI_DMA_OUT_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .M_AXI_DMA_OUT_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .M_AXI_DMA_OUT_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .M_AXI_DMA_OUT_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .M_AXI_DMA_OUT_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .M_AXI_DMA_OUT_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .M_AXI_DMA_OUT_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .M_AXI_DMA_OUT_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .S_AXIS_DS0_tdata(S_AXIS_DS0_1_TDATA),
        .S_AXIS_DS0_tkeep(S_AXIS_DS0_1_TKEEP),
        .S_AXIS_DS0_tlast(S_AXIS_DS0_1_TLAST),
        .S_AXIS_DS0_tready(S_AXIS_DS0_1_TREADY),
        .S_AXIS_DS0_tvalid(S_AXIS_DS0_1_TVALID),
        .S_AXI_LITE_araddr(DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR),
        .S_AXI_LITE_arready(DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY),
        .S_AXI_LITE_arvalid(DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID),
        .S_AXI_LITE_awaddr(DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR),
        .S_AXI_LITE_awready(DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY),
        .S_AXI_LITE_awvalid(DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID),
        .S_AXI_LITE_bready(DFX_Ctrl_0_axi_periph_M00_AXI_BREADY),
        .S_AXI_LITE_bresp(DFX_Ctrl_0_axi_periph_M00_AXI_BRESP),
        .S_AXI_LITE_bvalid(DFX_Ctrl_0_axi_periph_M00_AXI_BVALID),
        .S_AXI_LITE_rdata(DFX_Ctrl_0_axi_periph_M00_AXI_RDATA),
        .S_AXI_LITE_rready(DFX_Ctrl_0_axi_periph_M00_AXI_RREADY),
        .S_AXI_LITE_rresp(DFX_Ctrl_0_axi_periph_M00_AXI_RRESP),
        .S_AXI_LITE_rvalid(DFX_Ctrl_0_axi_periph_M00_AXI_RVALID),
        .S_AXI_LITE_wdata(DFX_Ctrl_0_axi_periph_M00_AXI_WDATA),
        .S_AXI_LITE_wready(DFX_Ctrl_0_axi_periph_M00_AXI_WREADY),
        .S_AXI_LITE_wvalid(DFX_Ctrl_0_axi_periph_M00_AXI_WVALID),
        .clk(clk_0_1),
        .decouple(util_vector_logic_0_Res),
        .nreset(reset_0_1),
        .s2mm_introut(axi_dma_0_s2mm_introut));
  dfx_wrapper_icapWrap_0_0 icapWrap_0
       (.AVAIL(DFX_Ctrl_B_ICAP_avail),
        .CLK(clk_0_1),
        .CSIB(DFX_Ctrl_B_ICAP_csib),
        .I(DFX_Ctrl_B_ICAP_i),
        .O(DFX_Ctrl_B_ICAP_o),
        .PRDONE(DFX_Ctrl_B_ICAP_prdone),
        .PRERROR(DFX_Ctrl_B_ICAP_prerror),
        .RDWRB(DFX_Ctrl_B_ICAP_rdwrb));
  dfx_wrapper_util_vector_logic_0_0 reset_join
       (.Op1(DFX_Ctrl_B_vsm_vs4ml_rm_reset),
        .Op2(axi_dfx_reset_gpio_io_o),
        .Res(reset_join_Res));
  dfx_wrapper_util_vector_logic_0_1 util_vector_logic_0
       (.Op1(DFX_Ctrl_B_vsm_vs4ml_rm_decouple),
        .Op2(axi_dfx_decup_gpio_io_o),
        .Res(util_vector_logic_0_Res));
  dfx_wrapper_xlconcat_0_0 xlconcat_0
       (.In0(axi_dma_0_s2mm_introut),
        .In1(Dfx_Streamer_1_finStore),
        .In2(xlconstant_1_dout),
        .dout(xlconcat_0_dout));
  dfx_wrapper_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  dfx_wrapper_xlconstant_1_0 xlconstant_1
       (.dout(xlconstant_1_dout));
  dfx_wrapper_xlconstant_2_0 xlconstant_2
       (.dout(xlconstant_2_dout));
endmodule

module dfx_wrapper_DFX_Ctrl_0_axi_periph_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wvalid,
    M01_ACLK,
    M01_ARESETN,
    M01_AXI_araddr,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wstrb,
    M01_AXI_wvalid,
    M02_ACLK,
    M02_ARESETN,
    M02_AXI_araddr,
    M02_AXI_arready,
    M02_AXI_arvalid,
    M02_AXI_awaddr,
    M02_AXI_awready,
    M02_AXI_awvalid,
    M02_AXI_bready,
    M02_AXI_bresp,
    M02_AXI_bvalid,
    M02_AXI_rdata,
    M02_AXI_rready,
    M02_AXI_rresp,
    M02_AXI_rvalid,
    M02_AXI_wdata,
    M02_AXI_wready,
    M02_AXI_wvalid,
    M03_ACLK,
    M03_ARESETN,
    M03_AXI_araddr,
    M03_AXI_arready,
    M03_AXI_arvalid,
    M03_AXI_awaddr,
    M03_AXI_awready,
    M03_AXI_awvalid,
    M03_AXI_bready,
    M03_AXI_bresp,
    M03_AXI_bvalid,
    M03_AXI_rdata,
    M03_AXI_rready,
    M03_AXI_rresp,
    M03_AXI_rvalid,
    M03_AXI_wdata,
    M03_AXI_wready,
    M03_AXI_wstrb,
    M03_AXI_wvalid,
    M04_ACLK,
    M04_ARESETN,
    M04_AXI_araddr,
    M04_AXI_arready,
    M04_AXI_arvalid,
    M04_AXI_awaddr,
    M04_AXI_awready,
    M04_AXI_awvalid,
    M04_AXI_bready,
    M04_AXI_bresp,
    M04_AXI_bvalid,
    M04_AXI_rdata,
    M04_AXI_rready,
    M04_AXI_rresp,
    M04_AXI_rvalid,
    M04_AXI_wdata,
    M04_AXI_wready,
    M04_AXI_wstrb,
    M04_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arready,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awready,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S01_ACLK,
    S01_ARESETN,
    S01_AXI_araddr,
    S01_AXI_arburst,
    S01_AXI_arcache,
    S01_AXI_arid,
    S01_AXI_arlen,
    S01_AXI_arlock,
    S01_AXI_arprot,
    S01_AXI_arqos,
    S01_AXI_arready,
    S01_AXI_arregion,
    S01_AXI_arsize,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awburst,
    S01_AXI_awcache,
    S01_AXI_awid,
    S01_AXI_awlen,
    S01_AXI_awlock,
    S01_AXI_awprot,
    S01_AXI_awqos,
    S01_AXI_awready,
    S01_AXI_awregion,
    S01_AXI_awsize,
    S01_AXI_awvalid,
    S01_AXI_bid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rid,
    S01_AXI_rlast,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wlast,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output M00_AXI_wvalid;
  input M01_ACLK;
  input M01_ARESETN;
  output [31:0]M01_AXI_araddr;
  input [0:0]M01_AXI_arready;
  output [0:0]M01_AXI_arvalid;
  output [31:0]M01_AXI_awaddr;
  input [0:0]M01_AXI_awready;
  output [0:0]M01_AXI_awvalid;
  output [0:0]M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input [0:0]M01_AXI_bvalid;
  input [31:0]M01_AXI_rdata;
  output [0:0]M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input [0:0]M01_AXI_rvalid;
  output [31:0]M01_AXI_wdata;
  input [0:0]M01_AXI_wready;
  output [3:0]M01_AXI_wstrb;
  output [0:0]M01_AXI_wvalid;
  input M02_ACLK;
  input M02_ARESETN;
  output [31:0]M02_AXI_araddr;
  input M02_AXI_arready;
  output M02_AXI_arvalid;
  output [31:0]M02_AXI_awaddr;
  input M02_AXI_awready;
  output M02_AXI_awvalid;
  output M02_AXI_bready;
  input [1:0]M02_AXI_bresp;
  input M02_AXI_bvalid;
  input [31:0]M02_AXI_rdata;
  output M02_AXI_rready;
  input [1:0]M02_AXI_rresp;
  input M02_AXI_rvalid;
  output [31:0]M02_AXI_wdata;
  input M02_AXI_wready;
  output M02_AXI_wvalid;
  input M03_ACLK;
  input M03_ARESETN;
  output [31:0]M03_AXI_araddr;
  input M03_AXI_arready;
  output M03_AXI_arvalid;
  output [31:0]M03_AXI_awaddr;
  input M03_AXI_awready;
  output M03_AXI_awvalid;
  output M03_AXI_bready;
  input [1:0]M03_AXI_bresp;
  input M03_AXI_bvalid;
  input [31:0]M03_AXI_rdata;
  output M03_AXI_rready;
  input [1:0]M03_AXI_rresp;
  input M03_AXI_rvalid;
  output [31:0]M03_AXI_wdata;
  input M03_AXI_wready;
  output [3:0]M03_AXI_wstrb;
  output M03_AXI_wvalid;
  input M04_ACLK;
  input M04_ARESETN;
  output [31:0]M04_AXI_araddr;
  input M04_AXI_arready;
  output M04_AXI_arvalid;
  output [31:0]M04_AXI_awaddr;
  input M04_AXI_awready;
  output M04_AXI_awvalid;
  output M04_AXI_bready;
  input [1:0]M04_AXI_bresp;
  input M04_AXI_bvalid;
  input [31:0]M04_AXI_rdata;
  output M04_AXI_rready;
  input [1:0]M04_AXI_rresp;
  input M04_AXI_rvalid;
  output [31:0]M04_AXI_wdata;
  input M04_AXI_wready;
  output [3:0]M04_AXI_wstrb;
  output M04_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  output [0:0]S00_AXI_arready;
  input [0:0]S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  output [0:0]S00_AXI_awready;
  input [0:0]S00_AXI_awvalid;
  input [0:0]S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  input [0:0]S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  output [0:0]S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wvalid;
  input S01_ACLK;
  input S01_ARESETN;
  input [31:0]S01_AXI_araddr;
  input [1:0]S01_AXI_arburst;
  input [3:0]S01_AXI_arcache;
  input [0:0]S01_AXI_arid;
  input [7:0]S01_AXI_arlen;
  input [0:0]S01_AXI_arlock;
  input [2:0]S01_AXI_arprot;
  input [3:0]S01_AXI_arqos;
  output S01_AXI_arready;
  input [3:0]S01_AXI_arregion;
  input [2:0]S01_AXI_arsize;
  input S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [1:0]S01_AXI_awburst;
  input [3:0]S01_AXI_awcache;
  input [0:0]S01_AXI_awid;
  input [7:0]S01_AXI_awlen;
  input [0:0]S01_AXI_awlock;
  input [2:0]S01_AXI_awprot;
  input [3:0]S01_AXI_awqos;
  output S01_AXI_awready;
  input [3:0]S01_AXI_awregion;
  input [2:0]S01_AXI_awsize;
  input S01_AXI_awvalid;
  output [0:0]S01_AXI_bid;
  input S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  output [0:0]S01_AXI_rid;
  output S01_AXI_rlast;
  input S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  input S01_AXI_wlast;
  output S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input S01_AXI_wvalid;

  wire DFX_Ctrl_0_axi_periph_ACLK_net;
  wire DFX_Ctrl_0_axi_periph_ARESETN_net;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_ARADDR;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_ARREADY;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_AWADDR;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_AWREADY;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_AWVALID;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_BRESP;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_RDATA;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_RRESP;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_WDATA;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_WREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_WSTRB;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s00_couplers_WVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARADDR;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARBURST;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARCACHE;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARID;
  wire [7:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLEN;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLOCK;
  wire [2:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARPROT;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARQOS;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREGION;
  wire [2:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_ARSIZE;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWADDR;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWBURST;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWCACHE;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWID;
  wire [7:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLEN;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLOCK;
  wire [2:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWPROT;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWQOS;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREGION;
  wire [2:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_AWSIZE;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_AWVALID;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_BID;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_BRESP;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_RDATA;
  wire [0:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_RID;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_RLAST;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_RRESP;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_WDATA;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_WLAST;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_WREADY;
  wire [3:0]DFX_Ctrl_0_axi_periph_to_s01_couplers_WSTRB;
  wire DFX_Ctrl_0_axi_periph_to_s01_couplers_WVALID;
  wire [31:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  wire [31:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  wire [1:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_BRESP;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_BVALID;
  wire [31:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_RDATA;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  wire [1:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_RRESP;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_RVALID;
  wire [31:0]m00_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_WREADY;
  wire m00_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  wire [31:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  wire [31:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  wire [1:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_BRESP;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_BVALID;
  wire [31:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_RDATA;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  wire [1:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_RRESP;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_RVALID;
  wire [31:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_WREADY;
  wire [3:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  wire [0:0]m01_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  wire [31:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  wire [31:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  wire [1:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_BRESP;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_BVALID;
  wire [31:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_RDATA;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  wire [1:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_RRESP;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_RVALID;
  wire [31:0]m02_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_WREADY;
  wire m02_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  wire [31:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  wire [31:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  wire [1:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_BRESP;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_BVALID;
  wire [31:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_RDATA;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  wire [1:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_RRESP;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_RVALID;
  wire [31:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_WREADY;
  wire [3:0]m03_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  wire m03_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  wire [31:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  wire [31:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  wire [1:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_BRESP;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_BVALID;
  wire [31:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_RDATA;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  wire [1:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_RRESP;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_RVALID;
  wire [31:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_WREADY;
  wire [3:0]m04_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  wire m04_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [0:0]s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [0:0]s00_couplers_to_xbar_AWVALID;
  wire [0:0]s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [31:0]s00_couplers_to_xbar_RDATA;
  wire [0:0]s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [31:0]s00_couplers_to_xbar_WDATA;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [3:0]s00_couplers_to_xbar_WSTRB;
  wire [0:0]s00_couplers_to_xbar_WVALID;
  wire [31:0]s01_couplers_to_xbar_ARADDR;
  wire [2:0]s01_couplers_to_xbar_ARPROT;
  wire [1:1]s01_couplers_to_xbar_ARREADY;
  wire s01_couplers_to_xbar_ARVALID;
  wire [31:0]s01_couplers_to_xbar_AWADDR;
  wire [2:0]s01_couplers_to_xbar_AWPROT;
  wire [1:1]s01_couplers_to_xbar_AWREADY;
  wire s01_couplers_to_xbar_AWVALID;
  wire s01_couplers_to_xbar_BREADY;
  wire [3:2]s01_couplers_to_xbar_BRESP;
  wire [1:1]s01_couplers_to_xbar_BVALID;
  wire [63:32]s01_couplers_to_xbar_RDATA;
  wire s01_couplers_to_xbar_RREADY;
  wire [3:2]s01_couplers_to_xbar_RRESP;
  wire [1:1]s01_couplers_to_xbar_RVALID;
  wire [31:0]s01_couplers_to_xbar_WDATA;
  wire [1:1]s01_couplers_to_xbar_WREADY;
  wire [3:0]s01_couplers_to_xbar_WSTRB;
  wire s01_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire xbar_to_m00_couplers_ARREADY;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire xbar_to_m00_couplers_AWREADY;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [31:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [31:0]xbar_to_m00_couplers_WDATA;
  wire xbar_to_m00_couplers_WREADY;
  wire [0:0]xbar_to_m00_couplers_WVALID;
  wire [63:32]xbar_to_m01_couplers_ARADDR;
  wire [0:0]xbar_to_m01_couplers_ARREADY;
  wire [1:1]xbar_to_m01_couplers_ARVALID;
  wire [63:32]xbar_to_m01_couplers_AWADDR;
  wire [0:0]xbar_to_m01_couplers_AWREADY;
  wire [1:1]xbar_to_m01_couplers_AWVALID;
  wire [1:1]xbar_to_m01_couplers_BREADY;
  wire [1:0]xbar_to_m01_couplers_BRESP;
  wire [0:0]xbar_to_m01_couplers_BVALID;
  wire [31:0]xbar_to_m01_couplers_RDATA;
  wire [1:1]xbar_to_m01_couplers_RREADY;
  wire [1:0]xbar_to_m01_couplers_RRESP;
  wire [0:0]xbar_to_m01_couplers_RVALID;
  wire [63:32]xbar_to_m01_couplers_WDATA;
  wire [0:0]xbar_to_m01_couplers_WREADY;
  wire [7:4]xbar_to_m01_couplers_WSTRB;
  wire [1:1]xbar_to_m01_couplers_WVALID;
  wire [95:64]xbar_to_m02_couplers_ARADDR;
  wire xbar_to_m02_couplers_ARREADY;
  wire [2:2]xbar_to_m02_couplers_ARVALID;
  wire [95:64]xbar_to_m02_couplers_AWADDR;
  wire xbar_to_m02_couplers_AWREADY;
  wire [2:2]xbar_to_m02_couplers_AWVALID;
  wire [2:2]xbar_to_m02_couplers_BREADY;
  wire [1:0]xbar_to_m02_couplers_BRESP;
  wire xbar_to_m02_couplers_BVALID;
  wire [31:0]xbar_to_m02_couplers_RDATA;
  wire [2:2]xbar_to_m02_couplers_RREADY;
  wire [1:0]xbar_to_m02_couplers_RRESP;
  wire xbar_to_m02_couplers_RVALID;
  wire [95:64]xbar_to_m02_couplers_WDATA;
  wire xbar_to_m02_couplers_WREADY;
  wire [2:2]xbar_to_m02_couplers_WVALID;
  wire [127:96]xbar_to_m03_couplers_ARADDR;
  wire xbar_to_m03_couplers_ARREADY;
  wire [3:3]xbar_to_m03_couplers_ARVALID;
  wire [127:96]xbar_to_m03_couplers_AWADDR;
  wire xbar_to_m03_couplers_AWREADY;
  wire [3:3]xbar_to_m03_couplers_AWVALID;
  wire [3:3]xbar_to_m03_couplers_BREADY;
  wire [1:0]xbar_to_m03_couplers_BRESP;
  wire xbar_to_m03_couplers_BVALID;
  wire [31:0]xbar_to_m03_couplers_RDATA;
  wire [3:3]xbar_to_m03_couplers_RREADY;
  wire [1:0]xbar_to_m03_couplers_RRESP;
  wire xbar_to_m03_couplers_RVALID;
  wire [127:96]xbar_to_m03_couplers_WDATA;
  wire xbar_to_m03_couplers_WREADY;
  wire [15:12]xbar_to_m03_couplers_WSTRB;
  wire [3:3]xbar_to_m03_couplers_WVALID;
  wire [159:128]xbar_to_m04_couplers_ARADDR;
  wire xbar_to_m04_couplers_ARREADY;
  wire [4:4]xbar_to_m04_couplers_ARVALID;
  wire [159:128]xbar_to_m04_couplers_AWADDR;
  wire xbar_to_m04_couplers_AWREADY;
  wire [4:4]xbar_to_m04_couplers_AWVALID;
  wire [4:4]xbar_to_m04_couplers_BREADY;
  wire [1:0]xbar_to_m04_couplers_BRESP;
  wire xbar_to_m04_couplers_BVALID;
  wire [31:0]xbar_to_m04_couplers_RDATA;
  wire [4:4]xbar_to_m04_couplers_RREADY;
  wire [1:0]xbar_to_m04_couplers_RRESP;
  wire xbar_to_m04_couplers_RVALID;
  wire [159:128]xbar_to_m04_couplers_WDATA;
  wire xbar_to_m04_couplers_WREADY;
  wire [19:16]xbar_to_m04_couplers_WSTRB;
  wire [4:4]xbar_to_m04_couplers_WVALID;
  wire [19:0]NLW_xbar_m_axi_wstrb_UNCONNECTED;

  assign DFX_Ctrl_0_axi_periph_ACLK_net = ACLK;
  assign DFX_Ctrl_0_axi_periph_ARESETN_net = ARESETN;
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_ARVALID = S00_AXI_arvalid[0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_AWVALID = S00_AXI_awvalid[0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_BREADY = S00_AXI_bready[0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_RREADY = S00_AXI_rready[0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s00_couplers_WVALID = S00_AXI_wvalid[0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARADDR = S01_AXI_araddr[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARBURST = S01_AXI_arburst[1:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARCACHE = S01_AXI_arcache[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARID = S01_AXI_arid[0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLEN = S01_AXI_arlen[7:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLOCK = S01_AXI_arlock[0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARPROT = S01_AXI_arprot[2:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARQOS = S01_AXI_arqos[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREGION = S01_AXI_arregion[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARSIZE = S01_AXI_arsize[2:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_ARVALID = S01_AXI_arvalid;
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWADDR = S01_AXI_awaddr[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWBURST = S01_AXI_awburst[1:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWCACHE = S01_AXI_awcache[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWID = S01_AXI_awid[0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLEN = S01_AXI_awlen[7:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLOCK = S01_AXI_awlock[0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWPROT = S01_AXI_awprot[2:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWQOS = S01_AXI_awqos[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREGION = S01_AXI_awregion[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWSIZE = S01_AXI_awsize[2:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_AWVALID = S01_AXI_awvalid;
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_BREADY = S01_AXI_bready;
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_RREADY = S01_AXI_rready;
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_WDATA = S01_AXI_wdata[31:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_WLAST = S01_AXI_wlast;
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_WSTRB = S01_AXI_wstrb[3:0];
  assign DFX_Ctrl_0_axi_periph_to_s01_couplers_WVALID = S01_AXI_wvalid;
  assign M00_AXI_araddr[31:0] = m00_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  assign M00_AXI_arvalid = m00_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  assign M00_AXI_awvalid = m00_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  assign M00_AXI_rready = m00_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  assign M00_AXI_wdata[31:0] = m00_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  assign M00_AXI_wvalid = m00_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  assign M01_AXI_araddr[31:0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  assign M01_AXI_arvalid[0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  assign M01_AXI_awaddr[31:0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  assign M01_AXI_awvalid[0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  assign M01_AXI_bready[0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  assign M01_AXI_rready[0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  assign M01_AXI_wdata[31:0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  assign M01_AXI_wstrb[3:0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  assign M01_AXI_wvalid[0] = m01_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  assign M02_AXI_araddr[31:0] = m02_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  assign M02_AXI_arvalid = m02_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  assign M02_AXI_awaddr[31:0] = m02_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  assign M02_AXI_awvalid = m02_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  assign M02_AXI_bready = m02_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  assign M02_AXI_rready = m02_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  assign M02_AXI_wdata[31:0] = m02_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  assign M02_AXI_wvalid = m02_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  assign M03_AXI_araddr[31:0] = m03_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  assign M03_AXI_arvalid = m03_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  assign M03_AXI_awaddr[31:0] = m03_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  assign M03_AXI_awvalid = m03_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  assign M03_AXI_bready = m03_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  assign M03_AXI_rready = m03_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  assign M03_AXI_wdata[31:0] = m03_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  assign M03_AXI_wstrb[3:0] = m03_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  assign M03_AXI_wvalid = m03_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  assign M04_AXI_araddr[31:0] = m04_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR;
  assign M04_AXI_arvalid = m04_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID;
  assign M04_AXI_awaddr[31:0] = m04_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR;
  assign M04_AXI_awvalid = m04_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID;
  assign M04_AXI_bready = m04_couplers_to_DFX_Ctrl_0_axi_periph_BREADY;
  assign M04_AXI_rready = m04_couplers_to_DFX_Ctrl_0_axi_periph_RREADY;
  assign M04_AXI_wdata[31:0] = m04_couplers_to_DFX_Ctrl_0_axi_periph_WDATA;
  assign M04_AXI_wstrb[3:0] = m04_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB;
  assign M04_AXI_wvalid = m04_couplers_to_DFX_Ctrl_0_axi_periph_WVALID;
  assign S00_AXI_arready[0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_ARREADY;
  assign S00_AXI_awready[0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_AWREADY;
  assign S00_AXI_bresp[1:0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid[0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_RDATA;
  assign S00_AXI_rresp[1:0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid[0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_RVALID;
  assign S00_AXI_wready[0] = DFX_Ctrl_0_axi_periph_to_s00_couplers_WREADY;
  assign S01_AXI_arready = DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREADY;
  assign S01_AXI_awready = DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREADY;
  assign S01_AXI_bid[0] = DFX_Ctrl_0_axi_periph_to_s01_couplers_BID;
  assign S01_AXI_bresp[1:0] = DFX_Ctrl_0_axi_periph_to_s01_couplers_BRESP;
  assign S01_AXI_bvalid = DFX_Ctrl_0_axi_periph_to_s01_couplers_BVALID;
  assign S01_AXI_rdata[31:0] = DFX_Ctrl_0_axi_periph_to_s01_couplers_RDATA;
  assign S01_AXI_rid[0] = DFX_Ctrl_0_axi_periph_to_s01_couplers_RID;
  assign S01_AXI_rlast = DFX_Ctrl_0_axi_periph_to_s01_couplers_RLAST;
  assign S01_AXI_rresp[1:0] = DFX_Ctrl_0_axi_periph_to_s01_couplers_RRESP;
  assign S01_AXI_rvalid = DFX_Ctrl_0_axi_periph_to_s01_couplers_RVALID;
  assign S01_AXI_wready = DFX_Ctrl_0_axi_periph_to_s01_couplers_WREADY;
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_RDATA = M00_AXI_rdata[31:0];
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_DFX_Ctrl_0_axi_periph_WREADY = M00_AXI_wready;
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY = M01_AXI_arready[0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY = M01_AXI_awready[0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_BRESP = M01_AXI_bresp[1:0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_BVALID = M01_AXI_bvalid[0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_RDATA = M01_AXI_rdata[31:0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_RRESP = M01_AXI_rresp[1:0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_RVALID = M01_AXI_rvalid[0];
  assign m01_couplers_to_DFX_Ctrl_0_axi_periph_WREADY = M01_AXI_wready[0];
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY = M02_AXI_arready;
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY = M02_AXI_awready;
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_BRESP = M02_AXI_bresp[1:0];
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_BVALID = M02_AXI_bvalid;
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_RDATA = M02_AXI_rdata[31:0];
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_RRESP = M02_AXI_rresp[1:0];
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_RVALID = M02_AXI_rvalid;
  assign m02_couplers_to_DFX_Ctrl_0_axi_periph_WREADY = M02_AXI_wready;
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY = M03_AXI_arready;
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY = M03_AXI_awready;
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_BRESP = M03_AXI_bresp[1:0];
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_BVALID = M03_AXI_bvalid;
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_RDATA = M03_AXI_rdata[31:0];
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_RRESP = M03_AXI_rresp[1:0];
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_RVALID = M03_AXI_rvalid;
  assign m03_couplers_to_DFX_Ctrl_0_axi_periph_WREADY = M03_AXI_wready;
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY = M04_AXI_arready;
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY = M04_AXI_awready;
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_BRESP = M04_AXI_bresp[1:0];
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_BVALID = M04_AXI_bvalid;
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_RDATA = M04_AXI_rdata[31:0];
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_RRESP = M04_AXI_rresp[1:0];
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_RVALID = M04_AXI_rvalid;
  assign m04_couplers_to_DFX_Ctrl_0_axi_periph_WREADY = M04_AXI_wready;
  m00_couplers_imp_2VI8KG m00_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR),
        .M_AXI_arready(m00_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR),
        .M_AXI_awready(m00_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID),
        .M_AXI_bready(m00_couplers_to_DFX_Ctrl_0_axi_periph_BREADY),
        .M_AXI_bresp(m00_couplers_to_DFX_Ctrl_0_axi_periph_BRESP),
        .M_AXI_bvalid(m00_couplers_to_DFX_Ctrl_0_axi_periph_BVALID),
        .M_AXI_rdata(m00_couplers_to_DFX_Ctrl_0_axi_periph_RDATA),
        .M_AXI_rready(m00_couplers_to_DFX_Ctrl_0_axi_periph_RREADY),
        .M_AXI_rresp(m00_couplers_to_DFX_Ctrl_0_axi_periph_RRESP),
        .M_AXI_rvalid(m00_couplers_to_DFX_Ctrl_0_axi_periph_RVALID),
        .M_AXI_wdata(m00_couplers_to_DFX_Ctrl_0_axi_periph_WDATA),
        .M_AXI_wready(m00_couplers_to_DFX_Ctrl_0_axi_periph_WREADY),
        .M_AXI_wvalid(m00_couplers_to_DFX_Ctrl_0_axi_periph_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  m01_couplers_imp_15HK326 m01_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(m01_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR),
        .M_AXI_arready(m01_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY),
        .M_AXI_arvalid(m01_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID),
        .M_AXI_awaddr(m01_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR),
        .M_AXI_awready(m01_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY),
        .M_AXI_awvalid(m01_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID),
        .M_AXI_bready(m01_couplers_to_DFX_Ctrl_0_axi_periph_BREADY),
        .M_AXI_bresp(m01_couplers_to_DFX_Ctrl_0_axi_periph_BRESP),
        .M_AXI_bvalid(m01_couplers_to_DFX_Ctrl_0_axi_periph_BVALID),
        .M_AXI_rdata(m01_couplers_to_DFX_Ctrl_0_axi_periph_RDATA),
        .M_AXI_rready(m01_couplers_to_DFX_Ctrl_0_axi_periph_RREADY),
        .M_AXI_rresp(m01_couplers_to_DFX_Ctrl_0_axi_periph_RRESP),
        .M_AXI_rvalid(m01_couplers_to_DFX_Ctrl_0_axi_periph_RVALID),
        .M_AXI_wdata(m01_couplers_to_DFX_Ctrl_0_axi_periph_WDATA),
        .M_AXI_wready(m01_couplers_to_DFX_Ctrl_0_axi_periph_WREADY),
        .M_AXI_wstrb(m01_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB),
        .M_AXI_wvalid(m01_couplers_to_DFX_Ctrl_0_axi_periph_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(xbar_to_m01_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m01_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m01_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m01_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m01_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m01_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m01_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m01_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m01_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m01_couplers_RDATA),
        .S_AXI_rready(xbar_to_m01_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m01_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m01_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m01_couplers_WDATA),
        .S_AXI_wready(xbar_to_m01_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m01_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m01_couplers_WVALID));
  m02_couplers_imp_1U79Y1P m02_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(m02_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR),
        .M_AXI_arready(m02_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY),
        .M_AXI_arvalid(m02_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID),
        .M_AXI_awaddr(m02_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR),
        .M_AXI_awready(m02_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY),
        .M_AXI_awvalid(m02_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID),
        .M_AXI_bready(m02_couplers_to_DFX_Ctrl_0_axi_periph_BREADY),
        .M_AXI_bresp(m02_couplers_to_DFX_Ctrl_0_axi_periph_BRESP),
        .M_AXI_bvalid(m02_couplers_to_DFX_Ctrl_0_axi_periph_BVALID),
        .M_AXI_rdata(m02_couplers_to_DFX_Ctrl_0_axi_periph_RDATA),
        .M_AXI_rready(m02_couplers_to_DFX_Ctrl_0_axi_periph_RREADY),
        .M_AXI_rresp(m02_couplers_to_DFX_Ctrl_0_axi_periph_RRESP),
        .M_AXI_rvalid(m02_couplers_to_DFX_Ctrl_0_axi_periph_RVALID),
        .M_AXI_wdata(m02_couplers_to_DFX_Ctrl_0_axi_periph_WDATA),
        .M_AXI_wready(m02_couplers_to_DFX_Ctrl_0_axi_periph_WREADY),
        .M_AXI_wvalid(m02_couplers_to_DFX_Ctrl_0_axi_periph_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(xbar_to_m02_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m02_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m02_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m02_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m02_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m02_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m02_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m02_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m02_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m02_couplers_RDATA),
        .S_AXI_rready(xbar_to_m02_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m02_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m02_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m02_couplers_WDATA),
        .S_AXI_wready(xbar_to_m02_couplers_WREADY),
        .S_AXI_wvalid(xbar_to_m02_couplers_WVALID));
  m03_couplers_imp_VFB6DF m03_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(m03_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR),
        .M_AXI_arready(m03_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY),
        .M_AXI_arvalid(m03_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID),
        .M_AXI_awaddr(m03_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR),
        .M_AXI_awready(m03_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY),
        .M_AXI_awvalid(m03_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID),
        .M_AXI_bready(m03_couplers_to_DFX_Ctrl_0_axi_periph_BREADY),
        .M_AXI_bresp(m03_couplers_to_DFX_Ctrl_0_axi_periph_BRESP),
        .M_AXI_bvalid(m03_couplers_to_DFX_Ctrl_0_axi_periph_BVALID),
        .M_AXI_rdata(m03_couplers_to_DFX_Ctrl_0_axi_periph_RDATA),
        .M_AXI_rready(m03_couplers_to_DFX_Ctrl_0_axi_periph_RREADY),
        .M_AXI_rresp(m03_couplers_to_DFX_Ctrl_0_axi_periph_RRESP),
        .M_AXI_rvalid(m03_couplers_to_DFX_Ctrl_0_axi_periph_RVALID),
        .M_AXI_wdata(m03_couplers_to_DFX_Ctrl_0_axi_periph_WDATA),
        .M_AXI_wready(m03_couplers_to_DFX_Ctrl_0_axi_periph_WREADY),
        .M_AXI_wstrb(m03_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB),
        .M_AXI_wvalid(m03_couplers_to_DFX_Ctrl_0_axi_periph_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(xbar_to_m03_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m03_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m03_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m03_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m03_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m03_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m03_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m03_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m03_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m03_couplers_RDATA),
        .S_AXI_rready(xbar_to_m03_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m03_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m03_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m03_couplers_WDATA),
        .S_AXI_wready(xbar_to_m03_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m03_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m03_couplers_WVALID));
  m04_couplers_imp_6U742J m04_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(m04_couplers_to_DFX_Ctrl_0_axi_periph_ARADDR),
        .M_AXI_arready(m04_couplers_to_DFX_Ctrl_0_axi_periph_ARREADY),
        .M_AXI_arvalid(m04_couplers_to_DFX_Ctrl_0_axi_periph_ARVALID),
        .M_AXI_awaddr(m04_couplers_to_DFX_Ctrl_0_axi_periph_AWADDR),
        .M_AXI_awready(m04_couplers_to_DFX_Ctrl_0_axi_periph_AWREADY),
        .M_AXI_awvalid(m04_couplers_to_DFX_Ctrl_0_axi_periph_AWVALID),
        .M_AXI_bready(m04_couplers_to_DFX_Ctrl_0_axi_periph_BREADY),
        .M_AXI_bresp(m04_couplers_to_DFX_Ctrl_0_axi_periph_BRESP),
        .M_AXI_bvalid(m04_couplers_to_DFX_Ctrl_0_axi_periph_BVALID),
        .M_AXI_rdata(m04_couplers_to_DFX_Ctrl_0_axi_periph_RDATA),
        .M_AXI_rready(m04_couplers_to_DFX_Ctrl_0_axi_periph_RREADY),
        .M_AXI_rresp(m04_couplers_to_DFX_Ctrl_0_axi_periph_RRESP),
        .M_AXI_rvalid(m04_couplers_to_DFX_Ctrl_0_axi_periph_RVALID),
        .M_AXI_wdata(m04_couplers_to_DFX_Ctrl_0_axi_periph_WDATA),
        .M_AXI_wready(m04_couplers_to_DFX_Ctrl_0_axi_periph_WREADY),
        .M_AXI_wstrb(m04_couplers_to_DFX_Ctrl_0_axi_periph_WSTRB),
        .M_AXI_wvalid(m04_couplers_to_DFX_Ctrl_0_axi_periph_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(xbar_to_m04_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m04_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m04_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m04_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m04_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m04_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m04_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m04_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m04_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m04_couplers_RDATA),
        .S_AXI_rready(xbar_to_m04_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m04_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m04_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m04_couplers_WDATA),
        .S_AXI_wready(xbar_to_m04_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m04_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m04_couplers_WVALID));
  s00_couplers_imp_1RX1W4W s00_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(DFX_Ctrl_0_axi_periph_to_s00_couplers_ARADDR),
        .S_AXI_arready(DFX_Ctrl_0_axi_periph_to_s00_couplers_ARREADY),
        .S_AXI_arvalid(DFX_Ctrl_0_axi_periph_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(DFX_Ctrl_0_axi_periph_to_s00_couplers_AWADDR),
        .S_AXI_awready(DFX_Ctrl_0_axi_periph_to_s00_couplers_AWREADY),
        .S_AXI_awvalid(DFX_Ctrl_0_axi_periph_to_s00_couplers_AWVALID),
        .S_AXI_bready(DFX_Ctrl_0_axi_periph_to_s00_couplers_BREADY),
        .S_AXI_bresp(DFX_Ctrl_0_axi_periph_to_s00_couplers_BRESP),
        .S_AXI_bvalid(DFX_Ctrl_0_axi_periph_to_s00_couplers_BVALID),
        .S_AXI_rdata(DFX_Ctrl_0_axi_periph_to_s00_couplers_RDATA),
        .S_AXI_rready(DFX_Ctrl_0_axi_periph_to_s00_couplers_RREADY),
        .S_AXI_rresp(DFX_Ctrl_0_axi_periph_to_s00_couplers_RRESP),
        .S_AXI_rvalid(DFX_Ctrl_0_axi_periph_to_s00_couplers_RVALID),
        .S_AXI_wdata(DFX_Ctrl_0_axi_periph_to_s00_couplers_WDATA),
        .S_AXI_wready(DFX_Ctrl_0_axi_periph_to_s00_couplers_WREADY),
        .S_AXI_wstrb(DFX_Ctrl_0_axi_periph_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(DFX_Ctrl_0_axi_periph_to_s00_couplers_WVALID));
  s01_couplers_imp_XPXUNI s01_couplers
       (.M_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .M_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .M_AXI_araddr(s01_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s01_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s01_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s01_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s01_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s01_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s01_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s01_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s01_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s01_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s01_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s01_couplers_to_xbar_RDATA),
        .M_AXI_rready(s01_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s01_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s01_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s01_couplers_to_xbar_WDATA),
        .M_AXI_wready(s01_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s01_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s01_couplers_to_xbar_WVALID),
        .S_ACLK(DFX_Ctrl_0_axi_periph_ACLK_net),
        .S_ARESETN(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .S_AXI_araddr(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARADDR),
        .S_AXI_arburst(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARBURST),
        .S_AXI_arcache(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARCACHE),
        .S_AXI_arid(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARID),
        .S_AXI_arlen(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLEN),
        .S_AXI_arlock(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARLOCK),
        .S_AXI_arprot(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARPROT),
        .S_AXI_arqos(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARQOS),
        .S_AXI_arready(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREADY),
        .S_AXI_arregion(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARREGION),
        .S_AXI_arsize(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARSIZE),
        .S_AXI_arvalid(DFX_Ctrl_0_axi_periph_to_s01_couplers_ARVALID),
        .S_AXI_awaddr(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWADDR),
        .S_AXI_awburst(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWBURST),
        .S_AXI_awcache(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWCACHE),
        .S_AXI_awid(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWID),
        .S_AXI_awlen(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLEN),
        .S_AXI_awlock(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWLOCK),
        .S_AXI_awprot(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWPROT),
        .S_AXI_awqos(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWQOS),
        .S_AXI_awready(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREADY),
        .S_AXI_awregion(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWREGION),
        .S_AXI_awsize(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWSIZE),
        .S_AXI_awvalid(DFX_Ctrl_0_axi_periph_to_s01_couplers_AWVALID),
        .S_AXI_bid(DFX_Ctrl_0_axi_periph_to_s01_couplers_BID),
        .S_AXI_bready(DFX_Ctrl_0_axi_periph_to_s01_couplers_BREADY),
        .S_AXI_bresp(DFX_Ctrl_0_axi_periph_to_s01_couplers_BRESP),
        .S_AXI_bvalid(DFX_Ctrl_0_axi_periph_to_s01_couplers_BVALID),
        .S_AXI_rdata(DFX_Ctrl_0_axi_periph_to_s01_couplers_RDATA),
        .S_AXI_rid(DFX_Ctrl_0_axi_periph_to_s01_couplers_RID),
        .S_AXI_rlast(DFX_Ctrl_0_axi_periph_to_s01_couplers_RLAST),
        .S_AXI_rready(DFX_Ctrl_0_axi_periph_to_s01_couplers_RREADY),
        .S_AXI_rresp(DFX_Ctrl_0_axi_periph_to_s01_couplers_RRESP),
        .S_AXI_rvalid(DFX_Ctrl_0_axi_periph_to_s01_couplers_RVALID),
        .S_AXI_wdata(DFX_Ctrl_0_axi_periph_to_s01_couplers_WDATA),
        .S_AXI_wlast(DFX_Ctrl_0_axi_periph_to_s01_couplers_WLAST),
        .S_AXI_wready(DFX_Ctrl_0_axi_periph_to_s01_couplers_WREADY),
        .S_AXI_wstrb(DFX_Ctrl_0_axi_periph_to_s01_couplers_WSTRB),
        .S_AXI_wvalid(DFX_Ctrl_0_axi_periph_to_s01_couplers_WVALID));
  dfx_wrapper_xbar_0 xbar
       (.aclk(DFX_Ctrl_0_axi_periph_ACLK_net),
        .aresetn(DFX_Ctrl_0_axi_periph_ARESETN_net),
        .m_axi_araddr({xbar_to_m04_couplers_ARADDR,xbar_to_m03_couplers_ARADDR,xbar_to_m02_couplers_ARADDR,xbar_to_m01_couplers_ARADDR,xbar_to_m00_couplers_ARADDR}),
        .m_axi_arready({xbar_to_m04_couplers_ARREADY,xbar_to_m03_couplers_ARREADY,xbar_to_m02_couplers_ARREADY,xbar_to_m01_couplers_ARREADY,xbar_to_m00_couplers_ARREADY}),
        .m_axi_arvalid({xbar_to_m04_couplers_ARVALID,xbar_to_m03_couplers_ARVALID,xbar_to_m02_couplers_ARVALID,xbar_to_m01_couplers_ARVALID,xbar_to_m00_couplers_ARVALID}),
        .m_axi_awaddr({xbar_to_m04_couplers_AWADDR,xbar_to_m03_couplers_AWADDR,xbar_to_m02_couplers_AWADDR,xbar_to_m01_couplers_AWADDR,xbar_to_m00_couplers_AWADDR}),
        .m_axi_awready({xbar_to_m04_couplers_AWREADY,xbar_to_m03_couplers_AWREADY,xbar_to_m02_couplers_AWREADY,xbar_to_m01_couplers_AWREADY,xbar_to_m00_couplers_AWREADY}),
        .m_axi_awvalid({xbar_to_m04_couplers_AWVALID,xbar_to_m03_couplers_AWVALID,xbar_to_m02_couplers_AWVALID,xbar_to_m01_couplers_AWVALID,xbar_to_m00_couplers_AWVALID}),
        .m_axi_bready({xbar_to_m04_couplers_BREADY,xbar_to_m03_couplers_BREADY,xbar_to_m02_couplers_BREADY,xbar_to_m01_couplers_BREADY,xbar_to_m00_couplers_BREADY}),
        .m_axi_bresp({xbar_to_m04_couplers_BRESP,xbar_to_m03_couplers_BRESP,xbar_to_m02_couplers_BRESP,xbar_to_m01_couplers_BRESP,xbar_to_m00_couplers_BRESP}),
        .m_axi_bvalid({xbar_to_m04_couplers_BVALID,xbar_to_m03_couplers_BVALID,xbar_to_m02_couplers_BVALID,xbar_to_m01_couplers_BVALID,xbar_to_m00_couplers_BVALID}),
        .m_axi_rdata({xbar_to_m04_couplers_RDATA,xbar_to_m03_couplers_RDATA,xbar_to_m02_couplers_RDATA,xbar_to_m01_couplers_RDATA,xbar_to_m00_couplers_RDATA}),
        .m_axi_rready({xbar_to_m04_couplers_RREADY,xbar_to_m03_couplers_RREADY,xbar_to_m02_couplers_RREADY,xbar_to_m01_couplers_RREADY,xbar_to_m00_couplers_RREADY}),
        .m_axi_rresp({xbar_to_m04_couplers_RRESP,xbar_to_m03_couplers_RRESP,xbar_to_m02_couplers_RRESP,xbar_to_m01_couplers_RRESP,xbar_to_m00_couplers_RRESP}),
        .m_axi_rvalid({xbar_to_m04_couplers_RVALID,xbar_to_m03_couplers_RVALID,xbar_to_m02_couplers_RVALID,xbar_to_m01_couplers_RVALID,xbar_to_m00_couplers_RVALID}),
        .m_axi_wdata({xbar_to_m04_couplers_WDATA,xbar_to_m03_couplers_WDATA,xbar_to_m02_couplers_WDATA,xbar_to_m01_couplers_WDATA,xbar_to_m00_couplers_WDATA}),
        .m_axi_wready({xbar_to_m04_couplers_WREADY,xbar_to_m03_couplers_WREADY,xbar_to_m02_couplers_WREADY,xbar_to_m01_couplers_WREADY,xbar_to_m00_couplers_WREADY}),
        .m_axi_wstrb({xbar_to_m04_couplers_WSTRB,xbar_to_m03_couplers_WSTRB,NLW_xbar_m_axi_wstrb_UNCONNECTED[11:8],xbar_to_m01_couplers_WSTRB,NLW_xbar_m_axi_wstrb_UNCONNECTED[3:0]}),
        .m_axi_wvalid({xbar_to_m04_couplers_WVALID,xbar_to_m03_couplers_WVALID,xbar_to_m02_couplers_WVALID,xbar_to_m01_couplers_WVALID,xbar_to_m00_couplers_WVALID}),
        .s_axi_araddr({s01_couplers_to_xbar_ARADDR,s00_couplers_to_xbar_ARADDR}),
        .s_axi_arprot({s01_couplers_to_xbar_ARPROT,1'b0,1'b0,1'b0}),
        .s_axi_arready({s01_couplers_to_xbar_ARREADY,s00_couplers_to_xbar_ARREADY}),
        .s_axi_arvalid({s01_couplers_to_xbar_ARVALID,s00_couplers_to_xbar_ARVALID}),
        .s_axi_awaddr({s01_couplers_to_xbar_AWADDR,s00_couplers_to_xbar_AWADDR}),
        .s_axi_awprot({s01_couplers_to_xbar_AWPROT,1'b0,1'b0,1'b0}),
        .s_axi_awready({s01_couplers_to_xbar_AWREADY,s00_couplers_to_xbar_AWREADY}),
        .s_axi_awvalid({s01_couplers_to_xbar_AWVALID,s00_couplers_to_xbar_AWVALID}),
        .s_axi_bready({s01_couplers_to_xbar_BREADY,s00_couplers_to_xbar_BREADY}),
        .s_axi_bresp({s01_couplers_to_xbar_BRESP,s00_couplers_to_xbar_BRESP}),
        .s_axi_bvalid({s01_couplers_to_xbar_BVALID,s00_couplers_to_xbar_BVALID}),
        .s_axi_rdata({s01_couplers_to_xbar_RDATA,s00_couplers_to_xbar_RDATA}),
        .s_axi_rready({s01_couplers_to_xbar_RREADY,s00_couplers_to_xbar_RREADY}),
        .s_axi_rresp({s01_couplers_to_xbar_RRESP,s00_couplers_to_xbar_RRESP}),
        .s_axi_rvalid({s01_couplers_to_xbar_RVALID,s00_couplers_to_xbar_RVALID}),
        .s_axi_wdata({s01_couplers_to_xbar_WDATA,s00_couplers_to_xbar_WDATA}),
        .s_axi_wready({s01_couplers_to_xbar_WREADY,s00_couplers_to_xbar_WREADY}),
        .s_axi_wstrb({s01_couplers_to_xbar_WSTRB,s00_couplers_to_xbar_WSTRB}),
        .s_axi_wvalid({s01_couplers_to_xbar_WVALID,s00_couplers_to_xbar_WVALID}));
endmodule

module dma_hier_imp_147877G
   (M_AXIS_DS0_tdata,
    M_AXIS_DS0_tkeep,
    M_AXIS_DS0_tlast,
    M_AXIS_DS0_tready,
    M_AXIS_DS0_tvalid,
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
    S_AXI_LITE_araddr,
    S_AXI_LITE_arready,
    S_AXI_LITE_arvalid,
    S_AXI_LITE_awaddr,
    S_AXI_LITE_awready,
    S_AXI_LITE_awvalid,
    S_AXI_LITE_bready,
    S_AXI_LITE_bresp,
    S_AXI_LITE_bvalid,
    S_AXI_LITE_rdata,
    S_AXI_LITE_rready,
    S_AXI_LITE_rresp,
    S_AXI_LITE_rvalid,
    S_AXI_LITE_wdata,
    S_AXI_LITE_wready,
    S_AXI_LITE_wvalid,
    clk,
    decouple,
    nreset,
    s2mm_introut);
  output [31:0]M_AXIS_DS0_tdata;
  output [3:0]M_AXIS_DS0_tkeep;
  output M_AXIS_DS0_tlast;
  input M_AXIS_DS0_tready;
  output M_AXIS_DS0_tvalid;
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
  input [31:0]S_AXI_LITE_araddr;
  output S_AXI_LITE_arready;
  input S_AXI_LITE_arvalid;
  input [31:0]S_AXI_LITE_awaddr;
  output S_AXI_LITE_awready;
  input S_AXI_LITE_awvalid;
  input S_AXI_LITE_bready;
  output [1:0]S_AXI_LITE_bresp;
  output S_AXI_LITE_bvalid;
  output [31:0]S_AXI_LITE_rdata;
  input S_AXI_LITE_rready;
  output [1:0]S_AXI_LITE_rresp;
  output S_AXI_LITE_rvalid;
  input [31:0]S_AXI_LITE_wdata;
  output S_AXI_LITE_wready;
  input S_AXI_LITE_wvalid;
  input clk;
  input decouple;
  input nreset;
  output s2mm_introut;

  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_BREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M00_AXI_BRESP;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_BVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_RDATA;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_RREADY;
  wire [1:0]DFX_Ctrl_0_axi_periph_M00_AXI_RRESP;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_RVALID;
  wire [31:0]DFX_Ctrl_0_axi_periph_M00_AXI_WDATA;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_WREADY;
  wire DFX_Ctrl_0_axi_periph_M00_AXI_WVALID;
  wire [31:0]S_AXIS_DS0_1_TDATA;
  wire [3:0]S_AXIS_DS0_1_TKEEP;
  wire S_AXIS_DS0_1_TLAST;
  wire S_AXIS_DS0_1_TREADY;
  wire S_AXIS_DS0_1_TVALID;
  wire [31:0]axi_dma_0_M_AXIS_MM2S_TDATA;
  wire [3:0]axi_dma_0_M_AXIS_MM2S_TKEEP;
  wire axi_dma_0_M_AXIS_MM2S_TLAST;
  wire axi_dma_0_M_AXIS_MM2S_TREADY;
  wire axi_dma_0_M_AXIS_MM2S_TVALID;
  wire [31:0]axi_dma_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_0_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_0_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_0_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARPROT;
  wire axi_dma_0_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARSIZE;
  wire axi_dma_0_M_AXI_MM2S_ARVALID;
  wire [31:0]axi_dma_0_M_AXI_MM2S_RDATA;
  wire axi_dma_0_M_AXI_MM2S_RLAST;
  wire axi_dma_0_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_0_M_AXI_MM2S_RRESP;
  wire axi_dma_0_M_AXI_MM2S_RVALID;
  wire [31:0]axi_dma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_dma_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_dma_0_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_dma_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWPROT;
  wire axi_dma_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWSIZE;
  wire axi_dma_0_M_AXI_S2MM_AWVALID;
  wire axi_dma_0_M_AXI_S2MM_BREADY;
  wire [1:0]axi_dma_0_M_AXI_S2MM_BRESP;
  wire axi_dma_0_M_AXI_S2MM_BVALID;
  wire [31:0]axi_dma_0_M_AXI_S2MM_WDATA;
  wire axi_dma_0_M_AXI_S2MM_WLAST;
  wire axi_dma_0_M_AXI_S2MM_WREADY;
  wire [3:0]axi_dma_0_M_AXI_S2MM_WSTRB;
  wire axi_dma_0_M_AXI_S2MM_WVALID;
  wire axi_dma_0_s2mm_introut;
  wire clk_0_1;
  wire [31:0]dfx_decoupler_0_s_intf_0_TDATA;
  wire [3:0]dfx_decoupler_0_s_intf_0_TKEEP;
  wire dfx_decoupler_0_s_intf_0_TLAST;
  wire dfx_decoupler_0_s_intf_0_TREADY;
  wire dfx_decoupler_0_s_intf_0_TVALID;
  wire [31:0]dfx_decoupler_1_rp_intf_0_TDATA;
  wire [3:0]dfx_decoupler_1_rp_intf_0_TKEEP;
  wire dfx_decoupler_1_rp_intf_0_TLAST;
  wire dfx_decoupler_1_rp_intf_0_TREADY;
  wire dfx_decoupler_1_rp_intf_0_TVALID;
  wire reset_0_1;
  wire util_vector_logic_0_Res;

  assign DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR = S_AXI_LITE_araddr[31:0];
  assign DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID = S_AXI_LITE_arvalid;
  assign DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR = S_AXI_LITE_awaddr[31:0];
  assign DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID = S_AXI_LITE_awvalid;
  assign DFX_Ctrl_0_axi_periph_M00_AXI_BREADY = S_AXI_LITE_bready;
  assign DFX_Ctrl_0_axi_periph_M00_AXI_RREADY = S_AXI_LITE_rready;
  assign DFX_Ctrl_0_axi_periph_M00_AXI_WDATA = S_AXI_LITE_wdata[31:0];
  assign DFX_Ctrl_0_axi_periph_M00_AXI_WVALID = S_AXI_LITE_wvalid;
  assign M_AXIS_DS0_tdata[31:0] = dfx_decoupler_1_rp_intf_0_TDATA;
  assign M_AXIS_DS0_tkeep[3:0] = dfx_decoupler_1_rp_intf_0_TKEEP;
  assign M_AXIS_DS0_tlast = dfx_decoupler_1_rp_intf_0_TLAST;
  assign M_AXIS_DS0_tvalid = dfx_decoupler_1_rp_intf_0_TVALID;
  assign M_AXI_DMA_IN_araddr[31:0] = axi_dma_0_M_AXI_MM2S_ARADDR;
  assign M_AXI_DMA_IN_arburst[1:0] = axi_dma_0_M_AXI_MM2S_ARBURST;
  assign M_AXI_DMA_IN_arcache[3:0] = axi_dma_0_M_AXI_MM2S_ARCACHE;
  assign M_AXI_DMA_IN_arlen[7:0] = axi_dma_0_M_AXI_MM2S_ARLEN;
  assign M_AXI_DMA_IN_arprot[2:0] = axi_dma_0_M_AXI_MM2S_ARPROT;
  assign M_AXI_DMA_IN_arsize[2:0] = axi_dma_0_M_AXI_MM2S_ARSIZE;
  assign M_AXI_DMA_IN_arvalid = axi_dma_0_M_AXI_MM2S_ARVALID;
  assign M_AXI_DMA_IN_rready = axi_dma_0_M_AXI_MM2S_RREADY;
  assign M_AXI_DMA_OUT_awaddr[31:0] = axi_dma_0_M_AXI_S2MM_AWADDR;
  assign M_AXI_DMA_OUT_awburst[1:0] = axi_dma_0_M_AXI_S2MM_AWBURST;
  assign M_AXI_DMA_OUT_awcache[3:0] = axi_dma_0_M_AXI_S2MM_AWCACHE;
  assign M_AXI_DMA_OUT_awlen[7:0] = axi_dma_0_M_AXI_S2MM_AWLEN;
  assign M_AXI_DMA_OUT_awprot[2:0] = axi_dma_0_M_AXI_S2MM_AWPROT;
  assign M_AXI_DMA_OUT_awsize[2:0] = axi_dma_0_M_AXI_S2MM_AWSIZE;
  assign M_AXI_DMA_OUT_awvalid = axi_dma_0_M_AXI_S2MM_AWVALID;
  assign M_AXI_DMA_OUT_bready = axi_dma_0_M_AXI_S2MM_BREADY;
  assign M_AXI_DMA_OUT_wdata[31:0] = axi_dma_0_M_AXI_S2MM_WDATA;
  assign M_AXI_DMA_OUT_wlast = axi_dma_0_M_AXI_S2MM_WLAST;
  assign M_AXI_DMA_OUT_wstrb[3:0] = axi_dma_0_M_AXI_S2MM_WSTRB;
  assign M_AXI_DMA_OUT_wvalid = axi_dma_0_M_AXI_S2MM_WVALID;
  assign S_AXIS_DS0_1_TDATA = S_AXIS_DS0_tdata[31:0];
  assign S_AXIS_DS0_1_TKEEP = S_AXIS_DS0_tkeep[3:0];
  assign S_AXIS_DS0_1_TLAST = S_AXIS_DS0_tlast;
  assign S_AXIS_DS0_1_TVALID = S_AXIS_DS0_tvalid;
  assign S_AXIS_DS0_tready = S_AXIS_DS0_1_TREADY;
  assign S_AXI_LITE_arready = DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY;
  assign S_AXI_LITE_awready = DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY;
  assign S_AXI_LITE_bresp[1:0] = DFX_Ctrl_0_axi_periph_M00_AXI_BRESP;
  assign S_AXI_LITE_bvalid = DFX_Ctrl_0_axi_periph_M00_AXI_BVALID;
  assign S_AXI_LITE_rdata[31:0] = DFX_Ctrl_0_axi_periph_M00_AXI_RDATA;
  assign S_AXI_LITE_rresp[1:0] = DFX_Ctrl_0_axi_periph_M00_AXI_RRESP;
  assign S_AXI_LITE_rvalid = DFX_Ctrl_0_axi_periph_M00_AXI_RVALID;
  assign S_AXI_LITE_wready = DFX_Ctrl_0_axi_periph_M00_AXI_WREADY;
  assign axi_dma_0_M_AXI_MM2S_ARREADY = M_AXI_DMA_IN_arready;
  assign axi_dma_0_M_AXI_MM2S_RDATA = M_AXI_DMA_IN_rdata[31:0];
  assign axi_dma_0_M_AXI_MM2S_RLAST = M_AXI_DMA_IN_rlast;
  assign axi_dma_0_M_AXI_MM2S_RRESP = M_AXI_DMA_IN_rresp[1:0];
  assign axi_dma_0_M_AXI_MM2S_RVALID = M_AXI_DMA_IN_rvalid;
  assign axi_dma_0_M_AXI_S2MM_AWREADY = M_AXI_DMA_OUT_awready;
  assign axi_dma_0_M_AXI_S2MM_BRESP = M_AXI_DMA_OUT_bresp[1:0];
  assign axi_dma_0_M_AXI_S2MM_BVALID = M_AXI_DMA_OUT_bvalid;
  assign axi_dma_0_M_AXI_S2MM_WREADY = M_AXI_DMA_OUT_wready;
  assign clk_0_1 = clk;
  assign dfx_decoupler_1_rp_intf_0_TREADY = M_AXIS_DS0_tready;
  assign reset_0_1 = nreset;
  assign s2mm_introut = axi_dma_0_s2mm_introut;
  assign util_vector_logic_0_Res = decouple;
  dfx_wrapper_axi_dma_0_0 axi_dma_0
       (.axi_resetn(reset_0_1),
        .m_axi_mm2s_aclk(clk_0_1),
        .m_axi_mm2s_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_0_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(clk_0_1),
        .m_axi_s2mm_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_dma_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_tdata(axi_dma_0_M_AXIS_MM2S_TDATA),
        .m_axis_mm2s_tkeep(axi_dma_0_M_AXIS_MM2S_TKEEP),
        .m_axis_mm2s_tlast(axi_dma_0_M_AXIS_MM2S_TLAST),
        .m_axis_mm2s_tready(axi_dma_0_M_AXIS_MM2S_TREADY),
        .m_axis_mm2s_tvalid(axi_dma_0_M_AXIS_MM2S_TVALID),
        .s2mm_introut(axi_dma_0_s2mm_introut),
        .s_axi_lite_aclk(clk_0_1),
        .s_axi_lite_araddr(DFX_Ctrl_0_axi_periph_M00_AXI_ARADDR[9:0]),
        .s_axi_lite_arready(DFX_Ctrl_0_axi_periph_M00_AXI_ARREADY),
        .s_axi_lite_arvalid(DFX_Ctrl_0_axi_periph_M00_AXI_ARVALID),
        .s_axi_lite_awaddr(DFX_Ctrl_0_axi_periph_M00_AXI_AWADDR[9:0]),
        .s_axi_lite_awready(DFX_Ctrl_0_axi_periph_M00_AXI_AWREADY),
        .s_axi_lite_awvalid(DFX_Ctrl_0_axi_periph_M00_AXI_AWVALID),
        .s_axi_lite_bready(DFX_Ctrl_0_axi_periph_M00_AXI_BREADY),
        .s_axi_lite_bresp(DFX_Ctrl_0_axi_periph_M00_AXI_BRESP),
        .s_axi_lite_bvalid(DFX_Ctrl_0_axi_periph_M00_AXI_BVALID),
        .s_axi_lite_rdata(DFX_Ctrl_0_axi_periph_M00_AXI_RDATA),
        .s_axi_lite_rready(DFX_Ctrl_0_axi_periph_M00_AXI_RREADY),
        .s_axi_lite_rresp(DFX_Ctrl_0_axi_periph_M00_AXI_RRESP),
        .s_axi_lite_rvalid(DFX_Ctrl_0_axi_periph_M00_AXI_RVALID),
        .s_axi_lite_wdata(DFX_Ctrl_0_axi_periph_M00_AXI_WDATA),
        .s_axi_lite_wready(DFX_Ctrl_0_axi_periph_M00_AXI_WREADY),
        .s_axi_lite_wvalid(DFX_Ctrl_0_axi_periph_M00_AXI_WVALID),
        .s_axis_s2mm_tdata(dfx_decoupler_0_s_intf_0_TDATA),
        .s_axis_s2mm_tkeep(dfx_decoupler_0_s_intf_0_TKEEP),
        .s_axis_s2mm_tlast(dfx_decoupler_0_s_intf_0_TLAST),
        .s_axis_s2mm_tready(dfx_decoupler_0_s_intf_0_TREADY),
        .s_axis_s2mm_tvalid(dfx_decoupler_0_s_intf_0_TVALID));
  dfx_wrapper_dfx_decoupler_0_0 dfx_decoupler_0
       (.decouple(util_vector_logic_0_Res),
        .intf_0_aclk(clk_0_1),
        .intf_0_arstn(reset_0_1),
        .rp_intf_0_TDATA(S_AXIS_DS0_1_TDATA),
        .rp_intf_0_TKEEP(S_AXIS_DS0_1_TKEEP),
        .rp_intf_0_TLAST(S_AXIS_DS0_1_TLAST),
        .rp_intf_0_TREADY(S_AXIS_DS0_1_TREADY),
        .rp_intf_0_TVALID(S_AXIS_DS0_1_TVALID),
        .s_intf_0_TDATA(dfx_decoupler_0_s_intf_0_TDATA),
        .s_intf_0_TKEEP(dfx_decoupler_0_s_intf_0_TKEEP),
        .s_intf_0_TLAST(dfx_decoupler_0_s_intf_0_TLAST),
        .s_intf_0_TREADY(dfx_decoupler_0_s_intf_0_TREADY),
        .s_intf_0_TVALID(dfx_decoupler_0_s_intf_0_TVALID));
  dfx_wrapper_dfx_decoupler_1_2 dfx_decoupler_1
       (.decouple(util_vector_logic_0_Res),
        .intf_0_aclk(clk_0_1),
        .intf_0_arstn(reset_0_1),
        .rp_intf_0_TDATA(dfx_decoupler_1_rp_intf_0_TDATA),
        .rp_intf_0_TKEEP(dfx_decoupler_1_rp_intf_0_TKEEP),
        .rp_intf_0_TLAST(dfx_decoupler_1_rp_intf_0_TLAST),
        .rp_intf_0_TREADY(dfx_decoupler_1_rp_intf_0_TREADY),
        .rp_intf_0_TVALID(dfx_decoupler_1_rp_intf_0_TVALID),
        .s_intf_0_TDATA(axi_dma_0_M_AXIS_MM2S_TDATA),
        .s_intf_0_TKEEP(axi_dma_0_M_AXIS_MM2S_TKEEP),
        .s_intf_0_TLAST(axi_dma_0_M_AXIS_MM2S_TLAST),
        .s_intf_0_TREADY(axi_dma_0_M_AXIS_MM2S_TREADY),
        .s_intf_0_TVALID(axi_dma_0_M_AXIS_MM2S_TVALID));
endmodule

module m00_couplers_imp_2VI8KG
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input S_AXI_wvalid;

  wire [31:0]m00_couplers_to_m00_couplers_ARADDR;
  wire m00_couplers_to_m00_couplers_ARREADY;
  wire m00_couplers_to_m00_couplers_ARVALID;
  wire [31:0]m00_couplers_to_m00_couplers_AWADDR;
  wire m00_couplers_to_m00_couplers_AWREADY;
  wire m00_couplers_to_m00_couplers_AWVALID;
  wire m00_couplers_to_m00_couplers_BREADY;
  wire [1:0]m00_couplers_to_m00_couplers_BRESP;
  wire m00_couplers_to_m00_couplers_BVALID;
  wire [31:0]m00_couplers_to_m00_couplers_RDATA;
  wire m00_couplers_to_m00_couplers_RREADY;
  wire [1:0]m00_couplers_to_m00_couplers_RRESP;
  wire m00_couplers_to_m00_couplers_RVALID;
  wire [31:0]m00_couplers_to_m00_couplers_WDATA;
  wire m00_couplers_to_m00_couplers_WREADY;
  wire m00_couplers_to_m00_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m00_couplers_to_m00_couplers_ARADDR;
  assign M_AXI_arvalid = m00_couplers_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m00_couplers_to_m00_couplers_AWADDR;
  assign M_AXI_awvalid = m00_couplers_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_couplers_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_couplers_to_m00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m00_couplers_to_m00_couplers_WDATA;
  assign M_AXI_wvalid = m00_couplers_to_m00_couplers_WVALID;
  assign S_AXI_arready = m00_couplers_to_m00_couplers_ARREADY;
  assign S_AXI_awready = m00_couplers_to_m00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_couplers_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_m00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m00_couplers_to_m00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_couplers_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_m00_couplers_RVALID;
  assign S_AXI_wready = m00_couplers_to_m00_couplers_WREADY;
  assign m00_couplers_to_m00_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_couplers_to_m00_couplers_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_m00_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_couplers_to_m00_couplers_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_m00_couplers_BREADY = S_AXI_bready;
  assign m00_couplers_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_couplers_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_couplers_to_m00_couplers_RDATA = M_AXI_rdata[31:0];
  assign m00_couplers_to_m00_couplers_RREADY = S_AXI_rready;
  assign m00_couplers_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_couplers_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_couplers_to_m00_couplers_WDATA = S_AXI_wdata[31:0];
  assign m00_couplers_to_m00_couplers_WREADY = M_AXI_wready;
  assign m00_couplers_to_m00_couplers_WVALID = S_AXI_wvalid;
endmodule

module m01_couplers_imp_15HK326
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]m01_couplers_to_m01_couplers_ARADDR;
  wire [0:0]m01_couplers_to_m01_couplers_ARREADY;
  wire [0:0]m01_couplers_to_m01_couplers_ARVALID;
  wire [31:0]m01_couplers_to_m01_couplers_AWADDR;
  wire [0:0]m01_couplers_to_m01_couplers_AWREADY;
  wire [0:0]m01_couplers_to_m01_couplers_AWVALID;
  wire [0:0]m01_couplers_to_m01_couplers_BREADY;
  wire [1:0]m01_couplers_to_m01_couplers_BRESP;
  wire [0:0]m01_couplers_to_m01_couplers_BVALID;
  wire [31:0]m01_couplers_to_m01_couplers_RDATA;
  wire [0:0]m01_couplers_to_m01_couplers_RREADY;
  wire [1:0]m01_couplers_to_m01_couplers_RRESP;
  wire [0:0]m01_couplers_to_m01_couplers_RVALID;
  wire [31:0]m01_couplers_to_m01_couplers_WDATA;
  wire [0:0]m01_couplers_to_m01_couplers_WREADY;
  wire [3:0]m01_couplers_to_m01_couplers_WSTRB;
  wire [0:0]m01_couplers_to_m01_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m01_couplers_to_m01_couplers_ARADDR;
  assign M_AXI_arvalid[0] = m01_couplers_to_m01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m01_couplers_to_m01_couplers_AWADDR;
  assign M_AXI_awvalid[0] = m01_couplers_to_m01_couplers_AWVALID;
  assign M_AXI_bready[0] = m01_couplers_to_m01_couplers_BREADY;
  assign M_AXI_rready[0] = m01_couplers_to_m01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m01_couplers_to_m01_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m01_couplers_to_m01_couplers_WSTRB;
  assign M_AXI_wvalid[0] = m01_couplers_to_m01_couplers_WVALID;
  assign S_AXI_arready[0] = m01_couplers_to_m01_couplers_ARREADY;
  assign S_AXI_awready[0] = m01_couplers_to_m01_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m01_couplers_to_m01_couplers_BRESP;
  assign S_AXI_bvalid[0] = m01_couplers_to_m01_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m01_couplers_to_m01_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m01_couplers_to_m01_couplers_RRESP;
  assign S_AXI_rvalid[0] = m01_couplers_to_m01_couplers_RVALID;
  assign S_AXI_wready[0] = m01_couplers_to_m01_couplers_WREADY;
  assign m01_couplers_to_m01_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m01_couplers_to_m01_couplers_ARREADY = M_AXI_arready[0];
  assign m01_couplers_to_m01_couplers_ARVALID = S_AXI_arvalid[0];
  assign m01_couplers_to_m01_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m01_couplers_to_m01_couplers_AWREADY = M_AXI_awready[0];
  assign m01_couplers_to_m01_couplers_AWVALID = S_AXI_awvalid[0];
  assign m01_couplers_to_m01_couplers_BREADY = S_AXI_bready[0];
  assign m01_couplers_to_m01_couplers_BRESP = M_AXI_bresp[1:0];
  assign m01_couplers_to_m01_couplers_BVALID = M_AXI_bvalid[0];
  assign m01_couplers_to_m01_couplers_RDATA = M_AXI_rdata[31:0];
  assign m01_couplers_to_m01_couplers_RREADY = S_AXI_rready[0];
  assign m01_couplers_to_m01_couplers_RRESP = M_AXI_rresp[1:0];
  assign m01_couplers_to_m01_couplers_RVALID = M_AXI_rvalid[0];
  assign m01_couplers_to_m01_couplers_WDATA = S_AXI_wdata[31:0];
  assign m01_couplers_to_m01_couplers_WREADY = M_AXI_wready[0];
  assign m01_couplers_to_m01_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m01_couplers_to_m01_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module m02_couplers_imp_1U79Y1P
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input S_AXI_wvalid;

  wire [31:0]m02_couplers_to_m02_couplers_ARADDR;
  wire m02_couplers_to_m02_couplers_ARREADY;
  wire m02_couplers_to_m02_couplers_ARVALID;
  wire [31:0]m02_couplers_to_m02_couplers_AWADDR;
  wire m02_couplers_to_m02_couplers_AWREADY;
  wire m02_couplers_to_m02_couplers_AWVALID;
  wire m02_couplers_to_m02_couplers_BREADY;
  wire [1:0]m02_couplers_to_m02_couplers_BRESP;
  wire m02_couplers_to_m02_couplers_BVALID;
  wire [31:0]m02_couplers_to_m02_couplers_RDATA;
  wire m02_couplers_to_m02_couplers_RREADY;
  wire [1:0]m02_couplers_to_m02_couplers_RRESP;
  wire m02_couplers_to_m02_couplers_RVALID;
  wire [31:0]m02_couplers_to_m02_couplers_WDATA;
  wire m02_couplers_to_m02_couplers_WREADY;
  wire m02_couplers_to_m02_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m02_couplers_to_m02_couplers_ARADDR;
  assign M_AXI_arvalid = m02_couplers_to_m02_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m02_couplers_to_m02_couplers_AWADDR;
  assign M_AXI_awvalid = m02_couplers_to_m02_couplers_AWVALID;
  assign M_AXI_bready = m02_couplers_to_m02_couplers_BREADY;
  assign M_AXI_rready = m02_couplers_to_m02_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m02_couplers_to_m02_couplers_WDATA;
  assign M_AXI_wvalid = m02_couplers_to_m02_couplers_WVALID;
  assign S_AXI_arready = m02_couplers_to_m02_couplers_ARREADY;
  assign S_AXI_awready = m02_couplers_to_m02_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m02_couplers_to_m02_couplers_BRESP;
  assign S_AXI_bvalid = m02_couplers_to_m02_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m02_couplers_to_m02_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m02_couplers_to_m02_couplers_RRESP;
  assign S_AXI_rvalid = m02_couplers_to_m02_couplers_RVALID;
  assign S_AXI_wready = m02_couplers_to_m02_couplers_WREADY;
  assign m02_couplers_to_m02_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m02_couplers_to_m02_couplers_ARREADY = M_AXI_arready;
  assign m02_couplers_to_m02_couplers_ARVALID = S_AXI_arvalid;
  assign m02_couplers_to_m02_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m02_couplers_to_m02_couplers_AWREADY = M_AXI_awready;
  assign m02_couplers_to_m02_couplers_AWVALID = S_AXI_awvalid;
  assign m02_couplers_to_m02_couplers_BREADY = S_AXI_bready;
  assign m02_couplers_to_m02_couplers_BRESP = M_AXI_bresp[1:0];
  assign m02_couplers_to_m02_couplers_BVALID = M_AXI_bvalid;
  assign m02_couplers_to_m02_couplers_RDATA = M_AXI_rdata[31:0];
  assign m02_couplers_to_m02_couplers_RREADY = S_AXI_rready;
  assign m02_couplers_to_m02_couplers_RRESP = M_AXI_rresp[1:0];
  assign m02_couplers_to_m02_couplers_RVALID = M_AXI_rvalid;
  assign m02_couplers_to_m02_couplers_WDATA = S_AXI_wdata[31:0];
  assign m02_couplers_to_m02_couplers_WREADY = M_AXI_wready;
  assign m02_couplers_to_m02_couplers_WVALID = S_AXI_wvalid;
endmodule

module m03_couplers_imp_VFB6DF
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m03_couplers_to_m03_couplers_ARADDR;
  wire m03_couplers_to_m03_couplers_ARREADY;
  wire m03_couplers_to_m03_couplers_ARVALID;
  wire [31:0]m03_couplers_to_m03_couplers_AWADDR;
  wire m03_couplers_to_m03_couplers_AWREADY;
  wire m03_couplers_to_m03_couplers_AWVALID;
  wire m03_couplers_to_m03_couplers_BREADY;
  wire [1:0]m03_couplers_to_m03_couplers_BRESP;
  wire m03_couplers_to_m03_couplers_BVALID;
  wire [31:0]m03_couplers_to_m03_couplers_RDATA;
  wire m03_couplers_to_m03_couplers_RREADY;
  wire [1:0]m03_couplers_to_m03_couplers_RRESP;
  wire m03_couplers_to_m03_couplers_RVALID;
  wire [31:0]m03_couplers_to_m03_couplers_WDATA;
  wire m03_couplers_to_m03_couplers_WREADY;
  wire [3:0]m03_couplers_to_m03_couplers_WSTRB;
  wire m03_couplers_to_m03_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m03_couplers_to_m03_couplers_ARADDR;
  assign M_AXI_arvalid = m03_couplers_to_m03_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m03_couplers_to_m03_couplers_AWADDR;
  assign M_AXI_awvalid = m03_couplers_to_m03_couplers_AWVALID;
  assign M_AXI_bready = m03_couplers_to_m03_couplers_BREADY;
  assign M_AXI_rready = m03_couplers_to_m03_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m03_couplers_to_m03_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m03_couplers_to_m03_couplers_WSTRB;
  assign M_AXI_wvalid = m03_couplers_to_m03_couplers_WVALID;
  assign S_AXI_arready = m03_couplers_to_m03_couplers_ARREADY;
  assign S_AXI_awready = m03_couplers_to_m03_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m03_couplers_to_m03_couplers_BRESP;
  assign S_AXI_bvalid = m03_couplers_to_m03_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m03_couplers_to_m03_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m03_couplers_to_m03_couplers_RRESP;
  assign S_AXI_rvalid = m03_couplers_to_m03_couplers_RVALID;
  assign S_AXI_wready = m03_couplers_to_m03_couplers_WREADY;
  assign m03_couplers_to_m03_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m03_couplers_to_m03_couplers_ARREADY = M_AXI_arready;
  assign m03_couplers_to_m03_couplers_ARVALID = S_AXI_arvalid;
  assign m03_couplers_to_m03_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m03_couplers_to_m03_couplers_AWREADY = M_AXI_awready;
  assign m03_couplers_to_m03_couplers_AWVALID = S_AXI_awvalid;
  assign m03_couplers_to_m03_couplers_BREADY = S_AXI_bready;
  assign m03_couplers_to_m03_couplers_BRESP = M_AXI_bresp[1:0];
  assign m03_couplers_to_m03_couplers_BVALID = M_AXI_bvalid;
  assign m03_couplers_to_m03_couplers_RDATA = M_AXI_rdata[31:0];
  assign m03_couplers_to_m03_couplers_RREADY = S_AXI_rready;
  assign m03_couplers_to_m03_couplers_RRESP = M_AXI_rresp[1:0];
  assign m03_couplers_to_m03_couplers_RVALID = M_AXI_rvalid;
  assign m03_couplers_to_m03_couplers_WDATA = S_AXI_wdata[31:0];
  assign m03_couplers_to_m03_couplers_WREADY = M_AXI_wready;
  assign m03_couplers_to_m03_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m03_couplers_to_m03_couplers_WVALID = S_AXI_wvalid;
endmodule

module m04_couplers_imp_6U742J
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m04_couplers_to_m04_couplers_ARADDR;
  wire m04_couplers_to_m04_couplers_ARREADY;
  wire m04_couplers_to_m04_couplers_ARVALID;
  wire [31:0]m04_couplers_to_m04_couplers_AWADDR;
  wire m04_couplers_to_m04_couplers_AWREADY;
  wire m04_couplers_to_m04_couplers_AWVALID;
  wire m04_couplers_to_m04_couplers_BREADY;
  wire [1:0]m04_couplers_to_m04_couplers_BRESP;
  wire m04_couplers_to_m04_couplers_BVALID;
  wire [31:0]m04_couplers_to_m04_couplers_RDATA;
  wire m04_couplers_to_m04_couplers_RREADY;
  wire [1:0]m04_couplers_to_m04_couplers_RRESP;
  wire m04_couplers_to_m04_couplers_RVALID;
  wire [31:0]m04_couplers_to_m04_couplers_WDATA;
  wire m04_couplers_to_m04_couplers_WREADY;
  wire [3:0]m04_couplers_to_m04_couplers_WSTRB;
  wire m04_couplers_to_m04_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m04_couplers_to_m04_couplers_ARADDR;
  assign M_AXI_arvalid = m04_couplers_to_m04_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m04_couplers_to_m04_couplers_AWADDR;
  assign M_AXI_awvalid = m04_couplers_to_m04_couplers_AWVALID;
  assign M_AXI_bready = m04_couplers_to_m04_couplers_BREADY;
  assign M_AXI_rready = m04_couplers_to_m04_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m04_couplers_to_m04_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m04_couplers_to_m04_couplers_WSTRB;
  assign M_AXI_wvalid = m04_couplers_to_m04_couplers_WVALID;
  assign S_AXI_arready = m04_couplers_to_m04_couplers_ARREADY;
  assign S_AXI_awready = m04_couplers_to_m04_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m04_couplers_to_m04_couplers_BRESP;
  assign S_AXI_bvalid = m04_couplers_to_m04_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m04_couplers_to_m04_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m04_couplers_to_m04_couplers_RRESP;
  assign S_AXI_rvalid = m04_couplers_to_m04_couplers_RVALID;
  assign S_AXI_wready = m04_couplers_to_m04_couplers_WREADY;
  assign m04_couplers_to_m04_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m04_couplers_to_m04_couplers_ARREADY = M_AXI_arready;
  assign m04_couplers_to_m04_couplers_ARVALID = S_AXI_arvalid;
  assign m04_couplers_to_m04_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m04_couplers_to_m04_couplers_AWREADY = M_AXI_awready;
  assign m04_couplers_to_m04_couplers_AWVALID = S_AXI_awvalid;
  assign m04_couplers_to_m04_couplers_BREADY = S_AXI_bready;
  assign m04_couplers_to_m04_couplers_BRESP = M_AXI_bresp[1:0];
  assign m04_couplers_to_m04_couplers_BVALID = M_AXI_bvalid;
  assign m04_couplers_to_m04_couplers_RDATA = M_AXI_rdata[31:0];
  assign m04_couplers_to_m04_couplers_RREADY = S_AXI_rready;
  assign m04_couplers_to_m04_couplers_RRESP = M_AXI_rresp[1:0];
  assign m04_couplers_to_m04_couplers_RVALID = M_AXI_rvalid;
  assign m04_couplers_to_m04_couplers_WDATA = S_AXI_wdata[31:0];
  assign m04_couplers_to_m04_couplers_WREADY = M_AXI_wready;
  assign m04_couplers_to_m04_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m04_couplers_to_m04_couplers_WVALID = S_AXI_wvalid;
endmodule

module s00_couplers_imp_1RX1W4W
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s00_couplers_to_s00_couplers_ARADDR;
  wire [0:0]s00_couplers_to_s00_couplers_ARREADY;
  wire [0:0]s00_couplers_to_s00_couplers_ARVALID;
  wire [31:0]s00_couplers_to_s00_couplers_AWADDR;
  wire [0:0]s00_couplers_to_s00_couplers_AWREADY;
  wire [0:0]s00_couplers_to_s00_couplers_AWVALID;
  wire [0:0]s00_couplers_to_s00_couplers_BREADY;
  wire [1:0]s00_couplers_to_s00_couplers_BRESP;
  wire [0:0]s00_couplers_to_s00_couplers_BVALID;
  wire [31:0]s00_couplers_to_s00_couplers_RDATA;
  wire [0:0]s00_couplers_to_s00_couplers_RREADY;
  wire [1:0]s00_couplers_to_s00_couplers_RRESP;
  wire [0:0]s00_couplers_to_s00_couplers_RVALID;
  wire [31:0]s00_couplers_to_s00_couplers_WDATA;
  wire [0:0]s00_couplers_to_s00_couplers_WREADY;
  wire [3:0]s00_couplers_to_s00_couplers_WSTRB;
  wire [0:0]s00_couplers_to_s00_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s00_couplers_to_s00_couplers_ARADDR;
  assign M_AXI_arvalid[0] = s00_couplers_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s00_couplers_to_s00_couplers_AWADDR;
  assign M_AXI_awvalid[0] = s00_couplers_to_s00_couplers_AWVALID;
  assign M_AXI_bready[0] = s00_couplers_to_s00_couplers_BREADY;
  assign M_AXI_rready[0] = s00_couplers_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s00_couplers_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s00_couplers_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s00_couplers_to_s00_couplers_WVALID;
  assign S_AXI_arready[0] = s00_couplers_to_s00_couplers_ARREADY;
  assign S_AXI_awready[0] = s00_couplers_to_s00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_couplers_BRESP;
  assign S_AXI_bvalid[0] = s00_couplers_to_s00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_s00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_couplers_RRESP;
  assign S_AXI_rvalid[0] = s00_couplers_to_s00_couplers_RVALID;
  assign S_AXI_wready[0] = s00_couplers_to_s00_couplers_WREADY;
  assign s00_couplers_to_s00_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_s00_couplers_ARREADY = M_AXI_arready[0];
  assign s00_couplers_to_s00_couplers_ARVALID = S_AXI_arvalid[0];
  assign s00_couplers_to_s00_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_s00_couplers_AWREADY = M_AXI_awready[0];
  assign s00_couplers_to_s00_couplers_AWVALID = S_AXI_awvalid[0];
  assign s00_couplers_to_s00_couplers_BREADY = S_AXI_bready[0];
  assign s00_couplers_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign s00_couplers_to_s00_couplers_BVALID = M_AXI_bvalid[0];
  assign s00_couplers_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign s00_couplers_to_s00_couplers_RREADY = S_AXI_rready[0];
  assign s00_couplers_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign s00_couplers_to_s00_couplers_RVALID = M_AXI_rvalid[0];
  assign s00_couplers_to_s00_couplers_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_s00_couplers_WREADY = M_AXI_wready[0];
  assign s00_couplers_to_s00_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_s00_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s01_couplers_imp_XPXUNI
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [0:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [0:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [0:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [0:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_s01_couplers_ARADDR;
  wire [2:0]auto_pc_to_s01_couplers_ARPROT;
  wire auto_pc_to_s01_couplers_ARREADY;
  wire auto_pc_to_s01_couplers_ARVALID;
  wire [31:0]auto_pc_to_s01_couplers_AWADDR;
  wire [2:0]auto_pc_to_s01_couplers_AWPROT;
  wire auto_pc_to_s01_couplers_AWREADY;
  wire auto_pc_to_s01_couplers_AWVALID;
  wire auto_pc_to_s01_couplers_BREADY;
  wire [1:0]auto_pc_to_s01_couplers_BRESP;
  wire auto_pc_to_s01_couplers_BVALID;
  wire [31:0]auto_pc_to_s01_couplers_RDATA;
  wire auto_pc_to_s01_couplers_RREADY;
  wire [1:0]auto_pc_to_s01_couplers_RRESP;
  wire auto_pc_to_s01_couplers_RVALID;
  wire [31:0]auto_pc_to_s01_couplers_WDATA;
  wire auto_pc_to_s01_couplers_WREADY;
  wire [3:0]auto_pc_to_s01_couplers_WSTRB;
  wire auto_pc_to_s01_couplers_WVALID;
  wire [31:0]s01_couplers_to_auto_pc_ARADDR;
  wire [1:0]s01_couplers_to_auto_pc_ARBURST;
  wire [3:0]s01_couplers_to_auto_pc_ARCACHE;
  wire [0:0]s01_couplers_to_auto_pc_ARID;
  wire [7:0]s01_couplers_to_auto_pc_ARLEN;
  wire [0:0]s01_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s01_couplers_to_auto_pc_ARPROT;
  wire [3:0]s01_couplers_to_auto_pc_ARQOS;
  wire s01_couplers_to_auto_pc_ARREADY;
  wire [3:0]s01_couplers_to_auto_pc_ARREGION;
  wire [2:0]s01_couplers_to_auto_pc_ARSIZE;
  wire s01_couplers_to_auto_pc_ARVALID;
  wire [31:0]s01_couplers_to_auto_pc_AWADDR;
  wire [1:0]s01_couplers_to_auto_pc_AWBURST;
  wire [3:0]s01_couplers_to_auto_pc_AWCACHE;
  wire [0:0]s01_couplers_to_auto_pc_AWID;
  wire [7:0]s01_couplers_to_auto_pc_AWLEN;
  wire [0:0]s01_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s01_couplers_to_auto_pc_AWPROT;
  wire [3:0]s01_couplers_to_auto_pc_AWQOS;
  wire s01_couplers_to_auto_pc_AWREADY;
  wire [3:0]s01_couplers_to_auto_pc_AWREGION;
  wire [2:0]s01_couplers_to_auto_pc_AWSIZE;
  wire s01_couplers_to_auto_pc_AWVALID;
  wire [0:0]s01_couplers_to_auto_pc_BID;
  wire s01_couplers_to_auto_pc_BREADY;
  wire [1:0]s01_couplers_to_auto_pc_BRESP;
  wire s01_couplers_to_auto_pc_BVALID;
  wire [31:0]s01_couplers_to_auto_pc_RDATA;
  wire [0:0]s01_couplers_to_auto_pc_RID;
  wire s01_couplers_to_auto_pc_RLAST;
  wire s01_couplers_to_auto_pc_RREADY;
  wire [1:0]s01_couplers_to_auto_pc_RRESP;
  wire s01_couplers_to_auto_pc_RVALID;
  wire [31:0]s01_couplers_to_auto_pc_WDATA;
  wire s01_couplers_to_auto_pc_WLAST;
  wire s01_couplers_to_auto_pc_WREADY;
  wire [3:0]s01_couplers_to_auto_pc_WSTRB;
  wire s01_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s01_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = auto_pc_to_s01_couplers_ARPROT;
  assign M_AXI_arvalid = auto_pc_to_s01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s01_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = auto_pc_to_s01_couplers_AWPROT;
  assign M_AXI_awvalid = auto_pc_to_s01_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s01_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s01_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s01_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s01_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s01_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s01_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[0] = s01_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s01_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s01_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s01_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[0] = s01_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s01_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s01_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s01_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s01_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s01_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s01_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s01_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s01_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s01_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s01_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s01_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s01_couplers_WREADY = M_AXI_wready;
  assign s01_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s01_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s01_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s01_couplers_to_auto_pc_ARID = S_AXI_arid[0];
  assign s01_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign s01_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[0];
  assign s01_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s01_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s01_couplers_to_auto_pc_ARREGION = S_AXI_arregion[3:0];
  assign s01_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s01_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s01_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s01_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s01_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s01_couplers_to_auto_pc_AWID = S_AXI_awid[0];
  assign s01_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign s01_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[0];
  assign s01_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s01_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s01_couplers_to_auto_pc_AWREGION = S_AXI_awregion[3:0];
  assign s01_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s01_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s01_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s01_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s01_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s01_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s01_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s01_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  dfx_wrapper_auto_pc_0 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s01_couplers_ARADDR),
        .m_axi_arprot(auto_pc_to_s01_couplers_ARPROT),
        .m_axi_arready(auto_pc_to_s01_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s01_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s01_couplers_AWADDR),
        .m_axi_awprot(auto_pc_to_s01_couplers_AWPROT),
        .m_axi_awready(auto_pc_to_s01_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s01_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s01_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s01_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s01_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s01_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s01_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s01_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s01_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s01_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s01_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s01_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s01_couplers_WVALID),
        .s_axi_araddr(s01_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s01_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s01_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s01_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s01_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s01_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s01_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s01_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s01_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion(s01_couplers_to_auto_pc_ARREGION),
        .s_axi_arsize(s01_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s01_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s01_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s01_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s01_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s01_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s01_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s01_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s01_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s01_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s01_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion(s01_couplers_to_auto_pc_AWREGION),
        .s_axi_awsize(s01_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s01_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s01_couplers_to_auto_pc_BID),
        .s_axi_bready(s01_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s01_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s01_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s01_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s01_couplers_to_auto_pc_RID),
        .s_axi_rlast(s01_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s01_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s01_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s01_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s01_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(s01_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s01_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s01_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s01_couplers_to_auto_pc_WVALID));
endmodule
