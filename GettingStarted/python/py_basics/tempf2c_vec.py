# Script: tempf2c_vect.py

import numpy as np

# Set the precision for printing floating-point numbers in NumPy objects
np.set_printoptions(precision=4)

fahren = np.linspace(0, 80, 5)
print(f'{fahren= }')
celsius = (5 / 9) * (fahren - 32)
print(f'{celsius= }')