import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4) 

#------------------------------------------------------------------------------
# Extract Vglin for n-MOSFET
sv.load_file('DATA/IdVgLin_nMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

vg = ext.extract_vglin(vgs, ids, i_o=1e-7, name='Vglin', format='.4f')