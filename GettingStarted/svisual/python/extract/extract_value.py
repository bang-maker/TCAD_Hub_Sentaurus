import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

#------------------------------------------------------------------------------
xs = [1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12]
ys = [-100.0, -25.0, 25.0, 50.0, 100.0, 100.0, 75.0, 50.0, 25.0, -25.0, -100.0]

xs = np.array(xs)
ys = np.array(ys)

# Extract the first interpolated x-value for the given target y-value
# using the default linear interpolation 
xlin = ext.extract_value(ys, xs, x_o=0.0, y_log=False, name='Xlin')

# Extract the first interpolated x-value for the given target y-value
# using logrithmic interpolation 
xlog = ext.extract_value(ys, xs, x_o=0.0, y_log=True, name='Xlog')

# Extract the 2d interpolated x-value for the given target y-value
# using logrithmic interpolation 
x2log = ext.extract_value(
    ys, xs, x_o=0.0, y_log=True, occurrence=2, name='X2nd_log')