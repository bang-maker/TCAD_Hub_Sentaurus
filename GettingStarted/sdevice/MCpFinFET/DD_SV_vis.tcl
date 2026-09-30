
#setdep @node|DD@

set N @node|DD@
set fname @[relpath IdVg_@plot@]@

if {![file exists $fname]} {
	puts stderr ".plt file $fname does not exist."
	exit 11
}
load_file $fname -name PLT($N)
create_variable -name "Vg_abs" -function "abs(<Gate OuterVoltage:PLT($N)>)" -dataset PLT($N)  
create_variable -name "Id_abs" -function "abs(<Drain TotalCurrent:PLT($N)>)" -dataset PLT($N)  

# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
# --------- Extraction -------------------------------------------------
	load_library extract
	
	set Vgs [get_variable_data "Vg_abs" -dataset PLT($N)]
	set Ids [get_variable_data "Id_abs" -dataset PLT($N)]
	
	create_variable -name "Id_sqrt" -function "sqrt(<Id_abs:PLT($N)>)" -dataset PLT($N)
	set Id_sqrt [get_variable_data "Id_sqrt" -dataset PLT($N)]
	
	ext::ExtractVtgm -out VTS  -name out -f %.3f -v $Vgs -i $Id_sqrt 
	ext::ExtractSsub -out S    -name out -f %.3f -v $Vgs -i $Ids 
	ext::ExtractGm   -out gm   -name out -f %.3e -v $Vgs -i $Ids
	ext::ExtractIoff -out Ioff -name out -f %.3e -v $Vgs -i $Ids -vo 1e-5 
	ext::ExtractIoff -out Ion  -name out -f %.3e -v $Vgs -i $Ids -vo [expr -0.9999*@V_SUPPLY@] 
} else { 
# --------- Plotting -------------------------------------------------
	# Create plot if it does not exist and set properties
	if {[llength [list_plots Plot_1D]]==0} {
		create_plot -1d -name Plot_1D
		select_plots Plot_1D
		set_plot_prop -hide_title -show_legend
		set_axis_prop -title_font_size 24 -label_font_size 22 -type linear
		set_axis_prop -axis x -title "Gate Voltage (V)" 
		set_axis_prop -axis y -title "Drain Current (A/<greek>m</greek>m" 
		set_legend_prop -label_font_size 16
	}

	# Plot IV curve
	create_curve -name IdVg($N) -dataset PLT($N) \
		-axisX "Vg_abs" -axisY "Id_abs" 
	set_curve_prop IdVg($N) -label "IdVg(n$N) $legend" \
		-color $color -line_style solid -line_width 3
}
