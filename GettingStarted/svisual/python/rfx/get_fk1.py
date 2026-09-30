import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=2)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Compute fK1 versus bias corresponding dataset
fk = rf.get_fk1(
    dataset='fK_bias', xscale='log', target=1.0, occurrence=1, scale=1e9
)

print('Bias Points: ')
print(fk['bias'])
print('Cutoff frequencies for stability [GHz]:')
print(fk['fK1'])

#-> Bias Points: 
#-> [0.   0.05 0.1  0.15 0.2  0.25 0.3  0.35 0.4 ...]
#-> Cutoff frequencies for stability [GHz]: 
#-> [ 0.    0.    0.    0.   14.53  8.04  6.83  6.46  6.32 ... ]