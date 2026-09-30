#setdep @node|sdevice@

#--------------
echo "defining some parameters"
set n @node@
set plt @plot@

#---------
echo "defining datasets"
set vi i(tres,n0)
set vu v(n1)
set vT t(tR)

#---------
echo "loading plt files"
load_file $plt  -name ds($n)

#---------
echo "creating plot"
if {[llength [list_plots]] <= 0} {
  create_plot -1d -name Plot_trans
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 16 -label_font_size 14
  set_axis_prop -axis x -title {time [s]} 
  set_axis_prop -axis y -title {current [A/<greek>m</greek>m], voltage [V]} 
  set_axis_prop -axis y2 -title {temperature [K]}
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
  #---
  create_plot -1d -name Plot_R
  link_plots [list_plots] -unlink
  select_plots Plot_R
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 16 -label_font_size 14
  set_axis_prop -axis x -title {temperature [K]} 
  set_axis_prop -axis y -title {resistance [<greek>W</greek> <greek>m</greek>m]} 
  set_legend_prop -label_font_size 12 -label_font_att bold -location top_left
  #---
}

#----------
echo "create transient curve" 
select_plots Plot_trans
create_curve -name cu($n) -axisX time -axisY $vu -dataset ds($n) -plot Plot_trans
create_curve -name ci($n) -axisX time -axisY $vi -dataset ds($n) -plot Plot_trans
create_curve -name cT($n) -axisX time -axisY2 $vT -dataset ds($n) -plot Plot_trans

select_plots Plot_R
create_curve -name cv -axisX $vT -axisY $vu -dataset ds($n) -plot Plot_R
create_curve -name ci -axisX $vT -axisY $vi -dataset ds($n) -plot Plot_R
create_curve -name cR($n) -function <cv>/<ci> -plot Plot_R
remove_curves {ci cv}
#----------
echo "extract R at 1V" 
set R0V [lindex [get_curve_data cR($n) -axisY] 0]
puts [format "DOE: R0V %.1f" $R0V]
set R1V [lindex [get_curve_data cR($n) -axisY] end]
puts [format "DOE: R1V %.1f" $R1V]

if {[info exists runVisualizerNodesTogether]} {
  # executed only if visualization wrapper script is used to visualize curves
  select_plots Plot_trans
  set_curve_prop cu($n) -label "U $leg" -color $color -hide_markers \
    -line_width 3 -line_style solid
  set_curve_prop ci($n) -label "I $leg" -color $color -hide_markers \
    -line_width 3 -line_style dash
  set_curve_prop cT($n) -label "T $leg" -color $color -hide_markers \
    -line_width 3 -line_style dot
  select_plots Plot_R
  set_curve_prop cR($n) -label "R $leg" -color $color -hide_markers \
  -line_width 3 -line_style solid
}
