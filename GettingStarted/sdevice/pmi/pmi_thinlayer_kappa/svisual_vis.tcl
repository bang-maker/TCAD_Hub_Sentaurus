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
set PlotName Plot_ThinLayerKappa
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name $PlotName
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x   -title {voltage [V]} 
  set_axis_prop -axis y   -title {Current [A/&mu;m]}
  set_axis_prop -axis y2  -title {T<sub>max</sub> [K]}
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
  
  set_axis_prop -plot $PlotName -axis y -type log
  set_axis_prop -plot $PlotName -axis y -min 1e-15 -min_fixed
  set_axis_prop -plot $PlotName -axis y -max 0.01 -max_fixed
}

#----------
select_plots $PlotName

create_curve -name IV($n)   -axisX "c1 InnerVoltage" -axisY  "c1 TotalCurrent" -dataset ds($n) -plot $PlotName
create_curve -name Tmax($n) -axisX "c1 InnerVoltage" -axisY2 "Tmax" -dataset ds($n) -plot $PlotName


set_curve_prop IV($n)   -label "Current: $legend"     -line_width 3 -color $color \
  -hide_markers
set_curve_prop Tmax($n) -label "Temperature: $legend" -line_width 3 -color $color \
  -show_markers -markers_size 9


