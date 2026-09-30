# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

#------------------------------------------------------------------------------
# Remove 0 from x-values
xs = [0.0, 1.0, 2.0, 3.0, 0.0, -1.0]
ys = [10.0, 20.0, 30.0, 40.0, 50.0, 0.0]

xs = np.array(xs)
ys = np.array(ys)

# Remove zeros only from xs
x, y = ext.remove_zeros(xs, ys, iplists='x')

print(f'new xs: {x}')
print(f'new ys: {y}')

#-> new xs: [ 1.  2.  3. -1.]
#-> new ys: [20. 30. 40.  0.]