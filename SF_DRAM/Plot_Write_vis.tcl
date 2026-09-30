#setdep @previous@

#set Vmax 0

set N     @node@
set i     @node:index@
  
#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

echo "#########################################"
echo "Plotting Charge-Time curve"
echo "#########################################"
load_file Write_n@node|sdevice_mixedmode@_sys_des.plt -name PLT_Cout($N)

if {[lsearch [list_plots] Plot_Cout] == -1} {
	create_plot -1d -name Plot_Cout
}
select_plots Plot_Cout

create_curve -name Vin($N) -dataset PLT_Cout($N) -axisX "time" -axisY "v(bl)"
create_curve -name Vdd($N) -dataset PLT_Cout($N) -axisX "time" -axisY "v(wl)"
create_curve -name Vout($N) -dataset PLT_Cout($N) -axisX "time" -axisY "v(sc)"

set_curve_prop Vin($N) -label "Vd_BitLine" -color blue -line_style solid -line_width 3
set_curve_prop Vdd($N) -label "Vg_WordLine" -color black -line_style solid -line_width 3
set_curve_prop Vout($N) -label "Vout_SC" -color magenta -line_style solid -line_width 3

set_axis_prop -axis x -title "Time (s)" \
	-title_font_size 16 -label_font_size 14 -type linear  -min 1e-10 -max 3e-8
set_axis_prop -axis y -title "Input Bias (V)" \
	-title_font_size 16 -label_font_size 14 -type linear  -min -0.1 -max 1.5
	
set_plot_prop -show_grid -show_legend -hide_title
set_grid_prop -align right
set_legend_prop -label_font_size 16 -location top_left -label_font_att bold

#Extract Vmax
set Vmax [lindex [get_variable_data "v(sc)" -dataset PLT_Cout($N)] end]
puts "Vmax= $Vmax"
puts "DOE: Vmax [format %.5e $Vmax]"


