import numpy as np
import os

input_file = 'x_input_1000000.npy'

data = np.load(input_file)
print(data[:100])
