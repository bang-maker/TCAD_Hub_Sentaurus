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
set PlotName Plot_voltages
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name $PlotName
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x  -title {time [s]} 
  set_axis_prop -axis y  -title {voltage [V]}
  set_axis_prop -axis y2 -title {voltage ratio} 
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
}

#----------
echo "create transient curve" 
select_plots $PlotName
create_curve -name v1($n) -axisX time -axisY v(1) -dataset ds($n) -plot $PlotName
create_curve -name v2($n) -axisX time -axisY v(2) -dataset ds($n) -plot $PlotName
create_curve -name v3($n) -axisX time -axisY v(3) -dataset ds($n) -plot $PlotName
create_curve -name vi($n) -axisX time -axisY v(coupled_inst.i1) -dataset ds($n) -plot $PlotName

create_curve -name U2U3($n) -function <v3($n)>/<v2($n)> -plot $PlotName -y 2

create_curve -name U23($n)  -function 0.0*<vi($n)>+@<k*pow(L2/L1,0.5)>@ -plot $PlotName -y 2

if {[info exists runVisualizerNodesTogether]} {
  # executed only if visualization wrapper script is used to visualize curves
  select_plots $PlotName
  set_curve_prop v1($n) -label "U<sub>1</sub>" -color #00aa00 -hide_markers \
    -line_width 3 -line_style dot
  set_curve_prop v2($n) -label "U<sub>2</sub>" -color #00ff00 -hide_markers \
    -line_width 3 -line_style solid
  set_curve_prop v3($n) -label "U<sub>3</sub>" -color #ff0000 -hide_markers \
    -line_width 3 -line_style solid
  set_curve_prop vi($n) -label "U<sub>i1</sub>" -color #0000ff -hide_markers \
    -line_width 3 -line_style solid -hide
  set_curve_prop U2U3($n) -label "U<sub>3</sub>\/U<sub>2</sub>" -color magenta -show_markers \
    -line_width 1 -line_style dashdot
  set_curve_prop U23($n) -label "k*(L2/L1)<sup>1\/2</sup>" -color cyan -hide_markers \
    -line_width 3 -line_style dashdot
  
  set_axis_prop -plot $PlotName -axis y2 -min 0 -min_fixed
  set_axis_prop -plot $PlotName -axis y2 -max 3.5 -max_fixed
  set_legend_prop -plot $PlotName -location bottom_left
}
