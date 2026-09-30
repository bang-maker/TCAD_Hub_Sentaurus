import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)'
)

# Ex 1: Get nearest bias index corresponding to 0.025 V
i_bias = rfx.get_nearest_index(0.025, rf.bias)
print(f'Nearest bias point index: {i_bias}')

# Get bias point corresponding to the nearest bias index
bias_point = rf.bias[i_bias]
print(f'Corresponding bias point: {bias_point}')

#-> Nearest bias point index: 0
#-> Corresponding bias point: 0

# Ex 2: Get nearest frequency index corresponding to 1e9 Hz
i_freq = rfx.get_nearest_index(1e9, rf.freq)
print(f'Nearest frequency index: {i_freq}')

# Get frequency corresponding to the nearest frequency index
freq_point = rf.freq[i_freq]
print(f'Corresponding frequency: {freq_point:.2e}')

#-> Nearest frequency index: 6
#-> Corresponding frequency point: 1.00e+09