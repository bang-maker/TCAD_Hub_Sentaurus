set N @node|switching@
set fname "[file dirname @plot@]/n${N}_sys_des.plt"

if {![info exists runVisualizerNodesTogether]} {
# --------- Extraction -------------------------------------------------
	load_library extract
	
} elseif {[file exists $fname]} { 
# --------- Plotting -------------------------------------------------
	# Create plot if it does not exist and set properties
	if {[llength [list_plots Plot_1D]]==0} {
		create_plot -1d -name Plot_1D
		select_plots Plot_1D
		set_plot_prop -hide_title -show_legend
		set_axis_prop -axis x -title "Time (s)" \
			-title_font_size 24 -label_font_size 22 -type linear 
		set_axis_prop -axis y -title "V(out) (V)" \
			-title_font_size 24 -label_font_size 22 -type linear
		set_axis_prop -axis y2 -title "Current (A)" \
			-title_font_size 24 -label_font_size 22 -type linear
		set_legend_prop -label_font_size 16
	}

	# Plot IV curve
	load_file $fname -name PLT($N)
	create_curve -name Vout($N) -dataset PLT($N) \
		-axisX "time" -axisY "v(out)" 
	set_curve_prop Vout($N) -label "Vout(n$N) $legend" \
		-color $color -line_style solid -line_width 3
	create_curve -name Vin($N) -dataset PLT($N) \
		-axisX "time" -axisY "v(in)" 
	set_curve_prop Vin($N) -label "Vin(n$N) $legend" \
		-color $color -line_style dash -line_width 3
	create_curve -name In($N) -dataset PLT($N) \
		-axisX "time" -axisY2 "i(nmos1,out)" 
	set_curve_prop In($N) -label "Inmos(n$N) $legend" \
		-color $color -line_style dot -line_width 3
}
