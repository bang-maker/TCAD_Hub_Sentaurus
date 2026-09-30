#setdep @node|sdevice@

n = @node@
# Determine sdevice node status
status = '@[gproject::GetNodeStatus @node|sdevice@]@'

# Create plot if it does not exist and set properties
if 'Plot_1D' not in sv.list_plots():
    sv.create_plot(name='Plot_1D', xy=True)
    sv.link_plots(sv.list_plots(), unlink=True)
    sv.select_plots('Plot_1D')
    sv.set_plot_prop(hide_title=True, show_legend=True)
    sv.set_axis_prop(title_font_size=16, label_font_size=14) 
    sv.set_axis_prop(
        axis='x', title='Gate Voltage (V)', 
        type='linear'
    )
    sv.set_axis_prop(
        axis='y', title='Drain Current (A/<greek>m</greek>m)', 
        type='log'
    )
    sv.set_legend_prop(
        label_font_size=14, location='bottom_right'
    ) 
    
# Load and create IV curve 
sv.load_file('@[relpath IdVg_n@node|sdevice@_des.plt]@', name=f'PLT({n})')
idvg = f'IdVg({n})'
sv.create_curve(
    name=f'IdVg({n})', dataset=f'PLT({n})', 
    axisX='gate OuterVoltage', 
    axisY='drain TotalCurrent'
)

# Extract curve parameters only when sdevice node has status done
if status == 'done':
    # Import NumPy package
    import numpy as np
    # Import extraction module
    import svisualpylib.extract as ext
    
    np.set_printoptions(precision=4)
    
    vgs = sv.get_variable_data(
        varname='gate OuterVoltage', dataset=f'PLT({n})')
    ids = sv.get_variable_data(
        varname='drain TotalCurrent', dataset=f'PLT({n})')  
    
    vtgm = ext.extract_vtgm(vgs, ids, name='Vtgm')
    idmax = ext.extract_extremum(ids, 'max', name='Id')
    ss = ext.extract_ss(vgs, ids, vtgm/3, name='SS')
    gm = ext.extract_gm(vgs, ids, name='gm')
    
# Set curve properties only if script is run using "Run Visualizer Nodes Together"  
if 'runVisualizerNodesTogether' in globals():
    # The variables color, legend and line are provided by SWB,
    # and are different for each curve 
    sv.set_curve_prop(
        f'IdVg({n})', plot='Plot_1D', color=color, 
        label=f'IdVg {legend}', line_style=line, 
        line_width=3
    )
else:
    print('To see the curves, select Sentaurus Visual nodes and click\n'
          'the Run Selected Visualizer Nodes Together toolbar button')