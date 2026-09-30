import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract gm for a p-MOSFET
sv.load_file('DATA/IdVgLin_pMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')
abs_ids = np.abs(ids)

gm = ext.extract_gm(vgs, abs_ids, name='gmLin')
print(f'Max gm: {gm:.3e} S/um')
#-> Max gm: 1.913e-04 S/um