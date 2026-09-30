import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=4)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_noise_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)'
)

# Compute noise parameters, noise figure and input-referred spectral densities
# at 0 bias, as a function of frequency
nf = rf.get_noise_figure(dataset='NF_freq', xaxis='frequency', target=0.0)

print(f'freq = \n{nf["freq"]}')
print(f'NF = \n{nf["NF"]}')
print(f'NFmin = \n{nf["NFmin"]}')
print(f'Rn = \n{nf["Rn"]}')
print(f'Yopt = \n{nf["Yopt"]}')
print(f'Sv = \n{nf["Sv"]}')
print(f'Si = \n{nf["Si"]}')
print(f'Svi = \n{nf["Svi"]}')
