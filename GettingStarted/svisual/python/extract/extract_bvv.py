import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract breakdown voltage of a n-p-n bipolar transistor
sv.load_file('DATA/IcVcBV_npn_des.plt', name='BV')
vcb = sv.get_variable_data(dataset='BV', varname='collector InnerVoltage')
ic = sv.get_variable_data(dataset='BV', varname='collector TotalCurrent')

bv = ext.extract_bvv(vcb, is_npn=True, name='BVcbov', format='.3f')