# Import RFX module 
import svisualpylib.rfx as rfx

# Create RFX object rf; Create AC- and Y-matrix
rf = rfx.RFX(    
    filename='DATA/nMOS_ac_des.plt', dataset='ACPLT_nMOS', 
    port1=1, port2=2, bias_port='v(1)', device_width=0.9
)

# Create Y-parameter dataset as a function of bias
rf.create_dataset(rfmatrix='Y', xaxis='bias', dataset='Y_bias')

# Create AC-parameter dataset as a function of frequency
rf.create_dataset(rfmatrix='AC', xaxis='frequency', dataset='AC_freq')

# Plot Cgg Vs frequency at last bias point
sv.create_plot(name='Plot_Cf', xy=True) 

index = rf.i_biasend  # last bias-point index

sv.create_curve(
    name='Cgghb', dataset='AC_freq',
    axisX=f'bias_{index} frequency', axisY=f'bias_{index} c(1,1)'
)

sv.set_curve_prop(
    curve='Cgghb', plot='Plot_Cf', color='red', 
    label='C<sub>gg</sub> (high bias)', line_style='solid', line_width=3,
    show_markers=True, markers_type='circlef', markers_size=7
)

# Annotate plot
sv.set_plot_prop(
    title='C<sub>gg</sub> Vs frequency curve', 
    title_font_size=20, show_grid=True
)
sv.set_axis_prop(
    axis='x', title='Frequency [Hz]', label_format='scientific',
    title_font_size=16, label_font_size=14, type='log'
)
sv.set_axis_prop(
    axis='y', title='Capacitance [F]', 
    label_format='scientific', label_precision=0,
    title_font_size=16, label_font_size=14, type= 'linear'
)
sv.set_legend_prop(
    label_font_size=12, location='bottom_left', label_font_att='bold'
)
