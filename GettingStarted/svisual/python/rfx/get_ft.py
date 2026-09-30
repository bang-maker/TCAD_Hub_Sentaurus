import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=2)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Compute ft Vs bias. 
# Create dh21 Vs frequency and ft Vs bias datasets
ft = rf.get_ft(
    dataset='ft_bias', slopedataset='h21_slope_freq',
    method='unit-gain-point', xscale='log', scale=1e9
)

print(f'Bias Points: {ft["bias"]}')
print(f'Cutoff frequencies [GHz]: {ft["ft"]}')

#-> Bias Points: [0.   0.05 0.1  0.15 ... 0.95 1.  ]
#-> Cutoff frequencies [GHz]: [  0.     0.     0.     4.3 ... 438.72 401.3]