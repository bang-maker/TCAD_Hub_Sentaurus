#setdep @node|RH@

set N     @node@
set i     @node:index@

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS1  [list brown green magenta violet blue red]
set NCOLORS1 [llength $COLORS1]
set color1   [lindex  $COLORS1 [expr $i%$NCOLORS1]]

set COLORS2  [list blue red black violet brown green]
set NCOLORS2 [llength $COLORS2]
set color2   [lindex  $COLORS2 [expr $i%$NCOLORS2]]

load_file rh_n@node|RH@_sys_des.plt -name PLT($N)

if {[lsearch [list_plots] Plot_PG] == -1} {
	create_plot -1d -name Plot_PG
	set_plot_prop -title "Pass gate waveform and bitline potential transient curve" -title_font_size 20	
	set_axis_prop -axis x -title {Time [s]} \
		-title_font_size 16 -label_font_size 14 -type linear 
	set_axis_prop -axis y -title {PG Voltage [V]} \
		-title_font_size 16 -label_font_size 14 -type linear
	set_axis_prop -axis y2 -title {BL-SN Potential [V]} \
		-title_font_size 16 -label_font_size 14 -type linear		
	set_legend_prop -label_font_size 12 -location top_right -label_font_att bold	
}
select_plots Plot_PG

echo "#########################################"
echo "Plotting Pass gate waveform"
echo "#########################################"
create_curve -name PG($N) -dataset PLT($N) \
	-axisX time -axisY v(pg)
	
set_curve_prop PG($N) -label "PG" \
	-color $color1 -line_style solid -line_width 1

echo "#########################################"
echo "Plotting BL transient characteristic"
echo "#########################################"	
create_curve -name BL($N) -dataset PLT($N) \
	-axisX time -axisY2 v(bl)
	
set_curve_prop BL($N) -label "BL" \
	-color $color2 -line_style dash -line_width 3 -axis right


