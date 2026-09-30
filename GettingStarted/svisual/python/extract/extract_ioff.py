import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract drain leakage current of a pMOSFET 
sv.load_file('DATA/IdVgSat_pMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')
abs_ids = np.abs(ids)

ioff = ext.extract_ioff(vgs, abs_ids, v_o=-1e-4, log10=False, name='Ioff')
print(f'Ioff: {ioff:.3e} A/um')
#-> Ioff: 4.009e-06 A/um

log10_ioff = ext.extract_ioff(vgs, abs_ids, v_o=-1e-4, log10=True, name=None)
print(f'Log10Ioff: {log10_ioff:.3f}')
#-> Log10Ioff: -5.397 