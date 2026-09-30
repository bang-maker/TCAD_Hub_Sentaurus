#setdep @previous@

set n @previous@

echo "#########################################"
echo "Plotting  I-V curves"
echo "#########################################"

load_file @plot@ -name PLT($n)

if {[lsearch [list_plots] Plot_diode] == -1} {
  create_plot -1d -name Plot_diode
  link_plots Plot_diode -unlink
}
select_plots Plot_diode

create_curve -name IV($n) -dataset PLT($n) -axisX "top InnerVoltage" -axisY "top TotalCurrent"

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop IV($n) -label "$legend" \
    -color $color -line_style $line -line_width 3
  set_axis_prop -title_font_size 16 -label_font_size 14
  set_axis_prop -axis x -title "Voltage (V)" -type linear \
    -label_format fixed -manual_precision -label_precision 1
  set_axis_prop -axis y -title "Current (A)" -type log 
  
  set_plot_prop -show_grid -show_legend -title "Diode I-V's" -title_font_size 14
  set_grid_prop -align right
  set_legend_prop -label_font_size 14 -location bottom_left -label_font_att bold
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}
