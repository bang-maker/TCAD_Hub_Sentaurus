import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4) 

#------------------------------------------------------------------------------
# Extract Vti for n-MOSFET
sv.load_file('DATA/IdVgLin_nMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

lgate = 0.022 # um
io = 100e-9/lgate # subthreshold current level [A/um]
vti = ext.extract_vti(vgs, ids, io, name='VtiLin')

