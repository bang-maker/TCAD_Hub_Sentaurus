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
set plot2d [create_plot -dataset ds($n)]

#---------
echo "create a plot"
if {[lsearch [list_plots] Plot] == -1} {
  create_plot -1d -name Plot
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20 -label_font_size 14
  set_axis_prop -axis x  -title {Y [<greek>m</greek>m]} 
  set_axis_prop -axis y  -title {trap concentration [cm<sup>-3</sup>]} 
  set_legend_prop -label_font_size 16 -label_font_att bold -location bottom_left
}

#---------
echo "creating cutline"
create_cutline -name dscut($n) -dataset ds($n) -type x -at 0
remove_plots $plot2d
select_plots Plot

#----------
echo "creating curve" 
create_curve -name ctrap($n) -dataset dscut($n) -axisX Y \
  -axisY TrapConcentration_0(Ac,Le)

set_curve_prop ctrap($n) -label "$legend " -color $color -hide_markers \
  -line_width 3 -line_style solid
