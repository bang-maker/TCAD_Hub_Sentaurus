#; ----------------------------------------
# This script plots the Energy Band Diagram 
#; ----------------------------------------
# Define cutline parameters
direction = 'x'		# Cutline is created perpendicular to this axis
position  = 0.5   	# x-position of the cut

# Load TDR file
tdrfile = 'solar_jsc_des.tdr'  # TDR file used for creating cutline
dataset = 'Structure'
sv.load_file(tdrfile, name=dataset)

#  Create 2D plot
sv.create_plot(name='Plot_Structure', dataset=dataset)

# Create cutline and store resultant 1D data in cut_dataset
cut_dataset = sv.create_cutline(direction, at=position, dataset=dataset)
sv.link_plots(sv.list_plots(), unlink=True)

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
    name='Ec', dataset=cut_dataset,  
	axisX='Y', axisY='ConductionBandEnergy'
)
sv.create_curve(
    name='Efn', dataset=cut_dataset,  
	axisX='Y', axisY='eQuasiFermiEnergy'
)
sv.create_curve(
    name='Efp', dataset=cut_dataset,  
	axisX='Y', axisY='hQuasiFermiEnergy'
)
sv.create_curve(
    name='Ev', dataset=cut_dataset,  
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
	
sv.remove_plots('Plot_Structure')	

# Export variables from cutline dataset into a CSV file
sv.export_variables(
    dataset=cut_dataset, filename='n@node@_eg.csv', overwrite=True,
    varList=[
        'Y', 'ConductionBandEnergy', 'eQuasiFermiEnergy', 
        'hQuasiFermiEnergy', 'ValenceBandEnergy'
    ]
)