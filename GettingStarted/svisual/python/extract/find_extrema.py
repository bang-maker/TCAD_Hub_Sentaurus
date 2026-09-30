# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

x = np.array([0.0, 1.5, 2.0, 3.0])
y = np.array([0.0, 10.0, 5.0, 20.0])

xmax, ymax = ext.find_extrema(x, y)

print(f'x-values corresponding to the maxima: {xmax}')
print(f'maxima: {ymax}')

#-> x-values corresponding to the maxima: [1.5 3. ]
#-> maxima: [10. 20.]