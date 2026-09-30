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

z_matrix = rfx.y2z(y_matrix)

print(f'z_matrix = \n{z_matrix}')
#-> z_matrix = 
#-> [[ -482.3646-3.3658e+05j  1340.1477+2.4628e+00j]
#->  [64960.8792+6.5392e+06j 10152.5773-1.0846e+02j]]