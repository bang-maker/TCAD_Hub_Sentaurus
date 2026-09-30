import svisualpylib.ifm as ifm
import svisualpylib.extract as ext
import numpy as np

# inputs
pltfile = 'DATA/mos_ac_des.plt'
sv.load_file(pltfile, name='data1')

adgs = sv.get_variable_data(dataset='data1', varname='a(ndrain,ngate)')
adgs=np.array(adgs)
adds = sv.get_variable_data(dataset='data1', varname='a(ndrain,ndrain)')
adds=np.array(adds)
vgs = sv.get_variable_data(dataset='data1', varname='v(ngate)')
ids0 = sv.get_variable_data(dataset='data1', varname='i(mos,ndrain)')
ids = np.abs(ids0)

# function eg1
sIFM = 'DATA/mos_rdf.csv'
sig_rdf = ifm.get_sifm_stddev(sIFM, adgs)

# plotting eg1
sv.create_plot(name='std_dev_rdf', xy=True)
sv.create_variable(name='sigId_rdf', dataset='data1', values=sig_rdf['I'])
sv.create_curve(
    axisX='v(ngate)', axisY='sigId_rdf', dataset='data1', plot='std_dev_rdf')
sv.create_variable(name='sigVg_rdf', dataset='data1', values=sig_rdf['V'])
sv.create_curve(
    axisX='v(ngate)', axisY2='sigVg_rdf', dataset='data1', plot='std_dev_rdf')

# function eg2
sIFM = 'crv'
rsig = 1000
sig_crv = ifm.get_sifm_stddev(sIFM, adgs, rsig, adds, ids)

# plotting eg2
sv.create_plot(name='std_dev_crv', xy=True)
sv.create_variable(name='sigId_crv', dataset='data1', values=sig_crv['I'])
sv.create_curve(
    axisX='v(ngate)', axisY='sigId_crv', dataset='data1', plot='std_dev_crv')
sv.create_variable(name='sigVg_crv', dataset='data1', values=sig_crv['V'])
sv.create_curve(
    axisX='v(ngate)', axisY2='sigVg_crv', dataset='data1', plot='std_dev_crv')
