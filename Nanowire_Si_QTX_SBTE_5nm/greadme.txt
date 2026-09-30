# Setup Scattering
# Specific scattering mechanisms are activate via the Scattering parameter
# The following options are available:
# Ballistic   All scattering is turned off
# RTA_<mobility>  Use RTA scattering with approximate low-field mobility, e.g. RTA_150
# PH+SR           Use phonon and surface roughness scattering

o Device Structure Creation
  The device structure is a 3D circular nanowire created by first using sde to create the 2D cross-section.
  This is then extruded along the channel dirction by snmesh. The contacts and non-uniform doping profile are created
  by sprocess.

o Device Simulation
  The sband tool useds subband-BTE approach to compute linear and saturation IdVg curves with a lumped resistance.
  The supported channel directions are 100 and 110.
