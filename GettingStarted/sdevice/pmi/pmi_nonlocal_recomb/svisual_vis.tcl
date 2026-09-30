#setdep @previous@
if {![info exists runVisualizerNodesTogether]} {
  puts "To see some curves select some Sentaurus Visual nodes and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}

set N @previous@
set fname @plot@

# --------- Plotting -------------------------------------------------
# Create plot if it does not exist and set properties
if {[llength [list_plots Plot_1D]]==0} {
  create_plot -1d -name Plot_1D
  select_plots Plot_1D
  set_plot_prop -hide_title -show_legend
  set_axis_prop -title_font_size 24 -label_font_size 22  
  set_axis_prop -axis x -title "left Voltage (V)" 
  set_axis_prop -axis y -title "left Current (A)" 
  set_legend_prop -font_size 16
}

# Plot IV curve
load_file $fname -name PLT($N)
create_curve -name IV($N) -dataset PLT($N) \
  -axisX "left InnerVoltage" -axisY "left TotalCurrent" 
set_curve_prop IV($N) -label "IV($legend)" \
  -color $color -line_style solid -line_width 3

