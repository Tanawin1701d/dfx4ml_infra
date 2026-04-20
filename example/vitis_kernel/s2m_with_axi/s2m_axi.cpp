#include "ap_axi_sdata.h"

typedef hls::axis<int, 0, 0, 0, AXIS_ENABLE_KEEP | AXIS_ENABLE_LAST> dma_data_packet;



void axis_to_stream(
    hls::stream<dma_data_packet> &in,
    hls::stream<int> &out,
    int batch_size)
{
//     for (int i = 0; i < batch_size; i++) {
// #pragma HLS PIPELINE II=1
//         dma_data_packet w;
//         in.read(w);
//         out.write(w.data);
//     }

    while(true){
#pragma HLS PIPELINE II=1
        dma_data_packet w;
        in.read(w);
        out.write(w.data);
        if (w.data == 7){
            break;
        }
    }
}

void stream_to_axis(
    hls::stream<int> &in,
    hls::stream<dma_data_packet> &out,
    int batch_size)
{
//     for (int i = 0; i < batch_size; i++) {
// #pragma HLS PIPELINE II=1
//         dma_data_packet w;
//         w.data = in.read();
//         w.last = (i == batch_size - 1);
//         w.keep = -1;
//         out.write(w);
//     }

    while (true) {
#pragma HLS PIPELINE II=1
        dma_data_packet w;
        w.data = in.read();
        w.last = 0; ///(i == batch_size - 1);
        w.keep = -1;
        out.write(w);
        if (w.data == 7){
            break;
        }
    }

}

void s2m_axi_stream(
    hls::stream<dma_data_packet> &axi_input_stream,
    hls::stream<dma_data_packet> &axi_output_stream,
    int batch_size)
{
#pragma HLS INTERFACE axis port=axi_input_stream
#pragma HLS INTERFACE axis port=axi_output_stream
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=batch_size bundle=control

    static hls::stream<int> model_input_stream("model_input");
#pragma HLS STREAM variable=model_input_stream depth=1024
#pragma HLS DATAFLOW
axis_to_stream(axi_input_stream, model_input_stream, batch_size);
stream_to_axis(model_input_stream, axi_output_stream, batch_size);
}