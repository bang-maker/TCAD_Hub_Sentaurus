#setdep @node|AC@
set N     @node@
echo "#########################################"
echo "Plotting C-Vgs curve"
echo "#########################################"
load_file @[relpath n@node|AC@_ac_des.plt]@ -name PLT_Cg($N)

if {[lsearch [list_plots] Plot_Cg] == -1} {
  create_plot -1d -name Plot_Cg
  set_axis_prop -title_font_size 14 -label_font_size 14 -type linear 
  set_axis_prop -axis x -title "Gate Voltage (V)"
  set_axis_prop -axis y -title "Capacitance (F)" 
  
  set_plot_prop -show_legend -title_font_size 14
  set_legend_prop -label_font_size 14 -location top_right 
}
select_plots Plot_Cg

create_curve -name Cg($N) -dataset PLT_Cg($N) -axisX "v(g)" -axisY "c(g,g)"

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop Cg($N) -label "Cg(AC) $legend" \
    -color $color -line_style dash -line_width 3
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}
