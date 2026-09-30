import svisualpylib.ifm as ifm
import numpy as np

# inputs
pltfile = 'DATA/mos_ac_des.plt'
sv.load_file(pltfile, name='data1')
adgs = sv.get_variable_data(dataset='data1', varname='a(ndrain,ngate)')
adgs=np.array(adgs)

# function
Ws = ifm.get_mos_weights(adgs)
Ws = Ws.tolist()

# plotting
sv.create_variable(name='W', dataset='data1', values=Ws)
sv.create_plot(name='Weights', xy=True)
sv.create_curve(axisX='v(ngate)', axisY='W', dataset='data1', plot='Weights')
sv.create_curve(
    axisX='v(ngate)', axisY2='a(ndrain,ngate)', 
    dataset='data1', plot='Weights')
