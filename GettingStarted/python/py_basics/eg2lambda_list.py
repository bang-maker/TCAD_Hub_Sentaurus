# Script: eg2lambda_list.py  
import scipy.constants as const

# Specify bandgaps of Ge, Si and GaAs in a list
bandgap_ev = [0.661, 1.12, 1.424]

lambda_nm = []  # Create empty list 
for eg in bandgap_ev:
    bandgap_joule = eg * const.eV
    lambda_meter = const.h * const.c / bandgap_joule
    lambda_nm.append(lambda_meter / const.nano) 
    
print(f'cut-off wavelength: {lambda_nm} nm') 