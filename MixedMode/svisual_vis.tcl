#setdep @previous@

set N @node@
echo "#########################################"
echo "Plotting Id-Vgs curve"
echo "#########################################"
load_file "@[relpath n@node|MixedMode@_sys_des.plt]@" -name PLT_Vout($N)

if {[lsearch [list_plots] Plot_Vout] == -1} {
  create_plot -1d -name Plot_Vout
}
select_plots Plot_Vout

create_curve -name Vout($N) -dataset PLT_Vout($N) -axisX "time" -axisY "v(out)"

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop Vout($N) -label "Vout $legend" \
    -color $color -line_style $line -line_width 3
  set_axis_prop -title_font_size 16 -label_font_size 14 -type linear 
  set_axis_prop -axis x -title "Time (s)" 
  set_axis_prop -axis y -title "Output Voltage (V)" 
  
  set_plot_prop -show_grid -show_legend -title_font_size 16 
  set_grid_prop -align right
  set_legend_prop -label_font_size 14 -location top_left 
  
  link_plots Plot_IdVg -unlink
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}
