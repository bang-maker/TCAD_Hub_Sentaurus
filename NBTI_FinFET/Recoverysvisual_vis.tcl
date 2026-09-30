
set lTimes_s "0 1.0 3.3 10 33 100 330 1000 3300 10000"
set lDeltaVth ""

if  {[lsearch [list_plots] Plot] == -1} {
	create_plot -1d -name Plot
	set_plot_prop -show_title -title "Delta Vth vs Time" -title_font_family arial -title_font_size 20 \
		-title_font_color #000000 -title_font_att bold -show_legend
##	set_legend_prop -font_size 12 -font_att bold 
} 

set n 10
set lTimes_s "0 1e-5 1e-4 1e-3 1e-2 1e-1 1e0 1e1 1e2 1e3"
for {set i 0} {$i < $n} {incr i} {

	if {$i == 0} {
	load_file ./IV_${i}_n@node|StressLoadIV@_des.plt
	set DS IV_${i}_n@node|StressLoadIV@_des
	} else {
	load_file ./IV_${i}_n@previous@_des.plt
		set DS IV_${i}_n@previous@_des
	}
	
	
	set Vgs [get_variable_data "gate OuterVoltage" -dataset "$DS"]
	set Ids [get_variable_data "drain TotalCurrent" -dataset "$DS"]
	ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents
	create_variable -name absId -dataset "$DS" -values $absIds
	ext::ExtractVti -out Vth -name "noprint" -v $Vgs -i $absIds -io 1.0e-7

	
	if {$i==0} {set Vth_0 $Vth}
	set Vth $Vth
	set DeltaVth [expr abs($Vth_0 - $Vth)] 
	lappend lDeltaVth $DeltaVth 
}

create_variable -name Time -dataset "DVth_$DS" -values $lTimes_s
create_variable -name DVth -dataset "DVth_$DS" -values $lDeltaVth
create_curve -name "DVth_$DS" -dataset "DVth_$DS" -axisX "Time" -axisY "DVth"
set_curve_prop "DVth_$DS" -label "@Vg_Stress@V @Temp@K"  -markers_size 16 -show_markers -hide_line
set_axis_prop -axis x -title {Time [s]} -title_font_size 16 -label_font_size 14  -min 5e-6 -min_fixed -max 2000 -max_fixed -type log 
set_axis_prop -axis y -title {Delta Vth [V]} -title_font_size 16 -label_font_size 14  -min 0 -min_fixed -max 0.15 -max_fixed 
	
puts "DOE: DVthR_1ms   [format %.5f [lindex $lDeltaVth 3]]"
puts "DOE: DVthR_1s    [format %.5f [lindex $lDeltaVth 6]]"
puts "DOE: DVthR_1000s [format %.5f [lindex $lDeltaVth 9]]"
