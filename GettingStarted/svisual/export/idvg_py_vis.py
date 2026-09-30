# Import NumPy package
import numpy as np
# Import extraction module and rename to ext
import svisualpylib.extract as ext

# Set number of digits of precision for printing 
# floating-point numbers in NumPy objects
np.set_printoptions(precision=4)

#- Plotting IdVg
#----------------------------------------------------------------------#
# Load plt file and create dataset PLT
sv.load_file('idvg1_des.plt', name='PLT')

# Create plot Plot_IdVg
plot = sv.create_plot(name='Plot_IdVg', xy=True)
sv.select_plots(plot)

# Set plot and axes property
sv.set_plot_prop(
    title='IdVg', title_font_size=20,
    show_grid=True, show_curve_markers=True
)
sv.set_axis_prop(
    axis='x', title='Gate Voltage [V]',
    title_font_size=16, label_font_size=14, type='linear'
)
sv.set_axis_prop(
    axis='y', title='Drain Current [A]',
    title_font_size=16, label_font_size=14, type= 'log'
)
sv.set_legend_prop(
    label_font_size=12, location='top_left', label_font_att='bold'
)

# Create Id-Vg curve
sv.create_curve(
    name='IdVg', axisX='gate InnerVoltage', 
    axisY='drain TotalCurrent', dataset='PLT'
)
sv.set_curve_prop(
    'IdVg',  color='red', label='nMOS', 
	line_style='solid', line_width=3, 
	markers_size=7, markers_type='circlef'
)

#- Extraction
#----------------------------------------------------------------------#
# Get gate voltage and drain current values
# sv.get_curve_data returns 1D NumPy array
vgs = sv.get_curve_data('IdVg', axisX=True) 
ids = sv.get_curve_data('IdVg', axisY=True)

# Extract threshold voltage and write to SWB table
vt = ext.extract_vtgm(vgs, ids, name='Vtgm') 
                                   
# print(f'DOE: Vtgm {vt:.3f}')
