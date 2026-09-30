import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

# Ex 1: Compute power gain by specifying the S-parameters
s11 = 0.999999877967 - 8.36457327936e-05j
s12 = -1.20947562066e-07 + 1.09859319808e-05j
s21 =  -0.0536108305232 + 4.08872504539e-05j
s22 = 0.997240784695 - 2.17611978854e-05j

s_matrix = np.array(
    [[s11, s12],
     [s21, s22]] 
)

pgain = rfx.power_gain(s_matrix)

print(f'K = {pgain[0]:.4f}')
print(f'delta = {pgain[1]:.4f}')
print(f'MSG = {pgain[2]:.2f}')
print(f'MAG = {pgain[3]:.2f}')
print(f'MUG = {pgain[4]:.2f}')
print(f'U = {pgain[5]:.2f}')

#-> K = -0.0092
#-> delta = 0.9972
#-> MSG = 4879.66
#-> MAG = 4879.66
#-> MUG = -116265.65
#-> U = 449.60

# Ex 2: Get S-parameters from PLT file and compute power gain
# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_trunc_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# get s-parameters
sparam = rf.get_pars_at_point(
    rf_matrix='S', bias_point=0, freq_point=0
)
s11, s12 = sparam[(1,1)], sparam[(1,2)] 
s21, s22 = sparam[(2,1)], sparam[(2,2)]

s_matrix = np.array(
    [[s11, s12],
     [s21, s22]] 
)

pgain = rfx.power_gain(s_matrix)

print(f'K = {pgain[0]:.4f}')
print(f'delta = {pgain[1]:.4f}')
print(f'MSG = {pgain[2]:.2f}')
print(f'MAG = {pgain[3]:.2f}')
print(f'MUG = {pgain[4]:.2f}')
print(f'U = {pgain[5]:.2f}')

#-> K = 0.1802
#-> delta = 1.0000
#-> MSG = 5.56
#-> MAG = 5.56
#-> MUG = -102686.50
#-> U = 66383.58