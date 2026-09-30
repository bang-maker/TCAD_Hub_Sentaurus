# Import NumPy package
import numpy as np
# Import Extraction module
import svisualpylib.extract as ext

#------------------------------------------------------------------------------
# Perform linear fit on following data and compute slope, y-intercept and RMSE
xs = [20.0, 60.0, 100.0, 140.0, 180.0, 220.0, 260.0, 300.0, 340.0, 380.0]
ys = [0.18, 0.37, 0.35, 0.78, 0.56, 0.75, 1.18, 1.36, 1.17, 1.65]

xs = np.array(xs)
ys = np.array(ys)

xy = ext.lin_fit(xs, ys, xmin=xs[0], xmax=xs[-1])

print(f"Estimated slope: {xy['slope']:.4e}")
print(f"Estimated y-intercept: {xy['yintercept']:.4f}")
print(f"Root-MSE: {xy['RMSE']:.4f}")

#-> Estimated slope: 3.8288e-03
#-> Estimated y-intercept: 0.0692
#-> Root-MSE: 0.1591