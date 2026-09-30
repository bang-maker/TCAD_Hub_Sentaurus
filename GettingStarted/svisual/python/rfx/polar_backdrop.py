import numpy as np
# Import RFX module 
import svisualpylib.rfx as rfx

# Create polar backdrop
rs = np.array([0.25, 0.5, 0.75, 1.0, 1.25])
phis = np.array([0, 30, 60, 90, 120, 150])
rfx.polar_backdrop(plot='Plot_Polar', r=rs, phi=phis)

# Create polar plot of S12 and S21 as a function of frequency
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
    name='S12', dataset='S_freq',
    axisX=f'bias_{i_bias} s12_Re', axisY=f'bias_{i_bias} s12_Im'
)
sv.create_curve(
    name='S21', dataset='S_freq',
    axisX=f'bias_{i_bias} s21_Re', axisY=f'bias_{i_bias} s21_Im'
)

sv.set_curve_prop(
    curve='S12', plot='Plot_Polar', label='S12', color='red', line_width=3,
    show_markers=True, markers_type='circlef', markers_size=7
)
sv.set_curve_prop(
    curve='S21', plot='Plot_Polar', label='S21', color='blue', line_width=3,
    show_markers=True, markers_type='circlef', markers_size=7
)

# Annotate plot
title = ('S<sub>12</sub> and S<sub>21</sub> as a function of frequency' 
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