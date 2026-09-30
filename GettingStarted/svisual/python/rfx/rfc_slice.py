import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

# Compute z11 at v=0.5 V as a function of frequency
# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

i_bias = rfx.get_nearest_index(0.5, rf.bias)
print(f'Nearest bias point index: {i_bias}')

bias_point = rf.bias[i_bias]
print(f'Corresponding bias point: {bias_point}')
#-> Nearest bias point index: 10
#-> Corresponding bias point: 0.5

z11 = rf.rfc_slice(rfparameter='z11', index=i_bias, xaxis='frequency')
print(f'z11 = \n{z11}')
#-> z11 = 
#-> [10748.31634735 -138.15575716j 10746.14336395 -202.74139252j
#->  10741.46514002 -297.44612437j 10731.40073401 -436.15687422j
#->  10709.78575734 -638.82159779j 10663.53100927 -933.36140721j
#->  10565.30736024-1356.58293844j 10360.09564533-1950.08644955j
#-> ...