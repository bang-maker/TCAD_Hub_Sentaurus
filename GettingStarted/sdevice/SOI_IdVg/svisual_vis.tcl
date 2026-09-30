
# Definition of ID for determination of Vti [A/mm2]
set Ivti 1e-7

#set Vti -1
set N @node|sdevice@
set fname "@plot@"

set Vd @Vd@
puts "Drain Bias: $Vd"
set Vdd @Vdd@
puts "Vdd: $Vdd"


# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
# --------- Extraction -------------------------------------------------
	load_library extract
	
	load_file $fname -name PLT($N)
	set Vgs [get_variable_data "gate OuterVoltage"  -dataset PLT($N)]
	set Ids [get_variable_data "drain TotalCurrent" -dataset PLT($N)]
	
	ext::ExtractVti  -out Vti   -name out -f %.3f -v $Vgs -i $Ids -io $Ivti 
#if @Vd@ < 0.6
	ext::ExtractVtgm -out Vth   -name out -f %.3f -v $Vgs -i $Ids 
	ext::ExtractSsub -out S     -name out -f %.3f -v $Vgs -i $Ids 
	ext::ExtractGm   -out gm    -name out -f %.3e -v $Vgs -i $Ids
#else
	ext::ExtractIoff -out IdOff -name out -f %.3e -v $Vgs -i $Ids -vo 1e-4 
	ext::ExtractIoff -out IdSat -name out -f %.3e -v $Vgs -i $Ids -vo [expr 0.9999*$Vdd] 
#if @AvalFac@ == 1
	set DIBL [expr @<Vti:-1>@ - $Vti]
#else
	set DIBL [expr @<Vti:-2>@ - $Vti]
#endif
	puts "DOE: DIBL [format %.3f $DIBL]"
#endif
	
} elseif {[file exists $fname]} { 
# --------- Plotting -------------------------------------------------
	# Create plot if it does not exist and set properties
	if {[llength [list_plots Plot_1D]]==0} {
		create_plot -1d -name Plot_1D
		select_plots Plot_1D
		set_plot_prop -hide_title -show_legend
		set_axis_prop -axis x -title "Gate Voltage (V)" \
			-title_font_size 24 -label_font_size 22 -type linear 
		set_axis_prop -axis y -title "Drain Current (A/<greek>m</greek>m" \
			-title_font_size 24 -label_font_size 22 -type linear
		set_legend_prop -label_font_size 16
	}

	# Plot IV curve
	load_file $fname -name PLT($N)
	create_curve -name IdVg($N) -dataset PLT($N) \
		-axisX "gate InnerVoltage" -axisY "drain TotalCurrent" 
	set_curve_prop IdVg($N) -label "IdVg(n$N) $legend" \
		-color $color -line_style solid -line_width 3
}
