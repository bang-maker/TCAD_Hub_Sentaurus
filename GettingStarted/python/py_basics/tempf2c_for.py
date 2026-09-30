# Script: tempf2c_for.py
print(f'Fahren Celsius')
for fahren in range(0, 100, 20):
    celsius = (5 / 9) * (fahren - 32)
    print(f'{fahren:6.0f} {celsius:7.1f}') 