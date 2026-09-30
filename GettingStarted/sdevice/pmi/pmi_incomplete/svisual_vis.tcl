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
set PlotName Plot_AlMinus
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name $PlotName
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x  -title {Temperature [K]} 
  set_axis_prop -axis y  -title {AlMinusDoping [cm<sup>-3</sup>]}
  set_legend_prop -label_font_size 16 -label_font_att bold -location top_left
}

#----------
echo "create curve" 
select_plots $PlotName
create_curve -name AlMin($n) -axisX {Pos(0.5,0.5) LatticeTemperature} -axisY {Pos(0.5,0.5) AlMinusDoping} -dataset ds($n) -plot $PlotName

set_curve_prop AlMin($n) -label "AlMinusDoping $legend" -color $color -hide_markers \
  -line_width 3 -line_style solid
