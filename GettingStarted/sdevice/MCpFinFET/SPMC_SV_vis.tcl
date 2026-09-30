
#setdep @node|SPMC@

set N @node|SPMC@
set fname @[relpath n@node|SPMC@_mc.sparta_average.plt]@

if {![file exists $fname]} {
	puts stderr ".plt file $fname does not exist."
	exit 11
}
load_file $fname -name PLT($N)
create_variable -name "abs_ivs" -function "abs(<particle MCdrain:PLT($N)>)" -dataset PLT($N)  
create_variable -name "abs_dvs" -function "2*<abs_ivs:PLT($N)>*<particle MCdrain-Error:PLT($N)>" -dataset PLT($N)  

# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
# --------- Extraction -------------------------------------------------
	set ivs [get_variable_data "abs_ivs" -dataset PLT($N)]
	set dvs [get_variable_data "abs_dvs" -dataset PLT($N)]
	set idrainmc [expr [lindex $ivs end]*1e6]
	set ddrainmc [expr [lindex $dvs end]*1e4] 

	puts "DOE: IonMC [format %.4g $idrainmc]"
	puts  "S: Drain current IonMC             = $idrainmc uA/um"

	puts "DOE: FourSigmaIonMC [format %.4g $ddrainmc]"
	puts  "S: Drain current FourSigmaIonMC    = $ddrainmc uA/um"

} else { 
# --------- Plotting -------------------------------------------------
	# Create plot if it does not exist and set properties
	if {[llength [list_plots Plot_1D]]==0} {
		create_plot -1d -name Plot_1D
		select_plots Plot_1D
		set_plot_prop -hide_title -show_legend
		set_axis_prop -title_font_size 24 -label_font_size 22 -type linear
		set_axis_prop -axis x -title "Number" 
		set_axis_prop -axis y -title "Drain Current (A/<greek>m</greek>m" 
		set_legend_prop -label_font_size 16
	}

	# Plot IV curve
	create_curve -name IdVg($N) -dataset PLT($N) \
		-axisX "number" -axisY "abs_ivs" 
	set_curve_prop IdVg($N) -label "IdVg(n$N) $legend" \
		-color $color -line_style solid -line_width 3
}
