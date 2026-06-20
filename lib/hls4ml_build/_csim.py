"""csim mixin: single-partition predict + end-to-end chained csim across partitions."""

import numpy as np


class CsimMixin:
    """``csim_partition`` (single) and ``csim_chain`` (end-to-end) -- step 2."""

    @staticmethod
    def _aslist(y):
        """Normalize predict(): list for multi-output partitions, single array otherwise."""
        return list(y) if isinstance(y, (list, tuple)) else [y]

    def _partition_of(self, name):
        for partition in self.partitions:
            if partition.name == name:
                return partition
        raise KeyError(f"no partition named '{name}'")

    def csim_partition(self, name, inputs):
        """Compile + predict a single partition. ``inputs`` is an array or list of arrays."""
        hm = self.hls_models[name]
        hm.compile()
        ins = inputs if isinstance(inputs, (list, tuple)) else [inputs]
        # ins is supposed to   be [ np.array(SAMPLE, *DIM), .... ]
        return hm.predict(ins[0] if len(ins) == 1 else list(ins))
        # if it is ins[0]
        # list() is to prevent it to be tuple

    def _ext_input(self, n):
        """Random external input matching the 'DMA' port of the entry partition."""
        for partition in self.partitions:
            if 'DMA' in partition.inputs:
                idx = partition.inputs.index('DMA')
                shp = [int(d) for d in partition.model.inputs[idx].shape[1:]]
                return np.random.rand(n, *shp).astype('float32')
        raise RuntimeError("no partition consumes 'DMA'")

    def csim_chain(self, x0=None, n=2, peek=0):
        """End-to-end csim: chain partition n's outputs into n+1's inputs by stream name.

        Routes data exactly like the hardware ('DMA' = external network in/out, every other
        name is an inter-partition stream). Requires the partitions in producer-first order.
        Returns ``(final, bus)`` where ``final`` is the 'DMA' output and ``bus`` maps every
        inter-partition stream name to its csim array.
        """
        if x0 is None:
            x0 = self._ext_input(n)
        bus = {}      # inter-partition stream name -> array (flat, per-sample)
        final = None  # last partition writes the network output to 'DMA'
        for partition in self.partitions:
            hm = self.hls_models[partition.name]
            hm.compile()
            print('=' * 64, partition.name)
            ins = [x0 if name == 'DMA' else bus[name] for name in partition.inputs]
            if peek:
                for name, a in zip(partition.inputs, ins):
                    self._peek('in ', name, a, peek)
            outs = self._aslist(hm.predict(ins[0] if len(ins) == 1 else ins))
            for name, a in zip(partition.output_names, outs):
                if peek:
                    self._peek('out', name, a, peek)
                if name == 'DMA':
                    final = a
                else:
                    bus[name] = a
        print('=' * 64)
        print('end-to-end output shape:', None if final is None else np.asarray(final).shape)
        return final, bus

    @staticmethod
    def _peek(tag, name, a, peek):
        a = np.asarray(a)
        vals = np.array2string(a.ravel()[:peek], precision=4, floatmode='fixed')
        print(f'  {tag} {name:8s} {str(a.shape):14s} first{peek}= {vals}')
