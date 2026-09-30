import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4) 

#------------------------------------------------------------------------------
# Extract Vdlin for n-MOSFET
sv.load_file('DATA/IdVd_nMOS_des.plt', name='DC')
vds = sv.get_variable_data(dataset='DC', varname='drain OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

vd = ext.extract_vdlin(vds, ids, i_o=1e-4, name='Vdlin', format='.4f')