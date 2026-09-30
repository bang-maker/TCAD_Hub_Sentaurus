# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract Vtgm for a p-MOSFET
sv.load_file('DATA/IdVgLin_pMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')
abs_ids = np.abs(ids)

vt = ext.extract_vtgm(vgs, abs_ids, name='Vtgm')

print(f'Vt (Max gm method): {vt:.3f} V')
#-> Vt (Max gm method): -0.503 V