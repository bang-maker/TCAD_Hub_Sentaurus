#setdep @previous@

# continue only if we are in interactive mode. 
if {![info exists runVisualizerNodesTogether]} {
  puts "To show curves, select the Sentaurus Visual nodes and press the \"run visualizer nodes together\" button in the toolbar."
  exit 0
}

set n @node|sprocess@

if {[llength [list_plots]] <= 0} {
  set PLT [create_plot -1d]
  set_plot_prop -show_curve_markers -hide_title
  set_axis_prop -title_font_size 16 -label_font_size 14 
  set_legend_prop -position {0.75 0.80}
}

set pexp [load_file @pwd@/exp-@select@.plx]
set Cexp($n) [create_curve -dataset $pexp -axisX {BTotal x} -axisY {BTotal y}]

set psim [load_file @[relpath n@node|sprocess@_@select@_cont.plx]@]
set Csim($n) [create_curve -dataset $psim -axisX {BTotal x} -axisY {BTotal y}]


set_curve_prop -plot $PLT "$Cexp($n)" -color $color -label "experiment $legend" \
  -line_width 2 -show_markers -markers_size 8 
set_curve_prop -plot $PLT "$Csim($n)" -color $color -label "simulation $legend" \
  -line_width 2 -hide_markers 

set_axis_prop -axis x -title {Distance [<greek>m</greek>m]} \
  -min -0.001 -min_fixed -max 0.05 -max_fixed
set_axis_prop -axis y -title {BTotal [1/cm<sup>-3</sup>]} \
  -min 1e17  -min_fixed -type log
