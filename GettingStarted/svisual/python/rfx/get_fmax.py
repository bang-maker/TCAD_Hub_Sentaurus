import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=2)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Compute fmax Vs bias using MUG. 
# Create dMUG Vs frequency and fmax Vs bias datasets
fmax = rf.get_fmax(
    dataset='fmax_bias', slopedataset='MUG_slope_freq',
    powergain='MUG', method='unit-gain-point', 
    xscale='log', scale=1e9
)

print(f'Bias Points: {fmax["bias"]}')
print(f'Max frequency of oscillation [GHz]: {fmax["fmax"]}')

#-> Bias Points: [0.   0.05 0.1  0.15 0.2  0.25 0.3 ...]
#-> Max frequency of oscillation [GHz]: [  0.     0.     0.     0.   172.24 ... ] 