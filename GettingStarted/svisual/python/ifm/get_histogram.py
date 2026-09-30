import svisualpylib.ifm as ifm
import numpy as np

rx = np.array([1.0, 1.1, 2.0, 5, 5.1, 5.3, 6.0])

histogram = ifm.get_histogram(rx, xmin=0, xmax=6, nbin=6)

sv.create_variable(dataset='XY', name='X', values=histogram['X'])
sv.create_variable(dataset='XY', name='Y', values=histogram['Y'])

sv.create_plot(name='Histogram', xy=True) 
sv.select_plots('Histogram') 
sv.create_curve(name='hist', dataset='XY', axisX='X', axisY='Y') 

# Annotate plot
sv.set_curve_prop(
    'hist', plot='Histogram', color='red', label='rx', 
    line_style='solid', line_width=3)

sv.set_axis_prop(
    axis='x', title='X', 
    title_font_size=16, scale_font_size=14, type='linear')
sv.set_axis_prop(
    axis='y', title='Y', 
    title_font_size=16, scale_font_size=14, type= 'linear')
sv.set_legend_prop(
    label_font_size=12, location='top_right', label_font_att='bold') 
sv.set_legend_prop(
    label_font_size=12, location='top_right', label_font_att='bold')
