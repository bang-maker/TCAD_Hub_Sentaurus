import svisualpylib.ifm as ifm
import svisualpylib.extract as ext
import numpy as np

# inputs
var_sources = np.array(['rdf', 'crv', 'SUM'])
files = np.array([])
for var_source in var_sources:
	files=np.append(files,f'DATA/mos_{var_source}.csv')

pltfile = f'DATA/mos_ac_des.plt'
sv.load_file(pltfile, name='data1')

adgs = sv.get_variable_data(dataset='data1', varname='a(ndrain,ngate)')
adds = sv.get_variable_data(dataset='data1', varname='a(ndrain,ndrain)')
adds=np.array(adds)
vgs = sv.get_variable_data(dataset='data1', varname='v(ngate)')
ids0 = sv.get_variable_data(dataset='data1', varname='i(mos,ndrain)')
ids = np.abs(ids0)

# function
sifm, nrow, ncol = ifm.read_sifm(
    files, var_sources, rsig=1000, nrand=50, rseed=1337, ydd=adds, i=ids)
