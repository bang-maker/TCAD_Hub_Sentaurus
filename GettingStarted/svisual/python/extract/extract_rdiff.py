import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Extract on-state output resistance of a p-n-p bipolar transistor
sv.load_file('DATA/IcVc_pnp_des.plt', name='IcVce')

vcs = sv.get_variable_data(dataset='IcVce', varname='collector OuterVoltage')
ics = sv.get_variable_data(dataset='IcVce', varname='collector TotalCurrent')
ics_abs = np.abs(ics) # Compute absolute value of collector current

r_on = ext.extract_rdiff(vcs, ics_abs, v_o=-1.25, name='Ron', format='.2e')

print(f'Ron (at Vcs= -1.25 V): {r_on: .2e} Ohm-um')
#-> Ron= 3.35e+04 Ohm-um