# Import RFX module 
import svisualpylib.rfx as rfx

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Export RF-parameters to s2p file
rf.export_s2p(rfmatrix='S', bias=0.7, unit='GHz', filename='Sparam.s2p')

# Update z0 and export S-parameters to s2p file
rf.z0 = 100.0
rf.export_s2p(rfmatrix='S', bias=0.7, unit='GHz', filename='Sparam_z0_100.s2p')