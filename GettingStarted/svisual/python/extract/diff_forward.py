import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

# Compute derivative of y = 2 * x
x = np.array([1.0, 2.0, 3.0, 4.0])
y = 2 * x

xnew, dydx = ext.diff_forward(x, y)

print(f"{x= }")
print(f"{xnew= }")
print(f"{y= }")
print(f"{dydx= }")

#-> x= array([1., 2., 3., 4.])
#-> xnew= array([1.5, 2.5, 3.5])
#-> y= array([2., 4., 6., 8.])
#-> dydx= array([2., 2., 2.])