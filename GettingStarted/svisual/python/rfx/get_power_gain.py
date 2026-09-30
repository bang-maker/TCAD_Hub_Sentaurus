import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=5)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_trunc_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Compute stability factor and power gain at 1e8 Hz as a function of bias
gain = rf.get_power_gain(
	dataset='Pgain_bias', powergain='all', xaxis='bias', target=1e8
)

print(f'Bias Points: {gain["bias"]}')
print(f'K: {gain["K"]}')
print(f'delta: {gain["delta"]}')
print(f'MSG: {gain["MSG"]}')
print(f'MSG_dB: {gain["MSG_dB"]}')
print(f'MAG: {gain["MAG"]}')
print(f'MAG_dB: {gain["MAG_dB"]}')
print(f'MUG: {gain["MUG"]}')
print(f'MUG_dB: {gain["MUG_dB"]}')
print(f'U: {gain["U"]}')

#-> Bias Points: [0.  0.1]
#-> K: [0.18019 0.0161 ]
#-> delta: [0.99999 0.99992]
#-> MSG: [ 5.55723 62.92755]
#-> MSG_dB: [ 7.44858 17.98841]
#-> MAG: [ 5.55723 62.92755]
#-> MAG_dB: [ 7.44858 17.98841]
#-> MUG: [ -102686.50144 -1218108.32141]
#-> MUG_dB: [50.11513 60.85686]
#-> U: [ 66383.57685 134797.56995]