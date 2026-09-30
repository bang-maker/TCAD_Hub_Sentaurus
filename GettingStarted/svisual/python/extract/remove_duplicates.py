# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

#------------------------------------------------------------------------------
# Remove duplicates from x-values
xs = [1.0, 1.0, 2.0, 3.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0]
ys = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]

xs = np.array(xs)
ys = np.array(ys)

x, y = ext.remove_duplicates(xs, ys)

print(f'new xs: {x}')
print(f'new ys: {y}')

#-> new xs: [1. 2. 3. 1. 2. 3.]
#-> new ys: [ 20.  30.  40.  60.  90. 100.]