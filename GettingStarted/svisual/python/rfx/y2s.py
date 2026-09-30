import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=4)

y11 = 1.21582e-09 + 8.33508513295e-07j
y12 = 1.21693e-09 - 1.10011034906e-07j
y21 = 0.000536849 - 3.81214675594e-07j
y22 = 2.76303e-05 + 2.15260671987e-07j

y_matrix = np.array(
    [[y11, y12],
     [y21, y22]]
)

# Convert y-matrix to s-matrix:
# Use default characteristics impedance of 50 Ohm
s_matrix = rfx.y2s(y_matrix)

print(f's_matrix = \n{s_matrix}')
#-> s_matrix = 
#-> [[ 1.0000e+00-8.3646e-05j -1.2095e-07+1.0986e-05j]
#-> [-5.3611e-02+4.0887e-05j  9.9724e-01-2.1761e-05j]]

# Use characteristics impedance of 100 Ohm
s_matrix = rfx.y2s(y_matrix, z0=100.0)

print(f's_matrix = \n{s_matrix}')
#-> s_matrix = 
#-> [[ 1.0000e+00-1.6788e-04j -2.4040e-07+2.1942e-05j]
#->  [-1.0707e-01+8.7319e-05j  9.9449e-01-4.3990e-05j]]