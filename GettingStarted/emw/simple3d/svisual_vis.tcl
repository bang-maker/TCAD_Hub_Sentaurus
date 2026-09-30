#setdep @previous@
set n @previous@

#- define some dataset and variable names 
set ds  [file tail [file rootname @plot@]]
set dsDetector ${ds}_detector
set dsRTA ${ds}_sensor(RTA,transient)
set dt TickStep
# set dt Time
set dMaxDev        "MaxDeviation"
set dtol           "Tolerance"
set dR     "R"
set dT     "T"
set dA     "A"                                     
set dRTA   "RTA"

if {[llength [list_plots Plot_1D]] == 0} {
  create_plot -1d -name Plot_1D
  
  set_plot_prop -show_grid -hide_title 
  set_axis_prop -title_font_size 20 -label_font_size 18 
  set_axis_prop -axis x -title "$dt" -label_format fixed -manual_precision -label_precision 0
  set_axis_prop -axis y -title "Max. Dev., Tolerance, 1-RTA \[1\]" \
    -type log -range {1e-5 1} -min_fixed -max_fixed -label_format scientific
  set_axis_prop -axis y2 -title "R, T, A \[1\]" \
    -range {0 1} -min_fixed -max_fixed 
  set_legend_prop -location "top_left" -label_font_size 16
}

#-load emw plot file
load_file_datasets "@plot@" ;# returns the all geometries or "dataset name"

#--------------------------------------------
# plot maximum deviation versus emw timestep
#--------------------------------------------

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  if {[list_datasets $dsDetector] > 0} {
    echo "create monitor curve"             
    set MONITOR   [create_curve -dataset $dsDetector -axisX $dt -axisY $dMaxDev]
    set_curve_prop $MONITOR -color $color -line_width 2 -label "Max Dev.: $legend"
    set TOLERANCE [create_curve -dataset $dsDetector -axisX $dt -axisY $dtol]
    set_curve_prop $TOLERANCE -line_width 2 -line_style dash -color $color -label "Tolerance: $legend"
  }
  echo "create RTA curves"
  if {[list_variables -dataset $dsRTA $dR] > 0} {
    echo "create R"
    create_curve -name cR($n) -dataset $dsRTA -axisX $dt -axisY $dR
    set_curve_prop cR($n) -label "R: $legend" -color $color -show_markers -markers_type circle  -markers_size 8 -axis right
    # set_curve_prop cR($n) -hide
  }
  if {[list_variables -dataset $dsRTA $dT] > 0} {
    echo "create T"
    create_curve -name cT($n) -dataset $dsRTA -axisX $dt -axisY $dT
    set_curve_prop cT($n) -label "T: $legend" -color $color -show_markers -markers_type square  -markers_size 8 -axis right
    # set_curve_prop cT($n) -hide
  }
  if {[list_variables -dataset $dsRTA $dA] > 0} {
    echo "create A"
    create_curve -name cA($n) -dataset $dsRTA -axisX $dt -axisY $dA
    set_curve_prop cA($n) -label "A: $legend" -color $color -show_markers -markers_type diamond -markers_size 8 -axis right
    # set_curve_prop cA($n) -hide
  }                                                                   
  if {[list_variables -dataset $dsRTA $dRTA] > 0} {
    echo "create RTA"
    create_curve -name cRTA($n) -dataset $dsRTA -axisX $dt -axisY $dRTA
    set_curve_prop cRTA($n) -hide
    create_curve -name c1_RTA($n) -function "1-<cRTA($n)>"
    set_curve_prop c1_RTA($n) -label "1-RTA: $legend" -color $color -show_markers -markers_type cross -line_width 4
  }
  
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}