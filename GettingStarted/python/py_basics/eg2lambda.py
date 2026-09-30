# Script: eg2lambda.py  
import scipy.constants as const

bandgap_ev = 1.424  # GaAs bandgap in eV
# Convert bandgap unit from eV to J
bandgap_joule = bandgap_ev * const.eV
lambda_meter = const.h * const.c / bandgap_joule  # wavelength in m
lambda_nm = lambda_meter / const.nano             # wavelength in nm
print(f'cut-off wavelength: {lambda_nm:.2f} nm')