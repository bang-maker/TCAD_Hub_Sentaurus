# Import RFX module 
import svisualpylib.rfx as rfx

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Export S-parameters to CSV file using default value of z0 (50 Ohm)
rf.export(rfmatrix='S', xaxis='frequency', filename='Sparam_freq.csv')

# Update z0 and export S-parameters to CSV file
rf.z0 = 100.0
rf.export(rfmatrix='S', xaxis='frequency', filename='Sparam_freq_100.csv')
