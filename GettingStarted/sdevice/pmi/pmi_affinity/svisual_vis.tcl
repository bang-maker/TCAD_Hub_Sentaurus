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
set PlotName Plot_Affinity
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name $PlotName
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x  -title {Temperature [K]} 
  set_axis_prop -axis y  -title {Affinity [eV]}
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
  set_axis_prop -plot $PlotName -axis y -min 4.03 -min_fixed
  set_axis_prop -plot $PlotName -axis y -max 4.13 -max_fixed
}

#----------
echo "Create quasistationary Affinity curves probed close to cathode" 
select_plots $PlotName
create_curve -name affinity($n) -axisX {cathode Temperature} -axisY {Pos(0.05,0.001) ElectronAffinity} -dataset ds($n) -plot $PlotName


if {[info exists runVisualizerNodesTogether]} {
  # executed only if visualization wrapper script is used to visualize curves
  select_plots $PlotName
  
  #if [string match -nocase @Affinity@ pmi]
    #if [string is double "@delta@"]
    set_curve_prop affinity($n) -label "@Affinity@(<greek>D</greek>=@delta@)" -hide_markers \
      -line_width 3 -line_style solid -markers_size 9
    #else
    set_curve_prop affinity($n) -label "@Affinity@(<greek>D</greek>=0.5(@delta@))" -hide_markers \
      -line_width 3 -line_style solid -markers_type circle -markers_size 11
    #endif
  #else
  set_curve_prop affinity($n) -label "builtin model" -show_markers \
    -line_width 3 -line_style solid
  #endif
}

