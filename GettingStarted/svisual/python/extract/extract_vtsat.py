import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4) 

#------------------------------------------------------------------------------
# Extract Vtsat for n-MOSFET
sv.load_file('DATA/IdVgLin_nMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

vt = ext.extract_vtsat(vgs, ids, name='VtiLin')