
#----------------------------------------------------------------------#
#setdep @node|sdevice@
set N @node|sdevice@

load_file "@plot@" -name PLT($N)
            
# Compute gain above Vbe= 0.4 V for npn transistor 
set Vbes [get_variable_data "base OuterVoltage" -dataset PLT($N)] 
set Ics [get_variable_data "collector TotalCurrent" -dataset PLT($N)]
set Ibs [get_variable_data "base TotalCurrent" -dataset PLT($N)]
ext::SubLists -out clipVbeIc -x $Vbes -y $Ics -xmin  0.4 -xmax [lindex $Vbes end]
ext::SubLists -out clipVbeIb -x $Vbes -y $Ibs -xmin  0.4 -xmax [lindex $Vbes end]
set clipVbes $clipVbeIc(X)
set clipGains [list]
foreach ClipIc $clipVbeIc(Y) ClipIb $clipVbeIb(Y) {
	set gain [expr $ClipIc/$ClipIb]
	lappend clipGains $gain
}


# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
# --------- Extraction -------------------------------------------------
	load_library extract

	ext::ExtractExtremum -out MaxGain    -name out -x $clipVbes -y $clipGains -type max -f %.2f
	ext::ExtractValue    -out VbeMaxGain -name out -x $clipGains -y $clipVbes -xo $MaxGain -f %.2f
	ext::ExtractValue    -out IcMaxGain  -name out -x $Vbes -y $Ics -xo $VbeMaxGain -f %.2e
	
} else { 
# --------- Plotting -------------------------------------------------
	# Create plot if it does not exist and set properties
	if {[llength [list_plots Plot_1D]]==0} {
		create_plot -1d -name Plot_1D
		select_plots Plot_1D
		set_plot_prop -hide_title -show_legend \
			-title "Gummel Plot Characteristics" -title_font_size 16
		set_axis_prop -axis x -title {Base Voltage [V]} \
			-title_font_size 16 -label_font_size 14 -type linear 
		set_axis_prop -axis y -title {Ib, Ic [A]} \
			-title_font_size 16 -label_font_size 14 -type log
		set_axis_prop -axis y2 -title {Gain [1]} \
			-title_font_size 16 -label_font_size 14 -type linear	
		set_legend_prop -label_font_size 16
	}

	# Plot IV curve
	create_curve -name Ib($N) -dataset PLT($N) \
		-axisX "base OuterVoltage" -axisY "base TotalCurrent"
	set_curve_prop Ib($N) -label "Base Current (Ib)" \
		-color $color -line_style dot -line_width 3
	create_curve -name Ic($N) -dataset PLT($N) \
		-axisX "base OuterVoltage" -axisY "collector TotalCurrent"
	set_curve_prop Ic($N) -label "Collector Current (Ic)" \
		-color $color -line_style dash -line_width 3

	create_variable -name clipVbe -dataset Gummel($N) -values $clipVbes	
	create_variable -name clipGain -dataset Gummel($N) -values $clipGains
	create_curve -name Gain($N) -dataset Gummel($N) -axisX "clipVbe" -axisY2 "clipGain"
	set_curve_prop Gain($N) -label "Gain(n$N)" \
		-color $color -line_style solid -line_width 3	
}
