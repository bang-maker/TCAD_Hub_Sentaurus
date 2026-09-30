
set lTimes_s "0 1.0 3.3 10 33 100 330 1000 3300 10000"
set lDeltaVth ""

if  {[lsearch [list_plots] Plot] == -1} {
	create_plot -1d -name Plot
	set_plot_prop -show_title -title "Delta Vth vs Time" -title_font_family arial -title_font_size 20 \
		-title_font_color #000000 -title_font_att bold -show_legend
##	set_legend_prop -font_size 12 -font_att bold 
} 

set n 6
##set lTimes_s "0  0.1  10 1000"
set lTimes_s "0  0.1 1.0  10 100 1000"
for {set i 0} {$i < $n} {incr i} {

	load_file ./IV_${i}_n@previous@_des.plt
	set Vgs [get_variable_data "gate OuterVoltage" -dataset "IV_${i}_n@previous@_des"]
	set Ids [get_variable_data "drain TotalCurrent" -dataset "IV_${i}_n@previous@_des"]
	ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents
	create_variable -name absId -dataset "IV_${i}_n@previous@_des" -values $absIds
	ext::ExtractVti -out Vth -name "noprint" -v $Vgs -i $absIds -io 1e-7

	
	if {$i==0} {set Vth_0 $Vth}
	set Vth $Vth
	set DeltaVth [expr abs($Vth_0 - $Vth)] 
	lappend lDeltaVth $DeltaVth 
}

create_variable -name Time -dataset "DVth_n@previous@_des" -values $lTimes_s
create_variable -name DVth -dataset "DVth_n@previous@_des" -values $lDeltaVth
create_curve -name "DVth_n@previous@_des" -dataset "DVth_n@previous@_des" -axisX "Time" -axisY "DVth"
set_curve_prop "DVth_n@previous@_des" -label "@Vg_Stress@V @Temp@K"  -markers_size 16 -show_markers -hide_line
set_axis_prop -axis x -title {Time [s]} -title_font_size 16 -label_font_size 14  -min 0.01 -min_fixed -max 2000 -max_fixed -type log 
set_axis_prop -axis y -title {Delta Vth [V]} -title_font_size 16 -label_font_size 14  -min 5E-4 -min_fixed -max 0.2 -max_fixed -type log

		
puts "DOE: DVthS_10s   [format %.5f [lindex $lDeltaVth 3]]"
puts "DOE: DVthS_100s  [format %.5f [lindex $lDeltaVth 4]]"
puts "DOE: DVthS_1000s [format %.5f [lindex $lDeltaVth 5]]"
