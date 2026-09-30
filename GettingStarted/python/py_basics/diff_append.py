# Script: diff_append.py
import numpy as np

x = np.array([1.0, 2.0, 3.0, 4.0])
y = 2 * x

# Create empty derivatives array
dydx = np.empty(0) 
print(f'{id(dydx)= }')
for i in range(3):
    der = (y[i+1] - y[i]) / (x[i+1] - x[i])
    # Compute derivative and append to derivatives array
    dydx = np.append(dydx, der) 
    print(f'{id(dydx)= }')

print(f'{dydx= }')