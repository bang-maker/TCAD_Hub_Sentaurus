import svisualpylib.ifm as ifm

random_values = [-1.657, 0.7661, 2.142, 1.189, -1.919, -0.6670, -0.1915, 0.3662]
data_q = ifm.get_data_quantiles(random_values)
moments = ifm.get_moments(random_values)
gaussian_q = ifm.get_gaussian(
    moments=moments, n_sam=40, g_type='q', xmin=- 3.5, xmax=3.5)

qq = ifm.get_qq(data_q, gaussian_q, moments)

sv.create_variable(dataset='QQXY', name='QQX', values=qq[0])
sv.create_variable(dataset='QQXY', name='QQY', values=qq[1])

sv.create_plot(name='Plot_QQ', xy=True) 
sv.select_plots('Plot_QQ') 
sv.create_curve(name='qq', dataset='QQXY', axisX='QQX', axisY='QQY') 

# Annotate plot
sv.set_curve_prop(
    'qq', plot='Plot_QQ', color='red', label='Quantile', 
    line_style='solid', line_width=3, show_markers=True, markers_size=7)
sv.set_plot_prop(title='QQ Plot', title_font_size=20, show_grid=True)
sv.set_axis_prop(
    axis='x', title='X', 
    title_font_size=16, scale_font_size=14, type='linear')
sv.set_axis_prop(
    axis='y', title='Y', 
    title_font_size=16, scale_font_size=14, type= 'linear')
sv.set_legend_prop(
    label_font_size=12, location='top_left', label_font_att='bold') 