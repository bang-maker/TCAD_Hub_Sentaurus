# Script: eg2lambda_array.py 
import numpy as np
import scipy.constants as const

# Set the precision for printing floating-point numbers in NumPy objects
np.set_printoptions(precision=2)

# Specify bandgaps of Ge, Si and GaAs in 1D array
bandgap_ev = np.array([0.661, 1.12, 1.424])

# Use element-wise scalar mulitplication to convert all bandgaps from eV to SI unit
bandgap_joule = bandgap_ev * const.eV
# Compute wavelength in [m] using element-wise inverse of array
lambda_meter = const.h * const.c / bandgap_joule 
lambda_nm = lambda_meter / const.nano

print(f'cut-off wavelengths: {lambda_nm} nm')