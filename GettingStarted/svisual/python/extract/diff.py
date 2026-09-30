import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

np.set_printoptions(precision=4)

#------------------------------------------------------------------------------
# Compute derivative of y = 2 * x using linear (default) interpolation
x = np.array([1.0, 2.0, 3.0, 4.0])
y = 2 * x

dydx = ext.diff(x, y)

print(f"{x= }")
print(f"{y= }")
print(f"{dydx= }")

#-> x= array([1., 2., 3., 4.])
#-> y= array([2., 4., 6., 8.])
#-> dydx= array([2., 2., 2., 2.])

#------------------------------------------------------------------------------
# Compute derivative of y = exp(x) + 1 using logarithmic interpolation
x = np.array([1.0, 1.5, 2.5, 6.0, 7.0, 7.5, 8.5, 8.7, 8.8, 10.0])
y = np.exp(x) + 1

# For exponential function, use logarithmic interpolation for y-axis values
dydx = ext.diff(x, y, y_log=True)

print(f"{x= }")
print(f"{y= }")
print(f"{dydx= }")

#-> x= array([ 1. ,  1.5,  2.5,  ..., 10. ])
#-> y= array([3.7183e+00, 5.4817e+00, 1.3182e+01, ..., 2.2027e+04])
#-> dydx= array([2.8871e+00, 4.5329e+00, 1.2232e+01, ..., 2.2012e+04])

