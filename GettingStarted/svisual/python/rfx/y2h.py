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

h_matrix = rfx.y2h(y_matrix)

print(f'h_matrix = \n{h_matrix}')
#-> h_matrix = 
#-> [[1.7500e+03-1.1997e+06j 1.3198e-01+1.6525e-03j]
#->  [4.8215e-01-6.4408e+02j 9.8486e-05+1.0521e-06j]]