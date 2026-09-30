import svisualpylib.ifm as ifm

x = 0.1
moments = {'norm': 1.0, 'ave': 0.0, 'std_dev': 1.0}

# Compute the y-value of a normalized Gaussian distribution for given x-value
y = ifm.gauss(x, moments)
print(f'The result is {y}')