import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract Early voltage for a p-n-p bipolar transistor
sv.load_file('DATA/IcVc_pnp_des.plt', name='IcVce')

vcs = sv.get_variable_data(dataset='IcVce', varname='collector OuterVoltage')
ics = sv.get_variable_data(dataset='IcVce', varname='collector TotalCurrent')
ics_abs = np.abs(ics) # Compute absolute value of collector current

va = ext.extract_early_v(vcs, ics_abs, v_o=-1.25, name='Va', format='.2f')