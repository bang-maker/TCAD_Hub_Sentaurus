import svisualpylib.ifm as ifm

moments = {'norm': 1, 'ave': 0, 'std_dev': 1}

gaussian = ifm.get_gaussian(
    moments=moments, n_sam=100, g_type='f', xmin=- 3.5, xmax=3.5)

sv.create_variable(dataset='GXY', name='GX', values=gaussian['X'])
sv.create_variable(dataset='GXY', name='GY', values=gaussian['Y'])

sv.create_plot(name='Gaussian', xy=True) 
sv.select_plots('Gaussian') 
sv.create_curve(name='gauss', dataset='GXY', axisX='GX', axisY='GY') 

# Annotate plot
sv.set_curve_prop(
    'gauss', plot='Gaussian', color='red', label='Gaussian', 
    line_style='solid', line_width=3, show_markers=True, markers_size=7)
sv.set_plot_prop(title='Gaussian Curve', title_font_size=20, show_grid=True)
sv.set_axis_prop(
    axis='x', title='X', 
    title_font_size=16, scale_font_size=14, type='linear')
sv.set_axis_prop(
    axis='y', title='Y', 
    title_font_size=16, scale_font_size=14, type= 'linear')
sv.set_legend_prop(
    label_font_size=12, location='top_right', label_font_att='bold') 