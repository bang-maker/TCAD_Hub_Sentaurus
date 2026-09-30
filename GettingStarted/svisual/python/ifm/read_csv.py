import svisualpylib.ifm as ifm
import numpy as np

data = {
    'A': np.array([1.1, 1.2, 1.3, 1.4]),
    'B': np.array([2.1, 2.2, 2.3, 2.4]),
    'C': np.array([3.1, 3.2, 3.3, 3.4])
}
ifm.write_csv('my.csv', data)

data_csv = ifm.read_csv('my.csv')[0]

for key, value in data_csv.items():
    print(f'Column name: {key}')
    print(f'Column data: {value}')
    
#-> Column name: A
#-> Column data: [1.1, 1.2, 1.3, 1.4]
#-> Column name: B
#-> Column data: [2.1, 2.2, 2.3, 2.4]
#-> Column name: C
#-> Column data: [3.1, 3.2, 3.3, 3.4]
