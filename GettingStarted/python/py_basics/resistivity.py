# Script: resistivity.py
# Import physical constants from scipy.constants module
import scipy.constants as const

# Define function
def resistivity(nd, mobility_n):
    """Compute resistivity of n-type semiconductor.

    :param nd: donor concentration [1/cm^3]  
    :param mobility_n: electron mobility [cm2/(V-s)]  
    :return: resistivity [Ohm-cm] of n-type semiconductor

    """
    sigma = const.e * mobility_n * nd
    rho = 1/sigma
    return rho 