#ifndef NNET_HELPERS_DFX_H_
#define NNET_HELPERS_DFX_H_

// ---------------------------------------------------------------------------
// Flat AXI-Stream <-> float[] converters for the VitisUnifiedDFx4ml backend.
//
// The dfx4ml multi-port kernels expose one flat AXI-Stream port per dfx
// streamer. Each beat on a flat port carries a whole MODEL_T chunk (an
// nnet::array of MODEL_T::size elements), exactly like load_input_flat /
// store_result_flat in the generated wrapper. The csim bridge and the cosim
// testbench drive / drain those ports from plain float buffers, so they need a
// pack/unpack that matches the wrapper's MODEL_T-per-beat convention.
// ---------------------------------------------------------------------------

#include <hls_stream.h>

namespace nnet {

// float[N]  ->  flat AXIS stream<AXI_T>  (N / MODEL_T::size beats)
template <typename AXI_T, typename MODEL_T, unsigned N>
void convert_data_axis_flat(float *src, hls::stream<AXI_T> &dst) {
    const unsigned n_beat = N / MODEL_T::size;
    for (unsigned c = 0; c < n_beat; c++) {
        MODEL_T chunk;
        for (unsigned j = 0; j < MODEL_T::size; j++) {
            chunk[j] = src[c * MODEL_T::size + j];
        }
        AXI_T pack;
        pack.data = chunk;
        pack.keep = -1;
        pack.last = (c == (n_beat - 1)) ? 1 : 0;
        dst.write(pack);
    }
}

// flat AXIS stream<AXI_T>  ->  float[N]
template <typename AXI_T, typename MODEL_T, unsigned N>
void convert_data_axis_flat(hls::stream<AXI_T> &src, float *dst) {
    const unsigned n_beat = N / MODEL_T::size;
    for (unsigned c = 0; c < n_beat; c++) {
        AXI_T pack = src.read();
        MODEL_T chunk = pack.data;
        for (unsigned j = 0; j < MODEL_T::size; j++) {
            dst[c * MODEL_T::size + j] = (float)chunk[j];
        }
    }
}

// fill a flat AXIS input stream with zeros (default-input path in the testbench)
template <typename AXI_T, typename MODEL_T, unsigned N> void fill_zero_axis_flat(hls::stream<AXI_T> &dst) {
    const unsigned n_beat = N / MODEL_T::size;
    for (unsigned c = 0; c < n_beat; c++) {
        MODEL_T chunk;
        for (unsigned j = 0; j < MODEL_T::size; j++) {
            chunk[j] = 0;
        }
        AXI_T pack;
        pack.data = chunk;
        pack.keep = -1;
        pack.last = (c == (n_beat - 1)) ? 1 : 0;
        dst.write(pack);
    }
}

// drain a flat AXIS output stream to a std::ostream (print path in the testbench)
template <typename AXI_T, typename MODEL_T, unsigned N>
void print_result_axis_flat(hls::stream<AXI_T> &src, std::ostream &out, bool keep = false) {
    const unsigned n_beat = N / MODEL_T::size;
    for (unsigned c = 0; c < n_beat; c++) {
        AXI_T pack = src.read();
        MODEL_T chunk = pack.data;
        for (unsigned j = 0; j < MODEL_T::size; j++) {
            out << (float)chunk[j] << " ";
        }
        if (keep) {
            src.write(pack);
        }
    }
}

} // namespace nnet

#endif
