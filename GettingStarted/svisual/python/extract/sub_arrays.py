# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

#------------------------------------------------------------------------------
# Create sub arrays using the range of x-values [2.0, 5.0]
xs = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
ys = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0]

xs = np.array(xs)
ys = np.array(ys)

x, y = ext.sub_arrays(xs, ys, xmin=2.0, xmax=5.0)

print(f'new xs: {x}')
print(f'new ys: {y}')

#-> new xs: [2. 3. 4. 5.]
#-> new ys: [20. 30. 40. 50.]