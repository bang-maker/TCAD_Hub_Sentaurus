import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

np.set_printoptions(precision=4)

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Compute AC parameters at first bias point and frequency
bias_pt = rf.bias[0]
freq_pt = rf.freq[0]

ac_data = rf.get_pars_at_point(
    rf_matrix='AC', bias_point=bias_pt, freq_point=freq_pt
)

# Build ac matrix
ac11, ac12 = ac_data[(1,1)], ac_data[(1,2)]
ac21, ac22 = ac_data[(2,1)], ac_data[(2,2)]

ac_matrix = np.array(
    [[ac11, ac12],
     [ac21, ac22]]
)
        
# Print ac matrix
print(f'{ac_data["bias"] = }')
print(f'{ac_data["freq"] = }')
print(f'ac_matrix = \n{ac_matrix}')

#-> ac_data["bias"] = array(0.)
#-> ac_data["freq"] = array(1.e+08)
#-> ac_matrix = 
#-> [[ 9.0000e-06+3.8010e-16j -9.0000e-06-1.7187e-16j]
#->  [-8.4097e-06-1.7212e-16j  9.0767e-06+3.1516e-16j]]

