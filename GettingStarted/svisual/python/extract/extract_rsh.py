import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
sv.load_file('DATA/LDMOS_des.tdr', name='Structure2d')
sv.create_plot(name='Plot_Structure2d', dataset='Structure2d') 

# Create cutline at y=5.0 and extract Rsh
rsh = ext.extract_rsh(
    dataset='Structure2d', sem_dataset='RshProfile', axis_type='y', at=5.0
)

print(f"Thickness of each layer: {rsh['d']= }'")
#-> Thickness of each layer: rsh['d']= array([ 2.023 ,  7.4849, 10.0819])'

# p-n junction depth
print(f"xj: {rsh['xjTop']:.3f} um")
#-> xj: 2.023 um

print(f"Sheet Resistance of each layer: {rsh['rsh']= }")
#-> Sheet Resistance of each layer: rsh['rsh']= array([7.2661e+04, 7.3474e+02, 2.4960e+01])

# Sheet resistance of top layer
print(f"Rshtop: {rsh['rshTop']:.2e} Ohm/sq")
#-> Rshtop: 7.27e+04 Ohm/sq

# Extract p-n junction depth
print(f"DOE: xj {rsh['xjTop']:.3f}")
# Extract sheet resistance of top layer
print(f"DOE: Rshtop {rsh['rshTop']:.2e}")

# Plot conductivity profile
sv.create_plot(xy=True, name="Plot_Profile")
sv.create_curve(dataset="RshProfile", axisX="X", axisY="Conductivity")
