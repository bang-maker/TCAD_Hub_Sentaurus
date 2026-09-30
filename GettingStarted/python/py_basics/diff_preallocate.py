# Script: diff_preallocate.py
import numpy as np

x = np.array([1.0, 2.0, 3.0, 4.0])
y = 2 * x

# Preallocate dydx: Create derivate array filled with zeros
dydx = np.zeros(len(x)-1) 
print(f'{id(dydx)= }')
for i in range(3):
    # Compute derivative and update derivative array
    dydx[i] = (y[i+1] - y[i]) / (x[i+1] - x[i])
    print(f'{id(dydx)= }')
    
print(f'{dydx= }')  