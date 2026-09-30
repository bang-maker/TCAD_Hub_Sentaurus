import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4) 

#------------------------------------------------------------------------------
# Extract subthreshold voltage swing for n-MOSFET
sv.load_file('DATA/IdVgLin_nMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

vgo = 1e-2
ss = ext.extract_ss(vgs, ids, vgo, name='SSlin')