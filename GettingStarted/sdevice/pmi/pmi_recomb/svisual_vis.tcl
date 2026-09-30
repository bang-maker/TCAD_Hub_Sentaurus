#setdep @node|sdevice@

#--------------
echo "defining some parameters"
set n @node@
set plt @plot@

#---------
echo "defining datasets"
set dsVoltage "anode OuterVoltage"
set dsCurrent "anode TotalCurrent"
set dsAuger "IntegrSemiconductor AugerRecombination"
set dsPMI "IntegrSemiconductor PMIRecombination"

#---------
echo "loading plt files"
load_file $plt -name JVdata($n)

#---------
echo "creating plot"
if {[lsearch [list_plots] Plot_JV] == -1} {
  create_plot -1d -name Plot_JV
  set_plot_prop -title "Dark IV" -title_font_size 20
  set_axis_prop -title_font_size 16 -label_font_size 14
  set_axis_prop -axis x -title {Voltage [V]} \
    -type linear -min 0 -min_fixed
  set_axis_prop -axis y -title {Current [A/<sub>m</sub>m]} \
    -type log -min 1e-20 -min_fixed
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left 
  link_plots [list_plots] -unlink
}
select_plots Plot_JV

#----------
echo "create I-V curve" 
create_curve -name JV($n) -dataset JVdata($n) -axisX $dsVoltage -axisY $dsCurrent

#----------
echo "extract integrated recombination values" 
set Rauger [lindex [get_variable_data $dsAuger -dataset JVdata($n)] end]
puts [format "DOE: Rauger %.2e" $Rauger]
set Rpmi [lindex [get_variable_data $dsPMI -dataset JVdata($n)] end]
puts [format "DOE: Rpmi %.2e" $Rpmi]

if {[info exists runVisualizerNodesTogether]} {
  # executed only if visualization wrapper script is used to visualize curves
  set_curve_prop JV($n) -label "$leg" -color $color \
    -line_width 3 -show_markers -markers_size 10 -markers_type $marker
}
