import numpy as np
import os

input_file = 'x_input_1000000.npy'
output_file = 'x_input_20000.npy'

if not os.path.exists(input_file):
    print(f"Error: {input_file} not found.")
    exit(1)

print(f"Loading {input_file}...")
data = np.load(input_file)

print(f"Original shape: {data.shape}")

if data.shape == (1000000, 8, 8, 1):
    print("Shape matches (1000000, 8, 8, 1).")
    
    print("Slicing to (20000, 8, 8, 1)...")
    sliced_data = data[:20000]
    
    print(f"Sliced shape: {sliced_data.shape}")
    
    print(f"Saving to {output_file}...")
    np.save(output_file, sliced_data)
    print("Done.")
else:
    print(f"Error: Shape {data.shape} does not match (1000000, 8, 8, 1).")
    exit(1)
