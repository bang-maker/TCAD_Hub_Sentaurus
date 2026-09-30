"""
Running S-Visual 
a) in batch mode extracts breakdown voltage
b) interactively using "Run Visualizer Nodes Together" plots the 
collector current versus the collector voltage curve 
"""
# Import extraction module 
import svisualpylib.extract as ext

n       = @node@             # node number
fname   = "@pwd@/break.plt"  # plt file
dataset = f'PLT({n})'        # dataset name
ilevel  = 1e-8               # Breakdown voltage extraction current level

sv.load_file(fname, name=dataset)

if 'runVisualizerNodesTogether' in globals():
    # Run S-Visual interactively using "Run Visualizer Nodes Together"
    # Plot collector current versus the collector voltage curve
    # --------- Plotting -------------------------------------------------
    if 'Plot_1D' not in sv.list_plots():
        sv.create_plot(name='Plot_1D', xy=True)
        sv.select_plots('Plot_1D')
        sv.link_plots(sv.list_plots(), unlink=True)
        sv.set_plot_prop(hide_title=True, show_legend=True)
        sv.set_axis_prop(
            axis='x', title='Collector Voltage (V)', 
            title_font_size=16, label_font_size=14, type='linear',
            label_format='fixed', manual_precision=True, label_precision=0
        )
        sv.set_axis_prop(
            axis='y', title='Collector Current (A)', 
            title_font_size=16, label_font_size=14, type= 'log',
            min=1e-15, min_fixed=True, max=ilevel, max_fixed=True
        )
        sv.set_legend_prop(
            label_font_size=16, location='top_right', 
            label_font_att='bold'
        ) 
        
    # Plot IV curve
    icvc = f'IcVc({n})'
    sv.create_curve(
        name=icvc, dataset=dataset, 
        axisX='Collector InnerVoltage', 
        axisY='Collector TotalCurrent'
    )
    sv.set_curve_prop(
        icvc, color=color, label=f'IcVc(n{n}) {legend}', 
        line_style='solid', line_width=3, show_markers=True
    )
else:
    # Run S-Visual in batch mode
    # Extract breakdown voltages
    # --------- Extraction -------------------------------------------------
    # Get voltage and current values
    # sv.get_variable_data returns 1D NumPy array
    vcs = sv.get_variable_data(
        varname='Collector InnerVoltage', dataset=dataset
    )
    ics = sv.get_variable_data(
        varname='Collector TotalCurrent', dataset=dataset
    )
    
    # Extract breakdown voltage
    bv_vmax = ext.extract_bvv(
        vcs, is_npn=True, name='BV_vmax', format='.2f'
    )
    bv_ilevel = ext.extract_bvi(
        vcs, ics, i_o=ilevel, name='BV_Ilevel', format='.2f'
    )
