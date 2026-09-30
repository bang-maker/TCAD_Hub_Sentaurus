# Script: diff_vectorize.py
import numpy as np

x = np.array([1.0, 2.0, 3.0, 4.0])
y = 2 * x

dydx = np.diff(y)/np.diff(x)
print(f'{dydx= }')