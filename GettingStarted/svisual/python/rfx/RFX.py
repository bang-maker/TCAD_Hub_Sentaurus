import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=2)

# Create RFX object rf1; Create AC- and Y-matrix
rf1 = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Access attributes of object rf1
print(f'Number of bias points: {rf1.nbias}')
print(f'Bias points: {rf1.bias}')
print(f'Number of frequencies: {rf1.nfreq}') 
print(f'Frequencies: {rf1.freq}') 

#-> Number of bias points: 21
#-> Bias points: [0.   0.05 0.1 ... 0.9  0.95 1.  ]
#-> Number of frequencies: 25
#-> Frequencies: [1.00e+08 1.47e+08 2.15e+08 ... 6.81e+11 1.00e+12]

# Create another RFX object rf2; Create AC- and Y-matrix
rf2 = rfx.RFX(    
    filename='DATA/pMOS_ac_des.plt', dataset='ACPLT_pMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

print(f'Number of bias points: {rf2.nbias}')
print(f'Bias points: {rf2.bias}')
print(f'Number of frequencies: {rf2.nfreq}')
print(f'Frequencies: {rf2.freq}') 

#-> Number of bias points: 21
#-> Bias points: [ 0.   -0.05 -0.1 ... -0.9  -0.95 -1.  ]
#-> Number of frequencies: 25
#-> Frequencies: [1.00e+08 1.47e+08 2.15e+08 ... 6.81e+11 1.00e+12]