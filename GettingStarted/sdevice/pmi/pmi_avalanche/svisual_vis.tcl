#setdep @previous@
if {![info exists runVisualizerNodesTogether]} {
  puts "To see some curves select some Sentaurus Visual nodes and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}

#--------------
echo "defining some parameters"
set n @node@
set plt @plot@

#---------
echo "loading plt files"
load_file $plt  -name ds($n)

#---------
set PlotName Plot_Avalanche
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name $PlotName
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x  -title {voltage [V]} 
  set_axis_prop -axis y  -title {Current [A/&mu;m]}
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
}

#----------
echo "Create quasistationary IV curves" 
select_plots $PlotName

create_curve -name IV($n) -axisX {right InnerVoltage} -axisY {right TotalCurrent} -dataset ds($n) -plot $PlotName


if {[info exists runVisualizerNodesTogether]} {
  # executed only if visualization wrapper script is used to visualize curves
  select_plots $PlotName
 
    #if [string match -nocase @Okuto@ pmi]
      #if [string is double "@b_e@"]
      set_curve_prop IV($n) -label "$legend" -show_markers \
      -line_width 3 -line_style solid -markers_size 9
      #else
      set_curve_prop IV($n) -label "$legend" -show_markers \
      -line_width 3 -line_style solid -markers_type circle -markers_size 11
      #endif
    #else
      #if [string is double "@b_e@"]
      set_curve_prop IV($n) -label "$legend" -hide_markers \
      -line_width 3 -line_style solid
      #else
      set_curve_prop IV($n) -label "$legend" -show_markers \
      -markers_type cross -markers_size 9 -line_width 2 -hide_line
      #endif
    #endif
}


