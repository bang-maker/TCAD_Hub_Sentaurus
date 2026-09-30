#setdep @previous@
if {![info exists runVisualizerNodesTogether]} {
  puts "To see some curves select some Sentaurus Visual nodes and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}

#--------------
echo "defining some parameters"
set n @node@
set tdr "n@previous@_des.tdr" 

#---------
echo "loading tdr files"
load_file $tdr -name ds($n)
create_plot -dataset ds($n)

#---------
echo "creating cutline"
set PlotName Cut
create_cutline -plot Plot_ds($n) -type x -at 0.5
create_plot -dataset C1(ds($n)) -1d -name $PlotName
set_plot_prop -hide_title
set_axis_prop -title_font_size 20 -label_font_size 14
set_axis_prop -axis x  -title {Y [<greek>m</greek>m]} 
set_axis_prop -axis y  -title {Lifetime [s]} -type log
set_legend_prop -label_font_size 16 -label_font_att bold -location top_left

select_plots $PlotName

#----------
echo "creating curve" 
create_curve -name eLifetime($n) -plot $PlotName -dataset C1(ds($n)) -axisX Y -axisY eLifetime
create_curve -name hLifetime($n) -plot $PlotName -dataset C1(ds($n)) -axisX Y -axisY hLifetime

set_curve_prop eLifetime($n) -label "eLifetime($legend)" -color $color -hide_markers \
  -line_width 3 -line_style solid
set_curve_prop hLifetime($n) -label "hLifetime($legend)" -color $color -hide_markers \
  -line_width 3 -line_style dot
