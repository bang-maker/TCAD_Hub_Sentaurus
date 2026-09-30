import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

si11 = [8.24593987e-23, 0.0]
si12 = [-3.91285654e-23, -1.08922612e-23]
si22 = [4.57789473e-23, 0.0]
y11 = [0.00613324387, 0.0170027533]
y21 = [-0.00506706586, -0.0060744537]

si11 = 8.24593987e-23 + 0.0j
si12 = -3.91285654e-23-1.08922612e-23j
si21 = si12
si22 = 4.57789473e-23 + 0.0j
y11 = 0.00613324387 + 0.0170027533j
y21 = -0.00506706586-0.0060744537j
y22 = y11
y12 = y21

si_matrix = np.array(
    [[si11, si12], 
     [si12, si22]]
)

y_matrix = np.array(
    [[y11, y12],
     [y21, y22]]
)
nf = rfx.noise_figure(si_matrix, y_matrix)

print(f'NF = {nf["NF"]:.2f}')
print(f'NFmin = {nf["NFmin"]:.2f}')
print(f'Rn = {nf["Rn"]:.2f}')
print(f'Yopt = {nf["Yopt"]:.2e}')
print(f'Sv = {nf["Sv"]:.2e}')
print(f'Si = {nf["Si"]:.2e}')
print(f'Svi = {nf["Svi"]:.2e}')

#-> NF = 4.21
#-> NFmin = 3.19
#-> Rn = 45.68
#-> Yopt = 8.60e-03-1.06e-02j
#-> Sv = 7.32e-19
#-> Si = 1.36e-22
#-> Svi = 2.38e-21-7.76e-21j