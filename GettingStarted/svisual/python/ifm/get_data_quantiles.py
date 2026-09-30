import svisualpylib.ifm as ifm
import numpy as np

random_values = np.array([-1.657, 0.7661, 2.142, 1.189, -1.919, -0.6670, -0.1915, 0.3662])

# Compute quantiles for a given list of random values
data_quantiles = ifm.get_data_quantiles(random_values)

print(f'{data_quantiles["X"]}')
print(f'{data_quantiles["Y"]}')
#-> [-1.919, -1.657, -0.667, -0.1915, 0.3662, 0.7661, 1.189, 2.142]
#-> [0.0625, 0.1875, 0.3125, 0.4375, 0.5625, 0.6875, 0.8125, 0.9375]
