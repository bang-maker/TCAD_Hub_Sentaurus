import svisualpylib.ifm as ifm
import numpy as np

rv = np.array([1.0, 2.0, 3.0, 4.0, 5.0])

moments = ifm.get_moments(rv)

for key, value in moments.items():
    print(f'{key}: {value}')    

#-> norm: 5
#-> ave: 3.0
#-> rms: 3.3166247903554
#-> std_dev: 1.4142135623730951
#-> skew: 0.0
#-> kurtx: -1.2999999999999972
