
set lTimes_s "0 0.01 0.1 1.0 10 100 1000"
set lDeltaVth ""

if  {[lsearch [list_plots] Plot] == -1} {
create_plot -1d -name Plot
set_plot_prop -show_title -title "Delta Vth vs Time" -title_font_family arial -title_font_size 20 \
		-title_font_color #000000 -title_font_att bold -show_legend
##set_legend_prop -font_size 12 -font_att bold 
} 

set n 7
set lTimes_s "0 0.01 0.1 1.0 10 100 1000"

for {set i 0} {$i < $n} {incr i} {

	load_file ./IV_${i}_n@previous@_0_des.plt
	set Vgs [get_variable_data "gate OuterVoltage" -dataset "IV_${i}_n@previous@_0_des"]
	set Ids [get_variable_data "drain TotalCurrent" -dataset "IV_${i}_n@previous@_0_des"]
	ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents
	create_variable -name absId -dataset "IV_${i}_n@previous@_0_des" -values $absIds
	ext::ExtractVti -out Vth -name "noprint" -v $Vgs -i $absIds -io 1e-7
	
	if {$i==0} {set Vth_0 $Vth}
	set Vth $Vth
	set DeltaVth [expr abs($Vth_0 - $Vth)] 
	lappend lDeltaVth $DeltaVth 
}



create_variable -name Time -dataset "DVth_n@previous@_0_des" -values $lTimes_s
create_variable -name DVth -dataset "DVth_n@previous@_0_des" -values $lDeltaVth


create_curve -name "DVth_n@previous@_0_des" -dataset "DVth_n@previous@_0_des" -axisX "Time" -axisY "DVth"
set_curve_prop "DVth_n@previous@_0_des" -label "TCAD_@Type@ HCD_@Vg_Stress@V"  -markers_size 16 -show_markers -hide_line

set_axis_prop -axis x -title {Time [s]} -title_font_size 16 -label_font_size 14  -min 0.001 -min_fixed -max 2000 -max_fixed -type log 
set_axis_prop -axis y -title {Delta Vth [V]} -title_font_size 16 -label_font_size 14  -min 1E-5 -min_fixed -max 1.0 -max_fixed -type log
		
		
puts "DOE: DVth_10s   [format %.5f [lindex $lDeltaVth 4]]"
puts "DOE: DVth_100s  [format %.5f [lindex $lDeltaVth 5]]"
puts "DOE: DVth_1000s [format %.5f [lindex $lDeltaVth 6]]"
