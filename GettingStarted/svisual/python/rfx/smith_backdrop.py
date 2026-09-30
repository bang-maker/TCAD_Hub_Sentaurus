import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

# Create Smith backdrop
rs = np.array([0, 0.3333, 1.0, 3.0])
xs = np.array([0.268, 0.575, 1, 1.73, 3.75])
rfx.smith_backdrop(plot='Plot_Smith', r=rs, x=xs)

# Create Smith plot of S11 and S22 as a function of frequency
# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Create S-parameter dataset as a function of frequency
rf.create_dataset(rfmatrix='S', xaxis='frequency', dataset='S_freq')

# Get bias index corresponding to gate bias of 0.7 V
i_bias = rfx.get_nearest_index(0.7, rf.bias)
bias_point = rf.bias[i_bias]

sv.create_curve(
    name='S11', dataset='S_freq',
    axisX=f'bias_{i_bias} s11_Re', axisY=f'bias_{i_bias} s11_Im'
)
sv.create_curve(
    name='S22', dataset='S_freq',
    axisX=f'bias_{i_bias} s22_Re', axisY=f'bias_{i_bias} s22_Im'
)

sv.set_curve_prop(
    curve='S11', plot='Plot_Smith', label='S11', color='red', line_width=3,
    show_markers=True, markers_type='circlef', markers_size=7
)
sv.set_curve_prop(
    curve='S22', plot='Plot_Smith', label='S22', color='blue', line_width=3,
    show_markers=True, markers_type='circlef', markers_size=7
)

# Annotate plot
title = ('S<sub>11</sub> and S<sub>22</sub> as a function of frequency' 
         f' (V<sub>gs</sub>= {bias_point:.2f} V)')
sv.set_plot_prop(title=title, title_font_size=20, show_legend=True)
sv.set_axis_prop(
    axis='x', title='Re S [1]', 
    title_font_size=16, label_font_size=14, type='linear'
)
sv.set_axis_prop(
    axis='y', title='Im S [1]', 
    title_font_size=16, label_font_size=14, type= 'linear'
)
sv.set_legend_prop(
    label_font_size=12, location='top_left', label_font_att='bold'
)