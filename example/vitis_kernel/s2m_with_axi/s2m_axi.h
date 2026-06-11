#ifndef MYPROJECT_AXI_H_
#define MYPROJECT_AXI_H_

#include <iostream>
#include "ap_axi_sdata.h"

typedef hls::axis<int, 0, 0, 0> dma_data_packet;

void s2m_axi_stream(
                         hls::stream<dma_data_packet> &axi_input_stream,
                         hls::stream<dma_data_packet> &axi_output_stream, int batch_size);
#endif