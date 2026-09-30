#setdep @previous@
#; ----------------------------------------
# This script loads the CSV file using Pandas and plots the Energy Band Diagram
#; ----------------------------------------
# Import pandas
import pandas as pd

# Read CSV file and store data in DataFrame object eg_df
eg_df = pd.read_csv('n@node|-1@_eg.csv', skiprows=[1])

# Add bandgap column to eg_df
eg_df = eg_df.assign(
    BandGap = eg_df['ConductionBandEnergy'] - eg_df['ValenceBandEnergy'] 
)

# Save DataFrame columns as NumPy arrays
y = eg_df['Y'].to_numpy()
ec = eg_df['ConductionBandEnergy'].to_numpy()
efn = eg_df['eQuasiFermiEnergy'].to_numpy()
hfn = eg_df['hQuasiFermiEnergy'].to_numpy()
ev = eg_df['ValenceBandEnergy'].to_numpy()

# Create S-Visual variables using NumPy arrays
dataset = 'PLT'
sv.create_variable(name='Y', dataset=dataset, values=y)
sv.create_variable(name='ConductionBandEnergy', dataset=dataset, values=ec)
sv.create_variable(name='eQuasiFermiEnergy', dataset=dataset, values=efn)
sv.create_variable(name='hQuasiFermiEnergy', dataset=dataset, values=hfn)
sv.create_variable(name='ValenceBandEnergy', dataset=dataset, values=ev)

# Plot Band diagram
# Create plot and set plot properties
sv.create_plot(name='Plot_BandDgm', xy=True)
sv.link_plots(sv.list_plots(), unlink=True)
sv.set_plot_prop(
    title='Energy Band Diagram', title_font_size=20, show_regions_bg=True
)
sv.set_axis_prop(axis='x', title='Y [<greek>m</greek>m]', 
    title_font_size=16, label_font_size=14, type='linear')
sv.set_axis_prop(axis='y', title='Energy [eV]', 
    title_font_size=16, label_font_size=14, type= 'linear')
sv.set_legend_prop(
    label_font_size=12, location='top_right', label_font_att='bold'
)

sv.select_plots('Plot_BandDgm')

# Create curves
sv.create_curve(
    name='Ec', dataset=dataset,  
	axisX='Y', axisY='ConductionBandEnergy'
)
sv.create_curve(
    name='Efn', dataset=dataset,  
	axisX='Y', axisY='eQuasiFermiEnergy'
)
sv.create_curve(
    name='Efp', dataset=dataset,  
	axisX='Y', axisY='hQuasiFermiEnergy'
)
sv.create_curve(
    name='Ev', dataset=dataset,  
	axisX='Y', axisY='ValenceBandEnergy'
)

# Set curve properties
sv.set_curve_prop(
    'Ec', label='Conduction Band Energy ', 
    color='black', line_style='solid', line_width=3, 
    show_markers=True, markers_size=10, markers_type='circle'
) 

sv.set_curve_prop(
    'Efn', label='Electron Quasi Fermi Energy ', 
    color='red', line_style='solid', line_width=3, 
    show_markers=True, markers_size=10, markers_type='circle'
)

sv.set_curve_prop(
    'Efp', label='Hole Quasi Fermi Energy ', 
    color='blue', line_style='solid', line_width=3, 
    show_markers=True, markers_size=10, markers_type='circle'
)

sv.set_curve_prop(
    'Ev', label='Valence Band Energy ', 
    color='gray', line_style='solid', line_width=3, 
    show_markers=True, markers_size=10, markers_type='circle'
)