# Script: tempf2c_vec_tab.py
import numpy as np

fahren = np.linspace(0, 80, 5)
celsius = (5 / 9) * (fahren - 32)

# Print temperatures in tabular format
print(f'Fahren Celsius')
for fahren, celsius in zip(fahren, celsius):
    print(f'{fahren:6.0f} {celsius:7.1f}')