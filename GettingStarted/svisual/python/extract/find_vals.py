# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

x = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
y = np.array([0.0, 2.0, 4.0, 2.0, 0.0])

# Find all the elements of x corresponding to y = 2.0
xo = ext.find_vals(y, x, x_o=2.0)
print(f'Elements of x corresponding to y = 2.0: {xo}')

# Find the first element of x corresponding to y = 2.0
xo = ext.extract_value(y, x, x_o=2.0, name=None)
print(f'First element of x corresponding to y = 2.0: {xo}')

#-> Elements of x corresponding to y = 2.0: [1. 3.]
#-> First element of x corresponding to y = 2.0: 1.0