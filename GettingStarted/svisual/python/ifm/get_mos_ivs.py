import svisualpylib.ifm as ifm
import svisualpylib.extract as ext
import numpy as np

# inputs
var_sources = np.array(['rdf', 'crv', 'SUM'])
files = np.array([])
for var_source in var_sources:
    files=np.append(files,f'DATA/mos_{var_source}.csv')

pltfile = 'DATA/mos_ac_des.plt'
sv.load_file(pltfile, name='data1')

adgs = sv.get_variable_data(dataset='data1', varname='a(ndrain,ngate)')
adds = sv.get_variable_data(dataset='data1', varname='a(ndrain,ndrain)')
vgs = sv.get_variable_data(dataset='data1', varname='v(ngate)')
ids0 = sv.get_variable_data(dataset='data1', varname='i(mos,ndrain)')
ids = np.abs(ids0)

sifm, nrow, ncol = ifm.read_sifm(
    files, var_sources, rsig=1000, nrand=50, 
    rseed=1337, ydd=adds, i=ids)

# function 
for var_source in var_sources:
    iv = ifm.get_mos_ivs(
        vgs, ids, adgs, sifm, nrow, ncol, var_source, 
        vmin=0.1, vmax=1.25, sign=1, method='weighted')
    sv.create_plot(name=f'RanIV_{var_source}', xy=True)
    for j in [1, 10, 20, 42]:
        sv.create_variable(
            name=f'V_{var_source}_{j}', dataset=f'd_{var_source}', 
            values=iv['X'][j])
        sv.create_variable(
            name=f'I_{var_source}_{j}', dataset=f'd_{var_source}', 
            values=iv['Y'][j])
        sv.create_curve(
            axisX=f'V_{var_source}_{j}', axisY=f'I_{var_source}_{j}', 
            dataset=f'd_{var_source}', plot=f'RanIV_{var_source}')
